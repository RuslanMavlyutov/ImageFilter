import Foundation
import UIKit
import CoreImage

final class FilterModel {

    private let queue = DispatchQueue.global(qos: .userInitiated)

    struct FilterName {
        static let  sepiaFilter = "CISepiaTone"
        static let  photoEffectFilter = "CIPhotoEffectProcess"
        static let  blurFilter = "CIGaussianBlur"
        static let  noirFilter = "CIPhotoEffectNoir"
    }

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
