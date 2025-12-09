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

@Suite("Router Tests")
struct RouterTests {

  // MARK: - Initialization

  @Test("Initial state has empty path and route stack")
  func initialState() {
    let router = Router<TestRoute>()

    #expect(router.path.isEmpty)
    #expect(router.routeStack.isEmpty)
    #expect(router.currentRoute == nil)
  }

  // MARK: - Navigation

  @Test("Navigate appends routes to path and route stack correctly")
  func navigate() {
    let router = Router<TestRoute>()

    router.navigate(to: .home)
    #expect(router.path.count == 1)
    #expect(router.routeStack == [.home])
    #expect(router.currentRoute == .home)

    router.navigate(to: .profile(id: "123"))
    router.navigate(to: .settings)
    #expect(router.path.count == 3)
    #expect(router.routeStack == [.home, .profile(id: "123"), .settings])
    #expect(router.currentRoute == .settings)
  }

  // MARK: - Go Back

  @Test("Go back removes routes from stack correctly")
  func goBack() {
    let router = Router<TestRoute>()

    // Go back on empty stack does nothing
    router.goBack()
    #expect(router.path.isEmpty)
    #expect(router.routeStack.isEmpty)
    #expect(router.currentRoute == nil)

    // Navigate then go back
    router.navigate(to: .home)
    router.navigate(to: .settings)

    router.goBack()
    #expect(router.path.count == 1)
    #expect(router.routeStack == [.home])
    #expect(router.currentRoute == .home)

    // Go back to empty stack sets current route to nil
    router.goBack()
    #expect(router.path.isEmpty)
    #expect(router.routeStack.isEmpty)
    #expect(router.currentRoute == nil)
  }
}
