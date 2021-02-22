//
//  HistoryTableViewCell.swift
//  NASA Client
//
//  Created by Павел Бескоровайный on 20.02.2021.
//

import UIKit
import Kingfisher

class HistoryTableViewCell: UITableViewCell {
    
    var dateWasSeenlabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica Neue", size: 20)
        return label
    }()
    var photoWasSeenImageView: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 5
        return image
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(dateWasSeenlabel)
        addSubview(photoWasSeenImageView)
        photoWasSeenImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 0, width: 60, height: 40, enableInsets: false)
        dateWasSeenlabel.anchor(top: topAnchor, left: photoWasSeenImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 30, paddingBottom: 0, paddingRight: 0, width: frame.size.width / 1.5, height: 30, enableInsets: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var model: Photo?
    
    public func setPhotoToUI(_ model: Photo, time: Int) {
        if let photoURL = URL(string: model.imagePath ?? "") {
            photoWasSeenImageView.kf.indicatorType = .activity
            photoWasSeenImageView.kf.setImage(with: photoURL)
        }
        let date = Date.init(milisecondsSince1970: time)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        dateWasSeenlabel.text = dateFormatter.string(from: date)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
