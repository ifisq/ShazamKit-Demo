//
//  SongView.swift
//  Shazam
//
//  Created by Aryan Nambiar on 1/26/23.
//  This view displays song metadata for Shazamed songs

import SwiftUI
import ShazamKit

struct SongView: View {
	let matchedSong: SHMediaItem
    var body: some View {
		VStack(spacing: 10) {
			AsyncImage(
				url: matchedSong.artworkURL,
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
			.cornerRadius(15)
			.overlay(alignment: .bottomLeading) {
				VStack() {
					Text(matchedSong.title ?? "")
						.padding(.horizontal, 10)
						.font(.system(size: 40, weight: .bold, design: .default))
						.frame(maxWidth: .infinity, alignment: .leading)
						.foregroundColor(.white)
					
					Text(matchedSong.artist ?? "")
						.font(.system(size: 30, weight: .regular, design: .default))
						.padding(.bottom, 10)
						.padding(.horizontal, 10)
						.frame(maxWidth: .infinity, alignment: .leading)
						.foregroundColor(.white)
				}
			}
			.overlay(alignment: .bottomTrailing) {
				if matchedSong.explicitContent == true {
					// Explicit Symbol
					Image(systemName: "e.square.fill")
						.padding(.trailing, 10)
						.padding(.bottom, 10)
						.font(.system(size: 25))
				}
			}
			
			if matchedSong.genres != [] {
				Text("Genres")
					.padding(.horizontal, 10)
					.font(.system(size: 25, weight: .bold, design: .default))
					.frame(maxWidth: .infinity, alignment: .leading)
			}
			
			ScrollView (.horizontal, showsIndicators: false) {
				 HStack {
					 ForEach(matchedSong.genres, id: \.self) { genre in
						 Text(genre)
							.padding()
							.background(
								Color(uiColor: .systemGray4)
									.cornerRadius(15)
							)
					 }
				 }
			}
			.padding(.horizontal, 10)
			
			if let videoURL = matchedSong.videoURL {
				Button(action: { UIApplication.shared.open(videoURL) }) {
					Text("Open Music Video")
						.padding()
						.font(.system(size: 15, weight: .regular, design: .default))
						.frame(maxWidth: .infinity, alignment: .leading)
						.background(
							Color(uiColor: .systemGray4)
								.cornerRadius(15)
						)
				}
				.padding(.horizontal, 10)
			}
			
			if let appleMusicURL = matchedSong.appleMusicURL {
				Button(action: { UIApplication.shared.open(appleMusicURL) }) {
					Text("Open in Apple Music")
						.padding()
						.font(.system(size: 15, weight: .regular, design: .default))
						.frame(maxWidth: .infinity, alignment: .leading)
						.background(
							Color(uiColor: .systemGray4)
								.cornerRadius(15)
						)
				}
				.padding(.horizontal, 10)
			}
			
			if let shazamURL = matchedSong.webURL {
				Button(action: { UIApplication.shared.open(shazamURL) }) {
					Text("Open in Shazam")
						.padding()
						.font(.system(size: 15, weight: .regular, design: .default))
						.frame(maxWidth: .infinity, alignment: .leading)
						.background(
							Color(uiColor: .systemGray4)
								.cornerRadius(15)
						)
				}
				.padding(.horizontal, 10)
			}
			Spacer()
		}
    }
}
