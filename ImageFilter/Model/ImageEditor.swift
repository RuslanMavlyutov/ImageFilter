import Foundation
import CoreImage
import UIKit

protocol ImageFilter
{
    var name: String { get }
    func apply(to image: UIImage, in rect: CGRect?, completion: @escaping (UIImage?, CIFilter?) -> Void)
    func revert(to previousImage: UIImage,
                for currentImage: CIImage,
                in rect: CGRect?,
                completion: @escaping (UIImage?) -> Void)
}

extension ImageFilter
{
    func revert(to previousImage: UIImage,
                for currentImage: CIImage,
                in rect: CGRect?,
                completion: @escaping (UIImage?) -> Void) {
        let img = UIImage(ciImage: currentImage)
        var revertImg = img
        if let rect = rect {
            revertImg = previousImage.drawImageInRect(inputImage: img, inRect: rect)!
        }
        completion(revertImg)
    }
}

struct FilterShortNames
{
    static let sepia = "Sepia"
    static let blur = "Blur"
    static let photoEffect = "Photo Effect"
    static let noir = "Noir"
}

struct FilterName
{
    static let sepiaFilter = "CISepiaTone"
    static let photoEffectFilter = "CIPhotoEffectProcess"
    static let blurFilter = "CIGaussianBlur"
    static let noirFilter = "CIPhotoEffectNoir"
}

final class SepiaImageFilter: ImageFilter
{
    func apply(to image: UIImage, in rect: CGRect?, completion: @escaping (UIImage?, CIFilter?) -> Void) {
        image.applyFilterRect(filter: FilterName.sepiaFilter, rect: rect) { (img, filter) in
            completion(img, filter)
        }
    }
    var name = FilterShortNames.sepia
}

final class BlurImageFilter: ImageFilter
{
    func apply(to image: UIImage, in rect: CGRect?, completion: @escaping (UIImage?, CIFilter?) -> Void) {
        image.applyFilterRect(filter: FilterName.blurFilter, rect: rect) { (img, filter) in
            completion(img, filter)
        }
    }
    var name: String = FilterShortNames.blur
}

final class PhotoEffectImageFilter: ImageFilter
{
    func apply(to image: UIImage, in rect: CGRect?, completion: @escaping (UIImage?, CIFilter?) -> Void) {
        image.applyFilterRect(filter: FilterName.photoEffectFilter, rect: rect) { (img, filter) in
            completion(img, filter)
        }
    }
    var name: String = FilterShortNames.photoEffect
}

final class NoirImageFilter: ImageFilter
{
    func apply(to image: UIImage, in rect: CGRect?, completion: @escaping (UIImage?, CIFilter?) -> Void) {
        image.applyFilterRect(filter: FilterName.noirFilter, rect: rect) { (img, filter) in
            completion(img, filter)
        }
    }
    var name: String = FilterShortNames.noir
}

protocol ImageEditorDelegate
{
    func imageEditor(_ editor: ImageEditor, didChangeImage image: UIImage)
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
    var editingImage: UIImage?
    let savedFilter = LinkSavedAppliedFilter()

    func revertSelectedFilter() {
        if !savedFilter.isEmpty() {
            let (filter, area) = savedFilter.deleteFirst()
            let cImg = filter?.value(forKey: kCIInputImageKey) as! CIImage
            selectedFilter?.revert(to: editingImage!, for: cImg, in: area, completion: { img in
                self.editingImage = img
                self.delegate?.imageEditor(self, didChangeImage: self.editingImage!)
            })
        }
    }
    
    func applySelectedFilter(in rect: CGRect?) {
        selectedFilter?.apply(to: editingImage!, in: rect, completion: { (img, filter) in
            if let filterName = self.selectedFilter?.name {
                self.saveAppliedFilter(for: filterName, in: rect)
                self.savedFilter.insertFirst(filter: filter!, area: rect)
            }
            self.editingImage = img
            self.delegate?.imageEditor(self, didChangeImage: self.editingImage!)
        })
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

    func filterImage(filterEffect: String) -> (UIImage?, CIFilter?) {
        let inputImage = UIKit.CIImage(cgImage: self.cgImage!)
        if let filter = CIFilter(name: filterEffect) {
            filter.setValue(inputImage, forKey: kCIInputImageKey)
            if filterEffect == FilterName.blurFilter {
                filter.setValue(6.0, forKey: kCIInputRadiusKey)
            } else if filterEffect == FilterName.sepiaFilter {
                filter.setValue(0.90, forKey: kCIInputIntensityKey)
            }
            if let effectImg = filter.outputImage {
                return (UIImage(ciImage: effectImg), filter)
            }
        }
        return (nil, nil)
    }

    func applyFilterRect(filter: String, rect: CGRect?, completion: @escaping (UIImage?, CIFilter?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] () -> Void in
            if let area = rect {
                if let subImage = self?.imageFromRect(area),
                    case let (filteredZone, filter) = subImage.filterImage(filterEffect: filter) {
                    if let img = self?.drawImageInRect(inputImage: filteredZone!, inRect: area) {
                        DispatchQueue.main.async { () -> Void in
                            completion(img, filter)
                        }
                    }
                }
            } else {
                if let (img, filter) = self?.filterImage(filterEffect: filter) {
                    let area = CGRect(x:0.0, y:0.0, width:img!.size.width, height:img!.size.height)
                    if let img = self?.drawImageInRect(inputImage: img!, inRect: area) {
                        DispatchQueue.main.async { () -> Void in
                            completion(img, filter)
                        }
                    }
                }
            }
        }
    }
}
