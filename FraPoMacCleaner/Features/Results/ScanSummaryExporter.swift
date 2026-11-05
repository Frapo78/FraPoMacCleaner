import Foundation

/// Explicitly privacy-preserving export. No path, filename, folder name,
/// timestamp, finding list, or full filesystem error is serialized.
enum ScanSummaryExporter {
    private struct CategorySummary: Encodable {
        let label: String
        let fileCount: Int
        let logicalSizeBytes: Int64
    }

    private struct CountSummary: Encodable {
        let label: String
        let count: Int
    }

    private struct SafeSummary: Encodable {
        let schemaVersion: Int
        let note: String
        let inspectedFileCount: Int
        let candidateCount: Int
        let skippedItemCount: Int
        let errorCount: Int
        let reachedLimit: Bool
        let observedLogicalBytes: Int64
        let categories: [CategorySummary]
        let exclusions: [CountSummary]
        let accessIssues: [CountSummary]
    }

    static func encode(_ report: ScanReport) throws -> Data {
        // Enumerate only known fixed labels, never arbitrary folder names
        // or the stored URLs of individual findings.
        let categories = ScanFileCategory.allCases.compactMap { kind -> CategorySummary? in
            guard let group = report.fileCategories.first(where: { $0.label == kind.label })
            else { return nil }
            return CategorySummary(
                label: kind.label,
                fileCount: group.fileCount,
                logicalSizeBytes: group.logicalSizeBytes
            )
        }
        let exclusions = ScanExclusionReason.allCases.compactMap { reason -> CountSummary? in
            guard let entry = report.exclusionSummary.first(where: { $0.reason == reason })
            else { return nil }
            return CountSummary(label: reason.label, count: entry.count)
        }
        let issues = ScanAccessIssue.allCases.compactMap { issue -> CountSummary? in
            guard let entry = report.issueSummary.first(where: { $0.issue == issue })
            else { return nil }
            return CountSummary(label: issue.label, count: entry.count)
        }
        let summary = SafeSummary(
            schemaVersion: 1,
            note: "Solo metadati aggregati. Dimensione logica, non spazio recuperabile.",
            inspectedFileCount: report.inspectedFileCount,
            candidateCount: report.candidateCount,
            skippedItemCount: report.skippedItemCount,
            errorCount: report.errorCount,
            reachedLimit: report.reachedLimit,
            observedLogicalBytes: report.observedLogicalBytes,
            categories: categories,
            exclusions: exclusions,
            accessIssues: issues
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(summary)
    }
}
