//
//  RouterScreen.swift
//  ARUtilities
//
//  Created by Afonso Rosa on 09/12/2025.
//

import SwiftUI

/// A view that manages navigation using a Router and a ScreenFactory.
public struct RouterScreen<Factory: ScreenFactory>: View {

  /// Router instance to manage navigation.
  @State
  private var router: Router<Factory.Route>

  /// Factory instance to create screens based on routes.
  private let factory: Factory

  /// The initial/root route.
  private let rootRoute: Factory.Route

  public init(
    factory: Factory,
    rootRoute: Factory.Route
  ) {
    let router = Router<Factory.Route>(rootRoute: rootRoute)
    self._router = State(initialValue: router)
    self.factory = factory
    self.rootRoute = rootRoute
  }

  public var body: some View {
    // Navigation view for managing the stack of screens.
    NavigationStack(path: $router.path) {

      // Root screen
      factory.makeScreen(for: rootRoute)
        .navigationDestination(for: Factory.Route.self) { route in
          // Destination screens based on the route
          factory.makeScreen(for: route)
      }
    }
    .environment(router)
    .onChange(of: router.path.count) { _, _ in
      router.syncRouteStack()
    }
  }
}
