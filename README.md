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
    .package(url: "https://github.com/AfonsoBroclan/ARUtilities", from: "0.2.0")
]
```

#### Requirements
- iOS 17.0+
- Swift 6.0+

#### Modules
* ARUtilities
* ARNavigation
* ARPersistence

## ARNavigation

### Router

A lightweight, type-safe navigation router for SwiftUI applications.

#### Features
- Protocol-based routing with `Router`, `RouterScreen`, and `ScreenFactory`
- Type-safe navigation without string-based identifiers
- Easy to test and mock

#### Usage

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

#### Example

See the full working example in Examples/ARNavigationDemo.

## ARPersistence

Persistence utilities for iOS applications.

### GenericCacheManager

A thread-safe, actor-based cache manager with TTL support.

#### Features
- Generic key-value storage with type safety
- Automatic expiration via TTL (Time-To-Live)
- Actor-based thread safety
- Configurable count limits
- Built on NSCache for automatic memory management

#### Usage

##### Basic Caching

```swift
import ARPersistence

// Create a cache with default 24-hour TTL
let cache = GenericCacheManager<String, User>()

// Insert values
await cache.insert(user, forKey: "user_123")

// Retrieve values
if let cachedUser = await cache.value(forKey: "user_123") {
    print("Found user: \(cachedUser)")
}

// Remove specific value
await cache.removeValue(forKey: "user_123")

// Clear all cached values
await cache.clear()
```

##### Custom TTL and Count Limit

```swift
// Create cache with 1-hour TTL
let cache = GenericCacheManager<String, Data>(ttl: 3600)

// Or change TTL after initialization
await cache.changeTTL(to: 1800) // 30 minutes

// Set maximum count limit
await cache.setCountLimit(100) // Max 100 items

// System evicts items automatically when limit is exceeded
```
