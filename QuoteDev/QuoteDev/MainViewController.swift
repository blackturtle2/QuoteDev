//
//  ViewController.swift
//  QuoteDev
//
//  Created by leejaesung on 2017. 9. 14..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import UIKit
import Firebase

class MainViewController: UIViewController {
    
    @IBOutlet var tableViewMain: UITableView!
    
    @IBOutlet var buttonLike : UIButton! //명언 좋아요 버튼
    @IBOutlet var buttonComment : UIButton! //명언 댓글 버튼
    
    /*******************************************/
    //MARK:-        LifeCycle                  //
    /*******************************************/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableViewMain.delegate = self
        self.tableViewMain.dataSource = self
        
        //스크롤 뷰의 initial position을 조정해서 명언 모드 Segmented Control이 처음에는 보이지 않게 합니다.
        self.tableViewMain.contentOffset = CGPoint(x: 0, y: 50)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*******************************************/
    //MARK:-         Functions                 //
    /*******************************************/
    
    // MARK: 명언 좋아요 버튼 액션
    @IBAction func buttonLikeAction(_ sender: UIButton) {
        
    }
    
    // MARK: 명언 댓글 버튼 액션
    @IBAction func buttonCommentAction(_ sender: UIButton) {
        
        // UserDefaults에 사용자 닉네임이 없으면, 닉네임을 받습니다.
        if UserDefaults.standard.string(forKey: Constants.userDefaults_UserNickname) == nil {
            
            // UIAlertController 생성
            let alertSetUserNickname:UIAlertController = UIAlertController(title: "닉네임 설정", message: "닉네임을 설정해주세요.", preferredStyle: .alert)
            
            // testField 추가
            alertSetUserNickname.addTextField { (textField) in
                textField.placeholder = "스티브 잡스"
            }
            
            // OK 버튼 Action 추가
            alertSetUserNickname.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alertSetUserNickname] (_) in
                
                // 텍스트필드 호출
                let textFieldNickname = alertSetUserNickname!.textFields![0] // 위에서 직접 추가한 텍스트필드이므로 옵셔널 바인딩은 스킵.
                print("///// textField: ", textFieldNickname.text ?? "(no data)")
                
                // UserDefaults 에서 uid 호출 & 사용자가 텍스트필드에 입력한 텍스트 호출
                guard let uid = UserDefaults.standard.string(forKey: Constants.userDefaults_Uid) else { return }
                guard let userNickname = alertSetUserNickname!.textFields?[0].text else { return }
                
                let dicUserData:[String:Any] = [Constants.firebaseUserUid:uid, Constants.firebaseUserNickname:userNickname]
                
                // Firebase DB & UserDefaults에 저장
                Database.database().reference().child(Constants.firebaseUsersRoot).child(uid).setValue(dicUserData)
                UserDefaults.standard.set(userNickname, forKey: Constants.userDefaults_UserNickname)
                
                // 명언 댓글 뷰로 이동
                // 닉네임이 있을 경우, 스토리보드 상에 선언된 show를 타서 이동합니다.
                let nextVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.quoteCommentViewController) as! QuoteCommentViewController
                self.navigationController?.pushViewController(nextVC, animated: true)
                
            }))
            
            self.present(alertSetUserNickname, animated: true, completion: nil)
            
        }
        
        
        
    }
    
}

/*******************************************/
//MARK:-         extenstion                //
/*******************************************/
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    enum enumMainTableViewSection : Int {
        case quoteComment = 0
        case save = 1
        case archive = 2
    }
    
    // section의 개수
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    // section의 타이틀
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case enumMainTableViewSection.save.rawValue:
            return "SAVE"
        case enumMainTableViewSection.archive.rawValue:
            return "ARCHIVE"
        default:
            return ""
        }
    }
    
    // section의 row 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case enumMainTableViewSection.quoteComment.rawValue:
            return 3 //명언 댓글 리스트
        case enumMainTableViewSection.save.rawValue:
            return 2 //사진으로 저장, 배경화면으로 저장
        case enumMainTableViewSection.archive.rawValue:
            return 2 //나의 좋아요 명언, 나의 댓글 명언
        default:
            return 0
        }
    }
    
    // footer의 타이틀
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case enumMainTableViewSection.quoteComment.rawValue:
            return " "
        default:
            return nil
        }
    }
    
    // cell 그리기
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let basicCell = UITableViewCell()
        
        switch indexPath.section {
        case enumMainTableViewSection.quoteComment.rawValue:
            switch indexPath.row{
            case 0: //명언 댓글 첫번째
                return tableView.dequeueReusableCell(withIdentifier: "quoteComment", for: indexPath)
            case 1: //명언 댓글 두번째
                return tableView.dequeueReusableCell(withIdentifier: "quoteComment", for: indexPath)
            case 2: // 댓글 더보기 버튼
                return tableView.dequeueReusableCell(withIdentifier: "moreCommentsButton", for: indexPath)
            default:
                return basicCell
            }
        case enumMainTableViewSection.save.rawValue:
            switch indexPath.row{
            case 0: //사진으로 저장
                return tableView.dequeueReusableCell(withIdentifier: "saveToPhotoAlbumButton", for: indexPath)
            case 1: //배경화면으로 저장
                return tableView.dequeueReusableCell(withIdentifier: "saveToBackgroundPhotoButton", for: indexPath)
            default:
                return basicCell
            }
        case enumMainTableViewSection.archive.rawValue:
            switch indexPath.row{
            case 0: //나의 좋아요 명언
                return tableView.dequeueReusableCell(withIdentifier: "myLikeQuotesButton", for: indexPath)
            case 1: //나의 댓글 명언
                return tableView.dequeueReusableCell(withIdentifier: "myCommentQuoteButton", for: indexPath)
            default:
                return basicCell
            }
        default:
            return basicCell
        }
        
    }
}
