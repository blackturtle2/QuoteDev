//
//  CustomCommentTableViewCell.swift
//  QuoteDev
//
//  Created by leejaesung on 2017. 7. 10..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import UIKit

class CustomCommentTableViewCell: UITableViewCell {
    
    @IBOutlet var labelName:UILabel?
    @IBOutlet var labelContent:UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
