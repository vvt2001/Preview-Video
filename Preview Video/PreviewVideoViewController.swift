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
    @IBOutlet private weak var seekBarSlider: CustomSlider!
    @IBOutlet private var tapRecognizer: UITapGestureRecognizer!
    
    var videoPHAssets: [PHAsset]!
    private var currentAsset: PHAsset?
    private var totalDuration: Double = 0
    private var currentTime: Double = 0
    private var isPlaying: Bool = true
    private var playerLayer = AVPlayerLayer()
    private var player: AVPlayer?
    private var hideButtonItem: DispatchWorkItem?
    private var timeObserverToken: Any?

    @IBAction private func goBack(_ sender: UIButton){
        invalidateItem()
        removePeriodicTimeObserver()
        DispatchQueue.main.async {
            self.player!.pause()
            self.player = nil
            self.playerLayer.removeFromSuperlayer()
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func changeVideoTime(_ sender: UISlider){
        currentTime = totalDuration * Double(seekBarSlider.value/10000)
        currentTimeLabel.text = getTimeString(time: currentTime)
        player!.seek(to: CMTime(seconds: Double(currentTime), preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
    }
    
    @IBAction private func handleSliderPanGesture(_ sender: UIGestureRecognizer){
        switch sender.state{
        case .began, .changed:
            if isPlaying{
                player!.pause()
                playAndPauseButton.setImage(UIImage(named: "play"), for: .normal)
            }
            temporaryShowButton()
        case .ended:
            if isPlaying{
                player!.play()
                playAndPauseButton.setImage(UIImage(named: "pause"), for: .normal)
            }
        default:
            break
        }
    }
    
    private func changeButtonState(){
        let iconName = isPlaying ? "play" : "pause"
        playAndPauseButton.setImage(UIImage(named: iconName), for: .normal)
    }
    
    @IBAction private func playAndPause(_ sender: UIButton){
        if isPlaying{
            player!.pause()
        }
        else{
            player!.play()
        }
        changeButtonState()
        isPlaying = !isPlaying
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
    
    private func temporaryShowButton(){
        invalidateItem()
        UIView.transition(with: self.playAndPauseButton, duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.playAndPauseButton.isHidden = false
                          })
        hideButtonWithSchedule()
    }
    
    @IBAction private func handleTap(_ sender: UITapGestureRecognizer){
        temporaryShowButton()
    }
    
    private func setupVideoView(){
        let randomVideoAssets = self.videoPHAssets.randomElement()
        currentAsset = randomVideoAssets
        currentAsset?.getAVAsset(completionHandler: { asset in
            //setup player
            let playerItem = AVPlayerItem(asset: asset!)
            self.player = AVPlayer(playerItem: playerItem)
            self.playerLayer = AVPlayerLayer(player: self.player)
            
            //setup player layer layout
            self.playerLayer.frame = self.videoView.bounds
            self.playerLayer.videoGravity = .resizeAspectFill
            self.videoView.layer.insertSublayer(self.playerLayer, at: 0)
            
            self.addPeriodicTimeObserver()
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.videoDidEnded), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player!.currentItem)
            
            //play video
            self.player!.play()
        })
    }
    
    @objc private func videoDidEnded(){
        isPlaying = false
        playAndPauseButton.setImage(UIImage(named: "play"), for: .normal)
    }
    
    private func addPeriodicTimeObserver() {
        let time = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))

        timeObserverToken = player!.addPeriodicTimeObserver(forInterval: time, queue: .main, using: { time in
            let currentTime = time.seconds
            self.currentTime = currentTime
            self.seekBarSlider.value = Float(currentTime / self.totalDuration) * 10000
            self.currentTimeLabel.text = self.getTimeString(time: currentTime)
        })
    }
    
    private func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            player!.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
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
    
    private func setupPlayAndPauseButton(){
        playAndPauseButton.layer.cornerRadius = 0.46 * playAndPauseButton.frame.width
        hideButtonWithSchedule()
    }
    
    private func getTimeString(time: Double) -> String{
        let minutes = Int(time / 60)
        let seconds = Int(time.truncatingRemainder(dividingBy: 60))
        let minutesLabel = String(minutes)
        var secondsLabel = String(seconds)
        if seconds < 10{
            secondsLabel = "0" + secondsLabel
        }
        return minutesLabel + ":" + secondsLabel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBackgroundGradient()
        setupPlayAndPauseButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupVideoView()
        totalDuration = currentAsset!.duration
        totalDurationLabel.text = getTimeString(time: totalDuration)
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

// MARK: - UIGestureRecognizerDelegate
extension PreviewVideoViewController: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
}
