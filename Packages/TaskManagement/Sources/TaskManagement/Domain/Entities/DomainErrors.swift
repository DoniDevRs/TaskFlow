import Foundation

public enum TaskValidationError: Error, Equatable, LocalizedError {
    case emptyTitle
    case dueDateInPast

    public var errorDescription: String? {
        switch self {
        case .emptyTitle: "Title can't be empty."
        case .dueDateInPast: "Due date can't be in the past."
        }
    }
}

public enum ProjectValidationError: Error, Equatable, LocalizedError {
    case emptyName

    public var errorDescription: String? {
        switch self {
        case .emptyName: "Project name can't be empty."
        }
    }
}

public enum TaskUseCaseError: Error, Equatable, LocalizedError {
    case taskNotFound

    public var errorDescription: String? {
        switch self {
        case .taskNotFound: "That task couldn't be found."
        }
    }
}

public enum ProjectUseCaseError: Error, Equatable, LocalizedError {
    case projectNotFound

    public var errorDescription: String? {
        switch self {
        case .projectNotFound: "That project couldn't be found."
        }
    }
}
