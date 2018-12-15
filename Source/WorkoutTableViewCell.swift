//
//  WorkoutTableViewCell.swift
//  HEWAVL
//
//  Created by Klockenga,Nick on 12/4/18.
//  Copyright © 2018 Klockenga,Nick. All rights reserved.
//

import UIKit

class WorkoutTableViewCell: UITableViewCell {

    @IBOutlet weak var workoutText: UITextView!
    @IBOutlet weak var workoutName: UILabel!
    @IBOutlet weak var workoutDate: UITextView!
    @IBOutlet weak var nameBar: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        self.contentView.backgroundColor = UIColor(red: 141/255.0, green: 198/255.0, blue: 63/255.0, alpha: 1.0)
        self.contentView.layer.cornerRadius = 12
        self.contentView.bounds = CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y,
                                         width: self.bounds.width - 16, height: self.bounds.height - 12)
        //self.contentView.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.contentView.layer.masksToBounds = true
        //self.contentView.layer.shadowColor = UIColor.black.cgColor
        //self.contentView.layer.shadowOpacity = 0.25
        //self.contentView.layer.shadowRadius
        
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.contentView.layer.borderWidth = 5.0
        self.contentView.layer.shadowOpacity = 0.5
        self.contentView.layer.shadowColor = UIColor.lightGray.cgColor
        self.contentView.layer.shadowRadius = 12
        self.contentView.layer.shadowOffset = CGSize(width: 5, height: 5)
    }

}
