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

    @IBOutlet weak var wodTitle: WKInterfaceLabel!
    @IBOutlet weak var wodBody: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
