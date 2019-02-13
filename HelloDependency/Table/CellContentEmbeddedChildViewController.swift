import UIKit

class CellsEmbeddedChildViewController: UIViewController, CellContentView {
    
    var eventHandler: CounterViewEventHandler!
    
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var incrementLabel: UILabel!
    
    func cellContentDidConfigure() {
        eventHandler.onDidLoad()
    }
    
    @IBAction func incrementAction(_ sender: Any) {
        eventHandler.increment()
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
