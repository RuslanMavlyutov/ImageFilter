import UIKit

final class ImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    func configure(image: UIImage) {
        imageView.image = image
    }
}
