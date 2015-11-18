//
//  WsjTableViewCell.swift
//  wsj-swift
//
//  Created by WAYNE SMALL on 11/17/15.
//  Copyright © 2015 Waynemystir. All rights reserved.
//

import UIKit

class WsjTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var itemDescription: UILabel!
    @IBOutlet weak var itemImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
