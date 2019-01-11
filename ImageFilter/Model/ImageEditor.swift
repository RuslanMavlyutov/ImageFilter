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

struct FilterName {
    static let sepiaFilter = "CISepiaTone"
    static let photoEffectFilter = "CIPhotoEffectProcess"
    static let blurFilter = "CIGaussianBlur"
    static let noirFilter = "CIPhotoEffectNoir"
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

extension UIImage {
    func imageFromRect(_ rect: CGRect) -> UIImage? {
        if let cg = self.cgImage,
            let subImage = cg.cropping(to: rect) {
            return UIImage(cgImage: subImage)
        }
        return nil
    }

    func drawImageInRect(inputImage: UIImage, inRect imageRect: CGRect) -> UIImage? {
        UIGraphicsBeginImageContext(self.size)
        self.draw(in: CGRect(x:0.0, y:0.0, width:self.size.width, height:self.size.height))
        inputImage.draw(in: imageRect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    func filterImage(filterEffect: String) -> UIImage? {
        let inputImage = UIKit.CIImage(cgImage: self.cgImage!)
        if let filter = CIFilter(name: filterEffect) {
            filter.setValue(inputImage, forKey: kCIInputImageKey)
            if filterEffect == FilterName.blurFilter {
                filter.setValue(6.0, forKey: kCIInputRadiusKey)
            } else if filterEffect == FilterName.sepiaFilter {
                filter.setValue(0.90, forKey: kCIInputIntensityKey)
            }
            if let effectImg = filter.outputImage {
                return UIImage(ciImage: effectImg)
            }
        }
        return nil
    }

    func applyFilterRect(filter: String, rect: CGRect?, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] () -> Void in
            if let area = rect {
                if let subImage = self?.imageFromRect(area),
                    let filteredZone = subImage.filterImage(filterEffect: filter) {
                    if let img = self?.drawImageInRect(inputImage: filteredZone, inRect: area) {
                        DispatchQueue.main.async { () -> Void in
                            completion(img)
                        }
                    }
                }
            } else {
                if let img = self?.filterImage(filterEffect: filter) {
                    let area = CGRect(x:0.0, y:0.0, width:img.size.width, height:img.size.height)
                    if let img = self?.drawImageInRect(inputImage: img, inRect: area) {
                        DispatchQueue.main.async { () -> Void in
                            completion(img)
                        }
                    }
                }
            }
        }
    }
}
