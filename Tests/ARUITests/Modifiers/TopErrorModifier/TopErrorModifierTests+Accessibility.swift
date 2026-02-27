//
//  TopErrorModifierTests+Accessibility.swift
//  ARUtilities
//
//  Created by Afonso Rosa on 12/02/2026.
//

import Testing
import SwiftUI
import SnapshotTesting
@testable import ARUI

@MainActor
@Suite("TopErrorModifier Accessibility Tests")//, .snapshots(record: .all))
struct TopErrorModifierAccessibilityTests {
    
    // MARK: - Dark Mode
    
    @Test("Error in dark mode with default colors")
    func errorVisibleDarkMode() {
        let view = TopErrorTestView(errorMessage: .constant("Dark mode error"))
            .preferredColorScheme(.dark)
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13)))
    }
    
    @Test("Warning colors in dark mode")
    func warningColorsDarkMode() {
        let view = TopErrorTestView(
            errorMessage: .constant("Warning in dark mode"),
            backgroundColor: .orange,
            textColor: .black
        )
        .preferredColorScheme(.dark)
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13)))
    }
    
    @Test("Success colors in dark mode")
    func successColorsDarkMode() {
        let view = TopErrorTestView(
            errorMessage: .constant("Success in dark mode"),
            backgroundColor: .green,
            textColor: .white
        )
        .preferredColorScheme(.dark)
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13)))
    }
    
    // MARK: - Dynamic Type
    
    @Test("Error with extra small text size")
    func extraSmallTextSize() {
        let view = TopErrorTestView(errorMessage: .constant("Error message with extra small text"))
            .environment(\.sizeCategory, .extraSmall)
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13)))
    }
    
    @Test("Error with large text size")
    func largeTextSize() {
        let view = TopErrorTestView(errorMessage: .constant("Error message with large text"))
            .environment(\.sizeCategory, .large)
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13)))
    }
    
    @Test("Error with extra extra large text size")
    func extraExtraLargeTextSize() {
        let view = TopErrorTestView(errorMessage: .constant("Error message with extra extra large text"))
            .environment(\.sizeCategory, .extraExtraLarge)
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13)))
    }
    
    @Test("Error with extra extra extra large text size")
    func extraExtraExtraLargeTextSize() {
        let view = TopErrorTestView(errorMessage: .constant("Error message"))
            .environment(\.sizeCategory, .extraExtraExtraLarge)
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13)))
    }
    
    @Test("Error with accessibility extra large text size")
    func accessibilityExtraLargeTextSize() {
        let view = TopErrorTestView(errorMessage: .constant("Error"))
            .environment(\.sizeCategory, .accessibilityExtraLarge)
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13)))
    }
    
    @Test("Long message with accessibility extra extra large text")
    func longMessageAccessibilityExtraExtraLargeTextSize() {
        let view = TopErrorTestView(errorMessage: .constant("An unexpected error occurred while processing your request."))
            .environment(\.sizeCategory, .accessibilityExtraExtraLarge)
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13)))
    }
}
