import XCTest
@testable import HelloContainer

class DependencyProxyManagerTests: XCTestCase {
    
    override func setUp() {
        DependencyProxyManager.reset()
    }

    func test_dependencyReady_doesNotRetainObject() {
        var obj: ClassToProxy! = ClassToProxy()
        weak var weakObj = obj
        DependencyProxyManager.dependencyReady(obj)
        DependencyProxyManager.dependencyReady(obj, identifier: "test")
        XCTAssertNotNil(weakObj)
        
        obj = nil
        
        XCTAssertNil(weakObj)
    }
    
    func test_dependencyReady_doesNotRetainObjectAfterCreateProxy() {
        _ = DependencyProxyManager.createProxy(for: UIViewController.self)
        _ = DependencyProxyManager.createProxy(for: UIViewController.self,
                                               identifier: "test")
        var obj: ClassToProxy! = ClassToProxy()
        weak var weakObj = obj
        DependencyProxyManager.dependencyReady(obj)
        DependencyProxyManager.dependencyReady(obj, identifier: "test")
        
        obj = nil
        
        XCTAssertNil(weakObj)
    }
    
    func test_dependencyReady_invokesPostponedBlocks() {
        let proxy = DependencyProxyManager.createProxy(for: ClassToProxy.self)
        var callCount0 = 0
        proxy.executeOrPostpone {
            callCount0 += 1
        }
        var callCount1 = 0
        proxy.executeOrPostpone {
            callCount1 += 1
        }
        
        DependencyProxyManager.dependencyReady(ClassToProxy())
        
        XCTAssertEqual(callCount0, 1)
        XCTAssertEqual(callCount1, 1)
    }
    
    func test_dependencyReady_doesNotInvokeBlocksIfIdentifierDoesNotMatch() {
        let proxy0 = DependencyProxyManager.createProxy(for: ClassToProxy.self)
        let proxy1 = DependencyProxyManager.createProxy(for: ClassToProxy.self,
                                                        identifier: "test")
        var callCount = 0
        proxy0.executeOrPostpone {
            callCount += 1
        }
        proxy1.executeOrPostpone {
            callCount += 1
        }
        
        DependencyProxyManager.dependencyReady(ClassToProxy(), identifier: "differentIdentifier")
        
        XCTAssertEqual(callCount, 0)
    }
    
    func test_dependencyReady_doesNotInvokeBlocksIfReadyClassDoesNotMatch() {
        let proxy = DependencyProxyManager.createProxy(for: ClassToProxy.self)
        var callCount = 0
        proxy.executeOrPostpone {
            callCount += 1
        }
        
        DependencyProxyManager.dependencyReady(DifferentClass())
        
        XCTAssertEqual(callCount, 0)
    }
    class DifferentClass {}
    
    func test_viewControllerReady_doesNotInvokeBlocksOnNotPostpone() {
        let proxy = DependencyProxyManager.createProxy(for: ClassToProxy.self,
                                                       postponeCommands: false)
        var callCount = 0
        proxy.executeOrPostpone {
            callCount += 1
        }
        
        DependencyProxyManager.dependencyReady(ClassToProxy())
        
        XCTAssertEqual(callCount, 0)
    }
    
    func test_executeOrPostpone_doesNotPostponeBlocksAfterFirstReadyCall() {
        let proxy = DependencyProxyManager.createProxy(for: ClassToProxy.self)
        let obj = ClassToProxy()
        DependencyProxyManager.dependencyReady(obj)
        
        var callCount = 0
        proxy.executeOrPostpone {
            callCount += 1
        }
        
        XCTAssertEqual(callCount, 1)
    }
    
    func test_executeOrPostpone_doesNotInvokeBlockAfterSecondReadyCall() {
        let proxy = DependencyProxyManager.createProxy(for: ClassToProxy.self,
                                                       identifier: "test")
        let vc = ClassToProxy()
        DependencyProxyManager.dependencyReady(vc, identifier: "test")
        var callCount = 0
        proxy.executeOrPostpone {
            callCount += 1
        }
        XCTAssertEqual(callCount, 1)
        
        DependencyProxyManager.dependencyReady(vc, identifier: "test")
        DependencyProxyManager.dependencyReady(ClassToProxy(), identifier: "test")
        
        XCTAssertEqual(callCount, 1)
    }
    
    func test_executeOrPostpone_doesNotRetainBlockIfNotPostpone() {
        let proxy = DependencyProxyManager.createProxy(for: ClassToProxy.self,
                                                       postponeCommands: false)
        var obj: RetainingTestClass! = RetainingTestClass()
        obj.postponeSelfCommand(proxy)
        weak var weakObj = obj
        XCTAssertNotNil(weakObj)
        
        obj = nil
        
        XCTAssertNil(weakObj)
    }
    
    func test_dependencyReady_releaseRetainedBlocks() {
        let proxy = DependencyProxyManager.createProxy(for: ClassToProxy.self)
        var obj: RetainingTestClass! = RetainingTestClass()
        obj.postponeSelfCommand(proxy)
        weak var weakObj = obj
        obj = nil
        XCTAssertNotNil(weakObj)
        
        DependencyProxyManager.dependencyReady(ClassToProxy())
        
        XCTAssertNil(weakObj)
    }
    
    func test_removeProxiesDependency_releaseRetainedBlocks() {
        let proxy = DependencyProxyManager.createProxy(for: ClassToProxy.self)
        var obj: RetainingTestClass! = RetainingTestClass()
        obj.postponeSelfCommand(proxy)
        weak var weakObj = obj
        obj = nil
        
        proxy.dependency = nil
        
        XCTAssertNil(weakObj)
    }
}
fileprivate class ClassToProxy {}
fileprivate class RetainingTestClass {
    func postponeSelfCommand(_ proxy: DependencyProxy) {
        proxy.executeOrPostpone {
            self.tstPostpone()
        }
    }
    func tstPostpone() {}
}
