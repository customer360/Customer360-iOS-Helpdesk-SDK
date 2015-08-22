//
//  MessageCell.h
//  ChatForText
//
//  Created by Anveshan Technologies on 12/03/15.
//
//
#import <UIKit/UIKit.h>

#import "CusChatMessage.h"

@class CusChatMessageFrame;
@class CusChatMessageCell;

@interface CusChatMessageCell : UITableViewCell

-(void)setMessage:(CusChatMessage *)message withGrouping:(BOOL)isGroup;

@end

