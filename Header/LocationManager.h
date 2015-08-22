//
//  LocationManager.h
//  InAppChat
//
//  Created by Anveshan Technologies on 21/04/15.
//
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Cus360Chat.h"
@interface LocationManager : NSObject
@property(nonatomic,strong)NSTimer *pingTimer,*stopTimer;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSDate *lastTimestamp;

+ (instancetype)sharedInstance;
-(void)startUpdatingLocation;
@end
