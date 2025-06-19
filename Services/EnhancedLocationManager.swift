class EnhancedLocationManager: LocationManager {
    @Published var locationAccuracy: CLLocationAccuracy = 0
    @Published var isLocationStale = false
    private var lastLocationUpdate: Date?
    
    override func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        super.locationManager(manager, didUpdateLocations: locations)
        
        guard let location = locations.last else { return }
        locationAccuracy = location.horizontalAccuracy
        lastLocationUpdate = Date()
        
        Timer.scheduledTimer(withTimeInterval: 30, repeats: false) { _ in
            if let lastUpdate = self.lastLocationUpdate,
               Date().timeIntervalSince(lastUpdate) > 30 {
                self.isLocationStale = true
            }
        }
    }
    
    func requestHighAccuracyLocation() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestLocation()
    }
}