import UIKit
import HDependency
import IOSDependencyContainer

protocol CellContentView {
    func cellContentDidConfigure()
}
fileprivate final class CellViewsWrapper {
    var cellView: WeakBox<CellViewController>?
    var counterView: WeakBox<CellsEmbeddedChildViewController>?
}
final class TableConfiguratorImpl: TableConfigurator {
    private let cellIdentifier = "CounterTableViewCell"
    
    private var contentViews = [IndexPath: CellViewsWrapper]()
    
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
        configureEmbeddedChildViewController(cell, indexPath)
        notifyContentViews(cell)
    }
    
    private func configureCellViewController(_ cell: CounterTableViewCell, _ indexPath: IndexPath) {
        let contentVc = cell.cellViewController!
        configureContentDependency(contentVc, indexPath)
    }
    private func configureContentDependency(_ cellViewController: CellViewController,
                                            _ indexPath: IndexPath) {
        registerOrChangeDependency(indexPath, cellViewController)
        cellViewController.eventHandler = HelloDependency.resolve(CellViewEventHandler.self,
                                                                  for: indexPath.identifierForDependency)
    }
    private func registerOrChangeDependency(_ indexPath: IndexPath,
                                            _ cellViewController: CellViewController) {
        let wrapper = viewWrapper(at: indexPath)
        if let _ = wrapper.cellView {
            change(cellViewController: cellViewController, at: indexPath)
        }else{
            let data = repository.getData(for: indexPath.row)
            let weakCellView = WeakBox(cellViewController)
            wrapper.cellView = weakCellView
            HelloDependency.Single.register(CellViewEventHandler.self, forIdentifier: indexPath.identifierForDependency, { CellViewEventHandlerImpl(data, weakCellView) })
        }
    }
    private func viewWrapper(at indexPath: IndexPath) -> CellViewsWrapper {
        if let wrapper = contentViews[indexPath] {
            return wrapper
        }else{
            let wrapper = CellViewsWrapper()
            contentViews[indexPath] = wrapper
            return wrapper
        }
    }
    private func change(cellViewController: CellViewController, at indexPath: IndexPath) {
        for contentView in contentViews.values {
            if contentView.cellView?.unbox == cellViewController {
                contentView.cellView?.unbox = nil
            }
        }
        contentViews[indexPath]?.cellView?.unbox = cellViewController
    }
    private func configureEmbeddedChildViewController(_ cell: CounterTableViewCell, _ indexPath: IndexPath) {
        let embeddedChildViewController = cell.embeddedChildViewController!
        configureEmbeddedViewDependency(embeddedChildViewController, indexPath)
    }
    private func configureEmbeddedViewDependency(_ embeddedChildViewController: CellsEmbeddedChildViewController, _ indexPath: IndexPath) {
        registerOrChangeDependency(indexPath, embeddedChildViewController)
        embeddedChildViewController.eventHandler = HelloDependency.resolve(CounterViewEventHandler.self, for: indexPath.identifierForDependency)
    }
    private func registerOrChangeDependency(_ indexPath: IndexPath, _ embeddedChildViewController: CellsEmbeddedChildViewController) {
        let wrapper = viewWrapper(at: indexPath)
        if let _ = wrapper.counterView {
            change(embeddedChildViewController: embeddedChildViewController, at: indexPath)
        }else{
            let weakCounterView = WeakBox(embeddedChildViewController)
            wrapper.counterView = weakCounterView
            HelloDependency.Single.register(CounterViewEventHandler.self, forIdentifier: indexPath.identifierForDependency, {
                CounterViewEventHandlerImpl(weakCounterView, weakCounterView)
            })
        }
    }
    private func change(embeddedChildViewController: CellsEmbeddedChildViewController, at indexPath: IndexPath) {
        for contentView in contentViews.values {
            if contentView.counterView?.unbox == embeddedChildViewController {
                contentView.counterView?.unbox = nil
            }
        }
        contentViews[indexPath]?.counterView?.unbox = embeddedChildViewController
    }
    private func notifyContentViews(_ cell: CounterTableViewCell) {
        cell.cellViewController?.cellContentDidConfigure()
        cell.embeddedChildViewController?.cellContentDidConfigure()
    }
}
extension IndexPath {
    var identifierForDependency: String {
        return String(row)
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
