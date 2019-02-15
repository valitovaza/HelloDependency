import UIKit
import HDependency
import IOSDependencyContainer

class CounterViewController: UIViewController {
    
    private var eventHandler: CounterViewEventHandler!
    
    @IBOutlet weak var countLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventHandler = HelloDependency.resolve(CounterViewEventHandler.self)
        eventHandler.onDidLoad()
        
        //configuration even after resolving should work
        IOSDependencyContainer.viewControllerReady(self)
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
