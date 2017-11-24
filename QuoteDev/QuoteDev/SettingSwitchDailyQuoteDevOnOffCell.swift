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
        // Initialization code
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
