//
//  Cus360.h
//  Customer360SDK
//
//  Created by Customer360 on 02/12/14.
//  Copyright (c) 2014 Customer360. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ModelAccessToken;
//@class CUSTicketDetailsViewController;


extern NSString * const cusConstStrKeyAccessTokenHelpDesk;
//extern NSString * const cusConstStrKeyAccessToken;

extern NSString * const cusConstStrKeyAppApiKey;
extern NSString * const cusConstStrKeyUserEmailId;
extern NSString * const cusConstStrKeyGCMRegId;
extern NSString * const cusConstStrKeyUserSenderId;
extern NSString * const cusConstStrKeyChatUrl;
extern NSString * const cusConstStrKeyHAsAccesTokenBeenChanged;
extern NSString * const cusConstStrKeyNotificationsEnabled;
extern NSString * const cusConstStrKeyEnvironmentType;
extern NSString * const cusConstStrValueEnvironmentTypeLIVE;
extern NSString * const cusConstStrValueEnvironmentTypeTEST;
extern NSString * const cusConstStrKeyNavbarColor;
extern NSString * const cusConstStrKeyNavBarTitleColor;
extern NSString * const cusConstStrKeyTypeOfTokenUsed;

@interface Cus360 : NSObject{

    //your access token , you can find this by loggin in to you customer 360 dashboard
//    NSString* cusStrAcessToken;

    ModelAccessToken *cusMAccessTokenHelpDesk;

//    ModelAccessToken *cusMAccessToken;
    //your App Api Key , you can find this by loggin in to you customer 360 dashboard
    NSString* cusStrAppApiKey;

    //auto set field .. chat url comes from the api on the basis of your access token
    NSString* cusStrChatUrl;
    
    //choose from token comes from the api on the basis of your requirment
    NSString* cusStrTypeOfToken;

    //GCM registraion Id for your device...
    NSString* cusStrGCMRegId;
    
    //user email id
    NSString* cusStrEmaiId;
    
    //user email id
    NSString* cusStrSenderId;
    
    //flag to enable or disable notifications...
    NSNumber* cusNsnumNotificationsEnabled;
    
    //flag to enable or disable notifications...
    NSNumber* cusNsnumHasAccessTokenBeenChanged;

    NSString *cusStrEnvironmentType;
    
    
    //Change Navigation bar color matching to your rest of the product...
    NSString* cusNavigationBarTintColor;
    
    //Change Navigation bar title color matching to your rest of the product...
    NSString* cusNavigationBarTitleColor;
    
    
//    CUSTicketDetailsViewController* cusUivcTicketDetailsController;
    
}


#pragma mark - singleton getInstance() method...
+(Cus360*)sharedInstance;


#pragma mark -Custom Getters And Setters
//(notice the name of the getter and setter functions are  different from the name fo the variables and that's why I didn't declare them as property ,I don't want the compiler to genrate accessors for these variables on it's own)
//custom getter setter for mMAccessTokenHelpDesk
-(ModelAccessToken*) getAccessTokenHelpDesk;
-(void) setAccessTokenHelpDesk:(ModelAccessToken*) mInput;

//-(ModelAccessToken*) getAccessToken;
//-(void) setAccessToken:(ModelAccessToken*) mInput;
//

//custom getter setter for mStrAccessToken
//-(NSString*) getAccessToken;
//-(void) setAccessToken:(NSString*) mInput;

- (NSString *)getAppApiKey;
- (void)setAppApiKey:(NSString *)mInput;


-(NSString*) getChatUrl;
-(void) setChatUrl:(NSString*) mInput;


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

-(bool) getNotificationsEnabled;
-(void) setNotificationsEnabled:(bool) mInput;

-(bool) getHasAccessTokenBeenChanged;
-(void) setHasAccessTokenBeenChanged:(bool) mInput;

-(NSString*) getEnvironmentType;
-(void) setEnvironmentType:(NSString*) mInput;
//
//-(CUSTicketDetailsViewController *)getTicketDetailsViewController;
//-(void)setTicketDetailsViewController:(CUSTicketDetailsViewController *)cusArgTicketDetailsViewController;


-(NSString*) getTypeOfToken;
-(void) setTypeOfToken:(NSString*) mInput;


#pragma mark - other fucntionality
-(bool)checkIfAccessTokenHasBeenVerified;


#pragma mark - Install  fucntionality
-(void)install:(NSString*) cusStrArgApiToken;
-(void)install:(NSString*) cusStrArgApiToken withOptions: (NSMutableDictionary*) cusNsmdOptions;

//
//#pragma mark - Launching Functions
//-(void)launchTicketsModule:(UIViewController*) mCurrentViewController;
//
@end
