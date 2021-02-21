//
//  HistoryProtocol+Extension.swift
//  NASA Client
//
//  Created by Павел Бескоровайный on 20.02.2021.
//

import Foundation
protocol HistoryReload {
    func historyCellTapped(rover: String, camera: String, date: String)
}

extension MainViewController: HistoryReload {
    func historyCellTapped(rover: String, camera: String, date: String) {
        self.roverTextField.text = rover
        self.cameraTextField.text = camera.lowercased()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateFormString = dateFormatter.date(from: date)
        
        self.chosenDate = dateFormString ?? self.yesterday!
        self.chosenRover = Rovers(rawValue: rover) ?? .Curiosity
        self.chosenCamera = Cameras(rawValue: camera.lowercased()) ?? .fhaz
        
        let dateFomatter2 = DateFormatter()
        dateFomatter2.dateFormat = "dd.MM.yy"
        self.dateTextField.text = dateFomatter2.string(from: chosenDate)
        
        self.requestPage = 1
        self.getData()
        self.tableView.reloadData()
    }
}
