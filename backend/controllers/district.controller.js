const District = require('../models/District');

// @desc    Get all districts
// @route   GET /api/districts
// @access  Private
exports.getAllDistricts = async (req, res) => {
  try {
    const districts = await District.find()
      .populate('admin', 'fullName email')
      .populate('clubs', 'name logo location')
      .sort({ name: 1 });

    res.json(districts);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get district by ID
// @route   GET /api/districts/:id
// @access  Private
exports.getDistrictById = async (req, res) => {
  try {
    const district = await District.findById(req.params.id)
      .populate('admin', 'fullName email profilePhoto')
      .populate('clubs', 'name logo description location members');

    if (!district) {
      return res.status(404).json({ message: 'District not found' });
    }

    res.json(district);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Create district
// @route   POST /api/districts
// @access  Private (Super Admin only)
exports.createDistrict = async (req, res) => {
  try {
    const { name, location } = req.body;

    const district = await District.create({
      name,
      location,
      admin: req.user.id
    });

    const populatedDistrict = await District.findById(district._id)
      .populate('admin', 'fullName email');

    res.status(201).json(populatedDistrict);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
