public final class DependencyProxy {
    public typealias Command = ()->()
    private var commands: [Command] = []
    
    private var postponeCommands = false
    init(_ postponeCommands: Bool) {
        self.postponeCommands = postponeCommands
    }
    
    public weak var dependency: AnyObject? {
        didSet {
            processCommands()
        }
    }
    private func processCommands() {
        if let _ = dependency {
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
        if let _ = dependency {
            command()
        }else{
            postponeOptionally(command: command)
        }
    }
    private func postponeOptionally(command: @escaping Command) {
        guard postponeCommands && dependency == nil else { return }
        commands.append(command)
    }
}
