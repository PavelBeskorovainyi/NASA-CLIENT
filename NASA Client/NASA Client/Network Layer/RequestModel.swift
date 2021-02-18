//
//  RequestModel.swift
//  NASA Client
//
//  Created by Павел Бескоровайный on 18.02.2021.
//

import Foundation
import RealmSwift

struct RequestModel: Codable {
    var photos: [Photo]
}

class Photo: Codable {
    var imagePath: String?
    var camera: Camera
    var rover: Rover
    
    enum CodingKeys: String, CodingKey {
        case camera, rover
        case imagePath = "img_src"
    }
    
    init(from realm: RealmRequestModel) {
        self.imagePath = realm.imagePath
        self.camera = Camera(name: realm.cameraName, fullName: realm.cameraFullName)
        self.rover = Rover(name: realm.roverName)
    }
    
    func putObjectToRealm(){
        let realm = try! Realm()
        let realmObject = RealmRequestModel(from: self)
        try! realm.write({
            realm.add(realmObject, update: .all)
        })
    }
}

struct Camera: Codable {
    var name: String?
    var fullName: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case fullName = "full_name"
    }
}

struct Rover: Codable {
    var name: String?
}

