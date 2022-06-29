//
//  PreviewVideoViewController.swift
//  Preview Video
//
//  Created by Vũ Việt Thắng on 29/06/2022.
//

import UIKit
import AVFoundation
import Photos

class PreviewVideoViewController: UIViewController {
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var topGradientView: UIView!
    @IBOutlet weak var bottomGradientView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var totalDurationLabel: UILabel!
    @IBOutlet weak var playAndPauseButton: UIButton!
    @IBOutlet var tapRecognizer: UITapGestureRecognizer!
    
    var videoPHAssets: [PHAsset]!
    private var currentAsset: PHAsset?
    private var totalDuration: Int?
    private var currentTime: Int = 0
    private var isPlaying: Bool = true
    private var playerLayer = AVPlayerLayer()
    private var hideButtonItem: DispatchWorkItem?
    
    @IBAction private func goBack(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
        playerLayer.removeFromSuperlayer()
    }
    
    @IBAction private func changeVideoTime(_ sender: UISlider){
        
    }
    
    @IBAction private func playAndPause(_ sender: UIButton){
        if isPlaying{
            isPlaying = false
            currentAsset?.getAVAsset(completionHandler: { asset in
                //setup player
                let playerItem = AVPlayerItem(asset: asset!)
                let currentVideoPlayer = AVPlayer(playerItem: playerItem)
                //play video
                currentVideoPlayer.pause()
            })
            playAndPauseButton.setImage(UIImage(named: "play"), for: .normal)
        }
        else{
            isPlaying = true
            currentAsset?.getAVAsset(completionHandler: { asset in
                //setup player
                let playerItem = AVPlayerItem(asset: asset!)
                let currentVideoPlayer = AVPlayer(playerItem: playerItem)
                //play video
                currentVideoPlayer.play()
            })
            playAndPauseButton.setImage(UIImage(named: "pause"), for: .normal)
        }
    }
    
    private func hideButton(){
        UIView.transition(with: self.playAndPauseButton, duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.playAndPauseButton.isHidden = true
                          })
    }
    
    private func hideButtonWithSchedule() {
        hideButtonItem = DispatchWorkItem {
            self.hideButton()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: hideButtonItem!)
    }

    private func invalidateItem() {
        hideButtonItem?.cancel()
    }
    
    @IBAction private func handleTap(_ sender: UITapGestureRecognizer){
        invalidateItem()
        UIView.transition(with: self.playAndPauseButton, duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.playAndPauseButton.isHidden = false
                          })
        hideButtonWithSchedule()
    }
    
    private func setupVideoView(){
        let randomVideoAssets = self.videoPHAssets.randomElement()
        currentAsset = randomVideoAssets
        currentAsset?.getAVAsset(completionHandler: { asset in
            //setup player
            let playerItem = AVPlayerItem(asset: asset!)
            let currentAsset = AVPlayer(playerItem: playerItem)
            self.playerLayer = AVPlayerLayer(player: currentAsset)
            
            //setup player layer layout
            self.playerLayer.frame = self.videoView.bounds
            self.playerLayer.videoGravity = .resizeAspectFill
            self.videoView.layer.insertSublayer(self.playerLayer, at: 0)
            
            //play video
            currentAsset.play()
        })
    }
    
    private func addBackgroundGradient(){
        let topGradient = CAGradientLayer()
        topGradient.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        topGradient.locations = [0.0, 1.0]
        topGradient.frame = topGradientView.bounds
        topGradientView.alpha = 0.4
        topGradientView.layer.insertSublayer(topGradient, at: 0)
        
        let bottomGradient = CAGradientLayer()
        bottomGradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        bottomGradient.locations = [0.0, 1.0]
        bottomGradient.frame = bottomGradientView.bounds
        bottomGradientView.alpha = 0.4
        bottomGradientView.layer.insertSublayer(bottomGradient, at: 0)
    }
    
    private func setVideoTimeLabel (){
        // get video's duration
        if currentAsset != nil{
            let minutes = Int(currentAsset!.duration / 60)
            let seconds = Int(currentAsset!.duration.truncatingRemainder(dividingBy: 60))
            let minutesLabel = String(minutes)
            var secondsLabel = String(seconds)
            if seconds < 10{
                secondsLabel = "0" + secondsLabel
            }
            totalDurationLabel.text =  minutesLabel + ":" + secondsLabel
            totalDuration = Int(currentAsset!.duration)
        }
        else{
            totalDurationLabel.text = ""
        }
    }
    
    private func setupPlayAndPauseButton(){
        playAndPauseButton.layer.cornerRadius = 0.46 * playAndPauseButton.frame.width
        hideButtonWithSchedule()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBackgroundGradient()
        setupPlayAndPauseButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupVideoView()
        setVideoTimeLabel()
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
