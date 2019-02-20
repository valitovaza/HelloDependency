import UIKit
import HelloDependency

class CounterViewController: UIViewController {
    
    private var eventHandler: CounterViewEventHandler!
    
    @IBOutlet weak var countLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventHandler = HelloDependency.resolve(CounterViewEventHandler.self)
        eventHandler.onDidLoad()
        
        //configuration should work even after resolving
        HelloDependency.dependencyReady(self)
    }
    
    @IBAction func incrementAction(_ sender: Any) {
        eventHandler.increment()
    }
}
extension CounterViewController: CounterView {
    func setCountLabel(text: String) {
        countLabel.text = text
    }
}
