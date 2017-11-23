//
//  ViewController.swift
//  QuoteDev
//
//  Created by leejaesung on 2017. 9. 14..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import UIKit
import Firebase
import Toaster

class MainViewController: UIViewController {
    
    @IBOutlet var mainTableView: UITableView!
    @IBOutlet weak var segmentedControlQuoteMode: UISegmentedControl!
    
    @IBOutlet var labelQuoteText : UILabel! //명언 텍스트 레이블
    @IBOutlet var labelQuoteAuthor : UILabel! //명언 출처 or 저자 레이블
    
    @IBOutlet var buttonLike : UIButton! //명언 좋아요 버튼
    @IBOutlet var buttonLikeCount : UIButton! //명언 좋아요 개수 버튼
    @IBOutlet var buttonComment : UIButton! //명언 댓글 버튼
    @IBOutlet var buttonCommentsCount : UIButton! //명언 댓글 개수 버튼
    
    var currentQuoteID: String? // 현재의 명언 ID 저장 변수 - 좋아요, 댓글 개수, 댓글 목록 등에 활용합니다.
    
    var quoteSeriousKey: String? //오늘 날짜에 해당하는 진지모드 명언 키 값을 저장하는 변수
    var quoteJoyfulKey: String? //오늘 날짜에 해당하는 유쾌모드 명언 키 값을 저장하는 변수
    
    var commentsList: [QuoteComment] = [] // 최신 2개 댓글 데이터 저장용
    
    
    /*******************************************/
    //MARK:-        LifeCycle                  //
    /*******************************************/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        
        // UI: Segmented Control의 흰색 배경이 비치지 않도록 합니다.
        self.segmentedControlQuoteMode.layer.cornerRadius = 5;
        
        // UI: 스크롤 뷰의 initial position을 조정해서 명언 모드 Segmented Control이 처음에는 보이지 않게 합니다.
        // 메인 뷰에서 댓글을 가져오는 통신을 위해, reload를 하다보니, main queue를 태워야 원활하게 작동하였습니다.
        DispatchQueue.main.async {
            self.mainTableView.contentOffset = CGPoint(x: 0, y: 50)
        }
        
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
        self.getTodaysQuoteKeyAndShowData(selectedQuoteMode: userQuoteModeSetting, todayDate: Date())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*******************************************/
    //MARK:-         Functions                 //
    /*******************************************/
    // MARK: 명언 새로고침 버튼 액션 정의
    @IBAction func actionRefreshButton(_ sender: Any) {
        // UI
        DispatchQueue.main.async {
            // Segmented Control 보이지 않게 하기
            self.mainTableView.contentOffset = CGPoint(x: 0, y: 50)
        }
        
        switch self.segmentedControlQuoteMode.selectedSegmentIndex {
        case 0: // 진지 모드
            self.getTodaysQuoteKeyAndShowData(selectedQuoteMode: Constants.settingQuoteModeSerious, todayDate: Date())
            
        case 1: // 유쾌 모드
            self.getTodaysQuoteKeyAndShowData(selectedQuoteMode: Constants.settingQuoteModeJoyful, todayDate: Date())
        default:
            self.viewDidLoad()
        }
    }
    
    // MARK: 명언 모드 Segmented Control 액션 정의
    // 오늘의 명언 키 값을 이미 갖고 있느냐 아니냐에 따라 로직이 달라집니다.
    // 전역 변수에 오늘의 명언 키 값이 nil 이면, getTodaysQuoteKeyAndShowData()를 호출하고(viewDidLoad()와 같은 로직), 저장되어 있으면, getAndShowQuoteData()를 실행합니다.
    @IBAction func segmentedControlQuoteModeAction(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 { // 진지 모드
            guard let realSeriousKey = self.quoteSeriousKey else {
                self.getTodaysQuoteKeyAndShowData(selectedQuoteMode: Constants.settingQuoteModeSerious, todayDate: Date())
                return
            }
            
            self.getAndShowQuoteData(quoteMode: Constants.settingQuoteModeSerious, quoteKey: realSeriousKey)
            
        }else if sender.selectedSegmentIndex == 1 { // 유쾌 모드
            guard let realJoyfulKey = self.quoteJoyfulKey else {
                self.getTodaysQuoteKeyAndShowData(selectedQuoteMode: Constants.settingQuoteModeJoyful, todayDate: Date())
                return
            }
            
            self.getAndShowQuoteData(quoteMode: Constants.settingQuoteModeJoyful, quoteKey: realJoyfulKey)
        }
    }
    
    // MARK: 명언 키 값 가져오기 - 오늘 날짜에 맞는 명언 키 값 가져오고, getAndShowQuoteData() 호출하기
    func getTodaysQuoteKeyAndShowData(selectedQuoteMode:String, todayDate:Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMdd" // Firebase의 DB에 오늘 날짜(MMdd)에 맞춰서 오늘자 명언의 Key 값들이 저장되어 있습니다.
        
        let today = formatter.string(from: Date())
        
        // 각 모드에 맞는 key 값 가져오기
        if selectedQuoteMode == Constants.settingQuoteModeSerious {
            // 진지 모드
            Database.database().reference().child("quotes_data_today_kor_serious").child(today).observeSingleEvent(of: DataEventType.value, with: {[unowned self] (snapshot) in
                
                guard let realQouteSeriousKey = snapshot.value as? Int else { return }
                print("///// data- 425: \n", realQouteSeriousKey)
                self.quoteSeriousKey = String(realQouteSeriousKey) // 전역 변수에 저장하기
                
                // 해당 키 값에 맞는 명언 데이터 가져오기
                self.getAndShowQuoteData(quoteMode: selectedQuoteMode, quoteKey: String(realQouteSeriousKey))
                
            }) { (error) in
                print("///// firebase error- 425: \n", error)
            }
            
        } else if selectedQuoteMode == Constants.settingQuoteModeJoyful {
            // 유쾌 모드
            Database.database().reference().child("quotes_data_today_kor_joyful").child(today).observeSingleEvent(of: DataEventType.value, with: {[unowned self] (snapshot) in
                
                guard let realQouteJoyfulKey = snapshot.value as? Int else { return }
                print("///// data- 5236: \n", realQouteJoyfulKey)
                self.quoteJoyfulKey = String(realQouteJoyfulKey) // 전역 변수에 저장하기
                
                // 해당 키 값에 맞는 명언 데이터 가져오기
                self.getAndShowQuoteData(quoteMode: selectedQuoteMode, quoteKey: String(realQouteJoyfulKey))
                
            }) { (error) in
                print("///// firebase error- 5236: \n", error)
            }
        }
    }
    
    // MARK: [메인 플로우] 명언 데이터 가져오기 - 명언 모드와 키 값에 따라 명언 데이터를 가져오고, UI에 표현까지 완료하는 코드 구현
    func getAndShowQuoteData(quoteMode:String, quoteKey:String) {
        
        // 명언 모드에 따른 데이터 통신
        Database.database().reference().child(quoteMode).child(quoteKey).observeSingleEvent(of: DataEventType.value, with: {[unowned self]  (snapshot) in
            guard let data = snapshot.value as? [String:Any] else { return }
            
            let quoteID = data[Constants.firebaseQuoteID] as! String
            let quoteText = data[Constants.firebaseQuoteText] as! String
            let quoteAuthor = data[Constants.firebaseQuoteAuthor] as! String
            
            // UI
            DispatchQueue.main.async {
                self.labelQuoteText.text = "“" + quoteText + "”"
                self.labelQuoteAuthor.text = "- " + quoteAuthor + " -"
                
                // 값이 없으면, 특수문자 표시하지 않기
                if quoteText == "" {
                    self.labelQuoteText.text = quoteText
                }
                
                if quoteAuthor == "" {
                    self.labelQuoteAuthor.text = quoteAuthor
                }
            }
            
            // 전역 변수와 UserDefaults에 현재 보여지는 명언 ID를 저장합니다.
            self.currentQuoteID = quoteID
            UserDefaults.standard.set(quoteID, forKey: Constants.userDefaultsCurrentQuoteID)
            
            // 좋아요 개수를 가져오고, UI에 반영합니다.
            self.getAndShowQuoteLikesCountOf(quoteID: quoteID)
            
            // 사용자가 좋아요를 눌렀는지 체크하고, UI에 반영합니다.
            self.getAndShowQuoteMyLikeOf(quoteID: quoteID)
            
            // 댓글 개수를 가져오고, UI에 반영합니다.
            self.getAndShowQuoteCommentCountOf(quoteID: quoteID)
            
            // 최신 댓글 2개를 가져오고, UI에 반영합니다.
            self.getAndShowCommentDataToLastOf(itemsCount: 2)
            
        }) { (error) in
            print("///// firebase error- 2341: \n", error)
        }
    }
    
    // MARK: [좋아요] 명언 좋아요 카운트 변경 function 정의
    func getAndShowQuoteLikesCountOf(quoteID:String) {
        Database.database().reference().child(Constants.firebaseQuoteLikes).child(quoteID).child(Constants.firebaseQuoteLikesCount).observeSingleEvent(of: DataEventType.value, with: {[unowned self] (snapshot) in
            
            guard let data = snapshot.value as? Int else {
                DispatchQueue.main.async {
                    self.buttonLikeCount.setTitle("0", for: UIControlState.normal)
                }
                return
            }
            print("///// data- 4736: \n", data)
            
            // UI
            DispatchQueue.main.async {
                self.buttonLikeCount.setTitle(String(data), for: UIControlState.normal)
            }
            
        }) { (error) in
            print("///// error- 4736: \n", error.localizedDescription)
        }
    }
    
    // MARK: [좋아요] 나의 좋아요 여부 체크 및 UI(좋아요 버튼 이미지) 변경 function 정의
    func getAndShowQuoteMyLikeOf(quoteID:String) {
        guard let realUid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child(Constants.firebaseQuoteLikes).child(quoteID).child(Constants.firebaseQuoteLikesData).child(realUid).observeSingleEvent(of: DataEventType.value, with: {[unowned self] (snapshot) in
            
            // 좋아요 false
            guard let data = snapshot.value as? Bool else {
                // UI
                // 좋아요를 취소하면, 데이터를 제거하므로, guard문 안에서 UI를 처리합니다.
                DispatchQueue.main.async {
                    self.buttonLike.setImage(#imageLiteral(resourceName: "icon_button_like"), for: .normal)
                }
                return
            }
            
            // 좋아요 true
            // data가 true일 때, 좋아요 버튼의 이미지를 변경합니다.
            if data {
                // UI
                DispatchQueue.main.async {
                    self.buttonLike.setImage(#imageLiteral(resourceName: "icon_button_like_black"), for: .normal)
                }
            }
            
            print("///// data- 8473: \n", data)
            
        }) { (error) in
            print("///// error- 8473: \n", error.localizedDescription)
        }
    }

    // MARK: [댓글] 명언 댓글 개수 확인 & UI 적용
    func getAndShowQuoteCommentCountOf(quoteID:String) {
        Database.database().reference().child(Constants.firebaseQuoteComments).child(quoteID).child(Constants.firebaseQuoteCommentsCount).observeSingleEvent(of: DataEventType.value, with: {[unowned self] (snapshot) in
            
            // 댓글이 1개도 없을 때
            guard let data = snapshot.value as? Int else {
                // UI
                DispatchQueue.main.async {
                    self.buttonCommentsCount.setTitle("0", for: UIControlState.normal)
                }
                return
            }
            print("///// data- 6234: \n", data)
            
            // UI
            DispatchQueue.main.async {
                self.buttonCommentsCount.setTitle(String(data), for: UIControlState.normal)
            }
            
        }) { (error) in
            print("///// error- 6234: \n", error.localizedDescription)
        }
    }
    
    // MARK: [댓글] 최신 댓글 n개 데이터 가져오고, UI 새로고침
    func getAndShowCommentDataToLastOf(itemsCount: UInt) {
        guard let realCurrentQuoteID = self.currentQuoteID else { return }
        Database.database().reference().child(Constants.firebaseQuoteComments).child(realCurrentQuoteID).child(Constants.firebaseQuoteCommentsPosts).queryLimited(toLast: itemsCount).observeSingleEvent(of: DataEventType.value, with: {[unowned self] (snapshot) in
            
            self.commentsList = [] // 댓글 전역 변수 데이터 초기화
            
            if let realCommentsList = snapshot.value as? [String:Any] {
                // snapshot.value는 시간순으로 데이터가 오는데, guard-let을 통과하면서 정렬이 깨집니다.
                // 따라서 sorted()를 이용해, 시간순으로 정렬합니다. - Firebase의 AutoID key 값은 자동으로 시간순 정렬입니다.
                let sortedRealCommentsList = realCommentsList.sorted(by: {$0.key < $1.key} )
                
                // 전역 변수에 댓글 데이터를 저장하기
                for item in sortedRealCommentsList {
                    let oneCommentData = QuoteComment(dicData: item.value as! [String : Any])
                    self.commentsList.append(oneCommentData)
                    print("///// item(QuoteComment)- 9843: \n", oneCommentData)
                }
                print("///// self.commentsList- 9843: \n", self.commentsList)
            }
            
            // UI
            DispatchQueue.main.async {
                self.mainTableView.reloadSections(IndexSet(integersIn: 0...0), with: .automatic) // 댓글 Cell만 리로드
            }
            
        }) { (error) in
            print("///// error- 9843: \n", error)
        }
        
    }
    
    // MARK: [좋아요] 명언 좋아요 버튼 액션
    @IBAction func buttonLikeAction(_ sender: UIButton) {
        guard let realTodayQuoteID = self.currentQuoteID else { return }
        sender.isEnabled = false // 좋아요 버튼 연타 방지 예외처리
        
        // 오늘의 명언에 대해 최초로 좋아요를 눌렀을 케이스 예외처리입니다.
        Database.database().reference().child(Constants.firebaseQuoteLikes).child(realTodayQuoteID).observeSingleEvent(of: DataEventType.value, with: {[unowned self] (snapshot) in
            
            // 오늘의 명언에 대해 좋아요 데이터가 있는지 조회합니다.
            if snapshot.exists() { // snapshot이 있을 경우, 바로 좋아요 기능 작동.
                self.postShowLikeQuoteDB()
            }else {
                let dicInitialLikeData:[String:Any] = [Constants.firebaseQuoteLikesCount:0] // snapshot이 없을 경우, 좋아요 카운트 데이터 생성.
                Database.database().reference().child(Constants.firebaseQuoteLikes).child(realTodayQuoteID).setValue(dicInitialLikeData) // realTodayQuoteID의 노드 생성.
                self.postShowLikeQuoteDB() // 좋아요 기능 작동.
            }
            
        }) { (error) in
            print("///// error- 3130: \n", error.localizedDescription)
        }

    }
    
    // 좋아요 추가/취소 구현 부분입니다.
    // realTodayQuoteID 노드가 있다는 전제로 좋아요 기능이 작동됩니다.
    func postShowLikeQuoteDB() {
        guard let realUid = Auth.auth().currentUser?.uid else { return }
        guard let realTodayQuoteID = self.currentQuoteID else { return }
        Database.database().reference().child(Constants.firebaseQuoteLikes).child(realTodayQuoteID).runTransactionBlock({[unowned self] (currentData) -> TransactionResult in
            print("///// try runTransactionBlock- 6839")
            
            if var post = currentData.value as? [String : AnyObject] {
                var likes = post[Constants.firebaseQuoteLikesData] as? [String : Bool] ?? [:]
                var likeCount = post[Constants.firebaseQuoteLikesCount] as? Int ?? 0
                
                if let _ = likes[realUid] {
                    // 좋아요 취소
                    likeCount -= 1
                    likes.removeValue(forKey: realUid)
                    DispatchQueue.main.async {
                        self.buttonLike.setImage(#imageLiteral(resourceName: "icon_button_like"), for: .normal) // 좋아요 버튼 이미지 업데이트
                        self.buttonLikeCount.setTitle(String(likeCount), for: .normal) // 좋아요 카운트 버튼 타이틀 업데이트
                        self.buttonLike.isEnabled = true // 좋아요 버튼 연타 방지 예외처리
                    }
                } else {
                    // 좋아요 추가
                    likeCount += 1
                    likes[realUid] = true
                    DispatchQueue.main.async {
                        self.buttonLike.setImage(#imageLiteral(resourceName: "icon_button_like_black"), for: .normal)
                        self.buttonLikeCount.setTitle(String(likeCount), for: .normal)
                        self.buttonLike.isEnabled = true // 좋아요 버튼 연타 방지 예외처리
                    }
                }
                post[Constants.firebaseQuoteLikesData] = likes as AnyObject?
                post[Constants.firebaseQuoteLikesCount] = likeCount as AnyObject?
                
                currentData.value = post
                return TransactionResult.success(withValue: currentData)
            }
            
            return TransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                print("///// error 4632: \n", error.localizedDescription)
            }
        }
    }
    
    // MARK: [댓글] 명언 댓글 버튼 액션
    @IBAction func buttonCommentAction(_ sender: UIButton) {
        self.moveQuoteCommentViewController()
    }
    
    // MARK: [댓글] 명언 댓글 개수 버튼 액션
    @IBAction func buttonCommentCountAction(_ sender: UIButton) {
        self.moveQuoteCommentViewController()
    }
    
    // MARK: [댓글] 명언 댓글 뷰 이동 Function ( 명언 댓글 버튼이나 댓글 2개 나오는 테이블 뷰 셀, 댓글 더보기 버튼에서 사용 )
    func moveQuoteCommentViewController() {
        // UserDefaults에 사용자 닉네임이 없으면, 닉네임을 받습니다.
        if UserDefaults.standard.string(forKey: Constants.userDefaultsUserNickname) == nil {
            
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
                
                if textFieldNickname.text == "" {
                    Toast.init(text: "닉네임을 입력해주세요.").show()
                    return
                }
                
                // UserDefaults 에서 uid 호출 & 사용자가 텍스트필드에 입력한 텍스트 호출
                guard let uid = UserDefaults.standard.string(forKey: Constants.userDefaultsUserUid) else { return }
                guard let userNickname = alertSetUserNickname!.textFields?[0].text else { return }
                
                let dicUserData:[String:Any] = [Constants.firebaseUserUid:uid, Constants.firebaseUserNickname:userNickname]
                
                // Firebase DB & UserDefaults에 저장
                Database.database().reference().child(Constants.firebaseUsersRoot).child(uid).setValue(dicUserData)
                UserDefaults.standard.set(userNickname, forKey: Constants.userDefaultsUserNickname)
                
                // 명언 댓글 뷰로 이동
                guard let realQuoteText = self.labelQuoteText.text else { return }
                guard let realQuoteAuthor = self.labelQuoteAuthor.text else { return }
                let nextVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.quoteCommentViewController) as! QuoteCommentViewController
                nextVC.QuoteText = realQuoteText
                nextVC.QuoteAuthor = realQuoteAuthor
                self.navigationController?.pushViewController(nextVC, animated: true)
                
            }))
            
            self.present(alertSetUserNickname, animated: true, completion: nil)
        }
        
        guard let realQuoteText = self.labelQuoteText.text else { return }
        guard let realQuoteAuthor = self.labelQuoteAuthor.text else { return }
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.quoteCommentViewController) as! QuoteCommentViewController
        nextVC.QuoteText = realQuoteText
        nextVC.QuoteAuthor = realQuoteAuthor
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    // MARK: [공유] 명언 공유 버튼 액션 정의
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
            return self.commentsList.count + 1 // 명언 댓글 리스트
        case enumMainTableViewSection.save.rawValue:
            return 2 // 사진으로 저장, 배경화면으로 저장
        case enumMainTableViewSection.archive.rawValue:
            return 2 // 나의 좋아요 명언, 나의 댓글 명언
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
                if self.commentsList.count == 0 { // 댓글 개수가 0이면, '댓글 더 보기' 버튼이 보이도록 합니다.
                    let moreCommentsButtonCell = tableView.dequeueReusableCell(withIdentifier: "moreCommentsButtonCell", for: indexPath)
                    return moreCommentsButtonCell
                }else {
                    let quoteCommentCell = tableView.dequeueReusableCell(withIdentifier: "quoteCommentCell", for: indexPath) as! MainQuoteCommentCell
                    quoteCommentCell.labelNickName.text = self.commentsList[indexPath.row].userNickname
                    quoteCommentCell.labelCommentText.text = self.commentsList[indexPath.row].commentText
                    return quoteCommentCell
                }
            case 1: //명언 댓글 두번째
                if self.commentsList.count == 1 { // 댓글 개수가 1이면, '댓글 더 보기' 버튼이 보이도록 합니다.
                    let moreCommentsButtonCell = tableView.dequeueReusableCell(withIdentifier: "moreCommentsButtonCell", for: indexPath)
                    return moreCommentsButtonCell
                }else {
                    let quoteCommentCell = tableView.dequeueReusableCell(withIdentifier: "quoteCommentCell", for: indexPath) as! MainQuoteCommentCell
                    quoteCommentCell.labelNickName.text = self.commentsList[indexPath.row].userNickname
                    quoteCommentCell.labelCommentText.text = self.commentsList[indexPath.row].commentText
                    return quoteCommentCell
                }
            default: // 댓글 더보기 버튼
                return tableView.dequeueReusableCell(withIdentifier: "moreCommentsButtonCell", for: indexPath)
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
        
        switch indexPath.section {
        case enumMainTableViewSection.quoteComment.rawValue:
            switch indexPath.row{
            case 0: //명언 댓글 첫번째
                self.moveQuoteCommentViewController()
            case 1: //명언 댓글 두번째
                self.moveQuoteCommentViewController()
            case 2: // 댓글 더보기 버튼
                self.moveQuoteCommentViewController()
            default:
                self.moveQuoteCommentViewController()
            }
        default:
            Toast.init(text: "준비중입니다.").show()
        }
    }
}
