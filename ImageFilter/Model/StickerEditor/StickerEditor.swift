import Foundation
import UIKit

extension CroppableImageView
{
    func putStickerToImage(sticker image: UIImage) {
        let imgSticker = UIImageView(frame: CGRect.init(x: 0.0, y: 0.0, width: 120, height: 120))
        imgSticker.center = viewForImage.center
        imgSticker.image = image
        imgSticker.contentMode = UIViewContentMode.scaleAspectFill
        imgSticker.isUserInteractionEnabled = true
        addSubview(imgSticker)
        bringSubview(toFront: imgSticker)
        isEnabledSelectedArea = false

        let draggerSticker = UIPanGestureRecognizer(target: self, action: #selector(handlePanSticker(recognizer:)))
        let rotateSticker = UIRotationGestureRecognizer(target: self, action: #selector(handleRotationSticker(recognizer:)))
        let pinchSticker = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchSticker(recognizer:)))
        draggersSticker[imgSticker] = [draggerSticker, rotateSticker, pinchSticker]
        imgSticker.isUserInteractionEnabled = true
        imgSticker.addGestureRecognizer(draggerSticker)
        imgSticker.addGestureRecognizer(rotateSticker)
        imgSticker.addGestureRecognizer(pinchSticker)
    }

    func removeGestureForSticker() {
        for imageView in draggersSticker {
            for gesture in imageView.value {
                imageView.key.removeGestureRecognizer(gesture)
            }
        }
    }

    func imageWithSticker() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        viewForImage.layer.render(in: UIGraphicsGetCurrentContext()!)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    func removeSticker() {
        for img in draggersSticker {
            img.key.removeFromSuperview()
        }
    }

    func setTranslationWithLimit(_ view : UIView, _ translation: CGPoint) {
        let movedToX = view.center.x + translation.x
        let movedToY = view.center.y + translation.y
        let maxLimitForX = viewForImage.frame.width
        let minLimitForX = CGFloat()
        let maxLimitForY = (viewForImage.frame.height - view.frame.size.height / 4)
        let minLimitForY = CGFloat()

        if movedToX < maxLimitForX && movedToX > minLimitForX &&
            movedToY < maxLimitForY && movedToY > minLimitForY {
            view.center = CGPoint(x:view.center.x + translation.x,
                                  y:view.center.y + translation.y)
        }
    }

    @objc func handlePanSticker(recognizer: UIPanGestureRecognizer)
    {
        guard recognizer.view != nil else { return }

        let translation = recognizer.translation(in: self)
            if let view = recognizer.view {
                setTranslationWithLimit(view, translation)
            }
            recognizer.setTranslation(CGPoint.zero, in: self.viewForImage)
    }

    @objc func handleRotationSticker(recognizer: UIRotationGestureRecognizer)
    {
        guard recognizer.view != nil else { return }

        transform = transform.rotated(by: recognizer.rotation)
        recognizer.rotation = 0
    }

    @objc func handlePinchSticker(recognizer: UIPinchGestureRecognizer)
    {
        guard recognizer.view != nil else { return }

        transform = transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
        recognizer.scale = 1
    }
}
