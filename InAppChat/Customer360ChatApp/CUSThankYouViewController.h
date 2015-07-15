//
//  CUSThankYouViewController.h
//  Customer360SDK
//
//  Created by Customer360 on 15/12/14.
//  Copyright (c) 2014 Customer360. All rights reserved.
//



#import "CusChatUiViewControllerBase.h"

@class CUSCreateTicketViewController;

@interface CUSThankYouViewController : CusChatUiViewControllerBase

@property (strong, nonatomic) IBOutlet UILabel *cusArgUilTicketRefNoTxt;
@property (strong, nonatomic) IBOutlet UITextView *cusArgUilTicketResp;

@property (strong, nonatomic) NSDictionary *cusNsmdTicketIdResponseobject;

@property (strong,nonatomic) CUSCreateTicketViewController *cusCreateTicketViewController;
@property (nonatomic) BOOL online;

@end
