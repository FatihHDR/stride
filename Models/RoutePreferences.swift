struct RoutePreferences {
    var avoidHills: Bool = false
    var preferParks: Bool = true
    var avoidBusyRoads: Bool = true
    var includePointsOfInterest: Bool = false
    var difficulty: RouteDifficulty = .moderate
    var terrainType: TerrainType = .mixed
    
    enum RouteDifficulty {
        case easy, moderate, challenging, expert
    }
    
    enum TerrainType {
        case urban, park, waterfront, mixed
    }
}

// ViewModels/RoutePreferencesViewModel.swift
class RoutePreferencesViewModel: ObservableObject {
    @Published var preferences = RoutePreferences()
    
    func savePreferences() {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(preferences), forKey: "route_preferences")
    }
    
    func loadPreferences() {
        if let data = UserDefaults.standard.data(forKey: "route_preferences"),
           let preferences = try? PropertyListDecoder().decode(RoutePreferences.self, from: data) {
            self.preferences = preferences
        }
    }
}