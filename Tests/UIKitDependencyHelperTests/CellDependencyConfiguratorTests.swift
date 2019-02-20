import XCTest
import HelloDependency
import UIKitDependencyHelper

class CellDependencyConfiguratorTests: XCTestCase {
    
    func test_set_throwsErrorIfCellDoesNotConformToSentProtocol() {
        let sut = makeSUT()
        let cell = makeCell()
        
        XCTAssertThrowsError(try sut.set(configurable: WeakBox(cell), forType: DifferentProtocol.self, at: indexPath()))
        { (error) in
            checkDependencyError(error, expectedMessage: "Can not register WeakBox<Cell> as DifferentProtocol")
        }
    }
    private func makeSUT(_ file: StaticString = #file, line: UInt = #line) -> CellDependencyConfigurator {
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
    
    func test_configure_throwsErrorIfRequiredConfigurableArgumentsAreNotSet() {
        let sut = makeSUT()
        let cell = makeCell()
        let indexPath = self.indexPath(2, 6)
        setOnceRequiredArguments(sut, at: indexPath)
        
        XCTAssertThrowsError(try sut.buildDependency(for: cell, dependencyType: FirstCellDependency.self, at: indexPath))
        { (error) in
            checkDependencyError(error, expectedMessage: "Can not build FirstCellDependency at row: 2 section: 6")
        }
    }
    private func setOnceRequiredArguments(_ sut: CellDependencyConfigurator, at indexPath: IndexPath, _ file: StaticString = #file, _ line: UInt = #line) {
        setOnce(argument: DependencyArgument(), on: sut, forType: FirstArgument.self, at: indexPath, file, line)
        setOnce(argument: DependencyArgument(), on: sut, forType: SecondArgument.self, at: indexPath, file, line)
    }
    private func setOnce<T, D>(argument: T, on sut: CellDependencyConfigurator, forType type: D.Type, at indexPath: IndexPath, _ file: StaticString = #file, _ line: UInt = #line) {
        trackForMemoryLeaks(argument as AnyObject, file: file, line: line)
        XCTAssertNoThrow(try sut.setToBuildOnce(argument, forType: type, at: indexPath), file: file, line: line)
    }
    
    func test_configure_thorowsErrorIfRequiredArgumentsAreNotSet() {
        let sut = makeSUT()
        let cell = makeCell()
        let indexPath = self.indexPath(0, 5)
        setRequiredConfigurableArguments(sut, cell, at: indexPath)
        
        XCTAssertThrowsError(try sut.buildDependency(for: cell, dependencyType: FirstCellDependency.self, at: indexPath))
        { (error) in
            checkDependencyError(error, expectedMessage: "Can not build FirstCellDependency at row: 0 section: 5")
        }
    }
    private func setRequiredConfigurableArguments(_ sut: CellDependencyConfigurator, _ cell: Cell, at indexPath: IndexPath, _ file: StaticString = #file, _ line: UInt = #line) {
        let weakBox0 = WeakBox(cell)
        set(configurableArgument: weakBox0, on: sut, forType: FirstViewProtocol.self, at: indexPath)
        trackForMemoryLeaks(weakBox0, file: file, line: line)
        
        let weakBox1 = WeakBox(cell)
        trackForMemoryLeaks(weakBox1, file: file, line: line)
        set(configurableArgument: weakBox1, on: sut, forType: SecondViewProtocol.self, at: indexPath)
    }
    private func set<T, D>(configurableArgument: WeakBox<T>, on sut: CellDependencyConfigurator, forType type: D.Type, at indexPath: IndexPath, _ file: StaticString = #file, _ line: UInt = #line) {
        XCTAssertNoThrow(try sut.set(configurable: configurableArgument, forType: type, at: indexPath), file: file, line: line)
    }
    
    func test_configure_throwsErrorOnArgumentsAtDifferentIndexPath() {
        let sut = makeSUT()
        let cell = makeCell()
        setRequiredArguments(sut, cell, at: indexPath(0,5))
        
        XCTAssertThrowsError(try sut.buildDependency(for: cell, dependencyType: FirstCellDependency.self, at: indexPath(2, 6)))
        { (error) in
            checkDependencyError(error, expectedMessage: "Can not build FirstCellDependency at row: 2 section: 6")
        }
    }
    private func setRequiredArguments(_ sut: CellDependencyConfigurator, _ cell: Cell, at indexPath: IndexPath, _ file: StaticString = #file, _ line: UInt = #line) {
        setRequiredConfigurableArguments(sut, cell, at: indexPath, file, line)
        setOnceRequiredArguments(sut, at: indexPath, file, line)
    }
    
    func test_configure_buildsDependencyWithArgumentsRelatedToCell() {
        let sut = makeSUT()
        let cell = makeCell()
        setArgumentsAndConfigure(sut, cell)
        
        assertThatDependencyBuiltWithArguments(from: cell)
    }
    private func setArgumentsAndConfigure(_ sut: CellDependencyConfigurator, _ cell: Cell, _ indexPath: IndexPath = IndexPath(row: 0, section: 0), _ file: StaticString = #file, _ line: UInt = #line) {
        setRequiredArguments(sut, cell, at: indexPath, file, line)
        configure(cell: cell, on: sut, at: indexPath, file, line)
    }
    private func configure(cell: Cell, on sut: CellDependencyConfigurator, at indexPath: IndexPath, _ file: StaticString = #file, _ line: UInt = #line) {
        XCTAssertNoThrow(try sut.buildDependency(for: cell,
                                           dependencyType: FirstCellDependency.self,
                                           at: indexPath), file: file, line: line)
    }
    private func assertThatDependencyBuiltWithArguments(from cell: Cell, _ file: StaticString = #file, _ line: UInt = #line) {
        assertThatDependencyBuiltWithArguments(cell, cell, cell, file, line)
    }
    private func assertThatDependencyBuiltWithArguments(_ cell: Cell, _ viewProtocolCell: Cell, _ secondViewProtocolCell: Cell, _ file: StaticString = #file, _ line: UInt = #line) {
        cell.dependency?.triggerFirstViewMethod()
        XCTAssertEqual(viewProtocolCell.firstViewMethodCallCount, 1, file: file, line: line)
        cell.dependency?.triggerSecondViewMethod()
        XCTAssertEqual(secondViewProtocolCell.secondViewMethodCallCount, 1, file: file, line: line)
    }
    
    func test_configure_throwsErrorIfNotAllRequiredConfigurableArgumentsSet() {
        let sut = makeSUT()
        let cell = makeCell()
        let weakBox = WeakBox(cell)
        XCTAssertNoThrow(try sut.set(configurable: weakBox, forType: FirstViewProtocol.self, at: indexPath(1,1)))
        setOnceRequiredArguments(sut, at: indexPath(1,1))
        
        XCTAssertThrowsError(try sut.buildDependency(for: cell, dependencyType: FirstCellDependency.self, at: indexPath(1,1)))
        { (error) in
            checkDependencyError(error, expectedMessage: "Can not build FirstCellDependency at row: 1 section: 1")
        }
    }
    
    func test_setOnce_throwsErrorIfArgumentDoesNotConformToSentProtocol() {
        let sut = makeSUT()
        let cell = makeCell()
        
        XCTAssertThrowsError(try sut.setToBuildOnce(cell, forType: DifferentProtocol.self, at: indexPath()))
        { (error) in
            checkDependencyError(error, expectedMessage: "Can not register Cell as DifferentProtocol")
        }
    }
    
    func test_configure_setsDependencyArgumentsRelatedToArgumentTypes() {
        let sut = makeSUT()
        let cell = makeCell()
        let firstConfigurableArgument = makeCell()
        let secondConfigurableArgument = makeCell()
        set(configurableArgument: WeakBox(secondConfigurableArgument), on: sut, forType: SecondViewProtocol.self, at: indexPath())
        set(configurableArgument: WeakBox(firstConfigurableArgument), on: sut, forType: FirstViewProtocol.self, at: indexPath())
        let secondArgument = DependencyArgument()
        setOnce(argument: secondArgument, on: sut, forType: SecondArgument.self, at: indexPath())
        let firstArgument = DependencyArgument()
        setOnce(argument: firstArgument, on: sut, forType: FirstArgument.self, at: indexPath())
        
        configure(cell: cell, on: sut, at: indexPath())
        
        assertThatDependencyBuiltWithArguments(cell, firstConfigurableArgument, secondConfigurableArgument)
        
        cell.dependency?.triggerFirstTestMethod()
        XCTAssertEqual(firstArgument.firstArgumentMethodCallCount, 1)
        XCTAssertEqual(secondArgument.firstArgumentMethodCallCount, 0)
        
        cell.dependency?.triggerSecondTestMethod()
        XCTAssertEqual(secondArgument.secondArgumentMethodCallCount, 1)
        XCTAssertEqual(firstArgument.secondArgumentMethodCallCount, 0)
    }
    
    func test_set_updatesConfigurableArgumentForIndexPath() {
        let sut = makeSUT()
        let cell0 = makeCell()
        setArgumentsAndConfigure(sut, cell0)
        
        let cell1 = makeCell()
        setArgumentsAndConfigure(sut, cell1)
        
        assertThatDependencyBuiltWithArguments(from: cell1)
    }
    
    func test_set_doesNotUpdatesConfigurableArgumentForDifferentIndex() {
        let sut = makeSUT()
        let cell0 = makeCell()
        setArgumentsAndConfigure(sut, cell0, IndexPath(row: 0, section: 0))
        
        let cell1 = makeCell()
        setArgumentsAndConfigure(sut, cell1, IndexPath(row: 0, section: 1))
        
        assertThatDependencyBuiltWithArguments(from: cell0)
    }
    
    func test_set_doesNotUpdatesConfigurableArgumentForOtherProtocol() {
        let sut = makeSUT()
        let cell0 = makeCell()
        setArgumentsAndConfigure(sut, cell0)
        
        let cell1 = makeCell()
        let weakBox1 = WeakBox(cell1)
        set(configurableArgument: weakBox1, on: sut, forType: FirstViewProtocol.self, at: indexPath())
        
        cell0.dependency?.triggerSecondViewMethod()
        XCTAssertEqual(cell0.secondViewMethodCallCount, 1)
    }
    
    func test_set_removesConfigurableArgumentFromDependenciesAtOtherIndexPaths() {
        let sut = makeSUT()
        let indexPath0 = IndexPath(row: 0, section: 0)
        let indexPath1 = IndexPath(row: 1, section: 0)
        
        let dependencyHolder0 = makeCell()
        let configurableArgument = makeCell()
        setRequiredConfigurableArguments(sut, configurableArgument, at: indexPath0)
        setOnceRequiredArguments(sut, at: indexPath0)
        configure(cell: dependencyHolder0, on: sut, at: indexPath0)
        
        for index in 1..<10 {
            let differentArgument = Cell()
            setRequiredConfigurableArguments(sut, differentArgument, at: indexPath(index, index))
            setOnce(argument: differentArgument, on: sut, forType: FirstViewProtocol.self, at: indexPath(index, index))
        }
        
        let dependencyHolder1 = makeCell()
        setRequiredConfigurableArguments(sut, configurableArgument, at: indexPath1)
        setOnceRequiredArguments(sut, at: indexPath1)
        configure(cell: dependencyHolder1, on: sut, at: indexPath1)
        
        dependencyHolder0.dependency?.triggerFirstViewMethod()
        XCTAssertEqual(configurableArgument.firstViewMethodCallCount, 0)
        dependencyHolder1.dependency?.triggerFirstViewMethod()
        XCTAssertEqual(configurableArgument.firstViewMethodCallCount, 1)
    }
    
    func test_configure_createsAnotherDependencyForDifferentIndexPaths() {
        let sut = makeSUT()
        let cell = makeCell()
        setArgumentsAndConfigure(sut, cell, indexPath(0, 0))
        let dependency0 = cell.dependency
        
        setArgumentsAndConfigure(sut, cell, indexPath(0, 1))
        
        XCTAssertNotNil(dependency0)
        XCTAssertTrue(dependency0 !== cell.dependency)
    }
    
    func test_configure_createsDifferentTypesOfDependencies() {
        let sut = makeSUT()
        let cell = Cell()
        setArgumentsAndConfigure(sut, cell, indexPath())

        let secondCell = SecondCell()
        XCTAssertNoThrow(try sut.buildDependency(for: secondCell, dependencyType: SecondCellDependency.self, at: indexPath()))
        XCTAssertNotNil(cell.dependency)
        XCTAssertNotNil(secondCell.dependency)
    }
    
    func test_configure_createsSameInstanceOfDependencyPerType() {
        let sut = makeSUT()
        let cell0 = Cell()
        setArgumentsAndConfigure(sut, cell0, indexPath())
        let secondCell0 = SecondCell()
        XCTAssertNoThrow(try sut.buildDependency(for: secondCell0, dependencyType: SecondCellDependency.self, at: indexPath()))
        
        let cell1 = Cell()
        setArgumentsAndConfigure(sut, cell1, indexPath())
        
        let secondCell1 = SecondCell()
        XCTAssertNoThrow(try sut.buildDependency(for: secondCell1, dependencyType: SecondCellDependency.self, at: indexPath()))
        
        XCTAssertTrue(cell0.dependency === cell1.dependency)
        XCTAssertTrue(secondCell0.dependency === secondCell1.dependency)
    }
    
    func test_create_returnsSameDependencyForSameIndexPath() {
        let sut = makeSUT()
        let cell0 = Cell()
        setArgumentsAndConfigure(sut, cell0, indexPath())
        
        let cell1 = Cell()
        setArgumentsAndConfigure(sut, cell1, indexPath())
 
        XCTAssertNotNil(cell0.dependency)
        XCTAssertTrue(cell0.dependency === cell1.dependency)
    }

    func test_set_throwsErrorIfSameConfigurableArgumentSentMultipleTimes() {
        let sut = makeSUT()
        let cell = Cell()
        let configurableArgument = WeakBox(cell)
        let indexPath0 = IndexPath(row: 0, section: 0)
        let errorText = "Can not use same argument multiple times"
        
        set(configurableArgument: configurableArgument, on: sut, forType: FirstViewProtocol.self, at: indexPath0)
        
        XCTAssertThrowsError(try sut.set(configurable: configurableArgument, forType: FirstViewProtocol.self, at: indexPath0)) { (error) in
            if case CellDependencyConfiguratorError.error(let errorString) = error {
                XCTAssertEqual(errorString, errorText)
            }else{
                XCTFail("wrong error")
            }
        }
        
        XCTAssertThrowsError(try sut.set(configurable: configurableArgument, forType: SecondViewProtocol.self, at: indexPath0)) { (error) in
            if case CellDependencyConfiguratorError.error(let errorString) = error {
                XCTAssertEqual(errorString, errorText)
            }else{
                XCTFail("wrong error")
            }
        }
        
        let indexPath1 = IndexPath(row: 1, section: 1)
        XCTAssertThrowsError(try sut.set(configurable: configurableArgument, forType: FirstViewProtocol.self, at: indexPath1)) { (error) in
            if case CellDependencyConfiguratorError.error(let errorString) = error {
                XCTAssertEqual(errorString, errorText)
            }else{
                XCTFail("wrong error")
            }
        }
    }
}
