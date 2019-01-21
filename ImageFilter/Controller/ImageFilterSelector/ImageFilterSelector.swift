import UIKit

protocol ImageFilterSelectorDelegate: class {
    func filterSelector(_ selector: ImageFilterSelector, didSelect filter: ImageFilter)
}

final class ImageFilterSelector
{
    private let presenter: UIViewController

    init(presenter: UIViewController) {
        self.presenter = presenter
    }
    weak var delegate: ImageFilterSelectorDelegate?

    func imageFilterSelector(_ imageEditor: ImageEditor) {
        let anActionSheet =  UIAlertController(title: "Choose Filter Image",
                                               message: nil,
                                               preferredStyle: UIAlertControllerStyle.actionSheet)

        for filter in imageEditor.filters {
            let action = UIAlertAction(title: filter.name,
                                       style: UIAlertActionStyle.default,
                                       handler:
                {
                    (alert: UIAlertAction)  in
                    print(filter.name)
                    self.delegate?.filterSelector(self, didSelect: filter)
            }
            )
            anActionSheet.addAction(action)
        }
        presenter.present(anActionSheet, animated: true, completion: nil)
    }
}
