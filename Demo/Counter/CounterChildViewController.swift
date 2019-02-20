import UIKit
import HelloDependency

class CounterChildViewController: UIViewController {
    
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var incrementLabel: UILabel!
    
    private var eventHandler: CounterViewEventHandler!
    
    @IBAction func incrementAction(_ sender: Any) {
        eventHandler.increment()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventHandler = HelloDependency.resolve(CounterViewEventHandler.self, forIdentifier: String(describing: CounterChildViewController.self))
        eventHandler.onDidLoad()
        HelloDependency.dependencyReady(self)
    }
}
extension CounterChildViewController: CounterView {
    func setCountLabel(text: String) {
        countLabel.text = text
    }
}
extension CounterChildViewController: IncrementCountLabelView {
    func setIncrementCount(text: String) {
        incrementLabel.text = text
    }
}
