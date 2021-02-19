//
//  RoversEnum.swift
//  NASA Client
//
//  Created by Павел Бескоровайный on 18.02.2021.
//

import Foundation

enum Rovers: String, CaseIterable {
    case Curiosity
    case Opportunity
    case Spirit
    
    var roverCameras: [Cameras] {
        switch self {
        case .Curiosity: return [.fhaz, .rhaz, .mast, .chemcam, .mahli, .mardi, .navcam]
        case .Opportunity, .Spirit: return [.fhaz, .rhaz, .navcam, .pancam, .minites]
        }
    }
}
//Curiosity, Opportunity, and Spirit
