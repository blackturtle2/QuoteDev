//
//  ViewController.swift
//  QuoteDev
//
//  Created by leejaesung on 2017. 7. 6..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var imageQuoteImg:UIImageView?
    @IBOutlet var labelQuoteContent:UILabel?
    @IBOutlet var labelQuoteSpeaker:UILabel?
    
    @IBOutlet var buttonLikeNum:UIButton?
    @IBOutlet var buttonCommentNum:UIButton?
    
    @IBOutlet var tableViewComment:UITableView!
    
    var randomNum = Int(arc4random_uniform(4))
    
    
    // MARK: Lyfe Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewComment?.delegate = self
        tableViewComment?.dataSource = self
        
        DataCenter.sharedInstance.loadData()
        DataCenter.sharedInstance.loadCommentData()
        
        loadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: Logic
    func loadData() {
        var secondRandomNumber = Int(arc4random_uniform(9))
        
        // 같은 이미지가 반복되지 않도록 예외처리
        while randomNum == secondRandomNumber {
            secondRandomNumber = Int(arc4random_uniform(9))
        }
        randomNum = secondRandomNumber
        print(secondRandomNumber)
        
        print(DataCenter.sharedInstance.getQuoteImageFileNameOf(index: secondRandomNumber))
        imageQuoteImg?.image = UIImage(named: DataCenter.sharedInstance.getQuoteImageFileNameOf(index: secondRandomNumber))
        labelQuoteContent?.text = DataCenter.sharedInstance.getQuoteContentOf(index: secondRandomNumber)
        labelQuoteSpeaker?.text = "- \(DataCenter.sharedInstance.getQuoteSpeakerOf(index: secondRandomNumber)) -"
        
        let tempCommentData = DataCenter.sharedInstance.getCommentDataOf(index: secondRandomNumber)
        buttonCommentNum?.setTitle(String(tempCommentData._arrComment.count), for: .normal)
        
        tableViewComment.reloadData()
        
    }
    
    @IBAction func buttonReloadAction(_ sender:UIButton) {
        print("buttonReload")
        
        loadData()
    }
    
    @IBAction func buttonSettingAction(_ sender:UIButton) {
        print("buttonSettingAction")
        // Segue로 SettingViewController로 연결.
    }
    
    @IBAction func buttonLikeAction(_ sender:UIButton) {
        print("buttonLikeAction")
        
    }
    
    @IBAction func buttonCommentAction(_ sender:UIButton) {
        print("buttonCommentAction")
        
        UserDefaults.standard.set(randomNum, forKey: "currentIndex")
        
    }
    
    @IBAction func buttonCommentNumAction(_ sender:UIButton) {
        UserDefaults.standard.set(randomNum, forKey: "currentIndex")
    }
    
    @IBAction func buttonSavePhotoAction(_ sender:UIButton) {
        print("buttonSavePhotoAction")
        
    }
    
    
    // MARK: 댓글 테이블뷰 데이터 로드.
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let commentCell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! CustomCommentTableViewCell
        
        commentCell.labelName?.text = DataCenter.sharedInstance.getCommentDataOf(index: randomNum).getDicOf(index: indexPath.row).nickName
        commentCell.labelContent?.text = DataCenter.sharedInstance.getCommentDataOf(index: randomNum).getDicOf(index: indexPath.row).comment

        return commentCell
    }

}

