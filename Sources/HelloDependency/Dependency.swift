internal enum Dependency {
    case value(Any)
    case factory(()->(Any))
    
    var extractedObject: Any {
        switch self {
        case .value(let value): return value
        case .factory(let factory): return factory()
        }
    }
}
