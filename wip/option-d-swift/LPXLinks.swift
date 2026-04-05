#!/usr/bin/env swift
// LPX Links — Swift proof-of-concept
// Demonstrates that the core Ruby logic ports cleanly to Swift.
// Build: swiftc LPXLinks.swift -o lpx-links
// Run:   ./lpx-links

import Foundation

// MARK: - App Detection

struct AppInfo {
    let name: String
    let resourcePath: String
    let plistPattern: String
}

let appSearchPaths: [(String, [String], String)] = [
    ("Logic Pro", [
        "/Applications/Logic Pro Creator Studio.app/Contents/Resources",
        "/Applications/Logic Pro.app/Contents/Resources",
        "/Applications/Logic Pro X.app/Contents/Resources"
    ], "logicpro"),
    ("MainStage", [
        "/Applications/MainStage Creator Studio.app/Contents/Resources",
        "/Applications/MainStage 3.app/Contents/Resources",
        "/Applications/MainStage.app/Contents/Resources"
    ], "mainstage"),
    ("GarageBand", [
        "/Applications/GarageBand.app/Contents/Resources"
    ], "garageband")
]

func findInstalledApps() -> [AppInfo] {
    var found: [AppInfo] = []
    let fm = FileManager.default

    for (name, paths, pattern) in appSearchPaths {
        for path in paths {
            if fm.fileExists(atPath: path) {
                found.append(AppInfo(name: name, resourcePath: path, plistPattern: pattern))
                break
            }
        }
    }
    return found
}

func findPlist(in resourcePath: String, pattern: String) -> String? {
    let fm = FileManager.default
    guard let contents = try? fm.contentsOfDirectory(atPath: resourcePath) else { return nil }
    return contents.first { $0.hasPrefix(pattern) && $0.hasSuffix(".plist") }
}

// MARK: - Plist Parsing

struct Package {
    let downloadName: String
    let isMandatory: Bool
    let downloadSize: Int
    let installedSize: Int
}

func parsePackages(plistPath: String) -> [Package] {
    // Convert plist to JSON using plutil (same approach as the Ruby version)
    let tmpJSON = "/tmp/lpx_swift_content.json"
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/plutil")
    process.arguments = ["-convert", "json", plistPath, "-o", tmpJSON]
    try? process.run()
    process.waitUntilExit()

    guard let data = try? Data(contentsOf: URL(fileURLWithPath: tmpJSON)),
          let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
          let packages = json["Packages"] as? [String: [String: Any]] else {
        return []
    }

    return packages.compactMap { (_, pkg) in
        guard let downloadName = pkg["DownloadName"] as? String else { return nil }
        return Package(
            downloadName: downloadName,
            isMandatory: pkg["IsMandatory"] as? Bool ?? false,
            downloadSize: pkg["DownloadSize"] as? Int ?? 0,
            installedSize: pkg["InstalledSize"] as? Int ?? 0
        )
    }
}

// MARK: - Main

let baseURL = "http://audiocontentdownload.apple.com/lp10_ms3_content_2016/"
let apps = findInstalledApps()

if apps.isEmpty {
    print("No supported apps found. Install Logic Pro, MainStage, or GarageBand first.")
    exit(1)
}

print("LPX Links — Swift Proof of Concept")
print("===================================\n")
print("Found installed apps:\n")

for (i, app) in apps.enumerated() {
    guard let plistName = findPlist(in: app.resourcePath, pattern: app.plistPattern) else {
        print("  \(i + 1). \(app.name) — plist not found")
        continue
    }

    let plistPath = "\(app.resourcePath)/\(plistName)"
    let packages = parsePackages(plistPath: plistPath)
    let mandatory = packages.filter { $0.isMandatory }
    let totalDL = packages.reduce(0) { $0 + $1.downloadSize }
    let mandatoryDL = mandatory.reduce(0) { $0 + $1.downloadSize }

    print("  \(i + 1). \(app.name)")
    print("     Plist: \(plistName)")
    print("     Total packages: \(packages.count) (\(mandatory.count) essential)")
    print("     Essential download: \(String(format: "%.1f", Double(mandatoryDL) / 1e9)) GB")
    print("     Full download: \(String(format: "%.1f", Double(totalDL) / 1e9)) GB")
    print("")
}

print("This proof-of-concept demonstrates the core logic works in Swift.")
print("A full version would add SwiftUI, concurrent downloads, and pkg installation.")
