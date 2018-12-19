//
//  ViewController.swift
//  ImageFilter
//
//  Created by Ruslan Mavlyutov on 19/12/2018.
//  Copyright © 2018 Ruslan Mavlyutov. All rights reserved.
//

import UIKit

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
}

