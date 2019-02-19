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
    @IBOutlet weak var addStickerButton: UIBarButtonItem!
    @IBOutlet weak var fixButton: UIBarButtonItem!
    @IBOutlet weak var faceDetectionButton: UIBarButtonItem!
    @IBOutlet weak var undoButton: UIBarButtonItem!

    private var originalImage: UIImage?
    private var imageEditor = ImageEditor()
    lazy private var imageSelector = ImageSelector(presenter: self)
    lazy private var imageSaver = ImageSaver(presenter: self)
    lazy private var imageFilterSelector = ImageFilterSelector(presenter: self)
    lazy private var faceDetection = FaceDetectionConstructor(presenter: self, view: cropView)

    override func viewDidLoad() {
        super.viewDidLoad()
        cancelFilterButton.isEnabled = false
        saveImageButton.isEnabled = false
        applyFilterButton.isEnabled = false
        fixButton.isEnabled = false
        originalImage = cropView.imageToCrop
        initStyleBarButton()
        initDelegate()
    }

    enum faceButtonTitle: String {
        case add = "Face Detection"
        case clear = "Clear"
    }

    func initStyleBarButton() {
        guard let font = UIFont(name: "Helvetica-Bold", size: 12) else { return }

        for controlState in [UIControlState.normal, UIControlState.disabled, UIControlState.focused,
                             UIControlState.highlighted, UIControlState.selected] {
            addStickerButton.setTitleTextAttributes([NSAttributedStringKey.font: font], for: controlState)
            fixButton.setTitleTextAttributes([NSAttributedStringKey.font: font], for: controlState)
            faceDetectionButton.setTitleTextAttributes([NSAttributedStringKey.font: font], for: controlState)
            undoButton.setTitleTextAttributes([NSAttributedStringKey.font: font], for: controlState)
            saveImageButton.setTitleTextAttributes([NSAttributedStringKey.font: font], for: controlState)
        }
    }

    func initDelegate() {
        imageEditor.delegate = self
        imageSelector.delegate = self
        imageFilterSelector.delegate = self
        faceDetection.delegate = self
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
        imageFilterSelector.selectFilterFrom(filters: imageEditor.filters)
    }

    @IBAction func handleSelectImgButton(_ sender: UIButton) {
        checkPhotoLibraryAccess()
        imageSelector.selectImageFromDevice(sender)
    }

    func applySelectedEffect(area: CGRect?)
    {
        imageEditor.editingImage = cropView.imageToCrop
//        imageEditor.selectedFilter = imageEditor.filters[0]
        imageEditor.applySelectedFilter(in: area)
    }

    @IBAction func saveImage(_ sender: Any) {
        guard let img = cropView.imageToCrop else { return }

        if !cropView.draggersSticker.isEmpty, let imageWithSticker = cropView.imageWithSticker() {
           imageSaver.saveImageToDevice(imageWithSticker)
            return
        }
        imageSaver.saveImageToDevice(img)
    }

    @IBAction func cancelPreviousFilter(_ sender: UIBarButtonItem) {
        imageEditor.revertSelectedFilter()
    }

    @IBAction func addSticker(_ sender: UIBarButtonItem) {
        if let vc = viewController() {
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    @IBAction func fixStickerForImage(_ sender: UIBarButtonItem) {
        cropView.isEnabledSelectedArea = true
        stateFixButton(false)
    }

    func viewController() -> StickerViewController? {
        return UIStoryboard.init(
            name: "Main", bundle: Bundle.main)
            .instantiateViewController(withIdentifier: "stickerView"
            ) as? StickerViewController
    }

    func putStickerToImage(sticker image: UIImage) {
        cropView.putStickerToImage(sticker: image)
        stateFixButton(true)
    }

    func stateFixButton(_ isEnabled : Bool) {
        fixButton.isEnabled = isEnabled
    }

    @IBAction func faceDetectionProcess(_ sender: UIBarButtonItem) {
        switch faceDetectionButton.title {
        case faceButtonTitle.add.rawValue:
            faceDetection.detectFace()
        case faceButtonTitle.clear.rawValue:
            faceDetection.removeBoxView()
        default:
            print("Failed title")
            break
        }
    }

    func resetAddingStickerAndFaceDetection() {
        if !cropView.draggersSticker.isEmpty {
            cropView.removeSticker()
            cropView.draggersSticker.removeAll()
        }
        faceDetection.removeBoxView()
    }
}

extension ImageViewController: FaceDetectionConstructorDelegate {
    func faceSelectorDidDetectFaces(_ selector: FaceDetectionConstructor) {
        faceDetectionButton.title = faceButtonTitle.clear.rawValue
    }
    func faceSelectorDidNotDetectFaces(_ selector: FaceDetectionConstructor) {
        faceDetectionButton.title = faceButtonTitle.add.rawValue
    }
}

extension ImageViewController: ImageSelectorDelegate {
    func imageSelector(_ selector: ImageSelector, didSelect image: UIImage) {
        imageEditor.editingImage = image
        resetAddingStickerAndFaceDetection()
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
    func haveStickerForImage(_ haveStickerForImage:Bool)
    {
        fixButton.isEnabled = !haveStickerForImage
        saveImageButton.isEnabled = !haveStickerForImage
    }
}

extension ImageViewController: StickerViewControllerDelegate {
    func imageSelector(_ ctrl: StickerViewController,
                       didSelectImage image: UIImage)
    {
        navigationController?.popViewController(animated: true)
        putStickerToImage(sticker: image)
    }
}

extension ImageViewController: ImageEditorDelegate {
    func imageEditor(_ editor: ImageEditor, didChangeImage image: UIImage) {
        cropView.imageToCrop = image
        if imageEditor.canUndo {
            cancelFilterButton.isEnabled = true
            saveImageButton.isEnabled = true
        } else {
            cancelFilterButton.isEnabled = false
            if cropView.draggersSticker.isEmpty {
                saveImageButton.isEnabled = false
            }
        }
    }
}

