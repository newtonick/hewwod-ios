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

class SettingsTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var notificationsSwitch: UISwitch!
    @IBOutlet weak var dailyWODReminderSwitch: UISwitch!
    @IBOutlet weak var dailyWODTimePicker: UIDatePicker!
    @IBOutlet weak var timezonePicker: UIPickerView!
    @IBOutlet weak var fetchWebCount: UILabel!
    @IBOutlet weak var saveSettingsCount: UILabel!
    @IBOutlet weak var addTokenCount: UILabel!
    
    var timezonePickerDataSource = ["America/New_York", "America/Chicago", "America/Denver", "America/Los_Angeles", "Pacific/Honolulu"];
    
    var curTimeZone:String = "America/New_York"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /****************************
         * Defaults for UI Elements *
         ****************************/

//        self.tableView.beginUpdates()
//        self.tableView.deleteSections(IndexSet([3]), with: .none)
//        self.tableView.endUpdates()
        
        self.notificationsSwitch.isOn = false
        self.dailyWODReminderSwitch.isOn = true
        self.dailyWODReminderSwitch.isEnabled = false
        self.dailyWODTimePicker.isEnabled = false
        self.timezonePicker.isUserInteractionEnabled = false
        self.timezonePicker.alpha = 0.6

        self.timezonePicker.dataSource = self;
        self.timezonePicker.delegate = self;

        /****************************
         * Values from settings     *
         ****************************/
        
        self.notificationsSwitch.isOn = UserDefaults.standard.bool(forKey: "notificationsOnSwitch")
        //self.dailyWODReminderSwitch.isOn = UserDefaults.standard.bool(forKey: "todaysWODSwitch")
        
        if UserDefaults.standard.object(forKey: "todaysNotifyTime") != nil {
            self.dailyWODTimePicker.setDate(UserDefaults.standard.object(forKey: "todaysNotifyTime") as! Date, animated: false)
        }
        
        if UserDefaults.standard.object(forKey: "timeZone") != nil {
            self.curTimeZone = UserDefaults.standard.object(forKey: "timeZone") as! String
        } else {
            if self.timezonePickerDataSource.firstIndex(of:Calendar.current.timeZone.identifier) != nil {
                self.curTimeZone = Calendar.current.timeZone.identifier
            }
        }
        self.timezonePicker.selectRow(self.timezonePickerDataSource.firstIndex(of: self.curTimeZone)!, inComponent: 0, animated: false)

        if UserDefaults.standard.object(forKey: "todaysWODSwitch") != nil {
            self.dailyWODReminderSwitch.isOn = UserDefaults.standard.bool(forKey: "todaysWODSwitch")
        } else {
            self.dailyWODReminderSwitch.isOn = false
            UserDefaults.standard.set(false, forKey: "todaysWODSwitch")
            UserDefaults.standard.synchronize()
        }
        
        if self.notificationsSwitch.isOn {
            self.dailyWODReminderSwitch.isEnabled = true
        }
        
        if self.dailyWODReminderSwitch.isOn {
            self.dailyWODTimePicker.isEnabled = true
            self.timezonePicker.isUserInteractionEnabled = true
            self.timezonePicker.alpha = 1
        } else {
            self.dailyWODTimePicker.isEnabled = false
            self.timezonePicker.isUserInteractionEnabled = false
            self.timezonePicker.alpha = 0.6
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.fetchWebCount.text = String(UserDefaults.standard.integer(forKey: "fetch-workouts-count"))
        self.saveSettingsCount.text = String(UserDefaults.standard.integer(forKey: "save-settings-count"))
        self.addTokenCount.text = String(UserDefaults.standard.integer(forKey: "add-token-count"))
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
                            self.dailyWODTimePicker.isEnabled = false
                            //self.timezonePicker.isUserInteractionEnabled = false
                            //self.timezonePicker.alpha = 0.6
                            UserDefaults.standard.set(false, forKey: "notificationsOnSwitch")
                            UserDefaults.standard.synchronize()
                        }
                    return }
                
                DispatchQueue.main.async {
                    self.dailyWODReminderSwitch.isEnabled = true
                    if self.dailyWODReminderSwitch.isOn {
                        self.dailyWODTimePicker.isEnabled = true
                        self.timezonePicker.isUserInteractionEnabled = true
                        self.timezonePicker.alpha = 1
                    }
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
            self.timezonePicker.isUserInteractionEnabled = false
            self.timezonePicker.alpha = 0.6
            UserDefaults.standard.set(false, forKey: "notificationsOnSwitch")
            UserDefaults.standard.synchronize()
        }
    }
    
    @IBAction func dailyWODReminderSwitch(_ sender: UISwitch) {
        if sender.isOn {
            UserDefaults.standard.set(true, forKey: "todaysWODSwitch")
            self.dailyWODTimePicker.isEnabled = true
            self.timezonePicker.isUserInteractionEnabled = true
            self.timezonePicker.alpha = 1
        } else {
            UserDefaults.standard.set(false, forKey: "todaysWODSwitch")
            self.dailyWODTimePicker.isEnabled = false
            self.timezonePicker.isUserInteractionEnabled = false
            self.timezonePicker.alpha = 0.6
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
        let timezone:String = self.curTimeZone
        
        let url = URL(string: "https://hew.klck.in/api/1.0/device/settings?uuid=\(uuid)&token=\(token)&noti=\(noti)&wod=\(wod)&wodhour=\(wodhour)&wodminute=\(wodminute)&timezone=\(timezone)")
        let task = URLSession.shared.dataTask(with: url!)
        task.resume()
        UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "save-settings-count") + 1, forKey: "save-settings-count")
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.timezonePickerDataSource.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString.init(string: self.timezonePickerDataSource[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.curTimeZone = self.timezonePickerDataSource[row]
        print(self.curTimeZone)
        UserDefaults.standard.set(self.curTimeZone, forKey: "timeZone")
        UserDefaults.standard.synchronize()
    }

}
