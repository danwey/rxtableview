//
//  TableViewCell.swift
//  LrcTableView
//
//  Created by mac3 on 2017/9/22.
//  Copyright © 2017年 mac3. All rights reserved.
//

import UIKit

class LrcLabel: UILabel {
    var progress: CGFloat = 0.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        UIColor.green.set()
        let fillRect = CGRect(x: 0, y: 0, width: progress*rect.width, height: rect.height)
        UIRectFillUsingBlendMode(fillRect, CGBlendMode.sourceIn)
    }
}

class TableViewCell: UITableViewCell {

    @IBOutlet weak var lrcLabel: LrcLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        // Initialization code
    }
    
    var data: LrcData? {
        didSet {
            progress = 0
            lrcLabel.text = "\((data?.text)!)"
        }
    }
    
    var progress: TimeInterval = 0 {
        didSet {
            if let data = data {
                self.lrcLabel.progress = CGFloat(data.getPregress(progress))
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
