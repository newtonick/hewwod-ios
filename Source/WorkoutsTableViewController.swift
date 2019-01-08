//
//  WorkoutsTableViewController.swift
//  HEWAVL
//
//  Created by Klockenga,Nick on 12/4/18.
//  Copyright © 2018 Klockenga,Nick. All rights reserved.
//

import UIKit
import os.log
import Alamofire
import SwiftyJSON

class WorkoutsTableViewController: UITableViewController {
    
    @IBOutlet weak var settingsNavButton: UIBarButtonItem!
    @IBOutlet weak var refreshNavButton: UIBarButtonItem!
    var workouts = [Workout]()
    var webWorkouts = [Workout]()
    var archiveWorkouts = [Workout]()
    var webLoadComplete:Bool = false
    var archiveLoadComplete:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //used temp to hide nav settings button
        //self.navigationItem.setRightBarButton(UIBarButtonItem.init(), animated: false)
        self.navigationItem.setLeftBarButton(UIBarButtonItem.init(), animated: false)
        
        self.settingsNavButton?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "FontAwesome5FreeSolid", size: 17)!], for: UIControl.State.normal)
        self.settingsNavButton?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "FontAwesome5FreeSolid", size: 17)!], for: UIControl.State.selected)

        // pads the top cell 8 pt off the top of the nav bar
        self.tableView.contentInset = UIEdgeInsets(top: 2,left: 0,bottom: 0,right: 0)
        
        // removes the navigator bar shadow bar
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        // created a better shadow on the navigation bar into the table view area
        self.navigationController?.navigationBar.layer.masksToBounds = false
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.35
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 2
        
        // loads the archived and pulls down the web updates
        self.loadWorkouts()
        
        AppDelegate.workoutTableViewController = self
        
        os_log("WorkoutsTableViewController viewDidLoad is Complete", log: OSLog.default, type: .debug)
    }

    // MARK: - Table view data source
    
    @IBAction func forceRefresh(_ sender: UIBarButtonItem) {
        self.refreshNavButton.isEnabled = false;
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(enableRefresh), userInfo: nil, repeats: false)
        self.tableView.setContentOffset(.zero, animated: false)
        self.fetchWorkoutsFromWeb()
    }
    
    @objc func enableRefresh() {
        self.refreshNavButton.isEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        os_log("viewWillAppear", log: OSLog.default, type: .debug)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workouts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        os_log("loading tableView Cell: %@", log: OSLog.default, type: .debug, self.workouts[indexPath.row].name)
        let cellIdentifier = "WorkoutTableViewCell"
        
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? WorkoutTableViewCell else {
            fatalError("The cell is not an instance of WorkoutTableViewCell.")
        }
        
        //set cell values
        cell.workoutName.text = self.workouts[indexPath.row].name
        cell.workoutText.text = self.workouts[indexPath.row].text
        cell.workoutDate.text = self.workouts[indexPath.row].getDateString()
        cell.workoutText.attributedText = self.workouts[indexPath.row].attributedText
        
        if cell.workoutDate.text == "Today" {
            cell.nameBar.backgroundColor = UIColor(red:0.20, green:0.20, blue:0.20, alpha:1.00)
        } else {
            cell.nameBar.backgroundColor = UIColor.darkGray
        }
        
        //setup cell shadow
        cell.layer.masksToBounds = false
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.35
        cell.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        cell.layer.shadowRadius = 2
        
        //cell.layoutSubviews()
        
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let screenWidth = UIScreen.main.bounds.width
        
        let cgsize = CGSize(width: screenWidth - 46, height: 10000)
        let rect = self.workouts[indexPath.row].attributedText.boundingRect(with: cgsize, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)

        os_log("Height tableView Cell: %@", log: OSLog.default, type: .debug, rect.height.description)
        
        return CGFloat(90 + rect.height);
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 200
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return false
    }

    func loadWorkouts() {
        self.fetchWorkoutsFromArchive()
        self.fetchWorkoutsFromWeb()
    }
    
    private func fetchWorkoutsFromWeb() {
        AppDelegate.fetchWorksouts(completion: { workouts in
            self.webWorkouts = workouts
            if self.webWorkouts.count > 0 {
                self.webLoadComplete = true
            }
            self.fetchWorkoutsComplete()
        })
    }
    
    func fetchWorkoutsFromArchive() {
        self.archiveWorkouts = AppDelegate.fetchFromArchive()
    
        if self.archiveWorkouts.count > 0 {
            self.archiveLoadComplete = true
        }
        self.fetchWorkoutsComplete()
    }
    
    private func fetchWorkoutsComplete() {
        // compare archive to web if both are complete
        if self.webLoadComplete == true && self.archiveLoadComplete == true {
            os_log("Web Load and Archive Load Complete", log: OSLog.default, type: .debug)
            // compare of both complete
            var match:Bool = false
            
            if self.webWorkouts.count != self.archiveWorkouts.count {
                os_log("Web and Archive Counts Different, Loading from Web, Reloading Table, and Saving", log: OSLog.default, type: .debug)
                self.workouts = self.webWorkouts
                AppDelegate.saveToArchive(workouts: self.workouts)
                //self.tableView.reloadSections(IndexSet([0]), with: .bottom)
                self.tableView.reloadData()
                return
            }
            
            // loop over each workout in archive and web and compare id and date
            for arcW in self.archiveWorkouts {
                for webW in self.webWorkouts {
                    if webW.id == arcW.id && webW.date == arcW.date && webW.updated == arcW.updated {
                        match = true //set match to true when match is found
                    }
                }
                if match == false {
                    // when a match can't be found, web and archive are different. Load from Web and Save.
                    os_log("Web and Archive Non Match Found, Loading from Web, Realoding Table, and Saving", log: OSLog.default, type: .debug)
                    self.workouts = self.webWorkouts
                    AppDelegate.saveToArchive(workouts: self.workouts)
                    //self.tableView.reloadSections(IndexSet([0]), with: .bottom)
                    self.tableView.reloadData()
                    return
                }
                match = false
            }
            self.webLoadComplete = false
            self.archiveLoadComplete = false
        }
        else if self.archiveLoadComplete == true {
            os_log("Archive Load Complete", log: OSLog.default, type: .debug)
            self.workouts = self.archiveWorkouts
            //self.tableView.reloadSections(IndexSet([0]), with: .bottom)
            self.tableView.reloadData()
        }
        else if self.webLoadComplete == true {
            os_log("Web Load Complete", log: OSLog.default, type: .debug)
            self.workouts = self.webWorkouts
            AppDelegate.saveToArchive(workouts: self.workouts)
            //self.tableView.reloadSections(IndexSet([0]), with: .bottom)
            self.tableView.reloadData()
        }
    }
}
