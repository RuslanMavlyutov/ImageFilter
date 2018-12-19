//
//  ViewController.swift
//  ImageFilter
//
//  Created by Ruslan Mavlyutov on 19/12/2018.
//  Copyright © 2018 Ruslan Mavlyutov. All rights reserved.
//

import UIKit
import CoreImage

class ViewController: UIViewController {

    struct Filter {
        let filterName: String
        var filterEffectValue: Any?
        var filterEffectValueName: String?

        init(filterName: String, filterEffectValue: Any?, filterEffectValueName: String?) {
            self.filterName = filterName
            self.filterEffectValue = filterEffectValue
            self.filterEffectValueName = filterEffectValueName
        }
    }

    @IBOutlet weak var imageView: UIImageView!
    private var originalImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        originalImage = imageView.image
        // Do any additional setup after loading the view, typically from a nib.
    }

    private func applyFilterTo(image: UIImage, filterEffect: Filter) -> UIImage? {
        guard let cgImage = image.cgImage, let openGLContext = EAGLContext(api: .openGLES3) else {
            return nil
        }
        let context = CIContext(eaglContext: openGLContext)
        let ciImage = CIImage(cgImage: cgImage)
        let filter = CIFilter(name: filterEffect.filterName)

        filter?.setValue(ciImage, forKey: kCIInputImageKey)

        if let filterEffectValue = filterEffect.filterEffectValue,
            let filterEffectValueName = filterEffect.filterEffectValueName {
            filter?.setValue(filterEffectValue, forKey: filterEffectValueName)
        }

        var filteredImage: UIImage?

        if let output = filter?.value(forKey: kCIOutputImageKey) as? CIImage,
            let cgiImageResult = context.createCGImage(output, from: output.extent) {
            filteredImage = UIImage(cgImage: cgiImageResult)
        }

        return filteredImage
    }

    @IBAction func applySepia(_ sender: Any) {
        guard let image = imageView.image else {
            return
        }
        imageView.image = applyFilterTo(image: image, filterEffect: Filter(filterName: "CISepiaTone", filterEffectValue: 0.90, filterEffectValueName: kCIInputIntensityKey))
    }

    @IBAction func applyPhotoTransferEffect(_ sender: Any) {
        guard let image = imageView.image else {
            return
        }
        imageView.image = applyFilterTo(image: image, filterEffect: Filter(filterName: "CIPhotoEffectProcess", filterEffectValue: nil, filterEffectValueName: kCIInputIntensityKey))
    }

    @IBAction func applyBlur(_ sender: Any) {
        guard let image = imageView.image else {
            return
        }
        imageView.image = applyFilterTo(image: image, filterEffect: Filter(filterName: "CIGaussianBlur", filterEffectValue: 3.0, filterEffectValueName: kCIInputRadiusKey))
    }

    @IBAction func applyNoirEffect(_ sender: Any) {
        guard let image = imageView.image else {
            return
        }
        imageView.image = applyFilterTo(image: image, filterEffect: Filter(filterName: "CIPhotoEffectNoir", filterEffectValue: nil, filterEffectValueName: nil))
    }

    @IBAction func clearFilters(_ sender: Any) {
        imageView.image = originalImage
    }
}

