internal protocol SingleDependency {
    var value: Any { get }
}
internal final class StrongDependency: SingleDependency {
    private var cachedValue: Any?
    var factory: ()->(Any)
    init(_ factory: @escaping ()->(Any)) {
        self.factory = factory
    }
    var value: Any {
        guard let cachedValue = cachedValue else {
            let createdValue = factory()
            self.cachedValue = createdValue
            return createdValue
        }
        return cachedValue
    }
}
internal final class WeakDependency: SingleDependency {
    private weak var cachedValue: AnyObject?
    var factory: ()->(Any)
    init(_ factory: @escaping ()->(Any)) {
        self.factory = factory
    }
    var value: Any {
        guard let cachedValue = cachedValue else {
            let createdValue = factory()
            self.cachedValue = createdValue as AnyObject
            return createdValue
        }
        return cachedValue
    }
}
