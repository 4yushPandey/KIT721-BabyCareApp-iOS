//
//  GrowthTableViewCell.swift
//  BabyCare
//
//  Created by Ayush Pandey on 4/5/2023.
//

import UIKit

class GrowthTableViewCell: UITableViewCell {

    
    
    @IBOutlet weak var measuredDateLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
