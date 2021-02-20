//
//  RealmModel.swift
//  NASA Client
//
//  Created by Павел Бескоровайный on 18.02.2021.
//

import Foundation
import RealmSwift

class RealmRequestModel: Object {
    @objc dynamic var roverName: String?
    @objc dynamic var cameraName: String?
    @objc dynamic var imagePath: String?
    @objc dynamic var cameraFullName: String?
    @objc dynamic var earthDate: String?
    
    @objc dynamic var dateCreated: Int = Int(Date.timeIntervalSinceReferenceDate)
    
    override class func primaryKey() -> String? {
      return "dateCreated"
    }
    
    convenience init(from codableModel: Photo) {
      self.init()
        self.roverName = codableModel.rover.name
        self.cameraName = codableModel.camera.name
        self.imagePath = codableModel.imagePath
        self.cameraFullName = codableModel.camera.fullName
        self.earthDate = codableModel.earthDate
    }
}
