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

class InterfaceController: WKInterfaceController {

    @IBOutlet weak var titleGroup: WKInterfaceGroup!
    @IBOutlet weak var bodyGroup: WKInterfaceGroup!
    
    @IBOutlet weak var wodTitle: WKInterfaceLabel!
    @IBOutlet weak var wodBody: WKInterfaceLabel!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        let defaults = UserDefaults.init(suiteName: "workout.watch")!
        
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
                                                                                      font: UIFont(name: "Helvetica", size: 11),
                                                                                      color: UIColor.white,
                                                                                      paragraphStyle: style)
                    
                    self.wodBody.setAttributedText(attrText)
                    self.wodBody.setHorizontalAlignment(.center)
                }
            }
        }
        
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
                        
                        self.wodTitle.setText(json["workout"]["name"].string!)
                        self.wodTitle.setHorizontalAlignment(.center)
                        
                        let style = NSMutableParagraphStyle()
                        style.alignment = NSTextAlignment.center
                        
                        let attrText:NSAttributedString = NKMarkupParser.attributedString(fromMarkup: json["workout"]["text"].string!,
                                                                              font: UIFont(name: "Helvetica", size: 11),
                                                                              color: UIColor.white,
                                                                              paragraphStyle: style)
                        
                        self.wodBody.setAttributedText(attrText)
                        self.wodBody.setHorizontalAlignment(.center)
                        
                        defaults.set(json.description, forKey: "workout")
                    }
                }
            }
        }

        dataTask.resume()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        self.scroll(to: self.titleGroup, at: .top, animated: false)
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
