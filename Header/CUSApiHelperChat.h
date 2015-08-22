//
//  ApiHelper.h
//  Customer360SDK
//
//  Created by Customer360 on 03/12/14.
//  Copyright (c) 2014 Customer360. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "CUSApiHelper.h"
@interface CUSApiHelperChat : NSObject

+ (NSMutableString *)fetchBaseApiUrl;
//
+(void) verifyAccessTokenFromViewController : (id)cusArgObViewControllerThatContainsTheCallBackFunctions withOnSuccessCallBack:(SEL) cusArgSelOnSuccess andOnFailureCallBack: (SEL) cusArgSelOnFailure;
//
+(void)parseAccessTokenSuccessResponse:(id)cusArgResponseObject;
+(void)changeStatus : (id)cusArgObViewControllerThatContainsTheCallBackFunctions withOnSuccessCallBack:(SEL) cusArgSelOnSuccess andOnFailureCallBack: (SEL) cusArgSelOnFailure withParams:(NSString*) status;


+(void)saveVisitorInfo : (id)cusArgObViewControllerThatContainsTheCallBackFunctions withOnSuccessCallBack:(SEL) cusArgSelOnSuccess andOnFailureCallBack: (SEL) cusArgSelOnFailure withParams:(NSMutableDictionary*) visitorInfo;

+(void) getPreChatForm : (id)cusArgObViewControllerThatContainsTheCallBackFunctions withOnSuccessCallBack:(SEL) cusArgSelOnSuccess andOnFailureCallBack: (SEL) cusArgSelOnFailure;

+(void)getPreChatHistory : (id)cusArgObViewControllerThatContainsTheCallBackFunctions withOnSuccessCallBack:(SEL) cusArgSelOnSuccess andOnFailureCallBack: (SEL) cusArgSelOnFailure withParams:(NSString *) params;

+(void)getChatEvents : (id)cusArgObViewControllerThatContainsTheCallBackFunctions withOnSuccessCallBack:(SEL) cusArgSelOnSuccess andOnFailureCallBack: (SEL) cusArgSelOnFailure withParams:(NSString *) params;

+ (void)getAgentProfileDetail : (id)delegateVC withOnSuccessCallBack:(SEL) successCallback andOnFailureCallBack: (SEL) failCallback;

//
+ (NSMutableDictionary *)addCommonParams:(NSMutableDictionary *)cusArgnsmdParams;
//
+(bool) checkIfFetchDataWasSuccess:(id)cusArgResponseob;
+(NSDictionary*) fetchResponseKeyFromResponse:(id)cusArgResponseob;
+(NSString*)base64forData:(NSData*)theData ;


@end
