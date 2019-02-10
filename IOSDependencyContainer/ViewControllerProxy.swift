import UIKit

public final class ViewControllerProxy {
    public typealias Command = ()->()
    private var commands: [Command] = []
    
    private var postponeCommands = false
    init(_ postponeCommands: Bool) {
        self.postponeCommands = postponeCommands
    }
    
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
    
    public func executeOrPostpone(command: @escaping Command) {
        if let _ = viewController {
            command()
        }else{
            postponeOptionally(command: command)
        }
    }
    private func postponeOptionally(command: @escaping Command) {
        guard postponeCommands && viewController == nil else { return }
        commands.append(command)
    }
}
