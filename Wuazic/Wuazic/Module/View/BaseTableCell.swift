//
//  BaseTableCell.swift
//  SwiftyAds
//
//  Created by MinhNH on 24/04/2023.
//

import UIKit

class BaseTableCell: UITableViewCell {
    
    deinit {
#if DEBUG
        print("RELEASED \(String(describing: self.self))")
#endif
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
