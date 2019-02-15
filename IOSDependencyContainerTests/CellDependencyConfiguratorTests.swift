import XCTest
import IOSDependencyContainer

class CellDependencyConfiguratorTests: TestsWithPublicAccessToHelloDependency {
    
    let indexPath = IndexPath(row: 0, section: 0)
    
    override func setUp() {
        reset()
    }
    
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
        let sut = CellDependencyConfigurator(clearOnDeinit)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    private func makeCellAndFactory(file: StaticString = #file, line: UInt = #line) -> (Cell, EventHandlerFactory) {
        let cell = Cell()
        let factory = EventHandlerFactory(cell)
        trackForMemoryLeaks(factory, file: file, line: line)
        trackForMemoryLeaks(cell, file: file, line: line)
        return (cell, factory)
    }
    
    func test_set_registersDependency() {
        let sut = makeSUT()
        let (cell,_) = makeCellAndFactory()
        let indexPath = IndexPath(row: 2, section: 7)
        setDefault(value: Cell(), for: View.self)
        
        XCTAssertNoThrow(try sut.set(weakView: WeakBox(cell), asDependencyOfType: View.self, at: indexPath))
        
        XCTAssertNotNil(resolve(View.self, for: "2_7"))
        XCTAssertFalse(resolve(View.self, for: "2_7") as? Cell === cell)
    }
    
    func test_register_onlyRegistersForIdentifierRelatedToIndexPath() {
        let sut = makeSUT()
        _ = registerCellEventHandler(for: IndexPath(row: 7, section: 45), sut)
        
        assertFatalErrorOnResolve(EventHandler.self)
        assertFatalErrorOnResolve(EventHandler.self, forIdentifier: "34_6")
    }
    private func registerCellEventHandler(for indexPath: IndexPath, _ sut: CellDependencyConfigurator) -> EventHandlerFactory {
        let (_,factory) = makeCellAndFactory()
        setDefault(value: EventHandler(Cell()), for: EventHandler.self)
        sut.register(factory, toCreateType: EventHandler.self, at: indexPath)
        return factory
    }
    
    func test_register_registersFactory() {
        let sut = makeSUT()
        let factory = registerCellEventHandler(for: IndexPath(row: 34, section: 6), sut)
        
        XCTAssertTrue(resolve(EventHandler.self, for: "34_6") === factory.createdEventHandler)
    }
    
    func test_register_registersSingleDependency() {
        let sut = makeSUT()
        let factory = registerCellEventHandler(for: IndexPath(row: 34, section: 6), sut)
        
        _ = resolve(EventHandler.self, for: "34_6")
        _ = resolve(EventHandler.self, for: "34_6")
        
        XCTAssertEqual(factory.createCallCount, 1)
    }
    
    func test_configure_setsEventHandlerFromRegisteredFactory() throws {
        let (_,cell,factory, _) = try configureCell()
        
        XCTAssertTrue(cell.eventHandler === factory.createdEventHandler)
    }
    private func configureCell(_ indexPath: IndexPath = IndexPath(row: 0, section: 0)) throws -> (CellDependencyConfigurator, Cell, EventHandlerFactory, WeakBox<Cell>) {
        let sut = makeSUT()
        let (cell,factory) = makeCellAndFactory()
        let weakBox = WeakBox(cell)
        try sut.set(weakView: weakBox, asDependencyOfType: View.self, at: indexPath)
        sut.register(factory, toCreateType: EventHandler.self, at: indexPath)
        sut.configure(dependencyHolder: cell,
                      dependencyType: EventHandler.self, at: indexPath)
        return (sut, cell, factory, weakBox)
    }
    
    func test_set_updatesCurrentViewForIndexPath() throws {
        let (sut,_,_, weakBox0) = try configureCell(indexPath)
        
        let (cell1,_) = makeCellAndFactory()
        try sut.set(weakView: WeakBox(cell1), asDependencyOfType: View.self, at: indexPath)

        XCTAssertTrue(weakBox0.unbox === cell1)
    }
    
    func test_set_doesNotUpdatesViewForDifferentIndex() throws {
        let (sut,_,_, weakBox0) = try configureCell(IndexPath(row: 0, section: 0))
        
        let (cell1,_) = makeCellAndFactory()
        try sut.set(weakView: WeakBox(cell1), asDependencyOfType: View.self, at: IndexPath(row: 4, section: 6))
        
        XCTAssertTrue(weakBox0.unbox !== cell1)
    }
    
    func test_set_doesNotUpdatesViewForOtherProtocol() throws {
        let (sut,cell,_, weakBox0) = try configureCell(indexPath)
        
        let (cell1,_) = makeCellAndFactory()
        try sut.set(weakView: WeakBox(cell1), asDependencyOfType: CellView.self, at: indexPath)
        
        XCTAssertTrue(weakBox0.unbox === cell)
    }
    
    func test_set_onDifferentIndexRemovesSameViewFromOtherDependencies() throws {
        let indexPath0 = IndexPath(row: 0, section: 0)
        let (sut,cell,_, weakBox0) = try configureCell(indexPath0)
        let weakBox1 = WeakBox(cell)
        try sut.set(weakView: weakBox1, asDependencyOfType: CellView.self, at: indexPath0)
        
        let indexPath1 = IndexPath(row: 2, section: 1)
        try sut.set(weakView: WeakBox(cell), asDependencyOfType: CellView.self, at: indexPath1)
        try sut.set(weakView: WeakBox(cell), asDependencyOfType: View.self, at: indexPath1)
        
        XCTAssertNil(weakBox0.unbox)
        XCTAssertNil(weakBox1.unbox)
    }
    
    func test_set_onDifferentIndexDoesNotRemovesOtherViews() throws {
        let sut = makeSUT()
        let cell0 = Cell()
        let weakBox0 = WeakBox(cell0)
        try sut.set(weakView: weakBox0, asDependencyOfType: View.self, at: IndexPath(row: 0, section: 0))
        
        let cell1 = Cell()
        let weakBox1 = WeakBox(cell1)
        try sut.set(weakView: weakBox1, asDependencyOfType: View.self, at: IndexPath(row: 1, section: 1))
        
        XCTAssertNotNil(weakBox0.unbox)
    }
    
    func test_set_dntRemoveSameObjectInOtherDependencyIfProtoIsNotSame() throws {
        let (sut,cell,_, weakBox0) = try configureCell(IndexPath(row: 0, section: 0))
        
        try sut.set(weakView: WeakBox(cell), asDependencyOfType: CellView.self, at: IndexPath(row: 2, section: 1))
        
        XCTAssertTrue(weakBox0.unbox === cell)
    }
    
    func test_register_createsEventHandlersForDifferentIndexPaths() throws {
        let (factory, eventHandler0, eventHandler1) = try configure(at: IndexPath(row: 0, section: 0), secondIndexPath: IndexPath(row: 1, section: 1))
        
        XCTAssertEqual(factory.createCallCount, 2)
        XCTAssertNotNil(eventHandler0)
        XCTAssertTrue(eventHandler0 !== eventHandler1)
    }
    private func configure(at indexPath: IndexPath, clear: Bool = false, secondIndexPath: IndexPath) throws -> (EventHandlerFactory, EventHandler?, EventHandler?) {
        let sut = makeSUT()
        let (cell,factory) = makeCellAndFactory()
        try sut.set(weakView: WeakBox(cell), asDependencyOfType: View.self, at: indexPath)
        sut.register(factory, toCreateType: EventHandler.self, at: indexPath)
        sut.configure(dependencyHolder: cell,
                      dependencyType: EventHandler.self, at: indexPath)
        let eventHandler0 = cell.eventHandler

        if clear {
            sut.clear()
            try sut.set(weakView: WeakBox(cell), asDependencyOfType: View.self, at: indexPath)
        }
        sut.register(factory, toCreateType: EventHandler.self, at: secondIndexPath)
        sut.configure(dependencyHolder: cell,
                      dependencyType: EventHandler.self, at: secondIndexPath)
        let eventHandler1 = cell.eventHandler
        return (factory, eventHandler0, eventHandler1)
    }
    
    func test_register_createsDifferentTypesOfEventHandler() throws {
        let sut = makeSUT()
        let cell = Cell()
        sut.register(EventHandlerFactory(Cell()), toCreateType: EventHandler.self, at: indexPath)
        sut.configure(dependencyHolder: cell,
                      dependencyType: EventHandler.self, at: indexPath)

        let secondCell = SecondCell()
        sut.register(SecondEventHandlerFactory(), toCreateType: SecondEventHandler.self, at: indexPath)
        sut.configure(dependencyHolder: secondCell, dependencyType: SecondEventHandler.self, at: indexPath)
        
        XCTAssertNotNil(cell.eventHandler)
        XCTAssertNotNil(secondCell.eventHandler)
    }
    
    func test_register_doesNotOverridePreviousRegisteredFactory() throws {
        let (factory, eventHandler0, eventHandler1) = try configure(at: indexPath, secondIndexPath: indexPath)
        
        XCTAssertEqual(factory.createCallCount, 1)
        XCTAssertNotNil(eventHandler0)
        XCTAssertTrue(eventHandler0 === eventHandler1)
    }
    
    func test_register_overridePreviousRegisteredFactoryAfterClear() throws {
        let (factory, eventHandler0, eventHandler1) = try configure(at: indexPath, clear: true, secondIndexPath: indexPath)
        
        XCTAssertEqual(factory.createCallCount, 2)
        XCTAssertNotNil(eventHandler0)
        XCTAssertTrue(eventHandler0 !== eventHandler1)
    }
    
    func test_clear_removeSetViewsForAllIndexes() throws {
        let sut = makeSUT()
        var weakBox0: WeakBox! = try setViewAndReturnWeakBox(sut, IndexPath(row: 0, section: 0))
        weak var wb0: WeakBox? = weakBox0

        var weakBox1: WeakBox! = try setViewAndReturnWeakBox(sut, IndexPath(row: 4, section: 5))
        weak var wb1: WeakBox? = weakBox1
        
        weakBox0 = nil
        weakBox1 = nil
        XCTAssertNotNil(wb0)
        XCTAssertNotNil(wb1)
        
        sut.clear()
        
        XCTAssertNil(wb0)
        XCTAssertNil(wb1)
    }
    private func setViewAndReturnWeakBox(_ sut: CellDependencyConfigurator, _ indexPath: IndexPath) throws -> WeakBox<Cell> {
        let (cell,_) = makeCellAndFactory()
        let weakBox = WeakBox(cell)
        try sut.set(weakView: weakBox, asDependencyOfType: View.self, at: indexPath)
        try sut.set(weakView: weakBox, asDependencyOfType: CellView.self, at: indexPath)
        return weakBox
    }
    
    func test_clear_doesNotAffectDependenciesNotrelatedToTable() {
        let sut = makeSUT()
        register(Int.self, 4)
        
        sut.clear()
        
        XCTAssertEqual(resolve(Int.self), 4)
    }
    
    func test_clear_removesDependenciesRegisteredViaSutOnlyOnce() throws {
        let sut0 = makeSUT()
        let (cell0,_) = makeCellAndFactory()
        try sut0.set(weakView: WeakBox(cell0), asDependencyOfType: View.self, at: indexPath)
        
        sut0.clear()
        
        var sut1: CellDependencyConfigurator! = makeSUT(false)
        let (cell1,_) = makeCellAndFactory()
        var weakBox1: WeakBox! = WeakBox(cell1)
        weak var wb1: WeakBox? = weakBox1
        try sut1.set(weakView: weakBox1, asDependencyOfType: View.self, at: indexPath)
        
        sut0.clear()
        weakBox1 = nil
        sut1 = nil
        
        XCTAssertNotNil(wb1)
    }
    
    func test_clear_removesCreatedEventHandlersForAllIndexes() throws {
        let sut = makeSUT(false)
        let (cell,factory) = makeCellAndFactory()
        try sut.set(weakView: WeakBox(cell), asDependencyOfType: View.self, at: indexPath)
        sut.register(factory, toCreateType: EventHandler.self, at: indexPath)
        sut.configure(dependencyHolder: cell,
                      dependencyType: EventHandler.self, at: indexPath)
        trackForMemoryLeaks(factory.createdEventHandler!)
        
        sut.clear()
    }
    
    func test_deinit_removeRegisteredViewsForAllIndexes() throws {
        var sut: CellDependencyConfigurator! = makeSUT()
        var weakBox0: WeakBox! = try setViewAndReturnWeakBox(sut, IndexPath(row: 0, section: 0))
        weak var wb0: WeakBox? = weakBox0
        
        var weakBox1: WeakBox! = try setViewAndReturnWeakBox(sut, IndexPath(row: 4, section: 5))
        weak var wb1: WeakBox? = weakBox1
        
        weakBox0 = nil
        weakBox1 = nil
        XCTAssertNotNil(wb0)
        XCTAssertNotNil(wb1)
        
        sut = nil
        
        XCTAssertNil(wb0)
        XCTAssertNil(wb1)
    }
    
    func test_deinit_removesCreatedEventHandlersForAllIndexes() throws {
        let sut = makeSUT()
        let (cell,factory) = makeCellAndFactory()
        try sut.set(weakView: WeakBox(cell), asDependencyOfType: View.self, at: indexPath)
        sut.register(factory, toCreateType: EventHandler.self, at: indexPath)
        sut.configure(dependencyHolder: cell,
                      dependencyType: EventHandler.self, at: indexPath)
        trackForMemoryLeaks(factory.createdEventHandler!)
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
