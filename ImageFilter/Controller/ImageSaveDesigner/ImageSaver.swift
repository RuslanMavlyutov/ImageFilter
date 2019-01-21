import UIKit
import Photos

final class ImageSaver
{
    private let presenter: UIViewController

    init(presenter: UIViewController) {
        self.presenter = presenter
    }

    func saveImageToDevice(_ image: UIImage) {
        let alert = UIAlertController(title: "ImageFilter", message: "Your image will be saved to Photo Library", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            self.saveImageToCameraRoll(image)
            self.saveMessage()
            NSLog("The \"OK\" allert occured.")
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Default action"), style: .default, handler: { _ in
            NSLog("Canceled.")
        }))
        presenter.present(alert, animated: true, completion: nil)
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
    private func saveMessage() {
        let alert = UIAlertController(title: "ImageFilter", message: "Your image has been saved to Photo Library", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" allert occured.")
        }))
        presenter.present(alert, animated: true, completion: nil)
    }
}
