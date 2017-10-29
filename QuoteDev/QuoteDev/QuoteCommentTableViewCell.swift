//
//  QuoteCommentTableViewCell.swift
//  QuoteDev
//
//  Created by leejaesung on 2017. 10. 28..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import UIKit

class QuoteCommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelCommentKeyID: UILabel!
    @IBOutlet weak var labelCommentWriter: UILabel!
    @IBOutlet weak var labelCommentText: UILabel!
    @IBOutlet weak var labelCommentCreatedDate: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func buttonCommentOption(_ sender: UIButton) {
        print("///// buttonCommentOption- 4783\n")
    }
    
    @IBAction func buttonCommentLikeAction(_ sender: UIButton) {
        print("///// buttonCommentLikeAction- 5234\n")
    }
    
    @IBAction func buttonCommentLikeCountAction(_ sender: UIButton) {
        print("///// buttonCommentLikeCountAction- 5223\n")
    }

}
