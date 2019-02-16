import XCTest
import HelloDependency
import HelloContainer

class CellDependencyConfiguratorTests: XCTestCase {
    
    let indexPath = IndexPath(row: 0, section: 0)
    
    func test_set_throwsErrorIfCellDoesNotConformToSentProtocol() {
        let sut = makeSUT()
        let (cell,_) = makeCellAndFactory()
        
        XCTAssertThrowsError(try sut.set(weakView: WeakBox(cell), asDependencyOfType: DifferentProtocol.self, at: indexPath)) { (error) in
            if case HelloDependencyError.error(let errorString) = error {
                XCTAssertEqual(errorString, "Can not register Cell as DifferentProtocol")
            }else{
                XCTFail("wrong error")
            }
        }
    }
    private func makeSUT(_ clearOnDeinit: Bool = true, file: StaticString = #file, line: UInt = #line) -> CellDependencyConfigurator {
        let sut = CellDependencyConfigurator()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    private func makeCellAndFactory(file: StaticString = #file, line: UInt = #line) -> (Cell, EventHandlerFactory) {
        let cell = Cell()
        let factory = EventHandlerFactory(cell)
        trackForMemoryLeaks(factory, file: file, line: line)
        trackForMemoryLeaks(cell, file: file, line: line)
        trackForMemoryLeaks(factory, file: file, line: line)
        return (cell, factory)
    }
    
    func test_set_doesNotThrowErrorIfCellConformsToSentProtocol() {
        let sut = makeSUT()
        let (cell,_) = makeCellAndFactory()
        
        XCTAssertNoThrow(try sut.set(weakView: WeakBox(cell), asDependencyOfType: View.self, at: indexPath))
    }
    
    func test_configure_setsEventHandlerFromRegisteredFactory() {
        let (_,cell,factory, _) = configureCell()
        
        XCTAssertTrue(cell.eventHandler === factory.createdEventHandler)
    }
    private func configureCell(_ indexPath: IndexPath = IndexPath(row: 0, section: 0), _ file: StaticString = #file, _ line: UInt = #line) -> (CellDependencyConfigurator, Cell, EventHandlerFactory, WeakBox<Cell>) {
        let sut = makeSUT(file: file, line: line)
        let (cell,factory) = makeCellAndFactory(file: file, line: line)
        let weakBox = WeakBox(cell)
        trackForMemoryLeaks(weakBox, file: file, line: line)
        XCTAssertNoThrow(try sut.set(weakView: weakBox, asDependencyOfType: View.self, at: indexPath), file: file, line: line)
        sut.register(factory, toCreateType: EventHandler.self, at: indexPath)
        XCTAssertNoThrow(try sut.configure(dependencyHolder: cell, dependencyType: EventHandler.self, at: indexPath))
        return (sut, cell, factory, weakBox)
    }
    
    func test_set_updatesCurrentViewForIndexPath() {
        let (sut,_,_, weakBox0) = configureCell(indexPath)
        
        let (cell1,_) = makeCellAndFactory()
        XCTAssertNoThrow(try sut.set(weakView: WeakBox(cell1), asDependencyOfType: View.self, at: indexPath))

        XCTAssertTrue(weakBox0.unbox === cell1)
    }
    
    func test_set_doesNotUpdatesViewForDifferentIndex() {
        let (sut,_,_, weakBox0) = configureCell(IndexPath(row: 0, section: 0))
        
        let (cell1,_) = makeCellAndFactory()
        XCTAssertNoThrow(try sut.set(weakView: WeakBox(cell1), asDependencyOfType: View.self, at: IndexPath(row: 4, section: 6)))
        
        XCTAssertTrue(weakBox0.unbox !== cell1)
    }
    
    func test_set_doesNotUpdatesViewForOtherProtocol() {
        let (sut,cell,_, weakBox0) = configureCell(indexPath)
        
        let (cell1,_) = makeCellAndFactory()
        XCTAssertNoThrow(try sut.set(weakView: WeakBox(cell1), asDependencyOfType: CellView.self, at: indexPath))
        
        XCTAssertTrue(weakBox0.unbox === cell)
    }
    
    func test_set_onDifferentIndexRemovesSameViewFromOtherDependencies() {
        let indexPath0 = IndexPath(row: 0, section: 0)
        let indexPath1 = IndexPath(row: 2, section: 1)
        let (sut,cell,_, weakBox0) = configureCell(indexPath0)
        
        let differentCell = Cell()
        let differentWeakBox = WeakBox(differentCell)
        XCTAssertNoThrow(try sut.set(weakView: differentWeakBox, asDependencyOfType: CellView.self, at: indexPath1))
        
        let weakBox1 = WeakBox(cell)
        XCTAssertNoThrow(try sut.set(weakView: weakBox1, asDependencyOfType: CellView.self, at: indexPath0))
        
        XCTAssertNoThrow(try sut.set(weakView: WeakBox(cell), asDependencyOfType: CellView.self, at: indexPath1))
        XCTAssertNoThrow(try sut.set(weakView: WeakBox(cell), asDependencyOfType: View.self, at: indexPath1))
        
        XCTAssertNil(weakBox0.unbox)
        XCTAssertNil(weakBox1.unbox)
    }
    
    func test_set_onDifferentIndexDoesNotRemovesOtherViews() {
        let sut = makeSUT()
        let cell0 = Cell()
        let weakBox0 = WeakBox(cell0)
        XCTAssertNoThrow(try sut.set(weakView: weakBox0, asDependencyOfType: View.self, at: IndexPath(row: 0, section: 0)))
        
        let cell1 = Cell()
        let weakBox1 = WeakBox(cell1)
        XCTAssertNoThrow(try sut.set(weakView: weakBox1, asDependencyOfType: View.self, at: IndexPath(row: 1, section: 1)))
        
        XCTAssertNotNil(weakBox0.unbox)
    }
    
    func test_set_doesNotRemoveSameObjectInOtherDependencyIfProtoIsNotSame() {
        let (sut,cell,_, weakBox0) = configureCell(IndexPath(row: 0, section: 0))
        
        XCTAssertNoThrow(try sut.set(weakView: WeakBox(cell), asDependencyOfType: CellView.self, at: IndexPath(row: 2, section: 1)))
        
        XCTAssertTrue(weakBox0.unbox === cell)
    }
    
    func test_register_createsAnotherEventHandlerForDifferentIndexPaths() {
        let (factory, eventHandler0, eventHandler1) = configure(at: IndexPath(row: 0, section: 0), secondIndexPath: IndexPath(row: 1, section: 1))
        
        XCTAssertEqual(factory.createCallCount, 2)
        XCTAssertNotNil(eventHandler0)
        XCTAssertTrue(eventHandler0 !== eventHandler1)
    }
    private func configure(at indexPath: IndexPath, secondIndexPath: IndexPath, _ file: StaticString = #file, _ line: UInt = #line) -> (EventHandlerFactory, EventHandler?, EventHandler?) {
        let sut = makeSUT(file: file, line: line)
        let (cell,factory) = makeCellAndFactory(file: file, line: line)
        XCTAssertNoThrow(try sut.set(weakView: WeakBox(cell), asDependencyOfType: View.self, at: indexPath))
        sut.register(factory, toCreateType: EventHandler.self, at: indexPath)
        XCTAssertNoThrow(try sut.configure(dependencyHolder: cell, dependencyType: EventHandler.self, at: indexPath))
        let eventHandler0 = cell.eventHandler
        
        sut.register(factory, toCreateType: EventHandler.self, at: secondIndexPath)
        XCTAssertNoThrow(try sut.configure(dependencyHolder: cell, dependencyType: EventHandler.self, at: secondIndexPath))
        let eventHandler1 = cell.eventHandler
        
        if let eventHandler0 = eventHandler0 {
            trackForMemoryLeaks(eventHandler0, file: file, line: line)
        }
        if let eventHandler1 = eventHandler1 {
            trackForMemoryLeaks(eventHandler1, file: file, line: line)
        }
        return (factory, eventHandler0, eventHandler1)
    }
    
    func test_register_createsDifferentTypesOfEventHandler() {
        let sut = makeSUT()
        let cell = Cell()
        sut.register(EventHandlerFactory(Cell()), toCreateType: EventHandler.self, at: indexPath)
        XCTAssertNoThrow(try sut.configure(dependencyHolder: cell, dependencyType: EventHandler.self, at: indexPath))

        let secondCell = SecondCell()
        sut.register(SecondEventHandlerFactory(), toCreateType: SecondEventHandler.self, at: indexPath)
        XCTAssertNoThrow(try sut.configure(dependencyHolder: secondCell, dependencyType: SecondEventHandler.self, at: indexPath))
        
        XCTAssertNotNil(cell.eventHandler)
        XCTAssertNotNil(secondCell.eventHandler)
    }
    
    func test_register_doesNotOverridePreviousRegisteredFactory() {
        let (factory, eventHandler0, eventHandler1) = configure(at: indexPath, secondIndexPath: indexPath)
        
        XCTAssertEqual(factory.createCallCount, 1)
        XCTAssertNotNil(eventHandler0)
        XCTAssertTrue(eventHandler0 === eventHandler1)
    }
    
    func test_configure_throwsErrorIfNotRegistered() {
        let sut = makeSUT()
        let (cell, _) = makeCellAndFactory()
        XCTAssertThrowsError(try sut.configure(dependencyHolder: cell, dependencyType: EventHandler.self, at: IndexPath(row: 4, section: 7))) { (error) in
            if case HelloDependencyError.error(let errorString) = error {
                XCTAssertEqual(errorString, "EventHandler dependency is not registered at row: 4 section: 7")
            }else{
                XCTFail("wrong error")
            }
        }
    }
}

class Cell: View, CellView, CellEventHandlerHolder {
    
    var eventHandler: EventHandler!
    
    var cellDidConfigureCallCount = 0
    func cellDidConfigure() {
        cellDidConfigureCallCount += 1
    }
    
    func set(eventHandler: EventHandler) {
        self.eventHandler = eventHandler
    }
}
protocol View {}
protocol CellView {}
protocol DifferentProtocol {}

class EventHandler {
    let view: View
    init(_ view: View) {
        self.view = view
    }
}
class EventHandlerFactory: CellEventHandlerFactory {
    private let view: Cell
    init(_ view: Cell) {
        self.view = view
    }
    
    private(set) var createdEventHandler: EventHandler?
    var createCallCount = 0
    func create() -> EventHandler {
        createCallCount += 1
        let eh = EventHandler(WeakBox(view))
        createdEventHandler = eh
        return eh
    }
}

class SecondCell: CellEventHandlerHolder {
    var eventHandler: SecondEventHandler!
    func set(eventHandler: SecondEventHandler) {
        self.eventHandler = eventHandler
    }
}
class SecondEventHandler {}
class SecondEventHandlerFactory: CellEventHandlerFactory {
    func create() -> SecondEventHandler {
        return SecondEventHandler()
    }
}

extension WeakBox: View where A: View {}
extension WeakBox: CellView where A: CellView {}
