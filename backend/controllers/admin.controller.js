const firestoreService = require('../services/firestore.service');
const emailService = require('../services/email.service');
const authService = require('../services/auth.service');

// Generate a unique Leo ID (format: LEO-XXXXX)
const generateLeoId = () => {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  let result = 'LEO-';
  for (let i = 0; i < 5; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return result;
};

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

    // Convert Firestore timestamps to ISO strings
    const formattedLeoIds = leoIds.map(leoId => ({
      ...leoId,
      createdAt: leoId.createdAt?._seconds 
        ? new Date(leoId.createdAt._seconds * 1000).toISOString()
        : (leoId.createdAt ? new Date(leoId.createdAt).toISOString() : new Date().toISOString()),
      updatedAt: leoId.updatedAt?._seconds
        ? new Date(leoId.updatedAt._seconds * 1000).toISOString()
        : (leoId.updatedAt ? new Date(leoId.updatedAt).toISOString() : new Date().toISOString())
    }));

    res.json({ leoIds: formattedLeoIds });
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

// @desc    Create Leo ID by email (for members)
// @route   POST /api/admin/create-leo-id-by-email
// @access  Private (Super Admin only)
exports.createLeoIdByEmail = async (req, res) => {
  try {
    // Check if user is super admin
    if (req.user.role !== 'superadmin' && req.user.role !== 'super_admin') {
      return res.status(403).json({ message: 'Only super admin can create Leo IDs' });
    }

    const { email } = req.body;

    if (!email) {
      return res.status(400).json({ message: 'Email is required' });
    }

    // Check if email already has a Leo ID
    const existingLeoIds = await firestoreService.getAll('leoIds');
    const existingLeoId = existingLeoIds.find(l => l.email && l.email.toLowerCase() === email.toLowerCase());
    if (existingLeoId) {
      return res.status(400).json({ 
        message: 'This email already has a Leo ID assigned',
        leoId: existingLeoId.leoId
      });
    }

    // Find user by email (check Firebase Auth and Firestore)
    let userRecord = null;
    let userData = null;
    let userId = null;

    try {
      userRecord = await authService.getUserByEmail(email);
      if (userRecord) {
        userId = userRecord.uid;
        userData = await firestoreService.getById('users', userId);
      }
    } catch (error) {
      // User doesn't exist in Firebase Auth yet - that's okay, we'll create the Leo ID anyway
      console.log(`User ${email} not found in Firebase Auth, will create Leo ID for future registration`);
    }

    // Generate unique Leo ID
    let leoId = generateLeoId();
    let existing = existingLeoIds.find(l => l.leoId === leoId);
    while (existing) {
      leoId = generateLeoId();
      existing = existingLeoIds.find(l => l.leoId === leoId);
    }

    const now = new Date();
    const leoIdData = {
      leoId: leoId,
      email: email.toLowerCase(),
      fullName: userData?.fullName || null,
      userId: userId || null,
      isUsed: false, // Will be true when user verifies
      createdAt: now,
      updatedAt: now
    };

    const newLeoId = await firestoreService.create('leoIds', leoIdData);

    // If user exists, update their pendingLeoId
    if (userId && userData) {
      await firestoreService.update('users', userId, {
        pendingLeoId: leoId,
        updatedAt: now
      });
    }

    // Send Leo ID via email
    try {
      await emailService.sendLeoIdEmail(
        email,
        leoId,
        userData?.fullName || email.split('@')[0]
      );
      console.log(`📧 Leo ID email sent to ${email} for Leo ID: ${leoId}`);
    } catch (emailError) {
      console.error('❌ Failed to send Leo ID email:', emailError.message || emailError);
      // Don't fail the request if email fails, but log it
      // The Leo ID is still created successfully
    }

    res.status(201).json({
      message: 'Leo ID created and sent via email successfully',
      leoId: {
        id: newLeoId.id,
        leoId: leoId,
        email: email,
        fullName: userData?.fullName || null,
        isUsed: false,
        createdAt: now.toISOString(),
        updatedAt: now.toISOString()
      }
    });
  } catch (error) {
    console.error('Create Leo ID by email error:', error);
    res.status(500).json({ message: error.message });
  }
};

