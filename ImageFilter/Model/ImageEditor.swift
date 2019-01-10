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
        if let subImage = image.imageFromRect(rect!) {
            let inputImage = UIKit.CIImage(cgImage: subImage.cgImage!)
            var filteredZone = UIImage()
            if let filter = CIFilter(name: FilterName.sepiaFilter) {
                filter.setValue(inputImage, forKey: kCIInputImageKey)
                filter.setValue(0.90, forKey: kCIInputIntensityKey)
                if let effectImg = filter.outputImage {
                    filteredZone = UIImage(ciImage: effectImg)
                }
            }
            if let img = image.drawImageInRect(inputImage: filteredZone, inRect: rect!) {
                completion(img)
            }
        } else {
            completion(nil)
        }
    }
    var name: String = FilterShortNames.sepia
}

final class BlurImageFilter: ImageFilter {
    func apply(to image: UIImage, in rect: CGRect?, completion: @escaping (UIImage?) -> Void) {
        if let subImage = image.imageFromRect(rect!) {
            let inputImage = UIKit.CIImage(cgImage: subImage.cgImage!)
            var filteredZone = UIImage()
            if let filter = CIFilter(name: FilterName.blurFilter) {
                filter.setValue(inputImage, forKey: kCIInputImageKey)
                filter.setValue(6.0, forKey: kCIInputRadiusKey)
                if let effectImg = filter.outputImage {
                    filteredZone = UIImage(ciImage: effectImg)
                }
            }
            if let img = image.drawImageInRect(inputImage: filteredZone, inRect: rect!) {
                completion(img)
            }
        } else {
            completion(nil)
        }
    }
    var name: String = FilterShortNames.blur
}

protocol ImageEditorDelegate {
    func imageEditor(_ editor: ImageEditor, didChangeImage image: UIImage)
}

final class ImageEditor {
    let filters = [
        SepiaImageFilter(),
        BlurImageFilter()
        ] as [ImageFilter]
    
    var selectedFilter: ImageFilter?
    var delegate: ImageEditorDelegate?
    var editingImage: UIImage?
    
    func applySelectedFilter(in rect: CGRect) {
        selectedFilter?.apply(to: editingImage!, in: rect, completion: { img in
            self.editingImage = img
            self.delegate?.imageEditor(self, didChangeImage: self.editingImage!)
        })
    }
}

//protocol ImageFilterDelegate {
//    func editedImage() -> UIImage
//}
