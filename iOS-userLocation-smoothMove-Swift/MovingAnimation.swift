//
//  MovingAnimation.swift
//  iOS-userLocation-smoothMove
//
//  Created by eidan on 17/1/16.
//  Copyright © 2017年 autonavi. All rights reserved.
//

import UIKit

class MovingAnimation: NSObject {
    
    var startLoc: CLLocation?
    
    var desLoc:  CLLocation?
    
    var duration: Double = 0
    
    var elapsedTime: Double = 0
    
    func reset () {
        self.duration = 0
        self.elapsedTime = 0
        self.startLoc = nil
        self.desLoc = nil
    }
    
    func isFinished() -> Bool {
        return self.elapsedTime >= self.duration
    }
    
    func step(time: Double) -> CLLocationCoordinate2D {
        
        self.elapsedTime = self.elapsedTime + time
        
        if self.elapsedTime >= self.duration || self.duration == 0 {
            return (self.desLoc?.coordinate)!
        }
        
        let rate: Double = self.elapsedTime / self.duration
        let deltaLat: Double = ((self.desLoc?.coordinate.latitude)! - (self.startLoc?.coordinate.latitude)!) * rate
        let deltaLng: Double = ((self.desLoc?.coordinate.longitude)! - (self.startLoc?.coordinate.longitude)!) * rate
        let coord: CLLocationCoordinate2D = CLLocationCoordinate2DMake((self.startLoc?.coordinate.latitude)! + deltaLat, (self.startLoc?.coordinate.longitude)! + deltaLng)
        return coord
        
    }

}
