public protocol CellDependencyHolder {
    associatedtype CellDependency
    func set(cellDependency: CellDependency)
}
