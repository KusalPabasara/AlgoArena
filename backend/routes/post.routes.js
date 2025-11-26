const express = require('express');
const router = express.Router();
const {
  getFeed,
  createPost,
  toggleLike,
  addComment,
  deletePost,
  getUserPosts
} = require('../controllers/post.controller');
const { protect } = require('../middleware/auth');
const upload = require('../middleware/upload');

router.get('/', protect, getFeed);  // Support /posts for Flutter app
router.get('/feed', protect, getFeed);
router.post('/', protect, upload.array('images', 5), createPost);
router.put('/:id/like', protect, toggleLike);
router.post('/:id/comments', protect, addComment);
router.delete('/:id', protect, deletePost);
router.get('/user/:userId', protect, getUserPosts);

module.exports = router;
