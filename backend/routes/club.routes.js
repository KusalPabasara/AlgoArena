const express = require('express');
const router = express.Router();
const {
  getAllClubs,
  getClubById,
  getClubsByDistrict,
  createClub
} = require('../controllers/club.controller');
const { protect, authorize } = require('../middleware/auth');

router.get('/', protect, getAllClubs);
router.get('/:id', protect, getClubById);
router.get('/district/:districtId', protect, getClubsByDistrict);
router.post('/', protect, authorize('admin', 'super_admin'), createClub);

module.exports = router;
