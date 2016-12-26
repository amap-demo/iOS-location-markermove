本工程为基于高德地图iOS SDK进行封装，实现实现定位点平滑移动。
## 前述 ##
- [高德官网申请Key](http://lbs.amap.com/dev/#/).
- 阅读[开发指南](http://lbs.amap.com/api/ios-sdk/summary/).
- 工程基于iOS 3D地图SDK实现

## 功能描述 ##
自定义一个userLocationView，实现定位点平滑移动

## 核心类/接口 ##
| 类    | 接口  | 说明   | 版本  |
| -----|:-----:|:-----:|:-----:|
| MAMapVIew	| - (void)mapView:(MAMapView *) didUpdateUserLocation:(MAUserLocation *) updatingLocation:(BOOL); | 定位回调，内部决定是否动画移动定位点 | v4.0.0 |

## 核心难点 ##
###根据两次定位点在屏幕显示上的像素差决定是否动画移动
```
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


```
