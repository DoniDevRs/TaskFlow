import Foundation

public enum TaskValidationError: Error, Equatable, LocalizedError {
    case emptyTitle
    case dueDateInPast

    public var errorDescription: String? {
        switch self {
        case .emptyTitle:
            String(localized: "Title can't be empty.", bundle: .module)
        case .dueDateInPast:
            String(localized: "Due date can't be in the past.", bundle: .module)
        }
    }
}

public enum ProjectValidationError: Error, Equatable, LocalizedError {
    case emptyName

    public var errorDescription: String? {
        switch self {
        case .emptyName:
            String(localized: "Project name can't be empty.", bundle: .module)
        }
    }
}

public enum TaskUseCaseError: Error, Equatable, LocalizedError {
    case taskNotFound

    public var errorDescription: String? {
        switch self {
        case .taskNotFound:
            String(localized: "That task couldn't be found.", bundle: .module)
        }
    }
}

public enum ProjectUseCaseError: Error, Equatable, LocalizedError {
    case projectNotFound

    public var errorDescription: String? {
        switch self {
        case .projectNotFound:
            String(localized: "That project couldn't be found.", bundle: .module)
        }
    }
}
