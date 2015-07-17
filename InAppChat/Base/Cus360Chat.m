//
//  Cus360Chat.m
//  Customer360SDK
//
//  Created by Customer360 on 02/12/14.
//  Copyright (c) 2014 Customer360. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <CoreData/CoreData.h>
#import "SVProgressHUD.h"
#import "AFNetworkReachabilityManager.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
//#import "Cus360Chat.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <sys/utsname.h>

#import "ChatViewController.h"
//#import "CusChatAppDelegate.h"
#import "XMPPRoster.h"
#import "XMPP.h"
#import "XMPPAutoPing.h"
#import "XMPPPing.h"
#import "XMPPIQ.h"
#import "XMPPFramework.h"
#import "Cus360Chat.h"
//#import "LocationTracker.h"
#import "LocationManager.h"
#import "ChatViewController.h"
//#import "CUSTicketDetailsViewController.h"
#import "HomerUtils.h"
//#import "CusAppDelegate.h"
#import "CUSApiHelperChat.h"
#import "ModelAccessTokenChat.h"

#import "PostChatViewController.h"
#import "PreChatViewController.h"

struct utsname systemInfo;

@interface Cus360Chat()<XMPPStreamDelegate,XMPPRosterDelegate,XMPPAutoPingDelegate,CLLocationManagerDelegate,UIAlertViewDelegate,NSURLSessionDelegate>

{
    //    XMPPStream *xmppStream;
    //    XMPPReconnect *xmppReconnect;
    //    XMPPRoster *xmppRoster;
    //
    NSString *password;
    BOOL isOpen;
    BOOL customCertEvaluation;
    BOOL isXmppConnected;
    ChatViewController *chatViewController;
    int times ;
    
    NSTimer* timerForSendLocationAfterFiveMin, *timer30SecConnection;
    //    CLLocationManager *locationManager;
}
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;
//@property LocationTracker * locationTracker;
@property (nonatomic, strong) NSTimer* locationUpdateTimer;
@property (nonatomic, strong) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong) XMPPRoster *xmppRoster;
@property (nonatomic, strong) XMPPRosterCoreDataStorage *xmppRosterStorage;
- (void)setupStream;
- (void)teardownStream;
- (void)goOnline;
- (void)goOffline;

@end

NSString * const cusConstStrKeyJID = @"jid";
NSString * const cusConstStrKeyPassword = @"password";
NSString * const cusConstStrKeyAccessTokenChat = @"AccessTokenChat";
NSString * const cusChatConstStrKeyAppApiKey = @"AppApiKey";
NSString * const cusConstStrKeyUserEmailId = @"UserEmailId";
NSString * const cusConstStrKeyDeveloperEmailId = @"DevelpoerEmailId";
NSString * const cusConstStrKeyUserName = @"UserName";
NSString * const cusConstStrKeyFeedback = @"UserFeedback";
NSString * const cusConstStrKeyNavBarGradientColorFirst = @"FirstGradient";
NSString * const cusConstStrKeyNavBarGradientColorSecond = @"SecondGradient";

NSString * const cusConstStrKeyGCMRegId = @"GCMRegId";
NSString * const cusChatConstStrKeyUserSenderId = @"SenderId";
//NSString * const cusConstStrKeyChatUrl = @"ChatUrl";

NSString * const cusChatConstStrKeyHasAccesTokenBeenChanged = @"HasAccessTokenBeenChanged";
//NSString * const cusConstStrKeyNotificationsEnabled = @"NotificationsEnabled";
NSString * const cusChatConstStrKeyNavbarColor = @"NavigationbarColor";
NSString * const cusChatConstStrKeyNavBarTitleColor = @"TitleColor";
NSString * const cusConstStrKeyWaitingScreenImageName = @"WaitingScreen";
NSString * const cusConstStrKeyPreChatOnlineMessage = @"OnlineMessage";
NSString * const cusConstStrKeyPreChatOfflineMessage = @"OfflineMessage";
NSString * const cusConstStrKeyPreChatHeaderMsgBackgroundColor = @"OfflineColor";

NSString * const cusConstStrKeyEnvironmentType= @"cusConstStrKeyEnvironmentType";
NSString * const cusChatConstStrValueEnvironmentTypeLIVE= @"cusConstStrValueEnvironmentTypeLIVE";
NSString * const cusChatConstStrValueEnvironmentTypeTEST= @"cusChatConstStrValueEnvironmentTypeTEST";
NSString * const mStrKeyEnableAutoFormSubmit= @"NO";


@implementation Cus360Chat
#pragma mark - Get IP address of device (required for params)
@synthesize xmppStream;
@synthesize xmppReconnect;
@synthesize xmppRoster;
@synthesize xmppRosterStorage;

- (NSString *)getIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}


#pragma mark - Singleton methods
/**
 * Singleton methods
 */
+(Cus360Chat*)sharedInstance {
    static Cus360Chat *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[self alloc] init];
        
    });
    
    return sharedInstance;
}

-(ModelAccessTokenChat*)getAccessTokenChat{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableString * JSonModelAccesstoken = [defaults objectForKey:cusConstStrKeyAccessTokenChat];
    if([HomerUtils stringIsEmpty:JSonModelAccesstoken])
    {
        JSonModelAccesstoken =@"{id:"",access_token:""}".mutableCopy;
    }
    cusMAccessTokenChat = [[ModelAccessTokenChat alloc] initFromJsonString:JSonModelAccesstoken];
    
    if ([HomerUtils stringIsEmpty:cusMAccessTokenChat.cusNsstrAccessToken]) {
        cusMAccessTokenChat = [[ModelAccessTokenChat alloc] init];
    }
    
    return cusMAccessTokenChat;
};

-(void) setAccessTokenChat:(ModelAccessTokenChat *)mInput{
    NSUserDefaults *mNsudDefaults = [NSUserDefaults standardUserDefaults];
    [mNsudDefaults setObject:mInput.toString forKey:cusConstStrKeyAccessTokenChat];
    [mNsudDefaults synchronize];
    
    cusMAccessTokenChat.cusNsstrAccessToken = nil;
    [self getAccessTokenChat];
};

-(NSString*)getAppApiKey{
    
    if([HomerUtils stringIsEmpty:cusStrAppApiKeyChat])
    {
        NSUserDefaults *mNsudDefaults = [NSUserDefaults standardUserDefaults];
        cusStrAppApiKeyChat =[mNsudDefaults objectForKey:cusChatConstStrKeyAppApiKey];
    }
    return cusStrAppApiKeyChat;
};

-(void) setAppApiKey:(NSString*) mInput{
    
    NSUserDefaults *mNsudDefaults = [NSUserDefaults standardUserDefaults];
    [mNsudDefaults setObject:mInput forKey:cusChatConstStrKeyAppApiKey];
    [mNsudDefaults synchronize];
    
    cusStrAppApiKeyChat = nil;
    [self getAppApiKey];
    
};

-(NSString*)getNavigationBarColor{
    
    if([HomerUtils stringIsEmpty:cusNavigationBarTintColor]){
        
        NSUserDefaults *mNsudDefaults = [NSUserDefaults standardUserDefaults];
        cusNavigationBarTintColor =[mNsudDefaults objectForKey:cusChatConstStrKeyNavbarColor];
    }
    return cusNavigationBarTintColor;
};

-(void) setNavigationBarColor:(NSString *)mInput
{
    NSUserDefaults *mNsudDefaults = [NSUserDefaults standardUserDefaults];
    [mNsudDefaults setObject:mInput forKey:cusChatConstStrKeyNavbarColor];
    [mNsudDefaults synchronize];
    cusNavigationBarTintColor = nil;
    [self getNavigationBarColor];
};


-(NSString*) getNavigationBarTitleColor{
    
    if([HomerUtils stringIsEmpty:cusNavigationBarTitleColor]){
        
        NSUserDefaults *mNsudDefaults = [NSUserDefaults standardUserDefaults];
        cusNavigationBarTitleColor =[mNsudDefaults objectForKey:cusChatConstStrKeyNavBarTitleColor];
    }
    return cusNavigationBarTitleColor;
}
-(void) setNavigationBarTitleColor:(NSString*) mInput{
    
    NSUserDefaults *mNsudDefaults = [NSUserDefaults standardUserDefaults];
    [mNsudDefaults setObject:mInput forKey:cusChatConstStrKeyNavBarTitleColor];
    [mNsudDefaults synchronize];
    cusNavigationBarTitleColor = nil;
    [self getNavigationBarColor];
}

/*
 -(NSString*) getChatUrl{
 if([HomerUtils stringIsEmpty:cusStrChatUrl]) {
 
 NSUserDefaults *mNsudDefaults = [NSUserDefaults standardUserDefaults];
 cusStrChatUrl = [mNsudDefaults objectForKey:cusConstStrKeyChatUrl];
 
 }
 return cusStrChatUrl;
 };
 -(void) setChatUrl:(NSString*) mInput
 {
 NSUserDefaults *mNsudDefaults = [NSUserDefaults standardUserDefaults];
 [mNsudDefaults setObject:mInput forKey:cusConstStrKeyChatUrl];
 [mNsudDefaults synchronize];
 cusStrChatUrl = nil;
 [self getChatUrl];
 };
 */
-(NSString*) getGCMRegId{
    
    if([HomerUtils stringIsEmpty:cusChatStrGCMRegId])
    {
        NSUserDefaults *mNsudDefaults = [NSUserDefaults standardUserDefaults];
        cusChatStrGCMRegId = [mNsudDefaults objectForKey:cusConstStrKeyGCMRegId];
    }
    NSLog(@"GCMRegId==%@",cusChatStrGCMRegId);
    return cusChatStrGCMRegId;
};
-(void) setGCMRegId:(NSString*) mInput{
    NSString *str = @"";
    
    str = [mInput stringByReplacingOccurrencesOfString:@"<"
                                            withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@">"
                                         withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@" "
                                         withString:@""];
    str= [str stringByTrimmingCharactersInSet:
          [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSUserDefaults *mNsudDefaults = [NSUserDefaults standardUserDefaults];
    [mNsudDefaults setObject:str forKey:cusConstStrKeyGCMRegId];
    [mNsudDefaults synchronize];
    cusChatStrGCMRegId = nil;
    
    [self getGCMRegId];
};


-(NSString*) getUserEmailId{
    if([HomerUtils stringIsEmpty:cusStrEmaiId]){
        NSUserDefaults *mNsudDefaults = [NSUserDefaults standardUserDefaults];
        cusStrEmaiId =[mNsudDefaults objectForKey:cusConstStrKeyUserEmailId];
    }
    
    return cusStrEmaiId;
};
-(void) setUserEmailId:(NSString*) mInput{
    
    NSUserDefaults *mNsudDefaults = [NSUserDefaults standardUserDefaults];
    [mNsudDefaults setObject:mInput forKey:cusConstStrKeyUserEmailId];
    [mNsudDefaults synchronize];
    
    cusStrEmaiId = nil;
    [self getUserEmailId];
};

//Gradient
-(NSString*) getGradientColorFirst{
    if([HomerUtils stringIsEmpty:cusStrGradientColorFirst]){
        NSUserDefaults *mNsudDefaults = [NSUserDefaults standardUserDefaults];
        cusStrGradientColorFirst =[mNsudDefaults objectForKey:cusConstStrKeyNavBarGradientColorFirst];
    }
    
    return cusStrGradientColorFirst;
};
-(void) setGradientColorFirst:(NSString*) mInput{
    
    NSUserDefaults *mNsudDefaults = [NSUserDefaults standardUserDefaults];
    [mNsudDefaults setObject:mInput forKey:cusConstStrKeyNavBarGradientColorFirst];
    [mNsudDefaults synchronize];
    
    cusStrGradientColorFirst = nil;
    [self getGradientColorFirst];
};

-(NSString*) getGradientColorSecond{
    if([HomerUtils stringIsEmpty:cusStrGradientColorSecond]){
        NSUserDefaults *mNsudDefaults = [NSUserDefaults standardUserDefaults];
        cusStrGradientColorSecond =[mNsudDefaults objectForKey:cusConstStrKeyNavBarGradientColorSecond];
    }
    
    return cusStrGradientColorSecond;
};
-(void) setGradientColorSecond:(NSString*) mInput{
    
    NSUserDefaults *mNsudDefaults = [NSUserDefaults standardUserDefaults];
    [mNsudDefaults setObject:mInput forKey:cusConstStrKeyNavBarGradientColorSecond];
    [mNsudDefaults synchronize];
    
    cusStrGradientColorSecond = nil;
    [self getGradientColorSecond];
};
//
-(NSString*) getPreChatOfflineMsgBackgroundColor{
    if([HomerUtils stringIsEmpty:cusStrPreChatBackgroundColor]){
        NSUserDefaults *mNsudDefaults = [NSUserDefaults standardUserDefaults];
        cusStrPreChatBackgroundColor =[mNsudDefaults objectForKey:cusConstStrKeyPreChatHeaderMsgBackgroundColor];
    }
    
    return cusStrPreChatBackgroundColor;
};
-(void) setPreChatOfflineMsgBackgroundColor:(NSString*) mInput{
    
    NSUserDefaults *mNsudDefaults = [NSUserDefaults standardUserDefaults];
    [mNsudDefaults setObject:mInput forKey:cusConstStrKeyPreChatHeaderMsgBackgroundColor];
    [mNsudDefaults synchronize];
    
    cusStrPreChatBackgroundColor = nil;
    [self getPreChatOfflineMsgBackgroundColor];
};

-(NSString*) getSenderId{
    
    if([HomerUtils stringIsEmpty:cusStrSenderId]){
        NSUserDefaults *mNsudDefaults = [NSUserDefaults standardUserDefaults];
        cusStrSenderId =[mNsudDefaults objectForKey:cusChatConstStrKeyUserSenderId];
    }
    
    return cusStrSenderId;
};
-(void) setSenderId:(NSString*) mInput{
    
    NSUserDefaults *mNsudDefaults = [NSUserDefaults standardUserDefaults];
    [mNsudDefaults setObject:mInput forKey:cusChatConstStrKeyUserSenderId];
    [mNsudDefaults synchronize];
    
    cusStrSenderId = nil;
    [self getSenderId];
};
/*
 -(bool) getNotificationsEnabled{
 if(cusNsnumNotificationsEnabled == nil)
 {
 NSUserDefaults *mNsudDefaults = [NSUserDefaults standardUserDefaults];
 cusNsnumNotificationsEnabled =[mNsudDefaults objectForKey:cusConstStrKeyNotificationsEnabled];
 }
 
 return [cusNsnumNotificationsEnabled boolValue];
 };
 
 
 -(void) setNotificationsEnabled:(bool) mInput{
 
 NSUserDefaults *mNsudDefaults = [NSUserDefaults standardUserDefaults];
 [mNsudDefaults setObject:[NSNumber numberWithBool:mInput] forKey:cusConstStrKeyNotificationsEnabled];
 [mNsudDefaults synchronize];
 
 cusNsnumNotificationsEnabled = nil;
 [self getNotificationsEnabled];
 };*/


-(bool) getHasAccessTokenBeenChanged{
    if(cusNsnumHasAccessTokenBeenChanged == nil){
        NSUserDefaults *mNsudDefaults = [NSUserDefaults standardUserDefaults];
        cusNsnumHasAccessTokenBeenChanged =[mNsudDefaults objectForKey:cusChatConstStrKeyHasAccesTokenBeenChanged];
    }
    
    return [cusNsnumHasAccessTokenBeenChanged boolValue];
};
-(void) setHasAccessTokenBeenChanged:(bool) mInput{
    
    NSUserDefaults *mNsudDefaults = [NSUserDefaults standardUserDefaults];
    [mNsudDefaults setObject:[NSNumber numberWithBool:mInput] forKey:cusChatConstStrKeyHasAccesTokenBeenChanged];
    [mNsudDefaults synchronize];
    
    cusNsnumHasAccessTokenBeenChanged = nil;
    [self getHasAccessTokenBeenChanged];
    
};

-(NSString*) getEnvironmentType{
    if([HomerUtils stringIsEmpty:cusStrEnvironmentType]){
        NSUserDefaults *mNsudDefaults = [NSUserDefaults standardUserDefaults];
        cusStrEnvironmentType =[mNsudDefaults objectForKey:cusConstStrKeyEnvironmentType];
    }
    
    return cusStrEnvironmentType;
};
-(void) setEnvironmentType:(NSString*) mInput
{
    if(![mInput isEqualToString:cusChatConstStrValueEnvironmentTypeLIVE]&&![mInput isEqualToString:cusChatConstStrValueEnvironmentTypeTEST]){
        
        NSLog(@"The Environment Type can have oly one of the two Values..");
        NSLog(@"EnvironmentType can either be  cusConstStrValueEnvironmentTypeLIVE ");
        NSLog(@"OR ..EnvironmentType can  be  cusConstStrValueEnvironmentTypeTEST ");
        NSLog(@"Since the value usupplied which was %@ doesn't match any of the above values hence setting the value to default which is cusConstStrValueEnvironmentTypeLIVE",mInput);
        mInput = cusChatConstStrValueEnvironmentTypeLIVE;
    }
    NSUserDefaults *mNsudDefaults = [NSUserDefaults standardUserDefaults];
    [mNsudDefaults setObject:mInput forKey:cusConstStrKeyEnvironmentType];
    [mNsudDefaults synchronize];
    
    cusStrEnvironmentType = nil;
    [self getEnvironmentType];
};
/*
 -(NSString *)getTypeOfToken{
 
 if([HomerUtils stringIsEmpty:cusStrTypeOfToken]){
 NSUserDefaults *mNsudDefaults = [NSUserDefaults standardUserDefaults];
 cusStrTypeOfToken =[mNsudDefaults objectForKey:cusConstStrKeyTypeOfTokenUsed];
 }
 
 return cusStrTypeOfToken;
 
 }
 -(void) setTypeOfToken:(NSString *)mInput
 {
 NSUserDefaults *mNsudDefaults = [NSUserDefaults standardUserDefaults];
 [mNsudDefaults setObject:mInput forKey:cusConstStrKeyTypeOfTokenUsed];
 [mNsudDefaults synchronize];
 
 cusStrTypeOfToken = nil;
 [self getTypeOfToken];
 };
 
 
 */
#pragma mark -other  fucntionality


-(bool)checkIfAccessTokenHasBeenVerified{
    
    NSLog(@"CHECKING IF ACCESS TOKEN ALREADY VERIFIED");
    ModelAccessTokenChat * mTempCusAccessToken  = [[Cus360Chat sharedInstance] getAccessTokenChat] ;
    
    if(![HomerUtils stringIsEmpty:[[Cus360Chat sharedInstance] getAppApiKey]]
       &&![HomerUtils stringIsEmpty:[[Cus360Chat sharedInstance] getSenderId]]
       &&![HomerUtils stringIsEmpty:mTempCusAccessToken.cusNsstrAccessToken]
       &&![[Cus360Chat sharedInstance] getHasAccessTokenBeenChanged]){
        NSLog(@"::::::::ACCESS TOKEN VERIFIED CORRECTLY:::::::::");
        return YES;
    }
    NSLog(@"CHECKING IF ACCESS TOKEN NOT YET VERIFIED CORRECTLY");
    return NO;
};

#pragma mark-   Install Functionality

- (void)install:(NSString*) cusStrArgApiToken {
    
    
    [[Cus360Chat sharedInstance] install:cusStrArgApiToken withOptions:nil];
};

- (void)install:(NSString*)cusStrArgApiToken withOptions:(NSMutableDictionary*) mNsmdOptions
{
    //    LocationManager *new = [LocationManager sharedInstance];
    //    [[LocationManager sharedInstance] startUpdatingLocation];
    
    [AFNetworkReachabilityManager managerForDomain:@"www.google.com"];
    [[AFNetworkReachabilityManager sharedManager]startMonitoring];
    
    if([[[Cus360Chat sharedInstance] getAppApiKey] isEqualToString:cusStrArgApiToken] ) {
        
        [[Cus360Chat sharedInstance] setHasAccessTokenBeenChanged:NO];
    }  else{
        [[Cus360Chat sharedInstance] setHasAccessTokenBeenChanged:YES];
    }
    
    [[Cus360Chat sharedInstance] setAppApiKey:cusStrArgApiToken];
    [[Cus360Chat sharedInstance] setEnvironmentType:cusChatConstStrValueEnvironmentTypeLIVE];
    
    
    if(mNsmdOptions!=nil && [[mNsmdOptions allKeys] count]>0){
        if([mNsmdOptions objectForKey:cusConstStrKeyEnvironmentType]!=nil)
        {
            NSString *cusNsstrTempEnvironmentType = (NSString *)[mNsmdOptions objectForKey:cusConstStrKeyEnvironmentType];
            
            if(![[[Cus360Chat sharedInstance] getEnvironmentType] isEqualToString:cusNsstrTempEnvironmentType]){
                
                [[Cus360Chat sharedInstance] setEnvironmentType:cusNsstrTempEnvironmentType];
                [[Cus360Chat sharedInstance] setHasAccessTokenBeenChanged:YES];
            }
        }
        if ([mNsmdOptions objectForKey:cusChatConstStrKeyNavbarColor]!=nil)
        {
            NSString *cusNsstrTempNavigationBarTintColor = (NSString *)[mNsmdOptions objectForKey:cusChatConstStrKeyNavbarColor];
            
            [[Cus360Chat sharedInstance]setNavigationBarColor:cusNsstrTempNavigationBarTintColor];
        }
        else{
            [[Cus360Chat sharedInstance]setNavigationBarColor:@"#f8f8f8"];
        }
        
        if ([mNsmdOptions objectForKey:cusConstStrKeyNavBarGradientColorFirst]!=nil)
        {
            NSString *gradientOne = (NSString *)[mNsmdOptions objectForKey:cusConstStrKeyNavBarGradientColorFirst];
            [[Cus360Chat sharedInstance] setGradientColorFirst:gradientOne];
            
            NSString *gradientTwo = (NSString *)[mNsmdOptions objectForKey:cusConstStrKeyNavBarGradientColorSecond];
            [[Cus360Chat sharedInstance] setGradientColorSecond:gradientTwo];
        }
        else{
            [[Cus360Chat sharedInstance] setGradientColorFirst:@"#f8f8f8"];
            [[Cus360Chat sharedInstance] setGradientColorSecond:@"#f8f8f8"];
        }
        
        if ([mNsmdOptions objectForKey:cusChatConstStrKeyNavBarTitleColor]!=nil)
        {
            NSString *cusNsstrTempNavigationBarTitleColor = (NSString *)[mNsmdOptions objectForKey:cusChatConstStrKeyNavBarTitleColor];
            
            [[Cus360Chat sharedInstance]setNavigationBarTitleColor:cusNsstrTempNavigationBarTitleColor];
        }
        else{
            [[Cus360Chat sharedInstance]setNavigationBarTitleColor:@"#000000"];
        }
        
        if ([mNsmdOptions objectForKey:cusConstStrKeyDeveloperEmailId]!=nil)
        {
            NSString *cusNsstrTempEmailID = (NSString *)[mNsmdOptions objectForKey:cusConstStrKeyDeveloperEmailId];
            _cusStrDeveloperEmaiId = cusNsstrTempEmailID;
            [[Cus360Chat sharedInstance] setUserEmailId:cusNsstrTempEmailID];
        }
        
        if ([mNsmdOptions objectForKey:cusConstStrKeyUserName]!=nil)
        {
            NSString *cusNsstrTempUserName = (NSString *)[mNsmdOptions objectForKey:cusConstStrKeyUserName];
            _cusStrUserName = cusNsstrTempUserName;
        }
        if ([mNsmdOptions objectForKey:cusConstStrKeyFeedback]!=nil)
        {
            NSString *cusNsstrTempUserFeedback = (NSString *)[mNsmdOptions objectForKey:cusConstStrKeyFeedback];
            _cusStrUserFeedback = cusNsstrTempUserFeedback;
        }
        if ([mNsmdOptions objectForKey:cusConstStrKeyWaitingScreenImageName]!=nil)
        {
            NSString *waitingScreenImage = (NSString *)[mNsmdOptions objectForKey:cusConstStrKeyWaitingScreenImageName];
            _cusStrWaitingScreenImageName = waitingScreenImage;
        }
        if ([mNsmdOptions objectForKey:cusConstStrKeyPreChatOnlineMessage]!=nil) {
            NSString *preChatOfflineMessage = (NSString *)[mNsmdOptions objectForKey:cusConstStrKeyPreChatOnlineMessage];
            _cusStrPreChatOnlineMessage = preChatOfflineMessage;
        }
        if ([mNsmdOptions objectForKey:cusConstStrKeyPreChatOfflineMessage]!=nil) {
            NSString *preChatOfflineMessage = (NSString *)[mNsmdOptions objectForKey:cusConstStrKeyPreChatOfflineMessage];
            _cusStrPreChatOfflineMessage = preChatOfflineMessage;
        }
        if ([mNsmdOptions objectForKey:cusConstStrKeyPreChatHeaderMsgBackgroundColor]!=nil) {
            NSString *preChatOfflineMessageBackCOlor = (NSString *)[mNsmdOptions objectForKey:cusConstStrKeyPreChatHeaderMsgBackgroundColor];
            [[Cus360Chat sharedInstance] setPreChatOfflineMsgBackgroundColor:preChatOfflineMessageBackCOlor];
        }else
        {
            [[Cus360Chat sharedInstance] setPreChatOfflineMsgBackgroundColor:@"0079FF"];
        }
        
        if ([mNsmdOptions objectForKey:mStrKeyEnableAutoFormSubmit]!=nil) {
            if ([[mNsmdOptions objectForKey:mStrKeyEnableAutoFormSubmit] isEqualToString:@"YES"])
                [Cus360Chat sharedInstance].cusBoolEnableAutoFormSubmit = YES;
            else
                [Cus360Chat sharedInstance].cusBoolEnableAutoFormSubmit = NO;
        }else
            [Cus360Chat sharedInstance].cusBoolEnableAutoFormSubmit = NO;
    }
}

#pragma mark -Launching Functions

-(void)launchChatModule:(UIViewController*) mCurrentViewController{
    
    _cusBaseView =nil;
    _cusBaseView = mCurrentViewController;
    PreChatViewController* myCustomViewController=[[PreChatViewController alloc] initWithNibName:@"PreChatViewController" bundle:nil];
    
    //  PostChatViewController *myCustomViewController=[[PostChatViewController alloc]initWithNibName:@"PostChatViewController" bundle:nil];
    //[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:myCustomViewController.view cache:YES];
    //[_cusBaseView dismissViewControllerAnimated:NO completion:^{
    //    [UIView animateWithDuration:1.0 animations:^{
    
    [_cusBaseView presentViewController:myCustomViewController animated:YES completion:nil];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addTimerForSendLocationAfterFiveMin:) name:@"addTimerForSendLocationAfterFiveMin" object:nil];
    // ];
    // }];
    // [_cusBaseView presentViewController:myCustomViewController animated:YES completion:nil];
    
}

#pragma mark - XMPP Setup


- (void)setupStream {
    
    xmppStream = [[XMPPStream alloc] init];
    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore];
    
    xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];
    
    [xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    xmppRoster.autoFetchRoster = YES;
    xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
    
    [xmppRoster activate:xmppStream];
    
    // Setup reconnect
    //
    // The XMPPReconnect module monitors for "accidental disconnections" and
    // automatically reconnects the stream for you.
    // There's a bunch more information in the XMPPReconnect header file.
    xmppReconnect = [[XMPPReconnect alloc] init];
    [xmppReconnect activate:xmppStream];
    
    
    //    if ([[NSUserDefaults standardUserDefaults] objectForKey:cusConstStrKeyEnvironmentType]==cusChatConstStrValueEnvironmentTypeTEST)
    //    {
    
    if ([[Cus360Chat sharedInstance]getEnvironmentType]== cusChatConstStrValueEnvironmentTypeTEST) {
        [xmppStream setHostName:@"xmpp.c360dev.in"];
        //
    }
    else{
        [xmppStream setHostName:@"xmpp.customer360.co"];
    }
    //
    //    [xmppStream setHostPort:5222];
    //    [xmppStream oldSchoolSecureConnectWithTimeout:30 error:nil];
    // You may need to alter these settings depending on the server you're connecting to
    customCertEvaluation = YES;
    //    [xmppStream setEnableBackgroundingOnSocket:YES];
    //    [self setupBackgrounding];
    
}
-(NSMutableDictionary*)saveinfo
{
    UIDevice *myDevice=[UIDevice currentDevice];
    //      NSString *g = [[NSString alloc] init];
    NSString *systemName = [myDevice systemName];
    //      NSString *systemName = [self getDeviceName];
    
    NSString *systemVersion =[myDevice systemVersion] ;
    NSString *model = [myDevice model];
    [myDevice setBatteryMonitoringEnabled:YES];
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *strMyDate= [formatter stringFromDate:date];
    formatter.timeStyle = NSDateFormatterFullStyle;
    NSString *strMyTime = [formatter stringFromDate:date];
    strMyDate = [strMyDate  stringByAppendingFormat:@" %@",strMyTime];
    float batteryLevel=  [[UIDevice currentDevice]batteryLevel];
    
    CTTelephonyNetworkInfo *telephonyInfo = [[CTTelephonyNetworkInfo alloc] init];
    NSString *connetctedType = [self connected];
    NSString *connectedVia= [[NSString alloc] init];
    if ([[AFNetworkReachabilityManager sharedManager]isReachableViaWiFi]) {
        connetctedType =@"WIFI";
        connectedVia= @"WIFI";
    }
    else{
        connectedVia= @"Moblie";
        connetctedType = @"3G";
    }
    [[LocationManager sharedInstance] startUpdatingLocation];
    //        [[[LocationManager sharedInstance] locationManager] stopUpdatingLocation];
    float latitude = [LocationManager sharedInstance].locationManager.location.coordinate.latitude;
    float longitude =[LocationManager sharedInstance].locationManager.location.coordinate.longitude;
    NSString *carrierName =telephonyInfo.subscriberCellularProvider.carrierName;
    if (carrierName==nil) {
        carrierName=@"Unknown";
    }
    
    NSString* rid = [self randomAlphanumericStringWithLength:20];
    [[NSUserDefaults standardUserDefaults] setObject:rid forKey:@"rid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSMutableDictionary *visiterInfo= [[NSMutableDictionary alloc] init];
    [visiterInfo setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"rid"] forKey:@"rid"];//\"bq7qsssqes1ss4sssssss43c7e84b8e377e179974da2904d0f"
    [visiterInfo setObject:@"0" forKey:@"timeSpent"];//    "timeSpent\":0
    [visiterInfo setObject:systemName forKey:@"browserName"];
    //    "browserName":"Chrome\"
    [visiterInfo setObject:systemName forKey:@"browserAgent"];
    //        "browserAgent\":\"Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML  like Gecko) Chrome/44.0.2368.0 Safari/537.36\"
    [visiterInfo setObject:systemVersion forKey:@"browserVersion"];
    
    //        \"browserVersion\":\"44.0.2368.0\"
    //        \"browserMajorVersion\":44
    //        \"browserLanguage\":\"en-US\",
    //        \"browserPlatform\":\"Win32\",
    //        \"browserOS\":\"Windows NT 4.0\",
    [visiterInfo setObject:systemName forKey:@"browserOS"];
    [visiterInfo setObject:strMyDate forKey:@"datetime"];
    //       \"datetime\":\"2015-3-14 14:59:31 GMT+0530 (India Standard Time)\",
    [visiterInfo setObject:@"http://www.customer360.co" forKey:@"activeUrl"];
    //        \"activeUrl\":\"http://www.customer360.co",
    [visiterInfo setObject:@"true" forKey:@"isNewUser"];
    //        \"isNewUser\":true,
    //        \"isActive\":false,
    [visiterInfo setObject:@"false" forKey:@"isActive"];
    //        \"sessionLength\":0,
    [visiterInfo setObject:@"0" forKey:@"sessionLength"];
    [visiterInfo setObject:[self getIPAddress] forKey:@"ip"];
    //        \"ip\":\"10.187.32.239\",
    [visiterInfo setObject:@"Apple Inc." forKey:@"osManufacturer"];
    //        \"osModel\":\"XT1068\",
    [visiterInfo setObject:[self getDeviceName] forKey:@"osModel"];
    
    //        \"osManufacturer\":\"motorola\"
    [visiterInfo setObject:[self getDeviceName] forKey:@"osHardware"];
    //        \"osHardware\":\"qcom\"
    [visiterInfo setObject:systemName forKey:@"osDevice"];
    //        \"osDevice\":\"titan_umtsds\"
    [visiterInfo setObject:@" " forKey:@"osProduct"];
    //        \"osProduct\":\"titan_retaildsds\"
    [visiterInfo setObject:@" " forKey:@"osHost"];
    //        \"osHost\":\"titan_retaildsds\"
    [visiterInfo setObject:@"Apple" forKey:@"osBrand"];
    //        "osBrand\":\"motorola\"
    /*
     [visiterInfo setObject:[self getIPAddress] forKey:@"osModel"]
     \"osSerial\":\"ZX1D62PLD4\"*/
    
    NSTimeInterval new = [[NSDate date] timeIntervalSince1970];
    NSString *time = [NSString stringWithFormat:@"%f",new];
    
    [visiterInfo setObject:time forKey:@"osTime"];
    //        \"osTime\":\"1409102366000\"
    [visiterInfo setObject:systemName forKey:@"osName"];
    //        \"osName\":\"KITKAT\",
    [visiterInfo setObject:systemVersion forKey:@"osVersion"];
    //        \"osVersion\":\"4.4.4\",
    [visiterInfo setObject:systemVersion forKey:@"sdkVersion"];
    //        \"sdkVersion\":\"19\",
    NSString *strLatitude = [NSString stringWithFormat:@"%f",latitude];
    [visiterInfo setObject:strLatitude forKey:@"latitude"];
    //        \"latitude\":\"19.0815655\",
    
    NSString *strLongitude = [NSString stringWithFormat:@"%f",longitude];
    [visiterInfo setObject:strLongitude forKey:@"logitude"];
    //        \"logitude\":\"72.8411805\",
    NSString *strBattery = [NSString stringWithFormat:@"%.f %",batteryLevel*100];
    [visiterInfo setObject:strBattery forKey:@"osBattery"];
    //        \"osBattery\":\"100.0 %\",
    [visiterInfo setObject:carrierName forKey:@"osCarrierName"];
    //        \"osCarrierName\":\"Vodafone IN\",
    [visiterInfo setObject:connectedVia forKey:@"osNetworkInfo"];
    //        \"osNetworkInfo\":\"Mobile (or WIFI)\",
    
    [visiterInfo setObject:@"CONNECTED" forKey:@"osNetworkInfoState"];
    //        \"osNetworkInfoState\":\"CONNECTED\",
    
    [visiterInfo setObject:connetctedType forKey:@"osNetworkInfoType"];
    //        \"osNetworkInfoType\":\"3G\",
    [visiterInfo setObject:model forKey:@"osDeviceType"];
    //        \"osDeviceType\":\"Mobile/Tab\",
    [visiterInfo setObject:@"IOS" forKey:@"osPlateform"];
    //        \"osPlateform\":\"Android/IOS\"}
    //    [visiterInfo setObject:[self getIPAddress] forKey:@"osModel"]
    
    //        ","source":"inapp","domain_id":"0"}
    
    //       Customer360ChatApp[992:60b] jid-:-user27e4306edbfc93142a945dc2c5a53c60test1c360devin@test1.c360dev.in|rid-:-kWr5v2xL1kkAp352tsA6|sid-:-65q1wHCO8qj60N37opRo|timeSpent-:-0||activeUrl-:-http://www.customer360.co|isNewUser-:-true|isActive-:-false|sessionLength-:-0||ip-:-192.168.2.5|datetime-:-2015-04-22 5:01:32 pm India Standard Time|osTime-:-1429702292|osPlateForm-:-iPhone OS|osName-:-iOS|osVersion-:-7.1.2|osManufacturer-:-Apple Inc.|osModel-:-iPhone|osDeviceType-:-7.1.2|osBattery-:- 100|osCarrierName-:-Vodafone India|osNetworkInfoType-:-WIFI|sdkVersion-:-7.1.2|latitude-:-19.081623|logitude=72.841316|osNetworkInfoState:CONNECTED|browserName-:- iPhone OS 7.1.2|browserAgent-:- iPhone OS|browserVersion-:- iPhone|browserOS-:- iPhone OS|
    
    return visiterInfo;
}

-(NSString*)getDeviceName
{
    uname(&systemInfo);
    
    NSString *file = [[NSBundle mainBundle]pathForResource:@"iOS_device_types" ofType:@"txt"];
    NSError *error;
    
    NSString *text = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:&error];
    
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    NSArray * testArray = [[NSArray alloc] init];
    testArray = [text componentsSeparatedByString:@"\n"];
    NSString *real;
    for (NSString *s in testArray)
    {
        NSArray *arr = [s componentsSeparatedByString:@":"];
        if ([[arr objectAtIndex:0]isEqualToString:platform])
        {
            real = [arr objectAtIndex:1];
            break;
        }
    }
    return real;
}

-(NSString*)makeProbeResponcePacket
{
    UIDevice *myDevice=[UIDevice currentDevice];
    NSString *g = [[NSString alloc] init];
    g = [NSString stringWithFormat:@"jid-:-%@|rid-:-%@|sid-:-%@|timeSpent-:-0|", [xmppStream.myJID bare],[[NSUserDefaults standardUserDefaults] objectForKey:@"rid"], [self randomAlphanumericStringWithLength:20]];
    NSString *systemName = [self getDeviceName];
    NSString *systemVersion =[myDevice systemVersion] ;
    NSString *model = [myDevice model];
    [myDevice setBatteryMonitoringEnabled:YES];
    
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *strMyDate= [formatter stringFromDate:date];
    formatter.timeStyle = NSDateFormatterFullStyle;
    NSString *strMyTime = [formatter stringFromDate:date];
    strMyDate = [strMyDate  stringByAppendingFormat:@" %@",strMyTime];
    
    g= [g stringByAppendingString:[NSString stringWithFormat:@"activeUrl-:-http://www.customer360.co|isNewUser-:-true|isActive-:-false|sessionLength-:-0|ip-:-%@|datetime-:-%@|osTime-:-%.f",[self getIPAddress],strMyDate,[[NSDate date] timeIntervalSince1970]]];
    float batteryLevel=  [[UIDevice currentDevice]batteryLevel];
    
    CTTelephonyNetworkInfo *telephonyInfo = [[CTTelephonyNetworkInfo alloc] init];
    NSString *connetctedType = [self connected];
    if ([[AFNetworkReachabilityManager sharedManager]isReachableViaWiFi]) {
        connetctedType =@"WIFI";
    }
    else{
        
        connetctedType = @"Mobile";
    }
    //    [[LocationManager sharedInstance] startUpdatingLocation];
    //    [[[LocationManager sharedInstance] locationManager] stopUpdatingLocation];
    float latitude = [LocationManager sharedInstance].locationManager.location.coordinate.latitude;
    float longitude =[LocationManager sharedInstance].locationManager.location.coordinate.longitude;
    NSString *carrierName =telephonyInfo.subscriberCellularProvider.carrierName;
    NSString *Detail= [NSString stringWithFormat:@"|osPlateForm-:-%@|osName-:-iOS|osVersion-:-%@|osManufacturer-:-Apple Inc.|osModel-:-%@|osDeviceType-:-%@|osBattery-:- %.f|osCarrierName-:-%@|osNetworkInfoType-:-%@|sdkVersion-:-%@|latitude-:-%f|logitude=%f|osNetworkInfoState:CONNECTED",systemName,systemVersion,systemVersion,model,batteryLevel*100,carrierName,connetctedType,systemVersion,latitude,longitude];
    
    NSString *BrowserDetails = [NSString stringWithFormat:@"|browserName-:- %@ %@|browserAgent-:- %@|browserVersion-:- %@|browserOS-:- %@|source-:-inapp",systemName,systemVersion,systemName,model,systemName];
    
    
    g= [g stringByAppendingString:Detail];
    g= [g stringByAppendingString:BrowserDetails];
    
    return g;
}

-(NSString*)connected {
    
    __block BOOL reachable;
    
    // Setting block doesn't means you area running it right now
    
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSLog(@"Reachability: %@", AFStringFromNetworkReachabilityStatus(status));
        if ([AFStringFromNetworkReachabilityStatus(status) isEqualToString:@"Not Reachable"]) {
            if ([[_cusBaseView presentedViewController]isKindOfClass:[ChatViewController class]])
            {
                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Lost Network Connection" message:@"Please wait. Trying to reconnect" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
            timer30SecConnection = [NSTimer scheduledTimerWithTimeInterval:24 target:self selector:@selector(fireAlert) userInfo:nil repeats:NO];
            //              [self finishThisPage];
        }else
        {
            if ([[_cusBaseView presentedViewController]isKindOfClass:[ChatViewController class]])
            {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Network Connected!" message:@"Reconnection complete. Thank You. " delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
            [timer30SecConnection invalidate];
        }
        
    }];
    
    // and now activate monitoring
    //    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    //    if (!reachable) {
    
    //    }
    return  [[AFNetworkReachabilityManager sharedManager] localizedNetworkReachabilityStatusString];
    
}

-(void)fireAlert{
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ooops" message:@"Your internet seems to be disconnected. Please check your connection and retry connecting. "delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

- (NSString *)randomAlphanumericStringWithLength:(NSInteger)length
{
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
    
    for (int i = 0; i < length; i++) {
        [randomString appendFormat:@"%C", [letters characterAtIndex:arc4random() % [letters length]]];
    }
    
    return randomString;
}

- (void)teardownStream
{
    [xmppStream removeDelegate:self];
    [xmppRoster removeDelegate:self];
    
    [xmppReconnect deactivate];
    [xmppRoster deactivate];
    [xmppStream disconnect];
    xmppStream = nil;
    xmppReconnect = nil;
    xmppRoster = nil;
    isXmppConnected = NO;
    [[AFNetworkReachabilityManager sharedManager]stopMonitoring];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"agent_name"];
}

- (void)goOnline
{
    if (![[_cusBaseView presentedViewController]isKindOfClass:[ChatViewController class]])
    {
        XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
        NSString *domain = [xmppStream.myJID domain];
        NSLog(@"Connected To Domain : %@",domain);
        [xmppStream sendElement:presence];
    }
    //    NSStream * stream = [[NSStream alloc]init];
    //    stream = (NSStream*)xmppStream;
    //    NSOutputStream *outStream = [NSOutputStream outputStreamWithURL:@"http://www.google.com" append:YES];
    
}

- (void)goOffline {
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    
    NSLog(@"%@",[presence prettyXMLString]);
    [xmppStream sendElement:presence];
}

- (BOOL)connect {
    [self setupStream];
    if (![xmppStream isDisconnected]) {
        return YES;
    }
    
    NSString *myJID = [[NSUserDefaults standardUserDefaults] stringForKey:cusConstStrKeyJID];
    NSString *myPassword = [[NSUserDefaults standardUserDefaults] stringForKey:cusConstStrKeyPassword];
    
    //
    // If you don't want to use the Settings view to set the JID,
    // uncomment the section below to hard code a JID and password.
    //
    //    myJID = @"user1a25303ff19a8debfeb969f1cd7740actest1c360devin@test1.c360dev.in";
    //    myPassword = @"asdasdasd@34";
    
    if (myJID == nil || myPassword == nil) {
        return NO;
    }
    
    [xmppStream setMyJID:[XMPPJID jidWithString:myJID]];
    password = myPassword;
    
    NSError *error = nil;
    if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error connecting"
                                                            message:@"See console for error details."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        NSLog(@"Error connecting: %@", error);
        return NO;
    }
    
    return YES;
}


- (void)disconnect
{
    [self goOffline];
    [xmppStream disconnect];
    [self teardownStream];
}
#pragma mark XMPPStream Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
 - (void)xmppStream:(XMPPStream *)sender socketWillConnect:(GCDAsyncSocket *)socket
 {
 // Tell the socket to stay around if the app goes to the background (only works on apps with the VoIP background flag set)
 
 }*/
- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
    [socket performBlock:^{
        [socket enableBackgroundingOnSocket];
    }];
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
    //    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    NSString *expectedCertName = [xmppStream.myJID domain];
    if (expectedCertName)
    {
        settings[(NSString *) kCFStreamSSLPeerName] = expectedCertName;
    }
    
    if (customCertEvaluation)
    {
        settings[GCDAsyncSocketManuallyEvaluateTrust] = @(YES);
    }
}

/**
 * Allows a delegate to hook into the TLS handshake and manually validate the peer it's connecting to.
 *
 * This is only called if the stream is secured with settings that include:
 * - GCDAsyncSocketManuallyEvaluateTrust == YES
 * That is, if a delegate implements xmppStream:willSecureWithSettings:, and plugs in that key/value pair.
 *
 * Thus this delegate method is forwarding the TLS evaluation callback from the underlying GCDAsyncSocket.
 *
 * Typically the delegate will use SecTrustEvaluate (and related functions) to properly validate the peer.
 *
 * Note from Apple's documentation:
 *   Because [SecTrustEvaluate] might look on the network for certificates in the certificate chain,
 *   [it] might block while attempting network access. You should never call it from your main thread;
 *   call it only from within a function running on a dispatch queue or on a separate thread.
 *
 * This is why this method uses a completionHandler block rather than a normal return value.
 * The idea is that you should be performing SecTrustEvaluate on a background thread.
 * The completionHandler block is thread-safe, and may be invoked from a background queue/thread.
 * It is safe to invoke the completionHandler block even if the socket has been closed.
 *
 * Keep in mind that you can do all kinds of cool stuff here.
 * For example:
 *
 * If your development server is using a self-signed certificate,
 * then you could embed info about the self-signed cert within your app, and use this callback to ensure that
 * you're actually connecting to the expected dev server.
 *
 * Also, you could present certificates that don't pass SecTrustEvaluate to the client.
 * That is, if SecTrustEvaluate comes back with problems, you could invoke the completionHandler with NO,
 * and then ask the client if the cert can be trusted. This is similar to how most browsers act.
 *
 * Generally, only one delegate should implement this method.
 * However, if multiple delegates implement this method, then the first to invoke the completionHandler "wins".
 * And subsequent invocations of the completionHandler are ignored.
 **/
- (void)xmppStream:(XMPPStream *)sender didReceiveTrust:(SecTrustRef)trust
 completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler
{
    
    // The delegate method should likely have code similar to this,
    // but will presumably perform some extra security code stuff.
    // For example, allowing a specific self-signed certificate that is known to the app.
    
    dispatch_queue_t bgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(bgQueue, ^{
        
        SecTrustResultType result = kSecTrustResultDeny;
        OSStatus status = SecTrustEvaluate(trust, &result);
        
        if (status == noErr && (result == kSecTrustResultProceed || result == kSecTrustResultUnspecified)) {
            completionHandler(YES);
        }
        else {
            completionHandler(NO);
        }
    });
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
    
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    isXmppConnected = YES;
    
    NSError *error = nil;
    
    if (![[self xmppStream] authenticateWithPassword:password error:&error])
    {
        NSLog(@"Error authenticating: %@", error);
    }
    
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    //    NSLog( @" authenticationDate packet = %@",sender);
    [self goOnline];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    //    NSLog(@"%@",error);
    NSLog(@"Did Not authenticate %@", error);
    
}
-(XMPPIQ *)xmppStream:(XMPPStream *)sender willSendIQ:(XMPPIQ *)iq
{
    if ([[_cusBaseView presentedViewController]isKindOfClass:[ChatViewController class]])
    {
        if ([iq elementForName:@"query"]) {
            //      <query xmlns="jabber:iq:roster"/>
            [iq removeElementForName:@"query" xmlns:@"jabber:iq:roster"];
            //       <ping xmlns="urn:xmpp:ping"/>
            DDXMLElement *ping = [DDXMLElement elementWithName:@"ping" xmlns:@"urn:xmpp:ping"];
            [iq addChild:ping];
        }
    }
    return iq;
}/*
  -(void)xmppStream:(XMPPStream *)sender didSendIQ:(XMPPIQ *)iq{
  
  NSLog( @" iq packet sent= %@", iq.prettyXMLString);
  
  }
  */
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    //    NSLog( @" sender = %@", sender.remoteJID);
    //    NSLog( @" iq packet = %@", iq.prettyXMLString);
    return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    // A simple example of inbound message handling.
    NSLog(@"message is = %@",message.prettyXMLString);
    if ([message.type isEqualToString:@"headline"]) {
        //        [[NSUserDefaults standardUserDefaults] setObject:[message fromStr] forKey:@"agent_jid"];
    }
     NSString *body = [[message elementForName:@"body"] stringValue];
    
    //initailly agent was online, and goes offline while visitor was filling form
    if ([body rangeOfString:@"c360: no_agent_online"].location != NSNotFound && [body rangeOfString:@"c360: no_agent_online"].length > 0)
    {
        NSLog(@"c360: no_agent_online");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Agent Left" message:@"No Agent Online." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [CUSApiHelperChat changeStatus:self withOnSuccessCallBack:@selector(finishThisPage) andOnFailureCallBack:@selector(finishThisPage) withParams:@"missed"];
        return;
    }

    
    if ([message isChatMessageWithBody])
    {
        
        //        NSLog(@"message is = %@",message.prettyXMLString);
        
        //        XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[message from]
        //                                                                 xmppStream:xmppStream
        //                                                       managedObjectContext:[self managedObjectContext_roster]];
        
        //        NSString *displayName = [message fromStr];
        //NSString *body = [[message elementForName:@"body"] stringValue];
        
        //        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
        //  {
        if ([body rangeOfString:@"joined the chat"].length > 0) {
            
            NSString* agent_name = [body stringByReplacingOccurrencesOfString:@"C360:Agent_Joined " withString:@""] ;
            
            NSString *photoUrl = [agent_name substringFromIndex:[agent_name rangeOfString:@"|"].location+1];
            
            //            NSLog(@"%lu",(unsigned long)[photoUrl rangeOfString:@"|"].location);
            if ([photoUrl rangeOfString:@"|"].length>0) {
                photoUrl = [photoUrl substringToIndex:[photoUrl rangeOfString:@"|"].location];
            }
            photoUrl = [photoUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            //            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"agent_name"])
            //            {
            //                [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"agent_name"];
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"photoUrl"];
            //            }
            
            [[NSUserDefaults standardUserDefaults]setObject:photoUrl forKey:@"photoUrl"];
            agent_name = [agent_name substringToIndex:[agent_name rangeOfString:@" joined"].location];
            
            //            if (![[NSUserDefaults standardUserDefaults] objectForKey:@"agent_name"])
            if ([[NSUserDefaults standardUserDefaults]boolForKey:@"display_agent_name"])
            {
                [[NSUserDefaults standardUserDefaults]setObject:agent_name forKey:@"agent_name"];
            }
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            if (![body rangeOfString:@"C360:Chat_After_Transfer"].length>0)
            {
                chatViewController = [[ChatViewController alloc]initWithNibName:@"ChatViewController" bundle:nil];
                chatViewController.agentName = agent_name;
                
                [_cusBaseView dismissViewControllerAnimated:YES completion:nil];
                    
                [_cusBaseView presentViewController:chatViewController animated:YES completion:nil];

//                [UIView animateWithDuration:0.05 animations:^{
//                    [_cusBaseView dismissViewControllerAnimated:NO completion:^{
//                        
//                        [_cusBaseView presentViewController:chatViewController animated:YES completion:nil];
//                    }];
//                }];
            }
        }
        //        }
        
        /* else
         {
         // We are not active, so use a local notification instead
         //            [UIApplication ]
         / *   if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
         [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound categories:nil]];
         }* /
         
         / *UILocalNotification *localNotification = [[UILocalNotification alloc] init];
         localNotification.alertAction = @"Ok";
         localNotification.alertBody = [NSString stringWithFormat:@"From: %@\n\n%@",displayName,body];
         
         [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];* /
         }
         }*/
    }
}

-(void)xmppStream:(XMPPStream *)sender didSendPresence:(XMPPPresence *)presence{
    
            NSLog(@"didSendPresence to - %@",  [presence XMLString]);
}
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    NSLog(@"didReceivePresence fromStr - %@",  [presence XMLString]);
    if ([presence.type isEqualToString:@"unavailable"])
    {
        NSLog(@"unavailable presence");
    }
    if ([presence.type isEqualToString:@"probe"])
    {
        XMPPPresence *presence = [XMPPPresence presence];
        NSXMLElement *status = [NSXMLElement elementWithName:@"status"];
        [status setStringValue:[self makeProbeResponcePacket]];
        [presence addChild:status];
        [xmppStream sendElement:presence];
    }
    if (![[_cusBaseView presentedViewController]isKindOfClass:[ChatViewController class]])
    {
        if ([presence.type isEqualToString:@"unavailable"]&![[[presence from]bare]isEqualToString:[[[self xmppStream] myJID] bare]]) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Agent Left" message:@"Agent left the chat." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            [CUSApiHelperChat changeStatus:self withOnSuccessCallBack:@selector(finishThisPage) andOnFailureCallBack:@selector(finishThisPage) withParams:@"missed"];
        }
    }
    //    if([presence type ]isEqualToString:@"")
    
}
-(void)finishThisPage{
    
    [self disconnect];
    [_cusBaseView dismissViewControllerAnimated:NO completion:nil];
    [SVProgressHUD dismiss];
    //    [chatViewController finishThisPage];
}
- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
    //    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Failed" message:@"Unable to connect to server. Please retry connecting" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    
    //    [xmppReconnect manualStart];
    //    NSLog(@"Unable to connect to server. Check xmppStream.hostName , %@", error);
    
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    //    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    if (!isXmppConnected)
        if (error)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Failed" message:@"Unable to connect to server. Please retry connecting" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            
            //        NSLog(@"Unable to connect to server. Check xmppStream.hostName , %@", error);
            
        }
}


#pragma mark XMPPRosterDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)xmppRoster:(XMPPRoster *)sender didReceiveRosterPush:(XMPPIQ *)iq{
    
    //    NSLog(@"Roster iq = %@",iq);
}
-(void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(DDXMLElement *)item{
    //    NSLog( @" sender = %@", sender.remoteJID);
    //    NSLog( @" iq packet = %@", iq.prettyXMLString);
    if (![[_cusBaseView presentedViewController]isKindOfClass:[ChatViewController class]])
    {
        DDXMLNode *jidNode = [item attributeForName:@"jid"];
        
        NSString *jid =  [jidNode stringValue];
        [[NSUserDefaults standardUserDefaults] setObject:jid forKey:@"agent_jid"];
        
        XMPPPresence *presence = [XMPPPresence presence];
        NSXMLElement *status = [NSXMLElement elementWithName:@"status"];
        
        [status setStringValue:[self makeProbeResponcePacket]];
        [presence addChild:status];
        [xmppStream sendElement:presence];
        
        XMPPMessage * message = [XMPPMessage messageWithType:@"chat" to:[XMPPJID jidWithString:jid]];
        [message addAttributeWithName:@"prechat" stringValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"prechat_id"]];
        [message addBody:@"Pre chat form message"];
        
        [message addThread:[[NSUserDefaults standardUserDefaults] objectForKey:@"msgThread"]];
        
        [xmppStream sendElement:message];
        timerForSendLocationAfterFiveMin = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(sendPing) userInfo:nil repeats:YES];
        [timerForSendLocationAfterFiveMin fire];
        
        
        /*
         if ([[iq type]isEqualToString:@"set"])
         {
         NSString *item = [[[iq childElement] childAtIndex:0] XMLStringWithOptions:17];
         
         NSString *jid = [item substringFromIndex:[item rangeOfString:@"jid=\""].location+[item rangeOfString:@"jid=\""].length];
         jid = [jid substringToIndex:[jid rangeOfString:@"\""].location];
         //        NSLog(@"roster jid %@",jid);
         
         / *  XMPPAutoPing *autoPing = [[XMPPAutoPing alloc] initWithDispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)];
         autoPing.targetJID = [XMPPJID jidWithString:jid];
         [autoPing activate:xmppStream];
         //        NSLog(@"auto ping = %f",autoPing.lastReceiveTime);
         [autoPing setPingInterval:40];*
         
         timerForSendLocationAfterFiveMin = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(sendPing) userInfo:nil repeats:YES];
         [timerForSendLocationAfterFiveMin fire];
         }*/
    }
}
-(void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence{
    
    XMPPPresence *presen = [XMPPPresence presence];
    //    NSString *domain = [xmppStream.remoteJID domain];
    //    NSLog(@"didReceivePresenceSubscriptionRequest : %@",domain);
    [xmppStream sendElement:presen];
    
}

#pragma mark Core Data


- (NSManagedObjectContext *)managedObjectContext_roster
{
    return [xmppRosterStorage mainThreadManagedObjectContext];
}

-(void)sendPing{
    if (isXmppConnected)
    {
        XMPPPing *new = [[XMPPPing alloc] init];
        [new addDelegate:self delegateQueue:dispatch_get_main_queue()];
        //        NSString *toJID = [[NSUserDefaults standardUserDefaults] objectForKey:@"agent_jid"];
        [new activate:[self xmppStream]];
        [new sendPingToServer];
        //        [new sendPingToJID:[XMPPJID jidWithString:toJID]];
    }
}

- (void)setupBackgrounding {
    /*
     //    [[LocationManager sharedInstance] startUpdatingLocation];
     
     //    [_locationUpdateTimer invalidate];*/
    UIApplication *application = [UIApplication sharedApplication];
    if ([application applicationState]== UIApplicationStateBackground) {
        if([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)])
        {
            //        NSLog(@"Multitasking Supported");
            
            __block UIBackgroundTaskIdentifier background_task;
            
            background_task = [application beginBackgroundTaskWithExpirationHandler:^ {
                
                //            application.backgroundRefreshStatus = UIBackgroundRefreshStatusAvailable;
                
                //Clean up code. Tell the system that we are done.
                [application endBackgroundTask: background_task];
                background_task = UIBackgroundTaskInvalid;
            }];
            
            //To make the code block asynchronous
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                //### background task starts
                //            NSLog(@"Running in the background\n");
                int ios = 15;
                while(TRUE)
                {
                    //                NSLog(@"Background time Remaining: %f",[[UIApplication sharedApplication] backgroundTimeRemaining]);
                    /*
                     UILocalNotification *notify = [[UILocalNotification alloc]init];
                     notify.alertBody = @"15 sec done";
                     [[UIApplication sharedApplication] presentLocalNotificationNow: notify];
                     [self performSelectorInBackground:@selector(sendPing) withObject:nil];*/
                    //                [self sendPing];0
                    ios+=15;
                    [NSThread sleepForTimeInterval:15];
                    if (ios >= 900) {
                        break;
                    }//wait for 15 sec
                }
                
                //#### background task ends
                
                //Clean up code. Tell the system that we are done.
                [application endBackgroundTask: background_task];
                background_task = UIBackgroundTaskInvalid; 
            });
        }
        else
        {
            NSLog(@"Multitasking Not Supported");
        }
        
    }
}
#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    [self finishThisPage];
    
    //    if (xmppStream)
    //    {
    //        [xmppReconnect manualStart];
    //    }
    
}
@end
