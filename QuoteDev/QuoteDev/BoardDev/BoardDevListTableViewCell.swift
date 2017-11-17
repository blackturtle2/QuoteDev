//
//  BoardDevListTableViewCell.swift
//  QuoteDev
//
//  Created by HwangGisu on 2017. 9. 26..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import UIKit

class BoardDevListTableViewCell: UITableViewCell {
    @IBOutlet weak var boardCountLabel: UILabel!
    @IBOutlet weak var boardWriterLabel: UILabel!
    @IBOutlet weak var boardCotentsLabel: UILabel!
    @IBOutlet weak var boardCreateAtLabel: UILabel!
    
    @IBOutlet weak var boardLikeCountLabel: UILabel!
    @IBOutlet weak var boardReqCountLabel: UILabel!
    
    @IBOutlet weak var imageResultLabel: UILabel!
    @IBOutlet weak var imageResultImgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
