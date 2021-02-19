//
//  ViewController.swift
//  NASA Client
//
//  Created by Павел Бескоровайный on 17.02.2021.
//

import UIKit
import PromiseKit

class MainViewController: UIViewController {
    @IBOutlet weak var roverTextField: UITextField!
    @IBOutlet weak var cameraTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var roverControlState: UIControl!
    @IBOutlet weak var cameraControlState: UIControl!
    @IBOutlet weak var dateControlState: UIControl!
    
    private var datePicker = UIDatePicker()
    private var roverAndCameraPicker = UIPickerView()
    private var chosenDate = Date()
    private var chosenRover = Rovers.Curiosity
    private var chosenCamera = Cameras.fhaz
    
    private var receivedPhotosModel = [RequestModel]()
    private var receivedPhotos = [Photo]()
    
    private var requestPage = 1
    
    fileprivate enum Pickers {
        case rover
        case camera
        case date
    }
    private var chosenPicker: Pickers?
    
    private var chosenRoverIndex: Int {
        switch chosenRover {
        case .Curiosity: return 0
        case .Opportunity: return 1
        case .Spirit: return 2
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        roverAndCameraPicker.delegate = self
        roverAndCameraPicker.dataSource = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "MainTableViewCell", bundle: nil), forCellReuseIdentifier: "mainCell")
        tableView.estimatedRowHeight = 100
        setupPickers()
        setupDatePicker()
        getData()
    }
    
    @IBAction func roverChoosing(_ sender: Any) {
        chosenPicker = .rover
        self.roverControlState.isUserInteractionEnabled = true
        self.dateControlState.isUserInteractionEnabled = false
        self.cameraControlState.isUserInteractionEnabled = false
        self.cameraTextField.isUserInteractionEnabled = false
        self.roverTextField.isUserInteractionEnabled = true
        self.dateTextField.isUserInteractionEnabled = false
        self.roverTextField.becomeFirstResponder()
    }
    @IBAction func cameraChoosing(_ sender: Any) {
        chosenPicker = .camera
        self.cameraControlState.isUserInteractionEnabled = true
        self.roverControlState.isUserInteractionEnabled = false
        self.dateControlState.isUserInteractionEnabled = false
        self.cameraTextField.isUserInteractionEnabled = true
        self.roverTextField.isUserInteractionEnabled = false
        self.dateTextField.isUserInteractionEnabled = false
        self.cameraTextField.becomeFirstResponder()
    }
    @IBAction func dateChoosing(_ sender: Any) {
        chosenPicker = .date
        self.dateControlState.isUserInteractionEnabled = true
        self.roverControlState.isUserInteractionEnabled = false
        self.cameraControlState.isUserInteractionEnabled = false
        self.cameraTextField.isUserInteractionEnabled = false
        self.roverTextField.isUserInteractionEnabled = false
        self.dateTextField.isUserInteractionEnabled = true
        self.dateTextField.becomeFirstResponder()
    }
    
    @IBAction func historyPresenting(_ sender: Any) {
    }
}

//MARK: - Get Data From Server
extension MainViewController {
    func getData() {
        firstly {
            Provider.getDataFrom(rover: chosenRover.rawValue, camera: chosenCamera.rawValue, date: chosenDate, page: requestPage)
        }.done {
            [weak self] (response) in
            guard let self = self else {return}
            if self.requestPage == 1 {
                self.receivedPhotos.removeAll()
                response.photos.forEach({self.receivedPhotos.append($0)})
                self.tableView.reloadData()
            }
        } .catch { (error) in
            debugPrint(error.localizedDescription)
        }
    }
}

//MARK: - Pickers delegate, datasource and variables
extension MainViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch chosenPicker {
        case .rover: return Rovers.allCases.count
        case .camera: return chosenRover.roverCameras.count
        default: return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch chosenPicker {
        case .rover: return Rovers.allCases[row].rawValue
        case .camera: return Rovers.allCases[chosenRoverIndex].roverCameras[row].fullName
        default: return ""
        }
    }
}
//MARK: - input setups
extension MainViewController {
    fileprivate func setupPickers() {
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        dateTextField.inputView = datePicker
        [roverTextField, cameraTextField].forEach({$0?.inputView = roverAndCameraPicker})
        [roverTextField, cameraTextField, dateTextField].forEach({ $0?.isUserInteractionEnabled = false; $0?.inputAccessoryView = toolBar})
    }
    fileprivate func setupDatePicker() {
        let dateFomatter = DateFormatter()
        dateFomatter.dateFormat = "dd.MM.yy"
        switch chosenRoverIndex {
        case 0: datePicker.minimumDate = dateFomatter.date(from: "01.12.2011")
            datePicker.maximumDate = Date()
        case 1: datePicker.minimumDate = dateFomatter.date(from: "25.01.2004")
            datePicker.maximumDate = dateFomatter.date(from: "09.06.2018")
        case 2: datePicker.minimumDate = dateFomatter.date(from: "05.01.2004")
            datePicker.maximumDate = dateFomatter.date(from: "01.03.2010")
        default: break
        }
    }
    
    fileprivate var toolBar: UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(ignoreChanges))
        let saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveChosenDataAndRequestToServer))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([cancelButton, space, saveButton], animated: false)
        return toolbar
    }
    
    @objc private func ignoreChanges() {
        [cameraControlState,roverControlState, dateControlState].forEach({$0?.isUserInteractionEnabled = true})
        [roverTextField, cameraTextField, dateTextField].forEach({$0?.isUserInteractionEnabled = false})
        self.view.endEditing(true)
        
    }
    
    @objc private func saveChosenDataAndRequestToServer () {
        [cameraControlState,roverControlState, dateControlState].forEach({$0?.isUserInteractionEnabled = true})
        [roverTextField, cameraTextField, dateTextField].forEach({$0?.isUserInteractionEnabled = false})
        switch chosenPicker {
        case .rover: self.chosenRover = Rovers.allCases[roverAndCameraPicker.selectedRow(inComponent: 0)]
            self.roverTextField.text = Rovers.allCases[roverAndCameraPicker.selectedRow(inComponent: 0)].rawValue
        case .camera: self.chosenCamera = chosenRover.roverCameras[roverAndCameraPicker.selectedRow(inComponent: 0)]
            self.cameraTextField.text = chosenRover.roverCameras[roverAndCameraPicker.selectedRow(inComponent: 0)].rawValue
        case .date:
            let dateFomratter = DateFormatter()
            dateFomratter.dateFormat = "MMM d, yyyy"
            dateTextField.text = dateFomratter.string(from: datePicker.date)
            self.chosenDate = datePicker.date
        default: break
        }
        setupDatePicker()
        getData()
    }
}
//MARK: - Table View Extension
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.receivedPhotos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "mainCell", for: indexPath) as? MainTableViewCell {
            cell.setModelToUI(with: receivedPhotos[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
}
