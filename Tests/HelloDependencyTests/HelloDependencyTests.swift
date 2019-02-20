import XCTest
@testable import HelloDependency

class HelloDependencyTests: XCTestCase {
    
    private static var actions: [Action] = []
    
    override static func setUp() {
        assertContainerIsEqualToHelloDependencyContainer()
        assertSingleContainerIsEqualToHelloDependencyContainerSingle()
        assertWeakContainerIsEqualToDependencyContainerSingleWeak()
        assertDependencyManagerIsEqualToDependencyProxyManager()
        
        HelloDependency.container = HelloDependencyContainerProtocolSpy.self
        HelloDependency.singleContainer = HelloDependencySingleContainerProtocolSpy.self
        HelloDependency.weakContainer = HelloDependencyWeakContainerProtocolSpy.self
        HelloDependency.dependencyManager = DependencyProxyManagerProtocolSpy.self
    }
    private static func assertContainerIsEqualToHelloDependencyContainer(file: StaticString = #file, line: UInt = #line) {
        XCTAssertTrue(HelloDependency.container == HelloDependencyContainer.self, file: file, line: line)
    }
    private static func assertSingleContainerIsEqualToHelloDependencyContainerSingle(file: StaticString = #file, line: UInt = #line) {
        XCTAssertTrue(HelloDependency.singleContainer == HelloDependencyContainer.Single.self, file: file, line: line)
    }
    private static func assertWeakContainerIsEqualToDependencyContainerSingleWeak() {
        XCTAssertTrue(HelloDependency.weakContainer == HelloDependencyContainer.Single.Weak.self)
    }
    private static func assertDependencyManagerIsEqualToDependencyProxyManager() {
        XCTAssertTrue(HelloDependency.dependencyManager == DependencyProxyManager.self)
    }
    
    override func setUp() {
        HelloDependencyTests.actions = []
    }
    
    private let sut = HelloDependency.self
    
    func test_register_invokesContainersRegister() {
        sut.register(Int.self, 45)
        
        XCTAssertEqual(actionTypes, [.register])
        XCTAssertEqual(dependencies(), [45])
        XCTAssertEqual(typeDesciptions, ["Int"])
    }
    private var actionTypes: [ActionType] {
        return actions.map({$0.type})
    }
    private var actions: [Action] {
        return HelloDependencyTests.actions
    }
    private func dependencies<T>() -> [T] {
        return actions.compactMap({$0.dependency as? T})
    }
    private var typeDesciptions: [String] {
        return actions.compactMap({$0.typeDesciption})
    }
    
    func test_resolve_invokesContainersResolve() {
        setValueForResolve(33)
        let dependency = HelloDependency.resolve(Int.self)
        
        XCTAssertEqual(actionTypes, [.resolve])
        XCTAssertEqual(dependency, 33)
        XCTAssertEqual(typeDesciptions, ["Int"])
    }
    private func setValueForResolve(_ value: Any) {
        HelloDependencyContainerProtocolSpy.testValue = value
    }
    
    func test_release_invokesContainersRelease() {
        sut.release(Double.self)
        
        XCTAssertEqual(actionTypes, [.release])
        XCTAssertEqual(typeDesciptions, ["Double"])
    }
    
    func test_clear_invokesContainersClear() {
        sut.clear()
        
        XCTAssertEqual(actionTypes, [.clear])
    }
    
    func test_registerForIdentifier_invokesContainersRegisterForIdentifier() {
        sut.register(String.self, forIdentifier: "testId", "testValue")
        
        XCTAssertEqual(actionTypes, [.registerForIdentifier])
        XCTAssertEqual(dependencies(), ["testValue"])
        XCTAssertEqual(identifiers, ["testId"])
        XCTAssertEqual(typeDesciptions, ["String"])
    }
    private var identifiers: [String] {
        return actions.compactMap({$0.identifier})
    }
    
    func test_resolveForIdentifier_invokesContainersResolveForIdentifier() {
        setValueForResolve("testValue")
        let dependency = sut.resolve(String.self, forIdentifier: "testId")
        
        XCTAssertEqual(actionTypes, [.resolveForIdentifier])
        XCTAssertEqual(typeDesciptions, ["String"])
        XCTAssertEqual(identifiers, ["testId"])
        XCTAssertEqual(dependency, "testValue")
    }
    
    func test_releaseForIdentifier_invokesContainersReleaseForIdentifier() {
        sut.release(Float.self, forIdentifier: "testId")
        
        XCTAssertEqual(actionTypes, [.releaseForIdentifier])
        XCTAssertEqual(identifiers, ["testId"])
        XCTAssertEqual(typeDesciptions, ["Float"])
    }
    
    func test_registerFactory_invokesContainersRegisterFactry() {
        var factoryCallCount = 0
        sut.register(Int.self, {
            factoryCallCount += 1
            return 45
        })
        
        XCTAssertEqual(actionTypes, [.registerFactory])
        XCTAssertEqual(typeDesciptions, ["Int"])
        XCTAssertEqual(invokeFactory(),  45)
        XCTAssertEqual(factoryCallCount, 1)
    }
    private func invokeFactory<T>(file: StaticString = #file, line: UInt = #line) -> T? {
        let factories = actions.compactMap({$0.factory})
        if factories.count == 1 {
            return factories.first?() as? T
        }else if factories.isEmpty{
            XCTFail("No registered factory", file: file, line: line)
        }else {
            XCTFail("More than one factory registered", file: file, line: line)
        }
        return nil
    }
    
    func test_registerFactoryForIdentifier_invokesContainersRegisterFactoryForIdentifier() {
        var factoryCallCount = 0
        sut.register(Double.self, forIdentifier: "testId", {
            factoryCallCount += 1
            return 4.67
        })
        
        XCTAssertEqual(actionTypes, [.registerFactoryForIdentifier])
        XCTAssertEqual(typeDesciptions, ["Double"])
        XCTAssertEqual(invokeFactory(),  4.67)
        XCTAssertEqual(identifiers, ["testId"])
        XCTAssertEqual(factoryCallCount, 1)
    }
    
    func test_singleRegister_invokesContainersSingleRegister() {
        var factoryCallCount = 0
        sut.Single.register(String.self, {
            factoryCallCount += 1
            return "testValue"
        })
        
        XCTAssertEqual(actionTypes, [.singleRegister])
        XCTAssertEqual(typeDesciptions, ["String"])
        XCTAssertEqual(invokeFactory(), "testValue")
        XCTAssertEqual(factoryCallCount, 1)
    }
    
    func test_singleRegisterForIdentifier_invokesContainersSingleRegisterForIdentifier() {
        var factoryCallCount = 0
        sut.Single.register(String.self, forIdentifier: "testId", {
            factoryCallCount += 1
            return "testValue"
        })
        
        XCTAssertEqual(actionTypes, [.singleRegisterForIdentifier])
        XCTAssertEqual(typeDesciptions, ["String"])
        XCTAssertEqual(identifiers, ["testId"])
        XCTAssertEqual(invokeFactory(), "testValue")
        XCTAssertEqual(factoryCallCount, 1)
    }
    
    func test_weakRegister_invokesContainersWeakRegister() {
        var factoryCallCount = 0
        sut.Single.Weak.register(Int.self, {
            factoryCallCount += 1
            return 9
        })
        
        XCTAssertEqual(actionTypes, [.weakRegister])
        XCTAssertEqual(typeDesciptions, ["Int"])
        XCTAssertEqual(invokeFactory(), 9)
        XCTAssertEqual(factoryCallCount, 1)
    }
    
    func test_weakRegisterForIdentifier_invokesContainersWeakRegisterForIdentifier() {
        var factoryCallCount = 0
        sut.Single.Weak.register(Double.self, forIdentifier: "testId", {
            factoryCallCount += 1
            return 9.45
        })
        
        XCTAssertEqual(actionTypes, [.weakRegisterForIdentifier])
        XCTAssertEqual(typeDesciptions, ["Double"])
        XCTAssertEqual(identifiers, ["testId"])
        XCTAssertEqual(invokeFactory(), 9.45)
        XCTAssertEqual(factoryCallCount, 1)
    }
    
    func test_createProxy_returnsProxyFromDependencyManager() {
        let proxy = sut.createProxy(for: Int.self, identifier: "testId", postponeCommands: false)
        
        XCTAssertTrue(proxy === dependencyManagerSpy.createdProxy)
        XCTAssertEqual(actionTypes, [.createProxy])
        XCTAssertEqual(identifiers, ["testId"])
        XCTAssertEqual(typeDesciptions, ["Int"])
        XCTAssertEqual(postponeCommands, [false])
    }
    private var dependencyManagerSpy: DependencyProxyManagerProtocolSpy.Type {
        return DependencyProxyManagerProtocolSpy.self
    }
    private var postponeCommands: [Bool] {
        return actions.compactMap({$0.postponeCommands})
    }
    
    func test_createProxy_sendDefaultEmptyString() {
        _ = sut.createProxy(for: Int.self, postponeCommands: true)
        
        XCTAssertEqual(actionTypes, [.createProxy])
        XCTAssertEqual(identifiers, [""])
        XCTAssertEqual(postponeCommands, [true])
    }
    
    func test_createProxy_sendDefaultPostponeCommandsTrue() {
        _ = sut.createProxy(for: Int.self)
        
        XCTAssertEqual(actionTypes, [.createProxy])
        XCTAssertEqual(postponeCommands, [true])
    }
    
    func test_dependencyReady_invokesDependencyManagersDependencyReady() {
        let dependency = DependencyClass()
        sut.dependencyReady(dependency, identifier: "testId")
        
        XCTAssertEqual(actionTypes, [.dependencyReady])
        XCTAssertEqual(dependencies(), [dependency])
        XCTAssertEqual(identifiers, ["testId"])
    }
    class DependencyClass: Equatable {
        static func == (lhs: HelloDependencyTests.DependencyClass, rhs: HelloDependencyTests.DependencyClass) -> Bool {
            return lhs === rhs
        }
    }
    
    func test_dependencyReady_sendDefaultEmptyIdentifier() {
        sut.dependencyReady(DependencyClass())
        
        XCTAssertEqual(actionTypes, [.dependencyReady])
        XCTAssertEqual(identifiers, [""])
    }
}
extension HelloDependencyTests {
    enum ActionType {
        case register
        case resolve
        case release
        case clear
        case registerForIdentifier
        case resolveForIdentifier
        case releaseForIdentifier
        case registerFactory
        case registerFactoryForIdentifier
        
        case singleRegister
        case singleRegisterForIdentifier
        
        case weakRegister
        case weakRegisterForIdentifier
        
        case createProxy
        case dependencyReady
    }
    struct Action {
        let type: ActionType
        let typeDesciption: String?
        let dependency: Any?
        let factory: (()->(Any))?
        let identifier: String?
        let postponeCommands: Bool?
        init(type: ActionType,
             typeDesciption: String? = nil,
             dependency: Any? = nil,
             factory: (()->(Any))? = nil,
             identifier: String? = nil,
             postponeCommands: Bool? = nil) {
            self.type = type
            self.typeDesciption = typeDesciption
            self.dependency = dependency
            self.factory = factory
            self.identifier = identifier
            self.postponeCommands = postponeCommands
        }
    }
    class HelloDependencyContainerProtocolSpy: HelloDependencyContainerProtocol {
        static var testValue: Any?
        
        static func register<T>(_ type: T.Type, _ dependency: T) {
            actions.append(Action(type: .register, typeDesciption: String(describing: type), dependency: dependency))
        }
        static func resolve<T>(_ type: T.Type) -> T {
            actions.append(Action(type: .resolve, typeDesciption: String(describing: type)))
            return testValue! as! T
        }
        static func release<T>(_ type: T.Type) {
            actions.append(Action(type: .release, typeDesciption: String(describing: type)))
        }
        static func clear() {
            actions.append(Action(type: .clear))
        }
        
        static func register<T>(_ type: T.Type, forIdentifier identifier: Indentifier, _ dependency: T) {
            actions.append(Action(type: .registerForIdentifier, typeDesciption: String(describing: type), dependency: dependency, identifier: identifier))
        }
        static func resolve<T>(_ type: T.Type, forIdentifier identifier: Indentifier) -> T {
            actions.append(Action(type: .resolveForIdentifier, typeDesciption: String(describing: type), identifier: identifier))
            return testValue! as! T
        }
        static func release<T>(_ type: T.Type, forIdentifier identifier: Indentifier) {
            actions.append(Action(type: .releaseForIdentifier, typeDesciption: String(describing: type), identifier: identifier))
        }
        
        static func register<T>(_ type: T.Type, _ factory: @escaping ()->(T)) {
            actions.append(Action(type: .registerFactory, typeDesciption: String(describing: type), factory: factory))
        }
        static func register<T>(_ type: T.Type, forIdentifier identifier: Indentifier, _ factory: @escaping ()->(T)) {
            actions.append(Action(type: .registerFactoryForIdentifier, typeDesciption: String(describing: type), factory: factory, identifier: identifier))
        }
    }
    class HelloDependencySingleContainerProtocolSpy: HelloDependencySingleContainerProtocol {
        static func register<T>(_ type: T.Type, _ factory: @escaping ()->(T)) {
            actions.append(Action(type: .singleRegister, typeDesciption: String(describing: type), factory: factory))
        }
        static func register<T>(_ type: T.Type, forIdentifier identifier: Indentifier, _ factory: @escaping ()->(T)) {
            actions.append(Action(type: .singleRegisterForIdentifier, typeDesciption: String(describing: type), factory: factory, identifier: identifier))
        }
    }
    class HelloDependencyWeakContainerProtocolSpy: HelloDependencyWeakContainerProtocol {
        static func register<T>(_ type: T.Type, _ factory: @escaping ()->(T)) {
            actions.append(Action(type: .weakRegister, typeDesciption: String(describing: type), factory: factory))
        }
        static func register<T>(_ type: T.Type, forIdentifier identifier: Indentifier, _ factory: @escaping ()->(T)) {
            actions.append(Action(type: .weakRegisterForIdentifier, typeDesciption: String(describing: type), factory: factory, identifier: identifier))
        }
    }
    class DependencyProxyManagerProtocolSpy: DependencyProxyManagerProtocol {
        static var createdProxy = DependencyProxy(false)
        static func createProxy<T>(for type: T.Type, identifier: Identifier, postponeCommands: Bool) -> DependencyProxy {
            actions.append(Action(type: .createProxy, typeDesciption: String(describing: type), identifier: identifier, postponeCommands: postponeCommands))
            return createdProxy
        }
        static func dependencyReady<T: AnyObject>(_ dependency: T, identifier: Identifier) {
            actions.append(Action(type: .dependencyReady, dependency: dependency, identifier: identifier))
        }
    }
}
