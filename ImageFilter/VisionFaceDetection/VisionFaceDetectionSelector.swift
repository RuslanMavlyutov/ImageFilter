import UIKit
import Vision

protocol VisionFaceDetectionSelectorDelegate: class {
    func faceSelectorDidDetectFaces(_ selector: VisionFaceDetectionSelector)
    func faceSelectorDidNotDetectFaces(_ selector: VisionFaceDetectionSelector)
    func faceSelectorDidGetWarningMessage(_ selector: VisionFaceDetectionSelector,
                                          didSelect message: String)
}

final class VisionFaceDetectionSelector {
    private let workingQueue = DispatchQueue.global(qos: .background)
    weak var delegate: VisionFaceDetectionSelectorDelegate?
    var boxView: [UIView] = [] {
        didSet {
            boxView.isEmpty ? self.delegate?.faceSelectorDidNotDetectFaces(self) :
                self.delegate?.faceSelectorDidDetectFaces(self)
        }
    }

    func analyze(for cropView: CroppableImageView) {
        let faceDetectionRequest = VNDetectFaceRectanglesRequest(completionHandler: {
            [weak self] (request, err) in
            guard let this = self,
                let observations = request.results as? [VNFaceObservation] else {
                    print("Unexpected result type from VNFaceObservation")
                    return
            }
            DispatchQueue.main.async {
                for face in observations {
                    let view = this.createBoxView(withColor: UIColor.red)
                    guard let imageRect = cropView.imageRect else { return }
                    view.frame = RectSizeConstructor().transformRect(fromRect: face.boundingBox,
                                                                     imageRect: imageRect)
                    cropView.addSubview(view)
                    this.boxView.append(view)
                }
                if observations.isEmpty {
                    this.warningMessage()
                }
            }
        })
        guard let image = cropView.imageToCrop else { return }
        let handler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
        workingQueue.async {
            do {
                try handler.perform([faceDetectionRequest])
            } catch {
                print("Failed to perform classification.\n\(error.localizedDescription)")
            }
        }
    }

    func clearBoxView() {
        if !boxView.isEmpty {
            for view in boxView {
                view.removeFromSuperview()
            }
            boxView.removeAll()
        }
    }

    func createBoxView(withColor: UIColor) -> UIView {
        let view = UIView()
        view.layer.borderColor = withColor.cgColor
        view.layer.borderWidth = 2
        view.backgroundColor = UIColor.clear
        return view
    }

    func warningMessage() {
        self.delegate?.faceSelectorDidGetWarningMessage(self, didSelect: "There are no faces in this image")
    }
}
