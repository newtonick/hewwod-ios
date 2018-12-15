//
//  NSAttributedStringExtension.swift
//  HEW WOD
//
//  Created by Klockenga,Nick on 12/7/18.
//  Copyright © 2018 Klockenga,Nick. All rights reserved.
//

import Foundation

extension NSMutableAttributedString {
    public func attributedStringByTrimmingCharacterSet(charSet: CharacterSet) {
        var range = (string as NSString).rangeOfCharacter(from: charSet)
        
        // Trim leading characters from character set.
        while range.length != 0 && range.location == 0 {
            replaceCharacters(in: range, with: "")
            range = (string as NSString).rangeOfCharacter(from: charSet)
        }
        
        // Trim trailing characters from character set.
        range = (string as NSString).rangeOfCharacter(from: charSet, options: .backwards)
        while range.length != 0 && NSMaxRange(range) == length {
            replaceCharacters(in: range, with: "")
            range = (string as NSString).rangeOfCharacter(from: charSet, options: .backwards)
        }
    }
}
