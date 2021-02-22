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
    
    @objc dynamic var dateCreated: Int = Date().milisecondsSince1970

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
extension Date {
    var timeIntervalSince1970inMilliseconds: TimeInterval {
        return self.timeIntervalSince1970 * 1000
    }
    var milisecondsSince1970: Int {
        return Int(timeIntervalSince1970inMilliseconds)
    }
    
    init(milisecondsSince1970: Int) {
        self = Date(timeIntervalSince1970: Double(milisecondsSince1970) / 1000)
    }
    
    
}
