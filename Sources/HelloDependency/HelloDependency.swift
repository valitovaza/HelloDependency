public typealias Indentifier = String

internal protocol HelloDependencyContainerProtocol {
    static func register<T>(_ type: T.Type, _ dependency: T)
    static func resolve<T>(_ type: T.Type) -> T
    static func release<T>(_ type: T.Type)
    static func clear()
    
    static func register<T>(_ type: T.Type, forIdentifier identifier: Indentifier, _ dependency: T)
    static func resolve<T>(_ type: T.Type, forIdentifier identifier: Indentifier) -> T
    static func release<T>(_ type: T.Type, forIdentifier identifier: Indentifier)
    
    static func register<T>(_ type: T.Type, _ factory: @escaping ()->(T))
    static func register<T>(_ type: T.Type, forIdentifier identifier: Indentifier, _ factory: @escaping ()->(T))
}
extension HelloDependencyContainer: HelloDependencyContainerProtocol {}

internal protocol HelloDependencySingleContainerProtocol {
    static func register<T>(_ type: T.Type, _ factory: @escaping ()->(T))
    static func register<T>(_ type: T.Type, forIdentifier identifier: Indentifier, _ factory: @escaping ()->(T))
}
extension HelloDependencyContainer.Single: HelloDependencySingleContainerProtocol {}

internal protocol HelloDependencyWeakContainerProtocol {
    static func register<T>(_ type: T.Type, _ factory: @escaping ()->(T))
    static func register<T>(_ type: T.Type, forIdentifier identifier: Indentifier, _ factory: @escaping ()->(T))
}
extension HelloDependencyContainer.Single.Weak: HelloDependencyWeakContainerProtocol {}

public enum HelloDependency {
    internal static var container: HelloDependencyContainerProtocol.Type = HelloDependencyContainer.self
    internal static var singleContainer: HelloDependencySingleContainerProtocol.Type = HelloDependencyContainer.Single.self
    internal static var weakContainer: HelloDependencyWeakContainerProtocol.Type = HelloDependencyContainer.Single.Weak.self
    internal static var dependencyManager: DependencyProxyManagerProtocol.Type = DependencyProxyManager.self
}
extension HelloDependency: HelloDependencyContainerProtocol {
    public static func register<T>(_ type: T.Type, _ dependency: T) {
        container.register(type, dependency)
    }
    public static func resolve<T>(_ type: T.Type) -> T {
        return container.resolve(type)
    }
    public static func release<T>(_ type: T.Type) {
        container.release(type)
    }
    public static func clear() {
        container.clear()
    }
    
    public static func register<T>(_ type: T.Type, forIdentifier identifier: Indentifier, _ dependency: T) {
        container.register(type, forIdentifier: identifier, dependency)
    }
    public static func resolve<T>(_ type: T.Type, forIdentifier identifier: Indentifier) -> T {
        return container.resolve(type, forIdentifier: identifier)
    }
    public static func release<T>(_ type: T.Type, forIdentifier identifier: Indentifier) {
        container.release(type, forIdentifier: identifier)
    }
    
    public static func register<T>(_ type: T.Type, _ factory: @escaping ()->(T)) {
        container.register(type, factory)
    }
    public static func register<T>(_ type: T.Type, forIdentifier identifier: Indentifier, _ factory: @escaping ()->(T)) {
        container.register(type, forIdentifier: identifier, factory)
    }
}
extension HelloDependency {
    public enum Single: HelloDependencySingleContainerProtocol {
        public static func register<T>(_ type: T.Type, _ factory: @escaping ()->(T)) {
            HelloDependency.singleContainer.register(type, factory)
        }
        public static func register<T>(_ type: T.Type, forIdentifier identifier: Indentifier, _ factory: @escaping ()->(T)) {
            HelloDependency.singleContainer.register(type, forIdentifier: identifier, factory)
        }
        
        public enum Weak: HelloDependencyWeakContainerProtocol {
            public static func register<T>(_ type: T.Type, _ factory: @escaping ()->(T)) {
                HelloDependency.weakContainer.register(type, factory)
            }
            public static func register<T>(_ type: T.Type, forIdentifier identifier: Indentifier, _ factory: @escaping ()->(T)) {
                HelloDependency.weakContainer.register(type, forIdentifier: identifier, factory)
            }
        }
    }
}

protocol DependencyProxyManagerProtocol {
    static func createProxy<T>(for type: T.Type, identifier: Identifier, postponeCommands: Bool) -> DependencyProxy
    static func dependencyReady<T: AnyObject>(_ dependency: T, identifier: Identifier)
}
extension DependencyProxyManager: DependencyProxyManagerProtocol {}

extension HelloDependency: DependencyProxyManagerProtocol {
    public static func createProxy<T>(for type: T.Type, identifier: Identifier = "", postponeCommands: Bool = true) -> DependencyProxy {
        return dependencyManager.createProxy(for: type, identifier: identifier, postponeCommands: postponeCommands)
    }
    public static func dependencyReady<T: AnyObject>(_ dependency: T, identifier: Identifier = "") {
        dependencyManager.dependencyReady(dependency, identifier: identifier)
    }
}
