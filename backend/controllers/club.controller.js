const Club = require('../models/Club');

// @desc    Get all clubs
// @route   GET /api/clubs
// @access  Private
exports.getAllClubs = async (req, res) => {
  try {
    const clubs = await Club.find()
      .populate('admin', 'fullName email')
      .populate('district', 'name location')
      .sort({ name: 1 });

    res.json(clubs);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get club by ID
// @route   GET /api/clubs/:id
// @access  Private
exports.getClubById = async (req, res) => {
  try {
    const club = await Club.findById(req.params.id)
      .populate('admin', 'fullName email profilePhoto')
      .populate('district', 'name location')
      .populate('members', 'fullName email profilePhoto');

    if (!club) {
      return res.status(404).json({ message: 'Club not found' });
    }

    res.json(club);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get clubs by district
// @route   GET /api/clubs/district/:districtId
// @access  Private
exports.getClubsByDistrict = async (req, res) => {
  try {
    const clubs = await Club.find({ district: req.params.districtId })
      .populate('admin', 'fullName email')
      .sort({ name: 1 });

    res.json(clubs);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Create club
// @route   POST /api/clubs
// @access  Private (Admin only)
exports.createClub = async (req, res) => {
  try {
    const { name, description, location, district } = req.body;

    const club = await Club.create({
      name,
      description,
      location,
      district,
      admin: req.user.id,
      members: [req.user.id]
    });

    const populatedClub = await Club.findById(club._id)
      .populate('admin', 'fullName email')
      .populate('district', 'name location');

    res.status(201).json(populatedClub);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
