//
//  ViewController.m
//  iOS-userLocation-smoothMove
//
//  Created by shaobin on 16/12/22.
//  Copyright © 2016年 autonavi. All rights reserved.
//

#import "ViewController.h"
#import <MAMapKit/MAMapKit.h>
#import "MovingAnimation.h"

@interface ViewController ()<MAMapViewDelegate>

@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) MAPointAnnotation *customUserAnnotation;
@property (nonatomic, strong) MovingAnimation *movingAnimation;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.customizeUserLocationAccuracyCircleRepresentation = YES;
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    
    self.customUserAnnotation = [[MAPointAnnotation alloc] init];
    self.movingAnimation = [[MovingAnimation alloc] init];
    
    self.mapView.zoomLevel = 16;
    
    [self initBtn];
    
}

- (void)dealloc {
    [self stopTimer];
}

- (void)initBtn {
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(10, 100, 120, 32)];
    button.backgroundColor = [UIColor whiteColor];
    button.layer.borderWidth = 1.0;
    button.titleLabel.font = [UIFont systemFontOfSize:12];
    button.layer.borderColor = [UIColor redColor].CGColor;
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button setTitle:@"showsUserlocation" forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(actionLocation) forControlEvents:UIControlEventTouchUpInside];
    
    [button sizeToFit];
    [self.view addSubview:button];
}

- (void)actionLocation {
    self.mapView.showsUserLocation = !self.mapView.showsUserLocation;
    
    if (!self.mapView.showsUserLocation) {
        [self.mapView removeAnnotation:self.customUserAnnotation];
    }
}

#pragma mark - MAMapViewDelegate

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation {
    if(!updatingLocation || !userLocation.location) {
        return;
    }
    
    if([self.mapView.annotations containsObject:self.customUserAnnotation]) {
        CLLocationCoordinate2D preCoord = self.customUserAnnotation.coordinate;
        CLLocationCoordinate2D curCoord = userLocation.location.coordinate;
        
        
        /********************************
         模拟定位飘了的情况，方便测试用的
         ********************************/
        static int simulatedCount = 0;
        if(simulatedCount < 10) {
            float delta = 0.001 + (float)(rand() % 100) / 100000;
            float delta2 = 0.001 + (float)(rand() % 100) / 100000;
            delta *= (rand() % 2 == 0 ? 1 : -1);
            delta2 *= (rand() % 2 == 0 ? 1 : -1);
            curCoord.latitude = preCoord.latitude + delta;
            curCoord.longitude = (float)preCoord.longitude + delta2;
            
            simulatedCount++;
        }
        
        CLLocation *prevLoc = [[CLLocation alloc] initWithLatitude:preCoord.latitude longitude:preCoord.longitude];
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:curCoord.latitude longitude:curCoord.longitude];
        
        CGPoint prevPoint = [self.mapView convertCoordinate:preCoord toPointToView:self.mapView];
        CGPoint curPoint = [self.mapView convertCoordinate:curCoord toPointToView:self.mapView];
        
        //超过两个像素才做动画
        if(fabs(curPoint.x - prevPoint.x) > 2 || fabs(curPoint.y - prevPoint.y) > 2) {
            [self addMovingAnnotationFrom:prevLoc toCoord:loc];
        } else {
            self.customUserAnnotation.coordinate = curCoord;
        }
    } else {
        [self.mapView addAnnotation:self.customUserAnnotation];
        self.customUserAnnotation.coordinate = userLocation.location.coordinate;
        self.mapView.centerCoordinate = userLocation.location.coordinate;
    }
}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay {
    if(overlay == self.mapView.userLocationAccuracyCircle) {
        return nil;
    }
    
    return nil;
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation {
    if([annotation isKindOfClass:[MAUserLocation class]]) {
        NSString *reuseId = @"defaultUserAnnotation";
        MAAnnotationView * v = [self.mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
        if(v) {
            return v;
        }
        MAAnnotationView *userLocationView = [[MAAnnotationView alloc] initWithAnnotation:self.customUserAnnotation reuseIdentifier:reuseId];
        userLocationView.frame = CGRectZero;
        return userLocationView;
    }
    
    if(annotation == self.customUserAnnotation) {
        NSString *reuseId = @"customUserAnnotation";
        MAAnnotationView * v = [self.mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
        if(v) {
            return v;
        }
        MAAnnotationView *userLocationView = [[MAAnnotationView alloc] initWithAnnotation:self.customUserAnnotation reuseIdentifier:reuseId];
        userLocationView.frame = CGRectMake(0, 0, 20, 20);
        userLocationView.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.8];
        userLocationView.layer.cornerRadius = userLocationView.bounds.size.width / 2;
        userLocationView.layer.masksToBounds = YES;
        userLocationView.layer.borderColor = [UIColor whiteColor].CGColor;
        userLocationView.layer.borderWidth = 2;
        return userLocationView;
    }
    
    return nil;
}

- (void)addMovingAnnotationFrom:(CLLocation* )startLoc toCoord:(CLLocation *)destLoc {
    [self.movingAnimation reset];
    self.movingAnimation.startLoc = startLoc;
    self.movingAnimation.destLoc = destLoc;
    
    
    CLLocationDistance distance = [self.movingAnimation.startLoc distanceFromLocation:self.movingAnimation.destLoc];
    const double movingSpeed = 200.0 * 1000 / (60*60); //200公里/小时
    double duration = distance / movingSpeed;
    self.movingAnimation.duration = duration;
    self.movingAnimation.duration = 0.25; //您也可以指定一个固定动画时长
    
    [self startTimer];
}

- (void)startTimer {
    if(self.timer) {
        return;
    }
    
    //取消自动降低帧率
    self.mapView.isAllowDecreaseFrame = NO;
    __weak typeof(self) weakSelf = self;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0/30 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [weakSelf onTimer:timer];
    }];
}

- (void)onTimer:(NSTimer *)timer {
    self.customUserAnnotation.coordinate = [self.movingAnimation step:timer.timeInterval];
//    self.mapView.centerCoordinate = self.customUserAnnotation.coordinate;
    
    if([self.movingAnimation isFinished]) {
        //恢复自动降低帧率
        self.mapView.isAllowDecreaseFrame = YES;
        [self stopTimer];
    }
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}

@end
