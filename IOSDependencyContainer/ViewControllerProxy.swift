import UIKit

public class ViewControllerProxy {
    public typealias Command = ()->()
    private var commands: [Command] = []
    
    public var rememberCommands = false
    
    public weak var viewController: UIViewController? {
        didSet {
            processCommands()
        }
    }
    private func processCommands() {
        if let _ = viewController {
            applyCommands()
        }else{
            clearCommands()
        }
    }
    private func applyCommands() {
        commands.forEach({$0()})
        clearCommands()
    }
    private func clearCommands() {
        commands.removeAll()
    }
    
    public func executeOrRemember(command: @escaping Command) {
        if let _ = viewController {
            command()
        }else{
            rememberOptionally(command: command)
        }
    }
    private func rememberOptionally(command: @escaping Command) {
        guard rememberCommands && viewController == nil else { return }
        commands.append(command)
    }
}
