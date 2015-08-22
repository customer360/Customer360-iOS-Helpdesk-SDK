//
//  ModelAccessToken.h
//  Customer360SDK
//
//  Created by Customer360 on 25/12/14.
//  Copyright (c) 2014 Customer360. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModelAccessTokenChat : NSObject

@property (strong,nonatomic) NSMutableString * cusNsstrId;
@property (strong,nonatomic) NSMutableString * cusNsstrAccessToken;

- (instancetype)initWithId:(NSMutableString *)cusStrArgId andAccessToken:(NSMutableString *)cusStrArgAccessToken;


- (instancetype)initFromJsonString:(NSMutableString *)cusStrArgJsonString;

- (id)initWithCoder:(NSCoder *)coder;

- (void)encodeWithCoder:(NSCoder *)coder;

- (NSMutableString *)toString;
@end
