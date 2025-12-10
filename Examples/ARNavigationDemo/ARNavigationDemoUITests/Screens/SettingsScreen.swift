//
//  SettingsScreen.swift
//  ARNavigationDemo
//
//  Created by Afonso Rosa on 10/12/2025.
//

import XCTest

struct SettingsScreen: Screen {
  let app: XCUIApplication

  var rootButton: XCUIElement {
    app.buttons[AccessibilityIdentifiers.settingsRootButton]
  }

  var titleText: XCUIElement {
    app.staticTexts[AccessibilityIdentifiers.settingsTitle]
  }

  @discardableResult
  func tapRootButton() -> HomeScreen {

    assert(rootButton.exists, "Root button should exist on Settings Screen")

    rootButton.tap()
    return HomeScreen(app: app)
  }
}
