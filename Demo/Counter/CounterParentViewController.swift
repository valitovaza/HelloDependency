import UIKit
import HelloContainer

class CounterParentViewController: UIViewController {

    @IBOutlet weak var incrementCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IOSDependencyContainer.viewControllerReady(self)
    }
}
extension CounterParentViewController: IncrementCountLabelView {
    func setIncrementCount(text: String) {
        incrementCountLabel.text = text
    }
}
