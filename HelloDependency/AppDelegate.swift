import UIKit
import HDependency

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
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
        IOSDependencyContainer.register()
    }
}

enum IOSDependencyContainer {
    private static var isTestHostingDependenciesRegistered = false
    private static var isRegisterInvoked = false
    
    private static var viewControllerProxies = [String: ViewControllerProxy]()
    private static var registrationBlocks: [()->()] = []
    private static var stubRegistrationBlocks: [()->()] = []
    
    static func addRegisterationBlock(_ block: @escaping ()->()) {
        guard !isRegisterInvoked else { return }
        registrationBlocks.append(block)
    }
    
    static func addStubRegisterationBlock(_ block: @escaping ()->()) {
        guard !isTestHostingDependenciesRegistered else { return }
        stubRegistrationBlocks.append(block)
    }
    
    static func register() {
        if canRegister {
            registerAllDependencies()
        }else{
            registerStubsForTestsHostingApp()
        }
    }
    private static var canRegister: Bool {
        return !isUnitTesting
    }
    private static var isUnitTesting: Bool {
        return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }
    private static func registerAllDependencies() {
        guard !isRegisterInvoked else { return }
        isRegisterInvoked = true
        
        registrationBlocks.forEach({$0()})
        registrationBlocks.removeAll()
    }
    private static func registerStubsForTestsHostingApp() {
        guard !isTestHostingDependenciesRegistered else { return }
        isTestHostingDependenciesRegistered = true
        
        stubRegistrationBlocks.forEach({$0()})
        stubRegistrationBlocks.removeAll()
    }
    
    static func createProxy<T>(for type: T.Type) -> ViewControllerProxy {
        let proxy = ViewControllerProxy()
        viewControllerProxies[key(for: type)] = proxy
        return proxy
    }
    private static func key<T>(for type: T.Type) -> String {
        return String(describing: type)
    }
    
    static func viewControllerReady(_ viewController: UIViewController) {
        let key = self.key(for: type(of: viewController))
        guard let proxy = viewControllerProxies[key] else {return}
        proxy.viewController = viewController
    }
}

class ViewControllerProxy {
    typealias Command = ()->()
    private var commands: [Command] = []
    
    var rememberCommands = false
    
    weak var viewController: UIViewController? {
        didSet {
            processCommands()
        }
    }
    private func processCommands() {
        if let _ = viewController {
            applyCommands()
        }else{
            clearCommands()
        }
    }
    private func applyCommands() {
        commands.forEach({$0()})
        clearCommands()
    }
    private func clearCommands() {
        commands.removeAll()
    }
    
    func executeOrRemember(command: @escaping Command) {
        if let _ = viewController {
            command()
        }else{
            rememberOptionally(command: command)
        }
    }
    private func rememberOptionally(command: @escaping Command) {
        guard rememberCommands && viewController == nil else { return }
        commands.append(command)
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
