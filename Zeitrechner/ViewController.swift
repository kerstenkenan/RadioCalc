//
//  ViewController.swift
//  Zeitrechner
//
//  Created by Kersten Weise on 25.07.19.
//  Copyright © 2019 Kersten Weise. All rights reserved.
//

import UIKit

struct Cell: Codable {
    var title: String
    var timeTextfieldContent: String
    var stoppingTime: Double
    var stoppingButtonPressed: Bool
}

enum Cellparam {
    case textfieldContent
    case stopping
}

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var titleLabelConstraints: [NSLayoutConstraint]!
    @IBOutlet weak var hourButton: UIButton!
    
    var timeCells = [Cell]()
        
    var seconds = 0
    var minutes = 0
    var hours : Double = 60
    var counter = 1
    
    var buttonIsPressed = false
    
    var actualTextField : UITextField?
    
    var keyboardFrame : CGRect!
    var isKeyboardShowing = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !UserDefaults.standard.bool(forKey: "FirstTime") {
            timeCells = [Cell(title: "Before Last Piece", timeTextfieldContent: "", stoppingTime: 0, stoppingButtonPressed: false), Cell(title: "Last Moderation", timeTextfieldContent: "", stoppingTime: 0,  stoppingButtonPressed: false), Cell(title: "Departure Time", timeTextfieldContent: "", stoppingTime: 0,  stoppingButtonPressed: false)]
            saveCellsAnd(reload: true)
            UserDefaults.standard.set(true, forKey: "FirstTime")
        } else {
            if let cellsData = UserDefaults.standard.data(forKey: "timeCells") {
                if let cells = try? PropertyListDecoder().decode(Array<Cell>.self, from: cellsData) {
                    timeCells = cells
                }
            }
        }
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapRecognized(recognizer:)))
        self.view.addGestureRecognizer(tapRecognizer)
                
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func handleKeyboardNotification(notification: Notification) {
        if let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.keyboardFrame = keyboardFrame
            isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            let isKeyboardHiding = notification.name == UIResponder.keyboardWillHideNotification
            if isKeyboardShowing {
                tableView.contentInset.bottom = keyboardFrame.height
                tableView.layoutIfNeeded()
            }
            if isKeyboardHiding {
                tableView.contentInset = UIEdgeInsets.zero
            }
        }
    }
    
    @objc func tapRecognized(recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended :
            self.view.endEditing(true)
        default: break
        }
    }
    
    func calculate() {
        let textfieldsDec = sumCells(cells: timeCells, param: .textfieldContent)
        let stoppingTimePiecesDec = sumCells(cells: timeCells, param: .stopping)
        let lastPieceDec = hours - (textfieldsDec + stoppingTimePiecesDec)
        var lastPieceMin = Int(lastPieceDec)
        let lastPieceSec = ((lastPieceDec - Double(lastPieceMin))*60).rounded()
        
        let lastPieceHour = lastPieceMin / 60
        if lastPieceHour >= 1 {
            lastPieceMin = lastPieceMin % 60
        }
        let stoppingTime = hours - stoppingTimePiecesDec - lastPieceDec
        var stoppingTimeMin = Int(stoppingTime)
        let stoppingTimeSec = ((stoppingTime - Double(stoppingTimeMin))*60).rounded()
        let stoppingTimeHour = stoppingTimeMin / 60
        if stoppingTimeHour >= 1 {
            stoppingTimeMin = stoppingTimeMin % 60
        }
        let titleAttributes : [NSAttributedString.Key: Any] = [
            .font : UIFont.systemFont(ofSize: titleLabel.font.pointSize, weight: .regular),
            .foregroundColor : UIColor.white,
            .backgroundColor : UIColor.clear,
            ]

        let timeAttributes : [NSAttributedString.Key: Any] = [
        .font : UIFont.systemFont(ofSize: titleLabel.font.pointSize, weight: .heavy),
        .foregroundColor : UIColor.white,
        .backgroundColor : UIColor.clear,
        ]
        if lastPieceDec < 0 {
            titleLabel.text = "Hour overlapped \nNo last piece possible"
        } else {
            if lastPieceHour < 1 || stoppingTimeHour < 1 {
                let result = "Last piece: " + "\(String(format: "%02d", lastPieceMin))" + ":" + "\(String(format: "%02d", Int(lastPieceSec)))\nShould start at: " + "\(String(format: "%02d", stoppingTimeMin))" + ":" + "\(String(format: "%02d", Int(stoppingTimeSec)))"
                let attributedString = NSMutableAttributedString(string: result)
                attributedString.addAttributes(titleAttributes, range: NSRange(location: 0, length: 11))
                attributedString.addAttributes(timeAttributes, range: NSRange(location: 11, length: 6))
                attributedString.addAttributes(titleAttributes, range: NSRange(location: 17, length: 17))
                attributedString.addAttributes(timeAttributes, range: NSRange(location: 34, length: 6))
                titleLabel.attributedText = attributedString
            }
            if lastPieceHour >= 1 || stoppingTimeHour >= 1 {
                let result = "Last Piece: " + "\(String(format: "%02d", lastPieceHour))" + ":" + "\(String(format: "%02d", lastPieceMin))" + ":" + "\(String(format: "%02d", Int(lastPieceSec)))\nShould start at: " + "\(String(format: "%02d", stoppingTimeHour))" + ":" + "\(String(format: "%02d", stoppingTimeMin))" + ":" + "\(String(format: "%02d", Int(stoppingTimeSec)))"
                let attributedString = NSMutableAttributedString(string: result)
                attributedString.addAttributes(titleAttributes, range: NSRange(location: 0, length: 11))
                attributedString.addAttributes(timeAttributes, range: NSRange(location: 11, length: 10))
                attributedString.addAttributes(titleAttributes, range: NSRange(location: 21, length: 17))
                attributedString.addAttributes(timeAttributes, range: NSRange(location: 38, length: 4))
                titleLabel.attributedText = attributedString
            }
        }
    }
    
    func sumCells(cells: [Cell], param: Cellparam) -> Double {
        var doubleValue = [Double]()
        var singleDoubleValue = Double()
            switch param {
            case .textfieldContent:
                for cell in cells {
                    if !cell.stoppingButtonPressed {
                        singleDoubleValue = extractDoubleValue(text: cell.timeTextfieldContent)
                        doubleValue.append(singleDoubleValue)
                    }
                }
            case .stopping:
                for cell in cells {
                    if cell.stoppingButtonPressed {
                        singleDoubleValue = cell.stoppingTime
                        doubleValue.append(singleDoubleValue)
                    }
                }
            }
        return doubleValue.reduce(0, +)
    }
    
    func extractDoubleValue(text: String) -> Double {
        var doubleValue = 0.0
        if let y = text.firstIndex(of: ":") {
            guard let sec = Double(text[text.index(after: y)..<text.endIndex]) else { return 0}
            guard let min = Double(text[..<y]) else { return 0}
            doubleValue += (min + (sec/60))
        }
        return doubleValue
    }

    @IBAction func arrangeButtonPressed(_ sender: Any) {
        buttonIsPressed = !buttonIsPressed
        if let button = sender as? UIButton {
            button.isSelected = buttonIsPressed
            tableView.setEditing(buttonIsPressed, animated: true)
            tableView.allowsSelectionDuringEditing = true
        }
    }
    
    @IBAction func clearAllButtonPressed(_ sender: Any) {
        for i in 0..<timeCells.count {
            timeCells[i].timeTextfieldContent = ""
        }
        titleLabel.text = "Radio-Calculator"
        counter = 1
        saveCellsAnd(reload: true)
    }
    
    @IBAction func hourButtonPressed(_ sender: Any) {
        switch counter {
        case 0:
            hourButton.setTitle("1h", for: .normal)
            hours = 60
            counter += 1
        case 1:
            hourButton.setTitle("2h", for: .normal)
            hours = 120
            counter += 1
        default:
            hourButton.setTitle("3h", for: .normal)
            hours = 180
            counter = 0
        }
        checkTextFields()
    }
    
    
    @objc func saveCellsAnd(reload: Bool) {
        if let dataForCell = try? PropertyListEncoder().encode(timeCells) {
            UserDefaults.standard.set(dataForCell, forKey: "timeCells")
        }
        UserDefaults.standard.synchronize()
        if reload {
            tableView.reloadData()
        }
    }
    
    @IBAction func didInsertButtonPressed() {
        timeCells.append(Cell(title: "Title", timeTextfieldContent: "", stoppingTime: 0,  stoppingButtonPressed: false))
        tableView.performBatchUpdates({ [weak self] in
            let indexPath = IndexPath(row: timeCells.count - 1, section: 0)
            self?.tableView.insertRows(at: [indexPath], with: .fade)
        })
        saveCellsAnd(reload: true)
    }
}

extension ViewController: TimefieldDelegate, TimeCellDelegate, TitleTextfieldDelegate {
    func submit(titleTextfield: UITextField) {
        actualTextField = titleTextfield
        let textorigin = titleTextfield.convert(titleTextfield.bounds.origin, to: tableView)
        if let indexPath = tableView.indexPathForRow(at: textorigin) {
            timeCells[indexPath.row].title = titleTextfield.text!
        }
        saveCellsAnd(reload: false)
    }
    
    func checkTextFields() {
        var allFilled = false
        for field in timeCells {
            if field.timeTextfieldContent.isEmpty {
                allFilled = false
                break
            } else {
                allFilled = true
            }
        }
        if allFilled {
            calculate()
        }
    }
    
    func submit(textfield: UITextField, clearedOut: Bool) {
        let textorigin = textfield.convert(textfield.bounds.origin, to: tableView)
        actualTextField = textfield
        if isKeyboardShowing {
            tableView.contentInset.bottom = keyboardFrame.height
            tableView.layoutIfNeeded()
        }
        if let indexpath = tableView.indexPathForRow(at: textorigin) {
            switch clearedOut {
            case true:
                timeCells[indexpath.row].timeTextfieldContent = ""
                timeCells[indexpath.row].stoppingTime = 0
            default:
                timeCells[indexpath.row].timeTextfieldContent = textfield.text!
                if timeCells[indexpath.row].stoppingButtonPressed {
                    timeCells[indexpath.row].stoppingTime = extractDoubleValue(text: textfield.text!)
                } else {
                    timeCells[indexpath.row].stoppingTime = 0
                }
            }
        }
    }
    
    func toggleCell(timeCell: TimeCell) {
        if let indexPath = tableView.indexPath(for: timeCell) {
            if let text = timeCell.timeTextField.text {
                let doubleValue = extractDoubleValue(text: text)
                if timeCell.stoppingTimeButton.tintColor == .systemGreen {
                    timeCells[indexPath.row].stoppingTime = doubleValue
                    timeCells[indexPath.row].stoppingButtonPressed = true
                } else {
                    timeCells[indexPath.row].stoppingTime = 0
                    timeCells[indexPath.row].stoppingButtonPressed = false
                }
                saveCellsAnd(reload: false)
                checkTextFields()
            }
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if indexPath.section == 0 {
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "timeCell1", for: indexPath)
            if let timeCell = cell1 as? TimeCell {
                timeCell.titleField.text = timeCells[indexPath.row].title
                timeCell.timeTextField.text! = timeCells[indexPath.row].timeTextfieldContent
                if timeCells[indexPath.row].stoppingButtonPressed {
                    timeCell.stoppingTimeButton.tintColor = .systemGreen
                } else {
                    timeCell.stoppingTimeButton.tintColor = .systemBlue
                }
                timeCell.timeTextField.timefieldDelegate = self
                timeCell.titleField.titleTextfieldDelegate = self
                timeCell.timeCellDelegate = self
                cell = timeCell
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            timeCells.remove(at: indexPath.row)
            tableView.performBatchUpdates({ [weak self] in
                self?.tableView.deleteRows(at: [indexPath], with: .fade)
            })
            saveCellsAnd(reload: true)
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if tableView.isEditing {
            return .none
        } else {
            return .delete
        }                
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let cell = timeCells[sourceIndexPath.row]
        timeCells.remove(at: sourceIndexPath.row)
        timeCells.insert(cell, at: destinationIndexPath.row)
        saveCellsAnd(reload: true)
    }
}
