//
//  SummaryTableViewCell.swift
//  Weather
//
//  Created by 김진형 on 2018. 5. 14..
//  Copyright © 2018년 김진형. All rights reserved.
//

import UIKit

class SummaryTableViewCell: UITableViewCell {

    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var minMaxLabel: UILabel!
    @IBOutlet weak var skyNameLabel: UILabel!
    @IBOutlet weak var currentTempLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        
        skyNameLabel.textColor = UIColor.white
        minMaxLabel.textColor = skyNameLabel.textColor
        currentTempLabel.textColor = skyNameLabel.textColor
    }
}
