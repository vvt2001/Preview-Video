//
//  TimeIntervalExtension.swift
//  Preview Video
//
//  Created by Vũ Việt Thắng on 01/07/2022.
//

import Foundation

extension TimeInterval{
    func getTimeLabel() -> String{
        let minutes = Int(self / 60)
        let seconds = Int(self.truncatingRemainder(dividingBy: 60))
        let minutesLabel = String(minutes)
        var secondsLabel = String(seconds)
        if seconds < 10{
            secondsLabel = "0" + secondsLabel
        }
        let timeLabelString =  minutesLabel + ":" + secondsLabel
        return timeLabelString
    }
}
