//
//  SettingViewController.swift
//  QuoteDev
//
//  Created by leejaesung on 2017. 9. 26..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import UIKit
import MessageUI
import Toaster
import SafariServices

class SettingViewController: UIViewController {
    
    @IBOutlet var mainTableView : UITableView!
    
    // 알림 시간 cell 선택으로 나오는 UI 선언
    @IBOutlet weak var motherViewAlarmTimePicker: UIView!
    @IBOutlet weak var datePickerSetAlarmTime: UIDatePicker!

    /*******************************************/
    //MARK:-        LifeCycle                  //
    /*******************************************/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainTableView.delegate = self
        mainTableView.dataSource = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /*******************************************/
    //MARK:-         Functions                 //
    /*******************************************/
    
    //MARK: 개발자 문의 email 보내기 function 정의
    // [주의] `MessageUI` import 필요
    func sendEmailTo(emailAddress email:String) {
        let userSystemVersion = UIDevice.current.systemVersion // 현재 사용자 iOS 버전
        let userAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String // 현재 사용자 앱 버전
        
        // 메일 쓰는 뷰컨트롤러 선언
        let mailComposeViewController = configuredMailComposeViewController(emailAddress: email, systemVersion: userSystemVersion, appVersion: userAppVersion!)
        
        //사용자의 아이폰에 메일 주소가 세팅되어 있을 경우에만 mailComposeViewController()를 태웁니다.
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } // else일 경우, iOS 에서 자체적으로 메일 주소를 세팅하라는 메시지를 띄웁니다.
    }
    
    // MARK: 메일 보내는 뷰컨트롤러 속성 세팅
    func configuredMailComposeViewController(emailAddress:String, systemVersion:String, appVersion:String) -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // 메일 보내기 Finish 이후의 액션 정의를 위한 Delegate 초기화.
        
        mailComposerVC.setToRecipients([emailAddress]) // 받는 사람 설정
        mailComposerVC.setSubject("[QuoteDev] 사용자로부터 도착한 편지") // 메일 제목 설정
        mailComposerVC.setMessageBody("* iOS Version: \(systemVersion) / App Version: \(appVersion)\n** 고맙습니다. 무엇이 궁금하신가요? :D", isHTML: false) // 메일 내용 설정
        
        return mailComposerVC
    }
    
    // MARK: 알림 시간 DatePicker의 완료 버튼 액션 정의
    @IBAction func buttonCompleteAlarmTimeSetting(_ sender: UIButton) {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        print("///// buttonCompleteAlarmTimeSetting: ", formatter.string(from: self.datePickerSetAlarmTime.date))
        // "3:00 AM"과 같은 포맷입니다.
        
        let userAlarmTime = formatter.string(from: self.datePickerSetAlarmTime.date)
        
        // 사용자가 세팅한 알람 시간은 UserDefaults에 저장합니다.
        UserDefaults.standard.set(userAlarmTime, forKey: Constants.settingAlarmTime)
        self.mainTableView.reloadRows(at: [[enumSettingSection.quoteOptions.rawValue,1]], with: UITableViewRowAnimation.automatic) // 사용자가 세팅한 시간으로 알림 시간 cell의 UI에 표현합니다.
        
        self.motherViewAlarmTimePicker.isHidden = true
    }
    
    // MARK: 알림 시간 DatePicker의 취소 버튼 액션 정의
    @IBAction func buttonCancelAlarmSetting(_ sender: UIButton) {
        self.motherViewAlarmTimePicker.isHidden = true
    }
    
    // MARK: 기본 명언 모드 액션 정의
    func setDefaultQuoteMode() {
        let alert: UIAlertController = UIAlertController(title: nil, message: "설정 후, 다음 앱 실행 때부터 적용됩니다.", preferredStyle: .actionSheet)
        
        let seriousModeButton = UIAlertAction(title: "진지 모드", style: .default, handler: {[unowned self] (action) in
            print("seriousModeButton")
            UserDefaults.standard.set(Constants.settingQuoteModeSerous, forKey: Constants.settingDefaultQuoteMode)
            Toast.init(text: "진지 모드로 적용되었습니다.").show()
            self.mainTableView.reloadRows(at: [[enumSettingSection.quoteOptions.rawValue,2]], with: UITableViewRowAnimation.automatic) // 사용자가 설정한 기본 명언 모드의 텍스트가 cell의 UI에 표현됩니다.
        })
        
        let joyfulModeButton = UIAlertAction(title: "유쾌 모드", style: .default, handler: {[unowned self] (action) in
            print("joyfulModeButton")
            UserDefaults.standard.set(Constants.settingQuoteModeJoyful, forKey: Constants.settingDefaultQuoteMode)
            Toast.init(text: "유쾌 모드로 적용되었습니다.").show()
            self.mainTableView.reloadRows(at: [[enumSettingSection.quoteOptions.rawValue,2]], with: UITableViewRowAnimation.automatic) // 사용자가 설정한 기본 명언 모드의 텍스트가 cell의 UI에 표현됩니다.
        })
        let cancelButton = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(seriousModeButton)
        alert.addAction(joyfulModeButton)
        alert.addAction(cancelButton)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: 개발자 소개 액션 정의
    func showAboutDeveloperOf(person:String) {
        if person == "leejaesung" {
            let alert = UIAlertController(title: "이재성 (PM & iOS Dev)", message: "- QuoteDev 메인 및 설정 개발\n\n// 공돌이에서 기획자로\n// 기획자에서 다시 개발자로\n\n컴돌이로 졸업 후, 사업을 시작.\n3년 후, 모 카셰어링 회사에서 기획자로 근무.\n1년 후, iOS 개발자가 되겠다고 탈출.\n\nPalm OS, WindowsCE 시절부터 모바일을 좋아했고.\n애플을 좋아하며, 또 애플을 좋아한다.\n온라인에서는 \"까만거북이\"로 활동한다. (a.k.a 까북)", preferredStyle: .actionSheet)
            let blogButton = UIAlertAction(title: "Blog", style: .default, handler: {[unowned self] (action) in
                self.openSafariViewOf(url: "http://blackturtle2.net")
            })
            let githubButton = UIAlertAction(title: "GitHub", style: .default, handler: {[unowned self] (action) in
                self.openSafariViewOf(url: "https://github.com/blackturtle2")
            })
            let mailButton = UIAlertAction(title: "E-mail", style: .default, handler: {[unowned self] (action) in
                self.sendEmailTo(emailAddress: "blackturtle2@gmail.com")
            })
            let cancelButton = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            
            alert.addAction(blogButton)
            alert.addAction(githubButton)
            alert.addAction(mailButton)
            alert.addAction(cancelButton)
            
            self.present(alert, animated: true, completion: nil)
            
        }else if person == "hwanggisu" {
            let alert = UIAlertController(title: "황기수 (iOS Dev)", message: "- QuoteDev 게시판 개발\n\n", preferredStyle: .actionSheet)
            let mailButton = UIAlertAction(title: "e-mail", style: .default, handler: {[unowned self] (action) in
                self.sendEmailTo(emailAddress: "kisu9838@gmail.com")
            })
            let cancelButton = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            
            alert.addAction(mailButton)
            alert.addAction(cancelButton)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: 인앱웹뷰 열기 function 정의
    // `SafariServices`의 import가 필요합니다.
    func openSafariViewOf(url:String) {
        guard let realURL = URL(string: url) else { return }
        
        // iOS 9부터 지원하는 `SFSafariViewController`를 이용합니다.
        let safariViewController = SFSafariViewController(url: realURL)
//        safariViewController.delegate = self // 사파리 뷰에서 `Done` 버튼을 눌렀을 때의 액션 정의를 위한 Delegate 초기화입니다.
        self.present(safariViewController, animated: true, completion: nil)
    }
}

/*******************************************/
//MARK:-         extenstion                //
/*******************************************/
extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    enum enumSettingSection : Int {
        case howTo = 0
        case quoteOptions = 1
        case about = 2
        case setting = 3
    }
    
    // MARK: tableView - section의 개수
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    // MARK: tableView - section의 타이틀
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case enumSettingSection.howTo.rawValue:
            return "HOW TO"
        case enumSettingSection.quoteOptions.rawValue:
            return "QUOTE OPTIONS"
        case enumSettingSection.about.rawValue:
            return "ABOUT"
        case enumSettingSection.setting.rawValue:
            return "SETTING"
        default:
            return ""
        }
    }
    
    // MARK: tableView - section의 row 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case enumSettingSection.howTo.rawValue:
            return 1 //위젯 설정 방법
        case enumSettingSection.quoteOptions.rawValue:
            return 3 //알림, 알림 시간, 기본 모드
        case enumSettingSection.about.rawValue:
            return 4 //개발자 소개(이재성), 개발자 소개(황기수), 앱 버전, 앱 문의하기
        case enumSettingSection.setting.rawValue:
            return 1 // 초기화
        default:
            return 0
        }
    }
    
    // MARK: tableView - footer의 타이틀
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case enumSettingSection.quoteOptions.rawValue:
            return "매일 하루 1개의 명언이 새로고침 되고, 설정한 기본 모드의 명언이 위젯에 표시됩니다."
        case enumSettingSection.setting.rawValue:
            return "좋아요 명언 목록이 초기화됩니다."
        default:
            return nil
        }
    }
    
    // MARK: tableView - cell 그리기
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let basicCell = UITableViewCell()
        
        switch indexPath.section {
        // MARK: HOW TO
        case enumSettingSection.howTo.rawValue:
            switch indexPath.row{
            case 0: //위젯 설정 방법
                return tableView.dequeueReusableCell(withIdentifier: "howToWidgetSetting", for: indexPath)
            default:
                return basicCell
            }
        // MARK: QUOTE OPTIONS
        case enumSettingSection.quoteOptions.rawValue:
            switch indexPath.row{
            case 0: //알림 on/off
                let resultCell = tableView.dequeueReusableCell(withIdentifier: "notificationSetting", for: indexPath)
                resultCell.textLabel?.text = "알림 설정"
                return resultCell
            case 1: //알림 시간
                let resultCell = tableView.dequeueReusableCell(withIdentifier: "notificationTime", for: indexPath)
                resultCell.detailTextLabel?.text = UserDefaults.standard.string(forKey: Constants.settingAlarmTime) ?? "9:00 AM"
                return resultCell
            case 2: //기본 명언 모드
                let resultCell = tableView.dequeueReusableCell(withIdentifier: "defaultQuoteMode", for: indexPath)
                
                // 이전 뷰인 메인 뷰에서 userDefaults 값이 없을 경우, 진지 모드로 기본 생성됩니다. ( 앱을 처음 실행했을 때 )
                guard let userQuoteMode = UserDefaults.standard.string(forKey: Constants.settingDefaultQuoteMode) else { return resultCell }
                if userQuoteMode == Constants.settingQuoteModeSerous {
                    resultCell.detailTextLabel?.text = "진지 모드"
                }else if userQuoteMode == Constants.settingQuoteModeJoyful {
                    resultCell.detailTextLabel?.text = "유쾌 모드"
                }
                return resultCell
            default:
                return basicCell
            }
        // MARK: ABOUT
        case enumSettingSection.about.rawValue:
            switch indexPath.row{
            case 0: // 개발자 소개 (이재성)
                let resultCell = tableView.dequeueReusableCell(withIdentifier: "aboutDeveloper", for: indexPath)
                resultCell.detailTextLabel?.text = "Lee Jaesung"
                return resultCell
            case 1: // 개발자 소개 (황기수)
                let resultCell = tableView.dequeueReusableCell(withIdentifier: "aboutDeveloper", for: indexPath)
                resultCell.detailTextLabel?.text = "Hwang Gisu"
                return resultCell
            case 2: // 앱 버전
                return tableView.dequeueReusableCell(withIdentifier: "appVersion", for: indexPath)
            case 3: // 앱 문의하기
                return tableView.dequeueReusableCell(withIdentifier: "askToDeveloper", for: indexPath)
            default:
                return basicCell
            }
        // MARK: SETTING
        case enumSettingSection.setting.rawValue:
            switch indexPath.row{
            case 0: //초기화
                return tableView.dequeueReusableCell(withIdentifier: "reset", for: indexPath)
            default:
                return basicCell
            }
        default:
            return basicCell
        }
        
    }
    
    // MARK: tableView - cell 선택하기
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // 터치한 표시를 제거하는 액션
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        // MARK: HOW TO
            // 위젯 설정 방법은 스토리보드에서 show segue로 연결하였습니다.
        // MARK: QUOTE OPTIONS
        case enumSettingSection.quoteOptions.rawValue:
            switch indexPath.row {
            case 1: // 알림 시간 설정
                self.motherViewAlarmTimePicker.isHidden = false
            case 2: // 기본 명언 모드 설정
                self.setDefaultQuoteMode()
            default:
                return
            }
        // MARK: ABOUT
        case enumSettingSection.about.rawValue:
            switch indexPath.row{
            case 0: // 개발자 소개 (이재성)
                self.showAboutDeveloperOf(person: "leejaesung")
            case 1: // 개발자 소개 (황기수)
                self.showAboutDeveloperOf(person: "hwanggisu")
            case 2: // 앱 버전
                return
            case 3: // 앱 문의하기
                // 개발자에게 메일을 보냅니다.
                self.sendEmailTo(emailAddress: "blackturtle2@gmail.com")
            default:
                return
            }
        default:
            return
        }
        
    }
    
}

// MARK: Extension - MFMailComposeViewControllerDelegate
extension SettingViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
