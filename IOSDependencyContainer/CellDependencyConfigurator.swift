import UIKit
import Foundation
import HDependency

public protocol CellEventHandlerFactory {
    associatedtype Dependency
    func create() -> Dependency
}
public protocol CellEventHandlerHolder {
    associatedtype EventHandler
    func set(eventHandler: EventHandler)
}
public enum HelloDependencyError: Error {
    case error(String)
}
public final class CellDependencyConfigurator {
    private let clearOnDeinit: Bool
    private var releaseBlocks = [()->()]()
    private var cachedViews = [IndexPath: [String: Any]]()
    private var registeredIdentifiers = [String]()
    
    public init(_ clearOnDeinit: Bool = true) {
        self.clearOnDeinit = clearOnDeinit
    }
    
    public func set<View: AnyObject, Dependency>(weakView: WeakBox<View>, asDependencyOfType type: Dependency.Type, at indexPath: IndexPath) throws {
        if let weakDependency = weakView as? Dependency, let view = weakView.unbox {
            registerOrChange(view, weakDependency, type, indexPath)
        }else{
            throw HelloDependencyError.error("Can not register \(View.self) as \(type)")
        }
    }
    private func registerOrChange<View: AnyObject, Dependency>(_ view: View, _ weakDependency: Dependency, _ type: Dependency.Type, _ indexPath: IndexPath) {
        nillifyAll(equalTo: view, type)
        if let weakBox: WeakBox<View> = getRegisteredWeakView(at: indexPath, type) {
            weakBox.unbox = view
        }else{
            let dependencyId = dependencyIdentifier(for: indexPath)
            HelloDependency.register(type, forIdentifier: dependencyId, weakDependency)
            releaseBlocks.append {
                HelloDependency.release(type, forIdentifier: dependencyId)
            }
            cache(weakDependency, type, indexPath)
        }
    }
    private func nillifyAll<View: AnyObject, Dependency>(equalTo view: View, _ type: Dependency.Type) {
        for (indexPath, dict) in cachedViews {
            guard let weakView = dict[identifier(for: type, indexPath: indexPath)] as? WeakBox<View> else { continue }
            guard weakView.unbox === view else { return }
            weakView.unbox = nil
        }
    }
    private func getRegisteredWeakView<View: AnyObject, Dependency>(at indexPath: IndexPath, _ type: Dependency.Type) -> WeakBox<View>? {
        guard let dict = cachedViews[indexPath] else { return nil }
        guard let weakView = dict[identifier(for: type, indexPath: indexPath)] as? WeakBox<View> else { return nil }
        return weakView
    }
    private func identifier<T>(for type: T.Type, indexPath: IndexPath) -> String {
        return String(describing: type) + dependencyIdentifier(for: indexPath)
    }
    private func dependencyIdentifier(for indexPath: IndexPath) -> String {
        return "\(indexPath.row)_\(indexPath.section)"
    }
    private func cache<Dependency>(_ weakDependency: Dependency, _ type: Dependency.Type, _ indexPath: IndexPath) {
        var dict = self.dict(for: indexPath)
        dict[identifier(for: type, indexPath: indexPath)] = weakDependency
        cachedViews[indexPath] = dict
    }
    private func dict(for indexPath: IndexPath) -> [String: Any] {
        if let dict = cachedViews[indexPath] {
            return dict
        }else{
            let dict = [String: AnyObject]()
            cachedViews[indexPath] = dict
            return dict
        }
    }
    
    public func register<Factory: CellEventHandlerFactory, Dependency>(_ factory: Factory, toCreateType: Dependency.Type, at indexPath: IndexPath) where Factory.Dependency == Dependency {
        guard canRegister(for: indexPath, toCreateType) else { return }
        markFactoryRegistered(for: indexPath, toCreateType)
        
        let dependency = factory.create()
        let dependencyId = dependencyIdentifier(for: indexPath)
        HelloDependency.register(toCreateType, forIdentifier: dependencyId, {
            dependency
        })
        releaseBlocks.append {
            HelloDependency.release(toCreateType, forIdentifier: dependencyId)
        }
    }
    private func canRegister<Dependency>(for indexPath: IndexPath, _ type: Dependency.Type) -> Bool {
        let id = identifier(for: type, indexPath: indexPath)
        return !registeredIdentifiers.contains(id)
    }
    private func markFactoryRegistered<Dependency>(for indexPath: IndexPath, _ type: Dependency.Type) {
        let id = identifier(for: type, indexPath: indexPath)
        registeredIdentifiers.append(id)
    }
    
    public func configure<EventHandlerHolder: CellEventHandlerHolder, Dependency>(dependencyHolder: EventHandlerHolder, dependencyType: Dependency.Type, at indexPath: IndexPath) where EventHandlerHolder.EventHandler == Dependency {
        dependencyHolder.set(eventHandler: HelloDependency.resolve(dependencyType, forIdentifier: dependencyIdentifier(for: indexPath)))
    }
    
    public func clear() {
        releaseBlocks.forEach({$0()})
        releaseBlocks.removeAll()
        cachedViews.removeAll()
        registeredIdentifiers.removeAll()
    }
    
    deinit {
        if clearOnDeinit {
            clear()
        }
    }
}
