# Setting Up LiveTranslator

Follow these steps to run the LiveTranslator application locally:

## Prerequisites

1. An OpenAI API key with access to the GPT-4o-mini-realtime-preview Realtime API
2. A modern web browser (Chrome, Firefox, Safari, Edge)

## Installation Steps

1. Serve the application using any HTTP server:

   Using Python:
   ```
   python -m http.server 8000
   ```
   Then access the application at http://localhost:8000

   OR

   Using Node.js:
   ```
   npx http-server
   ```
   Then access the application at http://localhost:8080

2. Enter your OpenAI API key in the settings panel and select your languages.

3. Click "Start Translation" and begin speaking.

## Troubleshooting

### Browser Compatibility
This application uses WebRTC, which requires a modern browser:

1. Make sure you're using the latest version of Chrome, Firefox, Safari, or Edge
2. Access the application through an HTTP server and not by directly opening the HTML file
3. Check the browser console for any network errors

### WebSocket Connection Issues
If you can get a token but the WebSocket connection fails:

1. Make sure your API key has access to the Realtime API
2. Check that your internet connection is stable
3. Some corporate networks or VPNs may block WebSocket connections

### Audio Issues
If the audio capture or playback isn't working:

1. Make sure you've granted microphone permissions to the browser
2. Try using a different browser (Chrome or Edge generally work best)
3. Check your microphone and speaker settings