//
//  PHAssetExtension.swift
//  Preview Video
//
//  Created by Vũ Việt Thắng on 29/06/2022.
//

import Foundation
import Photos

extension PHAsset{
    func getAVAsset(completionHandler : @escaping ((_ asset : AVAsset?) -> Void)){
        if self.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                DispatchQueue.main.async {
                    completionHandler(asset)
                }
            })
        }
    }
}
