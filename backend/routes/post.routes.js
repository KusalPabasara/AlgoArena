const express = require('express');
const router = express.Router();
const {
  getFeed,
  createPost,
  toggleLike,
  addComment,
  updateComment,
  deleteComment,
  updatePost,
  deletePost,
  getUserPosts,
  getPostsByPage
} = require('../controllers/post.controller');
const { protect } = require('../middleware/auth');
const upload = require('../middleware/upload');

router.get('/', protect, getFeed);  // Support /posts for Flutter app
router.get('/feed', protect, getFeed);
router.get('/page/:pageId', protect, getPostsByPage);
router.post('/', protect, (req, res, next) => {
  upload.array('images', 5)(req, res, (err) => {
    if (err) {
      // Handle multer errors (file filter, size limit, etc.)
      console.error('Multer error:', err.message);
      if (err.message.includes('Only images are allowed')) {
        return res.status(400).json({ 
          message: 'Only image files are allowed (jpeg, jpg, png, gif, webp). Please check your file format.' 
        });
      }
      if (err.code === 'LIMIT_FILE_SIZE') {
        return res.status(400).json({ 
          message: 'File size too large. Maximum file size is 5MB.' 
        });
      }
      if (err.code === 'LIMIT_FILE_COUNT') {
        return res.status(400).json({ 
          message: 'Too many files. Maximum 5 images allowed.' 
        });
      }
      return res.status(400).json({ message: err.message });
    }
    next();
  });
}, createPost);
router.put('/:id', protect, updatePost);
router.put('/:id/like', protect, toggleLike);
router.post('/:id/comments', protect, addComment);
router.delete('/:id', protect, deletePost);
router.get('/user/:userId', protect, getUserPosts);

module.exports = router;
