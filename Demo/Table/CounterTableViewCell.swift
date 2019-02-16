import UIKit

class CounterTableViewCell: UITableViewCell {
    private(set) var cellViewController: CellViewController?
    
    func initializeContentViewOptionally(_ parentViewController: UIViewController) {
        guard cellViewController == nil else { return }
        let vc = createCellViewController()
        addChild(vc, parentViewController)
        cellViewController = vc
    }
    private func createCellViewController() -> CellViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CellViewController") as! CellViewController
    }
    private func addChild(_ contentVc: UIViewController,
                          _ parentViewController: UIViewController) {
        parentViewController.addChild(contentVc)
        contentVc.view.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(contentVc.view)
        NSLayoutConstraint.activate([
            contentVc.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            contentVc.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            contentVc.view.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            contentVc.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])
        contentVc.didMove(toParent: parentViewController)
    }
}
