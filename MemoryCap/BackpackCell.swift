//
//  BackpackCell.swift
//  MemoryCap
//
//  Created by Bao Trinh on 4/17/17.
//  Copyright © 2017 Bao Trinh. All rights reserved.
//

import UIKit

class BackpackCell: UITableViewCell {

    @IBOutlet weak var caption: UILabel!
    @IBOutlet weak var preview: RoundImageView!
    var key: String!
    var imageKeyArray: [String] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
