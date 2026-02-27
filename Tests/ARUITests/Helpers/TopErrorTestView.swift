//
//  TopErrorTestView.swift
//  ARUtilities
//
//  Created by Afonso Rosa on 12/02/2026.
//

import SwiftUI
@testable import ARUI

struct TopErrorTestView: View {
    @Binding var errorMessage: String?
    var backgroundColor: Color = .red
    var textColor: Color = .white
    
    init(
        errorMessage: Binding<String?>,
        backgroundColor: Color = .red,
        textColor: Color = .white
    ) {
        self._errorMessage = errorMessage
        self.backgroundColor = backgroundColor
        self.textColor = textColor
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Sample Content")
                .font(.title)
            
            Button("Some Button") {}
                .buttonStyle(.borderedProminent)
            
            Spacer()
        }
        .padding()
        .topError(
            message: $errorMessage,
            duration: nil, // No auto-dismiss for snapshots
            backgroundColor: backgroundColor,
            textColor: textColor
        )
        .transaction { $0.disablesAnimations = true }
    }
}
