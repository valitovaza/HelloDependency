import XCTest

class HelloDependencyWeakRegistrationTests: DependencyTests {
    
    func test_register_doesNotRetainReference() {
        assertWeakDependency(register: {
            Single.Weak.register(TestClass.self, {TestClass()})
        }) { () -> (TestClass?) in
            self.resolve(TestClass.self)
        }

        assertWeakDependency(register: {
            Single.Weak.register(TestClass.self,
                                 forIdentifier: "identifier", {TestClass()})
        }) { () -> (TestClass?) in
            self.resolve(TestClass.self, forIdentifier: "identifier")
        }
    }
    private func assertWeakDependency(_ file: StaticString = #file,
                                      _ line: UInt = #line,
                                      register: ()->(),
                                      resolve: ()->(TestClass?)) {
        invokeAndReset {
            register()
            
            weak var dependency = resolve()
            XCTAssertNil(dependency, file: file, line: line)
        }
    }
    
    func test_resolve_returnsWeakRegisteredStruct() {
        Single.Weak.register(TestStruct.self, {TestStruct()})
        XCTAssertEqual(resolve(TestStruct.self), TestStruct())
    }
}
