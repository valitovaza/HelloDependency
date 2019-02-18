public protocol ArgsContainerBuildable {
    associatedtype BuildType
    static func build(_ container: ArgsContainer) -> BuildType?
}
public protocol CellDependency: ArgsContainerBuildable where BuildType == Self {}
