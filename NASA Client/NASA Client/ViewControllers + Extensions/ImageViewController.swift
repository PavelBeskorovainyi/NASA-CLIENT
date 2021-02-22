//
//  ImageViewController.swift
//  NASA Client
//
//  Created by Павел Бескоровайный on 18.02.2021.
//

import UIKit
import Kingfisher

class ImageViewController: UIViewController, StoryboardInitializable {

    private var imageScrollView: ImageScrollView?
    public var selectedImageURL: String?
    private var photo = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageScrollView = ImageScrollView(frame: self.view.bounds)
        self.view.addSubview(imageScrollView!)
        
        if let photoURL = URL(string: selectedImageURL ?? "") {
            photo.kf.indicatorType = .activity
            photo.kf.setImage(with: photoURL)
        }
        imageScrollView?.set(image: photo.image ?? UIImage())
        self.setupImageScrollView()
        self.centerImage()
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    fileprivate func setupImageScrollView() {
        imageScrollView?.translatesAutoresizingMaskIntoConstraints = false
        imageScrollView?.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        imageScrollView?.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        imageScrollView?.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        imageScrollView?.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
//        imageScrollView?.contentOffset = self.view.center
        imageScrollView?.center = self.view.center
        imageScrollView?.contentMode = .redraw
    }
    fileprivate func centerImage() {
        self.imageScrollView?.zoom(
            to: CGRect(
                origin: CGPoint(
                    x: self.imageScrollView!.contentSize.width / 2 - self.view.frame.size.width / 2,
                    y: self.imageScrollView!.contentSize.height / 2 - self.view.frame.size.height / 2 ),
                size: CGSize(width: 200, height: 200)), animated: false)
        self.imageScrollView?.setZoomScale(1, animated: true)
    }
    
    @objc fileprivate func rotated() {
        if UIDevice.current.orientation.isLandscape{
            self.centerImage()
        } else {
            self.centerImage()}
    }
}
