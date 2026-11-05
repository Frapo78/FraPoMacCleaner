protocol DiskSpaceProviding {
    func snapshot() throws -> DiskSpaceSnapshot
}
