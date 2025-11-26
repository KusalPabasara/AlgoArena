const firestoreService = require('../services/firestore.service');

// @desc    Get all districts
// @route   GET /api/districts
// @access  Private
exports.getAllDistricts = async (req, res) => {
  try {
    const districts = await firestoreService.getAll('districts', {
      orderBy: ['name', 'asc']
    });

    // Populate admin and clubs data
    const districtsWithData = await Promise.all(
      districts.map(async (district) => {
        const admin = await firestoreService.getById('users', district.adminId);
        
        const clubs = await Promise.all(
          (district.clubIds || []).map(async (clubId) => {
            const club = await firestoreService.getById('clubs', clubId);
            return club ? {
              id: clubId,
              name: club.name,
              logo: club.logo,
              location: club.location
            } : null;
          })
        );

        return {
          ...district,
          admin: admin ? { id: district.adminId, fullName: admin.fullName, email: admin.email } : null,
          clubs: clubs.filter(Boolean)
        };
      })
    );

    res.json(districtsWithData);
  } catch (error) {
    console.error('Get all districts error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get district by ID
// @route   GET /api/districts/:id
// @access  Private
exports.getDistrictById = async (req, res) => {
  try {
    const district = await firestoreService.getById('districts', req.params.id);

    if (!district) {
      return res.status(404).json({ message: 'District not found' });
    }

    // Populate admin and clubs data
    const admin = await firestoreService.getById('users', district.adminId);
    
    const clubs = await Promise.all(
      (district.clubIds || []).map(async (clubId) => {
        const club = await firestoreService.getById('clubs', clubId);
        return club ? {
          id: clubId,
          name: club.name,
          logo: club.logo,
          description: club.description,
          location: club.location,
          members: club.memberIds || []
        } : null;
      })
    );

    res.json({
      ...district,
      admin: admin ? { id: district.adminId, fullName: admin.fullName, email: admin.email, profilePhoto: admin.profilePhoto } : null,
      clubs: clubs.filter(Boolean)
    });
  } catch (error) {
    console.error('Get district by ID error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Create district
// @route   POST /api/districts
// @access  Private (Super Admin only)
exports.createDistrict = async (req, res) => {
  try {
    const { name, location } = req.body;

    const districtData = {
      name,
      location,
      adminId: req.user.id,
      clubIds: []
    };

    const district = await firestoreService.create('districts', districtData);

    // Populate admin data
    const admin = await firestoreService.getById('users', req.user.id);

    res.status(201).json({
      ...district,
      admin: admin ? { id: req.user.id, fullName: admin.fullName, email: admin.email } : null
    });
  } catch (error) {
    console.error('Create district error:', error);
    res.status(500).json({ message: error.message });
  }
};
