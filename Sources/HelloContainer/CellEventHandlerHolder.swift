public protocol CellEventHandlerHolder {
    associatedtype EventHandler
    func set(eventHandler: EventHandler)
}
