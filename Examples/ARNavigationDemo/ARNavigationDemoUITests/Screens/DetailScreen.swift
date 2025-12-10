//
//  DetailScreen.swift
//  ARNavigationDemo
//
//  Created by Afonso Rosa on 10/12/2025.
//

import XCTest

struct DetailScreen: Screen {
  let app: XCUIApplication

  var goBackButton: XCUIElement {
    app.buttons[AccessibilityIdentifiers.detailBackButton]
  }

  var idText: XCUIElement {
    app.staticTexts[AccessibilityIdentifiers.detailIDLabel]
  }

  var titleText: XCUIElement {
    app.staticTexts[AccessibilityIdentifiers.detailTitle]
  }

  @discardableResult
  func tapGoBackButton() -> HomeScreen {

    assert(goBackButton.exists, "Go Back button should exist on Detail Screen")

    goBackButton.tap()
    return HomeScreen(app: app)
  }
}
