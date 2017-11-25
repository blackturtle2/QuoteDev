//
//  SettingSwitchDailyQuoteDevOnOffCell.swift
//  QuoteDev
//
//  Created by leejaesung on 2017. 11. 24..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import UIKit
import Toaster
import UserNotifications

protocol SettingSwitchDailyQuoteDevOnOffCellDelegate {
    func switchDailyQuoteDevOnOff(myValue: Bool)
}

class SettingSwitchDailyQuoteDevOnOffCell: UITableViewCell {
    
    var delegate: SettingSwitchDailyQuoteDevOnOffCellDelegate?

    @IBOutlet weak var switchDailyQuoteDevOnOff: UISwitch!
    
    /*******************************************/
    //MARK:-        LifeCycle                  //
    /*******************************************/
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // 사용자가 이전에 설정했는지 여부에 따라 스위치 값 on/off 세팅
        // "Constants.settingAlarmOnOff"의 UserDefaults는 AppDelegate에서 알림 on 할 때에도 함께 설정됩니다.
        if UserDefaults.standard.bool(forKey: Constants.settingAlarmOnOff) {
            self.switchDailyQuoteDevOnOff.setOn(true, animated: true)
        }else {
            self.switchDailyQuoteDevOnOff.setOn(false, animated: true)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    /*******************************************/
    //MARK:-         Functions                 //
    /*******************************************/
    
    // MARK: 알림 설정 on/off 스위치 액션
    @IBAction func actionSwitchDailyQuoteDevOnOff(_ sender: UISwitch) {
        // 스위치 ON
        if sender.isOn {
            if #available(iOS 10.0, *) {
                // iOS 시스템 설정에서 '알림 허용' 여부 체크 ( UNUserNotificationCenter )
                // https://developer.apple.com/documentation/usernotifications/unusernotificationcenter/1649524-getnotificationsettings
                UNUserNotificationCenter.current().getNotificationSettings(completionHandler: {[unowned self] (setting) in
                    print("///// setting- 8203: \n", setting)
                    
                    if setting.authorizationStatus == .authorized { // 알림 허용 ON
                        // dailyQuoteDev 실행
                        self.delegate?.switchDailyQuoteDevOnOff(myValue: true)
                        
                    }else if setting.authorizationStatus == .denied { // 알림 허용 OFF
                        
                        // UI
                        DispatchQueue.main.async {
                            // 스위치를 다시 OFF로 전환
                            self.switchDailyQuoteDevOnOff.setOn(false, animated: true)
                        }
                        
                        // iOS System Settings로 이동시키는 Alert 구현
                        let alert = UIAlertController(title: "Check again", message: "Please allow notifications first in Settings.", preferredStyle: UIAlertControllerStyle.alert)
                        let goAction = UIAlertAction(title: "Settings", style: UIAlertActionStyle.destructive, handler: { (action) in
                            // iOS 시스템 설정으로 이동
                            UIApplication.shared.openURL(URL(string:UIApplicationOpenSettingsURLString)!)
                        })
                        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
                        alert.addAction(goAction)
                        alert.addAction(cancelAction)
                        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                        
                    }
                })
                
            }else {
                // iOS 9에서는 스위치 다시 off
                Toast.init(text: "Notifications are only available on iOS 10 or higher.").show()
                self.switchDailyQuoteDevOnOff.setOn(false, animated: true)
            }
        }else { // 스위치 OFF
            delegate?.switchDailyQuoteDevOnOff(myValue: false)
        }
    }
}
