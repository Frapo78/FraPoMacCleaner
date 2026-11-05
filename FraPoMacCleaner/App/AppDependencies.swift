struct AppDependencies {
    let disk: any DiskSpaceProviding
    let scanner: any ScanEngine

    static let live = AppDependencies(
        disk: SystemDiskSpaceProvider(),
        scanner: UnavailableScanEngine()
    )
}
