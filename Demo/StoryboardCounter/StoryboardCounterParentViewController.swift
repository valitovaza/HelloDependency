import UIKit

class StoryboardCounterParentViewController: UIViewController {
    @IBOutlet weak var incrementCountLabel: UILabel!
}
extension StoryboardCounterParentViewController: IncrementCountLabelView {
    func setIncrementCount(text: String) {
        incrementCountLabel.text = text
    }
}
