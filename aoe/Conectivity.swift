//
//  Conectivity.swift
//  aoe
//
//  Created by Tomáš Boros on 11/04/2022.
//

import Foundation
import Alamofire

class Connectivity {
    class var isConnectedToInternet:Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
