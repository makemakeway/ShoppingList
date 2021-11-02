//
//  ShoppingTableViewCell.swift
//  TableViewPractice
//
//  Created by 박연배 on 2021/10/13.
//

import UIKit

class ShoppingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var checkMark: UIButton?
    @IBOutlet weak var shoppingLabel: UILabel?
    @IBOutlet weak var starMark: UIButton?
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
