/**
 * Notification Controller - CRUD operations for notifications
 */

const firestoreService = require('../services/firestore.service');

// @desc    Get all notifications for current user
// @route   GET /api/notifications
// @access  Protected
exports.getAllNotifications = async (req, res) => {
  try {
    const userId = req.user.id;
    
    // Get all notifications for this user, sorted by createdAt descending
    const notifications = await firestoreService.getAll('notifications', {
      orderBy: ['createdAt', 'desc']
    });
    
    // Filter notifications for this user (all users can see all notifications for now)
    // In the future, you might want to filter by userId or make notifications user-specific
    const userNotifications = notifications.filter(notif => {
      // For now, return all notifications
      // Later, you can add userId field to notifications and filter by it
      return true;
    });
    
    res.json(userNotifications);
  } catch (error) {
    console.error('Get all notifications error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Create notification
// @route   POST /api/notifications
// @access  Protected (admin/system only - usually called internally)
exports.createNotification = async (req, res) => {
  try {
    const {
      type,
      title,
      message,
      iconUrl,
      pageId,
      eventId,
      userId, // Optional: specific user, if null, notification is for all users
    } = req.body;

    if (!type || !title || !message) {
      return res.status(400).json({ message: 'Type, title, and message are required' });
    }

    const now = new Date();
    const notificationData = {
      type,
      title,
      message,
      iconUrl: iconUrl || null,
      pageId: pageId || null,
      eventId: eventId || null,
      userId: userId || null, // null means notification is for all users
      isRead: false,
      createdAt: now,
      updatedAt: now,
    };

    const notification = await firestoreService.create('notifications', notificationData);

    res.status(201).json({
      message: 'Notification created successfully',
      notification: {
        id: notification.id,
        ...notificationData,
        createdAt: now.toISOString(),
        updatedAt: now.toISOString(),
      },
    });
  } catch (error) {
    console.error('Create notification error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Mark notification as read
// @route   PUT /api/notifications/:id/read
// @access  Protected
exports.markAsRead = async (req, res) => {
  try {
    const notificationId = req.params.id;
    const userId = req.user.id;

    const notification = await firestoreService.getById('notifications', notificationId);
    if (!notification) {
      return res.status(404).json({ message: 'Notification not found' });
    }

    await firestoreService.update('notifications', notificationId, {
      isRead: true,
      updatedAt: new Date(),
    });

    res.json({ message: 'Notification marked as read' });
  } catch (error) {
    console.error('Mark notification as read error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Mark all notifications as read
// @route   PUT /api/notifications/read-all
// @access  Protected
exports.markAllAsRead = async (req, res) => {
  try {
    const userId = req.user.id;
    
    // Get all unread notifications
    const notifications = await firestoreService.getAll('notifications');
    const unreadNotifications = notifications.filter(n => !n.isRead);
    
    // Mark all as read
    for (const notif of unreadNotifications) {
      await firestoreService.update('notifications', notif.id, {
        isRead: true,
        updatedAt: new Date(),
      });
    }

    res.json({ 
      message: 'All notifications marked as read',
      count: unreadNotifications.length,
    });
  } catch (error) {
    console.error('Mark all notifications as read error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get unread count
// @route   GET /api/notifications/unread-count
// @access  Protected
exports.getUnreadCount = async (req, res) => {
  try {
    const notifications = await firestoreService.getAll('notifications');
    const unreadCount = notifications.filter(n => !n.isRead).length;
    
    res.json({ count: unreadCount });
  } catch (error) {
    console.error('Get unread count error:', error);
    res.status(500).json({ message: error.message });
  }
};

// Helper function to create notification (called from other controllers)
exports.createNotificationHelper = async (type, title, message, options = {}) => {
  try {
    const {
      iconUrl,
      pageId,
      eventId,
      userId,
    } = options;

    const now = new Date();
    const notificationData = {
      type,
      title,
      message,
      iconUrl: iconUrl || null,
      pageId: pageId || null,
      eventId: eventId || null,
      userId: userId || null,
      isRead: false,
      createdAt: now,
      updatedAt: now,
    };

    await firestoreService.create('notifications', notificationData);
    console.log(`📢 Notification created: ${title}`);
  } catch (error) {
    console.error('Error creating notification:', error);
    // Don't throw - notifications are not critical
  }
};

// Helper function to check events and create closing/expired notifications
exports.checkEventsForNotifications = async () => {
  try {
    const firestoreService = require('../services/firestore.service');
    const events = await firestoreService.getAll('events');
    const now = new Date();
    
    // Check if notification already exists for an event (to avoid duplicates)
    const existingNotifications = await firestoreService.getAll('notifications');
    
    for (const event of events) {
      if (!event.eventDate || !event.isActive) continue;
      
      try {
        const eventDate = new Date(event.eventDate);
        const hoursUntilEvent = (eventDate - now) / (1000 * 60 * 60);
        const daysSinceEvent = (now - eventDate) / (1000 * 60 * 60 * 24);
        
        // Check if event is closing soon (within 24 hours)
        if (hoursUntilEvent > 0 && hoursUntilEvent <= 24) {
          // Check if we already created a closing notification for this event
          const hasClosingNotif = existingNotifications.some(n => 
            n.eventId === event.id && n.type === 'event_closing'
          );
          
          if (!hasClosingNotif) {
            await exports.createNotificationHelper(
              'event_closing',
              'Event Closing Soon',
              `The event "${event.title}" is closing soon. Join now before it expires!`,
              {
                iconUrl: event.bannerImage || event.pageLogo,
                pageId: event.pageId,
                eventId: event.id,
              }
            );
            console.log(`⏰ Closing notification created for event: ${event.title}`);
          }
        }
        
        // Check if event has expired (within last 24 hours to avoid duplicate notifications)
        if (daysSinceEvent > 0 && daysSinceEvent <= 1) {
          // Check if we already created an expired notification for this event
          const hasExpiredNotif = existingNotifications.some(n => 
            n.eventId === event.id && n.type === 'event_expired'
          );
          
          if (!hasExpiredNotif) {
            await exports.createNotificationHelper(
              'event_expired',
              'Event Expired',
              `The event "${event.title}" has expired.`,
              {
                iconUrl: event.bannerImage || event.pageLogo,
                pageId: event.pageId,
                eventId: event.id,
              }
            );
            console.log(`⏱️ Expired notification created for event: ${event.title}`);
          }
        }
      } catch (eventError) {
        console.error(`Error processing event ${event.id}:`, eventError);
        // Continue with next event
      }
    }
  } catch (error) {
    console.error('Error checking events for notifications:', error);
    // Don't throw - this is a background task
  }
};


