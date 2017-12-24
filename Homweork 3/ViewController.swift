//
//  ViewController.swift
//  Homweork 3
//
//  Created by Rumit Singh Tuteja on 10/22/17.
//  Copyright © 2017 Rumit Singh Tuteja. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, XMLParserDelegate, UITableViewDelegate, UITableViewDataSource {
    var audioPlayer:AVPlayer?
    var xmlParser = XMLParser()
    var objPodcastItem:PodcastItem!
    var strElementName:String!
    var arrElements:[PodcastItem]! = []
    var isParsingItem:Bool! = false
    var currentPlayedBtn:UIButton?
    var arrMyPlayList:[PodcastItem]! = []
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 123
        self.tableView.register(UINib(nibName:"PodcastTableViewCell",bundle:nil), forCellReuseIdentifier: "podcastCell")
        fetchData()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populateMyPlaylist()
        self.tableView.reloadData()
    }
    
    
    func fetchData(){
        let url:String="http://feed.thisamericanlife.org/talpodcast"
        let urlToSend: URL = URL(string: url)!
        // Parse the XML
        xmlParser = XMLParser(contentsOf: urlToSend)!
        xmlParser.delegate = self
        let success:Bool = xmlParser.parse()
        if success {
//            for item in arrElements {
//                print(item.strTitle)
//                print(item.strAuthorName)
//                print(item.strItunesDuration)
//                print(item.strPubDate)
//                print(item.strMediaContent)
//            }
            self.tableView.reloadData()
        } else {
            print("parse failure!")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let array = self.arrElements {
            return array.count
        }
        return 0
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "podcastCell") as! PodcastTableViewCell
        let podcastItem = arrElements[indexPath.row]
        cell.populateCell(withPodcastItem: podcastItem)
        cell.btnPlay.addTarget(self, action: #selector(btnPlay(sender:)), for: .touchUpInside)
        cell.btnPlay.tag = indexPath.row
        cell.btnAddToPlaylist.tag = indexPath.row
        cell.btnAddToPlaylist.addTarget(self, action: #selector(btnAddToPlaylist(sender:)), for: .touchUpInside)
        if inInMyPpaylist(objItem: podcastItem) {
            cell.btnAddToPlaylist.setTitle("Remove", for: .normal)
            cell.btnAddToPlaylist.backgroundColor = .red
        }else{
            cell.btnAddToPlaylist.setTitle("Add", for: .normal)
            cell.btnAddToPlaylist.backgroundColor = .blue
        }
        return cell
    }
    
    func inInMyPpaylist(objItem:PodcastItem) -> Bool{
        for item in self.arrMyPlayList {
            if item.strTitle == objItem.strTitle {
                return true
            }
        }
        return false
    }
    
    func btnAddToPlaylist(sender:Any){
        let btn = sender as! UIButton
        let objItem = arrElements[btn.tag]
        if btn.currentTitle == "Add" {
            self.arrMyPlayList.append(objItem)
            btn.setTitle("Remove", for: .normal)
            btn.backgroundColor = .red
            updateUserDefaults(withItem: objItem)
        }else{
            self.arrMyPlayList.remove(at: self.arrMyPlayList.index(of: objItem)!)
            btn.setTitle("Add", for: .normal)
            btn.backgroundColor = .blue
            updateUserDefaults()
        }
    }
    
    func updateUserDefaults(){
        var arrPersistentPlaylist = [[String:String]]();
        let userDefaults = UserDefaults()
        for objItem in self.arrMyPlayList {
            let dict = ["strTitle":objItem.strTitle, "strPubDate":objItem.strPubDate, "strItunesDuration":objItem.strItunesDuration, "strMediaContent":objItem.strMediaContent,"strAuthorName":objItem.strAuthorName]
            arrPersistentPlaylist.append(dict as! [String : String])
        }
        userDefaults.set(arrPersistentPlaylist, forKey: "playlist")
    }

    
    func populateMyPlaylist(){
        self.arrMyPlayList.removeAll()
        
        if let arrPersistentPlaylist = UserDefaults().value(forKey: "playlist") as? [[String:String]] {
            for dict in arrPersistentPlaylist {
                let objItem = PodcastItem()
                objItem.populateItem(withDict: dict)
                self.arrMyPlayList.append(objItem)
            }
        }
    }
    
    func updateUserDefaults(withItem objItem:PodcastItem!){
        let userdefaults = UserDefaults()
        let dict = ["strTitle":objItem.strTitle, "strPubDate":objItem.strPubDate, "strItunesDuration":objItem.strItunesDuration, "strMediaContent":objItem.strMediaContent,"strAuthorName":objItem.strAuthorName]
        if UserDefaults().value(forKey: "playlist") as? [[String:String]] != nil{
            var arrPersistentPlaylist = UserDefaults().value(forKey: "playlist") as! [[String:String]]
            arrPersistentPlaylist.append(dict as! [String : String])
            userdefaults.set(arrPersistentPlaylist, forKey: "playlist")
        }else{
            var arrPersistentPlaylist = [[String:String!]]()
            arrPersistentPlaylist.append(dict as! [String : String])
            userdefaults.set(arrPersistentPlaylist, forKey: "playlist")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.audioPlayer != nil {
            self.audioPlayer?.pause()
            self.audioPlayer = nil
            self.currentPlayedBtn?.setTitle("Play", for: .normal)
        }
    }
    
    func btnPlay(sender:Any){
        let btn = sender as! UIButton
        if btn.title(for: .normal) == "Play" {
            btn.setTitle("Stop", for: .normal)
            let item = arrElements[btn.tag]
            let itemURL = URL(string:item.strMediaContent)
            do {
                let playerItem = AVPlayerItem(url: itemURL!)
                self.audioPlayer = try AVPlayer(playerItem:playerItem)
                self.audioPlayer!.volume = 1.0
                self.audioPlayer!.play()
            } catch let error as NSError {
                self.audioPlayer = nil
                print(error.localizedDescription)
            } catch {
                print("AVAudioPlayer init failed")
            }
            currentPlayedBtn?.setTitle("Play", for: .normal)
            self.currentPlayedBtn = btn
        }else {
            btn.setTitle("Play", for: .normal)
            if self.audioPlayer != nil {
                self.audioPlayer!.pause()
                self.audioPlayer = nil
            }
        }
    }
    
    func btnStop(sender:Any){
        
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if elementName == "item" {
            isParsingItem = true
            objPodcastItem = PodcastItem()
            print("item started")
        }
        if isParsingItem == true && (elementName == "title" || elementName == "pubDate" || elementName == "guid" || elementName == "itunes:duration" || elementName == "itunes:author") {
            strElementName = elementName
        }
        
        if isParsingItem && elementName == "media:content" {
            objPodcastItem.strMediaContent = attributeDict["url"]
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        strElementName = ""
        if elementName == "item" {
            isParsingItem = false
            arrElements.append(objPodcastItem)
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if isParsingItem == true, let strName = strElementName{
            switch strName {
            case "title" :
                objPodcastItem.strTitle = string
                print(objPodcastItem.strTitle)
            case "pubDate" :
                objPodcastItem.strPubDate = string
                print(objPodcastItem.strPubDate)
            case "itunes:duration" :
                objPodcastItem.strItunesDuration = string
                print(objPodcastItem.strItunesDuration)
            case "itunes:author" :
                objPodcastItem.strAuthorName = string
                print(objPodcastItem.strAuthorName)
            case "guid" :
                objPodcastItem.strGuid = string
                print(objPodcastItem.strGuid)
            default:
                print("none of the stated")
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if self.arrMyPlayList.count > 0 {
            return true
        }else {
            displayAlert(message: "Currently there are no items in the playlist. You are Create a playlist by adding from the podcast items listed below.", forViewController: self)
            return false
        }
    }

    
     func displayAlert(message:String, forViewController viewController:UIViewController){
        let myAlert = UIAlertController(title:"Playlist empty!", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title:"OK", style:UIAlertActionStyle.default, handler:nil)
        myAlert.addAction(okAction)
        viewController.present(myAlert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! MyPlaylistViewController
        vc.arrMyFavs = self.arrMyPlayList
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        
    }



}

