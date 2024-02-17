import SwiftUI
import AVFoundation
import SwiftWhisper
import AudioKit
import OpenAI

enum TranscriptionState {
    case waiting, running, finished(String)
}

extension URL {
    var mimeType: String {
        let pathExtension = self.pathExtension
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as CFString, nil)?.takeRetainedValue() {
            if let mimeType = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimeType as String
            }
        }
        return "application/octet-stream"
    }
}

struct ContentView: View {
    @State private var audioEngine = AVAudioEngine()
    @State private var isRecording = false
    private let normalSize: CGFloat = 200
    private let expandedSize: CGFloat = 250
    @State private var audioFile: AVAudioFile?
    @State private var outputFileURL: URL?
    
    @State private var status = TranscriptionState.waiting
    
    let helpers = Helpers()
    
    var body: some View {
        Circle()
            .fill(Color.blue)
            .frame(width: isRecording ? expandedSize : normalSize, height: isRecording ? expandedSize : normalSize)
            .shadow(radius: 10)
            .animation(.easeInOut(duration: 0.5), value: isRecording)
            .onTapGesture {
                if isRecording {
                    stopRecording()
                } else {
                    startRecording()
                }
                isRecording.toggle()
            }
    }

    func startRecording() {
            let fileManager = FileManager.default
            let docsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioFilename = docsDir.appendingPathComponent("recording.caf")
        
            // Remove existing file
            if fileManager.fileExists(atPath: audioFilename.path) {
                do {
                    try fileManager.removeItem(at: audioFilename)
                } catch {
                    print("Could not remove existing file: \(error.localizedDescription)")
                    return
                }
            }

            outputFileURL = audioFilename

            let inputNode = audioEngine.inputNode
        
            let recordingFormat = inputNode.outputFormat(forBus: 0)


            do {
                audioFile = try AVAudioFile(forWriting: audioFilename, settings: recordingFormat.settings)
            } catch {
                print("Failed to create audio file: \(error)")
                return
            }

            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
                do {
                    try self.audioFile?.write(from: buffer)
                } catch {
                    print("Error writing audio buffer to file: \(error)")
                }
            }

            do {
                try audioEngine.start()
            } catch {
                print("AudioEngine didn't start: \(error)")
            }
        }


        func stopRecording() {
            audioEngine.inputNode.removeTap(onBus: 0)
            audioEngine.stop()
            audioFile = nil // Close the file

            guard let outputFileURL = outputFileURL else {
                print("Recording URL is nil")
                return
            }
            
            Task {
                await processing(sourceUrl: outputFileURL)
            }

//            helpers.convertCafToM4a(sourceUrl: outputFileURL) { result in
//                DispatchQueue.main.async {
//                    switch result {
//                    case .success(let convertedUrl):
//                        Task {
//                            do {
//                                try await helpers.macPaw(fileUrl: convertedUrl)
//                                } catch {
//                                    // Handle the error here
//                                    print("An error occurred: \(error)")
//                                }
//                        }
//                    case .failure(let error):
//                        print("Conversion error: \(error.localizedDescription)")
//                    }
//                }
//            }
        }
    
        func processing(sourceUrl: URL) async {
            do {
                let convertedUrl = try await helpers.convertCafToM4a(sourceUrl: sourceUrl)
                let command = try await helpers.voicetotext(fileUrl: convertedUrl)
                print(command)
//                let code = try await helpers.texttocode(command: command)
            } catch {
                // Handle any errors that occurred during conversion or processing
                print("An error occurred: \(error)")
            }
        }
    
}

#Preview {
    ContentView()
}
