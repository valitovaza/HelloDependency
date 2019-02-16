import UIKit
import IOSDependencyContainer

class CellViewController: UIViewController {
    
    var eventHandler: CellViewEventHandler!
    
    @IBOutlet weak var titleLabel: UILabel!
}
extension CellViewController: CellEventHandlerHolder {
    func set(eventHandler: CellViewEventHandler) {
        self.eventHandler = eventHandler
        eventHandler.didConfigure()
    }
}
extension CellViewController: CellView {
    func show(title: String) {
        titleLabel.text = title
    }
}
