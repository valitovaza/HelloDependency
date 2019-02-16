internal protocol SingleDependency {
    var value: Any { get }
}
internal class _SingleDependency: SingleDependency {
    var factory: ()->(Any)
    init(_ factory: @escaping ()->(Any)) {
        self.factory = factory
    }
    var value: Any {
        guard let cachedValue = _cachedValue else {
            let createdValue = factory()
            cache(value: createdValue)
            return createdValue
        }
        return cachedValue
    }
    var _cachedValue: Any? { return nil }
    func cache(value: Any) {}
}
internal final class StrongDependency: _SingleDependency {
    private var cachedValue: Any?
    override var _cachedValue: Any? {
        return cachedValue
    }
    override func cache(value: Any) {
        cachedValue = value
    }
}
internal final class WeakDependency: _SingleDependency {
    private weak var cachedValue: AnyObject?
    override var _cachedValue: Any? {
        return cachedValue
    }
    override func cache(value: Any) {
        cachedValue = value as AnyObject
    }
}
