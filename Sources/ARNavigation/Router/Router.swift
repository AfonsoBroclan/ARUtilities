//
//  Router.swift
//  ARUtilities
//
//  Created by Afonso Rosa on 09/12/2025.
//

import SwiftUI

/// Entity responsible for handling navigation.
/// Route represents the different screens/routes ,normally an enum conforming to Hashable.
@Observable
public final class Router<Route: Hashable> {

  /// Represents the different routes/screens
  public var path = NavigationPath()

  /// The stack of routes/screens in the navigation, mirrors the `path` for easier access.
  public private(set) var routeStack: [Route] = [] {

    didSet { updateCurrentRoute() }
  }

  /// The current active route/screen.
  public private(set) var currentRoute: Route?

  /// Initialises a new Router instance.
  public init() {}
}

// MARK: - Navigation Methods
public extension Router {

  /// Goes back to the previous screen in the navigation stack.
  func goBack() {
    guard path.isEmpty == false else { return }
    path.removeLast()
    routeStack.removeLast()
  }

  /// Navigates to a specific route/screen.
  func navigate(to route: Route) {
    path.append(route)
    routeStack.append(route)
  }
}

// MARK: - Private Methods
private extension Router {
  /// Updates the current route based on the route stack.
  func updateCurrentRoute() {
    currentRoute = routeStack.last
  }
}
