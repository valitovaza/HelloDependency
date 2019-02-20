import UIKit
import HelloDependency

class CounterParentViewController: UIViewController {

    @IBOutlet weak var incrementCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        HelloDependency.dependencyReady(self)
    }
}
extension CounterParentViewController: IncrementCountLabelView {
    func setIncrementCount(text: String) {
        incrementCountLabel.text = text
    }
}
