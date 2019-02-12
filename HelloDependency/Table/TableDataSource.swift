import UIKit
import HDependency

protocol TableConfigurator {
    var rowsCount: Int { get }
    func registerCell(_ tableView: UITableView)
    func dequeueReusableCell(_ tableView: UITableView, for indexPath: IndexPath,
                             parentViewController: UIViewController) -> UITableViewCell
}
class TableDataSource: NSObject {
    
    @IBOutlet weak var parentViewController: TableViewController!
    
    private var configurator = {HelloDependency.resolve(TableConfigurator.self)}()
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            configurator.registerCell(tableView)
        }
    }
    
    deinit {
        print("TableDataSource deallocation")
    }
}
extension TableDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return configurator.rowsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return configurator.dequeueReusableCell(tableView, for: indexPath,
                                                parentViewController: parentViewController)
    }
}
