//
//  SongStore.swift
//  Shazam
//
//  Created by Aryan Nambiar on 1/27/23.
//  Note: This file is based on the "Persisting Data" tutorial from Apple's website: https://developer.apple.com/tutorials/app-dev-training/persisting-data

import Foundation
import SwiftUI

// Data Store
class SongStore: ObservableObject {
	@Published var songs: [CodableSHMediaItem] = []
	
	private static func fileURL() throws -> URL {
		try FileManager.default.url(for: .documentDirectory,
									   in: .userDomainMask,
									   appropriateFor: nil,
									   create: false)
			.appendingPathComponent("songs.data")
	}
	
	// Load songs.data from file
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
	
	// Save list of CodableSHMediaItems to songs.data
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
