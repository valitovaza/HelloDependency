import UIKit
import Foundation

public protocol CellEventHandlerFactory {
    associatedtype Dependency
    func create() -> Dependency
}

public enum HelloDependencyError: Error {
    case error(String)
}
public final class CellDependencyConfigurator {
    private var cachedDependencies = [IndexPath: [String: Any]]()
    private var eventHandlers = [String: Any]()
    
    public init() {}
    
    public func set<Dependency: AnyObject, TypeToConform>(weakView: WeakBox<Dependency>, asDependencyOfType type: TypeToConform.Type, at indexPath: IndexPath) throws {
        if let weakDependency = weakView as? TypeToConform, let view = weakView.unbox {
            try setOptionally(view, weakDependency, type, indexPath)
        }else{
            throw HelloDependencyError.error("Can not register \(Dependency.self) as \(type)")
        }
    }
    private func setOptionally<View: AnyObject, Dependency>(_ view: View, _ weakDependency: Dependency, _ type: Dependency.Type, _ indexPath: IndexPath) throws {
        if cachedDependencies.values.flatMap({$0.values}).filter({$0 as AnyObject === weakDependency as AnyObject}).isEmpty {
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
        for (indexPath, dict) in cachedDependencies {
            guard let weakView = dict[identifier(for: type, indexPath: indexPath)] as? WeakBox<View> else { continue }
            guard weakView.unbox === view else { continue }
            weakView.unbox = nil
        }
    }
    private func getRegisteredWeakView<View: AnyObject, Dependency>(at indexPath: IndexPath, _ type: Dependency.Type) -> WeakBox<View>? {
        guard let dict = cachedDependencies[indexPath] else { return nil }
        guard let weakView = dict[identifier(for: type, indexPath: indexPath)] as? WeakBox<View> else { return nil }
        return weakView
    }
    private func identifier<T>(for type: T.Type, indexPath: IndexPath) -> String {
        return String.identifier(for: type) + dependencyIdentifier(for: indexPath)
    }
    private func dependencyIdentifier(for indexPath: IndexPath) -> String {
        return "\(indexPath.row)_\(indexPath.section)"
    }
    private func cache<Dependency>(_ dependency: Dependency, _ type: Dependency.Type, _ indexPath: IndexPath) {
        var dict = self.dict(for: indexPath)
        dict[identifier(for: type, indexPath: indexPath)] = dependency
        cachedDependencies[indexPath] = dict
    }
    private func dict(for indexPath: IndexPath) -> [String: Any] {
        if let dict = cachedDependencies[indexPath] {
            return dict
        }else{
            let dict = [String: AnyObject]()
            cachedDependencies[indexPath] = dict
            return dict
        }
    }
    
    public func setOnce<Dependency, TypeToConform>(dependency: Dependency, asDependencyOfType type: TypeToConform.Type, at indexPath: IndexPath) throws {
        if let dependency = dependency as? TypeToConform {
            cache(dependency, type, indexPath)
        }else{
            throw HelloDependencyError.error("Can not register \(Dependency.self) as \(type)")
        }
    }
    
    public func configure<EventHandlerHolder: CellEventHandlerHolder, Dependency: CellDependency>(dependencyHolder: EventHandlerHolder, dependencyType: Dependency.Type, at indexPath: IndexPath) throws where EventHandlerHolder.EventHandler == Dependency {
        let eventHandlerKey = identifier(for: dependencyType, indexPath: indexPath)
        if let cachedEventHandler = eventHandlers[eventHandlerKey] as? Dependency {
            dependencyHolder.set(eventHandler: cachedEventHandler)
        }else{
            if let eventHandler = Dependency.build(argContainer(for: indexPath)) {
                eventHandlers[eventHandlerKey] = eventHandler
                dependencyHolder.set(eventHandler: eventHandler)
            }else{
                throw HelloDependencyError.error("Can not build \(dependencyType) at row: \(indexPath.row) section: \(indexPath.section)")
            }
        }
    }
    private func argContainer(for indexPath: IndexPath) -> ArgsContainer {
        return ArgsContainer(cachedDependencies[indexPath] ?? [:], dependencyIdentifier(for: indexPath))
    }
}
