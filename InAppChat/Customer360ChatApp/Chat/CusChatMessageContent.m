//
//  MessageContentButton.m
//  ChatForText
//
//  Created by Anveshan Technologies on 12/03/15.
//
//
#import "CusChatMessageContent.h"
@implementation CusChatMessageContent

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
    }
    return self;
}

- (void)setIsMyMessage:(BOOL)isMyMessage
{
    _isMyMessage = isMyMessage;
           //43, 96, 222 Royal Blue
        self.tintColor =[UIColor colorWithRed:43.0/255.0 green:96.0/255.0 blue:222.0/255.0 alpha:1.0];

}
@end
