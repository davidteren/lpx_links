# Option D: Native Swift App (Long-term)

## Why

A native SwiftUI app would provide the best user experience — proper macOS UI, no Terminal, Mac App Store distribution, code signing. But it's a significant rewrite.

## Proof of concept

`LPXLinks.swift` demonstrates the core logic in Swift: finding the app, reading the plist, extracting download URLs. It's a CLI tool that proves the Ruby logic can be ported.

## Build and run

```bash
cd wip/option-d-swift
swiftc LPXLinks.swift -o lpx-links
./lpx-links
```

## What a full version would need

- SwiftUI interface with app selection, progress bars, disk space indicator
- URLSession-based download manager with concurrent downloads and resume
- Package installation via `AuthorizationExecuteWithPrivileges` or a helper tool
- Code signing and notarization for Gatekeeper
- Apple Developer Program membership ($99/year)

## Effort estimate

A functional v1 with basic UI: 2-4 weeks for someone comfortable with Swift/SwiftUI.
