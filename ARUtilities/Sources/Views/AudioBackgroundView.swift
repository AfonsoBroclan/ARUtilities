//
//  AudioBackgroundView.swift
//  ARiOSUtilities
//
//  Created by Afonso Rosa on 14/04/2024.
//  Copyright (c) 2024 Afonso Rosa
//

import SwiftUI

import AVFoundation
import SwiftUI

public struct AudioBackgroundView<Content: View>: View {

    private var audioPlayer: AVAudioPlayer?
    private let content: Content

    public init(audio: String,
                numberOfLoops: Int = -1,
                @ViewBuilder content: () -> Content = { EmptyView() }) {

        if let backgroundMusic = Bundle.main.url(forResource: audio, withExtension: "mp3") {

            self.audioPlayer = try? AVAudioPlayer(contentsOf: backgroundMusic)

            self.audioPlayer?.numberOfLoops = numberOfLoops
            self.audioPlayer?.play()
        }

        self.content = content()
    }

    public var body: some View {
        self.content
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in

                self.audioPlayer?.pause()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in

                self.audioPlayer?.play()
            }
    }
}

#Preview {
    AudioBackgroundView(audio: "")
}
