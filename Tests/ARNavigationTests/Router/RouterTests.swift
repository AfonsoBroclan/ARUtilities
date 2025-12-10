//
//  RouterTests.swift
//  ARUtilities
//
//  Created by Afonso Rosa on 09/12/2025.
//

import Testing
@testable import ARNavigation

// MARK: - Test Route

enum TestRoute: Hashable {
  case home
  case profile(id: String)
  case settings
}

// MARK: - Router Tests

@MainActor
@Suite("Router Tests")
struct RouterTests {

  // MARK: - Initialization

  @Test("Initial state has empty path and route stack")
  func initialState() {
    let router = Router<TestRoute>(rootRoute: .home)

    #expect(router.path.isEmpty)
    #expect(router.routeStack.isEmpty)
    #expect(router.currentRoute == .home)
    #expect(router.rootRoute == .home)
  }

  // MARK: - Navigation

  @Test("Navigate appends routes to path and route stack correctly")
  func navigate() {
    let router = Router<TestRoute>(rootRoute: .home)

    router.navigate(to: .settings)
    #expect(router.path.count == 1)
    #expect(router.routeStack == [.settings])
    #expect(router.currentRoute == .settings)

    router.navigate(to: .profile(id: "123"))
    #expect(router.path.count == 2)
    #expect(router.routeStack == [.settings, .profile(id: "123")])
    #expect(router.currentRoute == .profile(id: "123"))
  }

  // MARK: - Go Back

  @Test("Go back removes routes from stack correctly")
  func goBack() {
    let router = Router<TestRoute>(rootRoute: .home)

    // Go back on empty stack does nothing
    router.goBack()
    #expect(router.path.isEmpty)
    #expect(router.routeStack.isEmpty)
    #expect(router.currentRoute == .home)

    // Navigate then go back
    router.navigate(to: .profile(id: "123"))
    router.navigate(to: .settings)

    router.goBack()
    #expect(router.path.count == 1)
    #expect(router.routeStack == [.profile(id: "123")])
    #expect(router.currentRoute == .profile(id: "123"))

    // Go back to empty stack sets current route to nil
    router.goBack()
    #expect(router.path.isEmpty)
    #expect(router.routeStack.isEmpty)
    #expect(router.currentRoute == .home)
  }

  // MARK: - Reset Navigation Stack
  @Test("Reset navigation stack clears all routes")
  func resetClearsAllRoutes() {
    let router = Router<TestRoute>(rootRoute: .home)
    router.navigate(to: .profile(id: "123"))
    router.navigate(to: .settings)

    router.resetNavigationStack()

    #expect(router.routeStack.isEmpty)
    #expect(router.path.count == 0)
    #expect(router.currentRoute == .home)
  }

  // MARK: - Synchronization
  @Test("Sync removes routes when path count decreases by one")
  func syncRemovesSingleRoute() {
    let router = Router<TestRoute>(rootRoute: .home)
    router.navigate(to: .profile(id: "123"))
    router.navigate(to: .settings)

    // Simulate swipe-back by removing from path directly
    router.path.removeLast()
    router.syncRouteStack()

    #expect(router.routeStack.count == 1)
    #expect(router.currentRoute == .profile(id: "123"))
  }

  @Test("Sync removes multiple routes when path count decreases by many")
  func syncRemovesMultipleRoutes() {
    let router = Router<TestRoute>(rootRoute: .home)
    router.navigate(to: .profile(id: "1"))
    router.navigate(to: .profile(id: "2"))
    router.navigate(to: .settings)

    // Simulate long-press back to root (remove all from path)
    router.path = .init()
    router.syncRouteStack()

    #expect(router.routeStack.isEmpty)
    #expect(router.currentRoute == .home)
  }

  @Test("Sync does nothing when path and stack are in sync")
  func syncDoesNothingWhenInSync() {
    let router = Router<TestRoute>(rootRoute: .home)
    router.navigate(to: .profile(id: "123"))

    router.syncRouteStack()

    #expect(router.routeStack.count == 1)
    #expect(router.currentRoute == .profile(id: "123"))
  }
}
