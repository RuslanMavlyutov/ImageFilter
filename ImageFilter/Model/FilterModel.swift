import Foundation
import UIKit
import CoreImage

final class FilterModel {

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

    func applyFilterTo(image: UIImage, filterEffect: Filter) -> UIImage? {
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

    func sepia(_ image: UIImage) -> UIImage? {
        return applyFilterTo(image: image, filterEffect: Filter(filterName: FilterName.sepiaFilter,
                                                                filterEffectValue: 0.90,
                                                                filterEffectValueName: kCIInputIntensityKey))
    }

    func photoEffectFilter(_ image: UIImage) -> UIImage? {
        return applyFilterTo(image: image, filterEffect: Filter(filterName: FilterName.photoEffectFilter,
                                                                filterEffectValue: nil,
                                                                filterEffectValueName: kCIInputIntensityKey))
    }

    func blur(_ image: UIImage) -> UIImage? {
        return applyFilterTo(image: image, filterEffect: Filter(filterName: FilterName.blurFilter,
                                                                filterEffectValue: 3.0,
                                                                filterEffectValueName: kCIInputRadiusKey))
    }

    func noir(_ image: UIImage) -> UIImage? {
        return applyFilterTo(image: image, filterEffect: Filter(filterName: FilterName.noirFilter,
                                                                filterEffectValue: nil,
                                                                filterEffectValueName: nil))
    }
}
