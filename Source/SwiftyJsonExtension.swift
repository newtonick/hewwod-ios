//
//  SwiftyJsonExtension.swift
//
//  Created by Chris Iona on 02/12/16.
//  MIT License.
//
//  Date extension for SwiftyJSON module
//  https://github.com/SwiftyJSON/SwiftyJSON
//
//  Assumes that you already have SwityJSON installed and available
//
import Foundation
import SwiftyJSON

extension JSON {
    public var date: Date? {
        get {
            if let epoch = self.double {
                // Convert epoch Interval (aka Double) to Date Object
                return Date(timeIntervalSince1970: epoch)
            }
            return nil
        }
        set {
            if let newValue = newValue {
                // Store date object as epoch Interval (aka Double)
                self.double = newValue.timeIntervalSince1970
            } else {
                self.object = NSNull()
            }
        }
    }
}
