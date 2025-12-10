//
//  DetailScreen.swift
//  ARNavigationDemo
//
//  Created by Afonso Rosa on 10/12/2025.
//

import ARNavigation
import SwiftUI

/// The detail screen of the demo app.
struct DetailScreen: View {
  /// The router environment to handle navigation actions.
  @Environment(DemoRouter.self) private var router
  /// The identifier for the detail item.
  let id: String

  var body: some View {
    VStack(spacing: 20) {
      // Title of the detail screen.
      Text("Detail Screen")
        .font(.largeTitle)
        .accessibilityIdentifier(AccessibilityIdentifiers.detailTitle)

      // Display the detail ID.
      Text("ID: \(id)")
        .accessibilityIdentifier(AccessibilityIdentifiers.detailIDLabel)

      // Button to go back to the previous screen.
      Button("Go Back") {
        router.goBack()
      }
      .accessibilityIdentifier(AccessibilityIdentifiers.detailBackButton)
    }
    .navigationTitle("Detail")
  }
}
