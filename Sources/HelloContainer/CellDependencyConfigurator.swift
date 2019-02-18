import UIKit
import Foundation

public enum CellDependencyConfiguratorError: Error {
    case error(String)
}
public final class CellDependencyConfigurator {
    private var cachedArguments = [IndexPath: [String: Any]]()
    private var cachedDependencies = [String: Any]()
    
    public init() {}
    
    public func set<Argument: AnyObject, TypeToConform>(weakArgument: WeakBox<Argument>, asType type: TypeToConform.Type, at indexPath: IndexPath) throws {
        if let weakArg = weakArgument as? TypeToConform, let argument = weakArgument.unbox {
            try setOptionally(argument, weakArg, type, indexPath)
        }else{
            throw CellDependencyConfiguratorError.error(errorText(for: weakArgument, typeToConform: type))
        }
    }
    private func setOptionally<Argument: AnyObject, TypeToConform>(_ argument: Argument, _ weakArgument: TypeToConform, _ type: TypeToConform.Type, _ indexPath: IndexPath) throws {
        if cachedArguments.values.flatMap({$0.values}).filter({$0 as AnyObject === weakArgument as AnyObject}).isEmpty {
            set(argument, weakArgument, type, indexPath)
        }else{
            throw CellDependencyConfiguratorError.error("Can not use same WeakArgument multiple times")
        }
    }
    private func set<Argument: AnyObject, TypeToConform>(_ argument: Argument, _ weakArgument: TypeToConform, _ type: TypeToConform.Type, _ indexPath: IndexPath) {
        removeAllReferences(equalTo: argument, type)
        if let weakBox: WeakBox<Argument> = getRegisteredWeakArgument(at: indexPath, type) {
            weakBox.unbox = argument
        }else{
            cache(weakArgument, type, indexPath)
        }
    }
    private func removeAllReferences<Argument: AnyObject, TypeToConform>(equalTo argument: Argument, _ type: TypeToConform.Type) {
        for (indexPath, dict) in cachedArguments {
            guard let weakArg = dict[identifier(for: type, indexPath: indexPath)] as? WeakBox<Argument> else { continue }
            guard weakArg.unbox === argument else { continue }
            weakArg.unbox = nil
        }
    }
    private func getRegisteredWeakArgument<Argument: AnyObject, TypeToConform>(at indexPath: IndexPath, _ type: TypeToConform.Type) -> WeakBox<Argument>? {
        guard let dict = cachedArguments[indexPath] else { return nil }
        guard let weakArg = dict[identifier(for: type, indexPath: indexPath)] as? WeakBox<Argument> else { return nil }
        return weakArg
    }
    private func identifier<T>(for type: T.Type, indexPath: IndexPath) -> String {
        return String.identifier(for: type) + dependencyIdentifier(for: indexPath)
    }
    private func dependencyIdentifier(for indexPath: IndexPath) -> String {
        return "\(indexPath.row)_\(indexPath.section)"
    }
    private func cache<Argument>(_ argument: Argument, _ type: Argument.Type, _ indexPath: IndexPath) {
        var dict = self.dict(for: indexPath)
        dict[identifier(for: type, indexPath: indexPath)] = argument
        cachedArguments[indexPath] = dict
    }
    private func dict(for indexPath: IndexPath) -> [String: Any] {
        if let dict = cachedArguments[indexPath] {
            return dict
        }else{
            let dict = [String: AnyObject]()
            cachedArguments[indexPath] = dict
            return dict
        }
    }
    private func errorText<Argument, TypeToConform>(for argument: Argument, typeToConform: TypeToConform.Type) -> String {
        return "Can not register \(Argument.self) as \(typeToConform)"
    }
    
    public func setOnceOptionally<Argument, TypeToConform>(argument: Argument, asDependencyOfType type: TypeToConform.Type, at indexPath: IndexPath) throws {
        if let dependency = argument as? TypeToConform {
            cache(dependency, type, indexPath)
        }else{
            throw CellDependencyConfiguratorError.error(errorText(for: argument, typeToConform: type))
        }
    }
    
    public func buildDependency<DependencyHolder: CellDependencyHolder, Dependency: CellDependency>(for dependencyHolder: DependencyHolder, dependencyType: Dependency.Type, at indexPath: IndexPath) throws where DependencyHolder.CellDependency == Dependency {
        let dependencyKey = identifier(for: dependencyType, indexPath: indexPath)
        if let cachedEventHandler = cachedDependencies[dependencyKey] as? Dependency {
            dependencyHolder.set(cellDependency: cachedEventHandler)
        }else{
            if let eventHandler = Dependency.build(argumentsContainer(for: indexPath)) {
                cachedDependencies[dependencyKey] = eventHandler
                dependencyHolder.set(cellDependency: eventHandler)
            }else{
                throw CellDependencyConfiguratorError.error("Can not build \(dependencyType) at row: \(indexPath.row) section: \(indexPath.section)")
            }
        }
    }
    private func argumentsContainer(for indexPath: IndexPath) -> ArgumentsContainer {
        return ArgumentsContainer(cachedArguments[indexPath] ?? [:], dependencyIdentifier(for: indexPath))
    }
}
