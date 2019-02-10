import UIKit

class CounterParentViewController: UIViewController {

    @IBOutlet weak var incrementCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IOSDependencyContainer.viewControllerReady(self)
    }
    
    deinit {
        print("CounterParentViewController deallocation")
    }
}
extension CounterParentViewController: IncrementCountLabelView {
    func clearIncrementLabel() {
        incrementCountLabel.text = ""
    }
    func setIncrementCount(text: String) {
        incrementCountLabel.text = text
    }
}
