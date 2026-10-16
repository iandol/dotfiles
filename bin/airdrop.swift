// airdrop.swift — send files via AirDrop, exit on completion or after a timeout
//
// Usage:   airdrop [--timeout=SECONDS] FILE...
// Env:     AIRDROP_TIMEOUT   default timeout in seconds (default: 300)
// Exit:    0   sent successfully
//          1   failure (e.g. AirDrop unavailable, share error)
//          2   timed out waiting for an outcome
//          64  usage error (no files given)
//          130 cancelled by the user
//
// How it works: AirDrop is exposed through AppKit's NSSharingService, so this
// script runs a headless NSApplication with an active run loop. A delegate
// receives the asynchronous outcome and exits the process explicitly —
// otherwise the process would linger after the AirDrop picker closes.
import AppKit
import Foundation

/// Delegate for the AirDrop sharing service.
///
/// NSSharingService reports the result of a share asynchronously through its
/// delegate. Because this is a CLI tool rather than a GUI app, the delegate
/// calls `exit()` directly once the outcome is known, which is also what
/// terminates the main run loop at the bottom of this file.
final class AirdropDelegate: NSObject, NSSharingServiceDelegate {
    /// Called when all items were accepted and sent successfully.
    func sharingService(_ service: NSSharingService, didShareItems items: [Any]) {
        FileHandle.standardError.write("airdrop: sent\n".data(using: .utf8)!)
        exit(0)
    }

    /// Called when the share fails — including when the user simply dismisses
    /// the AirDrop picker, which Cocoa reports as NSUserCancelledError.
    func sharingService(_ service: NSSharingService,
                        didFailToShareItems items: [Any],
                        error: Error) {
        let ns = error as NSError
        if ns.domain == NSCocoaErrorDomain, ns.code == NSUserCancelledError {
            FileHandle.standardError.write("airdrop: cancelled\n".data(using: .utf8)!)
            exit(130)  // 128 + SIGINT(2): conventional "terminated by Ctrl-C" code
        }
        FileHandle.standardError.write("airdrop: failed: \(error.localizedDescription)\n".data(using: .utf8)!)
        exit(1)
    }
}

// ---- args: [--timeout=SECONDS] FILE... ----
// Hand-rolled parsing: there is exactly one flag, so a full argument parser
// would be overkill. AIRDROP_TIMEOUT supplies the default; an explicit
// --timeout= flag — recognised only as the first argument — takes precedence.
var argv = Array(CommandLine.arguments.dropFirst())
var timeout = Double(ProcessInfo.processInfo.environment["AIRDROP_TIMEOUT"] ?? "") ?? 300
if let first = argv.first, first.hasPrefix("--timeout=") {
    timeout = Double(first.dropFirst("--timeout=".count)) ?? timeout
    argv.removeFirst()
}
guard !argv.isEmpty else {
    FileHandle.standardError.write("usage: airdrop [--timeout=SECONDS] FILE...\n".data(using: .utf8)!)
    exit(64)  // EX_USAGE from sysexits.h
}
// Remaining arguments are file paths. They are not checked for existence here —
// NSSharingService surfaces an error for unreadable items via the delegate.
let urls = argv.map { URL(fileURLWithPath: $0) }

// Look up the system-wide "Send via AirDrop" sharing service. This is nil on
// machines where AirDrop is disabled or unsupported.
guard let service = NSSharingService(named: .sendViaAirDrop) else {
    FileHandle.standardError.write("airdrop: AirDrop service unavailable\n".data(using: .utf8)!)
    exit(1)
}

// The service holds its delegate *weakly* — keep it alive at global scope.
let delegate = AirdropDelegate()
service.delegate = delegate

// A minimal NSApplication instance is required for AppKit's sharing UI.
// `.accessory` keeps the app out of the Dock and app switcher — it runs headless.
let app = NSApplication.shared
app.setActivationPolicy(.accessory)

// Belt and braces: dismissing the picker can produce no callback at all,
// so the process must never outlive `timeout`.
DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
    FileHandle.standardError.write("airdrop: timed out after \(Int(timeout))s\n".data(using: .utf8)!)
    exit(2)
}

// Hand the items to the sharing service. This presents the AirDrop picker;
// the actual outcome arrives later via the delegate callbacks above.
service.perform(withItems: urls)
app.activate(ignoringOtherApps: true)
// Block on the main run loop so the asynchronous delegate callbacks (and the
// timeout timer) can fire. Every exit path above terminates the process,
// which is what ends this loop.
RunLoop.main.run()
