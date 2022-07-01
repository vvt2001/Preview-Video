//
//  ViewController.swift
//  Preview Video
//
//  Created by Vũ Việt Thắng on 29/06/2022.
//

import UIKit
import Photos
import AVFoundation

class ViewController: UIViewController {
    @IBOutlet private weak var videoSelectorView: UIView!
    @IBOutlet private weak var selectVideoButton: UIButton!
    
    private var videoPHAssets = [PHAsset]()
    
    @IBAction private func showVideoPreview(_ sender: UIButton){
        let randomVideoAssets = self.videoPHAssets.randomElement()
        let previewVideoViewController = PreviewVideoViewController()
        previewVideoViewController.selectedVideoAsset = randomVideoAssets
        self.navigationController?.pushViewController(previewVideoViewController, animated: true)
    }
    
    private func giveSelectorViewRoundEdges(){
        let path = UIBezierPath(roundedRect:videoSelectorView.bounds,
                                byRoundingCorners:[.topRight],
                                cornerRadii: CGSize(width: 30, height: 30))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        videoSelectorView.layer.mask = maskLayer
    }
    
    private func setupButton(){
        selectVideoButton.layer.cornerRadius = 0.5 * selectVideoButton.bounds.size.width
        selectVideoButton.layer.shadowRadius = 15
        selectVideoButton.layer.shadowOpacity = 0.7
        selectVideoButton.layer.shadowColor = selectVideoButton.backgroundColor?.cgColor
    }
    
    private func loadAssetFromPhotos(){
        PHPhotoLibrary.requestAuthorization{ status in
            if status == .authorized {
                let videoAssets = PHAsset.fetchAssets(with: PHAssetMediaType.video, options: nil)
                videoAssets.enumerateObjects{ (object, _, _) in
                    self.videoPHAssets.append(object)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.isHidden = true
        setupButton()
        loadAssetFromPhotos()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        giveSelectorViewRoundEdges()
    }

}

