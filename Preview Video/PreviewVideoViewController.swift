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
    @IBOutlet private weak var videoView: UIView!
    @IBOutlet private weak var topGradientView: UIView!
    @IBOutlet private weak var bottomGradientView: UIView!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var currentTimeLabel: UILabel!
    @IBOutlet private weak var totalDurationLabel: UILabel!
    @IBOutlet private weak var playAndPauseButton: UIButton!
    @IBOutlet private var tapRecognizer: UITapGestureRecognizer!
    
    var selectedVideoAsset: PHAsset!
    private var totalDuration: Int?
    private var currentTime: Int = 0
    private var isPlaying: Bool = true
    private var playerLayer = AVPlayerLayer()
    private var hideButtonWorkItem: DispatchWorkItem?
    
    @IBAction private func goBack(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
        playerLayer.removeFromSuperlayer()
    }
    
    @IBAction private func changeVideoTime(_ sender: UISlider){
        
    }
    
    @IBAction private func playAndPause(_ sender: UIButton){

    }
    
    private func hideButton(){
        UIView.transition(with: self.playAndPauseButton, duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.playAndPauseButton.isHidden = true
                          })
    }
    
    private func hideButtonWithSchedule() {
        hideButtonWorkItem = DispatchWorkItem {
            self.hideButton()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: hideButtonWorkItem!)
    }

    private func invalidateItem() {
        hideButtonWorkItem?.cancel()
    }
    
    @IBAction private func handleScreenTapGesture(_ sender: UITapGestureRecognizer){
        invalidateItem()
        UIView.transition(with: self.playAndPauseButton, duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.playAndPauseButton.isHidden = false
                          })
        hideButtonWithSchedule()
    }
    
    private func setupVideoView(){
        selectedVideoAsset?.getAVAsset(completionHandler: { asset in
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
        if selectedVideoAsset != nil{
            totalDurationLabel.text =  selectedVideoAsset.duration.getTimeLabel()
            totalDuration = Int(selectedVideoAsset!.duration)
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
