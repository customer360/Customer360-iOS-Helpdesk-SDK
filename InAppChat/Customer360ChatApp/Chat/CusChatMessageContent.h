//
//  MessageContentButton.h
//  ChatForText
//
//  Created by Anveshan Technologies on 12/03/15.
//
//


#import <UIKit/UIKit.h>

@interface CusChatMessageContent : UITextView

@property (nonatomic, retain) UILabel *second;
@property (nonatomic, retain) UIActivityIndicatorView *indicator;

@property (nonatomic, assign) BOOL isMyMessage;

 
@end
