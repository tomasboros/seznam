//
//  IntroViewController.swift
//  aoe
//
//  Created by Tomáš Boros on 11/04/2022.
//

import UIKit

class IntroViewController: UIViewController {

    @IBOutlet weak var posterImageView: UIImageView!
    
    var timer: Timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .dark
        } else {
            // Fallback on earlier versions
        }
        
        posterImageView.image = UIImage(named: "background")
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(IntroViewController.switchToLeaderboard), userInfo: nil, repeats: false)
        
    }
    
    @objc func switchToLeaderboard() {
        performSegue(withIdentifier: "showLeaderboard", sender: self)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
