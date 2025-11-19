const express = require('express');
const router = express.Router();
const {
  getAllDistricts,
  getDistrictById,
  createDistrict
} = require('../controllers/district.controller');
const { protect, authorize } = require('../middleware/auth');

router.get('/', protect, getAllDistricts);
router.get('/:id', protect, getDistrictById);
router.post('/', protect, authorize('super_admin'), createDistrict);

module.exports = router;
