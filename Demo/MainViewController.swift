import UIKit
import HelloDependency

class MainViewController: UIViewController {
    private var eventHandler: MainViewEventHandler!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventHandler = HelloDependency.resolve(MainViewEventHandler.self)
        eventHandler.testMethod()
    }
}
protocol MainViewEventHandler {
    func testMethod()
}
class MainViewEventHandlerImpl: MainViewEventHandler {
    func testMethod() {
        print("Hello prodaction!")
    }
}
