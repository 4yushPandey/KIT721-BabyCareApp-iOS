//
//  SleeoTableViewCell.swift
//  BabyCare
//
//  Created by Ayush Pandey on 4/5/2023.
//

import UIKit

class SleepTableViewCell: UITableViewCell {

    
    @IBOutlet weak var sleepStartLabel: UILabel!
    @IBOutlet weak var sleepEndLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
