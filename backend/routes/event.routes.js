const express = require('express');
const router = express.Router();
const {
  getAllEvents,
  getEventById,
  getEventsByClub,
  getEventsByDistrict,
  createEvent,
  updateEvent,
  deleteEvent,
  toggleParticipation,
} = require('../controllers/event.controller');
const { protect } = require('../middleware/auth');

// All routes are protected
router.use(protect);

// Get all events
router.get('/', getAllEvents);

// Get events by club
router.get('/club/:clubId', getEventsByClub);

// Get events by district
router.get('/district/:districtId', getEventsByDistrict);

// Get single event
router.get('/:id', getEventById);

// Create event (webmaster/admin only - checked in controller)
router.post('/', createEvent);

// Update event
router.put('/:id', updateEvent);

// Delete event
router.delete('/:id', deleteEvent);

// Join/Leave event
router.put('/:id/participate', toggleParticipation);

module.exports = router;
