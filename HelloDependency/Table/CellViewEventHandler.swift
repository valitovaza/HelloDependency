protocol CellViewEventHandler {
    func onLoad()
}
protocol CellView {
    func show(title: String)
}
class CellViewEventHandlerImpl: CellViewEventHandler {
    private let data: TableData
    private let view: CellView
    init(_ data: TableData, _ view: CellView) {
        self.data = data
        self.view = view
    }
    func onLoad() {
        view.show(title: data.title)
    }
    deinit {
        print("CellViewEventHandlerImpl deallocation")
    }
}
