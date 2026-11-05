import Foundation
import XCTest
@testable import FraPoMacCleaner

private final class ProgressRecorder: @unchecked Sendable {
    private let lock = NSLock()
    private var snapshots: [ScanProgress] = []

    func record(_ snapshot: ScanProgress) {
        lock.lock()
        snapshots.append(snapshot)
        lock.unlock()
    }

    var values: [ScanProgress] {
        lock.lock()
        defer { lock.unlock() }
        return snapshots
    }
}

final class ReadOnlyScanEngineTests: XCTestCase {
    private var folder: URL!
    private var outside: URL!

    override func setUpWithError() throws {
        // A synthetic fixture under the user account, outside protected /private.
        // The root and the separate target are newly created for this test only.
        let fixtureHome = FileManager.default.homeDirectoryForCurrentUser
        folder = fixtureHome
            .appendingPathComponent("FraPoFixture-\(UUID().uuidString)", isDirectory: true)
        outside = fixtureHome
            .appendingPathComponent("FraPoOutside-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: outside, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        // These directories are created exclusively by this XCTest fixture.
        if let folder { try? FileManager.default.removeItem(at: folder) }
        if let outside { try? FileManager.default.removeItem(at: outside) }
    }

    private func makeFile(_ name: String, in directory: URL? = nil, bytes: Int = 256) throws -> URL {
        let file = (directory ?? folder!).appendingPathComponent(name)
        try Data(repeating: 0xAB, count: bytes).write(to: file)
        return file
    }

    private func scanner(maximumEntries: Int = 10_000) -> ReadOnlyScanEngine {
        ReadOnlyScanEngine(
            minimumLargeFileBytes: 128,
            minimumAgeDays: 30,
            maximumEntries: maximumEntries,
            referenceDate: Date()
        )
    }

    func testFindsLargeAndOldFilesWithoutChangingThem() async throws {
        let large = try makeFile("large.data")
        let old = try makeFile("old.txt", bytes: 8)
        let recent = try makeFile("recent.txt", bytes: 8)
        let oldDate = Date(timeIntervalSinceNow: -60 * 86_400)
        try FileManager.default.setAttributes(
            [.modificationDate: oldDate], ofItemAtPath: old.path
        )
        let original = try Data(contentsOf: large)

        let report = try await scanner().scan(in: ScanScope(folderURL: folder))
        XCTAssertEqual(report.inspectedFileCount, 3)
        XCTAssertEqual(report.candidateCount, 2)
        XCTAssertEqual(Set(report.findings.map { $0.fileURL.lastPathComponent }),
                       Set(["large.data", "old.txt"]))
        XCTAssertFalse(report.findings.contains { $0.fileURL == recent })
        XCTAssertEqual(try Data(contentsOf: large), original)
        XCTAssertTrue(report.findings.contains { $0.modifiedAt != nil })
        XCTAssertTrue(report.findings.first(where: {
            $0.fileURL.lastPathComponent == "large.data"
        })?.reasons.contains(.largeFile) == true)
        XCTAssertTrue(report.findings.first(where: {
            $0.fileURL.lastPathComponent == "old.txt"
        })?.reasons.contains(.oldFile) == true)
    }

    func testNeverTraversesSymbolicLinksAndPackages() async throws {
        _ = try makeFile("secret.bin", in: outside)
        try FileManager.default.createSymbolicLink(
            at: folder.appendingPathComponent("shortcut"),
            withDestinationURL: outside
        )
        let package = folder.appendingPathComponent("Demo.app", isDirectory: true)
        try FileManager.default.createDirectory(at: package, withIntermediateDirectories: true)
        _ = try makeFile("nested.bin", in: package)
        let git = folder.appendingPathComponent(".git", isDirectory: true)
        try FileManager.default.createDirectory(at: git, withIntermediateDirectories: true)
        _ = try makeFile("hidden.bin", in: git)
        let ordinary = try makeFile("ordinary.bin")

        let report = try await scanner().scan(in: ScanScope(folderURL: folder))
        XCTAssertEqual(report.candidateCount, 1)
        XCTAssertEqual(report.findings.first?.fileURL, ordinary)
        XCTAssertGreaterThanOrEqual(report.skippedItemCount, 3)
        XCTAssertEqual(report.exclusionSummary.reduce(0) { $0 + $1.count }, report.skippedItemCount)
        let reasons = Set(report.exclusionSummary.map(\.reason))
        XCTAssertTrue(reasons.contains(.symbolicLink))
        XCTAssertTrue(reasons.contains(.protectedPath))
    }

    func testRejectsSymlinkRootAndSystemScopes() async throws {
        let link = outside.appendingPathComponent("root-link")
        try FileManager.default.createSymbolicLink(
            at: link, withDestinationURL: folder
        )
        do {
            _ = try await scanner().scan(in: ScanScope(folderURL: link))
            XCTFail("Symlink roots must be rejected")
        } catch ReadOnlyScanError.invalidScope {}

        do {
            _ = try await scanner().scan(in: ScanScope(folderURL: URL(fileURLWithPath: "/System")))
            XCTFail("System roots must be excluded")
        } catch ReadOnlyScanError.protectedScope {}
    }

    func testLimitAndCancellation() async throws {
        for index in 0..<15 {
            _ = try makeFile("file-\(index).bin")
        }
        let partial = try await scanner(maximumEntries: 5).scan(
            in: ScanScope(folderURL: folder)
        )
        XCTAssertTrue(partial.reachedLimit)
        XCTAssertLessThanOrEqual(partial.inspectedFileCount, 5)

        let task = Task {
            try await scanner().scan(in: ScanScope(folderURL: folder))
        }
        task.cancel()
        do {
            _ = try await task.value
            XCTFail("Cancelled scans must not report success")
        } catch is CancellationError {}
    }

    func testLogicalBreakdownCountsFilesBelowCandidateThreshold() async throws {
        let nested = folder.appendingPathComponent("Media", isDirectory: true)
        try FileManager.default.createDirectory(at: nested, withIntermediateDirectories: true)

        _ = try makeFile("clip.MOV", in: nested, bytes: 256)
        _ = try makeFile("cover.HEIC", in: nested, bytes: 16)
        _ = try makeFile("note.txt", bytes: 8)

        let report = try await scanner().scan(in: ScanScope(folderURL: folder))
        XCTAssertEqual(report.inspectedFileCount, 3)
        XCTAssertEqual(report.candidateCount, 1)
        XCTAssertEqual(report.observedLogicalBytes, 280)
        XCTAssertEqual(report.fileCategories.map(\.label),
                       ["Video", "Immagini", "Documenti"])
        XCTAssertEqual(report.fileCategories.map(\.logicalSizeBytes),
                       [256, 16, 8])
        XCTAssertEqual(report.firstLevelFolders.map(\.label),
                       ["Media", "File nella cartella principale"])
        XCTAssertEqual(report.firstLevelFolders.map(\.logicalSizeBytes),
                       [272, 8])
    }

    func testProgressSnapshotsAreMonotonicAndMatchFinalReport() async throws {
        for index in 0..<260 {
            _ = try makeFile("progress-\(index).txt", bytes: 4)
        }
        let recorder = ProgressRecorder()
        let report = try await scanner().scan(
            in: ScanScope(folderURL: folder),
            progress: { recorder.record($0) }
        )
        let snapshots = recorder.values
        XCTAssertGreaterThanOrEqual(snapshots.count, 3)
        XCTAssertEqual(snapshots.last?.visitedItemCount, 260)
        XCTAssertEqual(snapshots.last?.inspectedFileCount, report.inspectedFileCount)
        XCTAssertEqual(snapshots.last?.skippedItemCount, report.skippedItemCount)
        XCTAssertTrue(zip(snapshots, snapshots.dropFirst()).allSatisfy {
            $0.visitedItemCount <= $1.visitedItemCount
        })
    }

    func testProtectedPathsAppearInSummaryWithoutInspectingContents() async throws {
        let protected = folder.appendingPathComponent(".ssh", isDirectory: true)
        try FileManager.default.createDirectory(at: protected, withIntermediateDirectories: true)
        _ = try makeFile("secret.bin", in: protected, bytes: 256)
        let report = try await scanner().scan(in: ScanScope(folderURL: folder))
        XCTAssertEqual(report.inspectedFileCount, 0)
        XCTAssertEqual(report.skippedItemCount, 1)
        XCTAssertEqual(report.exclusionSummary.first?.reason, .protectedPath)
        XCTAssertEqual(report.exclusionSummary.first?.count, 1)
        XCTAssertTrue(report.issueSummary.isEmpty)
    }

    func testCategoryIsMetadataOnlyAndCaseInsensitive() {
        XCTAssertEqual(ScanFileCategory.classify(URL(fileURLWithPath: "/tmp/example.MP4")), .video)
        XCTAssertEqual(ScanFileCategory.classify(URL(fileURLWithPath: "/tmp/example.swift")), .sourceCode)
        XCTAssertEqual(ScanFileCategory.classify(URL(fileURLWithPath: "/tmp/example.unknown")), .other)
    }

    func testExclusionRules() {
        XCTAssertTrue(ReadOnlyScanEngine.isExcluded(
            URL(fileURLWithPath: "/Users/sample/Library/Keychains")
        ))
        XCTAssertTrue(ReadOnlyScanEngine.isExcluded(
            URL(fileURLWithPath: "/Users/sample/Documents/Backup.photoslibrary")
        ))
        XCTAssertTrue(ReadOnlyScanEngine.isExcluded(
            URL(fileURLWithPath: "/Users/sample/Documents/PrivateCerts/FraPoDevelopment.p12")
        ))
        XCTAssertFalse(ReadOnlyScanEngine.isExcluded(
            URL(fileURLWithPath: "/Users/sample/Documents/ordinary.txt")
        ))
    }
}
