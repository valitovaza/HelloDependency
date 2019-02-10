import XCTest

class HelloDependencyTests: TestsWithPublicAccessToHelloDependency {
    
    override func setUp() {
        reset()
    }
    
    func test_resolve_fatalErrorIfNotRegistered() {
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
    
    func test_register_rewritesDependenciesRegisteredBefore() {
        register(Int.self, 4)
        
        register(Int.self, -8)
        
        XCTAssertEqual(resolve(Int.self), -8)
    }
    
    func test_clear_releaseAllRegisteredDependencies() {
        register(Int.self, 234)
        register(String.self, "testDependency")
        
        clear()
        
        assertFatalErrorOnResolve(Int.self)
        assertFatalErrorOnResolve(String.self)
    }
    
    func test_release_removesRegisteredDependency() {
        register(Int.self, 234)
        register(String.self, "testDependency")
        
        release(String.self)
        
        assertFatalErrorOnResolve(String.self)
        XCTAssertEqual(resolve(Int.self), 234)
    }
    
    func test_register_holdsReferenceTillRelease() {
        var testObj: TestClass? = TestClass()
        register(TestClass.self, testObj!)
        
        testObj = nil
        
        XCTAssertNotNil(resolve(TestClass.self))
    }
    
    func test_clearedDependencyMustBeDeallocated() {
        assertWeakRef(registerBlock: { (obj) in
            register(TestClass.self, obj)
        }) {
            release(TestClass.self)
        }
    }
    
    func test_releasedDependencyMustBeDeallocated() {
        assertWeakRef(registerBlock: { (obj) in
            register(TestClass.self, obj)
        }) {
            release(TestClass.self)
        }
    }
    
    func test_resolveForIdentifier_fatalErrorIfNotRegistered() {
        assertFatalErrorOnResolve(Int.self, forIdentifier: "object0")
        assertFatalErrorOnResolve(TestClass.self, forIdentifier: "object1")
    }
    
    func test_resolveForIdentifier_returnsRegisteredForSameIdentifier() {
        register(String.self, for: "obj0", "dependencyForObj0")
        
        XCTAssertEqual(resolve(String.self, for: "obj0"), "dependencyForObj0")
    }
    
    func test_resolveForIdentifier_doesNotReturnForRegisteredWithoutIdentifier() {
        register(Int.self, 56)
        
        assertFatalErrorOnResolve(Int.self, forIdentifier: "obj0")
    }
    
    func test_resolveForIdentifier_doesNotReturnIfRegisteredWithDifferentId() {
        register(Int.self, for: "obj0", 22)
        
        assertFatalErrorOnResolve(Int.self, forIdentifier: "obj1")
    }
    
    func test_registerForIdentifier_holdsReferenceTillRelease() {
        var testObj: TestClass? = TestClass()
        register(TestClass.self, for: "obj", testObj!)
        
        testObj = nil
        
        XCTAssertNotNil(resolve(TestClass.self, for: "obj"))
    }
    
    func test_clear_dependencyMustBeDeallocated() {
        assertWeakRef(registerBlock: { (obj) in
            register(TestClass.self, for: "obj", obj)
        }) {
            clear()
        }
    }
    
    func test_release_dependencyMustBeDeallocated() {
        assertWeakRef(registerBlock: { (obj) in
            register(TestClass.self, for: "obj", obj)
        }) {
            release(TestClass.self, for: "obj")
        }
    }
    
    func test_register_doesNotOverrideRegisterWithIdentifier() {
        register(Int.self, for: "obj", 99)
        
        register(Int.self, 9)
        
        XCTAssertEqual(resolve(Int.self), 9)
        XCTAssertEqual(resolve(Int.self, for: "obj"), 99)
    }
    
    func test_registerWithIdentifier_doesNotOverrideRegister() {
        register(Int.self, 9)
        
        register(Int.self, for: "obj", 99)
        
        XCTAssertEqual(resolve(Int.self), 9)
        XCTAssertEqual(resolve(Int.self, for: "obj"), 99)
    }
    
    func test_releaseForIdentifier_doesNotReleaseRegisteredWithoutIdentifier() {
        register(Int.self, -234)
        
        release(Int.self, for: "obj")
        
        XCTAssertEqual(resolve(Int.self), -234)
    }
    
    func test_release_doesNotReleaseRegisteredForIdentifier() {
        register(Double.self, for: "objForDouble", Double(4.56))
        
        release(Double.self)
        
        XCTAssertEqual(resolve(Double.self, for: "objForDouble"), Double(4.56))
    }
    
    func test_release_doesNotReleaseRegisteredForDifferentIdentifier() {
        register(Double.self, for: "objForDouble", Double(23))
        
        release(Double.self, for: "differentObjForDouble")
        
        XCTAssertEqual(resolve(Double.self, for: "objForDouble"), Double(23))
    }
    
    func test_resolveAfterFactoryRegistration_returnsFactoryResult() {
        let objFromFactory = TestClass()
        register(TestClass.self) { () -> (TestClass) in return objFromFactory }
        
        XCTAssertTrue(resolve(TestClass.self) === objFromFactory)
    }
    
    func test_registerWithoutFactory_replaceRegistered() {
        register(TestClass.self) {TestClass()}
        
        let obj = TestClass()
        register(TestClass.self, obj)
        
        XCTAssertTrue(resolve(TestClass.self) === obj)
    }
    
    func test_registerWithFactory_replaceRegistered() {
        register(TestClass.self, TestClass())
        
        let objFromFactory = TestClass()
        register(TestClass.self) { () -> (TestClass) in return objFromFactory }
        
        XCTAssertTrue(resolve(TestClass.self) === objFromFactory)
    }
    
    func test_release_removeRegisteredFactory() {
        register(TestClass.self) {TestClass()}
        
        release(TestClass.self)
        
        assertFatalErrorOnResolve(TestClass.self)
    }
    
    func test_clear_removeRegisteredFactory() {
        register(TestClass.self) {TestClass()}
        
        clear()
        
        assertFatalErrorOnResolve(TestClass.self)
    }
    
    func test_registerFactoryWithIdentifier_registersFactory() {
        let objFromFactory = TestClass()
        
        register(TestClass.self, for: "obj0") {objFromFactory}
        
        XCTAssertTrue(resolve(TestClass.self, for: "obj0") === objFromFactory)
    }
    
    func test_registerFactoryWithIdentifier_registersOnlyForGivenIdentifier() {
        let objFromFactory = TestClass()
        
        register(TestClass.self, for: "obj0") {objFromFactory}
        
        assertFatalErrorOnResolve(Int.self, forIdentifier: "differentIdentifier")
    }
    
    func test_registerFactory_doesNotOverrideRegisterWithIdentifier() {
        let obj_obj0 = TestClass()
        register(TestClass.self, for: "obj0") {obj_obj0}
        
        let obj = TestClass()
        register(TestClass.self) {obj}
        
        XCTAssertTrue(resolve(TestClass.self) === obj)
        XCTAssertTrue(resolve(TestClass.self, for: "obj0") === obj_obj0)
    }
    
    func test_registerFactoryWithIdentifier_doesNotOverrideRegister() {
        let obj = TestClass()
        register(TestClass.self) {obj}
        
        let obj_obj0 = TestClass()
        register(TestClass.self, for: "obj0") {obj_obj0}
        
        XCTAssertTrue(resolve(TestClass.self) === obj)
        XCTAssertTrue(resolve(TestClass.self, for: "obj0") === obj_obj0)
    }
    
    func test_release_invokesFactoryMultipleTimes() {
        release_invokesFactoryMultipleTimes(register: { (factory) in
            register(TestClass.self, factory)
        }) { () -> (TestClass?) in
            resolve(TestClass.self)
        }
        
        release_invokesFactoryMultipleTimes(register: { (factory) in
            register(TestClass.self, for: "obj", factory)
        }) { () -> (TestClass?) in
            resolve(TestClass.self, for: "obj")
        }
    }
    private func release_invokesFactoryMultipleTimes(_ file: StaticString = #file,
                                                     _ line: UInt = #line,
                                    register: (@escaping ()->(TestClass))->(),
                                    resolve: ()->(TestClass?)) {
        var factoryCallCount = 0
        let factory = { () -> TestClass in
            factoryCallCount += 1
            return TestClass()
        }
        
        register(factory)
        
        XCTAssertFalse(resolve() === resolve(), file: file, line: line)
        XCTAssertEqual(factoryCallCount, 2, file: file, line: line)
        
        reset()
    }
}
