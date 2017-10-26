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
    @IBOutlet weak var segmentedControlQuoteMode: UISegmentedControl!
    
    @IBOutlet var labelQuoteText : UILabel! //명언 텍스트 레이블
    @IBOutlet var labelQuoteAuthor : UILabel! //명언 출처 or 저자 레이블
    
    @IBOutlet var buttonLike : UIButton! //명언 좋아요 버튼
    @IBOutlet var buttonLikeCount : UIButton! //명언 좋아요 버튼
    @IBOutlet var buttonComment : UIButton! //명언 댓글 버튼
    @IBOutlet var buttonCommentCount : UIButton! //명언 댓글 버튼
    
    var todaysQuoteID: String?
    
    var quoteSeriousKey: String? //오늘 날짜에 해당하는 진지모드 명언 키 값을 저장하는 변수
    var quoteJoyfulKey: String? //오늘 날짜에 해당하는 유쾌모드 명언 키 값을 저장하는 변수
    
    
    /*******************************************/
    //MARK:-        LifeCycle                  //
    /*******************************************/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableViewMain.delegate = self
        self.tableViewMain.dataSource = self
        
        // UI: Segmented Control의 흰색 배경이 비치지 않도록 합니다.
        self.segmentedControlQuoteMode.layer.cornerRadius = 5;
        
        // UI: 스크롤 뷰의 initial position을 조정해서 명언 모드 Segmented Control이 처음에는 보이지 않게 합니다.
        self.tableViewMain.contentOffset = CGPoint(x: 0, y: 50)
        
        // 기본 명언 모드를 세팅합니다. 앱 최초 실행으로 저장되어 있지 않으면, 강제로 진지모드로 설정(UserDefaults)합니다.
        if UserDefaults.standard.string(forKey: Constants.settingDefaultQuoteMode) == nil {
            UserDefaults.standard.set(Constants.settingQuoteModeSerious, forKey: Constants.settingDefaultQuoteMode)
        }
        guard let userQuoteModeSetting = UserDefaults.standard.string(forKey: Constants.settingDefaultQuoteMode) else { return }
        
        // UI: 사용자 설정이 유쾌모드일 경우, 화면 최상단에 있는 Segmented Control의 index를 바꿉니다.
        if userQuoteModeSetting == Constants.settingQuoteModeJoyful {
            self.segmentedControlQuoteMode.selectedSegmentIndex = 1 // 기본 세팅이 0이므로 진지 모드의 케이스는 액션을 주지 않았습니다.
        }
        
        // 오늘 날짜를 태워서 명언의 키 값을 찾고, UI에 출력까지 실행합니다.
        self.findTodayQuoteKey(quoteMode: userQuoteModeSetting, todayDate: Date())
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*******************************************/
    //MARK:-         Functions                 //
    /*******************************************/
    
    // MARK: 명언 모드 Segmented Control 액션 정의
    // 오늘 날짜의 명언 키 값이 전역 변수에 저장되어 있으면, findShowQuoteData()를 호출하고, 저장되어 있지 않으면, viewDidLoad()의 로직과 같은 루트로 실행합니다.
    @IBAction func segmentedControlQuoteModeAction(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 { // 진지 모드
            guard let realQuoteSeriousKey = self.quoteSeriousKey else {
                self.findTodayQuoteKey(quoteMode: Constants.settingQuoteModeSerious, todayDate: Date())
                return
            }
            
            self.findShowQuoteData(quoteMode: Constants.settingQuoteModeSerious, quoteKey: realQuoteSeriousKey)
            
        }else if sender.selectedSegmentIndex == 1 { // 유쾌 모드
            guard let realJoyfulSeriousKey = self.quoteJoyfulKey else {
                self.findTodayQuoteKey(quoteMode: Constants.settingQuoteModeJoyful, todayDate: Date())
                return
            }
            
            self.findShowQuoteData(quoteMode: Constants.settingQuoteModeJoyful, quoteKey: realJoyfulSeriousKey)
        }
    }
    
    // MARK: 오늘 날짜에 맞는 명언 키 값 가져오고, showQuoteData() 호출하기
    func findTodayQuoteKey(quoteMode:String, todayDate:Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMdd" // Firebase의 DB에 오늘 날짜(MMdd)에 맞춰서 오늘자 명언의 Key 값들이 저장되어 있습니다.
        
        let today = formatter.string(from: Date())
        
        // 진지모드 key 값 가져오기
        if quoteMode == Constants.settingQuoteModeSerious {
            Database.database().reference().child("quotes_data_today_kor_serious").child(today).observeSingleEvent(of: DataEventType.value, with: {[unowned self] (snapshot) in
                print("///// firebase snapshot- 425: \n", snapshot)
                
                guard let realQouteSeriousKey = snapshot.value as? Int else { return }
                print("///// data- 425: \n", realQouteSeriousKey)
                self.quoteSeriousKey = String(realQouteSeriousKey)
                
                // 해당 키 값에 맞는 명언 데이터 가져오기
                self.findShowQuoteData(quoteMode: quoteMode, quoteKey: String(realQouteSeriousKey))
                
            }) { (error) in
                print("///// firebase error- 425: \n", error)
            }
            
        // 유쾌모드 key 값 가져오기
        } else if quoteMode == Constants.settingQuoteModeJoyful {
            Database.database().reference().child("quotes_data_today_kor_joyful").child(today).observeSingleEvent(of: DataEventType.value, with: {[unowned self] (snapshot) in
                print("///// firebase snapshot- 5236: \n", snapshot)
                
                guard let realQouteJoyfulKey = snapshot.value as? Int else { return }
                print("///// data- 5236: \n", realQouteJoyfulKey)
                self.quoteJoyfulKey = String(realQouteJoyfulKey)
                
                // 해당 키 값에 맞는 명언 데이터 가져오기
                self.findShowQuoteData(quoteMode: quoteMode, quoteKey: String(realQouteJoyfulKey))
                
            }) { (error) in
                print("///// firebase error- 5236: \n", error)
            }
        }
    }
    
    // MARK: 명언 모드와 키 값에 따라 명언 데이터를 가져오고, UI에 표현까지 완료하는 코드 구현
    func findShowQuoteData(quoteMode:String, quoteKey:String) {
        
        // 명언 모드에 따른 데이터 통신
        Database.database().reference().child(quoteMode).child(quoteKey).observeSingleEvent(of: DataEventType.value, with: {[unowned self]  (snapshot) in
            guard let data = snapshot.value as? [String:Any] else { return }
            print("///// firebase snapshot- 2341: \n", data)
            
            let quotesID = data[Constants.firebaseQuoteID] as! String
            let quotesText = data[Constants.firebaseQuoteText] as! String
            let quotesAuthor = data[Constants.firebaseQuoteAuthor] as! String
            
            // UI 적용
            DispatchQueue.main.async {
                self.labelQuoteText.text = "“" + quotesText + "”"
                self.labelQuoteAuthor.text = "- " + quotesAuthor + " -"
            }
            
            self.todaysQuoteID = quotesID
            UserDefaults.standard.set(quotesID, forKey: Constants.userDefaultsTodayQuoteID)
            
            // 좋아요 개수를 가져오고, UI에 반영합니다.
            self.showQuoteLikesCount()
            
        }) { (error) in
            print("///// firebase error- 2341: \n", error)
        }
    }
    
    // MARK: 명언 좋아요 버튼의 카운트 변경 function 정의
    func showQuoteLikesCount() {
        guard let realTodayQuoteID = self.todaysQuoteID else { return }
        Database.database().reference().child(Constants.firebaseQuoteLikes).child(realTodayQuoteID).observe(DataEventType.value, with: {[unowned self] (snapshot) in
            guard let data = snapshot.value as? [String] else { return }
            print("///// data- firebase snapshot- quotes_likes: \n", data)
            
            let likesCount = data.count
            
            DispatchQueue.main.async {
                self.buttonLikeCount.setTitle(String(likesCount), for: UIControlState.normal)
            }
            
        }) { (error) in
            print("///// error- firebase quotes_likes: \n", error)
        }
    }
    
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
            alertSetUserNickname.addAction(UIAlertAction(title: "확인", style: .default, handler: { [weak alertSetUserNickname] (_) in
                
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
    
    // MARK: 명언 공유 버튼 액션 정의
    @IBAction func buttonShareAction(_ sender: UIButton) {
        guard let quoteText = self.labelQuoteText.text else { return }
        guard let quoteAuthor = self.labelQuoteAuthor.text else { return }
        let sharingText = quoteText + "\n" + quoteAuthor + "\n\n" + "by QuoteDev"
        
        self.shareTextOf(text: sharingText)
    }
    
    // 텍스트 공유 기능 function 정의
    func shareTextOf(text: String) {
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil) // 액티비티 뷰 컨트롤러 설정
        activityVC.popoverPresentationController?.sourceView = self.view // 아이패드에서 작동하도록 pop over로 설정
        activityVC.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.addToReadingList, UIActivityType.saveToCameraRoll ] // 제외 타입 설정: 에어드롭, 읽기목록, 카메라롤 저장
        
        self.present(activityVC, animated: true, completion: nil)
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
    
    // MARK: tableView - section의 개수
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    // MARK: tableView - section의 타이틀
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
    
    // MARK: tableView - section의 row 개수
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
    
    // MARK: tableView - footer의 타이틀
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case enumMainTableViewSection.quoteComment.rawValue:
            return " "
        default:
            return nil
        }
    }
    
    // MARK: tableView - cell 그리기
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
    
    // MARK: tableView - DidSelectRowAt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // 터치한 표시를 제거하는 액션
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}
