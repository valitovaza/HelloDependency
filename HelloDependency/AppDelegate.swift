import UIKit
import HDependency
import IOSDependencyContainer

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    private var showManualRootViewController = false //<----!!! Configurable
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        if showManualRootViewController {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let counterViewController = storyboard.instantiateViewController(withIdentifier: "IsolatedCounterViewController") as! IsolatedCounterViewController
            
            let eventHandler = CounterViewEventHandlerImpl(WeakBox(counterViewController),
                                                           WeakBox(counterViewController))
            counterViewController.eventHandler = eventHandler
            
            let rootViewController = UIViewController()
            rootViewController.view.backgroundColor = .white
            let navigationViewController = UINavigationController(rootViewController: rootViewController)
            navigationViewController.pushViewController(counterViewController, animated: false)
            
            window?.rootViewController = navigationViewController
            window?.makeKeyAndVisible()
        }else{
            registerDependensies()
        }
    }
    private func registerDependensies() {
        IOSDependencyContainer.addRegisterationBlock {
            HelloDependency.register(CounterViewEventHandler.self, {
                CounterViewEventHandlerImpl(HelloDependency.resolve(CounterView.self),
                                            HelloDependency.resolve(IncrementCountLabelView.self))
            })
        }
        IOSDependencyContainer.addRegisterationBlock {
            let counterParentProxy = IOSDependencyContainer.createProxy(for: CounterParentViewController.self)
            counterParentProxy.rememberCommands = true
            HelloDependency.register(IncrementCountLabelView.self, { counterParentProxy })
        }
        IOSDependencyContainer.addRegisterationBlock {
            let counterProxy = IOSDependencyContainer.createProxy(for: CounterViewController.self)
            counterProxy.rememberCommands = true
            HelloDependency.register(CounterView.self, { counterProxy })
        }
        IOSDependencyContainer.addRegisterationBlock {
            HelloDependency.register(MainViewEventHandler.self, { MainViewEventHandlerImpl() })
        }
        IOSDependencyContainer.addStubRegisterationBlock {
            HelloDependency.register(MainViewEventHandler.self, { MainViewEventHandlerStub() })
        }
        IOSDependencyContainer.register()
    }
}

class MainViewEventHandlerStub: MainViewEventHandler {
    func testMethod() {
        print("Hello tests!")
    }
}

extension ViewControllerProxy: IncrementCountLabelView {
    func clearIncrementLabel() {
        executeOrRemember {self.incrementCountLabelView?.clearIncrementLabel()}
    }
    private var incrementCountLabelView: IncrementCountLabelView? {
        return viewController as? IncrementCountLabelView
    }
    func setIncrementCount(text: String) {
        executeOrRemember {self.incrementCountLabelView?.setIncrementCount(text: text)}
    }
}
extension ViewControllerProxy: CounterView {
    func setCountLabel(text: String) {
        executeOrRemember {self.counterView?.setCountLabel(text: text)}
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
