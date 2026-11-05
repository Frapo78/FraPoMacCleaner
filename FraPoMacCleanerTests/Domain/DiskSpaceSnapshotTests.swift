import XCTest
@testable import FraPoMacCleaner

final class DiskSpaceSnapshotTests: XCTestCase {
    func testUsedCapacity() {
        let snapshot = DiskSpaceSnapshot(totalBytes: 100, availableBytes: 25)
        XCTAssertEqual(snapshot.usedBytes, 75)
        XCTAssertEqual(snapshot.usedFraction, 0.75, accuracy: 0.000001)
    }

    func testEmptyCapacity() {
        let snapshot = DiskSpaceSnapshot(totalBytes: 0, availableBytes: 0)
        XCTAssertEqual(snapshot.usedFraction, 0)
    }

    func testExcessAvailableCapacityIsClamped() {
        let snapshot = DiskSpaceSnapshot(totalBytes: 100, availableBytes: 150)
        XCTAssertEqual(snapshot.usedFraction, 0)
    }
}
