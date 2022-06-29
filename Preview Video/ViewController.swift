//
//  ViewController.swift
//  Preview Video
//
//  Created by Vũ Việt Thắng on 29/06/2022.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var videoSelectorView: UIView!
    @IBOutlet weak var selectVideoButton: UIButton!
    
    private func giveSelectorViewRoundEdges(){
        let path = UIBezierPath(roundedRect:videoSelectorView.bounds,
                                byRoundingCorners:[.topRight],
                                cornerRadii: CGSize(width: 30, height: 30))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        videoSelectorView.layer.mask = maskLayer
    }
    
    private func setupButton(){
        selectVideoButton.layer.cornerRadius = 0.45 * selectVideoButton.bounds.size.width
        selectVideoButton.layer.shadowRadius = 15
        selectVideoButton.layer.shadowOpacity = 0.7
        selectVideoButton.layer.shadowColor = selectVideoButton.backgroundColor?.cgColor
    }
    
    @IBAction private func showVideoPreview(_ sender: UIButton){
        let previewVideoViewController = PreviewVideoViewController()
        self.navigationController?.pushViewController(previewVideoViewController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        giveSelectorViewRoundEdges()
    }

}

