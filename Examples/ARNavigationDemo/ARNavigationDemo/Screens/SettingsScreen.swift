//
//  SettingsScreen.swift
//  ARNavigationDemo
//
//  Created by Afonso Rosa on 10/12/2025.
//

import ARNavigation
import SwiftUI

/// Settings screen for the application.
struct SettingsScreen: View {
  /// Router environment to manage navigation actions.
  @Environment(DemoRouter.self) private var router

  var body: some View {
    VStack(spacing: 20) {
      // Title of the settings screen.
      Text("Settings Screen")
        .font(.largeTitle)
        .accessibilityIdentifier(AccessibilityIdentifiers.settingsTitle)

      // Button to the root screen.
      Button("Go to Root") {
        router.resetNavigationStack()
      }
      .accessibilityIdentifier(AccessibilityIdentifiers.settingsRootButton)
    }
    .navigationTitle("Settings")
  }
}
