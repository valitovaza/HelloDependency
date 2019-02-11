import UIKit

public enum IOSDependencyContainer {
    private static var isTestHostingDependenciesRegistered = false
    private static var isRegisterInvoked = false
    
    private static var viewControllerProxies = [String: ViewControllerProxy]()
    private static var registrationBlocks: [()->()] = []
    private static var hostAppRegistrationBlocks: [()->()] = []
    
    internal static var isUnitTesting: Bool = {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }()
}
extension IOSDependencyContainer {
    internal static func reset() {
        isTestHostingDependenciesRegistered = false
        isRegisterInvoked = false
        
        viewControllerProxies = [String: ViewControllerProxy]()
        registrationBlocks = []
        hostAppRegistrationBlocks = []
    }
}
extension IOSDependencyContainer {
    public static func addRegisterationBlock(_ block: @escaping ()->()) {
        guard canAddProd else { return }
        registrationBlocks.append(block)
    }
    private static var canAddProd: Bool {
        return !isRegisterInvoked && canRegisterProdDependencies
    }
    
    public static func addHostAppsRegisterationBlock(_ block: @escaping ()->()) {
        guard canAddTesting else { return }
        hostAppRegistrationBlocks.append(block)
    }
    private static var canAddTesting: Bool {
        return !isTestHostingDependenciesRegistered && !canRegisterProdDependencies
    }
    
    public static func register() {
        if canRegisterProdDependencies {
            registerAllDependencies()
        }else{
            registerFakesForTestsHostingApp()
        }
    }
    private static var canRegisterProdDependencies: Bool {
        return !isUnitTesting
    }
    private static func registerAllDependencies() {
        guard !isRegisterInvoked else { return }
        isRegisterInvoked = true
        
        registrationBlocks.forEach({$0()})
        registrationBlocks.removeAll()
    }
    private static func registerFakesForTestsHostingApp() {
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
