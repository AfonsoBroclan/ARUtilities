//
//  TopErrorModifierTests+Device.swift
//  ARUtilities
//
//  Created by Afonso Rosa on 12/02/2026.
//

import Testing
import SwiftUI
import SnapshotTesting
@testable import ARUI

@MainActor
@Suite("TopErrorModifier Device Tests")//, .snapshots(record: .all))
struct TopErrorModifierDeviceTests {
    
    @Test("Error on iPhone SE (small device)")
    func errorOnIPhoneSE() {
        let view = TopErrorTestView(errorMessage: .constant("Error on small device"))
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhoneSe)))
    }
    
    @Test("Error on iPhone 13")
    func errorOnIPhone13() {
        let view = TopErrorTestView(errorMessage: .constant("Error on iPhone 13"))
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13)))
    }
    
    @Test("Error on iPhone 15 Pro")
    func errorOnIPhone15Pro() {
        let view = TopErrorTestView(errorMessage: .constant("Error on iPhone 13 Pro"))
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13Pro)))
    }
    
    @Test("Error on iPad Pro 12.9\"")
    func errorOnIPad() {
        let view = TopErrorTestView(errorMessage: .constant("Error on iPad"))
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPadPro12_9)))
    }
    
    @Test("Long message on iPhone SE")
    func longMessageOnIPhoneSE() {
        let view = TopErrorTestView(errorMessage: .constant("An unexpected error occurred while processing your request. Please try again later."))
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhoneSe)))
    }
    
    @Test("Long message on iPad")
    func longMessageOnIPad() {
        let view = TopErrorTestView(errorMessage: .constant("An unexpected error occurred while processing your request. Please try again later."))
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPadPro12_9)))
    }
}
