extension HelloDependency {
    public enum Single {
        public static func register<T>(_ type: T.Type,
                                       _ factory: @escaping ()->(T)) {
            let key = HelloDependency.key(for: type)
            setSingle(dependency: StrongDependency(factory), key: key)
        }
        private static func setSingle(dependency: SingleDependency, key: Key) {
            HelloDependency.savedDependencies[key] = nil
            HelloDependency.savedSingleDependencies[key] = dependency
        }
        public static func register<T>(_ type: T.Type,
                                       forIdentifier identifier: Indentifier,
                                       _ factory: @escaping ()->(T)) {
            let key = HelloDependency.key(for: type, identifier: identifier)
            setSingle(dependency: StrongDependency(factory), key: key)
        }
        public enum AndWeakly {
            public static func register<T>(_ type: T.Type,
                                           _ factory: @escaping ()->(T)) {
                let key = HelloDependency.key(for: type)
                setSingle(dependency: WeakDependency(factory), key: key)
            }
            public static func register<T>(_ type: T.Type,
                                           forIdentifier identifier: Indentifier,
                                           _ factory: @escaping ()->(T)) {
                let key = HelloDependency.key(for: type, identifier: identifier)
                setSingle(dependency: WeakDependency(factory), key: key)
            }
        }
    }
}
