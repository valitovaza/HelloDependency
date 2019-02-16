import XCTest

protocol DefaultInit {
    init()
}
extension XCTestCase {
    typealias ObjectWithDefaultInit = AnyObject & DefaultInit
    func assertWeakRef<T: ObjectWithDefaultInit>(message: String? = nil,
                                                 firstAction: (T)->(),
                                                 _ file: StaticString = #file,
                                                 _ line: UInt = #line,
                                                 secondAction: ()->()) {
        weak var weakObj: T?
        var obj: T? = T()
        weakObj = obj
        
        firstAction(obj!)
        
        secondAction()
        obj = nil
        
        if let message = message {
            XCTAssertNil(weakObj, message, file: file, line: line)
        }else{
            XCTAssertNil(weakObj, file: file, line: line)
        }
    }
}
