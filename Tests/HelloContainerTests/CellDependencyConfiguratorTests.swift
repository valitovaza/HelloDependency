import XCTest
import HelloDependency
import HelloContainer

class CellDependencyConfiguratorTests: XCTestCase {
    
    func test_set_throwsErrorIfCellDoesNotConformToSentProtocol() {
        let sut = makeSUT()
        let cell = makeCell()
        
        XCTAssertThrowsError(try sut.set(configurable: WeakBox(cell), forType: DifferentProtocol.self, at: indexPath()))
        { (error) in
            checkDependencyError(error, expectedMessage: "Can not register WeakBox<Cell> as DifferentProtocol")
        }
    }
    private func makeSUT(_ clearOnDeinit: Bool = true, file: StaticString = #file, line: UInt = #line) -> CellDependencyConfigurator {
        let sut = CellDependencyConfigurator()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    private func makeCell(file: StaticString = #file, line: UInt = #line) -> Cell {
        let cell = Cell()
        trackForMemoryLeaks(cell, file: file, line: line)
        return cell
    }
    private func indexPath(_ row: Int = 0, _ section: Int = 0) -> IndexPath {
        return IndexPath(row: row, section: section)
    }
    private func checkDependencyError(_ error: Error, expectedMessage: String, file: StaticString = #file, line: UInt = #line) {
        if case CellDependencyConfiguratorError.error(let errorString) = error {
            XCTAssertEqual(errorString, expectedMessage, file: file, line: line)
        }else{
            XCTFail("wrong error", file: file, line: line)
        }
    }
    
    func test_set_doesNotThrowErrorIfCellConformsToSentProtocol() {
        let sut = makeSUT()
        let cell = makeCell()
        
        XCTAssertNoThrow(try sut.set(configurable: WeakBox(cell), forType: FirstViewProtocol.self, at: indexPath()))
    }
    
    func test_configure_throwsErrorIfRequiredViewsIsNotSet() {
        let sut = makeSUT()
        let cell = makeCell()
        setOnceRequiredDependencies(sut, at: indexPath(2, 6))
        
        XCTAssertThrowsError(try sut.buildDependency(for: cell, dependencyType: EventHandler.self, at: indexPath(2, 6)))
        { (error) in
            checkDependencyError(error, expectedMessage: "Can not build EventHandler at row: 2 section: 6")
        }
    }
    
    func test_configure_thorowsErrorIfRequiredAdditionalDependenciesNotFound() {
        let sut = makeSUT()
        let cell = makeCell()
        setRequiredViews(sut, cell, at: indexPath(0,5))
        
        XCTAssertThrowsError(try sut.buildDependency(for: cell,
                                               dependencyType: EventHandler.self,
                                               at: indexPath(0,5)))
        { (error) in
            checkDependencyError(error, expectedMessage: "Can not build EventHandler at row: 0 section: 5")
        }
    }
    private func setRequiredViews(_ sut: CellDependencyConfigurator, _ cell: Cell, at indexPath: IndexPath, _ file: StaticString = #file, _ line: UInt = #line) {
        let weakBox0 = WeakBox(cell)
        set(view: weakBox0, on: sut, asType: FirstViewProtocol.self, at: indexPath)
        trackForMemoryLeaks(weakBox0, file: file, line: line)
        
        let weakBox1 = WeakBox(cell)
        trackForMemoryLeaks(weakBox1, file: file, line: line)
        set(view: weakBox1, on: sut, asType: SecondViewProtocol.self, at: indexPath)
    }
    private func set<T, D>(view: WeakBox<T>, on sut: CellDependencyConfigurator, asType type: D.Type, at indexPath: IndexPath, _ file: StaticString = #file, _ line: UInt = #line) {
        XCTAssertNoThrow(try sut.set(configurable: view, forType: type, at: indexPath), file: file, line: line)
    }
    
    func test_configure_throwsErrorOnSetViewAtDifferentIndexPath() {
        let sut = makeSUT()
        let cell = makeCell()
        setRequiredDependencies(sut, cell, at: indexPath(0,5))
        
        XCTAssertThrowsError(try sut.buildDependency(for: cell, dependencyType: EventHandler.self, at: indexPath(2, 6)))
        { (error) in
            checkDependencyError(error, expectedMessage: "Can not build EventHandler at row: 2 section: 6")
        }
    }
    private func setRequiredDependencies(_ sut: CellDependencyConfigurator, _ cell: Cell, at indexPath: IndexPath, _ file: StaticString = #file, _ line: UInt = #line) {
        setRequiredViews(sut, cell, at: indexPath, file, line)
        setOnceRequiredDependencies(sut, at: indexPath, file, line)
    }
    private func setOnceRequiredDependencies(_ sut: CellDependencyConfigurator, at indexPath: IndexPath, _ file: StaticString = #file, _ line: UInt = #line) {
        setOnce(dependency: EventHandlerDependency(), on: sut, asType: FirstEventHandlerDependency.self, at: indexPath, file, line)
        setOnce(dependency: EventHandlerDependency(), on: sut, asType: SecondEventHandlerDependency.self, at: indexPath, file, line)
    }
    private func setOnce<T, D>(dependency: T, on sut: CellDependencyConfigurator, asType type: D.Type, at indexPath: IndexPath, _ file: StaticString = #file, _ line: UInt = #line) {
        trackForMemoryLeaks(dependency as AnyObject, file: file, line: line)
        XCTAssertNoThrow(try sut.setToBuildOnce(dependency, forType: type, at: indexPath), file: file, line: line)
    }
    
    func test_configure_setsCellsEventHandlerWithDependenciesRelatedToCell() {
        let sut = makeSUT()
        let cell = makeCell()
        setDependenciesAndConfigure(sut, cell)
        
        assertThatCellConfiguredWithEventhandler(cell)
    }
    private func setDependenciesAndConfigure(_ sut: CellDependencyConfigurator, _ cell: Cell, _ indexPath: IndexPath = IndexPath(row: 0, section: 0), _ file: StaticString = #file, _ line: UInt = #line) {
        setRequiredDependencies(sut, cell, at: indexPath, file, line)
        configure(cell: cell, on: sut, at: indexPath, file, line)
    }
    private func configure(cell: Cell, on sut: CellDependencyConfigurator, at indexPath: IndexPath, _ file: StaticString = #file, _ line: UInt = #line) {
        XCTAssertNoThrow(try sut.buildDependency(for: cell,
                                           dependencyType: EventHandler.self,
                                           at: indexPath), file: file, line: line)
    }
    private func assertThatCellConfiguredWithEventhandler(_ cell: Cell, _ file: StaticString = #file, _ line: UInt = #line) {
        assertThatCellConfiguredWithEventhandler(cell, cell, cell, file, line)
    }
    private func assertThatCellConfiguredWithEventhandler(_ cell: Cell, _ viewProtocolCell: Cell, _ secondViewProtocolCell: Cell, _ file: StaticString = #file, _ line: UInt = #line) {
        cell.eventHandler?.triggerFirstViewMethod()
        XCTAssertEqual(viewProtocolCell.firstViewMethodCallCount, 1, file: file, line: line)
        cell.eventHandler?.triggerSecondViewMethod()
        XCTAssertEqual(secondViewProtocolCell.secondViewMethodCallCount, 1, file: file, line: line)
    }
    
    func test_configure_throwsErrorIfNotAllRequiredViewsSet() {
        let sut = makeSUT()
        let cell = makeCell()
        let weakBox = WeakBox(cell)
        XCTAssertNoThrow(try sut.set(configurable: weakBox, forType: FirstViewProtocol.self, at: indexPath(1,1)))
        setOnceRequiredDependencies(sut, at: indexPath(1,1))
        
        XCTAssertThrowsError(try sut.buildDependency(for: cell, dependencyType: EventHandler.self, at: indexPath(1,1)))
        { (error) in
            checkDependencyError(error, expectedMessage: "Can not build EventHandler at row: 1 section: 1")
        }
    }
    
    func test_setOnce_throwsErrorIfDependencyDoesNotConformToSentProtocol() {
        let sut = makeSUT()
        let cell = makeCell()
        
        XCTAssertThrowsError(try sut.setToBuildOnce(cell, forType: DifferentProtocol.self, at: indexPath()))
        { (error) in
            checkDependencyError(error, expectedMessage: "Can not register Cell as DifferentProtocol")
        }
    }
    
    func test_configure_setsEventHandlerDependenciesRelatedToDependencyType() {
        let sut = makeSUT()
        let cell = makeCell()
        let viewProtocolCell = makeCell()
        let secondViewProtocolCell = makeCell()
        set(view: WeakBox(secondViewProtocolCell), on: sut, asType: SecondViewProtocol.self, at: indexPath())
        set(view: WeakBox(viewProtocolCell), on: sut, asType: FirstViewProtocol.self, at: indexPath())
        let secondEhDep = EventHandlerDependency()
        setOnce(dependency: secondEhDep, on: sut, asType: SecondEventHandlerDependency.self, at: indexPath())
        let firstEhDep = EventHandlerDependency()
        setOnce(dependency: firstEhDep, on: sut, asType: FirstEventHandlerDependency.self, at: indexPath())
        
        configure(cell: cell, on: sut, at: indexPath())
        
        assertThatCellConfiguredWithEventhandler(cell, viewProtocolCell, secondViewProtocolCell)
        
        cell.eventHandler?.triggerFirstTestMethod()
        XCTAssertEqual(firstEhDep.firstTestMethodCallCount, 1)
        XCTAssertEqual(secondEhDep.firstTestMethodCallCount, 0)
        
        cell.eventHandler?.triggerSecondTestMethod()
        XCTAssertEqual(secondEhDep.secondTestMethodCallCount, 1)
        XCTAssertEqual(firstEhDep.secondTestMethodCallCount, 0)
    }
    
    func test_set_updatesCurrentViewForIndexPath() {
        let sut = makeSUT()
        let cell0 = makeCell()
        setDependenciesAndConfigure(sut, cell0)
        
        let cell1 = makeCell()
        setDependenciesAndConfigure(sut, cell1)
        
        assertThatCellConfiguredWithEventhandler(cell1)
    }
    
    func test_set_doesNotUpdatesViewForDifferentIndex() {
        let sut = makeSUT()
        let cell0 = makeCell()
        setDependenciesAndConfigure(sut, cell0, IndexPath(row: 0, section: 0))
        
        let cell1 = makeCell()
        setDependenciesAndConfigure(sut, cell1, IndexPath(row: 0, section: 1))
        
        assertThatCellConfiguredWithEventhandler(cell0)
    }
    
    func test_set_doesNotUpdatesViewForOtherProtocol() {
        let sut = makeSUT()
        let cell0 = makeCell()
        setDependenciesAndConfigure(sut, cell0)
        
        let cell1 = makeCell()
        let weakBox1 = WeakBox(cell1)
        set(view: weakBox1, on: sut, asType: FirstViewProtocol.self, at: indexPath())
        
        cell0.eventHandler?.triggerSecondViewMethod()
        XCTAssertEqual(cell0.secondViewMethodCallCount, 1)
    }
    
    func test_set_onDifferentIndexRemovesSameViewFromOtherDependencies() {
        let sut = makeSUT()
        let indexPath0 = IndexPath(row: 0, section: 0)
        let indexPath1 = IndexPath(row: 1, section: 0)
        
        let eventHolder0 = makeCell()
        let cellView = makeCell()
        setRequiredViews(sut, cellView, at: indexPath0)
        setOnceRequiredDependencies(sut, at: indexPath0)
        configure(cell: eventHolder0, on: sut, at: indexPath0)
        
        for index in 1..<10 {
            let differentCell = Cell()
            setRequiredViews(sut, differentCell, at: indexPath(index, index))
            setOnce(dependency: differentCell, on: sut, asType: FirstViewProtocol.self, at: indexPath(index, index))
        }
        
        let eventHolder1 = makeCell()
        setRequiredViews(sut, cellView, at: indexPath1)
        setOnceRequiredDependencies(sut, at: indexPath1)
        configure(cell: eventHolder1, on: sut, at: indexPath1)
        
        eventHolder0.eventHandler?.triggerFirstViewMethod()
        XCTAssertEqual(cellView.firstViewMethodCallCount, 0)
        eventHolder1.eventHandler?.triggerFirstViewMethod()
        XCTAssertEqual(cellView.firstViewMethodCallCount, 1)
    }
    
    func test_configure_createsAnotherEventHandlerForDifferentIndexPaths() {
        let sut = makeSUT()
        let cell = makeCell()
        setDependenciesAndConfigure(sut, cell, indexPath(0, 0))
        let eventHandler0 = cell.eventHandler
        
        setDependenciesAndConfigure(sut, cell, indexPath(0, 1))
        
        XCTAssertNotNil(eventHandler0)
        XCTAssertTrue(eventHandler0 !== cell.eventHandler)
    }
    
    func test_configure_createsDifferentTypesOfEventHandler() {
        let sut = makeSUT()
        let cell = Cell()
        setDependenciesAndConfigure(sut, cell, indexPath())

        let secondCell = SecondCell()
        XCTAssertNoThrow(try sut.buildDependency(for: secondCell,
                                           dependencyType: SecondEventHandler.self,
                                           at: indexPath()))
        XCTAssertNotNil(cell.eventHandler)
        XCTAssertNotNil(secondCell.secondEventHandler)
    }
    
    func test_configure_createsSameInstancePerType() {
        let sut = makeSUT()
        let cell0 = Cell()
        setDependenciesAndConfigure(sut, cell0, indexPath())
        let secondCell0 = SecondCell()
        XCTAssertNoThrow(try sut.buildDependency(for: secondCell0,
                                           dependencyType: SecondEventHandler.self,
                                           at: indexPath()))
        
        let cell1 = Cell()
        setDependenciesAndConfigure(sut, cell1, indexPath())
        
        let secondCell1 = SecondCell()
        XCTAssertNoThrow(try sut.buildDependency(for: secondCell1,
                                           dependencyType: SecondEventHandler.self,
                                           at: indexPath()))
        
        XCTAssertTrue(cell0.eventHandler === cell1.eventHandler)
        XCTAssertTrue(secondCell0.secondEventHandler === secondCell1.secondEventHandler)
    }
    
    func test_create_returnsSameEventHandlerForSameIndexPath() {
        let sut = makeSUT()
        let cell0 = Cell()
        setDependenciesAndConfigure(sut, cell0, indexPath())
        
        let cell1 = Cell()
        setDependenciesAndConfigure(sut, cell1, indexPath())
 
        XCTAssertNotNil(cell0.eventHandler)
        XCTAssertTrue(cell0.eventHandler === cell1.eventHandler)
    }

    func test_set_throwsErrorOnSendSameWeakViewMultipleTime() {
        let sut = makeSUT()
        let cell = Cell()
        let weakView = WeakBox(cell)
        let indexPath0 = IndexPath(row: 0, section: 0)
        let indexPath1 = IndexPath(row: 1, section: 1)
        let errorText = "Can not use same WeakArgument multiple times"
        
        set(view: weakView, on: sut, asType: FirstViewProtocol.self, at: indexPath0)
        
        XCTAssertThrowsError(try sut.set(configurable: weakView, forType: FirstViewProtocol.self, at: indexPath0)) { (error) in
            if case CellDependencyConfiguratorError.error(let errorString) = error {
                XCTAssertEqual(errorString, errorText)
            }else{
                XCTFail("wrong error")
            }
        }
        XCTAssertThrowsError(try sut.set(configurable: weakView, forType: SecondViewProtocol.self, at: indexPath0)) { (error) in
            if case CellDependencyConfiguratorError.error(let errorString) = error {
                XCTAssertEqual(errorString, errorText)
            }else{
                XCTFail("wrong error")
            }
        }
        XCTAssertThrowsError(try sut.set(configurable: weakView, forType: FirstViewProtocol.self, at: indexPath1)) { (error) in
            if case CellDependencyConfiguratorError.error(let errorString) = error {
                XCTAssertEqual(errorString, errorText)
            }else{
                XCTFail("wrong error")
            }
        }
    }
}
