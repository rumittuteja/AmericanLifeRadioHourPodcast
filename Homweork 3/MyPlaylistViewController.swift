//
//  MyPlaylistViewController.swift
//  Homweork 3
//
//  Created by Rumit Singh Tuteja on 10/23/17.
//  Copyright © 2017 Rumit Singh Tuteja. All rights reserved.
//

import UIKit
import AVFoundation

class MyPlaylistViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    var audioPlayerQueue:AVQueuePlayer?
    var audioPlayer:AVPlayer?
    var isQueuePlaying:Bool! = false
    var currentPlayedBtn:UIButton?
    @IBOutlet weak var tableView: UITableView!
    var arrMyFavs:[PodcastItem]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName:"PodcastTableViewCell",bundle:nil), forCellReuseIdentifier: "podcastCell")
        self.tableView.estimatedRowHeight = 123
        // Do any additional setup after loading the view.
    }
    
    func createQueue(){
        var arrPlayerItems = [AVPlayerItem]()
        for item in self.arrMyFavs {
            let itemURL = URL(string:item.strMediaContent)
            let playerItem = AVPlayerItem(url: itemURL!)
            arrPlayerItems.append(playerItem)
        }
        self.audioPlayerQueue = AVQueuePlayer(items:arrPlayerItems)
    }

    
    @IBAction func btnPlayAll(_ sender: Any) {
        stopAudioPlayer()
        let btn = sender as! UIBarButtonItem
        if !self.isQueuePlaying! {
            btn.title = "Stop Playing"
            createQueue()
            self.audioPlayerQueue?.play()
            self.isQueuePlaying = true
        }else {
            btn.title = "Play All"
            self.isQueuePlaying = false
            self.audioPlayerQueue?.pause()
            self.audioPlayerQueue?.removeAllItems()
            self.audioPlayerQueue = nil
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrMyFavs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "podcastCell") as! PodcastTableViewCell
        let objPodcastItem = arrMyFavs[indexPath.row]
        cell.populateCell(withPodcastItem: objPodcastItem)
        cell.btnPlay.addTarget(self, action: #selector(btnPlay(sender:)), for: .touchUpInside)
        cell.btnPlay.tag = indexPath.row
        cell.btnAddToPlaylist.tag = indexPath.row
        cell.btnAddToPlaylist.addTarget(self, action: #selector(btnAddToPlaylist(sender:)), for: .touchUpInside)
        cell.btnAddToPlaylist.setTitle("Remove", for: .normal)
        cell.btnAddToPlaylist.backgroundColor = .red
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func btnAddToPlaylist(sender:Any){
        stopAudioPlayer()
        stopAudioPlayerQueue()
        let btn = sender as! UIButton
        self.arrMyFavs.remove(at: btn.tag)
        updateUserDefaults()
        self.tableView.reloadData()
        if self.arrMyFavs.count == 0 {
            self.perform(#selector(self.popViewController), on: .main, with: nil, waitUntilDone: true)
        }
    }
    
    func popViewController(){
        self.displayAlert(message: "You can re-create a playlist by adding items from the podcast list.", forViewController: self)
    }
    
    func displayAlert(message:String, forViewController viewController:UIViewController){
        let myAlert = UIAlertController(title:"No items left!", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title:"OK", style:.default, handler:{ action in
            self.navigationController?.popViewController(animated: true)
        })
        
        myAlert.addAction(okAction)
        viewController.present(myAlert, animated: true, completion: nil)
    }
    
    func updateUserDefaults(){
        var arrPersistentPlaylist = [[String:String]]();
        let userDefaults = UserDefaults()
        for objItem in self.arrMyFavs {
             let dict = ["strTitle":objItem.strTitle, "strPubDate":objItem.strPubDate, "strItunesDuration":objItem.strItunesDuration, "strMediaContent":objItem.strMediaContent,"strAuthorName":objItem.strAuthorName]
            arrPersistentPlaylist.append(dict as! [String : String])
        }
        userDefaults.set(arrPersistentPlaylist, forKey: "playlist")
    }
    
    
    func stopAudioPlayerQueue(){
        if self.isQueuePlaying! {
            self.audioPlayerQueue?.pause()
            self.audioPlayerQueue?.removeAllItems()
            self.audioPlayerQueue = nil
            self.isQueuePlaying = false
            self.navigationItem.rightBarButtonItem?.title = "Play All"
        }
    }
    func stopAudioPlayer(){
        if self.audioPlayer != nil {
            self.currentPlayedBtn?.setTitle("Play", for: .normal)
            self.audioPlayer?.pause()
            self.audioPlayer = nil
        }
    }
    
    func btnPlay(sender:Any){
        stopAudioPlayerQueue()
        let btn = sender as! UIButton
        if btn.title(for: .normal) == "Play" {
            let item = arrMyFavs[btn.tag]
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
            btn.setTitle("Stop", for: .normal)
            self.currentPlayedBtn = btn
        }else {
            btn.setTitle("Play", for: .normal)
            self.currentPlayedBtn = nil
            if self.audioPlayer != nil {
                self.audioPlayer!.pause()
                self.audioPlayer = nil
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAudioPlayer()
        stopAudioPlayerQueue()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
