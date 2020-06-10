//
//  Timefield.swift
//  Zeitrechner
//
//  Created by Kersten Weise on 03.08.19.
//  Copyright © 2019 Kersten Weise. All rights reserved.
//

import UIKit

protocol TimefieldDelegate {
    func submit(textfield: UITextField, clearedOut: Bool)
    func checkTextFields()
}

class Timefield: UITextField, UITextFieldDelegate {

    var timefieldDelegate : TimefieldDelegate?
    
    override var canResignFirstResponder: Bool {
        return true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.sizeToFit()
        self.layer.shadowOffset = CGSize(width: 10, height: 10)
        self.layer.shadowRadius = 5
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowOpacity = 0.8
        self.layer.masksToBounds = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var oldText = textField.text!
        if let i = oldText.firstIndex(of: ":") {
            oldText.remove(at: i)
        }
        if let newNumber = Int(oldText + string) {
            let formatter = NumberFormatter()
            formatter.positiveFormat = "00,00"
            formatter.groupingSeparator = ":"
            
            if let newText = formatter.string(from: NSNumber(value: newNumber)) {
                if newText.count > 5 {
                    return false
                } else {
                    textField.text = newText
                }
            }
        }
        if string.isEmpty {
            textField.text!.removeLast()
        }
        timefieldDelegate?.submit(textfield: textField, clearedOut: false)
        timefieldDelegate?.checkTextFields()
        return false
    }
    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        timefieldDelegate?.checkTextFields()
//    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.becomeFirstResponder()
        timefieldDelegate?.submit(textfield: textField, clearedOut: true)
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        timefieldDelegate?.submit(textfield: textField, clearedOut: false)
        return true
    }
}
