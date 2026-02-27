# ARUIDemo

A demonstration app for the ARUI library, showcasing the `TopErrorModifier`.

## Overview

This demo app demonstrates how to use the `.topError()` view modifier to display error messages at the top of your SwiftUI views with smooth animations.

## Features Demonstrated

- **Auto-dismiss errors**: Errors that automatically disappear after 3 seconds
- **Manual dismiss errors**: Errors that require user interaction to dismiss
- **Long text handling**: How the modifier handles longer error messages
- **Smooth transitions**: Updating error messages while one is already displayed

## Running the Demo

1. Open `ARUIDemo.xcodeproj` in Xcode
2. Select a simulator or device
3. Press `Cmd+R` to build and run
4. Tap the buttons to see different error scenarios

## Running UI Tests

The project includes comprehensive UI tests that verify:
- Error appearance with animation
- Auto-dismiss behavior
- Manual dismiss functionality
- Smooth transitions when rapidly changing messages
- Proper handling of long text

To run the tests:
1. Open `ARUIDemo.xcodeproj` in Xcode
2. Press `Cmd+U` to run all tests
3. Or select individual tests in the Test Navigator (`Cmd+6`)

## Usage Example
```swift
import SwiftUI
import ARUI

struct MyView: View {
    @State private var errorMessage: String?
    
    var body: some View {
        VStack {
            // Your content here
            
            Button("Trigger Error") {
                errorMessage = "Something went wrong!"
            }
        }
        .topError(message: $errorMessage, duration: 3.0)
    }
}
```

### Parameters

- `message`: A binding to an optional `String`. Set to show an error, set to `nil` to dismiss.
- `duration`: Auto-dismiss duration in seconds. Pass `nil` for manual dismissal only. Defaults to 3 seconds.
- `backgroundColor`: Background color of the error banner. Defaults to `.red`.
- `textColor`: Text color of the error message. Defaults to `.white`.

## Project Structure
```
ARUIDemo/
├── ARUIDemo/
│   ├── ARUIDemoApp.swift       # App entry point
│   ├── ContentView.swift        # Demo UI
│   └── Assets.xcassets/         # App assets
├── ARUIDemoUITests/
│   └── ARUIDemoUITests.swift    # UI test suite
└── README.md                     # This file
```

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Local Development

This demo uses a local package dependency to the ARUI library. The package is referenced from `../../` (the repository root). If you move this demo, you'll need to update the package dependency path.
