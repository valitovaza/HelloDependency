internal enum HelloDependencyContainer {
    internal typealias Key = String
    internal typealias Indentifier = String
    
    internal static var savedDependencies: [Key: Dependency] = [:]
    internal static var savedSingleDependencies: [Key: SingleDependency] = [:]
    
    internal static var fatalErrorFunc = internalFatalError
    internal static var valueOnFatalError: Any?
    
    internal enum Single {
        internal static func register<T>(_ type: T.Type,
                                         _ factory: @escaping ()->(T)) {
            let key = HelloDependencyContainer.key(for: type)
            setSingle(dependency: StrongDependency(factory), key: key)
        }
        private static func setSingle(dependency: SingleDependency, key: Key) {
            HelloDependencyContainer.savedDependencies[key] = nil
            HelloDependencyContainer.savedSingleDependencies[key] = dependency
        }
        internal static func register<T>(_ type: T.Type,
                                         forIdentifier identifier: Indentifier,
                                         _ factory: @escaping ()->(T)) {
            let key = HelloDependencyContainer.key(for: type, identifier: identifier)
            setSingle(dependency: StrongDependency(factory), key: key)
        }
        internal enum Weak {
            internal static func register<T>(_ type: T.Type,
                                             _ factory: @escaping ()->(T)) {
                let key = HelloDependencyContainer.key(for: type)
                setSingle(dependency: WeakDependency(factory), key: key)
            }
            internal static func register<T>(_ type: T.Type,
                                             forIdentifier identifier: Indentifier,
                                             _ factory: @escaping ()->(T)) {
                let key = HelloDependencyContainer.key(for: type, identifier: identifier)
                setSingle(dependency: WeakDependency(factory), key: key)
            }
        }
    }
}
extension HelloDependencyContainer {
    internal static func reset() {
        valueOnFatalError = nil
        resetFatalErrorFunc()
        savedDependencies = [:]
        savedSingleDependencies = [:]
    }
}
extension HelloDependencyContainer {
    internal static func register<T>(_ type: T.Type, _ dependency: T) {
        let key = self.key(for: type)
        savedSingleDependencies[key] = nil
        savedDependencies[key] = Dependency.value(dependency)
    }
    internal static func key<T>(for type: T.Type) -> Key {
        return String(describing: type)
    }
    
    internal static func resolve<T>(_ type: T.Type) -> T {
        let key = self.key(for: type)
        return resolve(type, key: key, fatalErrorText: "Can not resolve \(key)")
    }
    private static func resolve<T>(_ type: T.Type,
                                   key: Key,
                                   fatalErrorText: String) -> T {
        if let singleDependency = savedSingleDependencies[key],
            let dependency = singleDependency.value as? T {
            return dependency
        }else if let dependency = savedDependencies[key]?.extractedObject as? T {
            return dependency
        }else{
            fatalErrorFunc(fatalErrorText)
            return valueOnFatalError as! T
        }
    }
    
    internal static func release<T>(_ type: T.Type) {
        let key = self.key(for: type)
        savedDependencies[key] = nil
        savedSingleDependencies[key] = nil
    }
    
    internal static func clear() {
        savedSingleDependencies.removeAll()
        savedDependencies.removeAll()
    }
}
extension HelloDependencyContainer {
    internal static func register<T>(_ type: T.Type,
                                   forIdentifier identifier: Indentifier,
                                   _ dependency: T) {
        let key = self.key(for: type, identifier: identifier)
        savedSingleDependencies[key] = nil
        savedDependencies[key] = Dependency.value(dependency)
    }
    internal static func key<T>(for type: T.Type, identifier: Indentifier) -> String {
        return String(describing: type) + identifier
    }
    
    internal static func resolve<T>(_ type: T.Type, forIdentifier identifier: Indentifier) -> T {
        return resolve(type, key: self.key(for: type, identifier: identifier),
                       fatalErrorText: "Can not resolve \(self.key(for: type)) for identifier: \(identifier)")
    }
    
    internal static func release<T>(_ type: T.Type, forIdentifier identifier: Indentifier) {
        let key = self.key(for: type, identifier: identifier)
        savedDependencies[key] = nil
        savedSingleDependencies[key] = nil
    }
}
extension HelloDependencyContainer {
    internal static func register<T>(_ type: T.Type, _ factory: @escaping ()->(T)) {
        let key = self.key(for: type)
        savedSingleDependencies[key] = nil
        savedDependencies[key] = Dependency.factory(factory)
    }
    internal static func register<T>(_ type: T.Type,
                                   forIdentifier identifier: Indentifier,
                                   _ factory: @escaping ()->(T)) {
        let key = self.key(for: type, identifier: identifier)
        savedSingleDependencies[key] = nil
        savedDependencies[key] = Dependency.factory(factory)
    }
}
extension HelloDependencyContainer {
    internal static func changeFatalErrorFunc(_ resolveValue: Any, _ fakeFatalError: @escaping (String)->()) {
        valueOnFatalError = resolveValue
        fatalErrorFunc = fakeFatalError
    }
    internal static func resetFatalErrorFunc() {
        fatalErrorFunc = internalFatalError
    }
    private static func internalFatalError(_ msg: String) {
        fatalError(msg)
    }
}
