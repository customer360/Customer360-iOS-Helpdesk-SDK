//
//  CUSThankYouViewController.m
//  Customer360SDK
//
//  Created by Customer360 on 15/12/14.
//  Copyright (c) 2014 Customer360. All rights reserved.
//

#import "CUSThankYouViewController.h"
//#import "CUSApiHelper.h"
//#import "CUSCreateTicketViewController.h"
#define FONT_SIZE 16
#define FONT_HELVETICA @"Helvetica-Light"
#define BLACK_SHADOW [UIColor colorWithRed:40.0f/255.0f green:40.0f/255.0f blue:40.0f/255.0f alpha:0.4f]

@interface CUSThankYouViewController ()

@end

@implementation CUSThankYouViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self performSubClassWork];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)finishThisPage{
    
/*
     [UIView animateWithDuration:0.05 animations:^{
     [[[Cus360 sharedInstance]cusBaseView] dismissViewControllerAnimated:NO completion:nil];
     }];
     
*/
    [super finishThisPage];
}
- (void)performSubClassWork {
    [super performSubClassWork];


    if (self.online) {
        
        [[_cusArgUilTicketResp layer] setBorderColor:[[UIColor grayColor] CGColor]];
        [[_cusArgUilTicketResp layer] setBorderWidth:0.5 ];
        [[_cusArgUilTicketResp layer] setCornerRadius:5];
       
        
        NSMutableAttributedString *attText1 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"We appreciate your time and valuable feedback in helping us improve!"] attributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0], NSFontAttributeName:[UIFont systemFontOfSize:16]}];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setAlignment:NSTextAlignmentCenter];
        [attText1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attText1.length)];

        _cusArgUilTicketResp.attributedText=attText1;

    }
    
    else
    
    {
//    _cusArgUilTicketRefNoTxt.lineBreakMode= NSLineBreakByWordWrapping;
//    _cusArgUilTicketRefNoTxt.numberOfLines = 3;
    
//    _cusArgUilTicketRefNoTxt.text =[NSString stringWithFormat: @"Your ticket with reference no : #%@ has been submitted" ,[self extractTicketIdRefNo]];
    
    [[_cusArgUilTicketResp layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[_cusArgUilTicketResp layer] setBorderWidth:0.5 ];
    [[_cusArgUilTicketResp layer] setCornerRadius:5];
//    _cusArgUilTicketRefNoTxt.textAlignment = NSTextAlignmentCenter;


    NSMutableAttributedString *attText1 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Thanks for leaving your message. We will shortly get back to you."] attributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0],NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    [attText1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attText1.length)];
    _cusArgUilTicketResp.attributedText=attText1;
    }
}
/*

-(NSString*)extractTicketIdRefNo{
     // NSDictionary* cusNsdResponseAccessToken  = (NSDictionary *)_cusNsmdTicketIdResponseobject;
    
    NSString* myval =   [[_cusNsmdTicketIdResponseobject objectForKey:@"response"] objectForKey:@"ticket_id"];
    return [NSString stringWithFormat:@"#%@", myval  ];
    
}*/
- (IBAction)doOnCloseButtonCliked:(id)sender
{
//    self.cusCreateTicketViewController.cusNsnumBoolFinishThisPage  = [NSNumber numberWithBool:YES];
    [self finishThisPage];
}

@end
