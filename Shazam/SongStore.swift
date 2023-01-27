//
//  SongStore.swift
//  Shazam
//
//  Created by Aryan Nambiar on 1/27/23.
//

import Foundation
import SwiftUI
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

class SongStore: ObservableObject {
	@Published var songs: [CodableSHMediaItem] = []
	
	private static func fileURL() throws -> URL {
		try FileManager.default.url(for: .documentDirectory,
									   in: .userDomainMask,
									   appropriateFor: nil,
									   create: false)
			.appendingPathComponent("songs.data")
	}
	
	static func load(completion: @escaping (Result<[CodableSHMediaItem], Error>)->Void) {
		DispatchQueue.global(qos: .background).async {
			do {
				let fileURL = try fileURL()
				guard let file = try? FileHandle(forReadingFrom: fileURL) else {
					DispatchQueue.main.async {
						completion(.success([]))
					}
					return
				}
				let decodedSongs = try JSONDecoder().decode([CodableSHMediaItem].self, from: file.availableData)
				DispatchQueue.main.async {
					completion(.success(decodedSongs))
				}
			} catch {
				DispatchQueue.main.async {
					completion(.failure(error))
				}
			}
		}
	}
	
	static func save(songs: [CodableSHMediaItem], completion: @escaping (Result<Int, Error>)->Void) {
		DispatchQueue.global(qos: .background).async {
			do {
				let data = try JSONEncoder().encode(songs)
				let outfile = try fileURL()
				try data.write(to: outfile)
				DispatchQueue.main.async {
					completion(.success(songs.count))
				}
			} catch {
				DispatchQueue.main.async {
					completion(.failure(error))
				}
			}
		}
	}
}
