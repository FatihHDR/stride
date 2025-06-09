# Random Walk Generator

A SwiftUI iOS application that generates random walking routes based on your current location and desired walk duration.

## Features

- 🚶‍♂️ Generate random walking routes from your current location
- ⏱️ Customizable walk duration (5-60 minutes)
- 🗺️ Interactive map view showing your generated route
- 🔄 Loop routes that return you to your starting point
- 📍 Real-time location tracking

## Architecture

This project follows MVVM (Model-View-ViewModel) architecture with a clear separation of concerns:

```
RandomWalkApp/
├── main.swift                 # App entry point
├── App/
│   └── Info.plist            # App configuration and permissions
├── Models/                   # Data models
│   ├── WalkRoute.swift
│   └── WalkParameters.swift
├── ViewModels/               # Business logic
│   └── WalkGeneratorViewModel.swift
├── Views/                    # SwiftUI views
│   ├── ContentView.swift
│   ├── WalkSetupView.swift
│   ├── MapView.swift
│   └── Components/
├── Services/                 # External services
│   ├── LocationManager.swift
│   └── RouteGenerator.swift
├── Utils/                    # Utilities and helpers
│   ├── Constants.swift
│   └── Extensions/
└── Tests/                    # Unit and UI tests
```

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+
- Location Services enabled

## Permissions

The app requires the following permissions:
- Location When In Use: To generate routes from your current location

## Usage

1. Launch the app
2. Grant location permission when prompted
3. Select your desired walk duration using the slider (5-60 minutes)
4. Tap "Generate Walk" to create a random route
5. View your route on the map and start walking!

## Development

### Running Tests

```bash
xcodebuild test -scheme RandomWalkApp -destination 'platform=iOS Simulator,name=iPhone 14'
```

### Building

```bash
xcodebuild -scheme RandomWalkApp -destination 'platform=iOS Simulator,name=iPhone 14' build
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License

This project is open source and available under the MIT License.
