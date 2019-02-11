import XCTest
@testable import IOSDependencyContainer

class IOSDependencyContainerTests: XCTestCase {
    override func setUp() {
        IOSDependencyContainer.reset()
    }
    
    func test_addRegisterBlock_doesNotInvokeAddedBlock() {
        IOSDependencyContainer.isUnitTesting = false
        var blockCallCount = 0
        IOSDependencyContainer.addRegisterationBlock {
            blockCallCount += 1
        }
        
        IOSDependencyContainer.isUnitTesting = true
        IOSDependencyContainer.addRegisterationBlock {
            blockCallCount += 1
        }
        
        XCTAssertEqual(blockCallCount, 0)
    }
    
    func test_addRegisterHostBlock_doesNotInvokeAddedBlock() {
        IOSDependencyContainer.isUnitTesting = true
        var blockCallCount = 0
        IOSDependencyContainer.addHostAppsRegisterationBlock {
            blockCallCount += 1
        }
        
        IOSDependencyContainer.isUnitTesting = false
        IOSDependencyContainer.addHostAppsRegisterationBlock {
            blockCallCount += 1
        }
        
        XCTAssertEqual(blockCallCount, 0)
    }
    
    func test_register_invokesAllRegisteredBlocksOnProd() {
        IOSDependencyContainer.isUnitTesting = false
        var block0CallCount = 0
        var block1CallCount = 0
        IOSDependencyContainer.addRegisterationBlock {
            block0CallCount += 1
        }
        IOSDependencyContainer.addRegisterationBlock {
            block1CallCount += 1
        }
        
        IOSDependencyContainer.register()
        
        XCTAssertEqual(block0CallCount, 1)
        XCTAssertEqual(block1CallCount, 1)
    }
    
    func test_register_doesNotInvokeHostAppRegistrationBlockOnProd() {
        IOSDependencyContainer.isUnitTesting = false
        var blockCallCount = 0
        IOSDependencyContainer.addHostAppsRegisterationBlock {
            blockCallCount += 1
        }
        
        IOSDependencyContainer.register()
        
        XCTAssertEqual(blockCallCount, 0)
    }
    
    func test_register_doesNotInvokeBlocksAfterFirstRegistration() {
        IOSDependencyContainer.isUnitTesting = false
        IOSDependencyContainer.register()
        var blockCallCount = 0
        IOSDependencyContainer.addRegisterationBlock {
            blockCallCount += 1
        }
        
        IOSDependencyContainer.register()
        
        XCTAssertEqual(blockCallCount, 0)
    }
    
    func test_register_doesNotInvokeBlocksOnTesting() {
        IOSDependencyContainer.isUnitTesting = true
        var blockCallCount = 0
        IOSDependencyContainer.addRegisterationBlock {
            blockCallCount += 1
        }
        
        IOSDependencyContainer.register()
        
        XCTAssertEqual(blockCallCount, 0)
    }
    
    func test_register_invokeHostBlocksOnTesting() {
        IOSDependencyContainer.isUnitTesting = true
        var block0CallCount = 0
        IOSDependencyContainer.addHostAppsRegisterationBlock {
            block0CallCount += 1
        }
        
        var block1CallCount = 0
        IOSDependencyContainer.addHostAppsRegisterationBlock {
            block1CallCount += 1
        }
        
        IOSDependencyContainer.register()
        
        XCTAssertEqual(block0CallCount, 1)
        XCTAssertEqual(block1CallCount, 1)
    }
    
    func test_register_invokesHostBlocksOnlyOnce() {
        IOSDependencyContainer.isUnitTesting = true
        IOSDependencyContainer.register()
        var blockCallCount = 0
        IOSDependencyContainer.addHostAppsRegisterationBlock {
            blockCallCount += 1
        }
        
        IOSDependencyContainer.register()
        
        XCTAssertEqual(blockCallCount, 0)
    }
    
    func test_register_releaseBlock() {
        register_releaseBlock(isUnitTesting: true)
        register_releaseBlock(isUnitTesting: false)
    }
    private func register_releaseBlock(isUnitTesting: Bool, file: StaticString = #file, line: UInt = #line) {
        IOSDependencyContainer.isUnitTesting = isUnitTesting
        var obj: TestClass! = TestClass()
        weak var weakObj = obj
        if isUnitTesting {
            obj.registerSelfToHostApp()
        }else{
            obj.registerSelfToProd()
        }
        obj = nil
        XCTAssertNotNil(weakObj)
        
        IOSDependencyContainer.register()
        
        XCTAssertNil(weakObj, file: file, line: line)
        
        IOSDependencyContainer.reset()
    }
    
    func test_addRegisterBlock_doesNotHoldOnWrongRegister() {
        addRegisterBlock_doesNotHoldOnWrongRegister(isUnitTesting: false)
        addRegisterBlock_doesNotHoldOnWrongRegister(isUnitTesting: true)
    }
    private func addRegisterBlock_doesNotHoldOnWrongRegister(isUnitTesting: Bool, file: StaticString = #file, line: UInt = #line) {
        IOSDependencyContainer.isUnitTesting = isUnitTesting
        var obj: TestClass! = TestClass()
        if !isUnitTesting {
            obj.registerSelfToHostApp()
        }else{
            obj.registerSelfToProd()
        }
        weak var weakObj = obj
        
        obj = nil
        
        XCTAssertNil(weakObj, file: file, line: line)
        IOSDependencyContainer.reset()
    }
    
    func test_addRegisterBlock_doesNotHoldBlockAfterRegistration() {
        addRegisterBlock_doesNotHoldBlockAfterRegistration(isUnitTesting: false)
        addRegisterBlock_doesNotHoldBlockAfterRegistration(isUnitTesting: true)
    }
    private func addRegisterBlock_doesNotHoldBlockAfterRegistration(isUnitTesting: Bool, file: StaticString = #file, line: UInt = #line) {
        IOSDependencyContainer.isUnitTesting = isUnitTesting
        IOSDependencyContainer.register()
        var obj: TestClass! = TestClass()
        if isUnitTesting {
            obj.registerSelfToHostApp()
        }else{
            obj.registerSelfToProd()
        }
        weak var weakObj = obj
        
        obj = nil
        
        XCTAssertNil(weakObj, file: file, line: line)
        IOSDependencyContainer.reset()
    }
}
extension IOSDependencyContainerTests{
    
    func test_viewControllerReady_doesNotHoldViewController() {
        var vc: UIViewController! = UIViewController()
        weak var weakVc = vc
        IOSDependencyContainer.viewControllerReady(vc)
        IOSDependencyContainer.viewControllerReady(vc, identifier: "test")
        XCTAssertNotNil(weakVc)
        
        vc = nil
        
        XCTAssertNil(weakVc)
    }
    
    func test_viewControllerReady_doesNotHoldViewControllerAfterCreateProxy() {
        _ = IOSDependencyContainer.createProxy(for: UIViewController.self)
        _ = IOSDependencyContainer.createProxy(for: UIViewController.self,
                                               identifier: "test")
        var vc: UIViewController! = UIViewController()
        weak var weakVc = vc
        IOSDependencyContainer.viewControllerReady(vc)
        IOSDependencyContainer.viewControllerReady(vc, identifier: "test")
        
        vc = nil
        
        XCTAssertNil(weakVc)
    }
    
    func test_viewControllerReady_invokesPostponedBlocks() {
        let proxy = IOSDependencyContainer.createProxy(for: UIViewController.self)
        var callCount0 = 0
        proxy.executeOrPostpone {
            callCount0 += 1
        }
        var callCount1 = 0
        proxy.executeOrPostpone {
            callCount1 += 1
        }
        
        IOSDependencyContainer.viewControllerReady(UIViewController())
        
        XCTAssertEqual(callCount0, 1)
        XCTAssertEqual(callCount1, 1)
    }
    
    func test_viewControllerReady_doesNotInvokeBlocksIfIdentifierDoesNotMatch() {
        let proxy0 = IOSDependencyContainer.createProxy(for: UIViewController.self)
        let proxy1 = IOSDependencyContainer.createProxy(for: UIViewController.self,
                                                        identifier: "test")
        var callCount = 0
        proxy0.executeOrPostpone {
            callCount += 1
        }
        proxy1.executeOrPostpone {
            callCount += 1
        }
        
        IOSDependencyContainer.viewControllerReady(UIViewController(),
                                                   identifier: "differentIdentifier")
        
        XCTAssertEqual(callCount, 0)
    }
    
    func test_viewControllerReady_doesNotInvokeBlocksIfClassIsDifferent() {
        let proxy = IOSDependencyContainer.createProxy(for: UIViewController.self)
        var callCount = 0
        proxy.executeOrPostpone {
            callCount += 1
        }
        
        IOSDependencyContainer.viewControllerReady(DifferentViewController())
        
        XCTAssertEqual(callCount, 0)
    }
    class DifferentViewController: UIViewController {}
    
    func test_viewControllerReady_doesNotInvokeBlocksIfNotPostpone() {
        let proxy = IOSDependencyContainer.createProxy(for: UIViewController.self,
                                                       postponeCommands: false)
        var callCount = 0
        proxy.executeOrPostpone {
            callCount += 1
        }
        
        IOSDependencyContainer.viewControllerReady(UIViewController())
        
        XCTAssertEqual(callCount, 0)
    }
    
    func test_executeOrPostpone_doesNotPostponeBlocksAfterFirstReady() {
        let proxy = IOSDependencyContainer.createProxy(for: UIViewController.self)
        let vc = UIViewController()
        IOSDependencyContainer.viewControllerReady(vc)
        
        var callCount = 0
        proxy.executeOrPostpone {
            callCount += 1
        }
        
        XCTAssertEqual(callCount, 1)
    }
    
    func test_executeOrPostpone_doesNotExecuteBlockAfterSecondReady() {
        let proxy = IOSDependencyContainer.createProxy(for: UIViewController.self,
                                                       identifier: "test")
        let vc = UIViewController()
        IOSDependencyContainer.viewControllerReady(vc, identifier: "test")
        var callCount = 0
        proxy.executeOrPostpone {
            callCount += 1
        }
        XCTAssertEqual(callCount, 1)
        
        IOSDependencyContainer.viewControllerReady(UIViewController(),
                                                   identifier: "test")
        
        XCTAssertEqual(callCount, 1)
    }
    
    func test_executeOrPostpone_doesNotHoldBlockIfNotPostpone() {
        let proxy = IOSDependencyContainer.createProxy(for: UIViewController.self,
                                                       postponeCommands: false)
        var obj: TestClass! = TestClass()
        obj.postponeSelfCommand(proxy)
        weak var weakObj = obj
        XCTAssertNotNil(weakObj)
        
        obj = nil
        
        XCTAssertNil(weakObj)
    }
    
    func test_viewControllerReady_releaseHoldedBlocks() {
        let proxy = IOSDependencyContainer.createProxy(for: UIViewController.self)
        var obj: TestClass! = TestClass()
        obj.postponeSelfCommand(proxy)
        weak var weakObj = obj
        obj = nil
        XCTAssertNotNil(weakObj)
        
        IOSDependencyContainer.viewControllerReady(UIViewController())
        
        XCTAssertNil(weakObj)
    }
    
    func test_removeProxiesViewController_releaseHoldedBlocks() {
        let proxy = IOSDependencyContainer.createProxy(for: UIViewController.self)
        var obj: TestClass! = TestClass()
        obj.postponeSelfCommand(proxy)
        weak var weakObj = obj
        obj = nil
        
        proxy.viewController = nil
        
        XCTAssertNil(weakObj)
    }
}
fileprivate class TestClass {
    func registerSelfToProd() {
        IOSDependencyContainer.addRegisterationBlock({self.tst()})
    }
    private func tst() {}
    
    func registerSelfToHostApp() {
        IOSDependencyContainer.addHostAppsRegisterationBlock({self.tst()})
    }
}
extension TestClass {
    func postponeSelfCommand(_ proxy: ViewControllerProxy) {
        proxy.executeOrPostpone {
            self.tstPostpone()
        }
    }
    func tstPostpone() {}
}
