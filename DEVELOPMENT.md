# Development Setup Guide

## Prerequisites

- Xcode 15.0 or later
- iOS 15.0+ (for target deployment)
- Swift 5.9+
- macOS (for iOS development)

## Getting Started

1. **Clone or download the project**
   ```
   cd c:\Users\narut\stride
   ```

2. **Open in Xcode**
   ```
   open Package.swift
   ```
   Or open the folder in Xcode as a Swift Package

3. **Build the project**
   ```
   swift build
   ```

4. **Run tests**
   ```
   swift test
   ```

## Project Structure Explained

### Core Components

- **main.swift**: App entry point with StrideApp
- **ContentView.swift**: Main tab navigation
- **Models/**: Data structures (WalkRoute, MultiLocationWalk, etc.)
- **ViewModels/**: Business logic (MVVM pattern)
- **Views/**: SwiftUI user interface components
- **Services/**: External integrations (location, routing, sharing)

### Key Features

1. **Random Walks**: Generate random routes from current location
2. **Multi-Location Walks**: Plan walks visiting multiple specific locations
3. **Public Sharing**: Share walks with community and discover others

## Development Workflow

### Adding New Features

1. Create models in `Models/`
2. Add business logic in `ViewModels/`
3. Create UI in `Views/`
4. Add services in `Services/` if needed
5. Write tests in `Tests/`

### Testing

- Unit tests in `Tests/UnitTests/`
- Run with: `swift test`
- Focus on core logic: route generation, location handling, data models

### Debugging

- Use Xcode simulator for UI testing
- Test location features on physical device
- Check Console for location permission issues

## Common Issues

### Location Services
- Ensure Info.plist has location usage descriptions
- Test on device for accurate GPS
- Handle permission denied gracefully

### Route Generation
- MapKit requires internet connection
- Fallback to simple routes if MapKit fails
- Test with various location combinations

### Sharing Features
- Currently uses mock data
- Ready for backend integration
- Share codes are locally generated

## Next Steps for Production

1. **Backend Integration**
   - Replace WalkSharingService mock with real API
   - Add user authentication
   - Implement real walk sharing database

2. **Enhanced Features**
   - Offline map support
   - Voice navigation
   - Fitness tracking integration
   - Social features (friends, groups)

3. **Performance**
   - Route caching
   - Image optimization
   - Background location updates

4. **App Store Preparation**
   - App icons and screenshots
   - Privacy policy
   - App Store description
   - Beta testing with TestFlight
