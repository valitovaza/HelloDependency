public class ArgumentsContainer {
    private var arguments: [String: Any] = [:]
    private var indexPathIdentifier: String
    internal init(_ arguments: [String: Any], _ indexPathIdentifier: String) {
        self.arguments = arguments
        self.indexPathIdentifier = indexPathIdentifier
    }
    
    public func getArgument<T>(ofType type: T.Type) -> T? {
        return arguments[key(for: type)] as? T
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
