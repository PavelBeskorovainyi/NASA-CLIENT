//
//  AppCoordinator.swift
//  NASA Client
//
//  Created by Track Ensure on 2021-02-26.
//

import Foundation
import UIKit

class AppCoordinator: NSObject {
    
    static let shared = AppCoordinator()
    
    private var currentNavigator: UINavigationController?
    
    private func instantiate(_ controller: AppViewController) -> UIViewController {
        switch controller {
        case .main: return MainViewController.createFromStoryboard()
        case .history:
            let vc = HistoryViewController.createFromStoryboard()
            vc.delegate = currentNavigator?.topViewController as? HistoryReload
            vc.title = "History"
            vc.getPhotosFromRealm()
            return vc
        case .photo(let selectedUrl):
            let vc = ImageViewController.createFromStoryboard()
            vc.selectedImageURL = selectedUrl
            return vc
        }
    }
    
    func start(with window: UIWindow) {
        let loginViewController = self.instantiate(.main)
        currentNavigator = UINavigationController(rootViewController: loginViewController)
        window.rootViewController = self.currentNavigator
        window.makeKeyAndVisible()
    }
    
    func push(_ controller: AppViewController, animated: Bool = true) {
      let vc = instantiate(controller)
        currentNavigator?.pushViewController(vc, animated: animated)
    }
    
    
}
