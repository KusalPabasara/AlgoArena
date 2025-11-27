const express = require('express');
const router = express.Router();
const {
  getAllPages,
  createPage,
  getPageById,
  checkWebmaster
} = require('../controllers/page.controller');
const { protect } = require('../middleware/auth');

router.get('/', protect, getAllPages);
router.post('/', protect, createPage);
router.get('/:id', protect, getPageById);
router.get('/:id/webmaster/:leoId', protect, checkWebmaster);

module.exports = router;

