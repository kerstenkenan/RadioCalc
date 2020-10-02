//
//  TitleTextfield.swift
//  Zeitrechner
//
//  Created by Kersten Weise on 26.11.19.
//  Copyright © 2019 Kersten Weise. All rights reserved.
//

import UIKit

protocol TitleTextfieldDelegate {
    func submit(titleTextfield: UITextField)
}

class TitleTextfield: UITextField, UITextFieldDelegate {
    var titleTextfieldDelegate: TitleTextfieldDelegate?
        
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.delegate = self
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        titleTextfieldDelegate?.submit(titleTextfield: textField)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        titleTextfieldDelegate?.submit(titleTextfield: textField)
    }
    
    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: self.bounds.maxX - 25, y: self.bounds.midY - 10, width: 20, height: 20)
    }
}
