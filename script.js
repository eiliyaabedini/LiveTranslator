// DOM Elements
const translateBtn = document.getElementById('translate-btn');
const micBtn = document.getElementById('mic-btn');
const micIcon = document.querySelector('.mic-icon');
const statusText = document.getElementById('status-text');
const speakerIndicator = document.getElementById('speaker-indicator');
const sourceLanguageMini = document.getElementById('source-language-mini');
const targetLanguageMini = document.getElementById('target-language-mini');
const quickSourceLanguageSelect = document.getElementById('quick-source-language-select');
const quickTargetLanguageSelect = document.getElementById('quick-target-language-select');

// Settings Elements
const settingsBtn = document.getElementById('settings-btn');
const infoBtn = document.getElementById('info-btn');
const settingsModal = document.getElementById('settings-modal');
const infoModal = document.getElementById('info-modal');
const closeSettings = document.getElementById('close-settings');
const closeInfo = document.getElementById('close-info');
const saveSettings = document.getElementById('save-settings');
const apiKeyInput = document.getElementById('api-key');
const sourceLanguageSelect = document.getElementById('source-language-select');
const targetLanguageSelect = document.getElementById('target-language-select');
const openaiBtn = document.getElementById('openai-btn');
const geminiBtn = document.getElementById('gemini-btn');

// App State
let isTranslating = false;
let currentSpeaker = '';
let apiKey = localStorage.getItem('apiKey') || '';
let sourceLanguage = localStorage.getItem('sourceLanguage') || 'English';
let targetLanguage = localStorage.getItem('targetLanguage') || 'Spanish';
// Volume is now fixed
let apiService = localStorage.getItem('apiService') || 'openai';

// WebRTC & Audio 
let rtcConnection = null;
let localStream = null;
let remoteAudioElement = null;

// Language code mappings
const languageCodes = {
    'English': 'en-US',
    'Spanish': 'es-ES',
    'Farsi': 'fa-IR',
    'French': 'fr-FR',
    'German': 'de-DE',
    'Italian': 'it-IT',
    'Portuguese': 'pt-PT',
    'Russian': 'ru-RU',
    'Japanese': 'ja-JP',
    'Chinese': 'zh-CN',
    'Korean': 'ko-KR',
    'Arabic': 'ar-SA'
};

// Initialize the app
function init() {
    // Load saved settings
    apiKeyInput.value = apiKey;
    sourceLanguageSelect.value = sourceLanguage;
    targetLanguageSelect.value = targetLanguage;
    quickSourceLanguageSelect.value = sourceLanguage;
    quickTargetLanguageSelect.value = targetLanguage;
    
    // Update displayed languages
    sourceLanguageMini.textContent = sourceLanguage;
    targetLanguageMini.textContent = targetLanguage;
    
    // Set API service selection
    if (apiService === 'openai') {
        openaiBtn.classList.add('selected');
        geminiBtn.classList.remove('selected');
    } else {
        geminiBtn.classList.add('selected');
        openaiBtn.classList.remove('selected');
    }
    
    // Create hidden audio element for remote audio
    remoteAudioElement = document.createElement('audio');
    remoteAudioElement.id = 'remote-audio';
    remoteAudioElement.autoplay = true;
    document.body.appendChild(remoteAudioElement);
    
    // Event listeners
    translateBtn.addEventListener('click', toggleTranslation);
    micBtn.addEventListener('click', toggleTranslation);
    settingsBtn.addEventListener('click', () => settingsModal.classList.remove('hidden'));
    infoBtn.addEventListener('click', () => infoModal.classList.remove('hidden'));
    closeSettings.addEventListener('click', () => settingsModal.classList.add('hidden'));
    closeInfo.addEventListener('click', () => infoModal.classList.add('hidden'));
    saveSettings.addEventListener('click', saveSettingsHandler);
    
    // Quick language selection
    quickSourceLanguageSelect.addEventListener('change', (e) => {
        sourceLanguage = e.target.value;
        sourceLanguageMini.textContent = sourceLanguage;
        sourceLanguageSelect.value = sourceLanguage;
        localStorage.setItem('sourceLanguage', sourceLanguage);
    });
    
    quickTargetLanguageSelect.addEventListener('change', (e) => {
        targetLanguage = e.target.value;
        targetLanguageMini.textContent = targetLanguage;
        targetLanguageSelect.value = targetLanguage;
        localStorage.setItem('targetLanguage', targetLanguage);
    });
    
    // Volume slider removed - we'll set a fixed volume
    
    openaiBtn.addEventListener('click', () => {
        openaiBtn.classList.add('selected');
        geminiBtn.classList.remove('selected');
        apiService = 'openai';
    });
    
    geminiBtn.addEventListener('click', () => {
        geminiBtn.classList.add('selected');
        openaiBtn.classList.remove('selected');
        apiService = 'gemini';
    });
    
    // Check if browser supports required APIs
    if (!window.RTCPeerConnection) {
        alert('Your browser does not support WebRTC. Please use a modern browser like Chrome, Firefox, or Safari.');
    }
}

// Save settings
function saveSettingsHandler() {
    apiKey = apiKeyInput.value;
    sourceLanguage = sourceLanguageSelect.value;
    targetLanguage = targetLanguageSelect.value;
    
    // Save to localStorage
    localStorage.setItem('apiKey', apiKey);
    localStorage.setItem('sourceLanguage', sourceLanguage);
    localStorage.setItem('targetLanguage', targetLanguage);
    localStorage.setItem('apiService', apiService);
    
    // Update displayed languages
    sourceLanguageMini.textContent = sourceLanguage;
    targetLanguageMini.textContent = targetLanguage;
    quickSourceLanguageSelect.value = sourceLanguage;
    quickTargetLanguageSelect.value = targetLanguage;
    
    // Close modal
    settingsModal.classList.add('hidden');
}

// Toggle translation state
function toggleTranslation() {
    if (!apiKey) {
        settingsModal.classList.remove('hidden');
        return;
    }
    
    if (isTranslating) {
        stopTranslation();
    } else {
        startTranslation();
    }
}

// Start translation
async function startTranslation() {
    try {
        // Request microphone access
        const stream = await navigator.mediaDevices.getUserMedia({ 
            audio: { 
                echoCancellation: true,
                noiseSuppression: true,
                autoGainControl: true
            } 
        });
        localStream = stream;
        
        // Get session from our proxy server
        const sessionData = await getSession();
        
        // Initialize and connect WebRTC
        await initializeWebRTC(sessionData);
        
        // Update UI
        isTranslating = true;
        translateBtn.textContent = 'Stop Translation';
        translateBtn.classList.add('stop');
        micIcon.classList.add('active');
        statusText.textContent = `Translating: ${sourceLanguage} ↔ ${targetLanguage}`;
        speakerIndicator.classList.remove('hidden');
        speakerIndicator.textContent = 'You are speaking...';
        currentSpeaker = 'You are speaking...';
        
    } catch (error) {
        console.error('Error starting translation:', error);
        alert(`Error: ${error.message}. Please check your API key and browser permissions.`);
        stopTranslation();
    }
}

// Get ephemeral token from our proxy server
async function getSession() {
    try {
        console.log("Requesting session from proxy");
        
        if (!apiKey) {
            throw new Error('API key is missing. Please add it in the settings.');
        }
        
        // Use the correct endpoint as defined in the proxy server with language parameters
        const url = `/session?sourceLanguage=${encodeURIComponent(sourceLanguage)}&targetLanguage=${encodeURIComponent(targetLanguage)}`;
        const tokenResponse = await fetch(url, {
            headers: {
                'Authorization': `Bearer ${apiKey}`
            }
        });
        
        if (!tokenResponse.ok) {
            const errorData = await tokenResponse.json();
            throw new Error(`API Error: ${tokenResponse.status} - ${errorData.error?.message || 'Failed to get session'}`);
        }
        
        const data = await tokenResponse.json();
        console.log("Session data received with language instructions:", data);
        return data;
    } catch (error) {
        console.error('Error getting session:', error);
        throw error;
    }
}

// Initialize WebRTC connection
async function initializeWebRTC(sessionData) {
    try {
        const EPHEMERAL_KEY = sessionData.client_secret.value;
        
        // Create a peer connection
        rtcConnection = new RTCPeerConnection();
        
        // Set up to play remote audio from the model
        remoteAudioElement.autoplay = true;
        rtcConnection.ontrack = handleTrack;
        
        // Add local audio track for microphone input in the browser
        if (localStream) {
            rtcConnection.addTrack(localStream.getTracks()[0]);
        }
        
        // Set up data channel for sending and receiving events
        const dc = rtcConnection.createDataChannel("oai-events");
        dc.addEventListener("message", (e) => {
            // Realtime server events appear here
            console.log("Event received:", e);
        });
        
        // Set up event handlers
        rtcConnection.onicecandidate = handleICECandidate;
        rtcConnection.onconnectionstatechange = handleConnectionStateChange;
        rtcConnection.onicecandidateerror = handleICECandidateError;
        
        // Start the session using the Session Description Protocol (SDP)
        const offer = await rtcConnection.createOffer();
        await rtcConnection.setLocalDescription(offer);
        
        const baseUrl = "https://api.openai.com/v1/realtime";
        const model = "gpt-4o-mini-realtime-preview-2024-12-17";
        const sdpResponse = await fetch(`${baseUrl}?model=${model}`, {
            method: "POST",
            body: offer.sdp,
            headers: {
                Authorization: `Bearer ${EPHEMERAL_KEY}`,
                "Content-Type": "application/sdp"
            },
        });
        
        if (!sdpResponse.ok) {
            throw new Error(`SDP response error: ${sdpResponse.status}`);
        }
        
        const answer = {
            type: "answer",
            sdp: await sdpResponse.text(),
        };
        await rtcConnection.setRemoteDescription(answer);
        
        console.log('WebRTC connection established successfully');
    } catch (error) {
        console.error('Error initializing WebRTC:', error);
        throw error;
    }
}

// Handle track from peer connection
function handleTrack(event) {
    console.log('Track received:', event.track.kind);
    
    if (event.track.kind === 'audio') {
        // Connect the remote audio track to the audio element
        const remoteStream = new MediaStream([event.track]);
        remoteAudioElement.srcObject = remoteStream;
        remoteAudioElement.volume = 0.8; // Fixed at 80%
        
        // Play audio (may require user interaction)
        remoteAudioElement.play().catch(error => {
            console.warn('Auto-play prevented:', error);
        });
    }
}

// Handle ICE candidate
function handleICECandidate(event) {
    if (event.candidate) {
        console.log('ICE candidate:', event.candidate);
    }
}

// Handle connection state change
function handleConnectionStateChange() {
    console.log('Connection state changed:', rtcConnection.connectionState);
    
    if (rtcConnection.connectionState === 'disconnected' || 
        rtcConnection.connectionState === 'failed' || 
        rtcConnection.connectionState === 'closed') {
        
        if (isTranslating) {
            console.warn('WebRTC connection closed unexpectedly');
            stopTranslation();
            alert('Connection to translation service was lost. Please try again.');
        }
    }
}

// Handle ICE candidate error
function handleICECandidateError(event) {
    console.error('ICE candidate error:', event);
}

// Stop translation
function stopTranslation() {
    // Close RTCPeerConnection
    if (rtcConnection) {
        try {
            rtcConnection.close();
        } catch (e) {
            console.warn('Error closing RTCPeerConnection:', e);
        }
        rtcConnection = null;
    }
    
    // Stop microphone access
    if (localStream) {
        localStream.getTracks().forEach(track => track.stop());
        localStream = null;
    }
    
    // Update UI
    isTranslating = false;
    translateBtn.textContent = 'Start Translation';
    translateBtn.classList.remove('stop');
    micIcon.classList.remove('active');
    statusText.textContent = 'Ready to translate';
    speakerIndicator.classList.add('hidden');
    currentSpeaker = '';
}

// Update speaker status
function updateSpeakerStatus(speakerText) {
    if (currentSpeaker !== speakerText) {
        currentSpeaker = speakerText;
        speakerIndicator.textContent = speakerText;
        
        // Update translation direction in status text
        if (speakerText === "You are speaking...") {
            statusText.textContent = `Translating: ${sourceLanguage} → ${targetLanguage}`;
        } else {
            statusText.textContent = `Translating: ${targetLanguage} → ${sourceLanguage}`;
        }
    }
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', init);