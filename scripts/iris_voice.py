#!/usr/bin/env python3

import os
import json
import subprocess
import tempfile
import time
import threading
import queue
import speech_recognition as sr
from gtts import gTTS
import pygame
import numpy as np
import sounddevice as sd

class IrisVoice:
    def __init__(self, config_file):
        self.config_file = config_file
        self.load_config()
        self.recognizer = sr.Recognizer()
        self.audio_queue = queue.Queue()
        self.is_listening = False
        self.is_speaking = False
        self.voice_thread = None
        self.listen_thread = None
        self.callback = None
        self.voice_model = "en-US"
        self.voice_speed = 1.0
        self.voice_volume = 1.0
        self.voice_pitch = 1.0
        self.voice_gender = "female"
        self.anime_voice = False
        self.anime_voice_style = "kawaii"
        
        # Initialize pygame for audio playback
        pygame.mixer.init()
        
    def load_config(self):
        """Load Iris configuration"""
        with open(self.config_file, 'r') as f:
            self.config = json.load(f)
            
        # Load voice settings if they exist
        if "voice" in self.config:
            voice_config = self.config["voice"]
            self.voice_model = voice_config.get("model", "en-US")
            self.voice_speed = voice_config.get("speed", 1.0)
            self.voice_volume = voice_config.get("volume", 1.0)
            self.voice_pitch = voice_config.get("pitch", 1.0)
            self.voice_gender = voice_config.get("gender", "female")
            self.anime_voice = voice_config.get("anime_voice", False)
            self.anime_voice_style = voice_config.get("anime_voice_style", "kawaii")
    
    def save_config(self):
        """Save voice configuration"""
        if "voice" not in self.config:
            self.config["voice"] = {}
            
        self.config["voice"] = {
            "model": self.voice_model,
            "speed": self.voice_speed,
            "volume": self.voice_volume,
            "pitch": self.voice_pitch,
            "gender": self.voice_gender,
            "anime_voice": self.anime_voice,
            "anime_voice_style": self.anime_voice_style
        }
        
        with open(self.config_file, 'w') as f:
            json.dump(self.config, f, indent=4)
    
    def set_voice_model(self, model):
        """Set the voice model"""
        self.voice_model = model
        self.save_config()
        return f"Voice model set to {model}"
    
    def set_voice_speed(self, speed):
        """Set the voice speed"""
        self.voice_speed = float(speed)
        self.save_config()
        return f"Voice speed set to {speed}"
    
    def set_voice_volume(self, volume):
        """Set the voice volume"""
        self.voice_volume = float(volume)
        self.save_config()
        return f"Voice volume set to {volume}"
    
    def set_voice_pitch(self, pitch):
        """Set the voice pitch"""
        self.voice_pitch = float(pitch)
        self.save_config()
        return f"Voice pitch set to {pitch}"
    
    def set_voice_gender(self, gender):
        """Set the voice gender"""
        self.voice_gender = gender
        self.save_config()
        return f"Voice gender set to {gender}"
    
    def toggle_anime_voice(self):
        """Toggle anime voice mode"""
        self.anime_voice = not self.anime_voice
        self.save_config()
        status = "enabled" if self.anime_voice else "disabled"
        return f"Anime voice {status}"
    
    def set_anime_voice_style(self, style):
        """Set the anime voice style"""
        self.anime_voice_style = style
        self.save_config()
        return f"Anime voice style set to {style}"
    
    def speak(self, text):
        """Convert text to speech and play it"""
        if not text:
            return
            
        self.is_speaking = True
        
        # Create a temporary file for the audio
        with tempfile.NamedTemporaryFile(suffix='.mp3', delete=False) as temp_file:
            temp_filename = temp_file.name
        
        try:
            # Generate speech
            tts = gTTS(text=text, lang=self.voice_model, slow=False)
            tts.save(temp_filename)
            
            # Apply anime voice effects if enabled
            if self.anime_voice:
                self._apply_anime_voice_effects(temp_filename)
            
            # Play the audio
            pygame.mixer.music.load(temp_filename)
            pygame.mixer.music.set_volume(self.voice_volume)
            pygame.mixer.music.play()
            
            # Wait for the audio to finish playing
            while pygame.mixer.music.get_busy():
                pygame.time.Clock().tick(10)
                
        except Exception as e:
            print(f"Error in speech synthesis: {str(e)}")
        finally:
            # Clean up the temporary file
            if os.path.exists(temp_filename):
                os.unlink(temp_filename)
                
        self.is_speaking = False
    
    def _apply_anime_voice_effects(self, audio_file):
        """Apply anime voice effects to the audio file"""
        try:
            # Load the audio file
            pygame.mixer.music.load(audio_file)
            pygame.mixer.music.play()
            
            # Get the audio data
            audio_data = pygame.mixer.Sound(audio_file)
            audio_array = pygame.sndarray.array(audio_data)
            
            # Apply effects based on the selected style
            if self.anime_voice_style == "kawaii":
                # Higher pitch, faster speed
                audio_array = self._pitch_shift(audio_array, 1.2)
                audio_array = self._speed_change(audio_array, 1.1)
            elif self.anime_voice_style == "tsundere":
                # Slightly higher pitch, normal speed
                audio_array = self._pitch_shift(audio_array, 1.1)
            elif self.anime_voice_style == "yandere":
                # Lower pitch, slower speed
                audio_array = self._pitch_shift(audio_array, 0.9)
                audio_array = self._speed_change(audio_array, 0.9)
            elif self.anime_voice_style == "kuudere":
                # Lower pitch, normal speed
                audio_array = self._pitch_shift(audio_array, 0.9)
            
            # Save the modified audio
            pygame.sndarray.make_sound(audio_array).save(audio_file)
            
        except Exception as e:
            print(f"Error applying anime voice effects: {str(e)}")
    
    def _pitch_shift(self, audio_array, pitch_factor):
        """Shift the pitch of the audio"""
        # Simple pitch shifting by resampling
        return np.interp(
            np.arange(0, len(audio_array), pitch_factor),
            np.arange(0, len(audio_array)),
            audio_array
        )
    
    def _speed_change(self, audio_array, speed_factor):
        """Change the speed of the audio"""
        # Simple speed changing by resampling
        return np.interp(
            np.arange(0, len(audio_array), speed_factor),
            np.arange(0, len(audio_array)),
            audio_array
        )
    
    def listen(self, callback=None):
        """Start listening for voice commands"""
        if self.is_listening:
            return "Already listening"
            
        self.callback = callback
        self.is_listening = True
        self.listen_thread = threading.Thread(target=self._listen_loop)
        self.listen_thread.daemon = True
        self.listen_thread.start()
        
        return "Listening for voice commands"
    
    def stop_listening(self):
        """Stop listening for voice commands"""
        if not self.is_listening:
            return "Not listening"
            
        self.is_listening = False
        if self.listen_thread:
            self.listen_thread.join(timeout=1.0)
            
        return "Stopped listening"
    
    def _listen_loop(self):
        """Main listening loop"""
        with sr.Microphone() as source:
            # Adjust for ambient noise
            self.recognizer.adjust_for_ambient_noise(source, duration=0.5)
            
            while self.is_listening:
                try:
                    # Listen for audio
                    audio = self.recognizer.listen(source, timeout=5, phrase_time_limit=10)
                    
                    # Recognize speech
                    text = self.recognizer.recognize_google(audio, language=self.voice_model)
                    
                    # Call the callback function with the recognized text
                    if self.callback and text:
                        self.callback(text)
                        
                except sr.WaitTimeoutError:
                    # Timeout, continue listening
                    pass
                except sr.UnknownValueError:
                    # Speech was unintelligible
                    pass
                except sr.RequestError as e:
                    # Could not request results
                    print(f"Error in speech recognition: {str(e)}")
                except Exception as e:
                    # Other errors
                    print(f"Error in listening loop: {str(e)}")
    
    def get_available_voice_models(self):
        """Get a list of available voice models"""
        return [
            "en-US", "en-GB", "en-AU", "en-CA", "en-IN",
            "ja-JP", "ko-KR", "zh-CN", "zh-TW", "fr-FR",
            "de-DE", "es-ES", "it-IT", "ru-RU", "pt-BR"
        ]
    
    def get_available_anime_voice_styles(self):
        """Get a list of available anime voice styles"""
        return ["kawaii", "tsundere", "yandere", "kuudere", "senpai"]
    
    def get_voice_settings(self):
        """Get current voice settings"""
        return {
            "model": self.voice_model,
            "speed": self.voice_speed,
            "volume": self.voice_volume,
            "pitch": self.voice_pitch,
            "gender": self.voice_gender,
            "anime_voice": self.anime_voice,
            "anime_voice_style": self.anime_voice_style
        } 