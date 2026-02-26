//
//  ARUIDemoUITests.swift
//  ARUIDemoUITests
//
//  Created by Afonso Rosa on 20/02/2026.
//

import XCTest

final class ARUIDemoUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    // MARK: - Test 1: Error appears with animation
    
    func testErrorAppearsWithAnimation() throws {
        let showErrorButton = app.buttons["showErrorButton"]
        let errorText = app.staticTexts["Error: Something went wrong!"]
        
        // Initially, error should not exist
        XCTAssertFalse(errorText.exists)
        
        // Tap show error button
        showErrorButton.tap()
        
        // Error should appear
        XCTAssertTrue(errorText.waitForExistence(timeout: 1.0))
        XCTAssertTrue(errorText.exists)
    }
    
    // MARK: - Test 2: Error dismisses automatically
    
    func testErrorDismissesAutomatically() throws {
        let showErrorButton = app.buttons["showErrorButton"]
        let errorText = app.staticTexts["Error: Something went wrong!"]
        
        // Show error
        showErrorButton.tap()
        XCTAssertTrue(errorText.waitForExistence(timeout: 1.0))
        
        // Wait for auto-dismiss (3 seconds + buffer)
        let disappeared = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: disappeared, object: errorText)
        let result = XCTWaiter.wait(for: [expectation], timeout: 4.0)
        
        XCTAssertEqual(result, .completed, "Error should auto-dismiss after 3 seconds")
        XCTAssertFalse(errorText.exists)
    }
    
    // MARK: - Test 3: Error updates smoothly when message changes
    
    func testErrorUpdatesSmoothlywhenMessageChanges() throws {
        let showErrorButton = app.buttons["showErrorButton"]
        let showLongErrorButton = app.buttons["showLongErrorButton"]
        
        let shortError = app.staticTexts["Error: Something went wrong!"]
        let longError = app.staticTexts["Error: An unexpected error occurred while processing your request. Please try again later or contact support."]
        
        // Show first error
        showErrorButton.tap()
        XCTAssertTrue(shortError.waitForExistence(timeout: 1.0))
        
        // Show second error before first dismisses
        sleep(1) // Wait a bit but not for full auto-dismiss
        showLongErrorButton.tap()
        
        // Long error should appear
        XCTAssertTrue(longError.waitForExistence(timeout: 1.0))
        
        // Short error should be gone
        XCTAssertFalse(shortError.exists)
    }
    
    // MARK: - Test 4: Rapid button taps handle transitions smoothly
    
    func testRapidButtonTapsHandleTransitions() throws {
        let showErrorButton = app.buttons["showErrorButton"]
        let showLongErrorButton = app.buttons["showLongErrorButton"]
        
        // Rapidly tap multiple times
        for _ in 0..<5 {
            showErrorButton.tap()
            usleep(100_000) // 0.1 second delay
            showLongErrorButton.tap()
            usleep(100_000)
        }
        
        // App should not crash and some error should be visible
        let anyError = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Error:'")).firstMatch
        XCTAssertTrue(anyError.exists, "An error message should be visible after rapid taps")
    }
    
    // MARK: - Test 5: Manual dismiss works
    
    func testManualDismissWorks() throws {
        let showManualErrorButton = app.buttons["showManualErrorButton"]
        let dismissButton = app.buttons["dismissButton"]
        let errorText = app.staticTexts["Error: This error requires manual dismissal. Tap the dismiss button below."]
        
        // Show manual dismiss error
        showManualErrorButton.tap()
        XCTAssertTrue(errorText.waitForExistence(timeout: 1.0))
        
        // Wait longer than auto-dismiss duration to ensure it doesn't auto-dismiss
        sleep(4)
        XCTAssertTrue(errorText.exists, "Manual dismiss error should still be visible")
        
        // Tap dismiss button
        XCTAssertTrue(dismissButton.isEnabled)
        dismissButton.tap()
        
        // Error should disappear
        let disappeared = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: disappeared, object: errorText)
        let result = XCTWaiter.wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(result, .completed, "Error should dismiss after tapping dismiss button")
        XCTAssertFalse(errorText.exists)
    }
    
    // MARK: - Test 6: Dismiss button is disabled when no error
    
    func testDismissButtonDisabledWhenNoError() throws {
        let dismissButton = app.buttons["dismissButton"]
        
        // Initially, dismiss button should be disabled
        XCTAssertFalse(dismissButton.isEnabled)
    }
    
    // MARK: - Test 7: Long error text displays correctly
    
    func testLongErrorDisplaysCorrectly() throws {
        let showLongErrorButton = app.buttons["showLongErrorButton"]
        let longError = app.staticTexts["Error: An unexpected error occurred while processing your request. Please try again later or contact support."]
        
        showLongErrorButton.tap()
        XCTAssertTrue(longError.waitForExistence(timeout: 1.0))
        XCTAssertTrue(longError.exists)
    }
}
