//
//  ContentView.swift
//  Shazam
//
//  Created by Aryan Nambiar on 1/25/23.
//  This view shows a list of recently Shazamed songs + allows the user to control microphone access to Shazam new songs

import SwiftUI
import ShazamKit

struct ContentView: View {
	@StateObject private var viewModel = ViewModel()
	@StateObject private var store = SongStore()
	@State private var showShazamSheet = false
	@Environment(\.scenePhase) var scenePhase
	
	// Fit as many grid items as possible (proper formatting on iPad)
	let columns = [
		GridItem(.adaptive(minimum: 150, maximum: 150), spacing: 25)
	]

	var body: some View {
		NavigationView {
			VStack(spacing: 12) {
				Text("Shazam")
					.padding(.horizontal, 20)
					.padding(.top, 10)
					.font(.system(size: 40, weight: .bold, design: .default))
					.frame(maxWidth: .infinity, alignment: .leading)
					.foregroundColor(.primary)
				
				Text("Recent")
					.padding(.horizontal, 20)
					.font(.system(size: 20, weight: .semibold, design: .default))
					.frame(maxWidth: .infinity, alignment: .leading)
				
				if (store.songs.isEmpty) {
					Text("Shazam some songs for them to appear here!")
						.frame(maxWidth: .infinity, maxHeight: .infinity)
						.foregroundColor(Color(uiColor: .systemGray))
				}
				
				ScrollView (.vertical, showsIndicators: false) {
					 LazyVGrid(columns: columns, spacing: 20) {
						 ForEach(store.songs.reversed(), id: \.self) { song in
							 // Converting from persisted CodableSHMediaItem to SHMediaItem
							 let mediaItem = buildSHMediaItem(codableItem: song)
							 
							 NavigationLink(destination: SongView(matchedSong: mediaItem)) {
								 AsyncImage(
									url: song.artworkURL ?? URL(string: ""),
									content: { image in
													image.resizable()
														 .aspectRatio(contentMode: .fit)
									},
									placeholder: {
										Rectangle()
											.background(
												Color(uiColor: .systemGray4)
													.cornerRadius(15)
											)
											.aspectRatio(contentMode: .fit)
									}
								 )
								 .brightness(-0.4)
								 .overlay(alignment: .bottomLeading) {
									 VStack(spacing: 1) {
										 Text(song.title ?? "")
											.lineLimit(1)
											.fontWeight(.semibold)
											.frame(maxWidth: .infinity, alignment: .leading)
										 Text(song.artist ?? "")
											 .lineLimit(1)
											.frame(maxWidth: .infinity, alignment: .leading)
											.font(.caption)
									 }
									 .padding(.bottom, 10)
									 .padding(.leading, 10)
								 }
								 .cornerRadius(15)
								 .overlay(
									 RoundedRectangle(cornerRadius: 15)
										 .stroke(Color.primary, lineWidth: 2)
								 )
							 }
							 .foregroundColor(.white)
						 }
					 }
					.padding(.top, 2)
				}
				.padding(.horizontal, 10)
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				
				Spacer()
				
				Button(action: {
					viewModel.match()
				}) {
					Text(viewModel.listening ? "Stop Shazam" : "Start Shazam")
						.padding()
						.padding(.horizontal, 20)
						.background(
							Color(uiColor: .systemBlue)
								.cornerRadius(15)
						)
						.foregroundColor(.white)
				}
				.padding(.bottom, 10)
			}
			.sheet(isPresented: $viewModel.newMatchedSong){
				// Update list of stored songs on a new match
				let _ = SongStore.load { result in
					switch result {
					case .failure(let error):
						fatalError(error.localizedDescription)
					case .success(let songs):
						store.songs = songs
					}
				}
				
				SongView(matchedSong: viewModel.matchedSong!)
			}
			.onAppear {
				SongStore.load { result in
					switch result {
					case .failure(let error):
						fatalError(error.localizedDescription)
					case .success(let songs):
						store.songs = songs
					}
				}
			}
			.onDisappear {
				viewModel.stopListening()
			}
			.onChange(of: scenePhase) { newPhase in
				if (newPhase == .active) {
					// Reset the audio engine as closing/reopening app makes existing one non-functional
					viewModel.configureAudioEngine()
				}
			}
		}
		.navigationViewStyle(StackNavigationViewStyle())
	}
}
