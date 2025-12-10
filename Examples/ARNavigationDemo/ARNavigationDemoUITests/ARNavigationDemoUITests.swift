//
//  ARNavigationDemoUITests.swift
//  ARNavigationDemoUITests
//
//  Created by Afonso Rosa on 10/12/2025.
//

import XCTest

final class ARNavigationDemoUITests: UITestCase {

  private enum Constants {
    static let timeout: TimeInterval = 2
  }

  func testHomeScreenDisplayed() {

    let homeScreen = HomeScreen(app: app)

    assert(homeScreen.detailButton.exists, "Detail button should exist on Home Screen")
    assert(homeScreen.settingsButton.exists, "Settings button should exist on Home Screen")
    assert(homeScreen.titleText.exists, "Title text should exist on Home Screen")
  }

  func testDetail() {

    let homeScreen = HomeScreen(app: app)

    let detailScreen = homeScreen.tapDetailButton()

    assert(detailScreen.idText.exists, "ID text should exist on Detail Screen")
    assert(detailScreen.titleText.exists, "Title text should exist on Detail Screen")

    let returnedHomeScreen = detailScreen.tapGoBackButton()
    assert(returnedHomeScreen.titleText.exists, "Title text should exist on Home Screen")
  }

  func testSettings() {

    let homeScreen = HomeScreen(app: app)

    let settingsScreen = homeScreen.tapSettingsButton()

    assert(settingsScreen.titleText.exists, "Title text should exist on Settings Screen")

    let returnedHomeScreen = settingsScreen.tapRootButton()
    assert(returnedHomeScreen.titleText.exists, "Title text should exist on Home Screen")
  }
}
