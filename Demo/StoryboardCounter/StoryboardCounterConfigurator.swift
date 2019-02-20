import Foundation
import HelloDependency
import UIKitDependencyHelper

class StoryboardCounterConfigurator: NSObject {
    @IBOutlet weak var vc: StoryboardCounterViewController? {
        didSet {
            guard let vc = vc else { return }
            HelloDependency.register(CounterView.self, forIdentifier: storyboardExample, WeakBox(vc))
            HelloDependency.register(CounterViewEventHandler.self, forIdentifier: storyboardExample,
            {
                let counterVc = HelloDependency.resolve(CounterView.self, forIdentifier: storyboardExample)
                let incrementCountLabelView = HelloDependency.resolve(IncrementCountLabelView.self, forIdentifier: storyboardExample)
                return CounterViewEventHandlerImpl(counterVc, incrementCountLabelView)
            })
            vc.eventHandler = HelloDependency.resolve(CounterViewEventHandler.self, forIdentifier: storyboardExample)
        }
    }
}
