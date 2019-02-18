public class ArgsContainer {
    private var args: [String: Any] = [:]
    private var indexPathIdentifier: String
    internal init(_ args: [String: Any], _ indexPathIdentifier: String) {
        self.args = args
        self.indexPathIdentifier = indexPathIdentifier
    }
    
    public func getArgument<T>(ofType type: T.Type) -> T? {
        return args[key(for: type)] as? T
    }
    private func key<T>(for type: T.Type) -> String {
        return String.identifier(for: type) + indexPathIdentifier
    }
}
extension String {
    internal static func identifier<T>(for type: T.Type) -> String {
        return String(describing: type)
    }
}
