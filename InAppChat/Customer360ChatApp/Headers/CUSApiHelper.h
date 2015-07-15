//
//  ApiHelper.h
//  Customer360SDK
//
//  Created by Customer360 on 03/12/14.
//  Copyright (c) 2014 Customer360. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CUSApiHelper : NSObject

+ (NSMutableString *)fetchBaseApiUrl;

+(void) verifyAccessTokenFromViewController : (id)cusArgObViewControllerThatContainsTheCallBackFunctions withOnSuccessCallBack:(SEL) cusArgSelOnSuccess andOnFailureCallBack: (SEL) cusArgSelOnFailure;

+(void)parseAccessTokenSuccessResponse:(id)cusArgResponseObject typeOfToken:(NSString*)typeOfToken;
 
+ (NSMutableDictionary *)addCommonParams:(NSMutableDictionary *)cusArgnsmdParams;

+(bool) checkIfFetchDataWasSuccess:(id)cusArgResponseob;
+(NSDictionary*) fetchResponseKeyFromResponse:(id)cusArgResponseob;
+(NSString*)base64forData:(NSData*)theData ;
@end
