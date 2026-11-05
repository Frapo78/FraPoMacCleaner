enum RiskLevel: String, CaseIterable, Sendable {
    case protected
    case caution
    case reviewable
}

/// Fail-closed: lo scheletro non autorizza alcun file alla pulizia.
struct ConservativeRiskPolicy: Sendable {
    func assess(_ finding: ScanFinding) -> RiskLevel { .protected }
}
