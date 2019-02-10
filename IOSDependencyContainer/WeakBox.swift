public final class WeakBox<A: AnyObject> {
    public weak var unbox: A?
    public init(_ value: A) {
        unbox = value
    }
}
