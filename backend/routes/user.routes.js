const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth');
const firestoreService = require('../services/firestore.service');

// @desc    Get user by ID
// @route   GET /api/users/:id
// @access  Private
router.get('/:id', protect, async (req, res) => {
  try {
    const user = await firestoreService.getById('users', req.params.id);

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Get club and district data if they exist
    let club = null;
    let district = null;

    if (user.clubId) {
      club = await firestoreService.getById('clubs', user.clubId);
    }

    if (user.districtId) {
      district = await firestoreService.getById('districts', user.districtId);
    }

    res.json({
      id: req.params.id,
      ...user,
      club: club ? { id: user.clubId, name: club.name, logo: club.logo } : null,
      district: district ? { id: user.districtId, name: district.name, location: district.location } : null
    });
  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({ message: error.message });
  }
});

// @desc    Update user profile
// @route   PUT /api/users/:id
// @access  Private
router.put('/:id', protect, async (req, res) => {
  try {
    if (req.user.id !== req.params.id) {
      return res.status(403).json({ message: 'Not authorized' });
    }

    const { fullName, bio, profilePhoto, clubId, districtId } = req.body;

    const updateData = {};
    if (fullName !== undefined) updateData.fullName = fullName;
    if (bio !== undefined) updateData.bio = bio;
    if (profilePhoto !== undefined) updateData.profilePhoto = profilePhoto;
    if (clubId !== undefined) updateData.clubId = clubId;
    if (districtId !== undefined) updateData.districtId = districtId;

    await firestoreService.update('users', req.params.id, updateData);

    const updatedUser = await firestoreService.getById('users', req.params.id);

    res.json({
      id: req.params.id,
      ...updatedUser
    });
  } catch (error) {
    console.error('Update user error:', error);
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;

