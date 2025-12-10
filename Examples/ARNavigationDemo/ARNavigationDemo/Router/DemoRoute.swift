//
//  DemoRoute.swift
//  ARNavigationDemo
//
//  Created by Afonso Rosa on 10/12/2025.
//

import ARNavigation

typealias DemoRouter = Router<DemoRoute>

enum DemoRoute: Hashable {
  case home
  case detail(id: String)
  case settings
}
