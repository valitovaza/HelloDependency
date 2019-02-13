import UIKit

class CellViewController: UIViewController, CellContentView {
    var eventHandler: CellViewEventHandler!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    func cellContentDidConfigure() {
        eventHandler.didConfigure()
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
