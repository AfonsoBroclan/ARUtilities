//
//  UITestCase.swift
//  ARNavigationDemo
//
//  Created by Afonso Rosa on 10/12/2025.
//

import XCTest

class UITestCase: XCTestCase {

  var app: XCUIApplication!

  override func setUp() {

    continueAfterFailure = false
    app = XCUIApplication()
    app.launch()
  }

  override func tearDown() {
    app.terminate()
  }
}
