//
//  QuoteCommentViewController.swift
//  QuoteDev
//
//  Created by leejaesung on 2017. 9. 20..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import UIKit

class QuoteCommentViewController: UIViewController {

    @IBOutlet weak var tableViewMain: UITableView!
    
    @IBOutlet weak var viewWritingCommentBox: UIView!
    @IBOutlet weak var textFieldWritingComment: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableViewMain.delegate = self
        self.tableViewMain.dataSource = self
        
        self.textFieldWritingComment.layer.borderColor = UIColor.black.cgColor
        self.textFieldWritingComment.layer.borderWidth = 1.0
//        self.textFieldWritingComment.borderStyle = .roundedRect
        self.textFieldWritingComment.layer.cornerRadius = 5; // borderStyle이 먹지 않는 관계로.. cornerRadius를 강제로 삽입합니다.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

/*******************************************/
//MARK:-         extenstion                //
/*******************************************/
extension QuoteCommentViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "comment_cell", for: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}
