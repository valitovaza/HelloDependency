import UIKit

class SecondTableViewCell: UITableViewCell {

    var incrementAction: (()->())?
    
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var incrementCountLabel: UILabel!
    
    @IBAction func incrementAction(_ sender: Any) {
        incrementAction?()
    }
}
extension SecondTableViewCell: CounterView {
    func setCountLabel(text: String) {
        countLabel.text = text
    }
}
extension SecondTableViewCell: IncrementCountLabelView {
    func setIncrementCount(text: String) {
        incrementCountLabel.text = text
    }
}
