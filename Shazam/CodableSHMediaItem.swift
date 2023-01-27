//
//  CodableSHMediaItem.swift
//  Shazam
//
//  Created by Aryan Nambiar on 1/27/23.
//  This struct is used to store the important data from an SHMediaItem so we can persist it through app launches.

import Foundation
import ShazamKit

struct CodableSHMediaItem: Codable, Hashable {
	let title: String?
	let subtitle: String?
	let artist: String?
	let artworkURL: URL?
	let videoURL: URL?
	let genres: Array<String>
	let explicitContent: Bool
	let appleMusicURL: URL?
	let webURL: URL?
}

// Helper function to convert from CodableSHMediaItem to SHMediaItem
func buildSHMediaItem(codableItem: CodableSHMediaItem) -> SHMediaItem {
	return SHMediaItem(
	   properties: [
		   .title: codableItem.title ?? "",
		   .subtitle: codableItem.subtitle ?? "",
		   .artist: codableItem.artist ?? "",
		   .artworkURL: codableItem.artworkURL as Any,
		   .videoURL: codableItem.videoURL as Any,
		   .genres: codableItem.genres,
		   .explicitContent: codableItem.explicitContent,
		   .appleMusicURL: codableItem.appleMusicURL as Any,
		   .webURL: codableItem.webURL as Any
	   ]
	)
}

// Helper function to convert from SHMediaItem to CodableSHMediaItem
func buildCodableSHMediaItem(mediaItem: SHMediaItem) -> CodableSHMediaItem {
	return CodableSHMediaItem(
		title: mediaItem.title,
		subtitle: mediaItem.subtitle,
		artist: mediaItem.artist,
		artworkURL: mediaItem.artworkURL,
		videoURL: mediaItem.videoURL,
		genres: mediaItem.genres,
		explicitContent: mediaItem.explicitContent,
		appleMusicURL: mediaItem.appleMusicURL,
		webURL: mediaItem.webURL
	)
}
