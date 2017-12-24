//
//  PodcastItem.swift
//  Homweork 3
//
//  Created by Rumit Singh Tuteja on 10/22/17.
//  Copyright © 2017 Rumit Singh Tuteja. All rights reserved.
//

import UIKit

class PodcastItem: NSObject {
    var strTitle:String!
    var strLink:String?
    var strDesc:String?
    var strPubDate:String!
    var strCreator:String?
    var strGuid:String?
    var strEnclosure:String?
    var strItunesDuration:String!
    var strItunesSubtitle:String?
    var strMediaContent:String!
    var strAuthorName:String!
    var strSummary:String?
    var isInPlaylist:Bool!
    
    func populateItem(withDict dict:[String:String]) {
        strTitle = dict["strTitle"]
        strPubDate = dict["strPubDate"]
        strItunesDuration = dict["strItunesDuration"]
        strMediaContent = dict["strMediaContent"]
        strAuthorName = dict["strAuthorName"]
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let other = object as? PodcastItem {
            return self.strTitle == other.strTitle
        } else {
            return false
        }
    }
    
}
