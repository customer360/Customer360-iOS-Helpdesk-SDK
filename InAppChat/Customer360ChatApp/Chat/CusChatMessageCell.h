//
//  MessageCell.h
//  ChatForText
//
//  Created by Anveshan Technologies on 12/03/15.
//
//
#import <UIKit/UIKit.h>
#import "CusChatMessageContent.h"
#import "CusChatMessage.h"
#import "AsyncImageView.h"

@class CusChatMessageFrame;
@class CusChatMessageCell;

@protocol MessageCellDelegate <NSObject>
@optional

- (void)cellContentDidClick:(CusChatMessageCell *)cell image:(UIImage *)contentImage;
@end


@interface CusChatMessageCell : UITableViewCell

@property (nonatomic, strong)UILabel *labelName;
@property (nonatomic, strong)AsyncImageView *btnHeadImage;

@property (nonatomic, strong)CusChatMessageContent *btnContent;
@property (nonatomic, strong)CusChatMessageFrame *messageFrame;
@property (nonatomic, strong)CusChatMessage *message ;

@property (nonatomic, assign)id<MessageCellDelegate>delegate;
-(void)setMessage:(CusChatMessage *)message;

@end

