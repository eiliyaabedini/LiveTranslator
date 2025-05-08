const express = require('express');
const cors = require('cors');
const fetch = require('node-fetch');

const app = express();
const port = 3000;

// Enable CORS for all routes
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

// Serve static files
app.use(express.static('.'));

// Parse JSON bodies
app.use(express.json());

// Endpoint to get session token from OpenAI
app.get("/session", async (req, res) => {
  try {
    const apiKey = req.headers.authorization?.split(' ')[1];
    if (!apiKey) {
      return res.status(401).json({ error: "API key is required" });
    }
    
    const sourceLanguage = req.query.sourceLanguage || 'English';
    const targetLanguage = req.query.targetLanguage || 'Spanish';
    
    console.log(`Translation request: ${sourceLanguage} to ${targetLanguage}`);

    const response = await fetch("https://api.openai.com/v1/realtime/sessions", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: "gpt-4o-mini-realtime-preview-2024-12-17",
        voice: "shimmer",
        instructions: `You are a MECHANICAL TRANSLATION DEVICE. You DO NOT engage in conversation.
        
        Your ONLY function is to DIRECTLY TRANSLATE the exact words spoken, nothing more:
        
        - When the user speaks in ${sourceLanguage}: Translate those EXACT words into ${targetLanguage}
        - When the user speaks in ${targetLanguage}: Translate those EXACT words into ${sourceLanguage}
        
        CRITICAL RULES:
        - NEVER respond to questions - only translate them word for word
        - NEVER answer questions like "How are you?" - just translate the question itself
        - NEVER have opinions or provide information
        - NEVER engage in conversation or act as an assistant
        - NEVER add explanations, context, or your own words
        - NEVER make up responses or answer on behalf of anyone
        
        EXAMPLE:
        User: "How are you?" 
        YOU: "¿Cómo estás?" (CORRECT - just translated)
        NOT: "Estoy bien, gracias." (WRONG - you answered instead of translating)
        
        User: "What is the capital of France?"
        YOU: "¿Cuál es la capital de Francia?" (CORRECT - just translated)
        NOT: "La capital de Francia es París." (WRONG - you answered the question)
        
        You are ONLY a translation device, not a conversational AI.`
      }),
    });

    if (!response.ok) {
      const errorData = await response.json();
      console.error("Error from OpenAI:", errorData);
      return res.status(response.status).json(errorData);
    }

    const data = await response.json();
    console.log("Successfully obtained session token with translation instructions");
    res.json(data);
  } catch (error) {
    console.error("Server error:", error);
    res.status(500).json({ error: error.message });
  }
});

app.listen(port, () => {
  console.log(`Proxy server running at http://localhost:${port}`);
});