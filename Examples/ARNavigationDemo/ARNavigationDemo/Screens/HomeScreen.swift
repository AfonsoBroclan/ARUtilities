//
//  HomeScreen.swift
//  ARNavigationDemo
//
//  Created by Afonso Rosa on 10/12/2025.
//

import ARNavigation
import SwiftUI

/// The home screen of the demo app.
struct HomeScreen: View {
  /// The router environment to handle navigation.
  @Environment(DemoRouter.self) private var router

  var body: some View {
    VStack(spacing: 20) {
      // Title of the home screen.
      Text("Home Screen")
        .font(.largeTitle)
        .accessibilityIdentifier(AccessibilityIdentifiers.homeTitle)

      // Button to navigate to the detail screen.
      Button("Go to Detail") {
        router.navigate(to: (.detail(id: "123")))
      }
      .accessibilityIdentifier(AccessibilityIdentifiers.homeDetailButton)

      // Button to navigate to the settings screen.
      Button("Go to Settings") {
        router.navigate(to: .settings)
      }
      .accessibilityIdentifier(AccessibilityIdentifiers.homeSettingsButton)
    }
    .navigationTitle("Home")
  }
}
