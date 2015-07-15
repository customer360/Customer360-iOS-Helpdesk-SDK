//
//  Cus360.h
//  Customer360SDK
//
//  Created by Customer360 on 02/12/14.
//  Copyright (c) 2014 Customer360. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//#import "Cus360.h"/
@class ModelAccessTokenChat;
//@class CUSTicketDetailsViewController;
//@class ChatViewController;

@class XMPPStream;

extern NSString * const cusConstStrKeyJID ;
extern NSString * const cusConstStrKeyPassword ;
extern NSString * const cusConstStrKeyAccessTokenChat;

extern NSString * const cusChatConstStrKeyAppApiKey;
extern NSString * const cusConstStrKeyUserEmailId;
extern NSString * const cusConstStrKeyGCMRegId;
extern NSString * const cusChatConstStrKeyUserSenderId;
//extern NSString * const cusConstStrKeyChatUrl;
extern NSString * const cusChatConstStrKeyHasAccesTokenBeenChanged;
//extern NSString * const cusConstStrKeyNotificationsEnabled;
extern NSString * const cusConstStrKeyEnvironmentType;
extern NSString * const cusChatConstStrValueEnvironmentTypeLIVE;
extern NSString * const cusChatConstStrValueEnvironmentTypeTEST;
extern NSString * const cusChatConstStrKeyNavbarColor;
extern NSString * const cusChatConstStrKeyNavBarTitleColor;
//extern NSString * const cusConstStrKeyTypeOfTokenUsed;
extern NSString * const cusConstStrKeyDeveloperEmailId;
extern NSString * const cusConstStrKeyUserName;
extern NSString * const cusConstStrKeyFeedback;
extern NSString * const cusConstStrKeyNavBarGradientColorFirst;
extern NSString * const cusConstStrKeyNavBarGradientColorSecond;
extern NSString * const cusConstStrKeyWaitingScreenImageName;
extern NSString * const cusConstStrKeyPreChatOnlineMessage;
extern NSString * const cusConstStrKeyPreChatOfflineMessage;
extern NSString * const cusConstStrKeyPreChatHeaderMsgBackgroundColor;
extern NSString * const mStrKeyEnableAutoFormSubmit;

@interface Cus360Chat : NSObject
{

    //your access token , you can find this by loggin in to you customer 360 dashboard
//    NSString* cusStrAcessToken;

    ModelAccessTokenChat *cusMAccessTokenChat;

    //your App Api Key , you can find this by loggin in to you customer 360 dashboard
    NSString* cusStrAppApiKeyChat;

    //auto set field .. chat url comes from the api on the basis of your access token
    NSString* cusStrChatUrl;
    
    //GCM registraion Id for your device...
    NSString* cusChatStrGCMRegId;
    
    //user email id
    NSString* cusStrEmaiId;
    
    //user sender id
    NSString* cusStrSenderId;
    
    //flag to enable or disable notifications...
//    NSNumber* cusNsnumNotificationsEnabled;
    
    //flag to enable or disable notifications...
    NSNumber* cusNsnumHasAccessTokenBeenChanged;

    NSString *cusStrEnvironmentType;
    
    
    //Change Navigation bar gradient color
    NSString* cusStrGradientColorFirst;
    NSString* cusStrGradientColorSecond;

    //pre chat offline message background color
    NSString* cusStrPreChatBackgroundColor;
    
    //Change Navigation bar color matching to your rest of the product...
    NSString* cusNavigationBarTintColor;
    
    //Change Navigation bar title color matching to your rest of the product...
    NSString* cusNavigationBarTitleColor;
    
  
//    CUSTicketDetailsViewController* cusUivcTicketDetailsController;
    
}

#pragma mark - singleton getInstance() method...
+(Cus360Chat*)sharedInstance;

@property (nonatomic, strong) XMPPStream *xmppStream;
@property (nonatomic, strong) UIViewController *cusBaseView;
@property (nonatomic, strong, readonly) NSString* cusStrDeveloperEmaiId;
@property (nonatomic, strong, readonly) NSString* cusStrUserName;
@property (nonatomic, strong, readonly) NSString* cusStrUserFeedback;
@property (nonatomic, strong, readonly) NSString* cusStrWaitingScreenImageName;
@property (nonatomic, strong, readonly) NSString* cusStrPreChatOnlineMessage;
@property (nonatomic, strong, readonly) NSString* cusStrPreChatOfflineMessage;
@property (nonatomic, strong) NSString* cusStrPreChatOffMsgBackgroundColor;
@property (nonatomic, assign) BOOL cusBoolEnableAutoFormSubmit;

#pragma mark -Custom Getters And Setters
//(notice the name of the getter and setter functions are  different from the name fo the variables and that's why I didn't declare them as property ,I don't want the compiler to genrate accessors for these variables on it's own)
//custom getter setter for mMAccessTokenHelpDesk
-(ModelAccessTokenChat*) getAccessTokenChat;
-(void) setAccessTokenChat:(ModelAccessTokenChat*) mInput;

//custom getter setter for mStrAccessToken
//-(NSString*) getAccessToken;
//-(void) setAccessToken:(NSString*) mInput;

- (NSString *)getAppApiKey;

- (void)setAppApiKey:(NSString *)mInput;

//-(NSString*) getChatUrl;
//-(void) setChatUrl:(NSString*) mInput;

-(NSString*) getGradientColorFirst;
-(void) setGradientColorFirst:(NSString*) mInput;

-(NSString*) getGradientColorSecond;
-(void) setGradientColorSecond:(NSString*) mInput;

-(NSString*) getPreChatOfflineMsgBackgroundColor;
-(void) setPreChatOfflineMsgBackgroundColor:(NSString*) mInput;

-(NSString*) getGCMRegId;
-(void) setGCMRegId:(NSString*) mInput;

-(NSString*) getUserEmailId;
-(void) setUserEmailId:(NSString*) mInput;


-(NSString*) getSenderId;
-(void) setSenderId:(NSString*) mInput;

-(NSString*) getNavigationBarColor;
-(void) setNavigationBarColor:(NSString*) mInput;


-(NSString*) getNavigationBarTitleColor;
-(void) setNavigationBarTitleColor:(NSString*) mInput;
/*
-(bool) getNotificationsEnabled;
-(void) setNotificationsEnabled:(bool) mInput;
*/
-(bool) getHasAccessTokenBeenChanged;
-(void) setHasAccessTokenBeenChanged:(bool) mInput;

-(NSString*) getEnvironmentType;
-(void) setEnvironmentType:(NSString*) mInput;
/*
-(CUSTicketDetailsViewController *)getTicketDetailsViewController;
-(void)setTicketDetailsViewController:(CUSTicketDetailsViewController *)cusArgTicketDetailsViewController;
*/

#pragma mark - other  fucntionality
-(bool)checkIfAccessTokenHasBeenVerified;
/*
- (void)registerForPushNotifications:(UIApplication *)application launchOptions:(NSDictionary *)launchOptions window:(UIWindow *)window;
-(void)handlePushNotificationRecieved:(NSDictionary *)userInfo launchTicketDetailsWithoutCheckignAnything:(BOOL) cusArgBoolLaunchWithOutChecking window:(UIWindow *)window;*/

#pragma mark - Install  fucntionality
-(void)install:(NSString*) cusStrArgApiToken;
-(void)install:(NSString*) cusStrArgApiToken withOptions: (NSMutableDictionary*) cusNsmdOptions;


#pragma mark - Launching Functions
-(void)launchChatModule:(UIViewController*) mCurrentViewController;
- (BOOL)connect;
- (void)disconnect;

- (void)setupBackgrounding;
-(void)sendPing;
-(NSMutableDictionary*)saveinfo;


@end
