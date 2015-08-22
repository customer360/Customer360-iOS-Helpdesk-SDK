//
//  Message.h
//  ChatForText
//
//  Created by Anveshan Technologies on 12/03/15.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define ChatContentFontSize 16
#define ChatContentFont [UIFont systemFontOfSize:ChatContentFontSize]

typedef enum {
    MessageTypeText     = 0 , 
    MessageTypePicture  = 1 ,
    MessageTypeVoice    = 2   
} MessageType;


typedef enum {
    MessageFromMe    = 100,   
    MessageFromOther = 101
} MessageFrom;


@interface CusChatMessage : NSObject

@property (nonatomic, copy) NSString *strIcon;
@property (nonatomic, copy) NSString *strName;
@property (nonatomic, copy) NSString *strContent;
@property (nonatomic, copy) NSString *strTime;


@property (nonatomic, assign) MessageType type;
@property (nonatomic, assign) MessageFrom from;


- (id)initWithDict:(NSDictionary *)dict;
- (CGRect)contentSize;

@end
