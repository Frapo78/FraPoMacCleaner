import Foundation
import XCTest
@testable import FraPoMacCleaner

final class ScanResultExplorerTests: XCTestCase {
    private func sample(
        _ path: String,
        size: Int64,
        timestamp: TimeInterval?,
        reasons: Set<ScanFindingReason>
    ) -> ScanFinding {
        ScanFinding(
            fileURL: URL(fileURLWithPath: path),
            logicalSizeBytes: size,
            modifiedAt: timestamp.map { Date(timeIntervalSince1970: $0) },
            explanation: "Fixture",
            reasons: reasons
        )
    }

    func testSearchByPathAndNameIsCaseInsensitive() {
        let items = [
            sample("/Users/fixture/Media/VIDEO.MOV", size: 300, timestamp: 10, reasons: [.largeFile]),
            sample("/Users/fixture/Docs/report.PDF", size: 10, timestamp: 20, reasons: [.oldFile])
        ]
        let found = ScanResultExplorer.apply(items, search: "video.mov")
        XCTAssertEqual(found.map(\.fileURL.lastPathComponent), ["VIDEO.MOV"])
        XCTAssertEqual(ScanResultExplorer.apply(items, search: "  docs  ").count, 1)
        XCTAssertEqual(ScanResultExplorer.apply(items, search: "nonexistent").count, 0)
    }

    func testReasonAndCategoryFiltersCompose() {
        let items = [
            sample("/Fixtures/a.MOV", size: 300, timestamp: 10, reasons: [.largeFile]),
            sample("/Fixtures/b.MOV", size: 50, timestamp: 15, reasons: [.oldFile]),
            sample("/Fixtures/c.PDF", size: 20, timestamp: 25, reasons: [.oldFile, .largeFile])
        ]
        XCTAssertEqual(ScanResultExplorer.apply(items, reason: .old).count, 2)
        XCTAssertEqual(ScanResultExplorer.apply(items, reason: .large, category: .video).count, 1)
        XCTAssertEqual(ScanResultExplorer.apply(items, reason: .old, category: .documents).count, 1)
    }

    func testSortOrdersAndMissingDates() {
        let items = [
            sample("/Fixtures/omega.PDF", size: 5, timestamp: nil, reasons: [.oldFile]),
            sample("/Fixtures/zeta.MOV", size: 100, timestamp: 100, reasons: [.largeFile]),
            sample("/Fixtures/alpha.MOV", size: 30, timestamp: 50, reasons: [.largeFile])
        ]
        XCTAssertEqual(
            ScanResultExplorer.apply(items, sort: .largest).map(\.logicalSizeBytes),
            [100, 30, 5]
        )
        XCTAssertEqual(
            ScanResultExplorer.apply(items, sort: .oldest).map(\.fileURL.lastPathComponent),
            ["alpha.MOV", "zeta.MOV", "omega.PDF"]
        )
        XCTAssertEqual(
            ScanResultExplorer.apply(items, sort: .newest).map(\.fileURL.lastPathComponent),
            ["zeta.MOV", "alpha.MOV", "omega.PDF"]
        )
        XCTAssertEqual(
            ScanResultExplorer.apply(items, sort: .filename).map(\.fileURL.lastPathComponent),
            ["alpha.MOV", "omega.PDF", "zeta.MOV"]
        )
    }

    func testExportCannotRevealNamesPathsOrFolderLabels() throws {
        let secret = "private-user-name-very-secret"
        let finding = sample("/Users/\(secret)/sensitive-project/report.PDF",
                             size: 512, timestamp: 10, reasons: [.largeFile])
        let report = ScanReport(
            findings: [finding],
            inspectedFileCount: 2,
            candidateCount: 1,
            skippedItemCount: 1,
            errorCount: 0,
            reachedLimit: false,
            exclusionSummary: [ScanExclusionSummary(reason: .protectedPath, count: 1)],
            issueSummary: [],
            observedLogicalBytes: 640,
            observedUniqueLogicalBytes: 640,
            observedAllocatedBytes: 512,
            hardLinkedEntryCount: 0,
            repeatedHardLinkEntryCount: 0,
            fileCategories: [
                ScanSizeGroup(label: "Documenti", fileCount: 2, logicalSizeBytes: 640),
                ScanSizeGroup(label: secret, fileCount: 1, logicalSizeBytes: 999)
            ],
            firstLevelFolders: [
                ScanSizeGroup(label: secret, fileCount: 2, logicalSizeBytes: 640)
            ]
        )
        let data = try ScanSummaryExporter.encode(report)
        let content = try XCTUnwrap(String(data: data, encoding: .utf8))
        XCTAssertFalse(content.contains(secret))
        XCTAssertFalse(content.contains("sensitive-project"))
        XCTAssertFalse(content.contains("report.PDF"))
        XCTAssertTrue(content.contains("\"schemaVersion\" : 2"))
        XCTAssertTrue(content.contains("\"observedLogicalBytes\" : 640"))
        XCTAssertTrue(content.contains("\"observedAllocatedBytes\" : 512"))
        XCTAssertTrue(content.contains("\"Documenti\""))
        XCTAssertTrue(content.contains("\"Percorso protetto\""))
    }

    func testRiskPolicyNeverAuthorizesCleanupAfterFiltering() {
        let finding = sample("/Fixtures/large.MOV", size: 4096, timestamp: 10,
                             reasons: [.largeFile, .oldFile])
        let result = ScanResultExplorer.apply([finding], reason: .large)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(ConservativeRiskPolicy().assess(result[0]), .protected)
    }
}
