//
//  ContentView.swift
//  Shazam
//
//  Created by Aryan Nambiar on 1/25/23.
//

import SwiftUI
import ShazamKit

struct ContentView: View {
	@StateObject private var viewModel = ViewModel()
	@StateObject private var store = SongStore()
	@State private var showShazamSheet = false
	var shazamSong: SHMediaItem?
	
	let columns = [
		GridItem(.fixed(150), spacing: 25),
		GridItem(.fixed(150), spacing: 25)
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
				Text("Recent Shazams")
					.padding(.horizontal, 20)
					.font(.system(size: 20, weight: .semibold, design: .default))
					.frame(maxWidth: .infinity, alignment: .leading)
				ScrollView (.vertical, showsIndicators: false) {
					 LazyVGrid(columns: columns, spacing: 20) {
						 ForEach(store.songs.reversed(), id: \.self) { song in
							 let mediaItem = SHMediaItem(properties: [.title: song.title, .subtitle: song.subtitle, .artist: song.artist, .artworkURL: song.artworkURL, .videoURL: song.videoURL, .genres: song.genres, .explicitContent: song.explicitContent, .appleMusicURL: song.appleMusicURL, .webURL: song.webURL])
							 
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
									 Text(song.title ?? "")
										.padding()
										.multilineTextAlignment(.leading)
								 }
								 .cornerRadius(15)
								 .overlay(
									 RoundedRectangle(cornerRadius: 15)
										 .stroke(Color.white, lineWidth: 2)
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
			}
			.sheet(isPresented: $viewModel.newMatchedSong){
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
		}
	}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
