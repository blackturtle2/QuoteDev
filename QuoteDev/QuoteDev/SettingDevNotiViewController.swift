//
//  SettingDevNotiViewController.swift
//  QuoteDev
//
//  Created by HwangGisu on 2017. 9. 18..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import UIKit
import UserNotifications

class SettingDevNotiViewController: UIViewController {
    
    @IBOutlet weak var notiTimePicker: UIDatePicker!
    override func viewDidLoad() {
        super.viewDidLoad()
        // 테스트를 위해 모든 로컬 노티를 지운다
// 10.0이하
//UIApplication.shared.cancelAllLocalNotifications()
        
                print("#ScheduleNOTI#",UIApplication.shared.scheduledLocalNotifications ?? "no data")
// 10.0이상
//
        if #available(iOS 10.0, *) {
//            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
                print("##UNUserNoficiationList viewdidload",notificationRequests.count)
            }
        } else {
            // Fallback on earlier versions
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func notiTimeDoneBtnTouched(_ sender: UIButton){
        print("*****************************")
        print(notiTimePicker.date.timeIntervalSinceNow)
        
        print("#3", notiTimePicker.calendar.timeZone)
        // datepicker의 시간값
        let notiDate = self.notiTimePicker.date
        
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let settingDate = dateFormatter.string(from: notiDate)
        let timeArr: [String] = settingDate.characters.split(separator: ":").map({ String($0)})
        print("#10.0 timearr// ",timeArr)
        
        var notiDateComponents = DateComponents()
        notiDateComponents.hour = Int(timeArr[0])
        notiDateComponents.minute = Int(timeArr[1])
        if #available(iOS 10.0, *) {
            
            // identifier 값으로 알람을 등록하거나 업데이트시 사용예정
            //            UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
            //                print("##UNUserNoficiationList btn",notificationRequests)
            //                var identifiers: [String] = []
            //                for notirequest in notificationRequests{
            //                    // 동일한 uuid값이 있으면 식별자를 통해 찾아서 찾은 노티를지워준다.
            //                    if notirequest.identifier == "uuid" {
            //                        identifiers.append(notirequest.identifier)
            //                    }
            //                }
            //                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
            //            }
            
            let notiContent = UNMutableNotificationContent()
            notiContent.title = "10.0이상 noti"
            notiContent.body = "노티테스트"
            notiContent.sound = UNNotificationSound.default()
            NSString.localizedUserNotificationString(forKey: "", arguments: nil)
//            // datepicker의 시간값
//            let notiDate = self.notiTimePicker.date
//            
//            let dateFormatter: DateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "HH:mm"
//            let settingDate = dateFormatter.string(from: notiDate)
//            let timeArr: [String] = settingDate.characters.split(separator: ":").map({ String($0)})
//            print("#10.0 timearr// ",timeArr)
//            
//            var notiDateComponents = DateComponents()
//            notiDateComponents.hour = Int(timeArr[0])
//            notiDateComponents.minute = Int(timeArr[1])
//            
            
            // 일정을 반복하기위한 UNCalendarNotificationTrigger 인스턴스생성
            let notiTriger = UNCalendarNotificationTrigger(dateMatching: notiDateComponents, repeats: true)
            let request: UNNotificationRequest = UNNotificationRequest(identifier: "uuid1", content: notiContent, trigger: notiTriger)
            
            // UNUserNotificationCenter에 노티를 추가
            UNUserNotificationCenter.current().add(request, withCompletionHandler: { [unowned self](_) in
                // 추가하면서 핸들링 할부분 구현 부분
                print("10.0 noti 등록후 호출")
                UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
                    print("##UNUserNoficiationList add",notificationRequests.count)
                }
                self.dismiss(animated: true, completion: nil)
            })
            
        }else{
            // 10.0 이전 버전 코드
            // 로컬스케쥴 노티정보가 비어있으면 그대로 스케쥴을 등록, 그렇지않으면 기존 스케쥴을 취소하고 새롭게 등록 0919
            //  UILocalNotification은 해당 노티가 업데이트되지않느다. 따라서 userInfo의 고유키값을 가지고 기존 노티를 지우고 새로 등록해야한다.
            guard let notiSchedules = UIApplication.shared.scheduledLocalNotifications else{ return }
            print("#4",notiSchedules.isEmpty)
            if !notiSchedules.isEmpty {
                //UIApplication.shared.cancelLocalNotification(notiSchedules.first!)
                for notiSchedule in notiSchedules {
                    // notiSchedule의 userInfo 딕셔너리 변수의 키값과 벨류가 일치할때 기존 벨류의 로컬노티를 취소하고 다시 등록
                    if notiSchedule.value(forKey: "firebase_id") as? String ?? "" == "uuid" {
                        
                        UIApplication.shared.cancelLocalNotification(notiSchedule)
                    }
                }
            }
            
            let calendar = Calendar(identifier: .gregorian)
            
            let notiAlarmDate = calendar.date(bySettingHour: notiDateComponents.hour ?? 09, minute: notiDateComponents.minute ?? 00, second: 00, of: Date(), matchingPolicy: .strict, repeatedTimePolicy: .first, direction: .forward)//calendar.date(bySettingHour: 10, minute: 43, second: 00, of: self.notiTimePicker.date)//calendar.date(from: dateCompo)
            // App 인스턴스생성
            
            let app = UIApplication.shared
            // Notification 셋팅 인스턴스 생성하여 설정정보 할당
            let notificationSetting = UIUserNotificationSettings(types: UIUserNotificationType([.alert,.sound]), categories: nil)
            // app에 설정정보가 담겨있는 notificationSetting을 파라미터로 할당
            app.registerUserNotificationSettings(notificationSetting)
            
            
            
            // 로컬 Notification 인스턴스 생성
            
            let notifyAlarm = UILocalNotification()
            // 알람이 울리는 시간
            // fireDate자체가 Date형식이고 인스턴스에 필요정보 할당후  호출해보면 next fireDate부분이 바뀌지않아서 실직적으로 일자가 다음날짜로 바뀌는지 현재는 알수없습니다. 조금더 확인 필요 한부분 입니다.
            notifyAlarm.fireDate = notiAlarmDate//self.notiTimePicker.date
            // 반복 일정( 매일)
            notifyAlarm.repeatInterval = .day
            notifyAlarm.alertTitle = "Noti 2017 0923 10:00"
            notifyAlarm.alertBody = "Notitest"
            //notifyAlarm.timeZone = notiTimePicker.timeZone
            // value값은 UserDefaults에서 값을 가져와서 할당해줄예정
            // UILocalNofication의 userInfo 변수자체가 옵셔널이다. 해당값에 값을 할당하기위한 변수를 선언하여 할당
            let identyUserinfo: [String: String] = ["uuid":"firebase_id"]
            // 할당된 변수 정보를 할당
            notifyAlarm.userInfo = identyUserinfo
            
            print(notifyAlarm)
            print("#ScheduleNOTI before#",UIApplication.shared.scheduledLocalNotifications ?? "no data")
            // 로컬 정보를 앱의 스케쥴노티에 등록
            app.scheduleLocalNotification(notifyAlarm)
            print("#ScheduleNOTI after#",UIApplication.shared.scheduledLocalNotifications ?? "no data")
            self.dismiss(animated: true, completion: nil)
            
            
        }
    }
    
    
    func setBadgeNumbers() {
        /*
         let scheduledNotifications: [UILocalNotification]? = UIApplication.shared.scheduledLocalNotifications // all scheduled notifications
         guard scheduledNotifications != nil else {return} // nothing to remove, so return
         
         let todoItems: [set] = self.allItems()
         
         // we can't modify scheduled notifications, so we'll loop through the scheduled notifications and
         // unschedule/reschedule items which need to be updated.
         var notifications: [UILocalNotification] = []
         
         for notification in scheduledNotifications! {
         print(UIApplication.shared.scheduledLocalNotifications!.count)
         let overdueItems = todoItems.filter({ (todoItem) -> Bool in // array of to-do items in which item deadline is on or before notification fire date
         return (todoItem.deadline.compare(notification.fireDate!) != .orderedDescending)
         })
         
         // set new badge number
         notification.applicationIconBadgeNumber = overdueItems.count
         notifications.append(notification)
         }
         
         // don't modify a collection while you're iterating through it
         UIApplication.shared.cancelAllLocalNotifications() // cancel all notifications
         
         for note in notifications {
         UIApplication.shared.scheduleLocalNotification(note) // reschedule the new versions
         }
         */
    }
    
    
    
}
