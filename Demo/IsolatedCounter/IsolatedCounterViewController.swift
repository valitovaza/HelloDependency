import UIKit

class IsolatedCounterViewController: UIViewController {
    
    var eventHandler: CounterViewEventHandler!
    
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var incrementCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventHandler.onDidLoad()
    }
    
    @IBAction func incrementAction(_ sender: Any) {
        eventHandler.increment()
    }
}
extension IsolatedCounterViewController: CounterView {
    func setCountLabel(text: String) {
        countLabel.text = text
    }
}
extension IsolatedCounterViewController: IncrementCountLabelView {
    func setIncrementCount(text: String) {
        incrementCountLabel.text = text
    }
}
