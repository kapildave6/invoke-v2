import Testing
@testable import InvokeShell

@Suite struct BrowserDriverTests {
  @Test func supportedBrowserPrefersFrontmost() {
    let b = BrowserDriver.supportedBrowser(frontmost: "com.brave.Browser", running: ["com.apple.Safari", "com.brave.Browser"])
    #expect(b?.name == "Brave Browser")
    #expect(b?.family == "chromium")
  }
  @Test func supportedBrowserFallsBackByPreference() {
    let b = BrowserDriver.supportedBrowser(frontmost: "com.apple.Finder", running: ["com.apple.Safari", "com.google.Chrome"])
    #expect(b?.name == "Google Chrome") // Chrome outranks Safari
  }
  @Test func noSupportedBrowser() {
    #expect(BrowserDriver.supportedBrowser(frontmost: "com.apple.Finder", running: ["com.apple.Finder"]) == nil)
  }
  @Test func parseTabId() {
    #expect(BrowserDriver.parseTabId("2:5")?.window == 2)
    #expect(BrowserDriver.parseTabId("2:5")?.tab == 5)
    #expect(BrowserDriver.parseTabId("garbage") == nil)
  }
  @Test func contentScriptEscapesAndTargets() {
    let s = BrowserDriver.contentScript(appName: "Google Chrome", family: "chromium", window: 1, tab: 3, format: "text", cssSelector: nil)
    #expect(s.contains("tab 3 of window 1"))
    #expect(s.contains("execute javascript"))
  }
}
