import Foundation
import CoreImage
import UIKit

protocol ImageEditorDelegate
{
    func imageEditor(_ editor: ImageEditor, didChangeImage image: UIImage)
}

final class ImageEditor
{
    let filters = [
        "Sepia",
        "Blur",
        "Photo Effect",
        "Noir"
    ]
    
    var selectedFilter: String?
    var delegate: ImageEditorDelegate?
    private var filteredimages: [UIImage] = []
    var editingImage: UIImage? {
        didSet {
            self.delegate?.imageEditor(self, didChangeImage: self.editingImage!)
        }
    }
    private let workingQueue = DispatchQueue.global(qos: .userInitiated)

    var canUndo: Bool {
        return !filteredimages.isEmpty
    }

    private func undo() {
        guard canUndo else {
            return
        }
        editingImage = filteredimages.removeLast()
    }

    func revertSelectedFilter() {
        undo()
    }

    func applySelectedFilter(in rect: CGRect?) {
        workingQueue.async { [weak self] in
            let filterFactory = FilterFactory()
            if let imageFilter = filterFactory.filter(filterName: (self?.selectedFilter)!) {
                let img = (self?.editingImage)!.apply(filter: imageFilter, in: rect)
                DispatchQueue.main.async {
                    self?.filteredimages.append((self?.editingImage)!)
                    self?.editingImage = img
                }
            }
        }
    }
}

final class FilterFactory
{
    func filter(filterName: String) -> CIFilter? {
        switch filterName {
        case "Sepia":
            return .sepia
        case "Blur":
            return .blur
        case "Photo Effect":
            return .photoEffect
        case "Noir":
            return .noir
        default:
            print("Filter with this name doesn't exist!")
            break
        }
        return nil
    }
}

extension CIFilter {
    class var sepia: CIFilter {
        let filter = CIFilter(name: "CISepiaTone")!
        filter.setValue(0.90, forKey: kCIInputIntensityKey)
        return filter
    }
    class var blur: CIFilter {
        let filter = CIFilter(name: "CIGaussianBlur")!
        filter.setValue(6.0, forKey: kCIInputRadiusKey)
        return filter
    }
    class var photoEffect: CIFilter {
        let filter = CIFilter(name: "CIPhotoEffectProcess")!
        return filter
    }
    class var noir: CIFilter {
        let filter = CIFilter(name: "CIPhotoEffectNoir")!
        return filter
    }
}

extension UIImage {
    func apply(filter: CIFilter, in rect: CGRect?) -> UIImage? {
        if let area = rect {
            if let subImage = imageFromRect(area) {
                let outputImage = subImage.apply(filter: filter)
                if let img = drawImageInRect(inputImage: outputImage!, inRect: area) {
                    return img
                }
            }
        } else {
            let outputImage = apply(filter: filter)
            let fullArea = CGRect(x:0.0, y:0.0, width:outputImage!.size.width, height:outputImage!.size.height)
            if let img = drawImageInRect(inputImage: outputImage!, inRect: fullArea) {
                return img
            }
        }
        return nil
    }

    func apply(filter: CIFilter) -> UIImage? {
        let ciImg = CIImage(cgImage: self.cgImage!)
        filter.setValue(ciImg, forKey: kCIInputImageKey)
        return filter.outputImage.map(UIImage.init(ciImage:))
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
}
