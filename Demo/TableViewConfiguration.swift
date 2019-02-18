import UIKit
import HelloDependency
import HelloContainer

final class TableConfiguratorImpl: TableConfigurator {
    private let configurator = CellDependencyConfigurator()
    private let cellIdentifier = "CounterTableViewCell"
    
    private let repository: TableRepository
    init(_ repository: TableRepository) {
        self.repository = repository
    }
    var rowsCount: Int {
        return repository.dataCount
    }
    func registerCell(_ tableView: UITableView) {
        tableView.register(CounterTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }
    func dequeueReusableCell(_ tableView: UITableView, for indexPath: IndexPath,
                             parentViewController: UIViewController) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,
                                                 for: indexPath) as! CounterTableViewCell
        configure(cell, indexPath, parentViewController)
        return cell
    }
    private func configure(_ cell: CounterTableViewCell, _ indexPath: IndexPath,
                           _ parentViewController: UIViewController) {
        cell.initializeContentViewOptionally(parentViewController)
        configureCellViewController(cell, indexPath)
        configure(embeddedChildViewController: cell.cellViewController!.children.first as! CellsEmbeddedChildViewController, indexPath)
    }
    private func configureCellViewController(_ cell: CounterTableViewCell, _ indexPath: IndexPath) {
        let cellViewController = cell.cellViewController!
        
        try! configurator.set(configurable: WeakBox(cellViewController), forType: CellView.self, at: indexPath)
        
        let data = repository.getData(for: indexPath.row)
        try! configurator.setToBuildOnce(data, forType: TableData.self, at: indexPath)
        
        try! configurator.buildDependency(for: cellViewController, dependencyType: CellViewEventHandlerImpl.self, at: indexPath)
    }
    private func configure(embeddedChildViewController: CellsEmbeddedChildViewController, _ indexPath: IndexPath) {
        try! configurator.set(configurable: WeakBox(embeddedChildViewController), forType: CounterView.self, at: indexPath)
        try! configurator.set(configurable: WeakBox(embeddedChildViewController), forType: IncrementCountLabelView.self, at: indexPath)
        
        try! configurator.buildDependency(for: embeddedChildViewController, dependencyType: CounterViewEventHandlerImpl.self, at: indexPath)
    }
}
extension CounterTableViewCell {
    var embeddedChildViewController: CellsEmbeddedChildViewController? {
        return cellViewController?.children.first as? CellsEmbeddedChildViewController
    }
}

extension CellViewEventHandlerImpl: CellDependency {
    static func build(_ container: ArgumentsContainer) -> CellViewEventHandlerImpl? {
        guard let data = container.getArgument(ofType: TableData.self) else { return nil }
        guard let view = container.getArgument(ofType: CellView.self) else { return nil }
        return CellViewEventHandlerImpl(data, view)
    }
}
extension CellViewController: CellDependencyHolder {
    func set(cellDependency: CellViewEventHandlerImpl) {
        self.eventHandler = cellDependency
        eventHandler.didConfigure()
    }
}

extension CounterViewEventHandlerImpl: CellDependency {
    static func build(_ container: ArgumentsContainer) -> CounterViewEventHandlerImpl? {
        guard let counterView = container.getArgument(ofType: CounterView.self) else { return nil }
        guard let incrementCountLabelView = container.getArgument(ofType: IncrementCountLabelView.self) else { return nil }
        return CounterViewEventHandlerImpl(counterView, incrementCountLabelView)
    }
}
extension CellsEmbeddedChildViewController: CellDependencyHolder {
    func set(cellDependency: CounterViewEventHandlerImpl) {
        self.eventHandler = cellDependency
        eventHandler.onDidLoad()
    }
}

extension WeakBox: CellView where A: CellView {
    func show(title: String) {
        unbox?.show(title: title)
    }
}
