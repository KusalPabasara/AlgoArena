const express = require('express');
const router = express.Router();
const leoAssistController = require('../controllers/leo-assist.controller');

// Leo Assist chatbot endpoint
router.post('/chat', leoAssistController.chat);

// Reset conversation
router.post('/reset', leoAssistController.resetConversation);

// Health check for Leo Assist
router.get('/health', leoAssistController.health);

module.exports = router;
