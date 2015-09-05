//
//  Cus360HelpDesk.h
//  DemoAppHelpDesk
//
//  Created by Anveshan Technologies on 24/02/15.
//
//  

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol Cus360HelpDeskDelegate<NSObject>
-(void)setNotificationCount:(NSString *)count;
@end

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

extern NSString * const cusConstStrKeyHelpDeskFormID;
extern NSString * const cusConstStrKeyHelpDeskSourceID;
extern NSString * const cusConstStrKeyBackgroundColor;
extern NSString * const cusConstStrKeyTextColor;
extern NSString * const cusConstStrKeyHelpDeskVisitorID;

extern NSString * const cusConstStrKeyTitle;
extern NSString * const cusConstStrKeyTitleRaiseTicket;
extern NSString * const cusConstStrKeyTitleConversation;
extern NSString * const cusConstStrKeyTitleThankYou;
extern NSString * const cusConstStrKeyThankYouMessage;
extern NSString * const cusConstStrKeyUserEmail;
extern NSString * const cusConstStrKeySubject;
extern NSString * const cusConstStrKeyFeedback;
extern NSString * const cusConstStrKeyNavBarGradientColorFirst;
extern NSString * const cusConstStrKeyNavBarGradientColorSecond;


@interface Cus360HelpDesk :NSObject
{
    CUSTicketDetailsViewController* cusUivcTicketDetailsController;
    ModelAccessTokenHelpDesk *cusMAccessTokenHelpDesk;
    
    //your access token , you can find this by loggin in to you customer 360 dashboard
    //    NSString* cusStrAcessToken;
    
    
    //Change Navigation bar gradient color
    NSString* cusStrGradientColorFirst;
    NSString* cusStrGradientColorSecond;

    //visitor id
    NSString* cusStrHelpVisitorId;
    
    //form id
    NSString* cusStrHelpDeskFormId;
    
    //source id
    NSString* cusStrHelpDeskSourceId;
    
    //background color
    NSString* cusStrHelpDeskBackgroundColor;
    
    //text color
    NSString* cusStrHelpDeskTextColor;
    
    //your App Api Key , you can find this by loggin in to you customer 360 dashboard
    NSString* cusStrAppApiKeyHelpDesk;
    
    //auto set field .. chat url comes from the api on the basis of your access token
    NSString* cusStrChatUrl;
    
    //GCM registraion Id for your device...
    NSString* cusHelpDeskStrGCMRegId;
    
    //user email id
    NSString* cusHelpDeskStrEmaiId;
    
    //user sender id
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
    
}

@property(weak,nonatomic)id<Cus360HelpDeskDelegate> delegate;
-(void)callToUpdateCount2;

@property (nonatomic, strong) UIViewController *cusBaseView;
@property (nonatomic, strong) NSMutableArray *unreadHelpDesk;
@property (nonatomic, strong) UIColor *defaultTextColor;
@property (nonatomic, strong, readonly) NSString* cusStrDeveloperEmaiId;
@property (nonatomic, strong, readonly) NSString* cusStrSubject;
@property (nonatomic, strong, readonly) NSString* cusStrUserFeedback;
@property (nonatomic, strong, readonly) NSString* cusStrNavBarTitleListing;
@property (nonatomic, strong, readonly) NSString* cusStrNavBarTitleRaiseTIcket;
@property (nonatomic, strong, readonly) NSString* cusStrNavBarTitleConversation;
@property (nonatomic, strong, readonly) NSString* cusStrNavBarTitleThankYou;
@property (nonatomic, strong, readonly) NSString* cusStrThankYouMessage;
@property (nonatomic) BOOL getFormID;

#pragma mark - singleton getInstance() method...
+(Cus360HelpDesk*)sharedInstance;


#pragma mark -Custom Getters And Setters
//(notice the name of the getter and setter functions are  different from the name fo the variables and that's why I didn't declare them as property ,I don't want the compiler to genrate accessors for these variables on it's own)

//custom getter setter for mMAccessTokenHelpDesk
-(ModelAccessTokenHelpDesk*) getAccessTokenHelpDesk;
-(void) setAccessTokenHelpDesk:(ModelAccessTokenHelpDesk*) mInput;

//custom getter setter for mStrAccessToken
//-(NSString*) getAccessToken;
//-(void) setAccessToken:(NSString*) mInput;

-(NSString*) getGradientColorFirst;
-(void) setGradientColorFirst:(NSString*) mInput;

-(NSString*) getGradientColorSecond;
-(void) setGradientColorSecond:(NSString*) mInput;

-(void)catchCrashReport:(NSException *)exception;
-(NSMutableDictionary*)saveinfo;

- (NSString *)getVisitorIDId;
- (void)setVisitorIDId:(NSString *)mInput;

- (NSString *)getBackgroundColor;
- (void)setBackgroundColor:(NSString *)mInput;

-(NSString *)getHelpDeskTextColor;
-(void) setHelpDeskTextColor:(NSString *)mInput;

- (NSString *)getAppApiKeyHelpDesk;
- (void)setAppApiKeyHelpDesk:(NSString *)mInput;

-(NSString*) getChatUrl;
-(void) setChatUrl:(NSString*) mInput;

-(NSString*) getGCMRegIdHelpDesk;
-(void) setGCMRegId:(NSString*) mInput;

-(NSString*) getUserEmailId;
-(void) setUserEmailId:(NSString*) mInput;

-(NSString*) getHelpDeskFormID;
-(void) setHelpDeskFormID:(NSString*) mInput;

-(NSString*) getHelpDeskSourceID;
-(void) setHelpDeskSourceID:(NSString*) mInput;

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
