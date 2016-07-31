import UIKit

class CollectionCell: UICollectionViewCell {
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.whiteColor()

        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.contentView.addSubview(self.textLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.textLabel.frame = CGRect(x: 0, y: 0, width: self.contentView.frame.width, height: self.contentView.frame.height)
    }
}