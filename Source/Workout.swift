//
//  Workout.swift
//  HEWAVL
//
//  Created by Klockenga,Nick on 12/4/18.
//  Copyright © 2018 Klockenga,Nick. All rights reserved.
//

import Foundation
import UIKit
import os.log

class Workout : NSObject, NSCoding {
    var id: String
    var name: String
    var text: String
    var date: Date
    var updated: Date
    var attributedText: NSAttributedString
    
    struct PropertyKey {
        static let id = "id"
        static let name = "name"
        static let text = "text"
        static let date = "date"
        static let updated = "updated"
        static let attributedText = "attributedText"
    }
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("workouts")
    
    init?(id: String, name: String, text: String, date: Date, updated: Date) {
        self.id = id
        self.name = name
        self.text = text
        self.date = date
        self.updated = updated
        
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        
        self.attributedText = NKMarkupParser.attributedString(fromMarkup: text,
                                                              font: UIFont(name: "Helvetica", size: 15),
                                                              color: UIColor.white,
                                                              paragraphStyle: style)
        super.init()
        
        if name.isEmpty || text.isEmpty || id.isEmpty {
            return nil
        }
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let id = aDecoder.decodeObject(forKey: PropertyKey.id) as? String else {
            os_log("Unable to decode the id for a Workout object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        if let _ = aDecoder.decodeObject(forKey: PropertyKey.updated) {
            
        } else {
            os_log("Unable to decode the updated field for a Workout object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        let name = aDecoder.decodeObject(forKey: PropertyKey.name) as! String
        let text = aDecoder.decodeObject(forKey: PropertyKey.text) as! String
        let date = aDecoder.decodeObject(forKey: PropertyKey.date) as! Date
        let updated = aDecoder.decodeObject(forKey: PropertyKey.updated) as! Date
        let attributedText = aDecoder.decodeObject(forKey: PropertyKey.attributedText) as! NSAttributedString
    
        self.init(id: id, name: name, text: text, date: date, updated: updated)
        self.attributedText = attributedText
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: PropertyKey.id)
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(text, forKey: PropertyKey.text)
        aCoder.encode(date, forKey: PropertyKey.date)
        aCoder.encode(updated, forKey: PropertyKey.updated)
        aCoder.encode(attributedText, forKey: PropertyKey.attributedText)
    }
    
    static func stringDateConverter(date: String) -> Date {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate,
                                       .withTime,
                                       .withDashSeparatorInDate,
                                       .withColonSeparatorInTime]
        
        return dateFormatter.date(from: date) ?? Date()
    }
    
    func getDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "en_US")
        
        if Calendar.current.isDateInToday(self.date) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(self.date) {
            return "Yesterday"
        } else {
            return (dateFormatter.string(from: self.date))
        }
    }
    
    
}
