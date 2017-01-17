//
//  ViewController.swift
//  iOS-userLocation-smoothMove-Swift
//
//  Created by eidan on 17/1/16.
//  Copyright © 2017年 autonavi. All rights reserved.
//

import UIKit

class ViewController: UIViewController,MAMapViewDelegate {
    
    var mapView: MAMapView!         //地图
    var customUserAnnotation: MAPointAnnotation!
    var movingAnimation: MovingAnimation!
    var timer: Timer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView = MAMapView(frame: CGRect(x: CGFloat(0), y: CGFloat(64), width: CGFloat(self.view.bounds.size.width), height: CGFloat(self.view.bounds.size.height - 64)))
        self.mapView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        self.mapView.delegate = self
        self.mapView.customizeUserLocationAccuracyCircleRepresentation = true
        self.mapView.zoomLevel = 16
        self.view.addSubview(self.mapView)
        self.view.sendSubview(toBack: self.mapView)
        
        self.customUserAnnotation = MAPointAnnotation.init()
        self.movingAnimation = MovingAnimation();
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func showUserLocation(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        self.mapView.showsUserLocation = !self.mapView.showsUserLocation
        if self.mapView.showsUserLocation == false {
            self.mapView.removeAnnotation(self.customUserAnnotation)
        }
    }
    
    func addMovingAnnotation(from startLoc: CLLocation, toCoord destLoc: CLLocation) {
        
        self.movingAnimation.reset()
        self.movingAnimation.startLoc = startLoc
        self.movingAnimation.desLoc = destLoc
        
        let distance: CLLocationDistance = (self.movingAnimation.startLoc?.distance(from: self.movingAnimation.desLoc!))!
        let movingSpeed: Double = 200.0 * 1000 / (60 * 60)  //200公里/小时
        let duration: Double = distance / movingSpeed
        self.movingAnimation.duration = duration
//        self.movingAnimation.duration = 0.25  //您也可以指定一个固定动画时长
        
        self.startTimer()
    }
    
    func startTimer() {
        
        if (self.timer != nil) {
            return
        }
        
        self.mapView.isAllowDecreaseFrame = false  //取消自动降低帧率
        self.timer = Timer.scheduledTimer(timeInterval: 1.0 / 30, target: self, selector: #selector(self.on(_:)), userInfo: nil, repeats: true)
    }
    
    func on(_ timer: Timer) {
        self.customUserAnnotation.coordinate = self.movingAnimation.step(time: timer.timeInterval)
        if self.movingAnimation.isFinished() {
            self.mapView.isAllowDecreaseFrame = true //恢复自动降低帧率
            self.stopTimer()
        }
    }
    
    func stopTimer() {
        self.timer.invalidate()
        self.timer = nil
    }
    
    
    // MARK: - MAMapViewDelegate
    
    func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
        
        if updatingLocation == false || userLocation.location == nil {
            return
        }
        
        let isContained = self.mapView.annotations.contains (where: { element in
            return element as? MAPointAnnotation == self.customUserAnnotation
        })
        
        if isContained {
            
            let preCoord: CLLocationCoordinate2D = self.customUserAnnotation.coordinate
            var curCoord: CLLocationCoordinate2D = userLocation.location.coordinate
            
            /********************************
             模拟定位飘了的情况，方便测试用的
             ********************************/
            var simulatedCount: Int = 0
            if simulatedCount < 10 {
                var delta = 0.001 + Double((arc4random() % 100) / 10000)
                var delta2 = 0.001 + Double((arc4random() % 100) / 10000)
                
                delta = delta * Double(arc4random() % 2 == 0 ? 1 : -1)
                delta2 = delta2 * Double(arc4random() % 2 == 0 ? 1 : -1)
                
                curCoord.latitude = preCoord.latitude + delta
                curCoord.longitude = preCoord.longitude + delta2
                
                simulatedCount = simulatedCount + 1
                
            }
            
            let prevLoc = CLLocation(latitude: preCoord.latitude, longitude: preCoord.longitude)
            let loc = CLLocation(latitude: curCoord.latitude, longitude: curCoord.longitude)
            let prevPoint: CGPoint = self.mapView.convert(preCoord, toPointTo: self.mapView)
            let curPoint: CGPoint = self.mapView.convert(curCoord, toPointTo: self.mapView)
            
            //超过两个像素才做动画
            if fabs(curPoint.x - prevPoint.x) > 2 || fabs(curPoint.y - prevPoint.y) > 2 {
                self.addMovingAnnotation(from: prevLoc, toCoord: loc)
            } else {
                self.customUserAnnotation.coordinate = curCoord
            }

        } else {
            self.mapView.addAnnotation(self.customUserAnnotation)
            self.customUserAnnotation.coordinate = userLocation.location.coordinate
            self.mapView.centerCoordinate = userLocation.location.coordinate
        }

    }
    
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        return nil
    }

    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        
        if annotation.isKind(of: MAUserLocation.self) {
            
            let pointReuseIndetifier = "defaultUserAnnotation"
            var annotationView: MAAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier)
            
            if annotationView == nil {
                annotationView = MAAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
                annotationView?.frame = CGRect.zero
                return annotationView
            }

        }
        
        if annotation.isKind(of: MAPointAnnotation.self) {
            
            let annotationTemp : MAPointAnnotation = annotation as! MAPointAnnotation
            
            if annotationTemp == self.customUserAnnotation {
                
                let pointReuseIndetifier = "customUserAnnotation"
                var userLocationView: MAAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier)
                
                if userLocationView == nil {
                    userLocationView = MAAnnotationView(annotation: self.customUserAnnotation, reuseIdentifier: pointReuseIndetifier)
                    userLocationView?.frame = CGRect.init(x: 0, y: 0, width: 20, height: 20)
                    userLocationView?.backgroundColor = UIColor.blue.withAlphaComponent(0.8)
                    userLocationView?.layer.cornerRadius = (userLocationView?.bounds.size.width)! / 2
                    userLocationView?.layer.masksToBounds = true
                    userLocationView?.layer.borderColor = UIColor.white.cgColor
                    userLocationView?.layer.borderWidth = 2
                    return userLocationView
                }
                
            }
            
        }
        
        return nil
    }

}

