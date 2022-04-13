//
//  LastGameViewController.swift
//  aoe
//
//  Created by Tomáš Boros on 11/04/2022.
//

import UIKit
import SwiftEventBus

class LastGameViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var mapLabel: UILabel!
    @IBOutlet weak var mapImageView: UIImageView!
    @IBOutlet weak var matchLenghtLabel: UILabel!
    @IBOutlet weak var matchLenghtImageView: UIImageView!
    @IBOutlet weak var matchNameLabel: UILabel!
    @IBOutlet weak var matchNameImageView: UIImageView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var alertView: UIView!
    
    var player: realmPlayer!
    private lazy var players: [realmMatchPlayer] = [realmMatchPlayer]()
    var match: realmMatch = realmMatch()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .dark
        } else {
            // Fallback on earlier versions
        }
        
        title = "Detail"
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        tableView.dataSource = self
        tableView.delegate = self
        
        alertView.isHidden = true
        alertLabel.text = "Loading"
        alertLabel.font = UIFont.boldSystemFont(ofSize: 12)
        alertLabel.textColor = UIColor.white
        activityIndicator.color = UIColor.white
        
        backgroundImageView.image = UIImage(named: "detail_background")
        backgroundView.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.85)
        
        matchNameImageView.image = UIImage(named: "match_name")
        matchLenghtImageView.image = UIImage(named: "match_lenght")
        mapImageView.image = UIImage(named: "map")
        
        matchNameLabel.font = UIFont.boldSystemFont(ofSize: 12)
        matchNameLabel.textColor = UIColor(red: 160/255, green: 160/255, blue: 160/255, alpha: 1.0)
        
        matchLenghtLabel.font = UIFont.boldSystemFont(ofSize: 12)
        matchLenghtLabel.textColor = UIColor(red: 160/255, green: 160/255, blue: 160/255, alpha: 1.0)
        
        mapLabel.font = UIFont.boldSystemFont(ofSize: 12)
        mapLabel.textColor = UIColor(red: 160/255, green: 160/255, blue: 160/255, alpha: 1.0)
        
        matchNameImageView.isHidden = true
        matchLenghtImageView.isHidden = true
        mapImageView.isHidden = true
        matchNameLabel.isHidden = true
        matchLenghtLabel.isHidden = true
        mapLabel.isHidden = true
        
        removeLastMatch()
        downloadLastMatch()
        
    }
    
    func downloadLastMatch() {
        if Connectivity.isConnectedToInternet {
            DispatchQueue.global(qos: .userInitiated).async {
                DispatchQueue.main.async {
                    self.activityIndicator.startAnimating()
                    self.alertView.isHidden = false
                    self.tableView.isHidden = true
                    downloadLastMatchToRealm(self.player.id)
                    SwiftEventBus.onBackgroundThread(self, name: "matchWasDownloaded") { notification in
                        SwiftEventBus.postToMainThread("matchWasDownloadedUpdate")
                    }
                    SwiftEventBus.onMainThread(self, name: "matchWasDownloadedUpdate") { notification in
                        self.alertView.isHidden = true
                        self.players = loadMatchPlayers()
                        self.match = loadMatch()
                        self.matchNameLabel.text = self.match.name
                        self.matchLenghtLabel.text = "\(self.match.finished) min."
                        self.mapLabel.text = ""
                        self.getString(type: "map", id: self.match.map, player: 0)
                        self.matchNameImageView.isHidden = false
                        self.matchLenghtImageView.isHidden = false
                        self.mapImageView.isHidden = false
                        self.matchNameLabel.isHidden = false
                        self.matchLenghtLabel.isHidden = false
                        self.mapLabel.isHidden = false
                        var i = 0
                        for item in self.players {
                            downloadStringToRealm("civ", id: item.civ)
                            SwiftEventBus.onMainThread(self, name:"stringWasDownloaded") { result in
                                self.alertView.isHidden = true
                                let string = result?.object
                                updateCivilisation(item.id, civilisation: "\(string!)")
                                self.players = loadMatchPlayers()
                                self.tableView.reloadData()
                            }
                            i = i+1
                            if i == self.players.count {
                                self.tableView.isHidden = false
                                SwiftEventBus.unregister(self, name: "matchWasDownloaded")
                            }
                        }
                    }
                }
            }
        } else {
            let alertController = UIAlertController(title: "Connection", message: "You are not connected to the internet!", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Close", style: UIAlertAction.Style.cancel) {
                UIAlertAction in
                self.alertView.isHidden = true
                self.navigationController!.popViewController(animated: true)
                NSLog("Cancel Pressed")
            }
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func getString(type: String, id: Int, player: Int) {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self.alertView.isHidden = false
                downloadStringToRealm(type, id: id)
                SwiftEventBus.onMainThread(self, name:"stringWasDownloaded") { result in
                    self.alertView.isHidden = true
                    let string = result?.object
                    if type == "civ" {
                        updateCivilisation(player, civilisation: "\(string!)")
                    } else {
                        self.mapLabel.text = "\(string!)"
                    }
                    SwiftEventBus.unregister(self, name: "stringWasDownloaded")
                }
            }
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MatchPlayerTableViewCell", for: indexPath) as! MatchPlayerTableViewCell
        
        var player = players[indexPath.row] as realmMatchPlayer
        player = self.players[indexPath.row]
        cell.player = player
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeLastMatch()
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
