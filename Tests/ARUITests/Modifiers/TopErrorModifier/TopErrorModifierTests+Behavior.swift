//
//  TopErrorModifierTests+Behavior.swift
//  ARUtilities
//
//  Created by Afonso Rosa on 12/02/2026.
//

import Testing
import Foundation
@testable import ARUI

@MainActor
@Suite("TopErrorViewModel Behavior Tests")
struct TopErrorViewModelBehaviorTests {
    
    @Test("Error auto-dismisses after specified duration", .timeLimit(.minutes(1)))
    func autoDismissBehavior() async throws {
        let viewModel = TopErrorViewModel()
        let duration: TimeInterval = 0.5
        
        await withCheckedContinuation { continuation in
            viewModel.onDismiss = {
                continuation.resume()
            }
            
            viewModel.show("Test error", duration: duration)
            #expect(viewModel.errorMessage == "Test error")
        }
        
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test("Error does not auto-dismiss when duration is nil")
    func manualDismissBehavior() async throws {
        let viewModel = TopErrorViewModel()
        var dismissed = false
        
        viewModel.onDismiss = {
            dismissed = true
        }
        
        viewModel.show("Test error", duration: nil)
        #expect(viewModel.errorMessage == "Test error")
        
        // Wait a bit - message should still be there
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        #expect(viewModel.errorMessage == "Test error")
        #expect(dismissed == false)
    }
    
    @Test("Changing error message cancels previous auto-dismiss")
    func messageChangeCancelsPreviousTask() async throws {
        let viewModel = TopErrorViewModel()
        let duration: TimeInterval = 1.0
        var dismissCount = 0
        
        viewModel.onDismiss = {
            dismissCount += 1
        }
        
        viewModel.show("First error", duration: duration)
        #expect(viewModel.errorMessage == "First error")
        
        // Change message before auto-dismiss completes
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        viewModel.show("Second error", duration: duration)
        
        #expect(viewModel.errorMessage == "Second error")
        #expect(dismissCount == 0) // No dismiss yet
        
        // Original task should have been cancelled
        // Wait less than the original duration but more than we've already waited
        try await Task.sleep(nanoseconds: 600_000_000) // 0.6 seconds total (0.2 + 0.6 = 0.8 < 1.0)
        
        // Should still be "Second error" because first task was cancelled
        #expect(viewModel.errorMessage == "Second error")
        #expect(dismissCount == 0)
        
        // Wait for the second auto-dismiss to complete
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 more seconds (total: 1.3s from second show)
        
        #expect(viewModel.errorMessage == nil)
        #expect(dismissCount == 1) // Only dismissed once (second auto-dismiss)
    }
    
    @Test("Manual dismiss clears message immediately")
    func manualDismiss() {
        let viewModel = TopErrorViewModel()
        var dismissed = false
        
        viewModel.onDismiss = {
            dismissed = true
        }
        
        viewModel.show("Test error", duration: 5.0)
        #expect(viewModel.errorMessage == "Test error")
        
        viewModel.dismiss()
        #expect(viewModel.errorMessage == nil)
        #expect(dismissed == true)
    }
    
    @Test("Manual dismiss cancels auto-dismiss task")
    func manualDismissCancelsTask() async throws {
        let viewModel = TopErrorViewModel()
        var dismissCount = 0
        
        viewModel.onDismiss = {
            dismissCount += 1
        }
        
        viewModel.show("Test error", duration: 0.5)
        #expect(viewModel.errorMessage == "Test error")
        
        viewModel.dismiss()
        #expect(viewModel.errorMessage == nil)
        #expect(dismissCount == 1)
        
        // Wait past the auto-dismiss duration
        try await Task.sleep(nanoseconds: 600_000_000)
        
        // Should still be nil (task was cancelled)
        #expect(viewModel.errorMessage == nil)
        #expect(dismissCount == 1) // Still only 1 dismiss (manual), auto-dismiss was cancelled
    }
}
