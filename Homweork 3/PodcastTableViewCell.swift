//
//  PodcastTableViewCell.swift
//  Homweork 3
//
//  Created by Rumit Singh Tuteja on 10/23/17.
//  Copyright © 2017 Rumit Singh Tuteja. All rights reserved.
//

import UIKit

class PodcastTableViewCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblAuthor: UILabel!
    @IBOutlet weak var lblCreatedDate: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnAddToPlaylist: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        btnPlay.layer.cornerRadius = 10.0
        btnAddToPlaylist.layer.cornerRadius = 10.0
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func populateCell(withPodcastItem item:PodcastItem) {
        self.lblTitle.text = item.strTitle
        self.lblAuthor.text = item.strAuthorName
        self.lblCreatedDate.text = item.strPubDate
        self.lblDuration.text = item.strItunesDuration
    }
    
}

