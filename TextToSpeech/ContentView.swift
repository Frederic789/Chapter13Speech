//
//  ContentView.swift
//  Speech
//
//  Created by Student Account on 11/30/23.
//


import SwiftUI
import Speech
import AVFoundation


struct ContentView: View {
    @State private var message = ""
    @State private var isTranscribing = true
    @State private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    @State private var audioEngine = AVAudioEngine()
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?

    var body: some View {
        VStack {
            Text(isTranscribing ? message : "")
                .padding()
        }
        .onAppear(perform: startUp)
    }
    
    // Add other functions here...

}
extension ContentView {
    func startUp() {
        speak("Welcome to the app!")
        startSpeechRecognition()
    }

    func startSpeechRecognition() {
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

         let inputNode = audioEngine.inputNode
        

        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object")
        }

        recognitionRequest.shouldReportPartialResults = true

        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                let transcript = result.bestTranscription.formattedString
                DispatchQueue.main.async {
                    self.message = transcript
                    self.checkForCommands(in: transcript)
                }
            }
        }

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try? audioEngine.start()
    }

    func checkForCommands(in transcript: String) {
        if transcript.lowercased().contains("stop") {
            isTranscribing = false
        } else if transcript.lowercased().contains("start") {
            isTranscribing = true
        }
    }

    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

