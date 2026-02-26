//
//  TopErrorViewModel.swift
//  ARUtilities
//
//  Created by Afonso Rosa on 12/02/2026.
//

import Foundation

@MainActor
@Observable
final class TopErrorViewModel {
    
    private(set) var errorMessage: String?
    private var autoDismissTask: Task<Void, Never>?
    
    var onDismiss: (() -> Void)?
    
    func show(_ message: String, duration: TimeInterval?) {
        autoDismissTask?.cancel()
        errorMessage = message
        
        if let duration {
            startAutoDismiss(duration: duration)
        }
    }
    
    func dismiss() {
        autoDismissTask?.cancel()
        errorMessage = nil
        onDismiss?()
    }
    
    private func startAutoDismiss(duration: TimeInterval) {
        autoDismissTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            guard !Task.isCancelled else { return }
            self?.dismiss()
        }
    }
    
    @MainActor
    deinit {
        autoDismissTask?.cancel()
    }
}

