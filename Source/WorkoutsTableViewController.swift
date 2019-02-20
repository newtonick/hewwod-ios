//
//  WorkoutsTableViewController.swift
//  HEWAVL
//
//  Created by Klockenga,Nick on 12/4/18.
//  Copyright © 2018 Klockenga,Nick. All rights reserved.
//

import UIKit
import os.log

class WorkoutsTableViewController: UITableViewController {
    
    @IBOutlet weak var settingsNavButton: UIBarButtonItem!
    @IBOutlet weak var refreshNavButton: UIBarButtonItem!
    
    let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var tableViewUpdated = Date()
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.appDelegate.workoutController.fetchWorkoutsFromWeb(completion: { workouts in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.6, execute: { refreshControl.endRefreshing()})
            self.refreshTable()
            self.appDelegate.workoutController.saveWorkoutsToUserDefaults()
        }, failure: {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.6, execute: { refreshControl.endRefreshing()})
        })
    }
    
    override func viewDidLoad() {
        os_log("viewDidLoad", log: OSLog.default, type: .debug)
        super.viewDidLoad()
        
        self.tableView.refreshControl = UIRefreshControl()
        
        self.tableView.refreshControl!.addTarget(self, action:
            #selector(self.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        
        self.tableView.refreshControl!.tintColor = UIColor.black
        self.tableView.refreshControl?.superview?.sendSubviewToBack(self.tableView.refreshControl!)
        
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
        
        self.appDelegate.workoutsTableViewController = self
        
        self.tableViewUpdated = UserDefaults.standard.object(forKey: "tableViewUpdated") as? Date ?? Date().addingTimeInterval(-60)
        
        // loads the userdefaults and pulls down the web updates
        self.loadWorkouts()
        
        os_log("WorkoutsTableViewController viewDidLoad is Complete", log: OSLog.default, type: .debug)
    }

    // MARK: - Table view data source
    
    @IBAction func forceRefresh(_ sender: UIBarButtonItem) {
        self.refreshNavButton.isEnabled = false;
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(enableRefresh), userInfo: nil, repeats: false)
        self.tableView.setContentOffset(.zero, animated: false)
        self.appDelegate.workoutController.fetchWorkoutsFromWeb(completion: { workouts in
            self.refreshTable()
            self.appDelegate.workoutController.saveWorkoutsToUserDefaults()
        }, failure: {})
    }
    
    @objc func enableRefresh() {
        self.refreshNavButton.isEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        os_log("viewWillAppear", log: OSLog.default, type: .debug)
        if self.tableViewUpdated.addingTimeInterval(60) < Date() {
            self.refreshTable()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.appDelegate.workoutController.workouts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "WorkoutTableViewCell"
        
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? WorkoutTableViewCell else {
            fatalError("The cell is not an instance of WorkoutTableViewCell.")
        }
        
        if self.appDelegate.workoutController.workouts.count >= indexPath.row {
            os_log("loading tableView Cell: %@", log: OSLog.default, type: .debug, self.appDelegate.workoutController.workouts[indexPath.row]?.name ?? "undefined")
            
            //set cell values
            cell.workoutName.text = self.appDelegate.workoutController.workouts[indexPath.row]?.name
            cell.workoutText.text = self.appDelegate.workoutController.workouts[indexPath.row]?.text
            cell.workoutDate.text = self.appDelegate.workoutController.workouts[indexPath.row]?.getDateString()
            cell.workoutText.attributedText = self.appDelegate.workoutController.workouts[indexPath.row]?.attributedText
            
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
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let screenWidth = UIScreen.main.bounds.width
        
        let cgsize = CGSize(width: screenWidth - 46, height: 10000)
        
        if self.appDelegate.workoutController.workouts.count >= indexPath.row {
            let rect = self.appDelegate.workoutController.workouts[indexPath.row]!.attributedText.boundingRect(with: cgsize, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
            os_log("Height tableView Cell: %@", log: OSLog.default, type: .debug, rect.height.description)
            
            return CGFloat(90 + rect.height);
        } else {
            os_log("Default Height Returned to tableView Cell", log: OSLog.default, type: .debug)
            return CGFloat(200);
        };
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
        self.appDelegate.working = true
        self.appDelegate.workoutController.fetchWorkoutsFromUserDefaults(completion: { workouts in
            let defaultsWorkouts = workouts
            if self.tableViewUpdated.addingTimeInterval(60) < Date() {
                self.refreshTable()
            }
            self.appDelegate.workoutController.fetchWorkoutsFromWeb(completion: { workouts in
                if defaultsWorkouts.count != workouts.count || defaultsWorkouts[0]?.updated != workouts[0].updated ||
                    defaultsWorkouts[0]?.name != workouts[0].name {
                    self.refreshTable()
                } else if self.tableViewUpdated.addingTimeInterval(60) < Date() {
                    self.refreshTable()
                }
                self.appDelegate.workoutController.saveWorkoutsToUserDefaults()
                self.appDelegate.working = false
            }, failure: { self.appDelegate.working = false })
        })
    }
    
    func refreshTable() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        self.tableViewUpdated = Date()
        UserDefaults.standard.set(self.tableViewUpdated, forKey:"tableViewUpdated")
        UserDefaults.standard.synchronize()
    }

}
