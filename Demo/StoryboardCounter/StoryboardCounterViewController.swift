import UIKit

class StoryboardCounterViewController: UIViewController {
    
    var eventHandler: CounterViewEventHandler!
    
    @IBOutlet weak var countLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventHandler.onDidLoad()
    }
    
    @IBAction func incrementAction(_ sender: Any) {
        eventHandler.increment()
    }
}
extension StoryboardCounterViewController: CounterView {
    func setCountLabel(text: String) {
        countLabel.text = text
    }
}
