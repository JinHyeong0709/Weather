//
//  ForecastTableViewCell.swift
//  Weather
//
//  Created by 김진형 on 02/11/2018.
//  Copyright © 2018 김진형. All rights reserved.
//

import UIKit

class ForecastTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.clear
        statusLabel.textColor = UIColor.white
        dateLabel.textColor = statusLabel.textColor
        timeLabel.textColor = statusLabel.textColor
        temperatureLabel.textColor = statusLabel.textColor
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
