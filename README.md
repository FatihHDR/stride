# Stride

A comprehensive SwiftUI iOS application for generating and sharing walking routes. Create random walks from your current location or plan multi-location walks with friends and the community.

## Features

### Random Walks
- 🚶‍♂️ Generate random walking routes from your current location
- ⏱️ Customizable walk duration (5-120 minutes)
- 🗺️ Interactive map view showing your generated route
- 🔄 Loop routes that return you to your starting point
- 📍 Real-time location tracking

### Multi-Location Walks
- 📍 Plan walks visiting multiple specific locations
- 🗺️ Smart routing between locations with MapKit integration
- 🔄 Choose between direct routes, loops, or exploring routes
- 📊 Route optimization for efficient path planning
- 📱 Location search with address suggestions

### Community Features
- 🌐 Share your walks with the community
- 🔗 Generate shareable walk codes
- 🔍 Discover public walks created by other users
- ⭐ Rate and review community walks
- 📥 Import walks from share codes

## Architecture

This project follows MVVM (Model-View-ViewModel) architecture with a clear separation of concerns:

```
Stride/
├── main.swift                 # App entry point (StrideApp)
├── Package.swift             # Swift Package Manager config
├── README.md                 # Project documentation
├── App/
│   └── Info.plist            # App configuration and permissions
├── Models/                   # Data models
│   ├── WalkRoute.swift
│   ├── WalkParameters.swift
│   └── MultiLocationWalk.swift
├── ViewModels/               # Business logic
│   ├── WalkGeneratorViewModel.swift
│   └── MultiLocationWalkViewModel.swift
├── Views/                    # SwiftUI views
│   ├── ContentView.swift
│   ├── WalkSetupView.swift
│   ├── MapView.swift
│   ├── MultiLocationWalkSetupView.swift
│   ├── MultiLocationMapView.swift
│   ├── PublicWalksView.swift
│   └── Components/
│       ├── ErrorView.swift
│       ├── LoadingView.swift
│       ├── TimePickerView.swift
│       ├── LocationRowView.swift
│       └── ShareSheetView.swift
├── Services/                 # External services
│   ├── LocationManager.swift
│   ├── RouteGenerator.swift
│   ├── NavigationService.swift
│   ├── LocationSearchService.swift
│   ├── WalkSharingService.swift
│   └── MultiLocationRouteGenerator.swift
├── Utils/                    # Utilities and helpers
│   ├── Constants.swift
│   └── Extensions/
│       ├── CLLocationCoordinate2D+Extensions.swift
│       └── Double+Extensions.swift
└── Tests/                    # Unit and UI tests
    ├── UnitTests/
    │   ├── WalkParametersTests.swift
    │   ├── RouteGeneratorTests.swift
    │   └── CLLocationCoordinate2DExtensionsTests.swift
    └── UITests/
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

### Random Walks
1. Open the "Random Walk" tab
2. Grant location permission when prompted
3. Select your desired walk duration using the slider (5-120 minutes)
4. Tap "Generate Walk" to create a random route
5. View your route on the map and start walking!

### Multi-Location Walks
1. Open the "Multi-Location" tab
2. Enter a name for your walk
3. Add locations by searching or using current location
4. Choose route options (direct, loop, or exploring)
5. Generate your multi-location walk
6. View the detailed route map with segments
7. Share your walk with others

### Discovering Public Walks
1. Open the "Discover" tab
2. Browse featured public walks
3. Use the search to find specific walks
4. Import walks using share codes
5. Rate and review walks you've tried

## Development

### Running Tests

```bash
xcodebuild test -scheme Stride -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Building

```bash
xcodebuild -scheme Stride -destination 'platform=iOS Simulator,name=iPhone 15' build
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License

This project is open source and available under the MIT License.
