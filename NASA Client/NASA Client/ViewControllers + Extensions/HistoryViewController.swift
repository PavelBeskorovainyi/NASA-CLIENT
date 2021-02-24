//
//  HistoryViewController.swift
//  NASA Client
//
//  Created by Павел Бескоровайный on 18.02.2021.
//

import UIKit
import RealmSwift

class HistoryViewController: UIViewController, StoryboardInitializable {
    private var tableView = UITableView()
    private var realmPhotos = [Photo]()
    private var realmFilesDates = [Int]()
    
    var delegate: HistoryReload?
    var selectedIndexPath: Int = 0
    
    override func viewDidLoad() {
//        deleteRealm()
//        try! FileManager.default.removeItem(at: Realm.Configuration.defaultConfiguration.fileURL!)
        super.viewDidLoad()
        tableView.register(HistoryTableViewCell.self, forCellReuseIdentifier: "historyCell")
        tableView.delegate = self
        tableView.dataSource = self
        setupTableView()
        
    }
    
    fileprivate func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
//MARK: - realm sorting
    public func getPhotosFromRealm () {
        let realm = try! Realm()
        let storedData = realm.objects(RealmRequestModel.self)
        storedData.sorted(by: {$0.dateCreated > $1.dateCreated}).forEach({realmPhotos.append(Photo(from: $0))})
        storedData.sorted(by: {$0.dateCreated > $1.dateCreated}).forEach({realmFilesDates.append($0.dateCreated)})
        tableView.reloadData()
    }
    
    func deleteRealm () {
        let realm = try! Realm()
        try! realm.write({
            realm.deleteAll()
        })
    }
}
//MARK: - Table View Delegate & Data source Extension
extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return realmPhotos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as? HistoryTableViewCell {
            cell.setPhotoToUI(realmPhotos[indexPath.row], time: realmFilesDates[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndexPath = indexPath.row
        if !realmPhotos.isEmpty{
            self.delegate?.historyCellTapped(rover: realmPhotos[selectedIndexPath].rover.name ?? "Curiosity", camera: realmPhotos[selectedIndexPath].camera.name ?? "fhaz" , date: realmPhotos[selectedIndexPath].earthDate ?? "2021-02-20")
        }
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.popViewController(animated: true)
    }
    
}
