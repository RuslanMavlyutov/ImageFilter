import Foundation
import UIKit
import Photos

final class ImageSaveBuilder
{
    var delegate: ImageSaveBuilderDelegate?

    func saveImageToDevice(_ image: UIImage) {
        let alert = UIAlertController(title: "ImageFilter", message: "Your image has been saved to Photo Library", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            self.saveImageToCameraRoll(image)
            NSLog("The \"OK\" allert occured.")
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Default action"), style: .default, handler: { _ in
            NSLog("Canceled.")
        }))
        delegate?.saveActionSheet(alert)
    }
    private func saveImageToCameraRoll(_ image: UIImage) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }, completionHandler: { success, error in
            if success {
                // Saved successfully!
            } else if let error = error {
                print("Save failed with error " + String(describing: error))
            } else {
            }
        })
    }
}

protocol ImageSaveBuilderDelegate {
    func saveActionSheet(_ alert: UIAlertController)
}
