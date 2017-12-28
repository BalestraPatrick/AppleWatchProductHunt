//
//  InterfaceController.swift
//  AppleWatchProductHunt WatchKit Extension
//
//  Created by Patrick Balestra on 22/12/14.
//  Copyright (c) 2014 Patrick Balestra. All rights reserved.
//

import WatchKit

import Foundation

import Alamofire

import SwiftyJSON

class InterfaceController: WKInterfaceController {
    
    @IBOutlet weak var huntsTable: WKInterfaceTable!
    
    let CLIENT_ID_TOKEN = "" // Add your API Key here
    let CLIENT_SECRET_TOKEN = "" // Add your API Secret here

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if !CLIENT_ID_TOKEN.isEmpty && !CLIENT_SECRET_TOKEN.isEmpty {
            requestToken()
        }
        
    }
    
    @IBAction func reload() {
        if !CLIENT_ID_TOKEN.isEmpty && !CLIENT_SECRET_TOKEN.isEmpty {
            requestToken()
        }
    }
    
    func requestToken() {
        let parameters = [
            "client_id" : CLIENT_ID_TOKEN,
            "client_secret" : CLIENT_SECRET_TOKEN,
            "grant_type" : "client_credentials"];
        
        Alamofire.request("https://api.producthunt.com/v1/oauth/token", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { rep in
            let json = JSON(rep.result.value!)
            print(json["access_token"].stringValue)
            let token = json["access_token"].stringValue
            if !token.isEmpty {
                self.requestTodayHunts(token)
            }
        }
    }
    
    func requestTodayHunts(_ token: String) {
        
        let url = URL(string: "https://api.producthunt.com/v1/posts")
        let mutableURLRequest = NSMutableURLRequest(url: url!)
        mutableURLRequest.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        mutableURLRequest.setValue("api.producthunt.com", forHTTPHeaderField: "Host")
        
        let h: HTTPHeaders = [
            "Authorization": "Bearer " + token,
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Host": "api.producthunt.com"
        ]
        //let manager = Alamofire.Manager.sharedInstance
        Alamofire.request("https://api.producthunt.com/v1/posts", method: .get, parameters: [:], encoding: JSONEncoding.default, headers: h)
            .responseJSON { (rep) in
            if rep.response?.statusCode == 200 {
                let json = JSON(rep.result.value!)
                let hunts = json["posts"]
                print(hunts[0])
                self.loadHuntsTable(hunts)
            }
        }
    }
    
    func loadHuntsTable(_ hunts: JSON) {
        
        huntsTable.setNumberOfRows(hunts.count, withRowType: "Hunt")
        
        for (index, _) in hunts.enumerated() {
            let row = huntsTable.rowController(at: index) as! HuntTableRowController
            if let name = hunts[index]["name"].string {
                row.huntTitle.setText(name)
            }
            if let votesCount = hunts[index]["votes_count"].int {
                row.votesLabel.setText("\(votesCount) ▲")
            }
            if let tagline = hunts[index]["tagline"].string {
                row.taglineLabel.setText(tagline)
            }
        }
    }

    override func willActivate() {
        super.willActivate()
    }

    override func didDeactivate() {
        super.didDeactivate()
    }

}
