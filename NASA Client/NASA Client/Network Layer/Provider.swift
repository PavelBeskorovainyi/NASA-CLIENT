//
//  Provider.swift
//  NASA Client
//
//  Created by Павел Бескоровайный on 18.02.2021.
//

import Foundation
import PromiseKit
import Moya

struct Provider {
    static private let provider = MoyaProvider<RequestTarget>()
    
    static func getDataFrom(rover: String, camera: String, date: Date, page: Int) -> Promise<RequestModel> {
        return Promise { seal in
            provider.request(.requestWithParametrs(rover: rover, camera: camera, date: date, page: page)) {
                result in
                switch result {
                case.success(let response):
                    do {
                        let marsData = try JSONDecoder().decode(RequestModel.self, from: response.data)
                        seal.fulfill(marsData)
                    } catch let error {
                        debugPrint(error.localizedDescription)
                        seal.reject(error)
                    }
                case .failure(let error):
                    debugPrint(error.localizedDescription)
                    seal.reject(error)
                }

            }
        }
    }
}
