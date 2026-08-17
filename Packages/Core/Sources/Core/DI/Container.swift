public enum ServiceScope {
    case transient
    case singleton
}

/// Explicit-registration Factory container — no reflection, no property
/// wrappers. The composition root (TaskFlow app target) registers concrete
/// implementations against protocols; everything else resolves by type.
public final class Container {
    private struct Registration {
        let scope: ServiceScope
        let factory: () -> Any
    }

    private var registrations: [ObjectIdentifier: Registration] = [:]
    private var singletons: [ObjectIdentifier: Any] = [:]

    public init() {}

    public func register<Service>(
        _ type: Service.Type,
        scope: ServiceScope = .transient,
        factory: @escaping () -> Service
    ) {
        registrations[ObjectIdentifier(type)] = Registration(scope: scope) { factory() }
    }

    public func resolve<Service>(_ type: Service.Type = Service.self) -> Service {
        let key = ObjectIdentifier(type)
        guard let registration = registrations[key] else {
            fatalError("No factory registered for \(Service.self). Register it in the composition root before resolving.")
        }

        if registration.scope == .singleton, let cached = singletons[key] as? Service {
            return cached
        }

        guard let service = registration.factory() as? Service else {
            fatalError("Registered factory for \(Service.self) produced a mismatched type.")
        }

        if registration.scope == .singleton {
            singletons[key] = service
        }

        return service
    }
}
