//
//  InterfaceController.swift
//  HEW WOD Watch Extension
//
//  Created by Klockenga,Nick on 1/8/19.
//  Copyright © 2019 Klockenga,Nick. All rights reserved.
//

import WatchKit
import Foundation
import SwiftyJSON
import WatchConnectivity

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
    private var defaults:UserDefaults!
    
    private var workout:Workout!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        print("awake")
        
        var loadComplete:Bool = false
        
        self.defaults = UserDefaults.init(suiteName: "workout.watch")!
        
        let jsonString = defaults.string(forKey: "workout") ?? "{}"
        let json = JSON.init(parseJSON: jsonString)

        if json["status"].exists() {
            if json["status"] == "success" {
                
                let dateFormatter = ISO8601DateFormatter()
                dateFormatter.formatOptions = [.withFullDate,
                                               .withTime,
                                               .withDashSeparatorInDate,
                                               .withColonSeparatorInTime]
            
                let curDate = dateFormatter.date(from: json["workout"]["date"].string!) ?? Date()
                
                if Calendar.current.isDateInToday(curDate) {
                    self.wodTitle.setText(json["workout"]["name"].string!)
                    self.wodTitle.setHorizontalAlignment(.center)
                    
                    let style = NSMutableParagraphStyle()
                    style.alignment = NSTextAlignment.center
                    
                    let attrText:NSAttributedString = NKMarkupParser.attributedString(fromMarkup: json["workout"]["text"].string!,
                                                                                      font: UIFont(name: "Helvetica", size: 11.5),
                                                                                      color: UIColor.white,
                                                                                      paragraphStyle: style)
                    
                    self.wodBody.setAttributedText(attrText)
                    self.wodBody.setHorizontalAlignment(.center)
                    self.workoutDate = curDate
                    
                    self.mainGroup.setHidden(false)
                    self.loadingLabel.setHidden(true)
                    self.forceUpdateGroup.setHidden(false)
                    
                    loadComplete = true
                }
            }
        }
        
        // only do url call if the load from defaults did not work
        if loadComplete == false {
            self.loadFromWeb()
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        print("willActivate")
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
        self.loadingLabel.setText("Loading ...")
        self.loadingLabel.setHorizontalAlignment(.center)
        
        self.loadFromWeb()
    }
    private func loadFromWeb() {
        print("loadFromWeb")
        
        let request = NSMutableURLRequest(url: URL(string: "https://hew.klck.in/api/1.0/workout")!,
                                          cachePolicy: .reloadIgnoringCacheData,
                                          timeoutInterval:30)
        request.httpMethod = "GET" // POST ,GET, PUT What you want
        
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: request as URLRequest) {data,response,error in
            
            do {
                let json = JSON(data!)
                
                if json["status"].exists() {
                    if json["status"] == "success" {
                        
                        let dateFormatter = ISO8601DateFormatter()
                        dateFormatter.formatOptions = [.withFullDate,
                                                       .withTime,
                                                       .withDashSeparatorInDate,
                                                       .withColonSeparatorInTime]
                        
                        let curDate = dateFormatter.date(from: json["workout"]["date"].string!) ?? Date()
                        
                        if Calendar.current.isDateInToday(curDate) {
                        
                            print("web load is today")
                            
                            self.wodTitle.setText(json["workout"]["name"].string!)
                            self.wodTitle.setHorizontalAlignment(.center)
                            
                            let style = NSMutableParagraphStyle()
                            style.alignment = NSTextAlignment.center
                            
                            let attrText:NSAttributedString = NKMarkupParser.attributedString(fromMarkup: json["workout"]["text"].string!,
                                                                                              font: UIFont(name: "Helvetica", size: 11.5),
                                                                                              color: UIColor.white,
                                                                                              paragraphStyle: style)
                            
                            self.wodBody.setAttributedText(attrText)
                            self.wodBody.setHorizontalAlignment(.center)
                            self.workoutDate = curDate
                            
                            self.mainGroup.setHidden(false)
                            self.loadingLabel.setHidden(true)
                            self.forceUpdateGroup.setHidden(false)
                            
                        } else {
                            
                            print("web load no workout today")
                            
                            self.loadingLabel.setText("No Workout Today")
                            self.loadingLabel.setHorizontalAlignment(.center)
                            self.loadingLabel.setHidden(false)
                            self.mainGroup.setHidden(true)
                            self.forceUpdateGroup.setHidden(false)

                            self.workoutDate = Date()
                            
                        }
                        
                        self.defaults.set(json.description, forKey: "workout")
                    }
                }
            }
        }
        
        dataTask.resume()
    }

}
