//
//  ViewController.swift
//  ImageFilter
//
//  Created by Ruslan Mavlyutov on 19/12/2018.
//  Copyright © 2018 Ruslan Mavlyutov. All rights reserved.
//

import UIKit
import Photos

final class ImageViewController:
    UIViewController,
    CroppableImageViewDelegateProtocol,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    UIPopoverControllerDelegate
{
    enum ImageSource: Int
    {
        case camera = 1
        case photoLibrary
    }

    func pickImageFromSource(
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
                self.present(
                    imagePicker,
                    animated: true)
                {
                    //println("In image picker completion block")
                }
            }
            else
            {
                self.present(
                    imagePicker,
                    animated: true)
                {
                    //println("In image picker completion block")
                }
                //        //Import from library on iPad
                //        let pickPhotoPopover = UIPopoverController.init(contentViewController: imagePicker)
                //        //pickPhotoPopover.delegate = self
                //        let buttonRect = fromButton.convertRect(
                //          fromButton.bounds,
                //          toView: self.view.window?.rootViewController?.view)
                //        imagePicker.delegate = self;
                //        pickPhotoPopover.presentPopoverFromRect(
                //          buttonRect,
                //          inView: self.view,
                //          permittedArrowDirections: UIPopoverArrowDirection.Any,
                //          animated: true)
                //
            }
        }
        else
        {
            self.present(
                imagePicker,
                animated: true)
            {
                print("In image picker completion block")
            }
        }
    }

    @IBOutlet weak var cropButton: UIButton!
    @IBOutlet weak var cancelFilterButton: UIBarButtonItem!
    @IBOutlet weak var whiteView: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet weak var cropView: CroppableImageView!

    private var originalImage: UIImage?
    private var filterModel: FilterModel?
//    private var selectedEffect = ImageFilter.sepia
    private var filteredImage: [UIImage] = []
    private var imageEditor = ImageEditor()

    override func viewDidAppear(_ animated: Bool) {
        let status = PHPhotoLibrary.authorizationStatus()
        if status != .authorized {
            PHPhotoLibrary.requestAuthorization() {
                status in
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        originalImage = imageView.image
        cancelFilterButton.isEnabled = false
        originalImage = cropView.imageToCrop
        filterModel = FilterModel()
        imageEditor.delegate = self
    }

    @IBAction func handleCropButton(_ sender: UIButton)
    {
        guard var targetZone = cropView.selectedArea() else { return }
        selectedAreaInCurrentDevice(for: &targetZone)
        applySelectedEffect(area: targetZone)
    }

    func selectedAreaInCurrentDevice(for area: inout CGRect)
    {
        let xScale = cropView.imageToCrop!.size.width / whiteView.frame.width
        if xScale > 1 {
            area.origin.x = area.origin.x * xScale
            area.origin.y = area.origin.y * xScale
            area.size.width = area.size.width * xScale
            area.size.height = area.size.height * xScale
        }
    }

    @IBAction func handleSelectEffectButton(_ sender: UIButton) {
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
                    self.imageEditor.selectedFilter = filter
            }
            )
            anActionSheet.addAction(action)
        }
        self.present(anActionSheet, animated: true)
        {
            //println("In action sheet completion block")
        }
    }

    @IBAction func handleSelectImgButton(_ sender: UIButton) {
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
//                self.cropView.imageToCrop = UIImage(named: "Scampers 6685")
                self.cropView.imageToCrop = UIImage(named: "Abu_dhabi_skylines_2014")
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

        self.present(anActionSheet, animated: true)
        {
            //println("In action sheet completion block")
        }
    }

    func applySelectedEffect(area: CGRect)
    {
        imageEditor.editingImage = cropView.imageToCrop
//        imageEditor.selectedFilter = imageEditor.filters[0]
        imageEditor.applySelectedFilter(in: area)
    }

    @IBAction func applySepia(_ sender: Any) {
        guard let image = imageView.image else {
            return
        }
        filterModel?.sepia(image, completion: { newImage in
            guard let img = newImage else { return }
            self.imageView.image = img
        })
    }

    @IBAction func applyPhotoTransferEffect(_ sender: Any) {
        guard let image = imageView.image else {
            return
        }
        filterModel?.photoEffectFilter(image, completion: { newImage in
            guard let img = newImage else { return }
            self.imageView.image = img
        })
    }

    @IBAction func applyBlur(_ sender: Any) {
        guard let image = imageView.image else {
            return
        }
        filterModel?.blur(image, completion: { newImage in
            guard let img = newImage else { return }
            self.imageView.image = img
        })
    }

    @IBAction func applyNoirEffect(_ sender: Any) {
        guard let image = imageView.image else {
            return
        }
        filterModel?.noir(image, completion: { newImage in
            guard let img = newImage else { return }
            self.imageView.image = img
        })
    }

    @IBAction func clearFilters(_ sender: Any) {
        imageView.image = originalImage
    }

    @IBAction func partImage(_ sender: Any) {
//        let targetZone = CGRect(x: -50, y: (self.imageView.image?.size.height)! - 120, width: (self.imageView.image?.size.width)! + 100, height: 220)
//        if let  resultImage = self.imageView.image?.applyBlurInRect(rect: targetZone, withRadius: 6.0) {
//            imageView.image = resultImage
//        }
    }

    @IBAction func saveImage(_ sender: Any) {
        guard let img = cropView.imageToCrop else { return }

        let alert = UIAlertController(title: "ImageFilter", message: "Your image has been saved to Photo Library", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            self.saveImageToCameraRoll(img)
            NSLog("The \"OK\" allert occured.")
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Default action"), style: .default, handler: { _ in
            NSLog("Canceled.")
        }))
        self.present(alert, animated: true, completion: nil)
    }

    func saveImageToCameraRoll(_ image: UIImage) {
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

    @IBAction func cancelPreviousFilter(_ sender: UIBarButtonItem) {
        cropView.imageToCrop = filteredImage.removeLast()
        if filteredImage.isEmpty {
            cancelFilterButton.isEnabled = false
        } else {
            cancelFilterButton.isEnabled = true
        }
    }

    func haveValidCropRect(_ haveValidCropRect:Bool)
    {
        //println("In haveValidCropRect. Value = \(haveValidCropRect)")
        cropButton.isEnabled = haveValidCropRect
    }

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [String : Any])
    {
        print("In \(#function)")
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            picker.dismiss(animated: true, completion: nil)
            cropView.imageToCrop = image
        }
        //cropView.setNeedsLayout()
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        print("In \(#function)")
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ImageViewController: ImageEditorDelegate {
    func imageEditor(_ editor: ImageEditor, didChangeImage image: UIImage) {
        print("delegate")
        cropView.imageToCrop = image
    }
}

