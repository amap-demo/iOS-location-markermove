//
//  MovingAnimation.m
//  iOS-userLocation-smoothMove
//
//  Created by shaobin on 16/12/23.
//  Copyright © 2016年 autonavi. All rights reserved.
//

#import "MovingAnimation.h"

@implementation MovingAnimation

- (void)reset {
    self.duration = 0;
    self.elapsedTime = 0;
    self.startLoc = nil;
    self.destLoc = nil;
}

- (CLLocationCoordinate2D)step:(double)time {
    self.elapsedTime += time;
    
    if(self.elapsedTime >= self.duration || self.duration == 0) {
        return self.destLoc.coordinate;
    }
    
    double rate = self.elapsedTime / self.duration;
    double deltaLat = (self.destLoc.coordinate.latitude - self.startLoc.coordinate.latitude) * rate;
    double deltaLng = (self.destLoc.coordinate.longitude - self.startLoc.coordinate.longitude) * rate;
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(self.startLoc.coordinate.latitude + deltaLat, self.startLoc.coordinate.longitude + deltaLng);
    
    return coord;
}

- (BOOL)isFinished {
    return (self.elapsedTime >= self.duration);
}

@end
