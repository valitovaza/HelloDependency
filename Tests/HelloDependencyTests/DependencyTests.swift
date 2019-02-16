import XCTest

class DependencyTests: XCTestCase {
    override func setUp() {
        reset()
    }
    func invokeAndReset(_ block: ()->()) {
        block()
        reset()
    }
    func assertWeakRefThenReset(firstAction: (TestClass)->(), secondAction: ()->(), _ file: StaticString = #file, _ line: UInt = #line) {
        assertWeakRef(firstAction: firstAction, file, line, secondAction: secondAction)
        reset()
    }
}
