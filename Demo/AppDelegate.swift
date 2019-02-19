import UIKit
import HelloDependency
import HelloContainer

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    private var configureManually = false //<----!!! Change to run isolated example
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        if configureManually {
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
        HelloDependency.register(CounterViewEventHandler.self, {
            CounterViewEventHandlerImpl(HelloDependency.resolve(CounterView.self),
                                        HelloDependency.resolve(IncrementCountLabelView.self))
        })
        
        let counterParentProxy = DependencyProxyManager.createProxy(for: CounterParentViewController.self)
        HelloDependency.register(IncrementCountLabelView.self, { counterParentProxy })
        
        let counterProxy = DependencyProxyManager.createProxy(for: CounterViewController.self)
        HelloDependency.register(CounterView.self, { counterProxy })
        
        HelloDependency.Single.Weak.register(TableConfigurator.self, {
            return TableConfiguratorImpl(HelloDependency.resolve(TableRepository.self))
        })
        HelloDependency.Single.Weak.register(TableRepository.self, {
            TableRepositoryImpl()
        })
    }
}
extension DependencyProxy: IncrementCountLabelView {
    func setIncrementCount(text: String) {
        executeOrPostpone {self.incrementCountLabelView?.setIncrementCount(text: text)}
    }
    private var incrementCountLabelView: IncrementCountLabelView? {
        return dependency as? IncrementCountLabelView
    }
}
extension DependencyProxy: CounterView {
    func setCountLabel(text: String) {
        executeOrPostpone {self.counterView?.setCountLabel(text: text)}
    }
    private var counterView: CounterView? {
        return dependency as? CounterView
    }
}

extension WeakBox: CounterView where A: CounterView {
    func setCountLabel(text: String) {
        unbox?.setCountLabel(text: text)
    }
}
extension WeakBox: IncrementCountLabelView where A: IncrementCountLabelView {
    func setIncrementCount(text: String) {
        unbox?.setIncrementCount(text: text)
    }
}
