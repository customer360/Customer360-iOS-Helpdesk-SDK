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
#define ChatTimeFont [UIFont boldSystemFontOfSize:14]  
#define ChatContentFont [UIFont systemFontOfSize:14]

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class CusChatMessage;

@interface CusChatMessageFrame : NSObject

@property (nonatomic, assign, readonly) CGRect nameF;
@property (nonatomic, assign, readonly) CGRect iconF;
@property (nonatomic, assign, readonly) CGRect contentF;

@property (nonatomic, assign, readonly) CGFloat cellHeight;
@property (nonatomic, strong) CusChatMessage *message;

@end
