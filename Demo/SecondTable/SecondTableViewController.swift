import UIKit
import HelloDependency

class SecondTableViewController: UITableViewController {

    private var repository: TableRepository!
    private var eventHandlers: [IndexPath: CounterViewEventHandler] = [:]
    private var counterViews: [IndexPath: WeakBox<SecondTableViewCell>] = [:]
    private var incrementLabelViews: [IndexPath: WeakBox<SecondTableViewCell>] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delaysContentTouches = false
        repository = HelloDependency.resolve(TableRepository.self)
    }
}
extension SecondTableViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200.0
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repository.dataCount
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SecondTableViewCell") as! SecondTableViewCell
        let eventHandler = self.eventHandler(for: indexPath, cell: cell)
        cell.incrementAction = eventHandler.increment
        eventHandler.onDidLoad()
        return cell
    }
    private func eventHandler(for indexPath: IndexPath, cell: SecondTableViewCell) -> CounterViewEventHandler {
        if let eventHandler = eventHandlers[indexPath] {
            let counterView = counterViews[indexPath]!
            counterView.unbox = cell
            let incrementLabelView = incrementLabelViews[indexPath]!
            incrementLabelView.unbox = cell
            return eventHandler
        }else{
            let counterView = WeakBox(cell)
            counterViews[indexPath] = counterView
            let incrementLabelView = WeakBox(cell)
            incrementLabelViews[indexPath] = incrementLabelView
            let eventHandler = CounterViewEventHandlerImpl(counterView, incrementLabelView)
            eventHandlers[indexPath] = eventHandler
            return eventHandler
        }
    }
}
