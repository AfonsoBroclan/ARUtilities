//
//  TopErrorModifierTests+Visibility.swift
//  ARUtilities
//
//  Created by Afonso Rosa on 12/02/2026.
//

import Testing
import SwiftUI
import SnapshotTesting

@testable import ARUI

@MainActor
@Suite("TopErrorModifier Visibility Tests")//, .snapshots(record: .all))
struct TopErrorModifierVisibilityTests {
    
    @Test("Error is hidden when message is nil")
    func errorHidden() {
        let view = TopErrorTestView(errorMessage: .constant(nil))
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13)))
    }
    
    @Test("Error is visible when message is set")
    func errorVisible() {
        let view = TopErrorTestView(errorMessage: .constant("Something went wrong!"))
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13)))
    }
}
