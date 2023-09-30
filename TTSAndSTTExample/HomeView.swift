//
//  HomeView.swift
//  TTSAndSTTExample
//
//  Created by SeungWoo Hong on 2023/10/01.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            Form {
                Section("TTS") {
                    NavigationLink(destination: TTSView()) {
                        Text("text to speech")
                    }
                }
                Section("STT") {
                    NavigationLink(destination: STTView()) {
                        Text("speech to text")
                    }
                }
            }
            .navigationTitle(Text("TTS & STT"))
        }
    }
}

#Preview {
    HomeView()
}
