import UIKit
import Vision

protocol FaceDetectionConstructorDelegate: class {
    func faceSelector(_ selector: FaceDetectionConstructor, isSelected isFaceDetected: Bool)
}

final class FaceDetectionConstructor
{
    private let presenter: UIViewController
    private let cropView: CroppableImageView
    private let workingQueue = DispatchQueue.global(qos: .background)
    private var boxView: [UIView] = [] {
        didSet {
            self.delegate?.faceSelector(self, isSelected: boxView.isEmpty)
        }
    }

    init(presenter: UIViewController, view: CroppableImageView) {
        self.presenter = presenter
        self.cropView = view
    }

    weak var delegate: FaceDetectionConstructorDelegate?

    func faceDetect() {
            let faceDetectionRequest: VNDetectFaceRectanglesRequest = {
                let faceRequest = VNDetectFaceRectanglesRequest(completionHandler: self.handleFaceDetection)
                return faceRequest
            }()
            guard let image = self.cropView.imageToCrop else { return }
            let handler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
            do {
                try handler.perform([faceDetectionRequest])
            } catch {
                print("Failed to perform classification.\n\(error.localizedDescription)")
            }
    }

    func handleFaceDetection(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNFaceObservation] else {
            print("Unexpected result type from VNFaceObservation")
            return
        }

        DispatchQueue.main.async {
            for face in observations {
                let view = self.createBoxView(withColor: UIColor.red)
                guard let imageRect = self.cropView.imageRect else { return }
                view.frame = RectSizeConstructor().transformRect(fromRect: face.boundingBox, imageRect: imageRect)
                self.cropView.addSubview(view)
                self.boxView.append(view)
            }
            if observations.isEmpty {
                self.warningMessage()
            }
        }
    }
    
    func warningMessage() {
        let alert = UIAlertController(title: "Face Detection", message: "There are no faces in this image", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" allert occured.")
        }))
        presenter.present(alert, animated: true, completion: nil)
    }

    func createBoxView(withColor: UIColor) -> UIView {
        let view = UIView()
        view.layer.borderColor = withColor.cgColor
        view.layer.borderWidth = 2
        view.backgroundColor = UIColor.clear
        return view
    }

    func removeBoxView() {
        if !boxView.isEmpty {
            for view in boxView {
                view.removeFromSuperview()
            }
            boxView.removeAll()
        }
    }
}
