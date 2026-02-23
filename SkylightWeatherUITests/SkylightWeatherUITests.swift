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

        let settingsButton = element(app, id: "nav_settings_button")
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 10))
        settingsButton.tap()

        let settingsForm = element(app, id: "settings_form")
        XCTAssertTrue(settingsForm.waitForExistence(timeout: 5))

        let doneButton = element(app, id: "settings_done_button")
        XCTAssertTrue(doneButton.waitForExistence(timeout: 5))
        doneButton.tap()

        XCTAssertTrue(waitForNonExistence(settingsForm, timeout: 5))
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 3))
    }

    @MainActor
    func testHourlyInnerScrollDoesNotSwitchPagerCard() throws {
        let app = launchApp()

        let pageIndicator = element(app, id: "weather_page_indicator")
        XCTAssertTrue(pageIndicator.waitForExistence(timeout: 20))
        XCTAssertEqual(pageIndicator.value as? String, "1/3")

        let cardsPager = element(app, id: "weather_cards_pager")
        XCTAssertTrue(cardsPager.waitForExistence(timeout: 20))
        cardsPager.swipeLeft()
        XCTAssertTrue(waitForPageIndicatorValue(pageIndicator, expected: "2/3", timeout: 5))

        let hourlyInnerScroll = element(app, id: "hourly_inner_scroll")
        XCTAssertTrue(hourlyInnerScroll.waitForExistence(timeout: 5))
        hourlyInnerScroll.swipeLeft()

        XCTAssertEqual(pageIndicator.value as? String, "2/3")
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
        app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
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

    private func element(_ app: XCUIApplication, id: String) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: id).firstMatch
    }
}
