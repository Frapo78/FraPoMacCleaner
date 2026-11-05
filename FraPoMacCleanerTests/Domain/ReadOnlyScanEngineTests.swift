import Foundation
import XCTest
@testable import FraPoMacCleaner

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
