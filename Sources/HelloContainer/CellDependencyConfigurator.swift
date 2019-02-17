import UIKit
import Foundation

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
    private var cachedViews = [IndexPath: [String: Any]]()
    private var registeredEventHandlers = [String: Any]()
    
    public init() {}
    
    public func set<View: AnyObject, Dependency>(weakView: WeakBox<View>, asDependencyOfType type: Dependency.Type, at indexPath: IndexPath) throws {
        if let weakDependency = weakView as? Dependency, let view = weakView.unbox {
            try setOptionally(view, weakDependency, type, indexPath)
        }else{
            throw HelloDependencyError.error("Can not register \(View.self) as \(type)")
        }
    }
    private func setOptionally<View: AnyObject, Dependency>(_ view: View, _ weakDependency: Dependency, _ type: Dependency.Type, _ indexPath: IndexPath) throws {
        if cachedViews.values.flatMap({$0.values}).filter({$0 as AnyObject === weakDependency as AnyObject}).isEmpty {
            set(view, weakDependency, type, indexPath)
        }else{
            throw HelloDependencyError.error("Can not use same Weakview multiple times")
        }
    }
    private func set<View: AnyObject, Dependency>(_ view: View, _ weakDependency: Dependency, _ type: Dependency.Type, _ indexPath: IndexPath) {
        nillifyAll(equalTo: view, type)
        if let weakBox: WeakBox<View> = getRegisteredWeakView(at: indexPath, type) {
            weakBox.unbox = view
        }else{
            cache(weakDependency, type, indexPath)
        }
    }
    private func nillifyAll<View: AnyObject, Dependency>(equalTo view: View, _ type: Dependency.Type) {
        for (indexPath, dict) in cachedViews {
            guard let weakView = dict[identifier(for: type, indexPath: indexPath)] as? WeakBox<View> else { continue }
            guard weakView.unbox === view else { continue }
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
    
    public func register<Factory: CellEventHandlerFactory, Dependency>(_ factory: Factory, toCreateType type: Dependency.Type, at indexPath: IndexPath) where Factory.Dependency == Dependency {
        guard canRegister(for: indexPath, type) else { return }
        cacheRegisteredEventHandler(eventHandler: factory.create(), for: indexPath, type)
    }
    private func canRegister<Dependency>(for indexPath: IndexPath, _ type: Dependency.Type) -> Bool {
        let identifier = self.identifier(for: type, indexPath: indexPath)
        return registeredEventHandlers[identifier] == nil
    }
    private func cacheRegisteredEventHandler<Dependency>(eventHandler: Any, for indexPath: IndexPath, _ type: Dependency.Type) {
        let identifier = self.identifier(for: type, indexPath: indexPath)
        registeredEventHandlers[identifier] = eventHandler
    }
    
    public func configure<EventHandlerHolder: CellEventHandlerHolder, Dependency>(dependencyHolder: EventHandlerHolder, dependencyType: Dependency.Type, at indexPath: IndexPath) throws where EventHandlerHolder.EventHandler == Dependency {
        let identifier = self.identifier(for: dependencyType, indexPath: indexPath)
        if let eventHandler = registeredEventHandlers[identifier] as? Dependency {
            dependencyHolder.set(eventHandler: eventHandler)
        }else{
            throw HelloDependencyError.error("\(dependencyType) dependency is not registered at row: \(indexPath.row) section: \(indexPath.section)")
        }
    }
}
