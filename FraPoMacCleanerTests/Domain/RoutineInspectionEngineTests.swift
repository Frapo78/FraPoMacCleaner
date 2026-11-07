import Foundation
import XCTest
@testable import FraPoMacCleaner

final class RoutineInspectionEngineTests: XCTestCase {
    private var root: URL!
    private var unrelated: URL!

    override func setUpWithError() throws {
        let base = FileManager.default.homeDirectoryForCurrentUser
        root = base.appendingPathComponent("RoutineFixture-\(UUID().uuidString)")
        unrelated = base.appendingPathComponent("OtherRoutine-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: unrelated, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        // Only XCTest-owned UUID fixtures, never an existing user directory.
        if let root { try? FileManager.default.removeItem(at: root) }
        if let unrelated { try? FileManager.default.removeItem(at: unrelated) }
    }

    private func engine(
        area: RoutineArea, date: Date = Date(),
        maximumVisited: Int = 20_000
    ) -> RoutineInspectionEngine {
        RoutineInspectionEngine(
            allowedRoots: [area: root], referenceDate: date,
            maximumVisited: maximumVisited
        )
    }

    @discardableResult
    private func fixture(
        _ name: String, bytes: Int = 32, in directory: URL? = nil,
        daysAgo: Int = 50
    ) throws -> URL {
        let url = (directory ?? root!).appendingPathComponent(name)
        try Data(repeating: 0x61, count: bytes).write(to: url)
        try FileManager.default.setAttributes(
            [.modificationDate: Date(timeIntervalSinceNow: -Double(daysAgo) * 86_400)],
            ofItemAtPath: url.path
        )
        return url
    }

    func testLogsMatchNarrowSuffixesAndAge() throws {
        try fixture("old.log", bytes: 96)
        try fixture("report.ips", bytes: 14)
        try fixture("rotated.log.1.gz", bytes: 24)
        try fixture("fresh.log", daysAgo: 1)
        try fixture("important.sqlite")
        try fixture("fake-log.txt")
        let report = try engine(area: .userLogs).inspect(area: .userLogs, selectedURL: root)
        XCTAssertEqual(Set(report.entries.map(\.label)),
                       Set(["old.log", "report.ips", "rotated.log.1.gz"]))
        XCTAssertEqual(report.observedLogicalBytes, 134)
        XCTAssertTrue(report.entries.allSatisfy { $0.description.contains("protetto") })
    }

    func testRefusesOtherSelectedRootAndSymlinkRoot() throws {
        let inspect = engine(area: .userLogs)
        XCTAssertThrowsError(try inspect.inspect(area: .userLogs, selectedURL: unrelated))
        let link = unrelated.appendingPathComponent("fake")
        try FileManager.default.createSymbolicLink(at: link, withDestinationURL: root)
        XCTAssertThrowsError(try inspect.inspect(area: .userLogs, selectedURL: link))
    }

    func testSkipsSymlinkHardLinkAndSensitiveNames() throws {
        let file = try fixture("good.log")
        try FileManager.default.linkItem(at: file, to: root.appendingPathComponent("linked.log"))
        try FileManager.default.createSymbolicLink(
            at: root.appendingPathComponent("link.log"), withDestinationURL: unrelated
        )
        let protected = root.appendingPathComponent("Keychains", isDirectory: true)
        try FileManager.default.createDirectory(at: protected, withIntermediateDirectories: true)
        try fixture("ignored.log", in: protected)
        let report = try engine(area: .userLogs).inspect(area: .userLogs, selectedURL: root)
        XCTAssertTrue(report.entries.isEmpty)
        XCTAssertGreaterThanOrEqual(report.skippedItemCount, 3)
    }

    func testReportsXcodeBuildGroupsWithoutReadingFiles() throws {
        let project = root.appendingPathComponent("Demo-12345", isDirectory: true)
        let deep = project.appendingPathComponent("Build", isDirectory: true)
        try FileManager.default.createDirectory(at: deep, withIntermediateDirectories: true)
        try fixture("object.o", bytes: 100, in: deep)
        try fixture("cache.dat", bytes: 50, in: project)
        try fixture("standalone.txt", bytes: 40)
        let report = try engine(area: .xcodeDerivedData).inspect(
            area: .xcodeDerivedData, selectedURL: root
        )
        XCTAssertEqual(report.entries.count, 1)
        XCTAssertEqual(report.entries[0].logicalSizeBytes, 150)
        XCTAssertEqual(report.observedLogicalBytes, 150)
        XCTAssertEqual(report.entries[0].label, "Demo-12345")
    }

    func testLaunchAgentsArePresentNotNecessarilyRunning() throws {
        try fixture("com.example.helper.plist")
        try fixture("unrelated.txt")
        let report = try engine(area: .userLaunchAgents).inspect(
            area: .userLaunchAgents, selectedURL: root
        )
        XCTAssertEqual(report.entries.count, 1)
        XCTAssertEqual(report.entries[0].label, "com.example.helper")
        XCTAssertTrue(report.entries[0].description.contains("non verificata"))
    }

    func testCancellationAndEntryLimit() throws {
        for number in 0..<10 { try fixture("file-\(number).log") }
        XCTAssertThrowsError(try engine(area: .userLogs).inspect(
            area: .userLogs, selectedURL: root,
            isCancelled: { true }
        ))
        let limited = try engine(area: .userLogs, maximumVisited: 3).inspect(
            area: .userLogs, selectedURL: root
        )
        XCTAssertTrue(limited.reachedLimit)
        XCTAssertEqual(limited.inspectedItemCount, 3)
    }

    func testAreaPathsAreFixedAndDistinct() {
        XCTAssertEqual(RoutineArea.userLogs.relativePath, "Library/Logs")
        XCTAssertEqual(RoutineArea.xcodeDerivedData.relativePath,
                       "Library/Developer/Xcode/DerivedData")
        XCTAssertEqual(RoutineArea.userLaunchAgents.relativePath,
                       "Library/LaunchAgents")
        XCTAssertEqual(Set(RoutineArea.allCases.map(\.relativePath)).count, 3)
    }

    func testMissingPredefinedFolderIsReportedAsMissing() throws {
        let unavailable = root.appendingPathComponent("missing", isDirectory: true)
        let configured = RoutineInspectionEngine(allowedRoots: [.userLogs: unavailable])
        XCTAssertThrowsError(try configured.inspect(
            area: .userLogs,
            selectedURL: unavailable
        )) { error in
            XCTAssertEqual(error as? RoutineInspectionError, .missingDirectory)
        }
    }

    func testOldDiagnosticsGetReviewHintButNormalLogsStayProtected() throws {
        try fixture("recent-report.ips", daysAgo: 40)
        try fixture("old-report.ips", daysAgo: 120)
        try fixture("old-app.log", daysAgo: 120)
        try fixture("old-rotated.log.1.gz", daysAgo: 120)
        let report = try engine(area: .userLogs).inspect(area: .userLogs, selectedURL: root)
        XCTAssertEqual(report.reviewCount, 2)
        XCTAssertEqual(Set(report.entries.filter {
            $0.reviewLevel == .needsReview
        }.map(\.label)), Set(["old-report.ips", "old-rotated.log.1.gz"]))
        XCTAssertTrue(report.entries.allSatisfy { !$0.canRemove })
        XCTAssertGreaterThanOrEqual(report.observedAllocatedBytes, 0)
    }

    func testXcodeOldBuildsAreHintsAndRecentBuildsRemainProtected() throws {
        let old = root.appendingPathComponent("OldProject", isDirectory: true)
        let recent = root.appendingPathComponent("RecentProject", isDirectory: true)
        try FileManager.default.createDirectory(at: old, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: recent, withIntermediateDirectories: true)
        try fixture("old.o", in: old, daysAgo: 180)
        try fixture("new.o", in: recent, daysAgo: 1)
        let report = try engine(area: .xcodeDerivedData).inspect(
            area: .xcodeDerivedData, selectedURL: root
        )
        XCTAssertEqual(report.entries.count, 2)
        XCTAssertEqual(report.reviewCount, 1)
        XCTAssertEqual(report.entries.first(where: { $0.label == "OldProject" })?.reviewLevel,
                       .needsReview)
        XCTAssertEqual(report.entries.first(where: { $0.label == "RecentProject" })?.reviewLevel,
                       .protected)
        XCTAssertTrue(report.entries.allSatisfy { !$0.canRemove })
    }

    func testIncompleteResultsCannotClaimToBeReviewable() throws {
        for i in 0..<6 { try fixture("report-\(i).ips", daysAgo: 130) }
        let report = try engine(area: .userLogs, maximumVisited: 2).inspect(
            area: .userLogs, selectedURL: root
        )
        XCTAssertTrue(report.reachedLimit)
        XCTAssertEqual(report.reviewCount, 0)
        XCTAssertTrue(report.entries.allSatisfy { $0.reviewLevel == .protected })
    }

    func testAgentIsAlwaysProtectedEvenWhenVeryOld() {
        let result = RoutineReviewPolicy.assess(
            area: .userLaunchAgents, filename: "com.example.old.plist",
            lastModified: Date(timeIntervalSince1970: 0),
            now: Date(), complete: true
        )
        XCTAssertEqual(result, .protected)
    }

    func testPolicyIsFailClosedForMissingDatesAndErrors() {
        XCTAssertEqual(RoutineReviewPolicy.assess(
            area: .xcodeDerivedData, filename: "Old",
            lastModified: nil, now: Date(), complete: true
        ), .protected)
        XCTAssertEqual(RoutineReviewPolicy.assess(
            area: .userLogs, filename: "old.ips",
            lastModified: Date(timeIntervalSince1970: 0),
            now: Date(), complete: false
        ), .protected)
    }

    func testSecondScanReportsMetadataChangesWithoutOpeningFiles() throws {
        let item = try fixture("old-report.ips", bytes: 32, daysAgo: 130)
        let first = try engine(area: .userLogs).inspect(area: .userLogs, selectedURL: root)
        let identical = try engine(area: .userLogs).inspect(area: .userLogs, selectedURL: root)
        let baseline = try XCTUnwrap(RoutineChangeInspector.compare(
            previous: first, current: identical
        ))
        XCTAssertEqual(baseline.noChangeObservedCount, 1)
        XCTAssertEqual(baseline.changedCount, 0)

        try FileManager.default.setAttributes([
            .modificationDate: Date(timeIntervalSinceNow: -110 * 86_400)
        ], ofItemAtPath: item.path)
        let updated = try engine(area: .userLogs).inspect(area: .userLogs, selectedURL: root)
        let changes = try XCTUnwrap(RoutineChangeInspector.compare(
            previous: first, current: updated
        ))
        XCTAssertEqual(changes.changedCount, 1)
        XCTAssertEqual(changes.noChangeObservedCount, 0)
        XCTAssertEqual(updated.reviewCount, 1)
        XCTAssertTrue(updated.entries.allSatisfy { !$0.canRemove })
    }

    func testSecondScanReportsNewAndMissingEntries() throws {
        let original = try fixture("old-report.ips", daysAgo: 130)
        let first = try engine(area: .userLogs).inspect(area: .userLogs, selectedURL: root)
        try FileManager.default.removeItem(at: original)
        try fixture("new-diagnostic.crash", daysAgo: 140)
        let second = try engine(area: .userLogs).inspect(area: .userLogs, selectedURL: root)
        let delta = try XCTUnwrap(RoutineChangeInspector.compare(
            previous: first, current: second
        ))
        XCTAssertEqual(delta.addedCount, 1)
        XCTAssertEqual(delta.removedCount, 1)
    }

    func testXcodeGroupChangeDetectsNewFileWithoutDeletingAnything() throws {
        let project = root.appendingPathComponent("OldProject", isDirectory: true)
        try FileManager.default.createDirectory(at: project, withIntermediateDirectories: true)
        try fixture("original.o", in: project, daysAgo: 150)
        let first = try engine(area: .xcodeDerivedData).inspect(
            area: .xcodeDerivedData, selectedURL: root
        )
        XCTAssertEqual(first.reviewCount, 1)
        try fixture("recent.o", in: project, daysAgo: 1)
        let second = try engine(area: .xcodeDerivedData).inspect(
            area: .xcodeDerivedData, selectedURL: root
        )
        let comparison = try XCTUnwrap(RoutineChangeInspector.compare(
            previous: first, current: second
        ))
        XCTAssertEqual(comparison.changedCount, 1)
        XCTAssertEqual(second.reviewCount, 0)
        XCTAssertFalse(second.entries[0].canRemove)
    }

    func testXcodeSkippedFilesPreventOldBuildHint() throws {
        let project = root.appendingPathComponent("OldProject", isDirectory: true)
        try FileManager.default.createDirectory(at: project, withIntermediateDirectories: true)
        try fixture("old.o", in: project, daysAgo: 140)
        try fixture("protected.sqlite", in: project, daysAgo: 140)
        let report = try engine(area: .xcodeDerivedData).inspect(
            area: .xcodeDerivedData, selectedURL: root
        )
        XCTAssertEqual(report.entries.count, 1)
        XCTAssertEqual(report.reviewCount, 0)
        XCTAssertFalse(report.entries[0].canRemove)
    }

    func testIncompleteScanCannotBeCompared() throws {
        for index in 0..<8 { try fixture("old-\(index).ips", daysAgo: 130) }
        let incomplete = try engine(area: .userLogs, maximumVisited: 2).inspect(
            area: .userLogs, selectedURL: root
        )
        let full = try engine(area: .userLogs).inspect(
            area: .userLogs, selectedURL: root
        )
        XCTAssertNil(RoutineChangeInspector.compare(previous: incomplete, current: full))
        XCTAssertNil(RoutineChangeInspector.compare(previous: full, current: incomplete))
    }

    func testUserReportsNeverContainDeletionAuthority() throws {
        try fixture("old.log")
        let report = try engine(area: .userLogs).inspect(
            area: .userLogs, selectedURL: root
        )
        XCTAssertEqual(report.entries.count, 1)
        XCTAssertFalse(report.entries[0].description.contains("eliminabile"))
    }
}
