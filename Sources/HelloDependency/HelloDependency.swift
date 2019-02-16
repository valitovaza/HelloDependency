public enum HelloDependency {
    public typealias Key = String
    public typealias Indentifier = String
    
    internal static var savedDependencies: [Key: Dependency] = [:]
    internal static var savedSingleDependencies: [Key: SingleDependency] = [:]
    
    internal static var fatalErrorFunc = internalFatalError
    internal static var valueOnFatalError: Any?
}
extension HelloDependency {
    internal static func reset() {
        valueOnFatalError = nil
        resetFatalErrorFunc()
        savedDependencies = [:]
        savedSingleDependencies = [:]
    }
}
extension HelloDependency {
    public static func register<T>(_ type: T.Type, _ dependency: T) {
        let key = self.key(for: type)
        savedSingleDependencies[key] = nil
        savedDependencies[key] = Dependency.value(dependency)
    }
    internal static func key<T>(for type: T.Type) -> Key {
        return String(describing: type)
    }
    
    public static func resolve<T>(_ type: T.Type) -> T {
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
    
    public static func release<T>(_ type: T.Type) {
        let key = self.key(for: type)
        savedDependencies[key] = nil
        savedSingleDependencies[key] = nil
    }
    
    public static func clear() {
        savedSingleDependencies.removeAll()
        savedDependencies.removeAll()
    }
}
extension HelloDependency {
    public static func register<T>(_ type: T.Type,
                                   forIdentifier identifier: Indentifier,
                                   _ dependency: T) {
        let key = self.key(for: type, identifier: identifier)
        savedSingleDependencies[key] = nil
        savedDependencies[key] = Dependency.value(dependency)
    }
    internal static func key<T>(for type: T.Type, identifier: Indentifier) -> String {
        return String(describing: type) + identifier
    }
    
    public static func resolve<T>(_ type: T.Type, forIdentifier identifier: Indentifier) -> T {
        return resolve(type, key: self.key(for: type, identifier: identifier),
                       fatalErrorText: "Can not resolve \(self.key(for: type)) for identifier: \(identifier)")
    }
    
    public static func release<T>(_ type: T.Type, forIdentifier identifier: Indentifier) {
        let key = self.key(for: type, identifier: identifier)
        savedDependencies[key] = nil
        savedSingleDependencies[key] = nil
    }
}
extension HelloDependency {
    public static func register<T>(_ type: T.Type, _ factory: @escaping ()->(T)) {
        let key = self.key(for: type)
        savedSingleDependencies[key] = nil
        savedDependencies[key] = Dependency.factory(factory)
    }
    public static func register<T>(_ type: T.Type,
                                   forIdentifier identifier: Indentifier,
                                   _ factory: @escaping ()->(T)) {
        let key = self.key(for: type, identifier: identifier)
        savedSingleDependencies[key] = nil
        savedDependencies[key] = Dependency.factory(factory)
    }
}
extension HelloDependency {
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
