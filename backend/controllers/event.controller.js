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
      bannerImage,
      category,
      maxParticipants,
    } = req.body;

    // Check if user is webmaster or admin
    const allowedRoles = ['webmaster', 'admin', 'super_admin', 'superadmin'];
    if (!allowedRoles.includes(req.user.role) && !req.user.isVerified) {
      return res.status(403).json({ 
        message: 'Only verified webmasters can create events' 
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
      clubId: clubId || null,
      districtId: districtId || null,
      bannerImage: bannerImage || null,
      category: category || 'general',
      maxParticipants: maxParticipants || null,
      organizerId: req.user.id,
      organizerName: req.user.fullName || 'Unknown',
      participants: [],
      participantsCount: 0,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    };

    const event = await firestoreService.create('events', eventData);

    console.log(`📅 Event created: "${title}" by ${req.user.fullName}`);

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
    const isParticipant = participants.includes(userId);

    let updatedParticipants;
    let message;

    if (isParticipant) {
      // Leave event
      updatedParticipants = participants.filter(id => id !== userId);
      message = 'Left event successfully';
    } else {
      // Check max participants
      if (event.maxParticipants && participants.length >= event.maxParticipants) {
        return res.status(400).json({ message: 'Event is full' });
      }
      // Join event
      updatedParticipants = [...participants, userId];
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
