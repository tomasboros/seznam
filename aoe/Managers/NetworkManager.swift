//
//  NetworkManager.swift
//  aoe
//
//  Created by Tomáš Boros on 11/04/2022.
//

import Foundation
import Alamofire
import SwiftEventBus
import RealmSwift
import SwiftyJSON

func downloadLeaderboardToRealm() {
    
    AF.request("https://aoe2.net/api/leaderboard?game=aoe2de&leaderboard_id=3&start=1&count=20", method: .get, encoding: JSONEncoding.default).validate().responseJSON { response in
        
        debugPrint(response)
        
        switch response.result {
        case .success:
            if let value = response.value {
                let json = JSON(value)
                var i = 0
                var allPlayers: [realmPlayer] = [realmPlayer]()
                if let players = json["leaderboard"].array {
                    var jsonIDs: [Int] = []
                    for player in players {
                        let rlmPlayer: realmPlayer = realmPlayer()
                        rlmPlayer.id = player["profile_id"].int!
                        rlmPlayer.rank = player["rank"].int!
                        rlmPlayer.rating = player["rating"].int!
                        rlmPlayer.name = player["name"].string!
                        rlmPlayer.win = ((player["wins"].double! / player["games"].double!) * 100).rounded()
                        let dateString = player["last_match"].int!
                        let datetime = Date(timeIntervalSince1970: Double(dateString))
                        rlmPlayer.last_match = datetime
                        jsonIDs.append(player["profile_id"].int!)
                        if playerExists(rlmPlayer.id) != nil {
                            updatePlayer(rlmPlayer)
                        } else {
                            allPlayers.append(rlmPlayer)
                        }
                        i = i+1
                    }
                    if i == players.count {
                        addPlayers(allPlayers)
                        SwiftEventBus.post("playersWasDownloaded")
                    }
                    deleteNonExistingPlayers(jsonIDs)
                }
            }
        case .failure(let error):
            NSLog("\(error), \(String(describing: String(data: response.data!, encoding: String.Encoding.utf8)))")
            return
        }
    }
}

func downloadLastMatchToRealm(_ id: Int) {
    
    AF.request("https://aoe2.net/api/player/lastmatch?game=aoe2de&profile_id=\(id)", method: .get, encoding: JSONEncoding.default).validate().responseJSON { response in
        
        debugPrint(response)
        
        switch response.result {
        case .success:
            if let value = response.value {
                var jsonIDs: [Int] = []
                let json = JSON(value)
                let rlmMatch: realmMatch = realmMatch()
                rlmMatch.id = Int(json["last_match"]["match_id"].string!)!
                rlmMatch.name = json["last_match"]["name"].string!
                if let finished = json["last_match"]["finished"].int {
                    let datetime = Date(timeIntervalSince1970: Double(String(finished))!)
                    let currentDate = Date()
                    let formatter = DateFormatter()
                    formatter.timeZone = .current
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let dateString = formatter.string(from: currentDate)
                    let finalDate = formatter.date(from: dateString)!
                    let timeInSeconds = finalDate.timeIntervalSince(datetime)
                    rlmMatch.finished = "\(Int((timeInSeconds/60).rounded()))"
                } else {
                    rlmMatch.finished = "undefined"
                }
                rlmMatch.map = json["last_match"]["leaderboard_id"].int!
                jsonIDs.append(rlmMatch.id)
                if matchExists(rlmMatch.id) != nil {
                    updateMatch(rlmMatch)
                } else {
                    addMatch(rlmMatch)
                }
                var i = 0
                var allPlayers: [realmMatchPlayer] = [realmMatchPlayer]()
                if let players = json["last_match"]["players"].array {
                    var jsonIDs: [Int] = []
                    for player in players {
                        let rlmPlayer: realmMatchPlayer = realmMatchPlayer()
                        rlmPlayer.id = player["profile_id"].int!
                        if let name = player["name"].string {
                            rlmPlayer.name = name
                        } else {
                            rlmPlayer.name = "undefined"
                        }
                        rlmPlayer.civ = player["civ"].int!
                        if let won = player["won"].bool {
                            rlmPlayer.won = won
                        }
                        jsonIDs.append(player["profile_id"].int!)
                        if matchPlayerExists(rlmPlayer.id) != nil {
                            updateMatchPlayer(rlmPlayer)
                        } else {
                            allPlayers.append(rlmPlayer)
                        }
                        i = i+1
                    }
                    if i == players.count {
                        addMatchPlayers(allPlayers)
                        SwiftEventBus.post("matchWasDownloaded")
                    }
                    deleteNonExistingMatchPlayers(jsonIDs)
                }
            }
        case .failure(let error):
            NSLog("\(error), \(String(describing: String(data: response.data!, encoding: String.Encoding.utf8)))")
            return
        }
    }
}

func downloadStringToRealm(_ type: String, id: Int) {
    
    AF.request("https://aoe2.net/api/strings?game=aoe2de&language=en", method: .get, encoding: JSONEncoding.default).validate().responseJSON { response in
        
        debugPrint(response)
        
        switch response.result {
        case .success:
            if let value = response.value {
                let json = JSON(value)
                if type == "map" {
                    if let leaderboard = json["leaderboard"].array {
                        for item in leaderboard {
                            let itemID = item["id"].int!
                            if itemID == id {
                                let string = item["string"].string!
                                SwiftEventBus.post("stringWasDownloaded", sender: string)
                            }
                        }
                    }
                }
                if type == "civ" {
                    if let civilisation = json["civ"].array {
                        for item in civilisation {
                            let itemID = item["id"].int!
                            if itemID == id {
                                let string = item["string"].string!
                                SwiftEventBus.post("stringWasDownloaded", sender: string)
                            }
                        }
                    }
                }
            }
        case .failure(let error):
            NSLog("\(error), \(String(describing: String(data: response.data!, encoding: String.Encoding.utf8)))")
            return
        }
    }
}
