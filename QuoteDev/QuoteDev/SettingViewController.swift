//
//  SettingViewController.swift
//  QuoteDev
//
//  Created by leejaesung on 2017. 9. 26..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import UIKit
import MessageUI

class SettingViewController: UIViewController {
    
    @IBOutlet var mainTableView : UITableView!

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
            return 3 //개발자 소개, 개발자 문의, 앱 버전
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
        case enumSettingSection.howTo.rawValue:
            switch indexPath.row{
            case 0: //위젯 설정 방법
                return tableView.dequeueReusableCell(withIdentifier: "howToWidgetSetting", for: indexPath)
            default:
                return basicCell
            }
        case enumSettingSection.quoteOptions.rawValue:
            switch indexPath.row{
            case 0: //알림 on/off
                let resultCell = tableView.dequeueReusableCell(withIdentifier: "notificationSetting", for: indexPath)
                resultCell.textLabel?.text = "알림 설정"
                return resultCell
            case 1: //알림 시간
                return tableView.dequeueReusableCell(withIdentifier: "notificationTime", for: indexPath)
            case 2: //기본 명언 모드
                return tableView.dequeueReusableCell(withIdentifier: "defaultQuoteMode", for: indexPath)
            default:
                return basicCell
            }
        case enumSettingSection.about.rawValue:
            switch indexPath.row{
            case 0: //개발자 소개
                return tableView.dequeueReusableCell(withIdentifier: "aboutDeveloper", for: indexPath)
            case 1: //개발자 문의
                return tableView.dequeueReusableCell(withIdentifier: "askToDeveloper", for: indexPath)
            case 2: //앱 버전
                return tableView.dequeueReusableCell(withIdentifier: "appVersion", for: indexPath)
            default:
                return basicCell
            }
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
        case enumSettingSection.about.rawValue:
            switch indexPath.row{
            case 0: //개발자 소개
                return
            case 1: //개발자 문의
                // 개발자에게 메일을 보냅니다.
                self.sendEmailTo(emailAddress: "blackturtle2@gmail.com")
            case 2: //앱 버전
                return
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
