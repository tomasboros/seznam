//
//  MatchPlayerTableViewCell.swift
//  aoe
//
//  Created by Tomáš Boros on 13/04/2022.
//

import UIKit
import SwiftEventBus

class MatchPlayerTableViewCell: UITableViewCell {

    @IBOutlet weak var civTitle: UILabel!
    @IBOutlet weak var civSubTitle: UILabel!
    @IBOutlet weak var playerTitle: UILabel!
    @IBOutlet weak var playerSubTitle: UILabel!
    
    var player: realmMatchPlayer! {
        didSet {
            
            playerSubTitle.text = "Player"
            playerSubTitle.font = UIFont.boldSystemFont(ofSize: 9)
            playerSubTitle.textColor = UIColor(red: 160/255, green: 160/255, blue: 160/255, alpha: 1.0)
            
            playerTitle.text = player.name
            playerTitle.font = UIFont.boldSystemFont(ofSize: 14)
            playerTitle.textColor = UIColor(red: 160/255, green: 160/255, blue: 160/255, alpha: 1.0)
            
            civSubTitle.text = "Civilization"
            civSubTitle.font = UIFont.boldSystemFont(ofSize: 9)
            civSubTitle.textColor = UIColor(red: 160/255, green: 160/255, blue: 160/255, alpha: 1.0)
            
            civTitle.text = player.civilisation
            civTitle.font = UIFont.boldSystemFont(ofSize: 14)
            civTitle.textColor = UIColor(red: 160/255, green: 160/255, blue: 160/255, alpha: 1.0)

        }
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
