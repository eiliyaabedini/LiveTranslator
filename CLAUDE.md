# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

LiveTranslator is a browser-based real-time voice translation application that enables seamless communication between people speaking different languages using OpenAI's GPT-4o-mini-realtime-preview API. It's a client-side only application with no backend server.

## Architecture

The application uses a simple structure:
- `index.html`: Main application UI and structure
- `styles.css`: Styling for the application
- `script.js`: Application logic and functionality

The app works by:
1. Capturing audio using the browser's MediaRecorder API
2. Obtaining a WebSocket token directly from OpenAI's API
3. Establishing a direct WebSocket connection to OpenAI's Realtime API
4. Streaming audio data to the model in real-time
5. Receiving translated audio data back through the WebSocket
6. Playing back translated speech through the browser

## Development Workflow

### Running the Application

Since this is a pure frontend application, you can serve it using any simple HTTP server:

```bash
# Using Python's built-in server
python -m http.server 8000

# Or using Node.js with http-server
npx http-server
```

Then open http://localhost:8000 in your browser.

### Testing

There are no automated tests for this project. Manual testing should be performed by running the application and testing the voice translation functionality with an OpenAI API key that has access to the Realtime API.

## Key Implementation Details

- The application uses vanilla JavaScript with no external dependencies
- Uses the OpenAI Realtime API which requires access to the gpt-4o-mini-realtime-preview model
- Audio processing is handled using the MediaRecorder API and WebAudio API
- The application supports translation between multiple languages including English, Spanish, Farsi, French, German, Italian, etc.
- API keys are stored in localStorage and never sent to any server beyond OpenAI
- The app has a responsive design that works on desktop and mobile browsers

## Important Functions

- `toggleTranslation()`: Starts/stops the translation process
- `startTranslation()`: Sets up audio context and initiates the connection process
- `getWebSocketToken()`: Gets an ephemeral WebSocket token from the OpenAI API
- `connectWebSocket()`: Establishes the WebSocket connection with the token
- `startAudioStreaming()`: Sets up MediaRecorder to send audio chunks to the API
- `handleWebSocketMessage()`: Processes messages from the Realtime API
- `playAudio()`: Plays back audio received from the API
- `updateSpeakerStatus()`: Updates the UI based on who is speaking