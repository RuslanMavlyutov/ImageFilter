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
    @IBOutlet weak var applyFilterButton: UIButton!
    @IBOutlet weak var cancelFilterButton: UIBarButtonItem!
    @IBOutlet weak var chooseFilterButton: UIButton!
    @IBOutlet weak var saveImageButton: UIBarButtonItem!
    @IBOutlet weak var whiteView: UIView!
    @IBOutlet weak var cropView: CroppableImageView!

    private var originalImage: UIImage?
    private var imageEditor = ImageEditor()
    lazy private var imageSelector = ImageSelector(presenter: self)
    lazy private var imageSaver = ImageSaver(presenter: self)
    lazy private var imageFilterSelector = ImageFilterSelector(presenter: self)

    override func viewDidLoad() {
        super.viewDidLoad()
        cancelFilterButton.isEnabled = false
        saveImageButton.isEnabled = false
        applyFilterButton.isEnabled = false
        originalImage = cropView.imageToCrop
        initDelegate()
    }

    func initDelegate() {
        imageEditor.delegate = self
        imageFilterSelector.delegate = self
    }

    func checkPhotoLibraryAccess() {
        let status = PHPhotoLibrary.authorizationStatus()
        if status != .authorized {
            PHPhotoLibrary.requestAuthorization() {
                status in
            }
        }
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
        imageFilterSelector.imageFilterSelector(imageEditor)
    }

    @IBAction func handleSelectImgButton(_ sender: UIButton) {
        checkPhotoLibraryAccess()
        imageSelector.imageSelector(sender, imageEditor)
    }

    func applySelectedEffect(area: CGRect?)
    {
        imageEditor.editingImage = cropView.imageToCrop
//        imageEditor.selectedFilter = imageEditor.filters[0]
        imageEditor.applySelectedFilter(in: area)
    }

    @IBAction func saveImage(_ sender: Any) {
        guard let img = cropView.imageToCrop else { return }
        imageSaver.saveImageToDevice(img)
    }

    @IBAction func cancelPreviousFilter(_ sender: UIBarButtonItem) {
        imageEditor.revertSelectedFilter()
    }
}

extension ImageViewController: ImageFilterSelectorDelegate {
    func filterSelector(_ selector: ImageFilterSelector, didSelect filterName: String) {
        self.imageEditor.selectedFilter = filterName
        chooseFilterButton.setTitle(filterName, for: .normal)
        applyFilterButton.isEnabled = true
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
        cropView.imageToCrop = image
        if !imageEditor.savedFilter.isEmpty() {
            cancelFilterButton.isEnabled = true
            saveImageButton.isEnabled = true
        } else {
            cancelFilterButton.isEnabled = false
            saveImageButton.isEnabled = false
        }
    }
}

