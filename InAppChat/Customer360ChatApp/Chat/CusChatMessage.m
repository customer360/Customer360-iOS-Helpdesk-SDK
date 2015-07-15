//
//  Message.m
//  ChatForText
//
//  Created by Anveshan Technologies on 12/03/15.
//
//
#import "CusChatMessage.h"

@implementation CusChatMessage

- (id)initWithDict:(NSMutableDictionary *)dict{
    
    self.strIcon = dict[@"strIcon"];
    self.strName = dict[@"strName"];
    
    if ([dict[@"from"] intValue]==1) {
        self.from = MessageFromMe;
    }
    else{
        self.from = MessageFromOther;
    }
    
    self.type = MessageTypeText;
    self.strContent = dict[@"strContent"];
    return self;
}

@end
