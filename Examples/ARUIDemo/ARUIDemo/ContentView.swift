//
//  ContentView.swift
//  ARUIDemo
//
//  Created by Afonso Rosa on 20/02/2026.
//

import SwiftUI
import ARUI

struct ContentView: View {
    @State private var errorMessage: String?
    @State private var useManualDismiss: Bool = false
    
    var body: some View {
        VStack(spacing: 30) {
            Text("TopError Modifier Demo")
                .font(.largeTitle)
                .padding()
            
            Spacer()
            
            VStack(spacing: 20) {
                Button("Show Error (Auto-dismiss)") {
                    useManualDismiss = false
                    errorMessage = "Something went wrong!"
                }
                .accessibilityIdentifier("showErrorButton")
                .buttonStyle(.borderedProminent)
                
                Button("Show Long Error") {
                    useManualDismiss = false
                    errorMessage = "An unexpected error occurred while processing your request. Please try again later or contact support."
                }
                .accessibilityIdentifier("showLongErrorButton")
                .buttonStyle(.borderedProminent)
                
                Button("Show Manual Dismiss Error") {
                    useManualDismiss = true
                    errorMessage = "This error requires manual dismissal. Tap the dismiss button below."
                }
                .accessibilityIdentifier("showManualErrorButton")
                .buttonStyle(.borderedProminent)
                
                Button("Dismiss") {
                    errorMessage = nil
                }
                .accessibilityIdentifier("dismissButton")
                .buttonStyle(.bordered)
                .disabled(errorMessage == nil)
            }
            
            Spacer()
            
            Text("Current Error:")
                .font(.caption)
            Text(errorMessage ?? "None")
                .font(.caption)
                .foregroundColor(.secondary)
                .accessibilityIdentifier("currentErrorLabel")
            
            Spacer()
        }
        .padding()
        .topError(
            message: $errorMessage,
            duration: useManualDismiss ? nil : 3.0
        )
    }
}

#Preview {
    ContentView()
}
