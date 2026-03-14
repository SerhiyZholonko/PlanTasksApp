import Foundation

enum AppError: LocalizedError {
    case unknown
    case notFound
    case saveFailed(String)

    var errorDescription: String? {
        switch self {
        case .unknown:                return "An unexpected error occurred."
        case .notFound:               return "The item could not be found."
        case .saveFailed(let reason): return "Save failed: \(reason)"
        }
    }
}
