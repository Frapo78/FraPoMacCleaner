import Foundation

enum ScanResultReasonFilter: String, CaseIterable, Identifiable {
    case all, large, old

    var id: Self { self }

    var label: String {
        switch self {
        case .all: "Tutti i motivi"
        case .large: "Solo file grandi"
        case .old: "Solo file datati"
        }
    }

    var reason: ScanFindingReason? {
        switch self {
        case .all: nil
        case .large: .largeFile
        case .old: .oldFile
        }
    }
}

enum ScanResultSort: String, CaseIterable, Identifiable {
    case largest, oldest, newest, filename

    var id: Self { self }

    var label: String {
        switch self {
        case .largest: "Dimensione ↓"
        case .oldest: "Più vecchi"
        case .newest: "Più recenti"
        case .filename: "Nome A–Z"
        }
    }
}

/// Pure, in-memory explorer of the at-most 500 findings retained by the scan.
/// No filesystem reads, no mutation, no background indexing.
struct ScanResultExplorer {
    static func apply(
        _ findings: [ScanFinding],
        search: String = "",
        reason: ScanResultReasonFilter = .all,
        category: ScanFileCategory? = nil,
        sort: ScanResultSort = .largest
    ) -> [ScanFinding] {
        let term = search.trimmingCharacters(in: .whitespacesAndNewlines)
        return findings.filter { finding in
            (term.isEmpty || finding.fileURL.path.localizedStandardContains(term)) &&
            (reason.reason.map { finding.reasons.contains($0) } ?? true) &&
            (category.map { ScanFileCategory.classify(finding.fileURL) == $0 } ?? true)
        }.sorted { left, right in
            switch sort {
            case .largest:
                if left.logicalSizeBytes != right.logicalSizeBytes {
                    return left.logicalSizeBytes > right.logicalSizeBytes
                }
            case .oldest:
                if left.modifiedAt != right.modifiedAt {
                    // Files with missing dates go last.
                    return (left.modifiedAt ?? .distantFuture) <
                        (right.modifiedAt ?? .distantFuture)
                }
            case .newest:
                if left.modifiedAt != right.modifiedAt {
                    return (left.modifiedAt ?? .distantPast) >
                        (right.modifiedAt ?? .distantPast)
                }
            case .filename:
                let comparison = left.fileURL.lastPathComponent.localizedStandardCompare(
                    right.fileURL.lastPathComponent
                )
                if comparison != .orderedSame {
                    return comparison == .orderedAscending
                }
            }
            return left.fileURL.path < right.fileURL.path
        }
    }
}
