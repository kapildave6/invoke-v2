// swift-tools-version: 6.0
//
// Invoke macOS shell (PLAN.md §3.1/§3.2/§4.3). Built as a SwiftPM package so it
// compiles with the Command Line Tools; a shippable .app bundle (Info.plist,
// hardened-runtime entitlements, notarization — PLAN.md §3.4/§8.5) is added with
// an Xcode project in Phase 0/3.5.
//
// Language mode .v5 keeps AppKit ergonomics simple for now; the strict-concurrency
// (.v6) migration is a tracked hardening task.
import PackageDescription

let package = Package(
    name: "Invoke",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "invoke", targets: ["InvokeApp"]),
    ],
    targets: [
        // Foundation-only core — mirrors @invoke/schema across the process boundary.
        .target(name: "InvokeIPC"),
        .target(name: "InvokeRenderer", dependencies: ["InvokeIPC"]),
        .target(name: "InvokeServices"),
        .target(name: "InvokePersistence"),
        // Tiny Objective-C shim: catch NSExceptions so a render bug degrades to an error view instead
        // of aborting the app (Swift's try/catch can't catch Obj-C exceptions).
        .target(name: "InvokeObjC"),
        // AppKit UI.
        .target(name: "InvokePalette", dependencies: ["InvokeRenderer", "InvokeIPC", "InvokeObjC"]),
        .target(
            name: "InvokeShell",
            dependencies: ["InvokePalette", "InvokeIPC", "InvokeRenderer", "InvokeServices", "InvokePersistence"],
            // Brand assets (app icon + wordmark) bundled as Bundle.module resources.
            resources: [.process("Resources")],
            // Carbon: RegisterEventHotKey for the global summon hotkey (§3.2).
            // sqlite3: the host-mediated read-only executeSQL capability (§4.4) uses the system SQLite.
            linkerSettings: [.linkedFramework("Carbon"), .linkedLibrary("sqlite3")]
        ),
        .executableTarget(name: "InvokeApp", dependencies: ["InvokeShell"]),
        .testTarget(name: "InvokeIPCTests", dependencies: ["InvokeIPC", "InvokeRenderer"]),
        .testTarget(name: "InvokeShellTests", dependencies: ["InvokeShell"]),
    ],
    swiftLanguageModes: [.v5]
)
