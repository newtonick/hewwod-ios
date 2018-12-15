//
//  SettingsTableViewController.swift
//  HEW WOD
//
//  Created by Klockenga,Nick on 12/11/18.
//  Copyright © 2018 Klockenga,Nick. All rights reserved.
//

import UIKit
import UserNotifications
import os.log
import Alamofire

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var notificationsSwitch: UISwitch!
    @IBOutlet weak var dailyWODReminderSwitch: UISwitch!
    @IBOutlet weak var dailyWODTimePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /****************************
         * Defaults for UI Elements *
         ****************************/

        self.notificationsSwitch.isOn = false
        self.dailyWODReminderSwitch.isOn = true
        self.dailyWODReminderSwitch.isEnabled = false
        self.dailyWODTimePicker.isEnabled = false

        /****************************
         * Values from settings     *
         ****************************/
        
        self.notificationsSwitch.isOn = UserDefaults.standard.bool(forKey: "notificationsOnSwitch")
        //self.dailyWODReminderSwitch.isOn = UserDefaults.standard.bool(forKey: "todaysWODSwitch")
        
        if UserDefaults.standard.object(forKey: "todaysNotifyTime") != nil {
            self.dailyWODTimePicker.setDate(UserDefaults.standard.object(forKey: "todaysNotifyTime") as! Date, animated: false)
        }
        
        if UserDefaults.standard.object(forKey: "todaysWODSwitch") != nil {
            self.dailyWODReminderSwitch.isOn = UserDefaults.standard.bool(forKey: "todaysWODSwitch")
        } else {
            self.dailyWODReminderSwitch.isOn = false
            UserDefaults.standard.set(false, forKey: "todaysWODSwitch")
            UserDefaults.standard.synchronize()
        }
        
        if self.notificationsSwitch.isOn {
            self.dailyWODReminderSwitch.isEnabled = true
            self.dailyWODTimePicker.isEnabled = true
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        self.saveSettings()
        self.navigationController?.dismiss(animated: false)
    }
    
    @IBAction func notificationsSwitch(_ sender: UISwitch) {
        if sender.isOn {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {
                    granted, error in
                    
                    os_log("UNUserNotificationCenter permission request: %@", log: OSLog.default, type: .debug, granted.description)
                    guard granted else {
                        // Not granted
                        
                        let alert = UIAlertController(title: "Notification Not Enabled", message: "Notifications are disbled in the setting app. Enable notifications in settings then return here to turn on the Daily WOD Reminder.", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { action in
                            switch action.style{
                            case .default:
                                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                                    return
                                }
                                
                                if UIApplication.shared.canOpenURL(settingsUrl) {
                                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                        print("Settings opened: \(success)") // Prints true
                                    })
                                }
                            case .cancel:
                                print("cancel")
                            case .destructive:
                                print("destructive")
                            }}))
                        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        
                        DispatchQueue.main.async {
                            self.notificationsSwitch?.isOn = false
                            self.dailyWODReminderSwitch.isEnabled = false
                            self.dailyWODTimePicker.isEnabled = false
                            UserDefaults.standard.set(false, forKey: "notificationsOnSwitch")
                            UserDefaults.standard.synchronize()
                        }
                    return }
                
                DispatchQueue.main.async {
                    self.dailyWODReminderSwitch.isEnabled = true
                    self.dailyWODTimePicker.isEnabled = true
                    UserDefaults.standard.set(true, forKey: "notificationsOnSwitch")
                    UserDefaults.standard.synchronize()
                    AppDelegate.getNotificationSettings()
                }
            }
        }
        else {
            //todo: let api know to not send push notifications
            self.dailyWODReminderSwitch.isEnabled = false
            self.dailyWODTimePicker.isEnabled = false
            UserDefaults.standard.set(false, forKey: "notificationsOnSwitch")
            UserDefaults.standard.synchronize()
        }
    }
    
    @IBAction func dailyWODReminderSwitch(_ sender: UISwitch) {
        if sender.isOn {
            UserDefaults.standard.set(true, forKey: "todaysWODSwitch")
        } else {
            UserDefaults.standard.set(false, forKey: "todaysWODSwitch")
        }
        UserDefaults.standard.synchronize()
    }
    
    @IBAction func notifyTimePicker(_ sender: UIDatePicker) {
        UserDefaults.standard.set(sender.date, forKey: "todaysNotifyTime")
        UserDefaults.standard.synchronize()
    }
    
    func saveSettings() {
        let calendar = Calendar.current
        
        let uuid:String = UserDefaults.standard.string(forKey: "uuid") ?? "empty"
        let token:String = UserDefaults.standard.string(forKey: "token") ?? ""
        let noti:Bool = self.notificationsSwitch?.isOn ?? false
        let wod:Bool = self.dailyWODReminderSwitch?.isOn ?? false
        let wodhour:Int = calendar.component(.hour, from: self.dailyWODTimePicker.date)
        let wodminute:Int = calendar.component(.minute, from: self.dailyWODTimePicker.date)
        
        let url = "https://hew.klck.in/api/1.0/device/settings?uuid=\(uuid)&token=\(token)&noti=\(noti)&wod=\(wod)&wodhour=\(wodhour)&wodminute=\(wodminute)"
        
        Alamofire.request(url)
    }

}
