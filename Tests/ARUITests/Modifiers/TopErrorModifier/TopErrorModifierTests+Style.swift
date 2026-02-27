//
//  TopErrorModifierTests+Style.swift
//  ARUtilities
//
//  Created by Afonso Rosa on 12/02/2026.
//

import Testing
import SwiftUI
import SnapshotTesting
@testable import ARUI

@MainActor
@Suite("TopErrorModifier Style Tests")//, .snapshots(record: .all))
struct TopErrorModifierStyleTests {
    
    // MARK: - Message Lengths
    
    @Test("Short error message")
    func shortMessage() {
        let view = TopErrorTestView(errorMessage: .constant("Error"))
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13)))
    }
    
    @Test("Long error message")
    func longMessage() {
        let view = TopErrorTestView(errorMessage: .constant("An unexpected error occurred while processing your request. Please try again later."))
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13)))
    }
    
    @Test("Multi-line error message")
    func multiLineMessage() {
        let view = TopErrorTestView(errorMessage: .constant("Network connection failed.\nPlease check your internet connection and try again."))
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13)))
    }
    
    // MARK: - Color Combinations
    
    @Test("Default colors (red background, white text)")
    func defaultColors() {
        let view = TopErrorTestView(
            errorMessage: .constant("Default red error"),
            backgroundColor: .red,
            textColor: .white
        )
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13)))
    }
    
    @Test("Warning colors (orange background, black text)")
    func warningColors() {
        let view = TopErrorTestView(
            errorMessage: .constant("Warning message"),
            backgroundColor: .orange,
            textColor: .black
        )
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13)))
    }
    
    @Test("Success colors (green background, white text)")
    func successColors() {
        let view = TopErrorTestView(
            errorMessage: .constant("Success message"),
            backgroundColor: .green,
            textColor: .white
        )
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13)))
    }
    
    @Test("Custom colors (purple background, yellow text)")
    func customColors() {
        let view = TopErrorTestView(
            errorMessage: .constant("Custom styled error"),
            backgroundColor: .purple,
            textColor: .yellow
        )
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13)))
    }
}
