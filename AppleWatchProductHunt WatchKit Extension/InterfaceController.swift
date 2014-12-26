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

class InterfaceController: WKInterfaceController {
    
    @IBOutlet weak var huntsTable: WKInterfaceTable!
    
    let CLIENT_ID_TOKEN = "" // Add your API Key here
    let CLIENT_SECRET_TOKEN = "" // Add your API Secret here

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        requestToken()
        
    }
    
    func requestToken() {
        let parameters = [
            "client_id" : CLIENT_ID_TOKEN,
            "client_secret" : CLIENT_SECRET_TOKEN,
            "grant_type" : "client_credentials"];
        
        Alamofire.request(.POST, "https://api.producthunt.com/v1/oauth/token", parameters: parameters).responseJSON {(request, response, JSON, error) in
            if (error == nil) {
                if let JSON = JSON as? NSDictionary {
                    let token = JSON["access_token"] as? NSString
                    self.requestTodayHunts(token!)
                }
            } else {
                println(error)
            }
        }
    }
    
    func requestTodayHunts(token: String) {
        
        let URL = NSURL(string: "https://api.producthunt.com/v1/posts")
        var mutableURLRequest = NSMutableURLRequest(URL: URL!)
        mutableURLRequest.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        mutableURLRequest.setValue("api.producthunt.com", forHTTPHeaderField: "Host")
        
        let manager = Alamofire.Manager.sharedInstance
        let request = manager.request(mutableURLRequest).responseJSON { (request, response, JSON, error) in
            if (error == nil) {
                if let JSON = JSON as? NSDictionary {
                    println(JSON)
                    let hunts = JSON["posts"] as? NSArray
                    self.loadHuntsTable(hunts!)
                }
            }
        }
    }
    
    func loadHuntsTable(hunts: NSArray) {
        
        huntsTable.setNumberOfRows(hunts.count, withRowType: "Hunt")
        
        for (index, hunt) in enumerate(hunts){
            let row = huntsTable.rowControllerAtIndex(index) as HuntTableRowController
            if let name = hunts[index]["name"] as? String {
                row.huntTitle.setText(name)
            }
            if let votesCount = hunts[index]["votes_count"] as? Int {
                row.votesLabel.setText("\(votesCount)")
            }
            if let tagline = hunts[index]["tagline"] as? String {
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
