//
//  HomeScreen.swift
//  ARNavigationDemo
//
//  Created by Afonso Rosa on 10/12/2025.
//

import XCTest

struct HomeScreen: Screen {

  let app: XCUIApplication

  var detailButton: XCUIElement {
    app.buttons[AccessibilityIdentifiers.homeDetailButton]
  }

  var settingsButton: XCUIElement {
    app.buttons[AccessibilityIdentifiers.homeSettingsButton]
  }

  var titleText: XCUIElement {
    app.staticTexts[AccessibilityIdentifiers.homeTitle]
  }

  @discardableResult
  func tapDetailButton() -> DetailScreen {
    detailButton.tap()
    return DetailScreen(app: app)
  }

  @discardableResult
  func tapSettingsButton() -> SettingsScreen {
    settingsButton.tap()
    return SettingsScreen(app: app)
  }
}


