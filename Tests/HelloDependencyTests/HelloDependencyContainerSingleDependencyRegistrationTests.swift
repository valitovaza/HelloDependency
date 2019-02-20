import XCTest

class HelloDependencyContainerSingleDependencyRegistrationTests: DependencyContainerTests {
    
    func test_resolve_returnsSameDependencyMultipleTimes() {
        assertThatResolveReturnsSameDependency2Times(registerBlock: {
            Single.register(TestClass.self, {TestClass()})
        }, resolveBlock: {
            self.resolve(TestClass.self)
        })
        
        assertThatResolveReturnsSameDependency2Times(registerBlock: {
            Single.register(TestClass.self, forIdentifier: "identifier", {TestClass()})
        }, resolveBlock: {
            self.resolve(TestClass.self, forIdentifier: "identifier")
        })
        
        let strongRef = TestClass()
        assertThatResolveReturnsSameDependency2Times(registerBlock: {
            Single.Weak.register(TestClass.self, {strongRef})
        }, resolveBlock: {
            self.resolve(TestClass.self)
        })
        
        assertThatResolveReturnsSameDependency2Times(registerBlock: {
            Single.Weak.register(TestClass.self, forIdentifier: "identifier", {strongRef})
        }, resolveBlock: {
            self.resolve(TestClass.self, forIdentifier: "identifier")
        })
    }
    private func assertThatResolveReturnsSameDependency2Times(_ file: StaticString = #file, _ line: UInt = #line, registerBlock: ()->(), resolveBlock: ()->(TestClass?)) {
        invokeAndReset {
            registerBlock()
            
            XCTAssertTrue(resolveBlock() === resolveBlock(), file: file, line: line)
        }
    }
    
    func test_resolve_fatalErrorAfterRelease() {
        invoke(registerBlock: {
            Single.register(TestClass.self, {TestClass()})
        }, releaseBlock: {
            self.release(TestClass.self)
        }, assertBlock: {
            self.assertFatalErrorOnResolve(TestClass.self)
        })
        
        invoke(registerBlock: {
            Single.register(TestClass.self, forIdentifier: "indetifier", {TestClass()})
        }, releaseBlock: {
            self.release(TestClass.self, forIdentifier: "indetifier")
        }, assertBlock: {
            self.assertFatalErrorOnResolve(TestClass.self, forIdentifier: "indetifier")
        })
        
        invoke(registerBlock: {
            Single.Weak.register(TestClass.self, {TestClass()})
        }, releaseBlock: {
            self.release(TestClass.self)
        }, assertBlock: {
            self.assertFatalErrorOnResolve(TestClass.self)
        })
        
        invoke(registerBlock: {
            Single.Weak.register(TestClass.self, forIdentifier: "indetifier", {TestClass()})
        }, releaseBlock: {
            self.release(TestClass.self, forIdentifier: "indetifier")
        }, assertBlock: {
            self.assertFatalErrorOnResolve(TestClass.self, forIdentifier: "indetifier")
        })
    }
    private func invoke(registerBlock: ()->(),
                        releaseBlock: ()->(),
                        assertBlock: ()->()) {
        invokeAndReset {
            registerBlock()
            releaseBlock()
            assertBlock()
        }
    }
    
    func test_release_deallocatesDependency() {
        assertWeakRefThenReset(firstAction: {obj in
            Single.register(TestClass.self, {obj})
            _ = self.resolve(TestClass.self)
        }, secondAction: {
            self.release(TestClass.self)
        })
        
        assertWeakRefThenReset(firstAction: {obj in
            Single.register(TestClass.self, forIdentifier: "identifier", {obj})
            _ = self.resolve(TestClass.self, forIdentifier: "identifier")
        }, secondAction: {
            self.release(TestClass.self, forIdentifier: "identifier")
        })
        
        assertWeakRefThenReset(firstAction: {obj in
            Single.Weak.register(TestClass.self, {obj})
            _ = self.resolve(TestClass.self)
        }, secondAction: {
            self.release(TestClass.self)
        })
        
        assertWeakRefThenReset(firstAction: {obj in
            Single.Weak.register(TestClass.self, forIdentifier: "identifier", {obj})
            _ = self.resolve(TestClass.self, forIdentifier: "identifier")
        }, secondAction: {
            self.release(TestClass.self, forIdentifier: "identifier")
        })
    }

    
    func test_clear_deallocatesDependency() {
        assertWeakRefThenReset(firstAction: {obj in
            Single.register(TestClass.self, {obj})
            _ = self.resolve(TestClass.self)
        }, secondAction: {
            self.clear()
        })
        
        assertWeakRefThenReset(firstAction: {obj in
            Single.register(TestClass.self, forIdentifier: "identifier", {obj})
            _ = self.resolve(TestClass.self, forIdentifier: "identifier")
        }, secondAction: {
            self.clear()
        })
        
        assertWeakRefThenReset(firstAction: {obj in
            Single.Weak.register(TestClass.self, {obj})
            _ = self.resolve(TestClass.self)
        }, secondAction: {
            self.clear()
        })
        
        assertWeakRefThenReset(firstAction: {obj in
            Single.Weak.register(TestClass.self, forIdentifier: "identifier", {obj})
            _ = self.resolve(TestClass.self, forIdentifier: "identifier")
        }, secondAction: {
            self.clear()
        })
    }
    
    func test_register_doesNotInvokeFactory() {
        assertRegisterDoesNotInvokeFactory(registerBlock: {factory in
            Single.register(TestClass.self, factory)
        })
        
        assertRegisterDoesNotInvokeFactory(registerBlock: {factory in
            Single.register(TestClass.self, forIdentifier: "identifier", factory)
        })
        
        assertRegisterDoesNotInvokeFactory(registerBlock: {factory in
            Single.Weak.register(TestClass.self, factory)
        })
        
        assertRegisterDoesNotInvokeFactory(registerBlock: {factory in
            Single.Weak.register(TestClass.self, forIdentifier: "identifier", factory)
        })
    }
    private func assertRegisterDoesNotInvokeFactory(_ file: StaticString = #file, _ line: UInt = #line, registerBlock: (@escaping () -> TestClass)->()) {
        invokeAndReset {
            var factoryInvokationCount = 0
            let factory = { () -> TestClass in
                factoryInvokationCount += 1
                return TestClass()
            }
            
            registerBlock(factory)
            
            XCTAssertEqual(factoryInvokationCount, 0, file: file, line: line)
        }
    }
    
    func test_resolve_invokesFactoryOnlyOnce() {
        assertThatResolving2TimesInvokeFactoryOnlyOnce(registerBlock: { factory in
            Single.register(TestClass.self, factory)
        }, resolve: {
            _ = self.resolve(TestClass.self)
        })
        
        assertThatResolving2TimesInvokeFactoryOnlyOnce(registerBlock: { factory in
            Single.register(TestClass.self, forIdentifier: "identifier", factory)
        }, resolve: {
            _ = self.resolve(TestClass.self, forIdentifier: "identifier")
        })
        
        var result: TestClass?
        assertThatResolving2TimesInvokeFactoryOnlyOnce(registerBlock: { factory in
            Single.Weak.register(TestClass.self, factory)
        }, resolve: {
            result = self.resolve(TestClass.self)
        })
        
        assertThatResolving2TimesInvokeFactoryOnlyOnce(registerBlock: { factory in
            Single.Weak.register(TestClass.self, forIdentifier: "identifier", factory)
        }, resolve: {
            result = self.resolve(TestClass.self, forIdentifier: "identifier")
        })
        
        XCTAssertNotNil(result)
    }
    private func assertThatResolving2TimesInvokeFactoryOnlyOnce(_ file: StaticString = #file, _ line: UInt = #line, registerBlock: (@escaping () -> TestClass)->(), resolve: ()->()) {
        invokeAndReset {
            var factoryInvokationCount = 0
            let factory = { () -> TestClass in
                factoryInvokationCount += 1
                return TestClass()
            }
            
            registerBlock(factory)
            
            resolve()
            resolve()
            
            XCTAssertEqual(factoryInvokationCount, 1, file: file, line: line)
        }
    }
    
    func test_resolve_returnsLastRegisteredDependency() {
        assertThatResolveReturnsLastRegisteredDependency(firstRegisterBlock:{obj in
            self.register(TestClass.self, obj)
        }, secondRegisterBlock:{obj in
            Single.register(TestClass.self, {obj})
        }, resolveBlock: {
            self.resolve(TestClass.self)
        })
        
        assertThatResolveReturnsLastRegisteredDependency(firstRegisterBlock:{obj in
            self.register(TestClass.self, forIdentifier: "identifier", obj)
        }, secondRegisterBlock: {obj in
            Single.register(TestClass.self, forIdentifier: "identifier", {obj})
        }, resolveBlock: {
            self.resolve(TestClass.self, forIdentifier: "identifier")
        })
        
        assertThatResolveReturnsLastRegisteredDependency(firstRegisterBlock:{obj in
            self.register(TestClass.self, obj)
        }, secondRegisterBlock: {obj in
            Single.Weak.register(TestClass.self, {obj})
        }, resolveBlock: {
            self.resolve(TestClass.self)
        })
        
        assertThatResolveReturnsLastRegisteredDependency(firstRegisterBlock:{obj in
            self.register(TestClass.self, forIdentifier: "identifier", obj)
        }, secondRegisterBlock: {obj in
            Single.Weak.register(TestClass.self, forIdentifier: "identifier", {obj})
        }, resolveBlock: {
            self.resolve(TestClass.self, forIdentifier: "identifier")
        })
        
        assertThatResolveReturnsLastRegisteredDependency(firstRegisterBlock:{obj in
            Single.register(TestClass.self, {obj})
        }, secondRegisterBlock: {obj in
            self.register(TestClass.self, obj)
        }, resolveBlock: {
            self.resolve(TestClass.self)
        })

        assertThatResolveReturnsLastRegisteredDependency(firstRegisterBlock:{obj in
            Single.register(TestClass.self, forIdentifier: "identifier", {obj})
        }, secondRegisterBlock: {obj in
            self.register(TestClass.self, forIdentifier: "identifier", obj)
        }, resolveBlock: {
            self.resolve(TestClass.self, forIdentifier: "identifier")
        })
        
        assertThatResolveReturnsLastRegisteredDependency(firstRegisterBlock:{obj in
            Single.Weak.register(TestClass.self, {obj})
        }, secondRegisterBlock: {obj in
            self.register(TestClass.self, obj)
        }, resolveBlock: {
            self.resolve(TestClass.self)
        })
        
        assertThatResolveReturnsLastRegisteredDependency(firstRegisterBlock:{obj in
            Single.Weak.register(TestClass.self, forIdentifier: "identifier", {obj})
        }, secondRegisterBlock: {obj in
            self.register(TestClass.self, forIdentifier: "identifier", obj)
        }, resolveBlock: {
            self.resolve(TestClass.self, forIdentifier: "identifier")
        })
        
        assertThatResolveReturnsLastRegisteredDependency(firstRegisterBlock:{obj in
            Single.Weak.register(TestClass.self, {obj})
        }, secondRegisterBlock: {obj in
            self.register(TestClass.self, {obj})
        }, resolveBlock: {
            self.resolve(TestClass.self)
        })
        
        assertThatResolveReturnsLastRegisteredDependency(firstRegisterBlock:{obj in
            Single.Weak.register(TestClass.self, forIdentifier: "identifier", {obj})
        }, secondRegisterBlock: {obj in
            self.register(TestClass.self, forIdentifier: "identifier", {obj})
        }, resolveBlock: {
            self.resolve(TestClass.self, forIdentifier: "identifier")
        })
        
        assertThatResolveReturnsLastRegisteredDependency(firstRegisterBlock:{obj in
            Single.Weak.register(TestClass.self, {obj})
        }, secondRegisterBlock: {obj in
            Single.register(TestClass.self, {obj})
        }, resolveBlock: {
            self.resolve(TestClass.self)
        })
        
        assertThatResolveReturnsLastRegisteredDependency(firstRegisterBlock:{obj in
            Single.Weak.register(TestClass.self, forIdentifier: "identifier", {obj})
        }, secondRegisterBlock: {obj in
            Single.register(TestClass.self, forIdentifier: "identifier", {obj})
        }, resolveBlock: {
            self.resolve(TestClass.self, forIdentifier: "identifier")
        })
        
        assertThatResolveReturnsLastRegisteredDependency(firstRegisterBlock:{obj in
            Single.register(TestClass.self, {obj})
        }, secondRegisterBlock: {obj in
            Single.Weak.register(TestClass.self, {obj})
        }, resolveBlock: {
            self.resolve(TestClass.self)
        })
        
        assertThatResolveReturnsLastRegisteredDependency(firstRegisterBlock:{obj in
            Single.register(TestClass.self, forIdentifier: "identifier", {obj})
        }, secondRegisterBlock: {obj in
            Single.Weak.register(TestClass.self, forIdentifier: "identifier", {obj})
        }, resolveBlock: {
            self.resolve(TestClass.self, forIdentifier: "identifier")
        })
    }
    private func assertThatResolveReturnsLastRegisteredDependency(_ file: StaticString = #file, _ line: UInt = #line, firstRegisterBlock: (TestClass)->(), secondRegisterBlock: (TestClass)->(), resolveBlock: ()->(TestClass?)) {
        invokeAndReset {
            firstRegisterBlock(TestClass())
            
            let secondObj = TestClass()
            secondRegisterBlock(secondObj)
            
            XCTAssertTrue(resolveBlock() === secondObj, file: file, line: line)
        }
    }
    
    func test_registerSingle_deallocatePreviousRegistered() {
        assertThatRegisterDeallocatesPreviousRegistered(register: { obj in
            self.register(TestClass.self, obj)
        }, secondRegister: {
            Single.register(TestClass.self, {TestClass()})
        })
        
        assertThatRegisterDeallocatesPreviousRegistered(register: { obj in
            self.register(TestClass.self, {obj})
            _ = self.resolve(TestClass.self)
        }, secondRegister: {
            Single.register(TestClass.self, {TestClass()})
        })
        
        assertThatRegisterDeallocatesPreviousRegistered(register: { obj in
            Single.register(TestClass.self, {obj})
            _ = self.resolve(TestClass.self)
        }, secondRegister: {
            self.register(TestClass.self, TestClass())
        })
        
        assertThatRegisterDeallocatesPreviousRegistered(register: { obj in
            Single.register(TestClass.self, {obj})
            _ = self.resolve(TestClass.self)
        }, secondRegister: {
            self.register(TestClass.self, {TestClass()})
        })
        
        assertThatRegisterDeallocatesPreviousRegistered(register: { obj in
            self.register(TestClass.self, forIdentifier: "identifier", obj)
        }, secondRegister: {
            Single.register(TestClass.self, forIdentifier: "identifier", {TestClass()})
        })
        
        assertThatRegisterDeallocatesPreviousRegistered(register: { obj in
            self.register(TestClass.self, {obj})
            _ = self.resolve(TestClass.self)
        }, secondRegister: {
            Single.Weak.register(TestClass.self, {TestClass()})
        })
        
        assertThatRegisterDeallocatesPreviousRegistered(register: { obj in
            self.register(TestClass.self, forIdentifier: "identifier", obj)
        }, secondRegister: {
            Single.Weak.register(TestClass.self, forIdentifier: "identifier", {TestClass()})
        })
    }
    private func assertThatRegisterDeallocatesPreviousRegistered(_ file: StaticString = #file, _ line: UInt = #line, register: (TestClass)->(), secondRegister: ()->()) {
        invokeAndReset {
            assertWeakRef(firstAction: { (obj) in
                register(obj)
            }, file, line) {
                secondRegister()
            }
        }
    }
    
    func test_register_mustRetainReference() {
        Single.register(TestClass.self, {TestClass()})
        XCTAssertNotNil(resolve(TestClass.self))
        
        Single.register(TestClass.self, forIdentifier: "identifier", {TestClass()})
        XCTAssertNotNil(resolve(TestClass.self, forIdentifier: "identifier"))
    }
}
