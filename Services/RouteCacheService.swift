class RouteCacheService {
    private let cacheKey = "cached_routes"
    
    func cacheRoute(_ route: WalkRoute, for parameters: WalkParameters) {
        let cacheItem = CachedRoute(route: route, parameters: parameters, cachedAt: Date())
        //
    }
    
    func getCachedRoute(for parameters: WalkParameters) -> WalkRoute? {
        //
        return nil
    }
}