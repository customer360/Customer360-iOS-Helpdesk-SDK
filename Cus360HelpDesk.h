//
//  Cus360HelpDesk.h
//  DemoAppHelpDesk
//
//  Created by Anveshan Technologies on 24/02/15.
//
//

#import <Foundation/Foundation.h>
#import "Cus360.h"
@class CUSTicketDetailsViewController;

@interface Cus360HelpDesk :Cus360
{
    CUSTicketDetailsViewController* cusUivcTicketDetailsController;
}
@property (nonatomic, strong) NSMutableArray *unread;

-(CUSTicketDetailsViewController *)getTicketDetailsViewController;
-(void)setTicketDetailsViewController:(CUSTicketDetailsViewController *)cusArgTicketDetailsViewController;

+(Cus360HelpDesk*)sharedInstance;

- (void)registerForPushNotifications:(UIApplication *)application launchOptions:(NSDictionary *)launchOptions window:(UIWindow *)window;
-(void)handlePushNotificationRecieved:(NSDictionary *)userInfo launchTicketDetailsWithoutCheckignAnything:(BOOL) cusArgBoolLaunchWithOutChecking window:(UIWindow *)window;

#pragma mark - Launching Functions
-(void)launchTicketsModule:(UIViewController*) mCurrentViewController;


@end
