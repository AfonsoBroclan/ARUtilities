//
//  TopErrorModifier.swift
//  ARUtilities
//
//  Created by Afonso Rosa on 12/02/2026.
//

import SwiftUI

struct TopErrorModifier: ViewModifier {
    
    @Binding var errorMessage: String?
    let duration: TimeInterval?
    let backgroundColor: Color
    let textColor: Color
    
    @State private var viewModel = TopErrorViewModel()
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(textColor)
                        .padding()
                        .background(backgroundColor)
                        .cornerRadius(Constants.cornerRadius)
                        .shadow(radius: Constants.shadowRadius)
                        .padding(.top, Constants.topPadding)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .accessibilityAddTraits(.isModal)
                        .accessibilityLabel("Error: \(errorMessage)")
                }
            }
            .animation(.spring(), value: viewModel.errorMessage != nil)
            .onChange(of: errorMessage) { _, newValue in
                if let newValue {
                    viewModel.show(newValue, duration: duration)
                } else {
                    viewModel.dismiss()
                }
            }
            .onAppear {
                // Sync initial state
                if let errorMessage {
                    viewModel.show(errorMessage, duration: duration)
                }
            }
            .onDisappear {
                viewModel.dismiss()
            }
    }
    
    private enum Constants {
        static let cornerRadius: CGFloat = 10
        static let shadowRadius: CGFloat = 5
        static let topPadding: CGFloat = 16
    }
}

extension View {
    /// Displays an error message at the top of the screen.
    /// - Parameters:
    ///   - errorMessage: Binding to an optional error message. When non-nil, the error is displayed.
    ///   - duration: Auto-dismiss duration in seconds. Pass `nil` for manual dismissal only. Defaults to 3 seconds.
    ///   - backgroundColor: Background color of the error banner. Defaults to red.
    ///   - textColor: Text color of the error message. Defaults to white.
    public func topError(
        message errorMessage: Binding<String?>,
        duration: TimeInterval? = 3.0,
        backgroundColor: Color = .red,
        textColor: Color = .white
    ) -> some View {
        modifier(TopErrorModifier(
            errorMessage: errorMessage,
            duration: duration,
            backgroundColor: backgroundColor,
            textColor: textColor
        ))
    }
}
