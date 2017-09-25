//
//  SettingViewController.swift
//  QuoteDev
//
//  Created by leejaesung on 2017. 9. 26..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import UIKit

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
    
    // section의 개수
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    // section의 타이틀
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
    
    // section의 row 개수
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
    
    // footer의 타이틀
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
    
    // cell 그리기
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
    
}
