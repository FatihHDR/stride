import Foundation
import CoreLocation
import MapKit
import Combine

class LocationSearchService: NSObject, ObservableObject {
    @Published var searchResults: [WalkLocation] = []
    @Published var isSearching = false
    @Published var errorMessage: String?
    
    private let geocoder = CLGeocoder()
    private let localSearch = MKLocalSearch.self
    
    func searchLocations(query: String, region: MKCoordinateRegion? = nil) {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        errorMessage = nil
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
        if let region = region {
            request.region = region
        }
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            DispatchQueue.main.async {
                self?.isSearching = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                guard let response = response else {
                    self?.errorMessage = "No results found"
                    return
                }
                
                self?.searchResults = response.mapItems.map { mapItem in
                    WalkLocation(
                        name: mapItem.name ?? "Unknown Location",
                        coordinate: mapItem.placemark.coordinate,
                        address: self?.formatAddress(from: mapItem.placemark),
                        type: .search
                    )
                }
            }
        }
    }
    
    func reverseGeocode(coordinate: CLLocationCoordinate2D) async throws -> WalkLocation {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        let placemarks = try await geocoder.reverseGeocodeLocation(location)
        
        guard let placemark = placemarks.first else {
            throw LocationSearchError.noResultsFound
        }
        
        return WalkLocation(
            name: placemark.name ?? "Unknown Location",
            coordinate: coordinate,
            address: formatAddress(from: placemark),
            type: .search
        )
    }
    
    private func formatAddress(from placemark: CLPlacemark) -> String {
        var components: [String] = []
        
        if let thoroughfare = placemark.thoroughfare {
            components.append(thoroughfare)
        }
        
        if let locality = placemark.locality {
            components.append(locality)
        }
        
        if let administrativeArea = placemark.administrativeArea {
            components.append(administrativeArea)
        }
        
        return components.joined(separator: ", ")
    }
}

enum LocationSearchError: Error, LocalizedError {
    case noResultsFound
    case invalidQuery
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .noResultsFound:
            return "No locations found for your search"
        case .invalidQuery:
            return "Please enter a valid location name or address"
        case .networkError:
            return "Network error occurred. Please try again."
        }
    }
}
