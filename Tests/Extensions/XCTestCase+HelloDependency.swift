import XCTest
@testable import HelloDependency

extension XCTestCase {
    
    class TestClass: DefaultInit {
        required init() {}
    }
    struct TestStruct: Equatable {}
    
    func reset() {
        HelloDependency.reset()
    }
    
    func assertFatalErrorOnResolve<T>(_ type: T.Type,
                                      file: StaticString = #file,
                                      line: UInt = #line) {
        let expectedMessage = "Can not resolve \(String(describing: type))"
        assertFatalErrorOnResolve(type,
                                  expectedMessage: expectedMessage,
                                  file: file, line: line) {
            HelloDependency.resolve(type)
        }
    }
    private func assertFatalErrorOnResolve<T>(_ type: T.Type,
                                              expectedMessage: String,
                                              file: StaticString = #file,
                                              line: UInt = #line,
                                              _ factory: ()->(T)) {
        let exp = expectation(description: "Wait fatal error")
        HelloDependency.changeFatalErrorFunc(defaultValue(for: type)) { (msg) in
            XCTAssertEqual(msg, expectedMessage, file: file, line: line)
            exp.fulfill()
        }
        _ = factory()
        self.waitForExpectations(timeout: 1.0) { (error) in
            guard let _ = error else { return }
            XCTFail("Waiting fatal error failed", file: file, line: line)
        }
    }
    
    func assertFatalErrorOnResolve<T>(_ type: T.Type,
                                      forIdentifier identifier: String,
                                      file: StaticString = #file,
                                      line: UInt = #line) {
        let expectedMessage = "Can not resolve \(String(describing: type)) for identifier: \(identifier)"
        assertFatalErrorOnResolve(type,
                                  expectedMessage: expectedMessage,
                                  file: file, line: line) {
            HelloDependency.resolve(type, forIdentifier: identifier)
        }
    }
    
    func safeResolve<T>(_ type: T.Type,
                        file: StaticString = #file,
                        line: UInt = #line,
                        _ factory: ()->(T)) -> T? {
        var fatalErrorOccured = false
        HelloDependency.changeFatalErrorFunc(defaultValue(for: type)) { (_) in
            fatalErrorOccured = true
        }
        let dependency = factory()
        if fatalErrorOccured {
            XCTFail("Fatal error occured!!!", file: file, line: line)
            return nil
        }else{
            return dependency
        }
    }
    
    func defaultValue<T>(for type: T.Type) -> Any {
        if type is Int.Type {
            return Int(0)
        }else if type is Double.Type {
            return Double(0)
        }else if type is Float.Type {
            return Float(0)
        }else if type is String.Type {
            return ""
        }else if type is TestClass.Type {
            return TestClass()
        }else if type is TestStruct.Type {
            return TestStruct()
        }
        fatalError("provide default value for \(type)")
    }
    
    func register<T>(_ type: T.Type, _ dependency: T) {
        HelloDependency.register(type, dependency)
    }
    
    func register<T>(_ type: T.Type,
                     forIdentifier identifier: String,
                     _ dependency: T) {
        HelloDependency.register(type, forIdentifier: identifier, dependency)
    }
    
    func register<T>(_ type: T.Type, _ factory: @escaping ()->(T)) {
        HelloDependency.register(type, factory)
    }
    
    func register<T>(_ type: T.Type, forIdentifier identifier: String,
                     _ factory: @escaping ()->(T)) {
        HelloDependency.register(type, forIdentifier: identifier, factory)
    }
    
    func resolve<T>(_ type: T.Type,
                    file: StaticString = #file, line: UInt = #line) -> T? {
        return safeResolve(type, file: file, line: line) {
            HelloDependency.resolve(type)
        }
    }
    
    func resolve<T>(_ type: T.Type,
                    forIdentifier identifier: String,
                    file: StaticString = #file,
                    line: UInt = #line) -> T? {
        return safeResolve(type, file: file, line: line) {
            HelloDependency.resolve(type, forIdentifier: identifier)
        }
    }
    
    func release<T>(_ type: T.Type) {
        HelloDependency.release(type)
    }
    
    func release<T>(_ type: T.Type, forIdentifier identifier: String) {
        HelloDependency.release(type, forIdentifier: identifier)
    }
    
    func clear() {
        HelloDependency.clear()
    }
    
    enum Single {
        static func register<T>(_ type: T.Type, _ factory: @escaping ()->(T)) {
            HelloDependency.Single.register(type, factory)
        }
        static func register<T>(_ type: T.Type, forIdentifier identifier: String,
                                _ factory: @escaping ()->(T)) {
            HelloDependency.Single.register(type, forIdentifier: identifier, factory)
        }
        
        enum Weak {
            static func register<T>(_ type: T.Type, _ factory: @escaping ()->(T)) {
                HelloDependency.Single.Weak.register(type, factory)
            }
            static func register<T>(_ type: T.Type,
                                    forIdentifier identifier: String,
                                    _ factory: @escaping ()->(T)) {
                HelloDependency.Single.Weak.register(type, forIdentifier: identifier, factory)
            }
        }
    }
}
