//
//  SettingSwitchDailyQuoteDevOnOffCell.swift
//  QuoteDev
//
//  Created by leejaesung on 2017. 11. 24..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import UIKit
import Toaster

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
        if sender.isOn {
            if #available(iOS 10.0, *) {
                delegate?.switchDailyQuoteDevOnOff(myValue: true)
            }else {
                // iOS 9에서는 스위치 다시 off
                Toast.init(text: "Notifications are only available on iOS 10 or higher.").show()
                self.switchDailyQuoteDevOnOff.setOn(false, animated: true)
            }
        }else {
            delegate?.switchDailyQuoteDevOnOff(myValue: false)
        }
    }
}
