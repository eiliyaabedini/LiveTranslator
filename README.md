# Real-Time Voice Translator

A browser-based real-time voice translation application that enables seamless communication between people speaking different languages using OpenAI's GPT-4o-mini-realtime-preview API.

## Features

- **Real-time voice-to-voice translation**: Direct translation between languages without intermediate text steps
- **Intuitive interface**: Simple one-button operation
- **Conversation mode**: Automatically detects speech pauses to switch translation direction
- **Customizable**: Use your own OpenAI API key
- **No installation required**: Works directly in your browser
- **Privacy-focused**: No server storage of conversations

## How It Works

1. Enter your OpenAI API key
2. Select your language and the target language
3. Click "Start Translation"
4. Speak in your language
5. The app translates your speech in real-time
6. When the other person speaks, it automatically translates back to your language

## Getting Started

### Prerequisites

- Modern web browser (Chrome, Firefox, Safari, Edge)
- OpenAI API key with access to GPT-4o-mini-realtime-preview API
- Microphone access
- Internet connection

### Local Setup

1. Clone this repository:
   ```
   git clone https://github.com/yourusername/real-time-voice-translator.git
   ```

2. Navigate to the project directory:
   ```
   cd real-time-voice-translator
   ```

3. Install dependencies and start the application:

   ```
   npm install
   npm start
   ```
   
   Then access the application at `http://localhost:3000`

The application uses a lightweight proxy server only for obtaining authentication tokens from OpenAI (to work around browser CORS restrictions). Once authenticated, the application uses WebRTC to establish a secure, direct connection to OpenAI's servers for real-time audio translation.

### API Key

This application requires an OpenAI API key with access to the GPT-4o-mini-realtime-preview model. To obtain one:

1. Create an account at [OpenAI](https://platform.openai.com/)
2. Navigate to the API section
3. Create a new API key
4. Apply for access to the Realtime API at [OpenAI Realtime API](https://platform.openai.com/docs/guides/realtime)
5. Enter your API key in the application's API Key field
6. Your key is never stored on any server and remains in your browser session only

## Technical Details

### Technology Stack

- **Frontend**: HTML5, CSS3, JavaScript (Vanilla JS)
- **API**: OpenAI GPT-4o-mini-realtime-preview Realtime API
- **Audio Processing**: Web Audio API, WebRTC API
- **Real-time Communication**: WebRTC / OpenAI Realtime API

### Architecture

The application uses a client-side only architecture:

1. **Audio Capture**: Uses the browser's WebRTC API to capture microphone input
2. **Secure WebRTC Connection**: Establishes a WebRTC connection directly to OpenAI's Realtime API with an ephemeral token
3. **Audio Streaming**: Streams audio data to OpenAI's model in real-time via WebRTC
4. **Translation Processing**: OpenAI's model translates audio in real-time
5. **Audio Output**: Translated speech is played back through the browser

## Limitations

- Requires OpenAI API access to the Realtime API
- Dependent on internet connection quality
- API usage costs are borne by the user
- May struggle with heavy accents or background noise
- Limited to languages supported by OpenAI's models
- Translation quality varies by language pair

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- OpenAI for providing the GPT-4o-mini-realtime-preview API