const express = require('express');
const router = express.Router();
const {
  getAllPages,
  createPage,
  getPageById,
  updatePage,
  deletePage,
  checkWebmaster,
  getMyPages,
  toggleFollow,
  getFollowStatus,
  getPageStats
} = require('../controllers/page.controller');
const { protect } = require('../middleware/auth');
const upload = require('../middleware/upload');

router.get('/', protect, getAllPages);
router.get('/my-pages', protect, getMyPages);
// Handle file uploads with error handling for unexpected fields
const uploadMiddleware = (req, res, next) => {
  upload.fields([
    { name: 'logo', maxCount: 1 },
    { name: 'mapImage', maxCount: 1 }
  ])(req, res, (err) => {
    if (err) {
      // If it's an "Unexpected field" error, log it but continue
      if (err.message && err.message.includes('Unexpected field')) {
        console.warn('Multer warning - unexpected field:', err.message);
        // Continue to controller - it will handle missing files gracefully
        return next();
      }
      return next(err);
    }
    next();
  });
};

router.post('/', protect, uploadMiddleware, createPage);
router.get('/:id', protect, getPageById);
router.get('/:id/stats', protect, getPageStats);
router.get('/:id/follow-status', protect, getFollowStatus);
router.post('/:id/follow', protect, toggleFollow);
router.put('/:id', protect, uploadMiddleware, updatePage);
router.delete('/:id', protect, deletePage);
router.get('/:id/webmaster/:leoId', protect, checkWebmaster);

module.exports = router;

