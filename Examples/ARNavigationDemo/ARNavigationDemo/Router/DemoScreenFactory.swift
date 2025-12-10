//
//  DemoScreenFactory.swift
//  ARNavigationDemo
//
//  Created by Afonso Rosa on 10/12/2025.
//

import ARNavigation
import SwiftUI

struct DemoScreenFactory: ScreenFactory {
  typealias Route = DemoRoute

  @ViewBuilder
  func makeScreen(for route: DemoRoute) -> some View {

    switch route {
    case .home:
      HomeScreen()
    case .detail(let id):
      DetailScreen(id: id)
    case .settings:
      SettingsScreen()
    }
  }
}
