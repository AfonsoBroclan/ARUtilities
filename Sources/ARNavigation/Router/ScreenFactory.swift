//
//  ScreenFactory.swift
//  ARUtilities
//
//  Created by Afonso Rosa on 09/12/2025.
//

import SwiftUI

/// A factory protocol responsible for creating screens based on routes.
@MainActor
public protocol ScreenFactory {
  /// The type representing different routes. Should be the same as that used in the Router.
  associatedtype Route: Hashable
  /// The type of view/screen that this factory creates. Example: some View.
  associatedtype Screen: View

  /// Creates a screen for the given route.
  @ViewBuilder
  func makeScreen(for route: Route?) -> Screen
}
