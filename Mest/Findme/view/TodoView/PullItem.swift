//
//  PullItem.swift
//  Findme
//
//  Created by yuhan yin on 6/23/18.
//  Copyright © 2018 mmoaay. All rights reserved.
//


import UIKit
class PullItem {
    
    unowned var view: UIView
    private var centerEnd: CGPoint
    private var centerStart: CGPoint
    
    init(view: UIView, centerEnd: CGPoint, parallaxRatio: CGFloat, sceneHeight: CGFloat) {
        self.view = view
        self.centerStart = CGPoint(x: centerEnd.x, y: centerEnd.y + (parallaxRatio * sceneHeight))
        self.centerEnd = centerEnd
        self.view.center = centerStart
        
        UIView.animate(withDuration: 10, delay: 0, options:[.curveEaseInOut, .repeat] , animations: {
            
            self.view.transform = CGAffineTransform(scaleX: 1.5, y: 1.5);
                //CGAffineTransform.identity.rotated(by: CGFloat(Double.pi/4))

            
        }) { (isFinished) in
            print("begin isFinished = ", isFinished)
        }
    }
    
    func updateViewPositionForProgress(progress: CGFloat) {
        view.center = CGPoint(
            x: centerStart.x + (centerEnd.x - centerStart.x) * progress,
            y: centerStart.y + (centerEnd.y - centerStart.y) * progress
        )
    }
}
