//
//  Screen.swift
//  ARNavigationDemo
//
//  Created by Afonso Rosa on 10/12/2025.
//

import XCTest

/// A protocol representing a screen in the UI tests.
protocol Screen {

  /// The application instance for UI interactions.
  var app: XCUIApplication { get }
}
