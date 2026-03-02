    //
    //  SkylightWeatherUITests.swift
    //  SkylightWeatherUITests
    //
    //  Created by Nekto_Ellez on 23.02.2026.
    //

import XCTest

final class SkylightWeatherUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
    }

    @MainActor
    func testSettingsSheetOpenAndClose() throws {
        let app = launchApp()
        XCTAssertTrue(element(app, id: "weather_dashboard").waitForExistence(timeout: 20))

        let settingsButton = element(app, id: "nav_settings_button")
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 10))
        XCTAssertTrue(waitForHittable(settingsButton, timeout: 5))
        settingsButton.tap()

        let doneButton = element(app, id: "settings_done_button")
        XCTAssertTrue(doneButton.waitForExistence(timeout: 10))
        doneButton.tap()

        XCTAssertTrue(waitForNonExistence(doneButton, timeout: 5))
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 3))
    }

    @MainActor
    func testCardsPagerSwipeFromFirstToSecondCard() throws {
        let app = launchApp()
        XCTAssertTrue(element(app, id: "weather_dashboard").waitForExistence(timeout: 20))

        let cardsPager = element(app, id: "weather_cards_pager")
        XCTAssertTrue(cardsPager.waitForExistence(timeout: 20))
        XCTAssertTrue(waitForPageIndicatorValue(cardsPager, expected: "1/3", timeout: 10))
        swipeLeftOnPager(cardsPager)
        XCTAssertTrue(waitForPageIndicatorValue(cardsPager, expected: "2/3", timeout: 10))

        let hourlyCard = element(app, id: "weather_card_hourly")
        XCTAssertTrue(hourlyCard.waitForExistence(timeout: 10))
    }

    @MainActor
    func testFirstCardSupportsVerticalScrollGestures() throws {
        let app = launchApp()
        let verticalScroll = element(app, id: "weather_dashboard")
        XCTAssertTrue(verticalScroll.waitForExistence(timeout: 20))

        verticalScroll.swipeUp()
        XCTAssertTrue(verticalScroll.waitForExistence(timeout: 5))

        verticalScroll.swipeDown()
        XCTAssertTrue(verticalScroll.waitForExistence(timeout: 5))
    }

    @MainActor
    func testHourlyInnerScrollDoesNotSwitchPagerCard() throws {
        let app = launchApp()
        XCTAssertTrue(element(app, id: "weather_dashboard").waitForExistence(timeout: 20))

        let cardsPager = element(app, id: "weather_cards_pager")
        XCTAssertTrue(cardsPager.waitForExistence(timeout: 20))
        XCTAssertTrue(waitForPageIndicatorValue(cardsPager, expected: "1/3", timeout: 10))
        swipeLeftOnPager(cardsPager)
        XCTAssertTrue(waitForPageIndicatorValue(cardsPager, expected: "2/3", timeout: 10))

        let verticalStart = cardsPager.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.75))
        let verticalEnd = cardsPager.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.25))
        verticalStart.press(forDuration: 0.03, thenDragTo: verticalEnd)

        XCTAssertTrue(waitForPageIndicatorValue(cardsPager, expected: "2/3", timeout: 10))
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            _ = launchApp()
        }
    }

    // MARK: - Helpers

    @MainActor
    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US", "UI_TEST_MODE"]
        app.launchEnvironment["UI_TEST_MODE"] = "1"
        app.launch()
        return app
    }

    private func waitForNonExistence(_ element: XCUIElement, timeout: TimeInterval) -> Bool {
        let predicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }

    private func waitForPageIndicatorValue(_ element: XCUIElement, expected: String, timeout: TimeInterval) -> Bool {
        let predicate = NSPredicate(format: "value == %@", expected)
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }

    private func waitForHittable(_ element: XCUIElement, timeout: TimeInterval) -> Bool {
        let predicate = NSPredicate(format: "hittable == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }

    private func swipeLeftOnPager(_ pager: XCUIElement) {
        let start = pager.coordinate(withNormalizedOffset: CGVector(dx: 0.82, dy: 0.5))
        let end = pager.coordinate(withNormalizedOffset: CGVector(dx: 0.18, dy: 0.5))
        start.press(forDuration: 0.03, thenDragTo: end)
    }

    private func element(_ app: XCUIApplication, id: String) -> XCUIElement {
        let typedCandidates: [XCUIElement] = [
            app.buttons[id],
            app.otherElements[id],
            app.scrollViews[id],
            app.collectionViews[id],
            app.staticTexts[id],
            app.images[id],
            app.switches[id]
        ]

        for candidate in typedCandidates where candidate.exists {
            return candidate
        }

        return app.descendants(matching: .any).matching(identifier: id).firstMatch
    }
}
