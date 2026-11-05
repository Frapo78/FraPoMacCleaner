import Foundation
import XCTest
@testable import FraPoMacCleaner

final class ConservativeRiskPolicyTests: XCTestCase {
    func testAllFindingsProtectedUntilReview() {
        let item = ScanFinding(
            fileURL: URL(fileURLWithPath: "/tmp/synthetic-fixture.txt"),
            logicalSizeBytes: 42,
            explanation: "Fixture"
        )
        XCTAssertEqual(ConservativeRiskPolicy().assess(item), .protected)
    }
}
