//
//  Router.swift
//  ARUtilities
//
//  Created by Afonso Rosa on 09/12/2025.
//

import SwiftUI

/// Entity responsible for handling navigation.
/// Route represents the different screens/routes ,normally an enum conforming to Hashable.
@MainActor
@Observable
public final class Router<Route: Hashable> {

  /// The current active route/screen.
  public var currentRoute: Route {
    routeStack.last ?? rootRoute
  }

  private var isNavigating = false

  /// Represents the different routes/screens
  public var path = NavigationPath()

  /// The initial/root route.
  public let rootRoute: Route

  /// The stack of pushed routes/screens (excludes rootRoute) in the navigation, mirrors the `path` for easier access.
  /// Use `currentRoute` to get the active route including root fallback.
  public private(set) var routeStack: [Route] = []

  /// Initialises a new Router instance.
  public init(rootRoute: Route) {
    self.rootRoute = rootRoute
  }

  /// Synchronises routeStack when path changes externally (e.g., swipe-back gesture).
  public func syncRouteStack() {
    guard isNavigating == false else { return }

    let pathCount = path.count
    let stackCount = routeStack.count

    if pathCount < stackCount {
      // User swiped back - remove routes from the end
      let itemsToRemove = stackCount - pathCount
      routeStack.removeLast(itemsToRemove)
    }
  }
}

// MARK: - Navigation Methods
public extension Router {

  /// Goes back to the previous screen in the navigation stack.
  func goBack() {
    guard path.isEmpty == false else { return }

    defer { isNavigating = false }
    isNavigating = true

    path.removeLast()
    routeStack.removeLast()
  }

  /// Navigates to a specific route/screen.
  func navigate(to route: Route) {

    defer { isNavigating = false }
    isNavigating = true

    path.append(route)
    routeStack.append(route)
  }

  /// Resets the navigation stack to its initial state.
  func resetNavigationStack() {

    defer { isNavigating = false }
    isNavigating = true

    path = NavigationPath()
    routeStack = []
  }
}
