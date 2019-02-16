import XCTest
import HelloDependency

class TestsWithPublicAccessToHelloDependency: TestsWithInternalAccessToHelloDependency {
    
    override func setUp() {
        reset()
    }
    
    func register<T>(_ type: T.Type, _ dependency: T) {
        HelloDependency.register(type, dependency)
    }
    
    func register<T>(_ type: T.Type,
                     for identifier: String,
                     _ dependency: T) {
        HelloDependency.register(type, forIdentifier: identifier, dependency)
    }
    
    func register<T>(_ type: T.Type, _ factory: @escaping ()->(T)) {
        HelloDependency.register(type, factory)
    }
    
    func register<T>(_ type: T.Type, for identifier: String,
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
                            for identifier: String,
                            file: StaticString = #file,
                            line: UInt = #line) -> T? {
        return safeResolve(type, file: file, line: line) {
            HelloDependency.resolve(type, forIdentifier: identifier)
        }
    }
    
    func release<T>(_ type: T.Type) {
        HelloDependency.release(type)
    }
    
    func release<T>(_ type: T.Type, for identifier: String) {
        HelloDependency.release(type, forIdentifier: identifier)
    }
    
    func clear() {
        HelloDependency.clear()
    }
}
extension TestsWithPublicAccessToHelloDependency {
    enum Single {
        static func register<T>(_ type: T.Type, _ factory: @escaping ()->(T)) {
            HelloDependency.Single.register(type, factory)
        }
        static func register<T>(_ type: T.Type, forIdentifier identifier: String,
                                _ factory: @escaping ()->(T)) {
            HelloDependency.Single
                .register(type, forIdentifier: identifier, factory)
        }
        
        enum AndWeakly {
            static func register<T>(_ type: T.Type, _ factory: @escaping ()->(T)) {
                HelloDependency.Single.AndWeakly.register(type, factory)
            }
            static func register<T>(_ type: T.Type,
                                    forIdentifier identifier: String,
                                    _ factory: @escaping ()->(T)) {
                HelloDependency.Single.AndWeakly
                    .register(type, forIdentifier: identifier, factory)
            }
        }
    }
}
