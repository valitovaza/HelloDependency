import UIKit

public enum IOSDependencyContainer {
    private static var isTestHostingDependenciesRegistered = false
    private static var isRegisterInvoked = false
    
    private static var viewControllerProxies = [String: ViewControllerProxy]()
    private static var registrationBlocks: [()->()] = []
    private static var hostAppRegistrationBlocks: [()->()] = []
    
    public static func addRegisterationBlock(_ block: @escaping ()->()) {
        guard !isRegisterInvoked else { return }
        registrationBlocks.append(block)
    }
    
    public static func addHostAppsRegisterationBlock(_ block: @escaping ()->()) {
        guard !isTestHostingDependenciesRegistered else { return }
        hostAppRegistrationBlocks.append(block)
    }
    
    public static func register() {
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
        
        hostAppRegistrationBlocks.forEach({$0()})
        hostAppRegistrationBlocks.removeAll()
    }
    
    public static func createProxy<T>(for type: T.Type,
                                      identifier: String = "",
                                      postponeCommands: Bool = true) -> ViewControllerProxy {
        let proxy = ViewControllerProxy(postponeCommands)
        viewControllerProxies[key(for: type, identifier: identifier)] = proxy
        return proxy
    }
    private static func key<T>(for type: T.Type, identifier: String) -> String {
        return String(describing: type) + identifier
    }
    
    public static func viewControllerReady(_ viewController: UIViewController, identifier: String = "") {
        let key = self.key(for: type(of: viewController), identifier: identifier)
        guard let proxy = viewControllerProxies[key] else {return}
        proxy.viewController = viewController
    }
}
