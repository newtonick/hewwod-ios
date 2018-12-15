//
//  AppDelegate.swift
//  HEWAVL
//
//  Created by Klockenga,Nick on 11/30/18.
//  Copyright © 2018 Klockenga,Nick. All rights reserved.
//

import UIKit
import UserNotifications
import Alamofire
import SwiftyJSON
import os.log

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    static var backgroundFetch:Bool = false
    static var backgroundFetchComplete:Bool = false
    static var workoutTableViewController:WorkoutsTableViewController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if UserDefaults.standard.object(forKey: "uuid") == nil {
            let UUID = NSUUID().uuidString
            UserDefaults.standard.set(UUID, forKey: "uuid")
            UserDefaults.standard.synchronize()
        }
        
        AppDelegate.backgroundFetchComplete = false
        UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(exactly: 10800.00)!) //3 Hours
        
        registerForPushNotifications()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        os_log("applicationWillResignActive", log: OSLog.default, type: .debug)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        os_log("applicationDidEnterBackground", log: OSLog.default, type: .debug)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        os_log("applicationWillEnterForeground", log: OSLog.default, type: .debug)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        os_log("applicationDidBecomeActive", log: OSLog.default, type: .debug)
        if AppDelegate.workoutTableViewController != nil && AppDelegate.backgroundFetchComplete {
            AppDelegate.workoutTableViewController?.fetchWorkoutsFromArchive()
            //AppDelegate.workoutTableViewController?.tableView.reloadData()
        }
        AppDelegate.backgroundFetchComplete = false
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        os_log("applicationWillTerminate", log: OSLog.default, type: .debug)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        let noti = UserDefaults.standard.bool(forKey: "notificationsOnSwitch") ? "on" : "off"
        
        if UserDefaults.standard.string(forKey: "token") != token {
            UserDefaults.standard.set(token, forKey: "token")
            UserDefaults.standard.synchronize()
        }
        
        os_log("Device Token %@", log: OSLog.default, type: .debug, token.description)

        //push token to api
        var url = "https://hew.klck.in/api/1.0/device/add?token=\(token)&env=production&notifications=\(noti)"
        #if DEBUG
        url = "https://hew.klck.in/api/1.0/device/add?token=\(token)&env=sandbox&notifications=\(noti)"
        #endif
        Alamofire.request(url)
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    func registerForPushNotifications() {
        if #available(iOS 12.0, *) {
            os_log("UNUserNotificationCenter iOS 12", log: OSLog.default, type: .debug)
            UNUserNotificationCenter.current()
                .requestAuthorization(options: [.provisional]) { //[.alert, .sound]) {
                    granted, error in
                    
                    os_log("Permission granted: %@", log: OSLog.default, type: .debug, granted.description)
                    guard granted else { return }
                    AppDelegate.getNotificationSettings()
            }
        }
    }
    
    static func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            os_log("Notification settings: %@", log: OSLog.default, type: .debug, settings.description)
            guard settings.authorizationStatus == .authorized else { return }
        }
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        os_log("performFetchWithCompletionHandler", log: OSLog.default, type: .debug)
        AppDelegate.backgroundFetch = true
        AppDelegate.fetchWorksouts(completion: { workouts in
            AppDelegate.saveToArchive(workouts: workouts)
            AppDelegate.backgroundFetch = false
            AppDelegate.backgroundFetchComplete = true
            completionHandler(UIBackgroundFetchResult.newData)
        })
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        os_log("didReceiveRemoteNotification", log: OSLog.default, type: .debug)
        AppDelegate.fetchWorksouts(completion: { workouts in
            AppDelegate.saveToArchive(workouts: workouts)
            completionHandler(UIBackgroundFetchResult.newData)
        })
    }
    
    static func fetchWorksouts(completion: @escaping ([Workout]) -> Void ) {
        var workouts = [Workout]()
        
        var queue:DispatchQueue = DispatchQueue.main
        if AppDelegate.backgroundFetch == true {
            queue = DispatchQueue(label: "com.klockenga.hewwod.bg", qos: .background, attributes: .concurrent)
        }
        
        Alamofire.request("https://hew.klck.in/api/1.0/workouts").responseJSON(queue: queue) { response in
            os_log("Alamofire workout fetch %@", log: OSLog.default, type: .debug, response.description)
            switch response.result {
            case .success:
                let json = JSON(response.result.value!)
                
                if json["status"].exists() {
                    if json["status"] == "success" {
                        
                        for(_,subJson):(String, JSON) in json["workouts"] {
                            
                            let w:Workout = Workout(id: subJson["_id"].string!, name: subJson["name"].string!,
                                                    text: subJson["text"].string!,
                                                    date: Workout.stringDateConverter(date: subJson["date"].string!),
                                                    updated: Workout.stringDateConverter(date: subJson["updated"].string!))!
                            
                            workouts += [w]
                        }
                        completion(workouts)
                    }
                }
            case .failure(let error):
                os_log("Alamofire workouts fetch error: %@", log: OSLog.default, type: .error, error.localizedDescription)
            }
        }
    }
    
    static func getDeviceSettings() {
        let token = UserDefaults.standard.string(forKey: "token")
        Alamofire.request("https://hew.klck.in/api/1.0/device/settings?token=\(token ?? "none")").responseJSON { response in
            switch response.result {
            case .success:
                _ = JSON(response.result.value!)
                
                //AppDelegate.notificationsEnabled = json["notifications"] == "on" ? true : false
                
            case .failure(let error):
                os_log("Alamofire device settings fetch error: %@", log: OSLog.default, type: .error, error.localizedDescription)
            }
        }
    }
    
    static func saveToArchive(workouts: [Workout]) {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(workouts, toFile: Workout.ArchiveURL.path)
        
        if isSuccessfulSave {
            os_log("Workouts successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Workouts failed saved.", log: OSLog.default, type: .error)
        }
    }
    
    static func fetchFromArchive() -> [Workout] {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Workout.ArchiveURL.path) as? [Workout] ?? [Workout]()
    }

}

