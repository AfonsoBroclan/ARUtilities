# ARUtilities
Swift utilities for iOS development

## Installation

### Swift Package Manager

Add ARUtilities to your project:

1. In Xcode: **File > Add Package Dependencies**
2. Enter: `https://github.com/AfonsoBroclan/ARUtilities`
3. Select version/branch

Or add to your `Package.swift`:
```swift
dependencies: [
    .package(url: "https://github.com/AfonsoBroclan/ARUtilities", from: "0.0.2")
]
```

Import the module you need
* ARUtilities
* ARNavigation

## ARNavigation

A lightweight, type-safe navigation router for SwiftUI applications.

### Features
- Protocol-based routing with `Router`, `RouterScreen`, and `ScreenFactory`
- Type-safe navigation without string-based identifiers
- Easy to test and mock

### Usage

```swift
// Define your routes
enum AppRoute: RouterScreen {
    case home
    case detail(id: String)
    case settings
}

// Create a screen factory
struct AppScreenFactory: ScreenFactory {
    func makeScreen(for route: AppRoute) -> some View {
        switch route {
        case .home: HomeScreen()
        case .detail(let id): DetailScreen(id: id)
        case .settings: SettingsScreen()
        }
    }
}

// Use the router
@StateObject var router = Router<AppRoute>()
```

### Example

See the full working example in Examples/ARNavigationDemo.
