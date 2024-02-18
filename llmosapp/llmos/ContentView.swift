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
    @State private var animate = false
    @State var isRotating = false
    
    @State private var status = TranscriptionState.waiting
    
    let helpers = Helpers()
    
    var body: some View {
        ZStack {
            ZStack {
                Image("shadow")
                Image("icon-bg")
                Image("pink-top")
                    .rotationEffect(.degrees(isRotating ? 320 : -360))
                    .hueRotation(.degrees(isRotating ? -270 : 60))
                
                Image("pink-left")
                    .rotationEffect(.degrees(isRotating ? -360 : 180))
                    .hueRotation(.degrees(isRotating ? -220 : 300))
                
                Image("blue-middle")
                    .rotationEffect(.degrees(isRotating ? -360 : 420))
                    .hueRotation(.degrees(isRotating ? -150 : 0))
                    .rotation3DEffect(.degrees(75), axis: (x: isRotating ? 1 : 5, y: 0, z: 0))
                
                Image("blue-right")
                    .rotationEffect(.degrees(isRotating ? -360 : 420))
                    .hueRotation(.degrees(isRotating ? 720 : -50))
                    .rotation3DEffect(.degrees(75), axis: (x: 1, y: 0, z: isRotating ? -5 : 15))
                
                Image("intersect")
                    .rotationEffect(.degrees(isRotating ? 30 : -420))
                    .hueRotation(.degrees(isRotating ? 0 : 720))
                    .rotation3DEffect(.degrees(15), axis: (x: 1, y: 1, z: 1), perspective: isRotating ? 5 : -5)
                
                Image("green-right")
                    .rotationEffect(.degrees(isRotating ? -300 : 360))
                    .hueRotation(.degrees(isRotating ? 300 : -15))
                    .rotation3DEffect(.degrees(15), axis: (x: 1, y: isRotating ? -1 : 1, z: 0), perspective: isRotating ? -1 : 1)
                
                Image("green-left")
                    .rotationEffect(.degrees(isRotating ? 360 : -360))
                    .hueRotation(.degrees(isRotating ? 180 :50))
                    .rotation3DEffect(.degrees(75), axis: (x: 1, y:isRotating ? -5 : 15, z: 0))
                
                
                Image("bottom-pink")
                    .rotationEffect(.degrees(isRotating ? 400 : -360))
                    .hueRotation(.degrees(isRotating ? 0 : 230))
                    .opacity(0.25)
                    .blendMode(.multiply)
                    .rotation3DEffect(.degrees(75), axis: (x: 5, y:isRotating ? 1 : -45, z: 0))
            }
            .blendMode(isRotating ? .hardLight : .difference )
            .scaleEffect(isRecording ? 1.1 : 1.0) // Adjust scale effect based on recording state
            .animation(isRecording ? Animation.easeInOut(duration: 1).repeatForever(autoreverses: true) : .default, value: isRecording) // Apply pulsing animation only when recording
            
            Image("highlight")
                .rotationEffect(.degrees(isRotating ? 360 : 250))
                .hueRotation(.degrees(isRotating ? 0 : 230))
                .padding()
                .onAppear{
                    withAnimation(.linear(duration: 12).repeatForever(autoreverses: true)) {
                        isRotating.toggle()
                    }
                }
        }.scaleEffect(0.6)
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
        }
    
        func processing(sourceUrl: URL) async {
            do {
                let convertedUrl = try await helpers.convertCafToM4a(sourceUrl: sourceUrl)
                let command = try await helpers.voicetotext(fileUrl: convertedUrl)
                print(command)
                
                // DISPLAY THE TEXT COMMAND UNDER THE PULSING BUBBLE IN CONTENTVIEW
                
                let code = try await helpers.texttocode(command: command)
                print("Last thing:")
                print(code)
                
                try await helpers.executeAppleScript(code: code)
            } catch {
                // Handle any errors that occurred during conversion or processing
                print("An error occurred: \(error)")
            }
        }
    
}

#Preview {
    ContentView()
}
