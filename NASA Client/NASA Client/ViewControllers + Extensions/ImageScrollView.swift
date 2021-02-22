//
//  ImageScrollView.swift
//  NASA Client
//
//  Created by Павел Бескоровайный on 21.02.2021.
//

import Foundation
import UIKit

class ImageScrollView: UIScrollView, UIScrollViewDelegate {
    
    private var imageView: UIImageView!
    public var currentZoom: CGFloat = 1
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(image: UIImage) {
        imageView?.removeFromSuperview()
        imageView = nil
        imageView = UIImageView(image: image)
        self.addSubview(imageView)
        configurateFor(imageSize: image.size)
        
        self.minimumZoomScale = 0.2
        self.maximumZoomScale = 4
    }
    
    private func configurateFor(imageSize: CGSize) {
        self.contentSize = imageSize
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let subview = scrollView.subviews.first
        let offsetX = max(((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5), 0.0)
        let offsetY = max(0.0, ((scrollView.bounds.height - scrollView.contentSize.height) * 0.5))
        subview?.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY - 44)
    }
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        self.currentZoom = scale
    }
    
}
