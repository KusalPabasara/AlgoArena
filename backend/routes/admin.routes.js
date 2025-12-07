const express = require('express');
const router = express.Router();
const {
  getAllLeoIds,
  addLeoId,
  deleteLeoId,
  lookupUserByLeoId,
  createLeoIdByEmail
} = require('../controllers/admin.controller');
const { protect } = require('../middleware/auth');

router.get('/leo-ids', protect, getAllLeoIds);
router.post('/leo-ids', protect, addLeoId);
router.post('/create-leo-id-by-email', protect, createLeoIdByEmail);
router.delete('/leo-ids/:id', protect, deleteLeoId);
router.get('/leo-ids/lookup/:leoId', protect, lookupUserByLeoId);

module.exports = router;

