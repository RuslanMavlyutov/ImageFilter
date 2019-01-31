import UIKit

protocol StickerViewControllerDelegate {
    func imageSelector(_ ctrl: StickerViewController,
                                      didSelectImage image: UIImage)
}

final class StickerViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!

    var delegate: StickerViewControllerDelegate?
    private let imageArray = ["banana", "icons8-cat-512", "monkey", "Sticker_Line_LeopardCat05",
                              "animal-png-hd-download-png-image-tiger-png-hd-1024"]

    struct Constants {
        static let spacing: CGFloat = 3
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        reloadUI()
    }

    func reloadUI() {
        let leftSpacing = Constants.spacing
        let rightSpacing = Constants.spacing
        let spacingBetweenCell = (Constants.spacing - 1) * Constants.spacing
        let fullSpacing = leftSpacing + rightSpacing + spacingBetweenCell + CGFloat(imageArray.count) - 1
        let itemSize = (UIScreen.main.bounds.width) / CGFloat(imageArray.count) - fullSpacing
        print(UIScreen.main.bounds.width)

        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(0, Constants.spacing, 0, Constants.spacing)
        layout.itemSize = CGSize(width: itemSize, height: itemSize)

        layout.minimumInteritemSpacing = Constants.spacing
        layout.minimumLineSpacing = Constants.spacing

        collectionView.collectionViewLayout = layout
    }
}

extension StickerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return Int(imageArray.count)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cellName = String(describing: ImageCell.self);
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath) as! ImageCell
        if let img = UIImage(named: imageArray[indexPath.row]) {
            cell.configure(image: img)
        }
        return cell
    }
}

extension StickerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if let img = UIImage(named: imageArray[indexPath.row]) {
            print("Selected img")
            self.delegate?.imageSelector(self, didSelectImage: img)
        }
    }
}
