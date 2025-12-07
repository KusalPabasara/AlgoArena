/**
 * Event Controller - CRUD operations for events
 * Webmasters can create/edit/delete events for their clubs/districts
 */

const firestoreService = require('../services/firestore.service');

// @desc    Get all events
// @route   GET /api/events
// @access  Protected
exports.getAllEvents = async (req, res) => {
  try {
    const events = await firestoreService.getAll('events');
    
    // Sort by date (newest first)
    events.sort((a, b) => {
      const dateA = a.eventDate ? new Date(a.eventDate) : new Date(a.createdAt);
      const dateB = b.eventDate ? new Date(b.eventDate) : new Date(b.createdAt);
      return dateB - dateA;
    });

    // Check events for closing/expiring notifications (async, don't wait)
    try {
      const { checkEventsForNotifications } = require('./notification.controller');
      checkEventsForNotifications().catch(err => {
        console.error('Background event notification check failed:', err);
      });
    } catch (notifError) {
      // Silently fail - notifications are not critical
    }

    res.json(events);
  } catch (error) {
    console.error('Get all events error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get events by club ID
// @route   GET /api/events/club/:clubId
// @access  Protected
exports.getEventsByClub = async (req, res) => {
  try {
    const { clubId } = req.params;
    const events = await firestoreService.query('events', 'clubId', '==', clubId);
    
    events.sort((a, b) => {
      const dateA = a.eventDate ? new Date(a.eventDate) : new Date(a.createdAt);
      const dateB = b.eventDate ? new Date(b.eventDate) : new Date(b.createdAt);
      return dateB - dateA;
    });

    res.json(events);
  } catch (error) {
    console.error('Get events by club error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get events by district ID
// @route   GET /api/events/district/:districtId
// @access  Protected
exports.getEventsByDistrict = async (req, res) => {
  try {
    const { districtId } = req.params;
    const events = await firestoreService.query('events', 'districtId', '==', districtId);
    
    events.sort((a, b) => {
      const dateA = a.eventDate ? new Date(a.eventDate) : new Date(a.createdAt);
      const dateB = b.eventDate ? new Date(b.eventDate) : new Date(b.createdAt);
      return dateB - dateA;
    });

    res.json(events);
  } catch (error) {
    console.error('Get events by district error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get event by ID
// @route   GET /api/events/:id
// @access  Protected
exports.getEventById = async (req, res) => {
  try {
    const event = await firestoreService.getById('events', req.params.id);

    if (!event) {
      return res.status(404).json({ message: 'Event not found' });
    }

    // Check this specific event for closing/expiring notifications (async, don't wait)
    (async () => {
      try {
        const now = new Date();
        if (event.eventDate && event.isActive) {
          const eventDate = new Date(event.eventDate);
          const hoursUntilEvent = (eventDate - now) / (1000 * 60 * 60);
          const daysSinceEvent = (now - eventDate) / (1000 * 60 * 60 * 24);
          
          const existingNotifications = await firestoreService.getAll('notifications');
          
          // Check if event is closing soon (within 24 hours)
          if (hoursUntilEvent > 0 && hoursUntilEvent <= 24) {
            const hasClosingNotif = existingNotifications.some(n => 
              n.eventId === event.id && n.type === 'event_closing'
            );
            
            if (!hasClosingNotif) {
              const { createNotificationHelper } = require('./notification.controller');
              await createNotificationHelper(
                'event_closing',
                'Event Closing Soon',
                `The event "${event.title}" is closing soon. Join now before it expires!`,
                {
                  iconUrl: event.bannerImage || event.pageLogo,
                  pageId: event.pageId,
                  eventId: event.id,
                }
              );
            }
          }
          
          // Check if event has expired (within last 24 hours)
          if (daysSinceEvent > 0 && daysSinceEvent <= 1) {
            const hasExpiredNotif = existingNotifications.some(n => 
              n.eventId === event.id && n.type === 'event_expired'
            );
            
            if (!hasExpiredNotif) {
              const { createNotificationHelper } = require('./notification.controller');
              await createNotificationHelper(
                'event_expired',
                'Event Expired',
                `The event "${event.title}" has expired.`,
                {
                  iconUrl: event.bannerImage || event.pageLogo,
                  pageId: event.pageId,
                  eventId: event.id,
                }
              );
            }
          }
        }
      } catch (notifError) {
        // Silently fail - notifications are not critical
        console.error('Error checking event notifications:', notifError);
      }
    })();

    // Get organizer info
    if (event.organizerId) {
      const organizer = await firestoreService.getById('users', event.organizerId);
      if (organizer) {
        event.organizer = {
          id: event.organizerId,
          fullName: organizer.fullName,
          profilePhoto: organizer.profilePhoto,
        };
      }
    }

    // Get club info if applicable
    if (event.clubId) {
      const club = await firestoreService.getById('clubs', event.clubId);
      if (club) {
        event.club = {
          id: event.clubId,
          name: club.name,
          logo: club.logo,
        };
      }
    }

    // Get district info if applicable
    if (event.districtId) {
      const district = await firestoreService.getById('districts', event.districtId);
      if (district) {
        event.district = {
          id: event.districtId,
          name: district.name,
          logo: district.logo,
        };
      }
    }

    res.json(event);
  } catch (error) {
    console.error('Get event by ID error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Create event
// @route   POST /api/events
// @access  Protected (webmaster, admin, super_admin)
exports.createEvent = async (req, res) => {
  try {
    const {
      title,
      description,
      eventDate,
      eventTime,
      location,
      clubId,
      districtId,
      pageId,
      bannerImage,
      documents,
      category,
      maxParticipants,
    } = req.body;

    // Require pageId - events can only be created from pages
    if (!pageId) {
      return res.status(400).json({ 
        message: 'Page ID is required. Events can only be created from club/district pages.' 
      });
    }

    // Get the page
    const page = await firestoreService.getById('pages', pageId);
    if (!page) {
      return res.status(404).json({ message: 'Page not found' });
    }

    // Get user's Leo ID
    const userData = await firestoreService.getById('users', req.user.id);
    const userLeoId = userData?.leoId;

    // Check if user is webmaster of this page or super admin
    const isWebmaster = userLeoId && (page.webmasterIds || []).includes(userLeoId);
    const isSuperAdmin = req.user.role === 'superadmin' || req.user.role === 'super_admin';

    if (!isWebmaster && !isSuperAdmin) {
      return res.status(403).json({ 
        message: 'Only webmasters of this page can create events. You must be assigned as a webmaster for this page.' 
      });
    }

    // Validate required fields
    if (!title || !eventDate) {
      return res.status(400).json({ message: 'Title and event date are required' });
    }

    const now = new Date();
    const eventData = {
      title,
      description: description || '',
      eventDate,
      eventTime: eventTime || '',
      location: location || '',
      clubId: page.clubId || null,
      districtId: page.districtId || null,
      pageId: pageId,
      bannerImage: bannerImage || null,
      documents: documents || [], // Store document URLs
      category: category || 'general',
      maxParticipants: maxParticipants || null,
      organizerId: page.id, // Use page ID as organizer ID
      organizerName: page.name, // Use page name instead of user name
      pageName: page.name, // Store page name
      pageLogo: page.logo || null, // Store page logo
      participants: [],
      participantsCount: 0,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    };

    const event = await firestoreService.create('events', eventData);

    console.log(`📅 Event created: "${title}" for page "${page.name}" by webmaster ${req.user.fullName}`);

    // Create notification for event creation
    try {
      const { createNotificationHelper } = require('./notification.controller');
      await createNotificationHelper(
        'event_created',
        'New Event Created',
        `A new event "${title}" has been created by ${page.name}.`,
        {
          iconUrl: page.logo || bannerImage,
          pageId: page.id,
          eventId: event.id,
        }
      );
    } catch (notifError) {
      console.error('Error creating event notification:', notifError);
      // Don't fail the request if notification creation fails
    }

    res.status(201).json({
      message: 'Event created successfully',
      event: { id: event.id, ...eventData },
    });
  } catch (error) {
    console.error('Create event error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Update event
// @route   PUT /api/events/:id
// @access  Protected (organizer or admin only)
exports.updateEvent = async (req, res) => {
  try {
    const event = await firestoreService.getById('events', req.params.id);

    if (!event) {
      return res.status(404).json({ message: 'Event not found' });
    }

    // Check if user is organizer or admin
    const isOrganizer = event.organizerId === req.user.id;
    const isAdmin = ['admin', 'super_admin', 'superadmin'].includes(req.user.role);

    if (!isOrganizer && !isAdmin) {
      return res.status(403).json({ message: 'Not authorized to update this event' });
    }

    const {
      title,
      description,
      eventDate,
      eventTime,
      location,
      bannerImage,
      documents,
      category,
      maxParticipants,
      isActive,
    } = req.body;

    const updates = {
      updatedAt: new Date(),
    };

    if (title !== undefined) updates.title = title;
    if (description !== undefined) updates.description = description;
    if (eventDate !== undefined) updates.eventDate = eventDate;
    if (eventTime !== undefined) updates.eventTime = eventTime;
    if (location !== undefined) updates.location = location;
    if (bannerImage !== undefined) updates.bannerImage = bannerImage;
    if (documents !== undefined) updates.documents = documents;
    if (category !== undefined) updates.category = category;
    if (maxParticipants !== undefined) updates.maxParticipants = maxParticipants;
    if (isActive !== undefined) updates.isActive = isActive;

    await firestoreService.update('events', req.params.id, updates);

    res.json({
      message: 'Event updated successfully',
      event: { id: req.params.id, ...event, ...updates },
    });
  } catch (error) {
    console.error('Update event error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Delete event
// @route   DELETE /api/events/:id
// @access  Protected (organizer or admin only)
exports.deleteEvent = async (req, res) => {
  try {
    const event = await firestoreService.getById('events', req.params.id);

    if (!event) {
      return res.status(404).json({ message: 'Event not found' });
    }

    // Check if user is organizer or admin
    const isOrganizer = event.organizerId === req.user.id;
    const isAdmin = ['admin', 'super_admin', 'superadmin'].includes(req.user.role);

    if (!isOrganizer && !isAdmin) {
      return res.status(403).json({ message: 'Not authorized to delete this event' });
    }

    await firestoreService.delete('events', req.params.id);

    res.json({ message: 'Event deleted successfully' });
  } catch (error) {
    console.error('Delete event error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Join/Leave event
// @route   PUT /api/events/:id/participate
// @access  Protected
exports.toggleParticipation = async (req, res) => {
  try {
    const event = await firestoreService.getById('events', req.params.id);

    if (!event) {
      return res.status(404).json({ message: 'Event not found' });
    }

    const participants = event.participants || [];
    const userId = req.user.id;
    
    // Check if user is already a participant (handle both old format [userId] and new format [{userId, ...}])
    const isParticipant = participants.some(p => {
      if (typeof p === 'string') return p === userId;
      return p.userId === userId || p.id === userId;
    });

    let updatedParticipants;
    let message;

    if (isParticipant) {
      // Leave event - remove participant
      updatedParticipants = participants.filter(p => {
        if (typeof p === 'string') return p !== userId;
        return (p.userId || p.id) !== userId;
      });
      message = 'Left event successfully';
    } else {
      // Check max participants
      if (event.maxParticipants && participants.length >= event.maxParticipants) {
        return res.status(400).json({ message: 'Event is full' });
      }
      
      // Join event - store participant data
      const { name, email, phone, notes } = req.body;
      const participantData = {
        userId: userId,
        id: userId, // For backward compatibility
        name: name || req.user.fullName || 'Unknown',
        email: email || req.user.email || '',
        phone: phone || req.user.phoneNumber || '',
        notes: notes || '',
        joinedAt: new Date(),
      };
      
      updatedParticipants = [...participants, participantData];
      message = 'Joined event successfully';
    }

    await firestoreService.update('events', req.params.id, {
      participants: updatedParticipants,
      participantsCount: updatedParticipants.length,
      updatedAt: new Date(),
    });

    res.json({
      message,
      isParticipant: !isParticipant,
      participantsCount: updatedParticipants.length,
    });
  } catch (error) {
    console.error('Toggle participation error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get registered users for an event (webmaster only)
// @route   GET /api/events/:id/participants
// @access  Protected (webmaster or admin only)
exports.getEventParticipants = async (req, res) => {
  try {
    const event = await firestoreService.getById('events', req.params.id);

    if (!event) {
      return res.status(404).json({ message: 'Event not found' });
    }

    // Check if user is organizer, webmaster of the page, or admin
    const isOrganizer = event.organizerId === req.user.id;
    const isAdmin = ['admin', 'super_admin', 'superadmin'].includes(req.user.role);
    
    let isWebmaster = false;
    if (event.pageId) {
      const page = await firestoreService.getById('pages', event.pageId);
      if (page) {
        const userData = await firestoreService.getById('users', req.user.id);
        const userLeoId = userData?.leoId;
        isWebmaster = userLeoId && (page.webmasterIds || []).includes(userLeoId);
      }
    }

    if (!isOrganizer && !isAdmin && !isWebmaster) {
      return res.status(403).json({ message: 'Not authorized to view participants' });
    }

    // Get participant data
    const participants = event.participants || [];
    const participantsData = await Promise.all(
      participants.map(async (participant) => {
        // Handle both old format (string userId) and new format (object with data)
        let userId, participantInfo;
        
        if (typeof participant === 'string') {
          // Old format - just userId string
          userId = participant;
          const user = await firestoreService.getById('users', userId);
          if (!user) return null;
          participantInfo = {
            id: userId,
            userId: userId,
            fullName: user.fullName,
            email: user.email,
            profilePhoto: user.profilePhoto || null,
            phoneNumber: user.phoneNumber || null,
            notes: null,
            joinedAt: null,
          };
        } else {
          // New format - object with form data
          userId = participant.userId || participant.id;
          const user = await firestoreService.getById('users', userId);
          participantInfo = {
            id: userId,
            userId: userId,
            fullName: participant.name || user?.fullName || 'Unknown',
            email: participant.email || user?.email || '',
            profilePhoto: user?.profilePhoto || null,
            phoneNumber: participant.phone || user?.phoneNumber || null,
            notes: participant.notes || null,
            joinedAt: participant.joinedAt || null,
          };
        }
        
        return participantInfo;
      })
    );

    res.json({
      eventId: event.id,
      eventTitle: event.title,
      participants: participantsData.filter(p => p !== null),
      participantsCount: participantsData.filter(p => p !== null).length,
    });
  } catch (error) {
    console.error('Get event participants error:', error);
    res.status(500).json({ message: error.message });
  }
};
