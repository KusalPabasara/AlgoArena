const firestoreService = require('../services/firestore.service');

// @desc    Get all clubs
// @route   GET /api/clubs
// @access  Private
exports.getAllClubs = async (req, res) => {
  try {
    const clubs = await firestoreService.getAll('clubs', {
      orderBy: ['name', 'asc']
    });

    // Populate admin and district data
    const clubsWithData = await Promise.all(
      clubs.map(async (club) => {
        const admin = await firestoreService.getById('users', club.adminId);
        const district = await firestoreService.getById('districts', club.districtId);
        return {
          ...club,
          admin: admin ? { id: club.adminId, fullName: admin.fullName, email: admin.email } : null,
          district: district ? { id: club.districtId, name: district.name, location: district.location } : null
        };
      })
    );

    res.json(clubsWithData);
  } catch (error) {
    console.error('Get all clubs error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get club by ID
// @route   GET /api/clubs/:id
// @access  Private
exports.getClubById = async (req, res) => {
  try {
    const club = await firestoreService.getById('clubs', req.params.id);

    if (!club) {
      return res.status(404).json({ message: 'Club not found' });
    }

    // Populate admin, district, and members data
    const admin = await firestoreService.getById('users', club.adminId);
    const district = await firestoreService.getById('districts', club.districtId);
    
    const members = await Promise.all(
      (club.memberIds || []).map(async (memberId) => {
        const member = await firestoreService.getById('users', memberId);
        return member ? {
          id: memberId,
          fullName: member.fullName,
          email: member.email,
          profilePhoto: member.profilePhoto
        } : null;
      })
    );

    res.json({
      ...club,
      admin: admin ? { id: club.adminId, fullName: admin.fullName, email: admin.email, profilePhoto: admin.profilePhoto } : null,
      district: district ? { id: club.districtId, name: district.name, location: district.location } : null,
      members: members.filter(Boolean)
    });
  } catch (error) {
    console.error('Get club by ID error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get clubs by district
// @route   GET /api/clubs/district/:districtId
// @access  Private
exports.getClubsByDistrict = async (req, res) => {
  try {
    const clubs = await firestoreService.getClubsByDistrict(req.params.districtId);

    // Populate admin data
    const clubsWithAdmin = await Promise.all(
      clubs.map(async (club) => {
        const admin = await firestoreService.getById('users', club.adminId);
        return {
          ...club,
          admin: admin ? { id: club.adminId, fullName: admin.fullName, email: admin.email } : null
        };
      })
    );

    res.json(clubsWithAdmin);
  } catch (error) {
    console.error('Get clubs by district error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Create club
// @route   POST /api/clubs
// @access  Private (Admin only)
exports.createClub = async (req, res) => {
  try {
    const { name, description, location, districtId } = req.body;

    const clubData = {
      name,
      description: description || '',
      location,
      districtId,
      adminId: req.user.id,
      memberIds: [req.user.id],
      logo: null
    };

    const club = await firestoreService.create('clubs', clubData);

    // Populate admin and district data
    const admin = await firestoreService.getById('users', req.user.id);
    const district = await firestoreService.getById('districts', districtId);

    res.status(201).json({
      ...club,
      admin: admin ? { id: req.user.id, fullName: admin.fullName, email: admin.email } : null,
      district: district ? { id: districtId, name: district.name, location: district.location } : null
    });
  } catch (error) {
    console.error('Create club error:', error);
    res.status(500).json({ message: error.message });
  }
};
