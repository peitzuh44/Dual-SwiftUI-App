# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a SwiftUI-based iOS/macOS application called "Dual" built with Xcode 16.2. The project uses Swift 5.0 and supports multiple Apple platforms including iOS (17.0+), macOS (14.6+), and visionOS (2.2+).

## Build Commands

- **Build the project**: Use Xcode's build system (`⌘+B` in Xcode) or `xcodebuild -project Dual.xcodeproj -scheme Dual build`
- **Run unit tests**: `xcodebuild test -project Dual.xcodeproj -scheme Dual -destination 'platform=iOS Simulator,name=iPhone 15'`
- **Run UI tests**: Include the DualUITests target when running tests

## Architecture

- **App Entry Point**: `DualApp.swift` - Main app structure using `@main` and `App` protocol
- **Main View**: `ContentView.swift` - Primary SwiftUI view with basic "Hello, world!" content
- **Testing Structure**:
  - Unit tests in `DualTests/` using Swift Testing framework
  - UI tests in `DualUITests/` using XCTest framework
- **Architectural Pattern**: Adopt MVVM (Model-View-ViewModel) architecture for better separation of concerns and testability

## Platform Support

The app is configured as a universal app supporting:
- iPhone (portrait and landscape)
- iPad (all orientations)
- Mac (via Mac Catalyst)
- Apple Vision Pro

## Bundle Configuration

- Bundle identifier: `com.realLifeRPG.app.Dual`
- Sandboxed app with file access permissions
- Uses automatic code signing with development team N5MYS96KJV

## Coding Guidelines

- Always use descriptive variable names