const express = require('express');
const router = express.Router();
const {
  getAllUsers,
  getAllLeoIds,
  createLeoId,
  verifyLeoId,
  revokeWebmaster,
  getWebmasters,
} = require('../controllers/webmaster.controller');
const { protect, authorize } = require('../middleware/auth');

// Public route for verifying Leo ID (but requires auth)
router.post('/verify-leo-id', protect, verifyLeoId);

// Super Admin only routes
router.get('/users', protect, authorize('super_admin', 'superadmin'), getAllUsers);
router.get('/leo-ids', protect, authorize('super_admin', 'superadmin'), getAllLeoIds);
router.get('/', protect, authorize('super_admin', 'superadmin'), getWebmasters);
router.post('/create-leo-id', protect, authorize('super_admin', 'superadmin'), createLeoId);
router.delete('/:userId', protect, authorize('super_admin', 'superadmin'), revokeWebmaster);

module.exports = router;
