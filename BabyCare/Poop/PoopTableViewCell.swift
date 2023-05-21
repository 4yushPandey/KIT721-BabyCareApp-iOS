//
//  PoopTableViewCell.swift
//  BabyCare
//
//  Created by Ayush Pandey on 4/5/2023.
//

import UIKit

class PoopTableViewCell: UITableViewCell {

    @IBOutlet weak var nappyType: UILabel!
    @IBOutlet weak var poopTime: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
