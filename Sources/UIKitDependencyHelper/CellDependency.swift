public protocol CanBeBuiltWithArgumentsContainer {
    associatedtype BuildType
    static func build(_ container: ArgumentsContainer) -> BuildType?
}
public protocol CellDependency: CanBeBuiltWithArgumentsContainer where BuildType == Self {}
