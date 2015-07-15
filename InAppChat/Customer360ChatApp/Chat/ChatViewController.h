//
//  ChatViewController.h
//  InAppChat
//
//  Created by Anveshan Technologies on 12/03/15.
//
//

#import <UIKit/UIKit.h>
#import "XMPP.h"
#import "XMPPMessage.h"
#import "CusChatUiViewControllerBase.h"
#import "CusChatMessage.h"
#import "CusChatMessageCell.h"
@interface ChatViewController : CusChatUiViewControllerBase
{
    NSString	*chatWithUser;
    UITableView		*tView;
    NSTimer *pingTimer;
    NSMutableArray *turnSockets;
    
}

@property (nonatomic, strong) IBOutlet UITextView *messageField;
@property (strong, nonatomic) IBOutlet UILabel *typing;
@property (strong, nonatomic) IBOutlet UIView *baseView;
@property (strong, nonatomic) IBOutlet UIView *sendBtn;

@property (nonatomic, strong ) NSString *agentName ;
@property (nonatomic, strong) NSMutableArray *messages;

@end
