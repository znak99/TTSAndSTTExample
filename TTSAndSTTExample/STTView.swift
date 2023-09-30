//
//  STTView.swift
//  TTSAndSTTExample
//
//  Created by SeungWoo Hong on 2023/10/01.
//

import SwiftUI
import Speech

struct STTView: View {
    
    @StateObject var vm = STTViewModel()
    
    var body: some View {
        Form {
            Section("Language") {
                Picker("Select language", selection: $vm.selectedLanguage) {
                    ForEach(vm.languages, id: \.self) { language in
                        Text(language)
                            .font(.subheadline)
                    }
                }
            }
            .font(.subheadline)
            .pickerStyle(.menu)
            Section("STT") {
                Button(action: {
                    if vm.isRecording {
                        vm.stopRecord()
                    } else {
                        vm.startRecord()
                    }
                }, label: {
                    HStack {
                        Spacer()
                        Text(vm.isRecording ? "Stop record" : "Start record")
                            .font(.headline)
                            .foregroundStyle(vm.isRecording ? .red : .blue)
                        Image(systemName: "waveform")
                            .foregroundStyle(vm.isRecording ? .red : .blue)
                        Spacer()
                    }
                })
                .disabled(vm.isSTTDisable)
                Text(vm.text)
            }
        }
        .onAppear {
            vm.requestSpeechAuthorization()
        }
    }
}

#Preview {
    STTView()
}

class STTViewModel: ObservableObject {
    let languages = ["English", "Japanese", "Korean"]
    
    private let englishRecognizer : SFSpeechRecognizer?
    private let japaneseRecognizer : SFSpeechRecognizer?
    private let koreanRecognizer : SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    private var audioEngine = AVAudioEngine()
    
    init() {
        englishRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        japaneseRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))
        koreanRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ko-KR"))
    }
    
    @Published var selectedLanguage = "English"
    @Published var text = ""
    @Published var isRecording = false
    @Published var isSTTDisable = false
    
    func startRecord() {
        do {
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
                self.recognitionRequest?.append(buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            
            text = ""
            
            if let recognitionRequest = recognitionRequest {
                if selectedLanguage == languages[0] {
                    transcription(recognizer: englishRecognizer,
                                  request: recognitionRequest)
                } else if selectedLanguage == languages[1] {
                    transcription(recognizer: japaneseRecognizer,
                                  request: recognitionRequest)
                } else if selectedLanguage == languages[2] {
                    transcription(recognizer: koreanRecognizer,
                                  request: recognitionRequest)
                }
            }
            isRecording = true
        } catch {
            print("Audio Engine error: \(error)")
        }
    }
    
    func stopRecord() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        isRecording = false
    }
    
    func transcription(recognizer: SFSpeechRecognizer?,
                       request: SFSpeechAudioBufferRecognitionRequest) {
        recognizer?.recognitionTask(with: request) { result, error in
            if let result = result {
                self.text = result.bestTranscription.formattedString
            } else if let error = error {
                print("Recognition error: \(error)")
            }
        }
    }
    
    func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            if authStatus == .authorized {
                print("Speech recognition authorized")
            } else {
                print("Speech recognition not authorized")
                self.isSTTDisable.toggle()
            }
        }
    }
}
