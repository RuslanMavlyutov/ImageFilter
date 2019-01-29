import UIKit

protocol ImageSelectorDelegate: class {
    func imageSelector(_ selector: ImageSelector, didSelect image: UIImage)
}

final class ImageSelector: UIViewController
{
    private let presenter: UIViewController

    init(presenter: UIViewController) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    weak var delegate: ImageSelectorDelegate?
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    enum ImageSource: Int
    {
        case camera = 1
        case photoLibrary
    }

    func selectImageFromDevice(_ sender: UIButton) {
        let deviceHasCamera: Bool = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        print("In \(#function)")
        
        //Create an alert controller that asks the user what type of image to choose.
        let anActionSheet =  UIAlertController(title: "Pick Image Source",
                                               message: nil,
                                               preferredStyle: UIAlertControllerStyle.actionSheet)
        
        //Offer the option to re-load the starting sample image
        let sampleAction = UIAlertAction(
            title:"Load Sample Image",
            style: UIAlertActionStyle.default,
            handler:
            {
                (alert: UIAlertAction)  in
                if let image = UIImage(named: "Abu_dhabi_skylines_2014") {
                    self.delegate?.imageSelector(self, didSelect: image)
                }
        }
        )
        
        //If the current device has a camera, add a "Take a New Picture" button
        var takePicAction: UIAlertAction? = nil
        if deviceHasCamera
        {
            takePicAction = UIAlertAction(
                title: "Take a New Picture",
                style: UIAlertActionStyle.default,
                handler:
                {
                    (alert: UIAlertAction)  in
                    self.pickImageFromSource(
                        ImageSource.camera,
                        fromButton: sender)
            }
            )
        }
        
        //Allow the user to select an amage from their photo library
        let selectPicAction = UIAlertAction(
            title:"Select Picture from library",
            style: UIAlertActionStyle.default,
            handler:
            {
                (alert: UIAlertAction)  in
                self.pickImageFromSource(
                    ImageSource.photoLibrary,
                    fromButton: sender)
        }
        )
        
        let cancelAction = UIAlertAction(
            title:"Cancel",
            style: UIAlertActionStyle.cancel,
            handler:
            {
                (alert: UIAlertAction)  in
                print("User chose cancel button")
        }
        )
        anActionSheet.addAction(sampleAction)
        
        if let requiredtakePicAction = takePicAction
        {
            anActionSheet.addAction(requiredtakePicAction)
        }
        anActionSheet.addAction(selectPicAction)
        anActionSheet.addAction(cancelAction)
        
        let popover = anActionSheet.popoverPresentationController
        popover?.sourceView = sender
        popover?.sourceRect = sender.bounds;

        presenter.present(anActionSheet, animated: true, completion: nil)
    }

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [String : Any])
    {
        print("In \(#function)")
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            picker.dismiss(animated: true, completion: nil)
            self.delegate?.imageSelector(self, didSelect: image)
        }
        //cropView.setNeedsLayout()
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        print("In \(#function)")
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ImageSelector:
    UINavigationControllerDelegate,
    UIImagePickerControllerDelegate {
    private func pickImageFromSource(
        _ theImageSource: ImageSource,
        fromButton: UIButton)
    {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        switch theImageSource
        {
        case .camera:
            print("User chose take new pic button")
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.cameraDevice = UIImagePickerControllerCameraDevice.front;
        case .photoLibrary:
            print("User chose select pic button")
            imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
        }
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            if theImageSource == ImageSource.camera
            {
                presenter.present(imagePicker, animated: true, completion: nil)
            }
            else
            {
                presenter.present(imagePicker, animated: true, completion: nil)
//                self.present(
//                    imagePicker,
//                    animated: true)
//                {
//                    //println("In image picker completion block")
//                }
//                //        //Import from library on iPad
//                //        let pickPhotoPopover = UIPopoverController.init(contentViewController: imagePicker)
//                //        //pickPhotoPopover.delegate = self
//                //        let buttonRect = fromButton.convertRect(
//                //          fromButton.bounds,
//                //          toView: self.view.window?.rootViewController?.view)
//                //        imagePicker.delegate = self;
//                //        pickPhotoPopover.presentPopoverFromRect(
//                //          buttonRect,
//                //          inView: self.view,
//                //          permittedArrowDirections: UIPopoverArrowDirection.Any,
//                //          animated: true)
//                //
            }
        }
        else
        {
            presenter.present(imagePicker, animated: true, completion: nil)
        }
    }
}
