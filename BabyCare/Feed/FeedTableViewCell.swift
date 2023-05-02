//
//  FeedTableViewCell.swift
//  BabyCare
//
//  Created by Ayush Pandey on 2/5/2023.
//

import UIKit

class FeedTableViewCell: UITableViewCell {

    @IBOutlet weak var milkTypeLabel: UILabel!
    @IBOutlet weak var feedDateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
