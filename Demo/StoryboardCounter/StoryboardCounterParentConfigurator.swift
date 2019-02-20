import Foundation
import HelloDependency

let storyboardExample = "storyboardConfiguration"

class StoryboardCounterParentConfigurator: NSObject {
    @IBOutlet weak var vc: StoryboardCounterParentViewController? {
        didSet {
            guard let vc = vc else { return }
            HelloDependency.register(IncrementCountLabelView.self, forIdentifier: storyboardExample, WeakBox(vc))
        }
    }
}
