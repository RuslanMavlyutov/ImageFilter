import Foundation
import UIKit
import CoreImage

struct FilterName {
    static let  sepiaFilter = "CISepiaTone"
    static let  photoEffectFilter = "CIPhotoEffectProcess"
    static let  blurFilter = "CIGaussianBlur"
    static let  noirFilter = "CIPhotoEffectNoir"
}

final class FilterModel {

    private let queue = DispatchQueue.global(qos: .userInitiated)

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

    func applyFilterTo(image: UIImage, filterEffect: Filter, completion: @escaping (UIImage?) -> Void) {
        queue.async { () -> Void in
            guard let cgImage = image.cgImage, let openGLContext = EAGLContext(api: .openGLES3) else {
                return
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
            DispatchQueue.main.async { () -> Void in
                completion(filteredImage)
            }
        }
    }

    func sepia(_ image: UIImage, completion: @escaping (UIImage?) -> Void) {
        applyFilterTo(image: image, filterEffect: Filter(filterName: FilterName.sepiaFilter,
                                                         filterEffectValue: 0.90,
                                                         filterEffectValueName: kCIInputIntensityKey)) { newImage in
            completion(newImage)
        }
    }

    func photoEffectFilter(_ image: UIImage, completion: @escaping (UIImage?) -> Void) {
        return applyFilterTo(image: image, filterEffect: Filter(filterName: FilterName.photoEffectFilter,
                                                                filterEffectValue: nil,
                                                                filterEffectValueName: kCIInputIntensityKey)) { newImage in
            completion(newImage)
        }
    }

    func blur(_ image: UIImage, completion: @escaping (UIImage?) -> Void) {
        return applyFilterTo(image: image, filterEffect: Filter(filterName: FilterName.blurFilter,
                                                                filterEffectValue: 3.0,
                                                                filterEffectValueName: kCIInputRadiusKey)) { newImage in
            completion(newImage)
        }
    }

    func noir(_ image: UIImage, completion: @escaping (UIImage?) -> Void) {
        return applyFilterTo(image: image, filterEffect: Filter(filterName: FilterName.noirFilter,
                                                                filterEffectValue: nil,
                                                                filterEffectValueName: nil)) { newImage in
            completion(newImage)
        }
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

    func filterImage(filterEffect: ImageFilter) -> UIImage? {
//        let inputImage = UIKit.CIImage(cgImage: self.cgImage!)
//
//        var nameFilter: String
//        var key = String()
//        switch filterEffect {
//        case .blur:
//            nameFilter = FilterName.blurFilter
//            key = kCIInputRadiusKey
//        case .sepia:
//            nameFilter = FilterName.sepiaFilter
//            key = kCIInputIntensityKey
//        case .photoEffect:
//            nameFilter = FilterName.photoEffectFilter
//        case .noir:
//            nameFilter = FilterName.noirFilter
//        }
//
//        if let filter = CIFilter(name: nameFilter) {
//            filter.setValue(inputImage, forKey: kCIInputImageKey)
//            if filterEffect == .blur {
//                filter.setValue(6.0, forKey: key)
//            } else if filterEffect == .sepia {
//                filter.setValue(0.90, forKey: key)
//            }
//            if let effectImg = filter.outputImage {
//                return UIImage(ciImage: effectImg)
//            }
//        }
        return nil
    }

    func applyFilterRect(filter: ImageFilter, rect: CGRect, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] () -> Void in
            if let subImage = self?.imageFromRect(rect),
                let filteredZone = subImage.filterImage(filterEffect: filter) {
                if let img = self?.drawImageInRect(inputImage: filteredZone, inRect: rect) {
                    DispatchQueue.main.async { () -> Void in
                        completion(img)
                    }
                }
            }
        }
    }
}
