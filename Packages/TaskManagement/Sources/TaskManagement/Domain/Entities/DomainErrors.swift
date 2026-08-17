public enum TaskValidationError: Error, Equatable {
    case emptyTitle
    case dueDateInPast
}

public enum ProjectValidationError: Error, Equatable {
    case emptyName
}

public enum TaskUseCaseError: Error, Equatable {
    case taskNotFound
}

public enum ProjectUseCaseError: Error, Equatable {
    case projectNotFound
}
