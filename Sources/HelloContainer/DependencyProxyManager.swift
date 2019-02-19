public enum DependencyProxyManager {
    private static var proxies = [String: DependencyProxy]()
}
extension DependencyProxyManager {
    public typealias Identifier = String
    internal static func reset() {
        proxies = [String: DependencyProxy]()
    }
}
extension DependencyProxyManager {
    public static func createProxy<T>(for type: T.Type, identifier: Identifier = "", postponeCommands: Bool = true) -> DependencyProxy {
        let proxy = DependencyProxy(postponeCommands)
        proxies[key(for: type, identifier: identifier)] = proxy
        return proxy
    }
    private static func key<T>(for type: T.Type, identifier: Identifier) -> String {
        return String(describing: type) + identifier
    }
    
    public static func dependencyReady<T: AnyObject>(_ dependency: T, identifier: Identifier = "") {
        let key = self.key(for: type(of: dependency), identifier: identifier)
        guard let proxy = proxies[key] else {return}
        proxy.dependency = dependency
    }
}
