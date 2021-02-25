//
//  CamerasEnum.swift
//  NASA Client
//
//  Created by Павел Бескоровайный on 18.02.2021.
//

import Foundation

enum Cameras: String, CaseIterable {
    case fhaz, rhaz, mast, chemcam, mahli, mardi, navcam, pancam, minites, all
    
    var fullName: String {
        switch self {
        case .fhaz: return "Front Hazard Avoidance Camera"
        case .rhaz: return "Rear Hazard Avoidance Camera"
        case .mast: return "Mast Camera"
        case .chemcam: return "Chemistry and Camera Complex"
        case .mahli: return "Mars Hand Lens Imager"
        case .mardi: return "Mars Descent Imager"
        case .navcam: return "Navigation Camera"
        case .pancam: return "Panoramic Camera"
        case .minites: return "Miniature Thermal Emission Spectrometer (Mini-TES)"
        case .all: return "ALL"
        }
    }
}

//Abbreviation    Camera    Curiosity    Opportunity    Spirit
//FHAZ    Front Hazard Avoidance Camera    ✔    ✔    ✔
//RHAZ    Rear Hazard Avoidance Camera    ✔    ✔    ✔
//MAST    Mast Camera    ✔
//CHEMCAM    Chemistry and Camera Complex    ✔
//MAHLI    Mars Hand Lens Imager    ✔
//MARDI    Mars Descent Imager    ✔
//NAVCAM    Navigation Camera    ✔    ✔    ✔
//PANCAM    Panoramic Camera        ✔    ✔
//MINITES    Miniature Thermal Emission Spectrometer (Mini-TES)        ✔    ✔
