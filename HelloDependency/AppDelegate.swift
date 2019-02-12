import UIKit
import HDependency
import IOSDependencyContainer

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    private var configureManually = false //<----!!! Change to run isolated example
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        if configureManually {
            let counterViewController = instantiateCounterViewController()
            
            let eventHandler = CounterViewEventHandlerImpl(WeakBox(counterViewController),
                                                           WeakBox(counterViewController))
            counterViewController.eventHandler = eventHandler

            let navigationViewController = createNavigationViewController()
            navigationViewController.pushViewController(counterViewController, animated: false)
            
            window?.rootViewController = navigationViewController
            window?.makeKeyAndVisible()
        }else{
            registerDependensies()
        }
    }
    private func instantiateCounterViewController() -> IsolatedCounterViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "IsolatedCounterViewController")
        return vc as! IsolatedCounterViewController
    }
    private func createNavigationViewController() -> UINavigationController {
        let rootViewController = UIViewController()
        rootViewController.view.backgroundColor = .white
        return UINavigationController(rootViewController: rootViewController)
    }
    private func registerDependensies() {
        registerProdDependencies()
        registerTestsHostAppFakeDependencies()
        
        IOSDependencyContainer.register()
    }
    private func registerProdDependencies() {
        IOSDependencyContainer.addRegisterationBlock {
            HelloDependency.register(CounterViewEventHandler.self, {
                CounterViewEventHandlerImpl(HelloDependency.resolve(CounterView.self),
                                            HelloDependency.resolve(IncrementCountLabelView.self))
            })
        }
        IOSDependencyContainer.addRegisterationBlock {
            let counterParentProxy = IOSDependencyContainer.createProxy(for: CounterParentViewController.self)
            HelloDependency.register(IncrementCountLabelView.self, { counterParentProxy })
        }
        IOSDependencyContainer.addRegisterationBlock {
            let counterProxy = IOSDependencyContainer.createProxy(for: CounterViewController.self)
            HelloDependency.register(CounterView.self, { counterProxy })
        }
        IOSDependencyContainer.addRegisterationBlock {
            HelloDependency.register(MainViewEventHandler.self, { MainViewEventHandlerImpl() })
        }
        IOSDependencyContainer.addRegisterationBlock {
            HelloDependency.register(TableConfigurator.self, {
                let ts = TableViewSpecification(reuseIdentifier: "cellIdentifier",
                                                cellType: CounterTableViewCell.self)
                return TableConfiguratorImpl(HelloDependency.resolve(TableRepository.self), ts)
            })
            HelloDependency.Single.AndWeakly.register(TableRepository.self, {
                TableRepositoryImpl()
            })
        }
    }
    private func registerTestsHostAppFakeDependencies() {
        IOSDependencyContainer.addHostAppsRegisterationBlock {
            HelloDependency.register(MainViewEventHandler.self, { MainViewEventHandlerFake() })
        }
    }
}

class MainViewEventHandlerFake: MainViewEventHandler {
    func testMethod() {
        print("Hello tests!")
    }
}

extension ViewControllerProxy: IncrementCountLabelView {
    func clearIncrementLabel() {
        executeOrPostpone {self.incrementCountLabelView?.clearIncrementLabel()}
    }
    private var incrementCountLabelView: IncrementCountLabelView? {
        return viewController as? IncrementCountLabelView
    }
    func setIncrementCount(text: String) {
        executeOrPostpone {self.incrementCountLabelView?.setIncrementCount(text: text)}
    }
}
extension ViewControllerProxy: CounterView {
    func setCountLabel(text: String) {
        executeOrPostpone {self.counterView?.setCountLabel(text: text)}
    }
    private var counterView: CounterView? {
        return viewController as? CounterView
    }
}

extension WeakBox: CounterView where A: CounterView {
    func setCountLabel(text: String) {
        unbox?.setCountLabel(text: text)
    }
}
extension WeakBox: IncrementCountLabelView where A: IncrementCountLabelView {
    func clearIncrementLabel() {
        unbox?.clearIncrementLabel()
    }
    func setIncrementCount(text: String) {
        unbox?.setIncrementCount(text: text)
    }
}

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
        insertExampleContentViewControllerOptionally(cell, indexPath, parentViewController)
        return cell
    }
    private func insertExampleContentViewControllerOptionally(_ cell: UITableViewCell,
                                                              _ indexPath: IndexPath,
                                                              _ parentViewController: UIViewController) {
        removePreviousContent(cell, parentViewController)
        let contentVc = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "CellViewController") as! CellViewController
        configureContentDependency(contentVc, indexPath)
        addChild(contentVc, parentViewController, cell)
    }
    private func removePreviousContent(_ cell: UITableViewCell, _ parentViewController: UIViewController) {
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
