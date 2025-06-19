import HealthKit

class HealthKitService: ObservableObject {
    private let healthStore = HKHealthStore()
    @Published var isAuthorized = false
    @Published var todaysSteps: Int = 0
    @Published var walkingDistance: Double = 0
    
    func requestAuthorization() async {
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]
        
        let typesToWrite: Set<HKSampleType> = [
            HKObjectType.workoutType(),
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
        ]
        
        do {
            try await healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead)
            isAuthorized = true
        } catch {
            print("HealthKit authorization failed: \(error)")
        }
    }
    
    func startWorkout(for route: WalkRoute) {
        let workout = HKWorkout(
            activityType: .walking,
            start: Date(),
            duration: route.estimatedDuration,
            totalDistance: HKQuantity(unit: .meter(), doubleValue: route.totalDistance),
            totalEnergyBurned: nil,
            device: HKDevice.local()
        )
        // Save workout to HealthKit
    }
}