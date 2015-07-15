//
//  ModelAccessToken.m
//  Customer360SDK
//
//  Created by Customer360 on 25/12/14.
//  Copyright (c) 2014 Customer360. All rights reserved.
//

#import "ModelAccessTokenChat.h"

@implementation ModelAccessTokenChat
- (instancetype)initWithId:(NSMutableString *)cusStrArgId andAccessToken:(NSMutableString *)cusStrArgAccessToken {
    self = [super init];
    if (self) {
        self.cusNsstrId=cusStrArgId;
        self.cusNsstrAccessToken=cusStrArgAccessToken;
    }
    return self;
}

- (instancetype)initFromJsonString:(NSMutableString *)cusStrArgJsonString{
    self = [super init];
    if (self) {
        NSError *error;
        NSDictionary *JSON =
                [NSJSONSerialization JSONObjectWithData: [cusStrArgJsonString dataUsingEncoding:NSUTF8StringEncoding]
                                                options: NSJSONReadingMutableContainers
                                                  error: &error];

        self.cusNsstrId= [JSON objectForKey:@"id"];
        self.cusNsstrAccessToken=[JSON objectForKey:@"access_token"];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
      self.cusNsstrId=@"".mutableCopy;
      self.cusNsstrAccessToken=@"".mutableCopy;
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.cusNsstrId forKey:@"id"];
    [encoder encodeObject:self.cusNsstrAccessToken forKey:@"access_token"];
}

-(NSMutableString *)toString{

    NSMutableDictionary* cusNsmdJsonParams = [[NSMutableDictionary alloc] init];
    [cusNsmdJsonParams setObject:_cusNsstrAccessToken forKey:@"access_token"];
    [cusNsmdJsonParams setObject:_cusNsstrId forKey:@"id"];

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:cusNsmdJsonParams
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
        jsonString=@"{id:"",access_token:""}";
    } else {

    }

    return jsonString.mutableCopy;
}


- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.cusNsstrId = [decoder decodeObjectForKey:@"id"];
        self.cusNsstrAccessToken = [decoder decodeObjectForKey:@"access_token"];
    }
    return self;
}


@end
