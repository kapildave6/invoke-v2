import XCTest
@testable import InvokeShell

// Pure-helper unit tests for BrowserDriver. XCTest (matching InvokeIPCTests) — these run under
// `swift test` on a full Xcode/CI toolchain. The AppleScript exec (getTabs/getContent) needs a live
// browser + Automation permission and is verified live, not here.
final class BrowserDriverTests: XCTestCase {
    func testSupportedBrowserPrefersFrontmost() {
        let b = BrowserDriver.supportedBrowser(frontmost: "com.brave.Browser", running: ["com.apple.Safari", "com.brave.Browser"])
        XCTAssertEqual(b?.name, "Brave Browser")
        XCTAssertEqual(b?.family, "chromium")
    }
    func testSupportedBrowserFallsBackByPreference() {
        let b = BrowserDriver.supportedBrowser(frontmost: "com.apple.Finder", running: ["com.apple.Safari", "com.google.Chrome"])
        XCTAssertEqual(b?.name, "Google Chrome") // Chrome outranks Safari in preference order
    }
    func testNoSupportedBrowser() {
        XCTAssertNil(BrowserDriver.supportedBrowser(frontmost: "com.apple.Finder", running: ["com.apple.Finder"]))
    }
    func testParseTabId() {
        XCTAssertEqual(BrowserDriver.parseTabId("2:5")?.window, 2)
        XCTAssertEqual(BrowserDriver.parseTabId("2:5")?.tab, 5)
        XCTAssertNil(BrowserDriver.parseTabId("garbage"))
    }
    func testContentScriptTargetsTabAndUsesExecuteJavascript() {
        let s = BrowserDriver.contentScript(appName: "Google Chrome", family: "chromium", window: 1, tab: 3, format: "text", cssSelector: nil)
        XCTAssertTrue(s.contains("tab 3 of window 1"))
        XCTAssertTrue(s.contains("execute javascript"))
    }
    func testContentScriptSafariUsesDoJavaScript() {
        let s = BrowserDriver.contentScript(appName: "Safari", family: "safari", window: 1, tab: 1, format: "html", cssSelector: nil)
        XCTAssertTrue(s.contains("do JavaScript"))
    }
    func testContentScriptDefaultChromiumUsesActiveTab() {
        let s = BrowserDriver.contentScript(appName: "Google Chrome", family: "chromium", window: nil, tab: nil, format: "text", cssSelector: nil)
        XCTAssertTrue(s.contains("active tab of window 1"), "Expected 'active tab of window 1', got: \(s)")
        XCTAssertFalse(s.contains("tab 1 of window 1"), "Should not fall back to explicit tab 1")
    }
    func testContentScriptDefaultSafariUsesCurrentTab() {
        let s = BrowserDriver.contentScript(appName: "Safari", family: "safari", window: nil, tab: nil, format: "text", cssSelector: nil)
        XCTAssertTrue(s.contains("current tab of window 1"), "Expected 'current tab of window 1', got: \(s)")
        XCTAssertFalse(s.contains("tab 1 of window 1"), "Should not fall back to explicit tab 1")
    }
}
