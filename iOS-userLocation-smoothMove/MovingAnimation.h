//
//  MovingAnimation.h
//  iOS-userLocation-smoothMove
//
//  Created by shaobin on 16/12/23.
//  Copyright © 2016年 autonavi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface MovingAnimation : NSObject

///起始点
@property (nonatomic, strong) CLLocation *startLoc;
///终点
@property (nonatomic, strong) CLLocation *destLoc;
///动画时长
@property (nonatomic, assign) double duration;
///elapsed
@property (nonatomic, assign) double elapsedTime;

- (void)reset;
///计算当前需要设置的经纬度坐标
- (CLLocationCoordinate2D)step:(double)time;
- (BOOL)isFinished;

@end
