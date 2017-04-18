//
//  RoundTextField.swift
//  MemoryCap
//
//  Created by Bao Trinh on 4/16/17.
//  Copyright © 2017 Bao Trinh. All rights reserved.
//

import UIKit

class RoundTextField: UITextField {
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    // round textfield
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = self.frame.height / 2
        
    }
}
