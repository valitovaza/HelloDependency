protocol CounterViewEventHandler {
    func onDidLoad()
    func increment()
}
protocol CounterView {
    func setCountLabel(text: String)
}
protocol IncrementCountLabelView {
    func setIncrementCount(text: String)
}
class CounterViewEventHandlerImpl: CounterViewEventHandler {
    private var count = 0
    
    private let view: CounterView
    private let otherView: IncrementCountLabelView
    init(_ view: CounterView, _ otherView: IncrementCountLabelView) {
        self.view = view
        self.otherView = otherView
    }
    func onDidLoad() {
        updateViews()
    }
    func increment() {
        handleIncrement()
        updateViews()
    }
    private func handleIncrement() {
        count += 1
    }
    private func updateViews() {
        view.setCountLabel(text: String(count))
        otherView.setIncrementCount(text: "Increments: \(count)")
    }
}
