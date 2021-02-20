//
//  ViewController.swift
//  NASA Client
//
//  Created by Павел Бескоровайный on 17.02.2021.
//

import UIKit
import PromiseKit
import NVActivityIndicatorView

class MainViewController: UIViewController {
    @IBOutlet weak var roverTextField: UITextField!
    @IBOutlet weak var cameraTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var roverControlState: UIControl!
    @IBOutlet weak var cameraControlState: UIControl!
    @IBOutlet weak var dateControlState: UIControl!
    @IBOutlet weak var historyControlState: UIControl!
    @IBOutlet weak var countingPhotosLabel: UILabel!
    
    private var activityIndicator: NVActivityIndicatorView?
    private var noResultFoundView = UIImageView(image: UIImage(named: "noResult"))
    
    fileprivate var datePicker = UIDatePicker()
    fileprivate var roverAndCameraPicker = UIPickerView()
    public var chosenDate = Date()
    public var chosenRover = Rovers.Curiosity
    public var chosenCamera = Cameras.fhaz
    
    private var receivedPhotos = [Photo]()
    private var requestPage = 1
    
    fileprivate enum Pickers {
        case rover
        case camera
        case date
    }
    private var chosenPicker: Pickers?
    public let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())
    
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
        
        chosenDate = self.yesterday ?? Date()
        setupPickersAndUI()
        setupDatePicker()
        loadingViewsSetup()
        registerKeyboardNotifications()
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
        let vc = HistoryViewController.createFromStoryboard()
        vc.title = "History"
        vc.getPhotosFromRealm()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    deinit {
        removeKeyboardNotifications()
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
            if !response.photos.isEmpty {
                if self.requestPage == 1 {
                    self.receivedPhotos.removeAll()
                    response.photos.forEach({self.receivedPhotos.append($0)})
                    self.noResultFoundView.isHidden = true
                    self.tableView.isHidden = false
                    self.activityIndicator?.stopAnimating()
                    self.countingPhotosLabel.text = "\(response.photos.count) photos"
                }
            } else {
                self.countingPhotosLabel.text = "no photos found"
                self.receivedPhotos.removeAll()
                self.tableView.isHidden = true
                self.noResultFoundView.isHidden = false
                self.activityIndicator?.stopAnimating()
            }
            self.tableView.reloadData()
            
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
    fileprivate func setupPickersAndUI() {
        [roverControlState, cameraControlState, dateControlState].forEach({
            $0!.layer.cornerRadius = 7; $0!.layer.borderWidth = 2;
            $0!.layer.borderColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        })
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        dateTextField.inputView = datePicker
        [roverTextField, cameraTextField].forEach({$0?.inputView = roverAndCameraPicker})
        [roverTextField, cameraTextField, dateTextField].forEach({ $0?.isUserInteractionEnabled = false; $0?.inputAccessoryView = toolBar})
        roverTextField.text = chosenRover.rawValue
        cameraTextField.text = chosenCamera.rawValue
        let dateFomatter = DateFormatter()
        dateFomatter.dateFormat = "dd.MM.yy"
        dateTextField.text = dateFomatter.string(from: chosenDate)
    }
    fileprivate func setupDatePicker() {
        let dateFomatter = DateFormatter()
        dateFomatter.dateFormat = "dd.MM.yy"
        switch chosenRoverIndex {
        case 0: datePicker.minimumDate = dateFomatter.date(from: "01.12.2011")
            datePicker.maximumDate = yesterday
        case 1: datePicker.minimumDate = dateFomatter.date(from: "25.01.2004")
            datePicker.maximumDate = dateFomatter.date(from: "09.06.2018")
        case 2: datePicker.minimumDate = dateFomatter.date(from: "05.01.2004")
            datePicker.maximumDate = dateFomatter.date(from: "01.03.2010")
        default: break
        }
    }
    fileprivate func loadingViewsSetup() {
        let nvRect = CGRect(x: self.view.frame.origin.x, y: self.view.frame.height / 2 - self.view.frame.height / 6, width: self.view.frame.width, height: self.view.frame.height / 3)
        let noResRect = CGRect(x: self.view.frame.origin.x, y: self.view.frame.height / 2 - self.view.frame.height / 4, width: self.view.frame.width, height: self.view.frame.height / 2)
        self.activityIndicator = NVActivityIndicatorView(frame: nvRect, type: .ballClipRotatePulse, color: .systemRed, padding: nil)
        self.view.addSubview(activityIndicator ?? UIView())
        self.noResultFoundView.frame = noResRect
        self.noResultFoundView.contentMode = .redraw
        self.noResultFoundView.isHidden = true
        self.view.addSubview(noResultFoundView)
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        [cameraControlState,roverControlState, dateControlState].forEach({$0?.isUserInteractionEnabled = true})
        [roverTextField, cameraTextField, dateTextField].forEach({$0?.isUserInteractionEnabled = false})
        switch chosenPicker {
        case .rover:
            self.chosenRover = Rovers.allCases[roverAndCameraPicker.selectedRow(inComponent: 0)]
            self.roverTextField.text = Rovers.allCases[roverAndCameraPicker.selectedRow(inComponent: 0)].rawValue
            self.roverAndCameraPicker.selectRow(self.chosenRoverIndex, inComponent: 0, animated: false)
            self.chosenCamera = Cameras.fhaz
            self.cameraTextField.text = chosenCamera.rawValue
            switch chosenRover{
            case .Curiosity: self.chosenDate = self.yesterday ?? Date()
            case .Opportunity: self.chosenDate = dateFormatter.date(from: "26.01.2004") ?? Date()
            case .Spirit: self.chosenDate = dateFormatter.date(from: "05.01.2004") ?? Date()
            }
            self.dateTextField.text = dateFormatter.string(from: chosenDate)
        case .camera:
            self.chosenCamera = chosenRover.roverCameras[roverAndCameraPicker.selectedRow(inComponent: 0)]
            self.cameraTextField.text = chosenRover.roverCameras[roverAndCameraPicker.selectedRow(inComponent: 0)].rawValue
            self.roverAndCameraPicker.selectRow(roverAndCameraPicker.selectedRow(inComponent: 0), inComponent: 0, animated: false)
        case .date:
            dateTextField.text = dateFormatter.string(from: datePicker.date)
            self.chosenDate = datePicker.date
        default: break
        }
        setupDatePicker()
        getData()
        self.activityIndicator?.startAnimating()
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.receivedPhotos[indexPath.row].putObjectToRealm()
    }
    
}

//MARK:- Keyboard appereance
extension MainViewController {
    private func registerKeyboardNotifications () {
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
    }
    @objc private func keyboardWillShow (_ notification: Notification) {
        let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        let keyboardHeight = keyboardFrame.cgRectValue.height
//        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: keyboardHeight + (self.inputView?.frame.size.height ?? 0) + self.additionalSafeAreaInsets.bottom)
    }
    @objc private func keyboardWillHide(_ notification: Notification) {
//        tableView.contentInset = .zero
        tableView.contentOffset = .zero
    }
    
    private func removeKeyboardNotifications () {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
}
