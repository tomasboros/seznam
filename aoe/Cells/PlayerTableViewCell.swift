//
//  PlayerTableViewCell.swift
//  aoe
//
//  Created by Tomáš Boros on 11/04/2022.
//

import UIKit

class PlayerTableViewCell: UITableViewCell {

    @IBOutlet weak var playerLabel: UILabel!
    @IBOutlet weak var winLabel: UILabel!
    @IBOutlet weak var winImageView: UIImageView!
    @IBOutlet weak var winView: UIView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var rankImageView: UIImageView!
    @IBOutlet weak var rankView: UIView!
    
    var player: realmPlayer! {
        didSet {
            
            winImageView.image = UIImage(named: "win")
            ratingImageView.image = UIImage(named: "rating")
            rankImageView.image = UIImage(named: "rank")
            
            playerLabel.text = player.name
            playerLabel.font = UIFont.boldSystemFont(ofSize: 14)
            playerLabel.textColor = UIColor(red: 155/255, green: 102/255, blue: 68/255, alpha: 1.0)
            
            winLabel.text = "\(player.win)%"
            winLabel.font = UIFont.boldSystemFont(ofSize: 12)
            winLabel.textColor = UIColor(red: 160/255, green: 160/255, blue: 160/255, alpha: 1.0)
            
            ratingLabel.text = "\(player.rating)"
            ratingLabel.font = UIFont.boldSystemFont(ofSize: 12)
            ratingLabel.textColor = UIColor(red: 160/255, green: 160/255, blue: 160/255, alpha: 1.0)
            
            rankLabel.text = "\(player.rank)"
            rankLabel.font = UIFont.boldSystemFont(ofSize: 12)
            rankLabel.textColor = UIColor(red: 160/255, green: 160/255, blue: 160/255, alpha: 1.0)

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
