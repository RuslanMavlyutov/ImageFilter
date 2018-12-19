//
//  ViewController.swift
//  ImageFilter
//
//  Created by Ruslan Mavlyutov on 19/12/2018.
//  Copyright © 2018 Ruslan Mavlyutov. All rights reserved.
//

import UIKit
import CoreImage

final class ImageViewController: UIViewController {

    private var filterModel: FilterModel?

    @IBOutlet private weak var imageView: UIImageView!
    private var originalImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        originalImage = imageView.image
        filterModel = FilterModel()
    }

    @IBAction func applySepia(_ sender: Any) {
        guard let image = imageView.image else {
            return
        }
        imageView.image = filterModel?.sepia(image)
    }

    @IBAction func applyPhotoTransferEffect(_ sender: Any) {
        guard let image = imageView.image else {
            return
        }
        imageView.image = filterModel?.photoEffectFilter(image)
    }

    @IBAction func applyBlur(_ sender: Any) {
        guard let image = imageView.image else {
            return
        }
        imageView.image = filterModel?.blur(image)
    }

    @IBAction func applyNoirEffect(_ sender: Any) {
        guard let image = imageView.image else {
            return
        }
        imageView.image = filterModel?.noir(image)
    }

    @IBAction func clearFilters(_ sender: Any) {
        imageView.image = originalImage
    }
}

