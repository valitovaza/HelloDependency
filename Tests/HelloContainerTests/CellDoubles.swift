import HelloContainer

protocol FirstViewProtocol {
    func firstViewMethod()
}
protocol SecondViewProtocol {
    func secondViewMethod()
}
protocol DifferentProtocol {}

class Cell {
    var firstViewMethodCallCount = 0
    var secondViewMethodCallCount = 0
    var eventHandler: EventHandler?
}
extension Cell: CellDependencyHolder {
    func set(cellDependency: EventHandler) {
        self.eventHandler = cellDependency
    }
}
extension Cell: FirstViewProtocol {
    func firstViewMethod() {
        firstViewMethodCallCount += 1
    }
}
extension Cell: SecondViewProtocol {
    func secondViewMethod() {
        secondViewMethodCallCount += 1
    }
}
class EventHandler {
    let firstEventHandlerDependency: FirstEventHandlerDependency
    let secondEventHandlerDependency: SecondEventHandlerDependency
    let view: FirstViewProtocol
    let secondView: SecondViewProtocol
    init(_ firstEventHandlerDependency: FirstEventHandlerDependency,
         _ secondEventHandlerDependency: SecondEventHandlerDependency,
         _ view: FirstViewProtocol,
         _ secondView: SecondViewProtocol) {
        self.firstEventHandlerDependency = firstEventHandlerDependency
        self.secondEventHandlerDependency = secondEventHandlerDependency
        self.view = view
        self.secondView = secondView
    }
    
    func triggerFirstViewMethod() {
        view.firstViewMethod()
    }
    
    func triggerSecondViewMethod() {
        secondView.secondViewMethod()
    }
    
    func triggerFirstTestMethod() {
        firstEventHandlerDependency.firstTestMethod()
    }
    
    func triggerSecondTestMethod() {
        secondEventHandlerDependency.secondTestMethod()
    }
}
protocol FirstEventHandlerDependency {
    func firstTestMethod()
}
protocol SecondEventHandlerDependency {
    func secondTestMethod()
}
class EventHandlerDependency: FirstEventHandlerDependency, SecondEventHandlerDependency {
    var firstTestMethodCallCount = 0
    var secondTestMethodCallCount = 0
    
    func firstTestMethod() {
        firstTestMethodCallCount += 1
    }
    func secondTestMethod() {
        secondTestMethodCallCount += 1
    }
}

extension EventHandler: CellDependency {
    static func build(_ container: ArgumentsContainer) -> EventHandler? {
        guard let view = container.getArgument(ofType: FirstViewProtocol.self) else { return nil}
        guard let secondView = container.getArgument(ofType: SecondViewProtocol.self) else { return nil}
        guard let firstEventHandlerDependency = container.getArgument(ofType: FirstEventHandlerDependency.self) else { return nil}
        guard let secondEventHandlerDependency = container.getArgument(ofType: SecondEventHandlerDependency.self) else { return nil}
        return EventHandler(firstEventHandlerDependency, secondEventHandlerDependency, view, secondView)
    }
}

class SecondCell {
    var secondEventHandler: SecondEventHandler!
}
extension SecondCell: CellDependencyHolder {
    func set(cellDependency: SecondEventHandler) {
        secondEventHandler = cellDependency
    }
}
class SecondEventHandler {}
extension SecondEventHandler: CellDependency {
    static func build(_ container: ArgumentsContainer) -> SecondEventHandler? {
        return SecondEventHandler()
    }
}

extension WeakBox: FirstViewProtocol where A: FirstViewProtocol {
    func firstViewMethod() {
        unbox?.firstViewMethod()
    }
}
extension WeakBox: SecondViewProtocol where A: SecondViewProtocol {
    func secondViewMethod() {
        unbox?.secondViewMethod()
    }
}
