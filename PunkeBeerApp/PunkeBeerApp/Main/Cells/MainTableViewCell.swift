//
//  MainTableViewCell.swift
//  PunkeBeerApp
//
//  Created by Marc Gallardo on 03/08/2020.
//  Copyright © 2020 Marc Gallardo. All rights reserved.
//

import UIKit

class MainTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgBeer: UIImageView!
    @IBOutlet weak var lblNameBeer: UILabel!
    @IBOutlet weak var lblTagLine: UILabel!
    @IBOutlet weak var lblDescription: UITextView!
    @IBOutlet weak var lblAbv: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
