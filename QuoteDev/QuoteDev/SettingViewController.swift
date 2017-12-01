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
import Firebase
import UserNotifications

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

        // UI
        // DatePicker를 사용자가 설정해 놓은 알림 시간으로 설정하거나 기본 세팅으로 설정합니다.
        if UserDefaults.standard.value(forKey: Constants.settingAlarmTimeDateFormat) != nil {
            self.datePickerSetAlarmTime.date = UserDefaults.standard.value(forKey: Constants.settingAlarmTimeDateFormat) as! Date
        }else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            self.datePickerSetAlarmTime.date = dateFormatter.date(from: "09:00")!
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /*******************************************/
    //MARK:-         Functions                 //
    /*******************************************/
    
    //MARK: [이메일] 앱 문의 email 보내기 function 정의
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
    
    // MARK: [이메일] 메일 보내는 뷰컨트롤러 속성 세팅
    func configuredMailComposeViewController(emailAddress:String, systemVersion:String, appVersion:String) -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // 메일 보내기 Finish 이후의 액션 정의를 위한 Delegate 초기화.
        
        mailComposerVC.setToRecipients([emailAddress]) // 받는 사람 설정
        mailComposerVC.setSubject("[QuoteDev] Letters from users") // 메일 제목 설정
        mailComposerVC.setMessageBody("* iOS Version: \(systemVersion) / App Version: \(appVersion)\n** Thank you. What can I help you. :D", isHTML: false) // 메일 내용 설정
        
        return mailComposerVC
    }

    
    // MARK: [알림] 시간 DatePicker 완료 버튼 액션 정의
    @IBAction func buttonCompleteAlarmTimeSetting(_ sender: UIButton) {
        let formatter = DateFormatter()
        formatter.timeStyle = .short // "3:00 AM"
        print("///// buttonCompleteAlarmTimeSetting: ", formatter.string(from: self.datePickerSetAlarmTime.date))
        
        let strUserAlarmTime = formatter.string(from: self.datePickerSetAlarmTime.date)
        
        // 알림 설정
        self.setDailyAlarmNotification()
        
        // 사용자가 세팅한 알림 시간을 UserDefaults에 저장
        UserDefaults.standard.set(strUserAlarmTime, forKey: Constants.settingAlarmTime) // string으로 저장 ( Label 표시용 )
        UserDefaults.standard.set(self.datePickerSetAlarmTime.date, forKey: Constants.settingAlarmTimeDateFormat) // Date Format으로 저장
        
        // UI
        // 사용자가 세팅한 시간으로 알림 시간 cell의 UI에 표현합니다.
        self.mainTableView.reloadRows(at: [[enumSettingSection.quoteOptions.rawValue,1]], with: UITableViewRowAnimation.automatic)
        self.motherViewAlarmTimePicker.isHidden = true
        
        Toast.init(text: "Complete notification settings").show()
    }
    
    // 알림 설정
    func setDailyAlarmNotification() {
        // [MEMO] Notification 등록 방법 ( feat. 'UserNotifications' framework )
        // http://horajjan.blog.me/220923713073
        // 01. UNMutableNotificationContent: 알림에 필요한 기본 콘텐츠 설정. ( 타이틀, 메시지, 배지, 사운드 등 )
        // 02. UNTimeIntervalNotificationTrigger: 알림 발송 조건 설정. ( 알림 시간, 반복 여부 등 )
        // 03. UNNotificationRequest: 알림 요청 객체 생성.
        // 04. UNUserNotificationCenter: 스케줄러, add(_:)를 통해 알림 요청 객체 추가로 알림 등록 과정 완료.
        
        print("///// date.timeIntervalSinceNow- 7392: \n", datePickerSetAlarmTime.date.timeIntervalSinceNow)
        print("///// calendar.timeZone- 7392: \n", datePickerSetAlarmTime.calendar.timeZone)
        
        // 사용자로부터 알림 시간 추출
        let datePickerData = self.datePickerSetAlarmTime.date
        
        let dateFormatterHour: DateFormatter = DateFormatter()
        dateFormatterHour.dateFormat = "HH"
        let dateFormatterMinute: DateFormatter = DateFormatter()
        dateFormatterMinute.dateFormat = "mm"
        
        var notificationDateComponents = DateComponents()
        notificationDateComponents.hour = Int(dateFormatterHour.string(from: datePickerData))
        notificationDateComponents.minute = Int(dateFormatterMinute.string(from: datePickerData))
        
        // Notification 세팅 시작
        if #available(iOS 10.0, *) {
            // 01. UNMutableNotificationContent
            let notificationContent = UNMutableNotificationContent()
            notificationContent.body = "오늘의 개발자 명언이 도착했습니다."
            notificationContent.sound = UNNotificationSound.default()
            
            // 02. UNTimeIntervalNotificationTrigger
            let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: notificationDateComponents, repeats: true)
            
            // 03. UNNotificationRequest
            let request: UNNotificationRequest = UNNotificationRequest(identifier: "dailyQuoteDev", content: notificationContent, trigger: notificationTrigger)
            
            // 04. UNUserNotificationCenter
            UNUserNotificationCenter.current().add(request, withCompletionHandler: { [unowned self](_) in
                self.dismiss(animated: true, completion: nil)
                
                // 기존 알림 확인
                UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
                    print("///// notificationRequests.count- 7892: \n", notificationRequests.count)
                    print("///// notificationRequests detail- 7892: \n", notificationRequests)
                }
            })
            
        }else{
            // iOS 10.0 이전 버전은 알림 지원 X.
        }
    }
    
    // MARK: [알림] 시간 DatePicker 취소 버튼 액션 정의
    @IBAction func buttonCancelAlarmSetting(_ sender: UIButton) {
        self.motherViewAlarmTimePicker.isHidden = true
    }
    
    // MARK: 기본 명언 모드 액션 정의
    func setDefaultQuoteMode() {
        let alert: UIAlertController = UIAlertController(title: nil, message: "After setting, it will be applied from next time you run the app.", preferredStyle: .actionSheet)
        
        let seriousModeButton = UIAlertAction(title: "진지 모드", style: .default, handler: {[unowned self] (action) in
            print("seriousModeButton")
            // 호스트 앱에서만 사용하는 UserDefaults 저장
            UserDefaults.standard.set(Constants.settingQuoteModeSerious, forKey: Constants.settingDefaultQuoteMode)
            
            // 위젯에서 사용하는 UserDefaults 저장
            UserDefaults.init(suiteName: Constants.settingQuoteTodayExtensionAppGroup)?.set(Constants.settingQuoteModeSerious, forKey: Constants.settingDefaultQuoteMode)
            
            Toast.init(text: "진지 모드로 적용되었습니다.").show()
            self.mainTableView.reloadRows(at: [[enumSettingSection.quoteOptions.rawValue,2]], with: UITableViewRowAnimation.automatic) // 사용자가 설정한 기본 명언 모드의 텍스트가 cell의 UI에 표현됩니다.
        })
        
        let joyfulModeButton = UIAlertAction(title: "유쾌 모드", style: .default, handler: {[unowned self] (action) in
            print("joyfulModeButton")
            UserDefaults.standard.set(Constants.settingQuoteModeJoyful, forKey: Constants.settingDefaultQuoteMode)
            // 위젯에서 사용하는 UserDefaults 저장
            UserDefaults.init(suiteName: Constants.settingQuoteTodayExtensionAppGroup)?.set(Constants.settingQuoteModeJoyful, forKey: Constants.settingDefaultQuoteMode)
            
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
            let alert = UIAlertController(title: "이재성 (PM & iOS Dev)", message: "[ QuoteDev 메인 및 설정 개발 ]\n\n// 공돌이에서 기획자로\n// 기획자에서 다시 개발자로\n\n컴돌이로 졸업 후, 사업 시작.\n3 년 후, 모 카셰어링 기업에서 기획자 근무.\n1 년 후, iOS 개발자가 되겠다고 탈출.\n\nPalm OS, WindowsCE 시절부터 모바일을 좋아했고.\n애플을 좋아하며, 또 애플을 좋아한다.\n온라인에서는 \"까만거북이\"로 활동한다. (a.k.a 까북)", preferredStyle: .actionSheet)
            let blogButton = UIAlertAction(title: "Blog", style: .default, handler: {[unowned self] (action) in
                self.openSafariViewOf(url: "http://blackturtle2.net")
            })
            let githubButton = UIAlertAction(title: "GitHub", style: .default, handler: {[unowned self] (action) in
                self.openSafariViewOf(url: "https://github.com/blackturtle2")
            })
            let mailButton = UIAlertAction(title: "E-mail", style: .destructive, handler: {[unowned self] (action) in
                self.sendEmailTo(emailAddress: "blackturtle2@gmail.com")
            })
            let cancelButton = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            
            alert.addAction(blogButton)
            alert.addAction(githubButton)
            alert.addAction(mailButton)
            alert.addAction(cancelButton)
            
            self.present(alert, animated: true, completion: nil)
            
        }else if person == "hwanggisu" {
            let alert = UIAlertController(title: "황기수 (iOS Dev)", message: "[ QuoteDev 게시판 개발 ]\n\n", preferredStyle: .actionSheet)
            let githubButton = UIAlertAction(title: "GitHub", style: .default, handler: {[unowned self] (action) in
                self.openSafariViewOf(url: "https://github.com/GisuHwang")
            })
            let mailButton = UIAlertAction(title: "E-mail", style: .destructive, handler: {[unowned self] (action) in
                self.sendEmailTo(emailAddress: "kisu9838@gmail.com")
            })
            let cancelButton = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            
            alert.addAction(githubButton)
            alert.addAction(mailButton)
            alert.addAction(cancelButton)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: 인앱웹뷰(SFSafariView) 열기 function 정의
    // `SafariServices`의 import가 필요합니다.
    func openSafariViewOf(url:String) {
        guard let realURL = URL(string: url) else { return }
        
        // iOS 9부터 지원하는 `SFSafariViewController`를 이용합니다.
        let safariViewController = SFSafariViewController(url: realURL)
//        safariViewController.delegate = self // 사파리 뷰에서 `Done` 버튼을 눌렀을 때의 액션 정의를 위한 Delegate 초기화입니다.
        self.present(safariViewController, animated: true, completion: nil)
    }
    
    // MARK: 앱의 최신 버전 체크 function 정의
    // 앱의 버전을 firebase로 체크하고, toast로 표현합니다.
    // 추후 강제 업데이트를 위해, firebase에는 `forced_update_version`을 넣어두었습니다.
    func checkAppNewVersion() {
        Database.database().reference().child(Constants.firebaseAppVersion).child(Constants.firebaseAppCurrentVersion).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            // firebase에 있는 최신 버전
            guard let firebaseAppCurrentVersion = snapshot.value else { return }
            print("///// firebaseAppCurrentVersion: ", firebaseAppCurrentVersion)
            
            // 현재 사용자의 앱 버전
            guard let realUserVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] else { return }
            
            if String(describing: firebaseAppCurrentVersion) == String(describing: realUserVersion) {
                DispatchQueue.main.async {
                    Toast.init(text: "현재 최신 버전입니다. :D").show()
                }
            }else {
                DispatchQueue.main.async {
                    Toast.init(text: "현재 최신 버전이 아닙니다.\n\n앱스토어에 등록된 최신 버전은 \(firebaseAppCurrentVersion) 버전입니다.\n앱 업데이트가 필요합니다.").show()
                }
            }
        })
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
//        return 4 // 명언 좋아요 초기화 기능은 다음 구현 기능으로 연기
        return 3
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
            case 0: // MARK: QUOTE OPTIONS - 알림 설정 그리기
                let resultCell = tableView.dequeueReusableCell(withIdentifier: "SettingSwitchDailyQuoteDevOnOffCell", for: indexPath) as! SettingSwitchDailyQuoteDevOnOffCell
                resultCell.textLabel?.text = "알림 설정"
                resultCell.delegate = self
                return resultCell
            case 1: // MARK: QUOTE OPTIONS - 알림 시간 그리기
                let resultCell = tableView.dequeueReusableCell(withIdentifier: "notificationTime", for: indexPath)
                resultCell.detailTextLabel?.text = UserDefaults.standard.string(forKey: Constants.settingAlarmTime) ?? "9:00 AM"
                
                // 사용자가 이전에 설정했는지 여부에 따라 알림 시간 cell 활성화 여부 결정
                // "Constants.settingAlarmOnOff"의 UserDefaults는 AppDelegate에서 알림 on 할 때에도 함께 설정됩니다.
                if UserDefaults.standard.bool(forKey: Constants.settingAlarmOnOff) {
                    resultCell.isUserInteractionEnabled = true
                    resultCell.contentView.alpha = 1
                }else {
                    resultCell.isUserInteractionEnabled = false
                    resultCell.contentView.alpha = 0.5
                }
                
                return resultCell
            case 2: // MARK: QUOTE OPTIONS - 기본 명언 모드 그리기
                let resultCell = tableView.dequeueReusableCell(withIdentifier: "defaultQuoteMode", for: indexPath)
                
                // 이전 뷰인 메인 뷰에서 userDefaults 값이 없을 경우, 진지 모드로 기본 생성됩니다. ( 앱을 처음 실행했을 때 )
                guard let userQuoteMode = UserDefaults.standard.string(forKey: Constants.settingDefaultQuoteMode) else { return resultCell }
                if userQuoteMode == Constants.settingQuoteModeSerious {
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
            case 2: // 버전 정보
                let resultCell = tableView.dequeueReusableCell(withIdentifier: "appVersion", for: indexPath)
                let userAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String // 현재 사용자 앱 버전
                resultCell.detailTextLabel?.text = userAppVersion
                return resultCell
            case 3: // 메일 문의하기
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
            // '위젯 설정 방법'은 스토리보드에서 show segue로 연결
        // MARK: QUOTE OPTIONS
        case enumSettingSection.quoteOptions.rawValue:
            switch indexPath.row {
            case 1: // MARK: QUOTE OPTIONS - 알림 시간 터치 액션
                self.motherViewAlarmTimePicker.isHidden = false
            case 2: // MARK: QUOTE OPTIONS - 기본 명언 모드 설정
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
                self.checkAppNewVersion()
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


// MARK: extension - SettingSwitchDailyQuoteDevOnOffCellDelegate
// MARK: [알림] 알림 설정 on/off 스위치 Delegate
extension SettingViewController: SettingSwitchDailyQuoteDevOnOffCellDelegate {
    func switchDailyQuoteDevOnOff(myValue: Bool) {
        if myValue {
            print("///// SettingViewController- switchDailyQuoteDevOnOff is ON \n")
            // dailyQuoteDev 설정
            DispatchQueue.main.async {
                // switchDailyQuoteDevOnOff()를 'SettingSwitchDailyQuoteDevOnOffCell'의 Closure 안에서 부르다보니, 안정적인 구동을 위해서는 main queue에 태워야 합니다.
                self.setDailyAlarmNotification()
                UserDefaults.standard.set(true, forKey: Constants.settingAlarmOnOff)
            }
            
            // UI: 알림 시간 cell, 터치 가능 및 정상적으로 보이도록 업데이트
            DispatchQueue.main.async {
                let cell = self.mainTableView.cellForRow(at: IndexPath(row: 1, section: enumSettingSection.quoteOptions.rawValue))
                cell?.isUserInteractionEnabled = true
                cell?.contentView.alpha = 1
            }
        }else {
            print("///// SettingViewController- switchDailyQuoteDevOnOff is OFF \n")
            
            // dailyQuoteDev 제거
            if #available(iOS 10.0, *) {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyQuoteDev"])
                UserDefaults.standard.set(false, forKey: Constants.settingAlarmOnOff)
                
                // UI: 알림 시간 cell, 터치 불가 및 흐리게 보이도록 업데이트
                let cell = self.mainTableView.cellForRow(at: IndexPath(row: 1, section: enumSettingSection.quoteOptions.rawValue))
                cell?.isUserInteractionEnabled = false
                cell?.contentView.alpha = 0.5
            }
            
        }
    }
}


// MARK: Extension - MFMailComposeViewControllerDelegate
extension SettingViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
