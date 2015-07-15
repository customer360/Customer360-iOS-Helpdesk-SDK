//
//  Cus360HelpDesk.h
//  DemoAppHelpDesk
//
//  Created by Anveshan Technologies on 24/02/15.
//
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
//#import "Cus360.h"

@class CUSTicketDetailsViewController;
@class ModelAccessTokenHelpDesk;

extern NSString * const cusConstStrKeyAccessTokenHelpDesk;
extern NSString * const cusConstStrKeyAppApiKeyHelpDesk;
extern NSString * const cusHelpDeskConstStrKeyUserEmailId;
extern NSString * const cusHelpDeskConstStrKeyGCMRegId;
extern NSString * const cusHelpDeskConstStrKeyUserSenderId;
extern NSString * const cusHelpDeskConstStrKeyChatUrl;
extern NSString * const cusHelpDeskConstStrKeyHAsAccesTokenBeenChanged;
extern NSString * const cusConstStrKeyNotificationsEnabled;
extern NSString * const cusHelpDeskConstStrKeyEnvironmentType;
extern NSString * const cusHelpDeskConstStrValueEnvironmentTypeLIVE;
extern NSString * const cusHelpDeskConstStrValueEnvironmentTypeTEST;
extern NSString * const cusConstStrKeyNavbarColor;
extern NSString * const cusConstStrKeyNavBarTitleColor;



@interface Cus360HelpDesk :NSObject
{
    CUSTicketDetailsViewController* cusUivcTicketDetailsController;
    
    //your access token , you can find this by loggin in to you customer 360 dashboard
    //    NSString* cusStrAcessToken;
    
    ModelAccessTokenHelpDesk *cusMAccessTokenHelpDesk;
    
    //your App Api Key , you can find this by loggin in to you customer 360 dashboard
    NSString* cusStrAppApiKeyHelpDesk;
    
    //auto set field .. chat url comes from the api on the basis of your access token
    NSString* cusStrChatUrl;
    
    //GCM registraion Id for your device...
    NSString* cusHelpDeskStrGCMRegId;
    
    //user email id
    NSString* cusHelpDeskStrEmaiId;
    
    //user email id
    NSString* cusHelpDeskStrSenderId;
    
    //flag to enable or disable notifications...
    NSNumber* cusNsnumNotificationsEnabledHelpDesk;
    
    //flag to enable or disable notifications...
    NSNumber* cusNsnumHasAccessTokenBeenChangedHelpDesk;
    
    NSString *cusHelpDeskStrEnvironmentType;
    
    
    //Change Navigation bar color matching to your rest of the product...
    NSString* cusHelpDeskNavigationBarTintColor;
    
    //Change Navigation bar title color matching to your rest of the product...
    NSString* cusHelpDeskNavigationBarTitleColor;
    
    
//    CUSTicketDetailsViewController* cusUivcTicketDetailsController;
    
}

@property (nonatomic, strong) NSMutableArray *unreadHelpDesk;
#pragma mark - singleton getInstance() method...
//+(Cus360*)sharedInstance;
+(Cus360HelpDesk*)sharedInstance;



#pragma mark -Custom Getters And Setters
//(notice the name of the getter and setter functions are  different from the name fo the variables and that's why I didn't declare them as property ,I don't want the compiler to genrate accessors for these variables on it's own)
//custom getter setter for mMAccessTokenHelpDesk
-(ModelAccessTokenHelpDesk*) getAccessTokenHelpDesk;
-(void) setAccessTokenHelpDesk:(ModelAccessTokenHelpDesk*) mInput;

//custom getter setter for mStrAccessToken
//-(NSString*) getAccessToken;
//-(void) setAccessToken:(NSString*) mInput;

- (NSString *)getAppApiKeyHelpDesk;

- (void)setAppApiKeyHelpDesk:(NSString *)mInput;

-(NSString*) getChatUrl;
-(void) setChatUrl:(NSString*) mInput;


-(NSString*) getGCMRegIdHelpDesk;
-(void) setGCMRegId:(NSString*) mInput;

-(NSString*) getUserEmailId;
-(void) setUserEmailId:(NSString*) mInput;


-(NSString*) getSenderId;
-(void) setSenderId:(NSString*) mInput;

-(NSString*) getNavigationBarColor;
-(void) setNavigationBarColor:(NSString*) mInput;


-(NSString*) getNavigationBarTitleColor;
-(void) setNavigationBarTitleColor:(NSString*) mInput;

-(bool) getNotificationsEnabled;
-(void) setNotificationsEnabled:(bool) mInput;

-(bool) getHasAccessTokenBeenChanged;
-(void) setHasAccessTokenBeenChanged:(bool) mInput;

-(NSString*) getEnvironmentType;
-(void) setEnvironmentType:(NSString*) mInput;


-(CUSTicketDetailsViewController *)getTicketDetailsViewController;
-(void)setTicketDetailsViewController:(CUSTicketDetailsViewController *)cusArgTicketDetailsViewController;
#pragma mark - other fucntionality
-(bool)checkIfAccessTokenHasBeenVerified;

- (void)registerForPushNotifications:(UIApplication *)application launchOptions:(NSDictionary *)launchOptions window:(UIWindow *)window;
-(void)handlePushNotificationRecieved:(NSDictionary *)userInfo launchTicketDetailsWithoutCheckignAnything:(BOOL) cusArgBoolLaunchWithOutChecking window:(UIWindow *)window;


#pragma mark - Install  fucntionality
-(void)install:(NSString*) cusStrArgApiToken;
-(void)install:(NSString*) cusStrArgApiToken withOptions: (NSMutableDictionary*) cusNsmdOptions;


#pragma mark - Launching Functions
-(void)launchTicketsModule:(UIViewController*) mCurrentViewController;


@end
