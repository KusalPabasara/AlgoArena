const express = require('express');
const router = express.Router();
const {
  getAllNotifications,
  createNotification,
  markAsRead,
  markAllAsRead,
  getUnreadCount,
} = require('../controllers/notification.controller');
const { protect } = require('../middleware/auth');

router.get('/', protect, getAllNotifications);
router.post('/', protect, createNotification);
router.put('/:id/read', protect, markAsRead);
router.put('/read-all', protect, markAllAsRead);
router.get('/unread-count', protect, getUnreadCount);

module.exports = router;


