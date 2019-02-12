import UIKit
import HDependency
import IOSDependencyContainer

struct TableViewSpecification {
    let reuseIdentifier: String
    let cellType: AnyObject.Type
}
class TableConfiguratorImpl: TableConfigurator {
    private var weakViews = [String: WeakBox<CellViewController>]()
    
    private let repository: TableRepository
    private let tableSpecification: TableViewSpecification
    init(_ repository: TableRepository, _ tableSpecification: TableViewSpecification) {
        self.repository = repository
        self.tableSpecification = tableSpecification
    }
    var rowsCount: Int {
        return repository.dataCount
    }
    func registerCell(_ tableView: UITableView) {
        tableView.register(tableSpecification.cellType,
                           forCellReuseIdentifier: tableSpecification.reuseIdentifier)
    }
    func dequeueReusableCell(_ tableView: UITableView, for indexPath: IndexPath,
                             parentViewController: UIViewController) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableSpecification.reuseIdentifier,
                                                 for: indexPath)
        insertExampleContentViewController(cell, indexPath, parentViewController)
        return cell
    }
    private func insertExampleContentViewController(_ cell: UITableViewCell,
                                                    _ indexPath: IndexPath,
                                                    _ parentViewController: UIViewController) {
        removePreviousContentOptionally(cell, parentViewController)
        let contentVc = createCellViewController()
        configureContentDependency(contentVc, indexPath)
        addChild(contentVc, parentViewController, cell)
    }
    private func createCellViewController() -> CellViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CellViewController") as! CellViewController
    }
    private func removePreviousContentOptionally(_ cell: UITableViewCell,
                                                 _ parentViewController: UIViewController) {
        guard let previousVc = parentViewController.children
            .filter({$0.view === cell.contentView.subviews.first}).first else { return }
        previousVc.willMove(toParent: nil)
        previousVc.view.removeFromSuperview()
        previousVc.removeFromParent()
    }
    private func configureContentDependency(_ cellViewController: CellViewController,
                                            _ indexPath: IndexPath) {
        registerOrChangeDependency(indexPath, cellViewController)
        cellViewController.eventHandler = HelloDependency.resolve(CellViewEventHandler.self,
                                                                  for: indexPath.identifierForDependency)
    }
    private func registerOrChangeDependency(_ indexPath: IndexPath,
                                            _ cellViewController: CellViewController) {
        if let weakViews = weakViews[indexPath.identifierForDependency] {
            weakViews.unbox = cellViewController
        }else{
            let data = repository.getData(for: indexPath.row)
            let weakCellView = WeakBox(cellViewController)
            weakViews[indexPath.identifierForDependency] = weakCellView
            HelloDependency.Single.AndWeakly.register(CellViewEventHandler.self, forIdentifier: indexPath.identifierForDependency, { CellViewEventHandlerImpl(data, weakCellView) })
        }
    }
    private func addChild(_ contentVc: UIViewController,
                          _ parentViewController: UIViewController, _ cell: UITableViewCell) {
        parentViewController.addChild(contentVc)
        contentVc.view.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(contentVc.view)
        NSLayoutConstraint.activate([
            contentVc.view.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            contentVc.view.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
            contentVc.view.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            contentVc.view.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
            ])
        contentVc.didMove(toParent: parentViewController)
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
