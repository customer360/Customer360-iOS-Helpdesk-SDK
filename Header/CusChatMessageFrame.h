//
//  MessageFrame.h
//  ChatForText
//
//  Created by Anveshan Technologies on 12/03/15.
//
//

#define ChatMargin 8       
#define ChatIconWH 32      
#define ChatPicWH 200      
#define ChatContentW 180    

#define ChatTimeMarginW 8  
#define ChatTimeMarginH 8  

#define ChatContentTop 16
#define ChatContentLeft 16
#define ChatContentBottom 16
#define ChatContentRight 16 

#define ChatBlurbX 8
#define ChatBlurbY 8
#define ChatBlurbWeightMargin 64
#define ChatBlurbHeightMargin 16

#define BlurbPointer 7

#define ChatTimeFont [UIFont boldSystemFontOfSize:14]

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CusChatMessage.h"

@class CusChatMessage;

@interface CusChatMessageFrame : UIView

@property (nonatomic, assign, readonly) CGRect nameF;
@property (nonatomic, assign, readonly) CGRect contentF;
//@property (nonatomic, assign, readonly) CGFloat cellHeight;

@property (nonatomic, assign, readonly) CGRect blurbFrame;
@property (nonatomic, assign, readonly) CGRect contentFrame;

- (id)initWithMessage:(CusChatMessage *)message forGroup:(BOOL)isGroup;

@end