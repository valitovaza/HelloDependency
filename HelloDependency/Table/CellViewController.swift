import UIKit

class CellViewController: UIViewController {
    var eventHandler: CellViewEventHandler!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventHandler.onLoad()
    }
    deinit {
        print("CellViewController deallocation")
    }
}
extension CellViewController: CellView {
    func show(title: String) {
        titleLabel.text = title
    }
}
