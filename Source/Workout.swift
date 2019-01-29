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

struct Workout: Codable {
    var id: String
    var name: String
    var text: String
    var date: Date
    var updated: Date
    var attributedText: NSAttributedString

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case text
        case date
        case updated
        case attributedText
    }
    
    init?() {
        self.id = ""
        self.name = ""
        self.text = ""
        self.date = Date()
        self.updated = Date()
        self.attributedText = NSAttributedString(string: "")
        
        return nil
    }
    
    init?(id: String, name: String, text: String, date: Date, updated: Date) {
        if id.isEmpty || name.isEmpty { return nil }
        self.id = id
        self.name = name
        self.text = text
        self.date = date
        self.updated = updated
        
        self.attributedText = Workout.attributedText(text: self.text)
    }
    
    init?(json:[String: Any]) {
        if (json["_id"] as? String)!.isEmpty { return nil }
        if (json["name"] as? String)!.isEmpty { return nil }
        if (json["date"] as? String)!.isEmpty { return nil }
        
        self.id = (json["_id"] as Any? as? String)!
        self.name = (json["name"] as Any? as? String) ?? ""
        self.text = (json["text"] as Any? as? String) ?? ""
        self.date = Workout.stringDateConverter(date: (json["date"] as Any? as? String)!)
        self.updated = Workout.stringDateConverter(date: (json["updated"] as Any? as? String)!)
        
        self.attributedText = Workout.attributedText(text: self.text)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(text, forKey: .text)
        try container.encode(date, forKey: .date)
        try container.encode(updated, forKey: .updated)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        text = try container.decode(String.self, forKey: .text)
        date = try container.decode(Date.self, forKey: .date)
        updated = try container.decode(Date.self, forKey: .updated)
        
        attributedText = Workout.attributedText(text: text)
    }
    
    static func stringDateConverter(date: String) -> Date {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate,
                                       .withTime,
                                       .withDashSeparatorInDate,
                                       .withColonSeparatorInTime]
        
        return dateFormatter.date(from: date) ?? Date()
    }
    
    static func attributedText(text: String) -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        
        return NKMarkupParser.attributedString(fromMarkup: text,
                                               font: UIFont(name: "Helvetica", size: 15),
                                               color: UIColor.white,
                                               paragraphStyle: style)
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
