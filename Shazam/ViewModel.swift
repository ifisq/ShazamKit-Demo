//
//  ViewModel.swift
//  Shazam
//
//  Created by Aryan Nambiar on 1/25/23.
//

import AVKit
import ShazamKit
import Combine

@MainActor
class ViewModel: NSObject, ObservableObject {
	let audioEngine = AVAudioEngine()
	let mixerNode = AVAudioMixerNode()
	var session: SHSession?
	@Published var matchedSong: SHMediaItem?
	@Published var listening: Bool = false
	@Published var newMatchedSong: Bool = false
	
	override init() {
		super.init()
		configureAudioEngine()
	}
	
	func addAudio(buffer: AVAudioPCMBuffer, audioTime: AVAudioTime) {
		// Add the audio to the current match request.
		session?.matchStreamingBuffer(buffer, at: audioTime)
	}
	
	func configureAudioEngine() {
		// Get the native audio format of the engine's input bus.
		let inputFormat = audioEngine.inputNode.inputFormat(forBus: 0)
		
		// Set an output format compatible with ShazamKit.
		let outputFormat = AVAudioFormat(standardFormatWithSampleRate: 48000, channels: 1)
						
		// Create a mixer node to convert the input.
		audioEngine.attach(mixerNode)

		// Attach the mixer to the microphone input and the output of the audio engine.
		audioEngine.connect(audioEngine.inputNode, to: mixerNode, format: inputFormat)
		audioEngine.connect(mixerNode, to: audioEngine.outputNode, format: outputFormat)
		
		// Install a tap on the mixer node to capture the microphone audio.
		mixerNode.installTap(onBus: 0,
							 bufferSize: 8192,
							 format: outputFormat) { buffer, audioTime in
			// Add captured audio to the buffer used for making a match.
			self.addAudio(buffer: buffer, audioTime: audioTime)
		}
	}
	
	func startListening() {
		do {
			// Throw an error if the audio engine is already running.
			guard !audioEngine.isRunning else { return }
			let audioSession = AVAudioSession.sharedInstance()
			
			// Audio Engine is already running, we just need to un-pause it
			if audioEngine.isRunning {
				try? self.audioEngine.start()
				self.listening = true
				return
			}
			
			// Ask the user for permission to use the mic if required then start the engine.
			try audioSession.setCategory(.playAndRecord)
			audioSession.requestRecordPermission { [weak self] success in
				guard success, let self = self else { return }
				try? self.audioEngine.start()
				self.listening = true
			}
		} catch {
			print(error.localizedDescription)
		}
	}
	
	func stopListening() {
		// Check if the audio engine is already recording.
		if audioEngine.isRunning {
			audioEngine.pause()
			self.listening = false
		}
	}
	
	func match() {
		// Create a session if one doesn't already exist.
		if (session == nil) {
			session = SHSession()
			session?.delegate = self
		}
		
		if !listening {
			// Start listening to the audio to find a match.
			startListening()
		} else {
			stopListening()
		}
	}
}

extension ViewModel: SHSessionDelegate {
	func session(_ session: SHSession, didFind match: SHMatch) {
		guard let mediaItem = match.mediaItems.first else { return }
		Task {
			if mediaItem != self.matchedSong {
				let newCodableSHMediaItem = CodableSHMediaItem(title: mediaItem.title, subtitle: mediaItem.subtitle, artist: mediaItem.artist, artworkURL: mediaItem.artworkURL, videoURL: mediaItem.videoURL, genres: mediaItem.genres, explicitContent: mediaItem.explicitContent, appleMusicURL: mediaItem.appleMusicURL, webURL: mediaItem.webURL)
				
				SongStore.load { result in
					switch result {
					case .failure(let error):
						fatalError(error.localizedDescription)
					case .success(var songs):
						songs.append(newCodableSHMediaItem)
						
						SongStore.save(songs: songs) { result in
							if case .failure(let error) = result {
								fatalError(error.localizedDescription)
							}
						}
					}
				}
				
				self.newMatchedSong = true
				self.stopListening()
			} else {
				self.newMatchedSong = false
			}
			self.matchedSong = mediaItem
		}
	}
}
