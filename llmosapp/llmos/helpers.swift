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
import AppKit

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
    
    func texttocode(command: String) async throws -> String {
        var apiKey = ""
        do {
            apiKey = try getAPIKey()
        } catch {
            print(error)
            throw error
        }
        
        let openAI = OpenAI(apiToken: apiKey)
                
        let query = ChatQuery(model: .gpt4_turbo_preview, messages: [
            .init(role: .system, content: """
                You are a helpful personal assistant.
            """),
            .init(role: .user, content: Prompt.promptStr + command)
        ])
        
        print("Will now query for code")
                
        let result = try await openAI.chats(query: query)
        print("Got the code")
        print(result)
        var extractedCode = ""
        if let content = result.choices[0].message.content {
            extractedCode = extractCode(from: content)[0]
        } else {
            print("Content is nil")
        }
        print("Extracted")
        return extractedCode
    }
    
    func extractCode(from text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: "```(?:applescript)?(.+?)```", options: [.dotMatchesLineSeparators])
            let nsString = text as NSString
            let results = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
            return results.map { nsString.substring(with: $0.range(at: 1)) }
        } catch let error {
            print("Invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    func executeAppleScript(code: String) {
//        var error: NSDictionary?
//        if let script = NSAppleScript(source: code) {
//            let output = script.executeAndReturnError(&error)
//            if let error = error {
//                print(error)
//            } else {
//                print(output)
//            }
//        }
        print("LETS GO")
        let process = Process()
        let pipe = Pipe()

        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = ["-e", code]
        process.standardOutput = pipe
        process.standardError = pipe

        do {
            try process.run()
            process.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                print(output)
            }
        } catch {
            print("Failed to execute script: \(error)")
        }
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
