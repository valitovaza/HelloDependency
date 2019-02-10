public enum HelloDependency {
    internal static var savedDependencies: [String: Dependency] = [:]
    internal static var savedSingleDependencies: [String: SingleDependency] = [:]
    
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
    internal static func key<T>(for type: T.Type) -> String {
        return String(describing: type)
    }
    
    public static func resolve<T>(_ type: T.Type) -> T {
        let key = self.key(for: type)
        return resolve(type, key: key, fatalErrorText: "Can not resolve \(key)")
    }
    private static func resolve<T>(_ type: T.Type,
                                   key: String,
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
                                   for identifier: String,
                                   _ dependency: T) {
        let key = self.key(for: type, identifier: identifier)
        savedSingleDependencies[key] = nil
        savedDependencies[key] = Dependency.value(dependency)
    }
    internal static func key<T>(for type: T.Type, identifier: String) -> String {
        return String(describing: type) + identifier
    }
    
    public static func resolve<T>(_ type: T.Type, for identifier: String) -> T {
        return resolve(type, key: self.key(for: type, identifier: identifier),
                       fatalErrorText: "Can not resolve \(self.key(for: type)) for identifier: \(identifier)")
    }
    
    public static func release<T>(_ type: T.Type, for identifier: String) {
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
                                   for identifier: String,
                                   _ factory: @escaping ()->(T)) {
        let key = self.key(for: type, identifier: identifier)
        savedSingleDependencies[key] = nil
        savedDependencies[key] = Dependency.factory(factory)
    }
}
extension HelloDependency {
    internal static func changeResolveFatalError
        (_ resolveValue: Any,
         _ fakeFatalError: @escaping (String)->()) {
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
