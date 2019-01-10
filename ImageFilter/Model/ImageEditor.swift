import Foundation
import CoreImage
import UIKit

protocol ImageFilter {
    var name: String { get }
    func apply(to image: UIImage, in rect: CGRect?, completion: @escaping (UIImage?) -> Void)
//    func revert(completion: )
}

struct FilterShortNames {
    static let sepia = "Sepia"
    static let blur = "Blur"
    static let photoEffect = "Photo Effect"
    static let noir = "Noir"
}

final class SepiaImageFilter: ImageFilter {
    func apply(to image: UIImage, in rect: CGRect?, completion: @escaping (UIImage?) -> Void) {
        image.applyFilterRect(filter: FilterName.sepiaFilter, rect: rect) { img in
            completion(img)
        }
    }
    var name = FilterShortNames.sepia
}

final class BlurImageFilter: ImageFilter {
    func apply(to image: UIImage, in rect: CGRect?, completion: @escaping (UIImage?) -> Void) {
        image.applyFilterRect(filter: FilterName.blurFilter, rect: rect) { img in
            completion(img)
        }
    }
    var name: String = FilterShortNames.blur
}

final class PhotoEffectImageFilter: ImageFilter {
    func apply(to image: UIImage, in rect: CGRect?, completion: @escaping (UIImage?) -> Void) {
        image.applyFilterRect(filter: FilterName.photoEffectFilter, rect: rect) { img in
            completion(img)
        }
    }
    var name: String = FilterShortNames.photoEffect
}

final class NoirImageFilter: ImageFilter {
    func apply(to image: UIImage, in rect: CGRect?, completion: @escaping (UIImage?) -> Void) {
        image.applyFilterRect(filter: FilterName.noirFilter, rect: rect) { img in
            completion(img)
        }
    }
    var name: String = FilterShortNames.noir
}

protocol ImageEditorDelegate {
    func imageEditor(_ editor: ImageEditor, didChangeImage image: UIImage)
}

final class ImageEditor {
    let filters = [
        SepiaImageFilter(),
        BlurImageFilter(),
        PhotoEffectImageFilter(),
        NoirImageFilter()
        ] as [ImageFilter]
    
    var selectedFilter: ImageFilter?
    var delegate: ImageEditorDelegate?
    var editingImage: UIImage?
    
    func applySelectedFilter(in rect: CGRect?) {
        selectedFilter?.apply(to: editingImage!, in: rect, completion: { img in
            self.editingImage = img
            self.delegate?.imageEditor(self, didChangeImage: self.editingImage!)
        })
    }
}
