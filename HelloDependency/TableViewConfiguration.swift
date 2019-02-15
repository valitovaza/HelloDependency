import UIKit
import HDependency
import IOSDependencyContainer

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
        let weakView = WeakBox(cellViewController)
        
        try! configurator.set(weakView: weakView, asDependencyOfType: CellView.self, at: indexPath)
        
        let data = repository.getData(for: indexPath.row)
        let eventHandlerFactory = CellViewEventHandlerFactory(data, weakView)
        
        configurator.register(eventHandlerFactory, toCreateType: CellViewEventHandler.self, at: indexPath)
        
        configurator.configure(dependencyHolder: cellViewController, dependencyType: CellViewEventHandler.self, at: indexPath)
    }
    private func configure(embeddedChildViewController: CellsEmbeddedChildViewController, _ indexPath: IndexPath) {
        let counterView = WeakBox(embeddedChildViewController)
        let incrementCountLabelView = WeakBox(embeddedChildViewController)
        
        try! configurator.set(weakView: counterView, asDependencyOfType: CounterView.self, at: indexPath)
        try! configurator.set(weakView: incrementCountLabelView, asDependencyOfType: IncrementCountLabelView.self, at: indexPath)
        
        let eventHandlerFactory = CounterViewEventHandlerFactory(counterView, incrementCountLabelView)
        
        configurator.register(eventHandlerFactory, toCreateType: CounterViewEventHandler.self, at: indexPath)
        
        configurator.configure(dependencyHolder: embeddedChildViewController, dependencyType: CounterViewEventHandler.self, at: indexPath)
    }
}
class CellViewEventHandlerFactory: CellEventHandlerFactory {
    private let data: TableData
    private let view: CellView
    init(_ data: TableData, _ view: CellView) {
        self.data = data
        self.view = view
    }
    func create() -> CellViewEventHandler {
        return CellViewEventHandlerImpl(data, view)
    }
}
class CounterViewEventHandlerFactory: CellEventHandlerFactory {
    private let counterView: CounterView
    private let incrementCountLabelView: IncrementCountLabelView
    init(_ counterView: CounterView, _ incrementCountLabelView: IncrementCountLabelView) {
        self.counterView = counterView
        self.incrementCountLabelView = incrementCountLabelView
    }
    func create() -> CounterViewEventHandler {
        return CounterViewEventHandlerImpl(counterView, incrementCountLabelView)
    }
}
extension WeakBox: CellView where A: CellView {
    func show(title: String) {
        unbox?.show(title: title)
    }
}
extension CounterTableViewCell {
    var embeddedChildViewController: CellsEmbeddedChildViewController? {
        return cellViewController?.children.first as? CellsEmbeddedChildViewController
    }
}
