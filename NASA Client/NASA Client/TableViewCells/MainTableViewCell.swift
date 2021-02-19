//
//  MainTableViewCell.swift
//  NASA Client
//
//  Created by Павел Бескоровайный on 19.02.2021.
//

import UIKit
import Kingfisher

class MainTableViewCell: UITableViewCell {
    @IBOutlet weak var roverNameLabel: UILabel!
    @IBOutlet weak var cameraNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    private var photoModel: Photo?
    
    func setModelToUI(with model: Photo){
        self.roverNameLabel.text = "Rover: \(model.rover.name ?? "")"
        self.cameraNameLabel.text = "Camera: \(model.camera.fullName ?? "")"
        self.dateLabel.text = "Date: \(model.earthDate ?? "")"
        if let photoURL = URL(string: model.imagePath ?? "") {
            photoImageView.kf.indicatorType = .activity
            photoImageView.kf.setImage(with: photoURL)
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
