//
//  RoundButton.swift
//  MemoryCap
//
//  Created by Bao Trinh on 4/16/17.
//  Copyright © 2017 Bao Trinh. All rights reserved.
//

import UIKit

class RoundButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        /*
         // dropshadow
         layer.shadowColor = UIColor(red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.6).cgColor
         layer.shadowOpacity = 0.8
         layer.shadowRadius = 5.0
         layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
         */
        // aspect fit
        imageView?.contentMode = .scaleAspectFit
    }
    
    // round button
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = self.frame.height / 2
    }
}
