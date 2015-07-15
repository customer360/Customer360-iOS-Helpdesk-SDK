//
//  MessageFrame.m
//  ChatForText
//
//  Created by Anveshan Technologies on 12/03/15.
//
//

#import "CusChatMessageFrame.h"
#import "CusChatMessage.h"

@implementation CusChatMessageFrame
- (void)setMessage:(CusChatMessage *)message
{
    _message = message;
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;

    CGFloat iconX = ChatMargin;
    if (message.from == MessageFromMe) {
        iconX = screenW - ChatIconWH-ChatMargin;
    }
    CGFloat iconY = ChatMargin;
    _iconF = CGRectMake(iconX, iconY, ChatIconWH, ChatIconWH);

    CGFloat contentX = CGRectGetMaxX(_iconF)+ChatMargin;
    CGFloat contentY = iconY;

    CGRect content = [_message.strContent boundingRectWithSize:CGSizeMake(screenW-130, CGFLOAT_MAX) options:(NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15.0]} context:nil];
  
    if (_message.from == MessageFromMe)
    {
        contentX = iconX - content.size.width - ChatContentLeft - ChatContentRight - ChatMargin-ChatMargin;
       
    }
    _contentF = CGRectMake(contentX, contentY+20, content.size.width + ChatContentLeft + ChatContentRight, content.size.height + ChatContentTop + ChatContentBottom);
     _nameF = CGRectMake(contentX, iconY, content.size.width, 20);
    
    _cellHeight = MAX(CGRectGetMaxY(_contentF), CGRectGetMaxY(_nameF)) ;// + ChatMargin;
    
}

@end
