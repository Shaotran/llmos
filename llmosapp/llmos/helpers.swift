//
//  helpers.swift
//  llmos
//
//  Created by Ethan Shaotran on 2/17/24.
//

import SwiftUI
import AVFoundation
import SwiftWhisper
import AudioKit
import OpenAI

struct Helpers {
    func voicetotext(fileUrl: URL) async throws -> String {
        var apiKey = ""
        do {
            apiKey = try getAPIKey()
        } catch {
            print(error)
            throw error
        }
        
        let openAI = OpenAI(apiToken: apiKey)

        let data: Data
        do {
            data = try Data(contentsOf: fileUrl)
        } catch {
            print("Error loading file: \(error)")
            throw error
        }
            
        let query = AudioTranscriptionQuery(file: data, fileName: fileUrl.lastPathComponent, model: .whisper_1)

        let result = try await openAI.audioTranscriptions(query: query)
        return result.text
    }
    
    func texttocode(command: String) async throws -> Void {
        var apiKey = ""
        do {
            apiKey = try getAPIKey()
        } catch {
            print(error)
            throw error
        }
        
        let openAI = OpenAI(apiToken: apiKey)
                
        let query = ChatQuery(model: .gpt4_turbo_preview, messages: [
            .init(role: .system, content: "You are Librarian-GPT. You know everything about the books."),
            .init(role: .user, content: "Who wrote Harry Potter?")
        ])
        
        let result = try await openAI.chats(query: query)
        print(result)
        
        
    }
    
    func convertCafToM4a(sourceUrl: URL) async throws -> URL {
        let outputUrl = sourceUrl.deletingPathExtension().appendingPathExtension("m4a")
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: outputUrl.path) {
            try fileManager.removeItem(at: outputUrl)
        }
        
        let asset = AVURLAsset(url: sourceUrl)
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
            throw NSError(domain: "ConversionError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not create AVAssetExportSession"])
        }
        
        exportSession.outputURL = outputUrl
        exportSession.outputFileType = .m4a
                
        return try await withCheckedThrowingContinuation { continuation in
            exportSession.exportAsynchronously {
                switch exportSession.status {
                case .completed:
                    continuation.resume(returning: outputUrl)
                case .failed, .cancelled:
                    let error = exportSession.error ?? NSError(domain: "ConversionError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unknown conversion error"])
                    continuation.resume(throwing: error)
                default:
                    let unexpectedError = NSError(domain: "ConversionError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unexpected export session status"])
                    continuation.resume(throwing: unexpectedError)
                }
            }
        }
    }
    
//    func getAPIKey() throws -> String? {
//        guard let filePath = Bundle.main.path(forResource: "Config", ofType: "plist") else { return nil }
//        let plist = NSDictionary(contentsOfFile: filePath)
//        let value = plist?.object(forKey: "OPENAIKEY") as? String
//        return value
//    }
    
    enum APIKeyError: Error {
        case keyNotFound
    }

    func getAPIKey() throws -> String {
        guard let filePath = Bundle.main.path(forResource: "config", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: filePath),
              let value = plist.object(forKey: "OPENAIKEY") as? String else {
                throw APIKeyError.keyNotFound
                }
        return value
    }


}
