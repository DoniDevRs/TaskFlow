import Core

extension ProjectEntity {
    func toDomain() -> Project {
        Project(
            id: id,
            name: name,
            colorTag: colorTag,
            taskIDs: tasksArray.map(\.id)
        )
    }

    func apply(from project: Project) {
        id = project.id
        name = project.name
        colorTag = project.colorTag
    }
}
