import Foundation
import CoreImage
import UIKit

protocol ImageFilter
{
    var name: String { get }
    var filter: CIFilter { get }
    func apply(to image: UIImage, in rect: CGRect?) -> UIImage?
}

final class SepiaImageFilter: ImageFilter
{
    private(set) var name = "Sepia"
    private(set) var filter: CIFilter = CIFilter(name: "CISepiaTone")!
    func apply(to image: UIImage, in rect: CGRect?) -> UIImage? {
        if let area = rect {
            if let subImage = image.imageFromRect(area) {
                let outputImage = setFilter(for: subImage)
                if let img = image.drawImageInRect(inputImage: outputImage!, inRect: area) {
                    return img
                }
            }
        } else {
            let outputImage = setFilter(for: image)
            let fullArea = CGRect(x:0.0, y:0.0, width:outputImage!.size.width, height:outputImage!.size.height)
            if let img = image.drawImageInRect(inputImage: outputImage!, inRect: fullArea) {
                return img
            }
        }
        return nil
    }

    private func setFilter(for image: UIImage) -> UIImage? {
        let inputImage = UIKit.CIImage(cgImage: image.cgImage!)
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(0.90, forKey: kCIInputIntensityKey)
        if let effectImg = filter.outputImage {
            return UIImage(ciImage: effectImg)
        }
        return nil
    }
}

final class BlurImageFilter: ImageFilter
{
    private(set) var name = "Blur"
    private(set) var filter: CIFilter = CIFilter(name: "CIGaussianBlur")!
    func apply(to image: UIImage, in rect: CGRect?) -> UIImage? {
        if let area = rect {
            if let subImage = image.imageFromRect(area) {
                let outputImage = setFilter(for: subImage)
                if let img = image.drawImageInRect(inputImage: outputImage!, inRect: area) {
                    return img
                }
            }
        } else {
            let outputImage = setFilter(for: image)
            let fullArea = CGRect(x:0.0, y:0.0, width:outputImage!.size.width, height:outputImage!.size.height)
            if let img = image.drawImageInRect(inputImage: outputImage!, inRect: fullArea) {
                return img
            }
        }
        return nil
    }

    private func setFilter(for image: UIImage) -> UIImage? {
        let inputImage = UIKit.CIImage(cgImage: image.cgImage!)
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(6.0, forKey: kCIInputRadiusKey)
        if let effectImg = filter.outputImage {
            return UIImage(ciImage: effectImg)
        }
        return nil
    }
}

final class PhotoEffectImageFilter: ImageFilter
{
    private(set) var name = "Photo Effect"
    private(set) var filter: CIFilter = CIFilter(name: "CIPhotoEffectProcess")!
    func apply(to image: UIImage, in rect: CGRect?) -> UIImage? {
        if let area = rect {
            if let subImage = image.imageFromRect(area) {
                let outputImage = setFilter(for: subImage)
                if let img = image.drawImageInRect(inputImage: outputImage!, inRect: area) {
                    return img
                }
            }
        } else {
            let outputImage = setFilter(for: image)
            let fullArea = CGRect(x:0.0, y:0.0, width:outputImage!.size.width, height:outputImage!.size.height)
            if let img = image.drawImageInRect(inputImage: outputImage!, inRect: fullArea) {
                return img
            }
        }
        return nil
    }

    private func setFilter(for image: UIImage) -> UIImage? {
        let inputImage = UIKit.CIImage(cgImage: image.cgImage!)
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        if let effectImg = filter.outputImage {
            return UIImage(ciImage: effectImg)
        }
        return nil
    }
}

final class NoirImageFilter: ImageFilter
{
    private(set) var name = "Noir"
    private(set) var filter: CIFilter = CIFilter(name: "CIPhotoEffectNoir")!
    func apply(to image: UIImage, in rect: CGRect?) -> UIImage? {
        if let area = rect {
            if let subImage = image.imageFromRect(area) {
                let outputImage = setFilter(for: subImage)
                if let img = image.drawImageInRect(inputImage: outputImage!, inRect: area) {
                    return img
                }
            }
        } else {
            let outputImage = setFilter(for: image)
            let fullArea = CGRect(x:0.0, y:0.0, width:outputImage!.size.width, height:outputImage!.size.height)
            if let img = image.drawImageInRect(inputImage: outputImage!, inRect: fullArea) {
                return img
            }
        }
        return nil
    }

    private func setFilter(for image: UIImage) -> UIImage? {
        let inputImage = UIKit.CIImage(cgImage: image.cgImage!)
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        if let effectImg = filter.outputImage {
            return UIImage(ciImage: effectImg)
        }
        return nil
    }
}

final class SavedAppliedFilter
{
    private var filter: CIFilter
    private var area: CGRect?
    var next: SavedAppliedFilter?

    init(for filter: CIFilter, in area: CGRect?) {
        self.filter = filter
        self.area = area
    }

    func showFilter() -> (CIFilter, CGRect?) {
        return (filter, area)
    }
}

final class LinkSavedAppliedFilter
{
    private var first: SavedAppliedFilter?

    func isEmpty() -> Bool {
        return first == nil
    }

    func insertFirst(filter: CIFilter, area: CGRect?) {
        let newSavedAppliedFilter = SavedAppliedFilter(for: filter, in: area)
        newSavedAppliedFilter.next = first
        first = newSavedAppliedFilter
    }

    func deleteFirst() -> (CIFilter?, CGRect?) {
        guard let first = first else { return (nil, nil) }
        self.first = first.next
        let (filter, area) = first.showFilter()
        return (filter, area)
    }
}

protocol ImageEditorDelegate
{
    func imageEditor(_ editor: ImageEditor, didChangeImage image: UIImage)
}

final class ImageEditor
{
    let filters = [
        SepiaImageFilter(),
        BlurImageFilter(),
        PhotoEffectImageFilter(),
        NoirImageFilter()
        ] as [ImageFilter]
    
    var selectedFilter: ImageFilter?
    var delegate: ImageEditorDelegate?
    var appliedEffect: [String : [CGRect?]] = [:]
    var editingImage: UIImage? {
        didSet {
            self.delegate?.imageEditor(self, didChangeImage: self.editingImage!)
        }
    }
    let savedFilter = LinkSavedAppliedFilter()
    private let workingQueue = DispatchQueue.global(qos: .userInitiated)

    func revertSelectedFilter() {
        if !savedFilter.isEmpty() {
            workingQueue.async { [weak self]() -> Void in
                let (filter, area) = (self?.savedFilter.deleteFirst())!
                let cImg = filter?.value(forKey: kCIInputImageKey) as! CIImage

                let image = UIImage(ciImage: cImg)
                let rect = area ?? CGRect(x:0.0, y:0.0, width:(self?.editingImage!.size.width)!, height:(self?.editingImage!.size.height)!)
                let revertImg = self?.editingImage!.drawImageInRect(inputImage: image, inRect: rect)!
                DispatchQueue.main.async {
                    self?.editingImage = revertImg
                }
            }
        }
    }
    
    func applySelectedFilter(in rect: CGRect?) {
        workingQueue.async { [weak self]() -> Void in
            let img = self?.selectedFilter?.apply(to: (self?.editingImage)!, in: rect)
            if let filterName = self?.selectedFilter?.name {
                self?.saveAppliedFilter(for: filterName, in: rect)
                self?.savedFilter.insertFirst(filter: (self?.selectedFilter?.filter)!, area: rect)
            }
            DispatchQueue.main.async {
                self?.editingImage = img
            }
        }
    }

    func saveAppliedFilter(for filterName: String, in rect: CGRect?) {
        var area = self.appliedEffect[filterName]
        if (area != nil) {
            area?.append(rect)
        } else {
            area = [rect]
        }
        self.appliedEffect[filterName] = area
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
