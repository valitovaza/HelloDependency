import UIKitDependencyHelper
import HelloDependency

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
    var dependency: FirstCellDependency?
}
extension Cell: CellDependencyHolder {
    func set(cellDependency: FirstCellDependency) {
        self.dependency = cellDependency
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
class FirstCellDependency {
    let firstArgument: FirstArgument
    let secondArgument: SecondArgument
    let firstView: FirstViewProtocol
    let secondView: SecondViewProtocol
    init(_ firstArgument: FirstArgument,
         _ secondArgument: SecondArgument,
         _ firstView: FirstViewProtocol,
         _ secondView: SecondViewProtocol) {
        self.firstArgument = firstArgument
        self.secondArgument = secondArgument
        self.firstView = firstView
        self.secondView = secondView
    }
    
    func triggerFirstViewMethod() {
        firstView.firstViewMethod()
    }
    
    func triggerSecondViewMethod() {
        secondView.secondViewMethod()
    }
    
    func triggerFirstTestMethod() {
        firstArgument.firstArgumentMethod()
    }
    
    func triggerSecondTestMethod() {
        secondArgument.secondArgumentMethod()
    }
}
protocol FirstArgument {
    func firstArgumentMethod()
}
protocol SecondArgument {
    func secondArgumentMethod()
}
class DependencyArgument: FirstArgument, SecondArgument {
    var firstArgumentMethodCallCount = 0
    var secondArgumentMethodCallCount = 0
    
    func firstArgumentMethod() {
        firstArgumentMethodCallCount += 1
    }
    func secondArgumentMethod() {
        secondArgumentMethodCallCount += 1
    }
}

extension FirstCellDependency: CellDependency {
    static func build(_ container: ArgumentsContainer) -> FirstCellDependency? {
        guard let view = container.getArgument(ofType: FirstViewProtocol.self) else { return nil}
        guard let secondView = container.getArgument(ofType: SecondViewProtocol.self) else { return nil}
        guard let firstEventHandlerDependency = container.getArgument(ofType: FirstArgument.self) else { return nil}
        guard let secondEventHandlerDependency = container.getArgument(ofType: SecondArgument.self) else { return nil}
        return FirstCellDependency(firstEventHandlerDependency, secondEventHandlerDependency, view, secondView)
    }
}

class SecondCell {
    var dependency: SecondCellDependency!
}
extension SecondCell: CellDependencyHolder {
    func set(cellDependency: SecondCellDependency) {
        dependency = cellDependency
    }
}
class SecondCellDependency {}
extension SecondCellDependency: CellDependency {
    static func build(_ container: ArgumentsContainer) -> SecondCellDependency? {
        return SecondCellDependency()
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
