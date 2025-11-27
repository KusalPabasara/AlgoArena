/**
 * Leo Assist Controller - Using Google Gemini AI API
 * Provides intelligent AI responses for Leo Club related queries
 */

const https = require('https');

// Google Gemini API Configuration
const GEMINI_API_KEY = 'AIzaSyDryQjK7nNdyMFvCm2-JssYBchPoK11MFE';
const GEMINI_API_URL = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
const API_TIMEOUT = 30000; // 30 seconds for AI response

// Store conversation history per session
const conversationHistory = new Map();

// System prompt for Leo Assist
const SYSTEM_PROMPT = `You are LeoAssist, a friendly and knowledgeable virtual assistant for Leo Clubs in Sri Lanka and the Maldives. 

About Leo Clubs:
- LEO stands for Leadership, Experience, and Opportunity
- Leo Clubs are youth organizations sponsored by Lions Clubs International
- Members are young people aged 12-30 who develop leadership skills while serving their communities
- Leo Clubs focus on community service, youth development, and leadership training
- In Sri Lanka and Maldives, Leo Clubs are very active in various community projects

Your role:
- Help users with questions about Leo Clubs, membership, events, and activities
- Provide information about community service opportunities
- Guide users on how to join or start a Leo Club
- Share information about Leo District 306 (Sri Lanka and Maldives)
- Be friendly, helpful, and encouraging

Keep responses concise but informative. Use emojis occasionally to be friendly. If you don't know something specific, suggest the user check the app's Events or Clubs section for more details.`;

/**
 * Make request to Google Gemini API
 */
function callGeminiAPI(message, conversationId) {
  return new Promise((resolve, reject) => {
    // Get or create conversation history
    let history = conversationHistory.get(conversationId) || [];
    
    // Build the conversation for Gemini
    const contents = [
      {
        role: 'user',
        parts: [{ text: SYSTEM_PROMPT + '\n\nUser message: ' + message }]
      }
    ];
    
    // Add conversation history if exists
    if (history.length > 0) {
      // Include last 5 exchanges for context
      const recentHistory = history.slice(-10);
      contents[0].parts[0].text = SYSTEM_PROMPT + '\n\nPrevious conversation:\n' + 
        recentHistory.map(h => `${h.role}: ${h.content}`).join('\n') + 
        '\n\nUser message: ' + message;
    }

    const requestData = JSON.stringify({
      contents: contents,
      generationConfig: {
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      },
      safetySettings: [
        { category: 'HARM_CATEGORY_HARASSMENT', threshold: 'BLOCK_MEDIUM_AND_ABOVE' },
        { category: 'HARM_CATEGORY_HATE_SPEECH', threshold: 'BLOCK_MEDIUM_AND_ABOVE' },
        { category: 'HARM_CATEGORY_SEXUALLY_EXPLICIT', threshold: 'BLOCK_MEDIUM_AND_ABOVE' },
        { category: 'HARM_CATEGORY_DANGEROUS_CONTENT', threshold: 'BLOCK_MEDIUM_AND_ABOVE' },
      ]
    });

    const url = new URL(GEMINI_API_URL + '?key=' + GEMINI_API_KEY);
    
    const options = {
      hostname: url.hostname,
      port: 443,
      path: url.pathname + url.search,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(requestData),
      },
      timeout: API_TIMEOUT,
    };

    const req = https.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk);
      res.on('end', () => {
        try {
          const data = JSON.parse(body);
          
          if (res.statusCode === 200 && data.candidates && data.candidates[0]) {
            const responseText = data.candidates[0].content?.parts?.[0]?.text;
            if (responseText) {
              // Update conversation history
              history.push({ role: 'user', content: message });
              history.push({ role: 'assistant', content: responseText });
              
              // Keep only last 20 messages
              if (history.length > 20) {
                history = history.slice(-20);
              }
              conversationHistory.set(conversationId, history);
              
              resolve({ success: true, text: responseText });
            } else {
              reject(new Error('No response text from Gemini'));
            }
          } else {
            console.error('Gemini API error:', res.statusCode, body);
            reject(new Error(`Gemini API error: ${res.statusCode} - ${data.error?.message || 'Unknown error'}`));
          }
        } catch (e) {
          reject(new Error('Failed to parse Gemini response: ' + e.message));
        }
      });
    });

    req.on('error', (e) => reject(new Error('Request failed: ' + e.message)));
    req.on('timeout', () => {
      req.destroy();
      reject(new Error('Request timeout'));
    });

    req.write(requestData);
    req.end();
  });
}

/**
 * Fallback responses when AI is unavailable
 */
const FALLBACK_RESPONSES = [
  "Hello! I'm LeoAssist. I'm having a brief connection issue, but I'm here to help with Leo Club questions. Please try again in a moment! 🦁",
  "Hi there! I apologize for the delay. Feel free to ask me about Leo Clubs, events, membership, or community service!",
  "Welcome to LeoAssist! I'm experiencing a temporary hiccup. Please try your question again. I'm here to help with all things Leo! ✨"
];

/**
 * Chat endpoint - processes messages using Google Gemini
 */
exports.chat = async (req, res) => {
  try {
    const { message, sessionId } = req.body;

    if (!message || typeof message !== 'string' || message.trim() === '') {
      return res.status(400).json({ 
        success: false, 
        error: 'Message is required' 
      });
    }

    const conversationId = sessionId || 'default-' + Date.now();
    console.log(`🤖 Leo Assist request: "${message.substring(0, 50)}..."`);

    try {
      const result = await callGeminiAPI(message.trim(), conversationId);
      console.log('✅ Leo Assist: Gemini response received');
      
      return res.json({
        success: true,
        response: result.text,
        conversationId: conversationId,
      });
    } catch (aiError) {
      console.error('⚠️ Gemini API error:', aiError.message);
      
      // Return fallback response
      const fallback = FALLBACK_RESPONSES[Math.floor(Math.random() * FALLBACK_RESPONSES.length)];
      return res.json({
        success: true,
        response: fallback,
        fallback: true,
      });
    }

  } catch (error) {
    console.error('❌ Leo Assist error:', error.message);
    return res.status(500).json({
      success: false,
      error: error.message,
      response: 'I apologize, an unexpected error occurred. Please try again.',
    });
  }
};

/**
 * Reset conversation endpoint
 */
exports.resetConversation = (req, res) => {
  const { sessionId } = req.body;
  if (sessionId) {
    conversationHistory.delete(sessionId);
    console.log(`🔄 Conversation reset for session: ${sessionId}`);
  }
  res.json({ success: true, message: 'Conversation reset' });
};

/**
 * Health check endpoint
 */
exports.health = (req, res) => {
  res.json({ 
    success: true, 
    service: 'Leo Assist',
    provider: 'Google Gemini',
    status: 'operational'
  });
};
