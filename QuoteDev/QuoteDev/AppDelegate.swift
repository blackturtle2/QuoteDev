//
//  AppDelegate.swift
//  QuoteDev
//
//  Created by leejaesung on 2017. 9. 14..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate{

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        // MARK: Notification 권한 요청
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current() // 로컬 및 원격 Notification에 대한 권한 요청
            center.delegate = self
            
            // 앱 첫 실행 후, dailyQuoteDev 초기 알림 세팅 ( 오전 9시 )
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound], completionHandler: { (flag, err) in
                print("///// UNUserNotificationCenter flag \n", flag)
                if flag && UserDefaults.standard.value(forKey: Constants.settingAlarmTimeDateFormat) == nil {
                    // 01. UNMutableNotificationContent
                    let notificationContent = UNMutableNotificationContent()
                    notificationContent.body = "오늘의 개발자 명언이 도착했습니다."
                    notificationContent.sound = UNNotificationSound.default()
                    
                    // 02. UNTimeIntervalNotificationTrigger
                    var notificationDateComponents = DateComponents()
                    notificationDateComponents.hour = 9
                    notificationDateComponents.minute = 0
                    
                    let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: notificationDateComponents, repeats: true)
                    
                    // 03. UNNotificationRequest
                    let request: UNNotificationRequest = UNNotificationRequest(identifier: "dailyQuoteDev", content: notificationContent, trigger: notificationTrigger)
                    
                    // 04. UNUserNotificationCenter
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: { (_) in
                        // 기존 알림 확인
                        UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
                            print("///// notificationRequests.count- 8923: \n", notificationRequests.count)
                            print("///// notificationRequests detail- 8923: \n", notificationRequests)
                        }
                    })
                }
            })
            application.registerForRemoteNotifications()
        } else {
            // iOS 10 미만 알림 미지원
//            application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .sound], categories: nil))
        }
        
        // MARK: Firebase Auth 진행 코드
        // UserDefaults에 저장된 uid가 없을 경우, Firebase의 Auth signInAnonymously을 진행합니다.
        // Firebase의 익명 Auth는 앱을 지웠다 설치하더라도 같은 uid를 갖습니다. ( 디바이스 의존성 )
        if UserDefaults.standard.string(forKey: Constants.userDefaultsUserUid) == nil {
            Auth.auth().signInAnonymously { (user, error) in
                print("///// signInAnonymously user: ", user ?? "no user")
                print("///// signInAnonymously user uid: ", user?.uid ?? "no user uid")
                print("///// signInAnonymously error: ", error ?? "no error")
                
                // SignIn 후, UserDefaults에 저장합니다.
                guard let uid = user?.uid else { return }
                UserDefaults.standard.set(uid, forKey: Constants.userDefaultsUserUid)
            }
        }
        print("///// userDefaults uid: ", UserDefaults.standard.string(forKey: Constants.userDefaultsUserUid) ?? "no data")
        
        // MARK: Firebase의 닉네임 데이터를 UserDefaults에 저장
        // 관리자가 닉네임을 삭제했거나 수정했을 케이스를 방지하는 목적입니다.
        guard let realUid = Auth.auth().currentUser?.uid else { return true }
        Database.database().reference().child(Constants.firebaseUsersRoot).child(realUid).child(Constants.firebaseUserNickname).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            print("///// snapshot- 8723: \n", snapshot)
            if snapshot.exists() { // 존재할 경우, UserDefaults에 저장.
                UserDefaults.standard.set(snapshot.value, forKey: Constants.userDefaultsUserNickname)
            }else { // 비어 있을 경우, nil로 저장.
                UserDefaults.standard.set(nil, forKey: Constants.userDefaultsUserNickname)
            }
            
        }) { (error) in
            print("///// error- 8723: \n", error.localizedDescription)
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // 특정 알림에 대해 사용자가 선택한 작업을 앱에 알리기 위해 호출됩니다.
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("userNotificatonCenter - didReceive")
    }
    
    // 포 그라운드 앱에 알림이 전달되면 호출됩니다
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("userNotificatonCenter - willPresent")
        center.getPendingNotificationRequests { (requests) in
            for req in requests {
                print(req.content.title+"호출됨")
                completionHandler(.alert)
            }
        }
    }
}

