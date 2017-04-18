//
//  RoundImage.swift
//  MemoryCap
//
//  Created by Bao Trinh on 4/17/17.
//  Copyright © 2017 Bao Trinh. All rights reserved.
//

import UIKit

class RoundImageView: UIImageView {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = self.frame.height / 8
        clipsToBounds = true
    }
    
}
