import XCTest
@testable import HDependency

class TestsWithInternalAccessToHelloDependency: XCTestCase {
    
    class TestClass {}
    struct TestStruct: Equatable {}
    
    override func setUp() {
        reset()
    }
    
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
        HelloDependency.changeResolveFatalError(defaultValue(for: type)) { (msg) in
            XCTAssertEqual(msg, expectedMessage, file: file, line: line)
            exp.fulfill()
        }
        _ = factory()
        waitForExpectations(timeout: 1.0) { (error) in
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
            HelloDependency.resolve(type, for: identifier)
        }
    }
    
    func safeResolve<T>(_ type: T.Type,
                                file: StaticString = #file,
                                line: UInt = #line,
                                _ factory: ()->(T)) -> T? {
        var fatalErrorOccured = false
        HelloDependency.changeResolveFatalError(defaultValue(for: type)) { (_) in
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
    
    func assertWeakRef(message: String? = nil,
                       registerBlock: (TestClass)->(),
                       _ file: StaticString = #file,
                       _ line: UInt = #line,
                       actionBlock: ()->()) {
        weak var weakObj: TestClass?
        var obj: TestClass? = TestClass()
        weakObj = obj
        
        registerBlock(obj!)
        
        actionBlock()
        obj = nil
        
        if let message = message {
            XCTAssertNil(weakObj, message, file: file, line: line)
        }else{
            XCTAssertNil(weakObj, file: file, line: line)
        }
    }
}
