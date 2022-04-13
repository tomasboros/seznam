//
//  LeaderboardViewController.swift
//  aoe
//
//  Created by Tomáš Boros on 11/04/2022.
//

import UIKit
import SwiftEventBus

class LeaderboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerImageView: UIImageView!
    
    private lazy var players: [realmPlayer] = [realmPlayer]()
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .dark
        } else {
            // Fallback on earlier versions
        }
        
        titleView.backgroundColor = UIColor.black
        
        titleLabel.text = "Leaderboard".uppercased()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 14)
        titleLabel.textColor = UIColor.white
        
        tableView.dataSource = self
        tableView.delegate = self
        
        refreshControl.attributedTitle = NSAttributedString(string: "Refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        alertView.isHidden = true
        alertLabel.text = "Loading"
        alertLabel.font = UIFont.boldSystemFont(ofSize: 12)
        alertLabel.textColor = UIColor.white
        activityIndicator.color = UIColor.white
        
        headerImageView.image = UIImage(named: "header")
        
        downloadPlayers()
        
    }
    
    @objc func refresh(_ sender: AnyObject) {
        downloadPlayersForRefresh()
    }
    
    func downloadPlayers() {
        if Connectivity.isConnectedToInternet {
            DispatchQueue.global(qos: .userInitiated).async {
                DispatchQueue.main.async {
                    self.activityIndicator.startAnimating()
                    self.alertView.isHidden = false
                    self.tableView.isHidden = true
                    downloadLeaderboardToRealm()
                    SwiftEventBus.onBackgroundThread(self, name: "playersWasDownloaded") { notification in
                        SwiftEventBus.postToMainThread("playersWasDownloadedUpdate")
                    }
                    SwiftEventBus.onMainThread(self, name: "playersWasDownloadedUpdate") { notification in
                        self.alertView.isHidden = true
                        self.players = loadPlayers()
                        self.tableView.reloadData()
                        self.tableView.isHidden = false
                        SwiftEventBus.unregister(self, name: "playersWasDownloaded")
                    }
                }
            }
        } else {
            let alertController = UIAlertController(title: "Connection", message: "You are not connected to the internet!", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Close", style: UIAlertAction.Style.cancel) {
                UIAlertAction in
                self.alertView.isHidden = true
                self.players = loadPlayers()
                self.tableView.reloadData()
                NSLog("Cancel Pressed")
            }
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func downloadPlayersForRefresh() {
        if Connectivity.isConnectedToInternet {
            DispatchQueue.global(qos: .userInitiated).async {
                DispatchQueue.main.async {
                    downloadLeaderboardToRealm()
                    SwiftEventBus.onBackgroundThread(self, name: "playersWasDownloaded") { notification in
                        SwiftEventBus.postToMainThread("playersWasDownloadedUpdate")
                    }
                    SwiftEventBus.onMainThread(self, name: "playersWasDownloadedUpdate") { notification in
                        self.players = loadPlayers()
                        self.tableView.reloadData()
                        self.refreshControl.endRefreshing()
                        SwiftEventBus.unregister(self, name: "playersWasDownloaded")
                    }
                }
            }
        } else {
            let alertController = UIAlertController(title: "Failed", message: "You are not connected to the internet!", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Close", style: UIAlertAction.Style.cancel) {
                UIAlertAction in
                self.alertView.isHidden = true
                self.players = loadPlayers()
                self.tableView.reloadData()
                NSLog("Cancel Pressed")
            }
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerTableViewCell", for: indexPath) as! PlayerTableViewCell
        
        var player = players[indexPath.row] as realmPlayer
        player = self.players[indexPath.row]
        cell.player = player
        
        cell.selectionStyle = .gray
        let cellBackgroundView = UIView()
        cellBackgroundView.backgroundColor = UIColor(red: 15/255, green: 15/255, blue: 15/255, alpha: 1.0)
        cell.selectedBackgroundView = cellBackgroundView
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
        
        guard let viewController = segue.destination as? LastGameViewController else { return }
        guard let cell = sender as? UITableViewCell else { return }
        if (segue.identifier == "showLastGame") {
            let index = tableView.indexPath(for: cell)!.row
            let selectedPlayer = players[index]
            viewController.player = selectedPlayer
        }
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
