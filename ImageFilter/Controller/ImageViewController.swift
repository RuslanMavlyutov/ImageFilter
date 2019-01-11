//
//  ViewController.swift
//  ImageFilter
//
//  Created by Ruslan Mavlyutov on 19/12/2018.
//  Copyright © 2018 Ruslan Mavlyutov. All rights reserved.
//

import UIKit
import Photos

final class ImageViewController: UIViewController
{
    @IBOutlet weak var cropButton: UIButton!
    @IBOutlet weak var cancelFilterButton: UIBarButtonItem!
    @IBOutlet weak var whiteView: UIView!
    @IBOutlet weak var cropView: CroppableImageView!

    private var originalImage: UIImage?
    private var imageEditor = ImageEditor()
    private var imageSelectorBuilder = ImageSelectorBuilder()
    private var imageSaveBuilder = ImageSaveBuilder()
    private var imageFilterSelectorBuilder = ImageFilterSelectorBuilder()

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
        cancelFilterButton.isEnabled = false
        originalImage = cropView.imageToCrop
        initDelegate()
    }

    func initDelegate() {
        imageEditor.delegate = self
        imageSelectorBuilder.delegate = self
        imageSaveBuilder.delegate = self
        imageFilterSelectorBuilder.delegate = self
    }

    @IBAction func handleCropButton(_ sender: UIButton)
    {
        guard var targetZone = cropView.selectedArea() else {
            applySelectedEffect(area: nil)
            return
        }
        let scale = cropView.imageToCrop!.size.width / whiteView.frame.width
        RectSizeConstructor.selectedAreaInCurrentDevice(for: &targetZone, xScale: scale)
        applySelectedEffect(area: targetZone)
    }

    @IBAction func handleSelectEffectButton(_ sender: UIButton) {
        imageFilterSelectorBuilder.imageFilterSelector(imageEditor)
    }

    @IBAction func handleSelectImgButton(_ sender: UIButton) {
        imageSelectorBuilder.imageSelector(sender)
    }

    func applySelectedEffect(area: CGRect?)
    {
        imageEditor.editingImage = cropView.imageToCrop
//        imageEditor.selectedFilter = imageEditor.filters[0]
        imageEditor.applySelectedFilter(in: area)
    }

    @IBAction func saveImage(_ sender: Any) {
        guard let img = cropView.imageToCrop else { return }
        imageSaveBuilder.saveImageToDevice(img)
    }

    @IBAction func cancelPreviousFilter(_ sender: UIBarButtonItem) {
//        cropView.imageToCrop = filteredImage.removeLast()
//        if filteredImage.isEmpty {
//            cancelFilterButton.isEnabled = false
//        } else {
//            cancelFilterButton.isEnabled = true
//        }
    }
}

extension ImageViewController: ImageSelectorBuilderDelegate {
    func loadSelectedImage(_ image: UIImage) {
        self.cropView.imageToCrop = image
    }
    func loadActionSheet(_ anActionSheet: UIAlertController) {
        self.present(anActionSheet, animated: true)
        {
            //println("In action sheet completion block")
        }
    }
    func pickImageFromDevice(_ imagePicker: UIImagePickerController) {
        self.present(imagePicker, animated: true)
    }
}

extension ImageViewController: ImageSaveBuilderDelegate {
    func saveActionSheet(_ alert: UIAlertController) {
        self.present(alert, animated: true, completion: nil)
    }
}

extension ImageViewController: ImageFilterSelectorBuilderDelegate {
    func selectFilter(_ filter: ImageFilter) {
        self.imageEditor.selectedFilter = filter
    }
    func filterActionSheet(_ anActionSheet: UIAlertController) {
        self.present(anActionSheet, animated: true)
        {
            //println("In action sheet completion block")
        }
    }
}

extension ImageViewController: CroppableImageViewDelegateProtocol {
    func haveValidCropRect(_ haveValidCropRect:Bool)
    {
        print("In haveValidCropRect. Value = \(haveValidCropRect)")
//        cropButton.isEnabled = haveValidCropRect
    }
}

extension ImageViewController: ImageEditorDelegate {
    func imageEditor(_ editor: ImageEditor, didChangeImage image: UIImage) {
        print("delegate")
        cropView.imageToCrop = image
    }
}

