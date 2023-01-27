//
//  ContentView.swift
//  Shazam
//
//  Created by Aryan Nambiar on 1/25/23.
//

import SwiftUI

struct ContentView: View {
	@StateObject private var viewModel = ViewModel()

	var body: some View {
		NavigationView {
			VStack(spacing: 12) {
				
				Spacer()
				if viewModel.matchedSong != nil {
					AsyncImage(
						url: viewModel.matchedSong?.artworkURL,
						content: { image in
										image.image?.resizable()
											 .aspectRatio(contentMode: .fit)
											 .frame(maxWidth: 250, maxHeight: 250)
						}
					)
					Text(viewModel.matchedSong?.title ?? "")
					Text(viewModel.matchedSong?.artist ?? "")
					if viewModel.matchedSong?.explicitContent == true {
						Text("Explicit")
					}
					
					Text("Genres: \((viewModel.matchedSong?.genres ?? []).joined(separator: ", "))")
					
					if let appleMusicURL = viewModel.matchedSong?.appleMusicURL {
						Button(action: { UIApplication.shared.open(appleMusicURL) }) {
							Text("Open in Apple Music")
						}
					}
					
					if let shazamURL = viewModel.matchedSong?.webURL {
						Button(action: { UIApplication.shared.open(shazamURL) }) {
							Text("Open in Shazam")
						}
					}
				}
				
				Spacer()
				
				Button(action: {
					viewModel.match()
				}) {
					Text(viewModel.listening ? "Stop Shazam" : "Start Shazam")
				}
			}
			.navigationTitle("Shazam")
		}
	}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
