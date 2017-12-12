//
//  MainQuoteCommentCell.swift
//  QuoteDev
//
//  Created by leejaesung on 2017. 11. 10..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import UIKit

class MainQuoteCommentCell: UITableViewCell {
    
    @IBOutlet weak var labelNickName: UILabel!
    @IBOutlet weak var labelCommentText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
