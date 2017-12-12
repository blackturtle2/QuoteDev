//
//  MyLikeCommentListTableViewCell.swift
//  QuoteDev
//
//  Created by leejaesung on 2017. 12. 2..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import UIKit

class MyLikeCommentListTableViewCell: UITableViewCell {

    @IBOutlet weak var labelQuoteText: UILabel!
    @IBOutlet weak var labelQuoteAuthor: UILabel!
    
    var quoteID: String?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
