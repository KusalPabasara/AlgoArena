const firestoreService = require('../services/firestore.service');

// @desc    Get all Leo IDs
// @route   GET /api/admin/leo-ids
// @access  Private (Super Admin only)
exports.getAllLeoIds = async (req, res) => {
  try {
    // Check if user is super admin
    if (req.user.role !== 'superadmin' && req.user.role !== 'super_admin') {
      return res.status(403).json({ message: 'Only super admin can access this' });
    }

    const leoIds = await firestoreService.getAll('leoIds', {
      orderBy: ['createdAt', 'desc']
    });

    res.json({ leoIds });
  } catch (error) {
    console.error('Get all Leo IDs error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Add Leo ID
// @route   POST /api/admin/leo-ids
// @access  Private (Super Admin only)
exports.addLeoId = async (req, res) => {
  try {
    // Check if user is super admin
    if (req.user.role !== 'superadmin' && req.user.role !== 'super_admin') {
      return res.status(403).json({ message: 'Only super admin can add Leo IDs' });
    }

    const { leoId, email, fullName } = req.body;

    if (!leoId || !email) {
      return res.status(400).json({ message: 'Leo ID and email are required' });
    }

    // Check if Leo ID already exists
    const existingLeoIds = await firestoreService.getAll('leoIds');
    const existing = existingLeoIds.find(l => l.leoId === leoId);
    if (existing) {
      return res.status(400).json({ message: 'Leo ID already exists' });
    }

    // Check if email already has a Leo ID
    const existingEmail = existingLeoIds.find(l => l.email === email);
    if (existingEmail) {
      return res.status(400).json({ message: 'Email already has a Leo ID' });
    }

    const now = new Date();
    const leoIdData = {
      leoId,
      email,
      fullName: fullName || null,
      createdAt: now,
      updatedAt: now
    };

    const newLeoId = await firestoreService.create('leoIds', leoIdData);

    res.status(201).json({
      leoId: {
        id: newLeoId.id,
        ...leoIdData,
        createdAt: now.toISOString(),
        updatedAt: now.toISOString()
      }
    });
  } catch (error) {
    console.error('Add Leo ID error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Delete Leo ID
// @route   DELETE /api/admin/leo-ids/:id
// @access  Private (Super Admin only)
exports.deleteLeoId = async (req, res) => {
  try {
    // Check if user is super admin
    if (req.user.role !== 'superadmin' && req.user.role !== 'super_admin') {
      return res.status(403).json({ message: 'Only super admin can delete Leo IDs' });
    }

    await firestoreService.delete('leoIds', req.params.id);

    res.json({ message: 'Leo ID deleted successfully' });
  } catch (error) {
    console.error('Delete Leo ID error:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Lookup user by Leo ID
// @route   GET /api/admin/leo-ids/lookup/:leoId
// @access  Private (Super Admin only)
exports.lookupUserByLeoId = async (req, res) => {
  try {
    // Check if user is super admin
    if (req.user.role !== 'superadmin' && req.user.role !== 'super_admin') {
      return res.status(403).json({ message: 'Only super admin can lookup users' });
    }

    const leoIds = await firestoreService.getAll('leoIds');
    const leoIdData = leoIds.find(l => l.leoId === req.params.leoId);

    if (!leoIdData) {
      return res.status(404).json({ message: 'Leo ID not found' });
    }

    // Try to find user by email
    const users = await firestoreService.getAll('users');
    const user = users.find(u => u.email === leoIdData.email);

    res.json({
      user: user ? {
        id: user.id || Object.keys(user)[0],
        fullName: user.fullName,
        email: user.email,
        leoId: leoIdData.leoId
      } : null,
      leoId: {
        id: leoIdData.id || Object.keys(leoIdData)[0],
        leoId: leoIdData.leoId,
        email: leoIdData.email,
        fullName: leoIdData.fullName
      }
    });
  } catch (error) {
    console.error('Lookup user by Leo ID error:', error);
    res.status(500).json({ message: error.message });
  }
};

