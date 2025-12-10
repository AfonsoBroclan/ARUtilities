//
//  ARNavigationDemoApp.swift
//  ARNavigationDemo
//
//  Created by Afonso Rosa on 10/12/2025.
//

import ARNavigation
import SwiftUI

@main
struct ARNavigationDemoApp: App {
    var body: some Scene {
        WindowGroup {
          RouterScreen(
            factory: DemoScreenFactory(),
            rootRoute: .home
          )
        }
    }
}
