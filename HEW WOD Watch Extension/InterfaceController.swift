//
//  InterfaceController.swift
//  HEW WOD Watch Extension
//
//  Created by Klockenga,Nick on 1/8/19.
//  Copyright © 2019 Klockenga,Nick. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {

    @IBOutlet weak var mainGroup: WKInterfaceGroup!
    @IBOutlet weak var titleGroup: WKInterfaceGroup!
    @IBOutlet weak var bodyGroup: WKInterfaceGroup!
    
    @IBOutlet weak var wodTitle: WKInterfaceLabel!
    @IBOutlet weak var wodBody: WKInterfaceLabel!
    
    @IBOutlet weak var loadingLabel: WKInterfaceLabel!
    @IBOutlet weak var forceUpdateButton: WKInterfaceButton!
    @IBOutlet weak var forceUpdateGroup: WKInterfaceGroup!
    
    private var workoutDate:Date!
    
    private var working:Bool = false
    
    var workoutController:WorkoutController = WorkoutController()

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        print("awake")
        loadWorkout()
    }
    
    func loadWorkout() {
        self.working = true
        self.workoutController.fetchLatestWorkoutFromUserDefault(completion: { workout in
            if workout != nil && self.workoutController.isLatestWorkoutToday(){
                    self.refreshView()
            } else {
                self.forceUpdateGroup.setHidden(true)
                self.mainGroup.setHidden(true)
                self.loadingLabel.setHidden(false)
                self.loadingLabel.setText("Fetching ...")
                self.loadingLabel.setHorizontalAlignment(.center)
            }
            
            self.workoutController.fetchLatestWorkoutFromWeb(completion: { workout in
                self.refreshView()
                self.workoutController.saveLatestWorkoutToUserDefault()
                self.working = false
            }, failure: {
                if workout == nil || !self.workoutController.isLatestWorkoutToday(){
                    self.mainGroup.setHidden(true)
                    self.loadingLabel.setHidden(false)
                    self.loadingLabel.setText("Failed to Load")
                    self.forceUpdateGroup.setHidden(false)
                }
            })
        })
    }
    
    func refreshView() {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate,
                                       .withTime,
                                       .withDashSeparatorInDate,
                                       .withColonSeparatorInTime]

        if Calendar.current.isDateInToday((self.workoutController.latestWorkout?.date)!) {
            self.wodTitle.setText(self.workoutController.latestWorkout?.name)
            self.wodTitle.setHorizontalAlignment(.center)

            let style = NSMutableParagraphStyle()
            style.alignment = NSTextAlignment.center

            let attrText:NSAttributedString = NKMarkupParser.attributedString(fromMarkup: self.workoutController.latestWorkout?.text,
                                                                              font: UIFont(name: "Helvetica", size: 11.5),
                                                                              color: UIColor.white,
                                                                              paragraphStyle: style)

            self.wodBody.setAttributedText(attrText)
            self.wodBody.setHorizontalAlignment(.center)
            self.workoutDate = self.workoutController.latestWorkout?.date

            self.mainGroup.setHidden(false)
            self.loadingLabel.setHidden(true)
            self.forceUpdateGroup.setHidden(false)
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        print("willActivate")
        
        if self.working == false && self.workoutController.latestWorkoutUpdated.addingTimeInterval(300) < Date() {
            self.loadWorkout()
        }
    }
    
    override func didAppear() {
        super.didAppear()

        print("didAppear")
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        print("didDeactivate")
        
        self.scroll(to: self.titleGroup, at: .top, animated: false)
    }
    
    @IBAction func forceUpdate() {
        self.forceUpdateGroup.setHidden(true)
        self.mainGroup.setHidden(true)
        self.loadingLabel.setHidden(false)
        self.loadingLabel.setText("Fetching ...")
        self.loadingLabel.setHorizontalAlignment(.center)
        
        self.workoutController.fetchLatestWorkoutFromWeb(completion: { workout in
            self.refreshView()
            self.workoutController.saveLatestWorkoutToUserDefault()
        }, failure: {
            self.mainGroup.setHidden(true)
            self.loadingLabel.setHidden(false)
            self.loadingLabel.setText("Failed to Load")
            self.forceUpdateGroup.setHidden(false)
        })
    }
}
