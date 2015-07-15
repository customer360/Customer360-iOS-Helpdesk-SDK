//
//  LocationManager.m
//  InAppChat
//
//  Created by Anveshan Technologies on 21/04/15.
//
//

#import "LocationManager.h"
#import "XMPPStream.h"
#import "XMPPPing.h"
@interface LocationManager () <CLLocationManagerDelegate>
@end

@implementation LocationManager

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        LocationManager *instance = sharedInstance;
        instance.locationManager = [CLLocationManager new];
        instance.locationManager.delegate = instance;
//        instance.locationManager.
        instance.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer; // you can use kCLLocationAccuracyHundredMeters to get better battery life
        instance.locationManager.pausesLocationUpdatesAutomatically = NO;

    });
    
    return sharedInstance;
}

- (XMPPStream *)xmppStream {
    return [[Cus360Chat sharedInstance] xmppStream];
    //    return [[self appDelegate] xmppStream];
}

- (void)startUpdatingLocation
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if (status == kCLAuthorizationStatusDenied)
    {
        NSLog(@"Location services are disabled in settings.");
    }
    else
    {
        // for iOS 8
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
        {
            [self.locationManager requestAlwaysAuthorization];
        }
        
        [self.locationManager startUpdatingLocation];
        [_pingTimer invalidate];
        _pingTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(sendPing) userInfo:nil repeats:YES];
//        [_pingTimer fire];
//        [self.locationManager stopUpdatingLocation]
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    _pingTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(sendPing) userInfo:nil repeats:YES];
    [_pingTimer fire];
     CLLocation *mostRecentLocation = locations.lastObject;
    NSDate *now = [NSDate date];
    NSTimeInterval interval = self.lastTimestamp ? [now timeIntervalSinceDate:self.lastTimestamp] : 0.0;
    NSLog(@"Current location: %@ %@", @(mostRecentLocation.coordinate.latitude), @(mostRecentLocation.coordinate.longitude));
   if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
    {
        [_pingTimer invalidate];
        [manager stopUpdatingLocation];
        [_stopTimer invalidate];
        /* if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)])
        {
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound categories:nil]];
        }
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertAction = @"Ok";
        localNotification.alertBody = [NSString stringWithFormat:@"From: Prasad MORe(Sending current location to web service at time = %f ",interval];
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];/*/
        
    }
   else if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground){
       [manager startUpdatingLocation];
      //
     // _stopTimer=[NSTimer scheduledTimerWithTimeInterval:30.0*60.0 target:self selector:@selector(disconnect) userInfo:nil repeats:NO];
//       [_stopTimer fire];
}
    
       if (!self.lastTimestamp || interval >= 1.0)
    {
        self.lastTimestamp = now;
//        NSLog(@"Sending current location to web service at time = %f ",interval);
            // We are not active, so use a local notification instead
            //            [UIApplication ]
    }
    
//    [self.locationManager stopUpdatingLocation];
}

-(void)sendPing{
    if ([[[Cus360Chat sharedInstance]xmppStream ]isConnected])
    {
        XMPPPing *new = [[XMPPPing alloc] init];
        [new addDelegate:self delegateQueue:dispatch_get_main_queue()];
        NSString *toJID = [[NSUserDefaults standardUserDefaults] objectForKey:@"agent_jid"];
        [new activate:[self xmppStream]];
        [new sendPingToServer];
//        [new sendPingToJID:[XMPPJID jidWithString:toJID]];
    }

//    [[Cus360Chat sharedInstance] sendPing];
    
}

-(void)disconnect{

    [_stopTimer invalidate];
    [_pingTimer invalidate];
    [[Cus360Chat sharedInstance] disconnect];
    [self.locationManager stopUpdatingLocation];

}
@end