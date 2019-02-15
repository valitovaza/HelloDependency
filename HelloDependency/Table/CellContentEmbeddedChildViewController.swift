import UIKit
import IOSDependencyContainer

class CellsEmbeddedChildViewController: UIViewController {
    
    var eventHandler: CounterViewEventHandler!
    
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var incrementLabel: UILabel!
    
    @IBAction func incrementAction(_ sender: Any) {
        eventHandler.increment()
    }
}
extension CellsEmbeddedChildViewController: CellEventHandlerHolder {
    func set(eventHandler: CounterViewEventHandler) {
        self.eventHandler = eventHandler
        eventHandler.onDidLoad()
    }
}
extension CellsEmbeddedChildViewController: CounterView {
    func setCountLabel(text: String) {
        countLabel.text = text
    }
}
extension CellsEmbeddedChildViewController: IncrementCountLabelView {
    func setIncrementCount(text: String) {
        incrementLabel.text = text
    }
}
