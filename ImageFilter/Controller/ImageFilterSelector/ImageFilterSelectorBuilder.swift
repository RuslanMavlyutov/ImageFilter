import Foundation
import UIKit

final class ImageFilterSelectorBuilder
{
    var delegate: ImageFilterSelectorBuilderDelegate?

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
                    self.delegate?.selectFilter(filter)
            }
            )
            anActionSheet.addAction(action)
        }
        self.delegate?.filterActionSheet(anActionSheet)
    }
}

protocol ImageFilterSelectorBuilderDelegate {
    func selectFilter(_ filter: ImageFilter)
    func filterActionSheet(_ anActionSheet: UIAlertController)
}
