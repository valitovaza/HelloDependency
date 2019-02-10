import XCTest

class HelloDependency_SingleTests: TestsWithPublicAccessToHelloDependency {

    override func setUp() {
        reset()
    }
    
    func test_resolve_returnsSameDependency() {
        let strongRef = TestClass()
        let variants: [(register: ()->(), resolve: ()->(TestClass?))] =
            [({Single.register(TestClass.self, {TestClass()})},
              {self.resolve(TestClass.self)}),
             
        ({Single.register(TestClass.self, forIdentifier: "obj", {TestClass()})},
         {self.resolve(TestClass.self, for: "obj")}),
        
        ({Single.AndWeakly.register(TestClass.self, {strongRef})},
         {self.resolve(TestClass.self)}),
        
        ({Single.AndWeakly.register(TestClass.self, forIdentifier: "obj", {strongRef})},
         {self.resolve(TestClass.self, for: "obj")})]
        
        for variant in variants {
            resolve_returnsSameDependency(registerBlock: {
                variant.register()
            }) { () -> (TestClass?) in
                return variant.resolve()
            }
            reset()
        }
    }
    private func resolve_returnsSameDependency(_ file: StaticString = #file,
                                               _ line: UInt = #line,
                                               registerBlock: ()->(),
                                               resolveBlock: ()->(TestClass?)) {
        registerBlock()
        
        XCTAssertTrue(resolveBlock() === resolveBlock(), file: file, line: line)
    }
    
    func test_release_removesDependency() {
        let variants: [(register: ()->(), release: ()->(), assert: ()->())] =
            [({Single.register(TestClass.self, {TestClass()})},
              {self.release(TestClass.self)},
              {self.assertFatalErrorOnResolve(TestClass.self)}),
             
             ({Single.register(TestClass.self, forIdentifier: "obj", {TestClass()})},
              {self.release(TestClass.self, for: "obj")},
              {self.assertFatalErrorOnResolve(TestClass.self, forIdentifier: "obj")}),
             
             ({Single.AndWeakly.register(TestClass.self, {TestClass()})},
              {self.release(TestClass.self)},
              {self.assertFatalErrorOnResolve(TestClass.self)}),
             
             ({Single.AndWeakly.register(TestClass.self, forIdentifier: "obj", {TestClass()})},
              {self.release(TestClass.self, for: "obj")},
              {self.assertFatalErrorOnResolve(TestClass.self, forIdentifier: "obj")})]
        
        for variant in variants {
            release_removesDependency(registerBlock: {
                variant.register()
            }, releaseBlock: {
                variant.release()
            }) {
                variant.assert()
            }
            reset()
        }
    }
    private func release_removesDependency(_ file: StaticString = #file,
                                           _ line: UInt = #line,
                                           registerBlock: ()->(),
                                           releaseBlock: ()->(),
                                           assertBlock: ()->()) {
        registerBlock()
        
        releaseBlock()
        
        assertBlock()
    }
    
    func test_release_deallocatesDependency() {
        let variants: [(register: (TestClass)->(), release: ()->())] =
            [({obj in Single.register(TestClass.self, {obj})
                _ = self.resolve(TestClass.self)},
              {self.release(TestClass.self)}),
             
             ({obj in Single.register(TestClass.self, forIdentifier: "obj", {obj})
                _ = self.resolve(TestClass.self, for: "obj")},
              {self.release(TestClass.self, for: "obj")}),
             
             ({obj in Single.AndWeakly.register(TestClass.self, {obj})
                _ = self.resolve(TestClass.self)},
              {self.release(TestClass.self)}),
             
             ({obj in Single.AndWeakly.register(TestClass.self, forIdentifier: "obj", {obj})
                _ = self.resolve(TestClass.self, for: "obj")},
              {self.release(TestClass.self, for: "obj")})]
        
        for variant in variants {
            assertWeakRef(registerBlock: {obj in
                variant.register(obj)
            }){
                variant.release()
            }
            reset()
        }
    }
    
    func test_clear_deallocatesDependency() {
        let variants: [(register: (TestClass)->(), release: ()->())] =
            [({obj in Single.register(TestClass.self, {obj})
                _ = self.resolve(TestClass.self)},
              {self.clear()}),
             
             ({obj in Single.register(TestClass.self, forIdentifier: "obj", {obj})
                _ = self.resolve(TestClass.self, for: "obj")},
              {self.clear()}),
             
             ({obj in Single.AndWeakly.register(TestClass.self, {obj})
                _ = self.resolve(TestClass.self)},
              {self.clear()}),
             
             ({obj in Single.AndWeakly.register(TestClass.self, forIdentifier: "obj", {obj})
                _ = self.resolve(TestClass.self, for: "obj")},
              {self.clear()})]
        
        for variant in variants {
            assertWeakRef(registerBlock: {obj in
                variant.register(obj)
            }){
                variant.release()
            }
            reset()
        }
    }
    
    func test_register_doesNotInvokeFactory() {
        let variants = [{factory in Single.register(TestClass.self, factory)},
                        {factory in Single.register(TestClass.self, forIdentifier: "obj", factory)},
                        {factory in Single.AndWeakly.register(TestClass.self, factory)},
                        {factory in Single.AndWeakly.register(TestClass.self, forIdentifier: "obj", factory)}]
        for variant in variants {
            register_doesNotInvokesfactory() {factory in
                variant(factory)
            }
            reset()
        }
    }
    private func register_doesNotInvokesfactory(_ file: StaticString = #file,
                                                _ line: UInt = #line,
                            _ registerBlock: (@escaping () -> TestClass)->()) {
        var factoryInvokationCount = 0
        let factory = { () -> TestClass in
            factoryInvokationCount += 1
            return TestClass()
        }
        
        registerBlock(factory)
        
        XCTAssertEqual(factoryInvokationCount, 0, file: file, line: line)
    }
    
    func test_resolve_invokesFactoryOnlyOnce() {
        typealias coupleType = (register: (@escaping () -> TestClass)->(), actions: ()->())
        let variants: [coupleType] =
            [({factory in Single.register(TestClass.self, factory)},
              {  _ = self.resolve(TestClass.self)
                _ = self.resolve(TestClass.self)}),
             
             ({factory in Single.register(TestClass.self, forIdentifier: "obj", factory)},
              {  _ = self.resolve(TestClass.self, for: "obj")
                 _ = self.resolve(TestClass.self, for: "obj")}),
             
             ({factory in Single.register(TestClass.self, factory)},
              {  _ = self.resolve(TestClass.self)
                _ = self.resolve(TestClass.self)}),
             
             ({factory in Single.register(TestClass.self, forIdentifier: "obj", factory)},
              {  _ = self.resolve(TestClass.self, for: "obj")
                _ = self.resolve(TestClass.self, for: "obj")})]
        for variant in variants {
            resolve_invokesFactory(count: 1, registerBlock: { (factory) in
                variant.register(factory)
            }) {
                variant.actions()
            }
            reset()
        }
    }
    private func resolve_invokesFactory(count: Int,
                                        _ file: StaticString = #file,
                                        _ line: UInt = #line,
                                registerBlock: (@escaping () -> TestClass)->(),
                                actions: ()->()) {
        var factoryInvokationCount = 0
        let factory = { () -> TestClass in
            factoryInvokationCount += 1
            return TestClass()
        }
        
        registerBlock(factory)
        
        actions()
        
        XCTAssertEqual(factoryInvokationCount, count)
    }
    
    func test_lastRegister_overridesPreviousRegister() {
        let variants: [(reg0: (TestClass)->(),
            reg1: (TestClass)->(),
            resolve: ()->(TestClass?))] =
            [({obj in self.register(TestClass.self, obj)},
              {obj in Single.register(TestClass.self, {obj})},
              {self.resolve(TestClass.self)}),
             
             ({obj in self.register(TestClass.self, for: "obj", obj)},
              {obj in Single.register(TestClass.self,
                                      forIdentifier: "obj", {obj})},
              {self.resolve(TestClass.self, for: "obj")}),
             
             ({obj in self.register(TestClass.self, obj)},
              {obj in Single.AndWeakly.register(TestClass.self, {obj})},
              {self.resolve(TestClass.self)}),
             
             ({obj in self.register(TestClass.self, for: "obj", obj)},
              {obj in Single.AndWeakly.register(TestClass.self,
                                                forIdentifier: "obj", {obj})},
              {self.resolve(TestClass.self, for: "obj")}),
             
             ({obj in Single.register(TestClass.self, {obj})},
              {obj in self.register(TestClass.self, obj)},
              {self.resolve(TestClass.self)}),
             
             ({obj in Single.register(TestClass.self,
                                      forIdentifier: "obj", {obj})},
              {obj in self.register(TestClass.self, for: "obj", obj)},
              {self.resolve(TestClass.self, for: "obj")}),
             
             ({obj in Single.AndWeakly.register(TestClass.self, {obj})},
              {obj in self.register(TestClass.self, obj)},
              {self.resolve(TestClass.self)}),
             
             ({obj in Single.AndWeakly.register(TestClass.self,
                                                forIdentifier: "obj", {obj})},
              {obj in self.register(TestClass.self, for: "obj", obj)},
              {self.resolve(TestClass.self, for: "obj")}),
             
             ({obj in Single.AndWeakly.register(TestClass.self, {obj})},
              {obj in self.register(TestClass.self, {obj})},
              {self.resolve(TestClass.self)}),
             
             ({obj in Single.AndWeakly.register(TestClass.self,
                                                forIdentifier: "obj", {obj})},
              {obj in self.register(TestClass.self, for: "obj", {obj})},
              {self.resolve(TestClass.self, for: "obj")})]
        
        for (index, variant) in variants.enumerated() {
            lastRegister_overridesPreviousOne(index: index,
                                              firstObj: TestClass(),
                                              secondObj: TestClass(),
                                              firstRegisterBlock: { (obj) in
                variant.reg0(obj)
            }, secondRegisterBlock: { (obj) in
                variant.reg1(obj)
            }) { () -> (TestClass?) in
                return variant.resolve()
            }
            reset()
        }
    }
    private func lastRegister_overridesPreviousOne(index: Int,
                                                   _ file: StaticString = #file,
                                                   _ line: UInt = #line,
                                                   firstObj: TestClass,
                                                   secondObj: TestClass,
                                            firstRegisterBlock: (TestClass)->(),
                                            secondRegisterBlock: (TestClass)->(),
                                            resolveBlock: ()->(TestClass?)) {
        firstRegisterBlock(firstObj)
        
        secondRegisterBlock(secondObj)
        
        XCTAssertTrue(resolveBlock() === secondObj,
                      "fails at \(index)", file: file, line: line)
    }
    
    func test_registerSingle_deallocatePreviousRegistered() {
        let variants: [(reg0: (TestClass)->(), reg1: ()->())] =
            [({obj in self.register(TestClass.self, obj)},
              {Single.register(TestClass.self, {TestClass()})}),
             
             ({obj in self.register(TestClass.self, {obj});
                _ = self.resolve(TestClass.self)},
              {Single.register(TestClass.self, {TestClass()})}),
             
             ({obj in Single.register(TestClass.self, {obj})
                _ = self.resolve(TestClass.self)},
              {self.register(TestClass.self, TestClass())}),
             
             ({obj in Single.register(TestClass.self, {obj})
                _ = self.resolve(TestClass.self)},
              {self.register(TestClass.self, {TestClass()})}),
             
             ({obj in self.register(TestClass.self, for: "obj", obj)},
              {Single.register(TestClass.self, forIdentifier: "obj",
                               {TestClass()})}),
             
             ({obj in self.register(TestClass.self, {obj});
                _ = self.resolve(TestClass.self)},
              {Single.AndWeakly.register(TestClass.self, {TestClass()})}),
             
             ({obj in self.register(TestClass.self, for: "obj", obj)},
              {Single.AndWeakly.register(TestClass.self, forIdentifier: "obj",
                                         {TestClass()})})]
        
        for (index, variant) in variants.enumerated() {
            assertWeakRef(message: "Failed at \(index)",
                          registerBlock: { (obj) in
                variant.reg0(obj)
            }) {
                variant.reg1()
            }
            reset()
        }
    }
    
    func test_register_mustRetainReference() {
        Single.register(TestClass.self, {TestClass()})
        XCTAssertNotNil(resolve(TestClass.self))
        
        Single.register(TestClass.self, forIdentifier: "obj", {TestClass()})
        XCTAssertNotNil(resolve(TestClass.self, for: "obj"))
    }
}
