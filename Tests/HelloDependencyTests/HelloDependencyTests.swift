import XCTest

class HelloDependencyTests: DependencyTests {
    
    func test_resolve_fatalErrorOnNotRegisteredDependency() {
        assertFatalErrorOnResolve(Int.self)
        assertFatalErrorOnResolve(TestClass.self)
    }
    
    func test_resolve_returnsRegisteredDependency() {
        register(Int.self, 4)
        register(Float.self, Float(-34.56))
        let testObject = TestClass()
        register(TestClass.self, testObject)
        
        XCTAssertEqual(resolve(Int.self), 4)
        XCTAssertEqual(resolve(Float.self), Float(-34.56))
        XCTAssertTrue(resolve(TestClass.self) === testObject)
    }
    
    func test_resolve_returnsLastRegisteredDependency() {
        register(Int.self, 4)
        
        register(Int.self, -8)
        
        XCTAssertEqual(resolve(Int.self), -8)
    }
    
    func test_resolve_fatalErrorForAllRegisteredAfterClear() {
        register(Int.self, 234)
        register(String.self, "testDependency")
        
        clear()
        
        assertFatalErrorOnResolve(Int.self)
        assertFatalErrorOnResolve(String.self)
    }
    
    func test_resolve_returnsRegisteredDependencyAfterReleasingDifferentType() {
        register(Int.self, 234)
        
        release(String.self)

        XCTAssertEqual(resolve(Int.self), 234)
    }
    
    func test_resolve_fatalErrorAfterRelease() {
        register(String.self, "testDependency")
        
        release(String.self)
        
        assertFatalErrorOnResolve(String.self)
    }
    
    func test_register_retainsReference() {
        var testObj: TestClass? = TestClass()
        register(TestClass.self, testObj!)
        
        testObj = nil
        
        XCTAssertNotNil(resolve(TestClass.self))
    }
    
    func test_clearedDependencyMustBeDeallocated() {
        assertWeakRef(firstAction: { (obj) in
            register(TestClass.self, obj)
        }) {
            clear()
        }
    }
    
    func test_releasedDependencyMustBeDeallocated() {
        assertWeakRef(firstAction: { (obj) in
            register(TestClass.self, obj)
        }) {
            release(TestClass.self)
        }
    }
    
    func test_resolveForIdentifier_fatalErrorOnNotRegisteredDependency() {
        assertFatalErrorOnResolve(Int.self, forIdentifier: "identifier0")
        assertFatalErrorOnResolve(TestClass.self, forIdentifier: "identifier1")
    }
    
    func test_resolveForIdentifier_returnsRegisteredDependencyForSameIdentifier() {
        register(String.self, forIdentifier: "identifier", "dependencyForObj0")
        
        XCTAssertEqual(resolve(String.self, forIdentifier: "identifier"), "dependencyForObj0")
    }
    
    func test_resolveForIdentifier_fatalErrorAfterRegistrationWithoutIndentifier() {
        register(Int.self, 56)
        
        assertFatalErrorOnResolve(Int.self, forIdentifier: "identifier")
    }
    
    func test_resolveForIdentifier_fatalErrorOnWrongIdentifier() {
        register(Int.self, forIdentifier: "identifier", 22)
        
        assertFatalErrorOnResolve(Int.self, forIdentifier: "wrong identifier")
    }
    
    func test_registerForIdentifier_retainsReference() {
        var testObj: TestClass? = TestClass()
        register(TestClass.self, forIdentifier: "identifier", testObj!)
        
        testObj = nil
        
        XCTAssertNotNil(resolve(TestClass.self, forIdentifier: "identifier"))
    }
    
    func test_clear_dependencyMustBeDeallocated() {
        assertWeakRef(firstAction: { (obj) in
            register(TestClass.self, forIdentifier: "identifier", obj)
        }) {
            clear()
        }
    }
    
    func test_release_dependencyMustBeDeallocated() {
        assertWeakRef(firstAction: { (obj) in
            register(TestClass.self, forIdentifier: "identifier", obj)
        }) {
            release(TestClass.self, forIdentifier: "identifier")
        }
    }
    
    func test_resolveForIdentifier_returnsRegisteredDependencyForSameIdentifierAfterOtherRegistration() {
        register(Int.self, forIdentifier: "identifier", 99)
        
        register(Int.self, 9)
        
        XCTAssertEqual(resolve(Int.self), 9)
        XCTAssertEqual(resolve(Int.self, forIdentifier: "identifier"), 99)
    }
    
    func test_register_returnsDependencyAfterRegistrationForDifferentIdentifier() {
        register(Int.self, 9)
        
        register(Int.self, forIdentifier: "identifier", 99)
        
        XCTAssertEqual(resolve(Int.self), 9)
        XCTAssertEqual(resolve(Int.self, forIdentifier: "identifier"), 99)
    }
    
    func test_resolve_returnsRegisteredDependencyAfterRegistrationForDiferentIdentifier() {
        register(Int.self, -234)
        
        release(Int.self, forIdentifier: "identifier")
        
        XCTAssertEqual(resolve(Int.self), -234)
    }
    
    func test_resolveForIdentifier_returnsRegisteredDependencyAfterReleasingWithoutIdentifier() {
        register(Double.self, forIdentifier: "identifier", Double(4.56))
        
        release(Double.self)
        
        XCTAssertEqual(resolve(Double.self, forIdentifier: "identifier"), Double(4.56))
    }
    
    func test_resolveForIdentifier_returnsRegisteredAfterReleasingForDifferentIdentifier() {
        register(Double.self, forIdentifier: "identifier", Double(23))
        
        release(Double.self, forIdentifier: "different identifier")
        
        XCTAssertEqual(resolve(Double.self, forIdentifier: "identifier"), Double(23))
    }
    
    func test_resolve_returnsFactoryResultAfterFactoryRegistration() {
        let objFromFactory = TestClass()
        register(TestClass.self) { () -> (TestClass) in return objFromFactory }
        
        XCTAssertTrue(resolve(TestClass.self) === objFromFactory)
    }
    
    func test_resolve_returnsLastRegisteredObjectAfterFactoryRegistration() {
        register(TestClass.self) {TestClass()}
        
        let obj = TestClass()
        register(TestClass.self, obj)
        
        XCTAssertTrue(resolve(TestClass.self) === obj)
    }
    
    func test_resolve_returnsObjectFromLastRegisteredFactory() {
        register(TestClass.self, TestClass())
        
        let objFromFactory = TestClass()
        register(TestClass.self) { () -> (TestClass) in return objFromFactory }
        
        XCTAssertTrue(resolve(TestClass.self) === objFromFactory)
    }
    
    func test_resolve_fatalErrorAfterReleasingRegisteredFactory() {
        register(TestClass.self) {TestClass()}
        
        release(TestClass.self)
        
        assertFatalErrorOnResolve(TestClass.self)
    }
    
    func test_resolve_fatalErrorAfterClearRegisteredFactory() {
        register(TestClass.self) {TestClass()}
        
        clear()
        
        assertFatalErrorOnResolve(TestClass.self)
    }
    
    func test_resolveForIdentifier_returnsObjectFromRegisteredFactoryForGivenIdentifier() {
        let objFromFactory = TestClass()
        
        register(TestClass.self, forIdentifier: "identifier") {objFromFactory}
        
        XCTAssertTrue(resolve(TestClass.self, forIdentifier: "identifier") === objFromFactory)
    }
    
    func test_resolve_fatalErrorAfterRegisteringFactoryForDifferentIdentifier() {
        let objFromFactory = TestClass()
        
        register(TestClass.self, forIdentifier: "differentIdentifier") {objFromFactory}
        
        assertFatalErrorOnResolve(Int.self, forIdentifier: "identifier")
    }
    
    func test_resolve_returnsRelatedRegisteredDependenciesAfterRegistrationFactoryThenValue() {
        let obj_obj0 = TestClass()
        register(TestClass.self, forIdentifier: "identifier") {obj_obj0}
        
        let obj = TestClass()
        register(TestClass.self) {obj}
        
        XCTAssertTrue(resolve(TestClass.self) === obj)
        XCTAssertTrue(resolve(TestClass.self, forIdentifier: "identifier") === obj_obj0)
    }
    
    func test_resolve_returnsRelatedRegisteredDependenciesAfterRegistrationValueThenFactory() {
        let obj = TestClass()
        register(TestClass.self) {obj}
        
        let obj_obj0 = TestClass()
        register(TestClass.self, forIdentifier: "identifier") {obj_obj0}
        
        XCTAssertTrue(resolve(TestClass.self) === obj)
        XCTAssertTrue(resolve(TestClass.self, forIdentifier: "identifier") === obj_obj0)
    }
    
    func test_resolve_invokesFactoryMultipleTimes() {
        registerThenResolve2Times(register: { (factory) in
            register(TestClass.self, factory)
        }) { () -> (TestClass?) in
            resolve(TestClass.self)
        }

        registerThenResolve2Times(register: { (factory) in
            register(TestClass.self, forIdentifier: "identifier", factory)
        }) { () -> (TestClass?) in
            resolve(TestClass.self, forIdentifier: "identifier")
        }
    }
    private func registerThenResolve2Times(_ file: StaticString = #file,
                                           _ line: UInt = #line,
                                           register: (@escaping ()->(TestClass))->(),
                                           resolve: ()->(TestClass?)) {
        invokeAndReset {
            var factoryCallCount = 0
            let factory = { () -> TestClass in
                factoryCallCount += 1
                return TestClass()
            }
            
            register(factory)
            
            XCTAssertFalse(resolve() === resolve(), file: file, line: line)
            XCTAssertEqual(factoryCallCount, 2, file: file, line: line)
        }
    }
}
