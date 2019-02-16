import XCTest

class HelloDependency_WeakTests: TestsWithPublicAccessToHelloDependency {

    override func setUp() {
        reset()
    }
    
    func test_register_mustNotRetainReference() {
        checkThatDependencyNotRetained(register: {
            Single.AndWeakly.register(TestClass.self, {TestClass()})
        }) { () -> (TestClass?) in
            self.resolve(TestClass.self)
        }
        
        checkThatDependencyNotRetained(register: {
            Single.AndWeakly.register(TestClass.self,
                                      forIdentifier: "obj", {TestClass()})
        }) { () -> (TestClass?) in
            self.resolve(TestClass.self, for: "obj")
        }
    }
    private func checkThatDependencyNotRetained(_ file: StaticString = #file,
                                                _ line: UInt = #line,
                                                register: ()->(),
                                                resolve: ()->(TestClass?)) {
        register()
        
        weak var dependency = resolve()
        XCTAssertNil(dependency, file: file, line: line)
        
        reset()
    }
    
    func test_register_canWorkWithStructs() {
        Single.AndWeakly.register(TestStruct.self, {TestStruct()})
        XCTAssertEqual(resolve(TestStruct.self), TestStruct())
    }
}
