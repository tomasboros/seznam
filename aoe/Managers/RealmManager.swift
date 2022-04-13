//
//  RealmManager.swift
//  aoe
//
//  Created by Tomáš Boros on 11/04/2022.
//

import Foundation
import RealmSwift

class realmPlayer: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var rank: Int = 0
    @objc dynamic var rating: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var win: Double = 0.0
    @objc dynamic var last_match: Date = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class realmMatch: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var finished: String = ""
    @objc dynamic var map: Int = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class realmMatchPlayer: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var civ: Int = 0
    @objc dynamic var civilisation: String = ""
    @objc dynamic var won: Bool = false
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

let realm = try! Realm()

func playerExists(_ id: Int) -> realmPlayer? {
    let predicate = NSPredicate(format: "id = %i", id)
    let players = realm.objects(realmPlayer.self).filter(predicate)
    if players.count == 1 {
        return players[0]
    }
    return nil
}

func updatePlayer(_ player: realmPlayer) {
    try! realm.write {
        realm.add(player, update: .modified)
    }
}

func deletePlayer(_ player: realmPlayer) {
    try! realm.write {
        realm.delete(player)
    }
}

func deletePlayers() {
    let players = realm.objects(realmPlayer.self)
    for player in players {
        try! realm.write {
            realm.delete(player)
        }
    }
}

func removePlayer(_ player: realmPlayer) {
    deletePlayer(player)
}

func addPlayer(_ player: realmPlayer) {
    let tempPlayer = playerExists(player.id)
    if tempPlayer != nil {
    } else {
        try! realm.write {
            realm.add(player)
        }
    }
}

func addPlayers(_ players: [realmPlayer]) {
    try! realm.write {
        realm.add(players)
    }
}

func deleteNonExistingPlayers(_ jsonIDs: [Int]) {
    let players = realm.objects(realmPlayer.self)
    for player in players {
        if !jsonIDs.contains(player.id) {
            deletePlayer(player)
        }
    }
}

func loadPlayers() -> [realmPlayer] {
    var playersToReturn: [realmPlayer] = []
    let players = realm.objects(realmPlayer.self)
    for player in players {
        playersToReturn.append(player)
    }
    playersToReturn = playersToReturn.sorted (by: {$0.rating > $1.rating})
    return playersToReturn
}

func matchExists(_ id: Int) -> realmMatch? {
    let predicate = NSPredicate(format: "id = %i", id)
    let matches = realm.objects(realmMatch.self).filter(predicate)
    if matches.count == 1 {
        return matches[0]
    }
    return nil
}

func updateMatch(_ match: realmMatch) {
    try! realm.write {
        realm.add(match, update: .modified)
    }
}

func deleteMatch(_ match: realmMatch) {
    try! realm.write {
        realm.delete(match)
    }
}

func deleteMatches() {
    let matches = realm.objects(realmMatch.self)
    for match in matches {
        try! realm.write {
            realm.delete(match)
        }
    }
}

func removeMatch(_ match: realmMatch) {
    deleteMatch(match)
}

func addMatch(_ match: realmMatch) {
    let tempMatch = matchExists(match.id)
    if tempMatch != nil {
    } else {
        try! realm.write {
            realm.add(match)
        }
    }
}

func deleteNonExistingMatches(_ jsonIDs: [Int]) {
    let matches = realm.objects(realmMatch.self)
    for match in matches {
        if !jsonIDs.contains(match.id) {
            deleteMatch(match)
        }
    }
}

func loadMatch() -> realmMatch {
    var matchesToReturn: [realmMatch] = []
    let matches = realm.objects(realmMatch.self)
    for match in matches {
        matchesToReturn.append(match)
    }
    return matchesToReturn[0]
}

func matchPlayerExists(_ id: Int) -> realmMatchPlayer? {
    let predicate = NSPredicate(format: "id = %i", id)
    let players = realm.objects(realmMatchPlayer.self).filter(predicate)
    if players.count == 1 {
        return players[0]
    }
    return nil
}

func updateMatchPlayer(_ player: realmMatchPlayer) {
    try! realm.write {
        realm.add(player, update: .modified)
    }
}

func updateCivilisation(_ player: Int, civilisation: String) {
    try! realm.write {
        let players = realm.objects(realmMatchPlayer.self)
        var pl: realmMatchPlayer = realmMatchPlayer()
        for item in players {
            if item.id == player {
                pl = item
            }
        }
        pl.civilisation = civilisation
        realm.add(pl, update: .modified)
    }
}

func deleteMatchPlayer(_ player: realmMatchPlayer) {
    try! realm.write {
        realm.delete(player)
    }
}

func deleteMatchPlayers() {
    let players = realm.objects(realmMatchPlayer.self)
    for player in players {
        try! realm.write {
            realm.delete(player)
        }
    }
}

func removeMatchPlayer(_ player: realmMatchPlayer) {
    deleteMatchPlayer(player)
}

func addMatchPlayer(_ player: realmMatchPlayer) {
    let tempPlayer = matchPlayerExists(player.id)
    if tempPlayer != nil {
    } else {
        try! realm.write {
            realm.add(player)
        }
    }
}

func addMatchPlayers(_ players: [realmMatchPlayer]) {
    try! realm.write {
        realm.add(players)
    }
}

func deleteNonExistingMatchPlayers(_ jsonIDs: [Int]) {
    let players = realm.objects(realmMatchPlayer.self)
    for player in players {
        if !jsonIDs.contains(player.id) {
            deleteMatchPlayer(player)
        }
    }
}

func loadMatchPlayers() -> [realmMatchPlayer] {
    var playersToReturn: [realmMatchPlayer] = []
    let players = realm.objects(realmMatchPlayer.self)
    for player in players {
        playersToReturn.append(player)
    }
    playersToReturn = playersToReturn.sorted (by: {$0.id < $1.id})
    return playersToReturn
}

func removeLastMatch() {
    try! realm.write {
        realm.delete(realm.objects(realmMatch.self))
        realm.delete(realm.objects(realmMatchPlayer.self))
    }
}
