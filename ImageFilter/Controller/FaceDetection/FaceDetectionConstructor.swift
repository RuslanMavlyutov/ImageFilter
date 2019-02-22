import UIKit
import Vision

protocol FaceDetectionConstructorDelegate: class {
    func faceSelectorDidDetectFaces(_ selector: FaceDetectionConstructor)
    func faceSelectorDidNotDetectFaces(_ selector: FaceDetectionConstructor)
}

final class FaceDetectionConstructor
{
    private let presenter: UIViewController
    private let workingQueue = DispatchQueue.global(qos: .background)
    private var visionFaceDetection: VisionFaceDetectionSelector

    init(presenter: UIViewController, view: CroppableImageView) {
        self.presenter = presenter
        self.visionFaceDetection = VisionFaceDetectionSelector()
        self.visionFaceDetection.delegate = self
    }

    weak var delegate: FaceDetectionConstructorDelegate?

    func detectFace(for cropView: CroppableImageView) {
        visionFaceDetection.analyze(for: cropView)
    }

    func removeDetectedFaces() {
        visionFaceDetection.clearBoxView()
    }
}

extension FaceDetectionConstructor: VisionFaceDetectionSelectorDelegate {
    func faceSelectorDidDetectFaces(_ selector: VisionFaceDetectionSelector) {
        self.delegate?.faceSelectorDidDetectFaces(self)
    }
    func faceSelectorDidNotDetectFaces(_ selector: VisionFaceDetectionSelector) {
        self.delegate?.faceSelectorDidNotDetectFaces(self)
    }
    func faceSelectorDidGetWarningMessage(_ selector: VisionFaceDetectionSelector,
                                          didSelect message: String) {
        let alert = UIAlertController(title: "Face Detection",
                                      message: "There are no faces in this image", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"),
                                      style: .default, handler: { _ in
            NSLog("The \"OK\" allert occured.")
        }))
        presenter.present(alert, animated: true, completion: nil)
    }
}
