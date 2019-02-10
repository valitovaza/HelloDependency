import UIKit
import HDependency
import IOSDependencyContainer

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    private var showManualRootViewController = false //<----!!! Configurable
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        if showManualRootViewController {
            let counterViewController = instantiateCounterViewController()
            
            let eventHandler = CounterViewEventHandlerImpl(WeakBox(counterViewController),
                                                           WeakBox(counterViewController))
            counterViewController.eventHandler = eventHandler

            let navigationViewController = createNavigationViewController()
            navigationViewController.pushViewController(counterViewController, animated: false)
            
            window?.rootViewController = navigationViewController
            window?.makeKeyAndVisible()
        }else{
            registerDependensies()
        }
    }
    private func instantiateCounterViewController() -> IsolatedCounterViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "IsolatedCounterViewController")
        return vc as! IsolatedCounterViewController
    }
    private func createNavigationViewController() -> UINavigationController {
        let rootViewController = UIViewController()
        rootViewController.view.backgroundColor = .white
        return UINavigationController(rootViewController: rootViewController)
    }
    private func registerDependensies() {
        registerProdDependencies()
        registerTestsHostAppFakeDependencies()
        
        IOSDependencyContainer.register()
    }
    private func registerProdDependencies() {
        IOSDependencyContainer.addRegisterationBlock {
            HelloDependency.register(CounterViewEventHandler.self, {
                CounterViewEventHandlerImpl(HelloDependency.resolve(CounterView.self),
                                            HelloDependency.resolve(IncrementCountLabelView.self))
            })
        }
        IOSDependencyContainer.addRegisterationBlock {
            let counterParentProxy = IOSDependencyContainer.createProxy(for: CounterParentViewController.self)
            HelloDependency.register(IncrementCountLabelView.self, { counterParentProxy })
        }
        IOSDependencyContainer.addRegisterationBlock {
            let counterProxy = IOSDependencyContainer.createProxy(for: CounterViewController.self)
            HelloDependency.register(CounterView.self, { counterProxy })
        }
        IOSDependencyContainer.addRegisterationBlock {
            HelloDependency.register(MainViewEventHandler.self, { MainViewEventHandlerImpl() })
        }
    }
    private func registerTestsHostAppFakeDependencies() {
        IOSDependencyContainer.addHostAppsRegisterationBlock {
            HelloDependency.register(MainViewEventHandler.self, { MainViewEventHandlerFake() })
        }
    }
}

class MainViewEventHandlerFake: MainViewEventHandler {
    func testMethod() {
        print("Hello tests!")
    }
}

extension ViewControllerProxy: IncrementCountLabelView {
    func clearIncrementLabel() {
        executeOrPostpone {self.incrementCountLabelView?.clearIncrementLabel()}
    }
    private var incrementCountLabelView: IncrementCountLabelView? {
        return viewController as? IncrementCountLabelView
    }
    func setIncrementCount(text: String) {
        executeOrPostpone {self.incrementCountLabelView?.setIncrementCount(text: text)}
    }
}
extension ViewControllerProxy: CounterView {
    func setCountLabel(text: String) {
        executeOrPostpone {self.counterView?.setCountLabel(text: text)}
    }
    private var counterView: CounterView? {
        return viewController as? CounterView
    }
}

extension WeakBox: CounterView where A: CounterView {
    func setCountLabel(text: String) {
        unbox?.setCountLabel(text: text)
    }
}
extension WeakBox: IncrementCountLabelView where A: IncrementCountLabelView {
    func clearIncrementLabel() {
        unbox?.clearIncrementLabel()
    }
    func setIncrementCount(text: String) {
        unbox?.setIncrementCount(text: text)
    }
}