//
//  TTSView.swift
//  TTSAndSTTExample
//
//  Created by SeungWoo Hong on 2023/10/01.
//

import SwiftUI
import AVFoundation

struct TTSView: View {
    
    @StateObject var vm = TTSViewModel()
    
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
            Section("TTS") {
                TextField("Enter text...", text: $vm.text)
                    .font(.headline)
                Button(action: vm.read, label: {
                    HStack {
                        Spacer()
                        Text("Read Text")
                            .font(.headline)
                        Spacer()
                    }
                })
            }
        }
    }
}

#Preview {
    TTSView()
}

class TTSViewModel: ObservableObject {
    let languages = ["English", "Japanese", "Korean"]
    
    private let synthesizer = AVSpeechSynthesizer()
    
    @Published var text = ""
    @Published var selectedLanguage = "English"
    
    func read() {
        if text.isEmpty {
            return
        }
        
        var languageCode = ""
        if selectedLanguage == languages[0] {
            languageCode = "en-US"
        } else if selectedLanguage == languages[1] {
            languageCode = "ja-JP"
        } else if selectedLanguage == languages[2] {
            languageCode = "ko-KR"
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.5
        utterance.voice = AVSpeechSynthesisVoice(language: languageCode)

        synthesizer.speak(utterance)
        
        text = ""
    }
}
