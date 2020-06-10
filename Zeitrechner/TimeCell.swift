//
//  TimeCell.swift
//  Zeitrechner
//
//  Created by Kersten Weise on 04.08.19.
//  Copyright © 2019 Kersten Weise. All rights reserved.
//

import UIKit

protocol TimeCellDelegate {
    func checkTextFields()
    func submit(textfield: UITextField, clearedOut: Bool)
    func toggleCell(timeCell: TimeCell)
}

class TimeCell: UITableViewCell {

    @IBOutlet weak var titleField: TitleTextfield!
    @IBOutlet weak var timeTextField: Timefield!
    @IBOutlet weak var stoppingTimeButton: UIButton!
    
    var timeCellDelegate : TimeCellDelegate?
            
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
    }
    
    @IBAction func plusMinusButtonPressed(_ sender: Any) {
        switch stoppingTimeButton.tintColor! {
        case .systemGreen:
            stoppingTimeButton.tintColor = .systemBlue
        case .systemBlue:
            stoppingTimeButton.tintColor = .systemGreen
        default: break
        }
        timeCellDelegate?.toggleCell(timeCell: self)
    }
    
    @IBAction func timeButtonPressed(_ sender: Any) {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "mm:ss"
        timeTextField.text = formatter.string(from: date)
        timeCellDelegate?.submit(textfield: timeTextField, clearedOut: false)
        timeCellDelegate?.checkTextFields()
    }
}
