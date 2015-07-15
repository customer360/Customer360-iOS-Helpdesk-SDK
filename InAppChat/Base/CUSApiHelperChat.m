//
//  ApiHelper.m
//  Customer360SDK
//
//  Created by Customer360 on 03/12/14.
//  Copyright (c) 2014 Customer360. All rights reserved.
//

#import "CUSApiHelperChat.h"
#import "AFHTTPRequestOperation.h"
#import "Cus360Chat.h"
#import "HomerUtils.h"
#import "ModelAccessTokenChat.h"

static NSString * const cusStrApiBaseURLQa = @"http://c360qa.c360dev.in/widget";
//static NSString * const cusStrApiBaseURLQa = @"http://c360all.c360dev.in/widget";
static NSString * const cusStrApiBaseURLLive = @"https://app.customer360.co/widget";

@implementation CUSApiHelperChat

static NSMutableString * cusStrApiBaseURL = @"http://c360qa.c360dev.in/widget";

+(NSMutableString *)fetchBaseApiUrl{

    if([[[Cus360Chat sharedInstance] getEnvironmentType] isEqualToString:cusChatConstStrValueEnvironmentTypeTEST]){

        cusStrApiBaseURL = [cusStrApiBaseURLQa mutableCopy];
    }else if([[[Cus360Chat sharedInstance] getEnvironmentType] isEqualToString:cusChatConstStrValueEnvironmentTypeLIVE]){
        cusStrApiBaseURL   = [cusStrApiBaseURLLive mutableCopy];
    }
    return cusStrApiBaseURL;
}


+(NSMutableDictionary *)addCommonParams:(NSMutableDictionary *)cusArgnsmdParams{

    if(cusArgnsmdParams!=nil)
    {
        ModelAccessTokenChat *mtempAccessToken= [[Cus360Chat sharedInstance] getAccessTokenChat] ;
        
        if(mtempAccessToken!=nil&& ![HomerUtils stringIsEmpty:mtempAccessToken.cusNsstrAccessToken])
        {
            [cusArgnsmdParams setObject:mtempAccessToken.cusNsstrAccessToken forKey:@"access_token"];
        }
        [cusArgnsmdParams setObject:[[Cus360Chat sharedInstance] getAppApiKey] forKey:@"api_key"];
        NSString* appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
        [cusArgnsmdParams setObject:appID forKey:@"identifier"];

        NSString *preChatFormId = [[NSUserDefaults standardUserDefaults] objectForKey:@"inapp_prechat_form_id"];
        [cusArgnsmdParams setObject:preChatFormId forKey:@"form_id"];

        NSLog(@"access_token:%@",mtempAccessToken.cusNsstrAccessToken);
        NSLog(@"api_key:%@",[[Cus360Chat sharedInstance] getAppApiKey]);
        NSLog(@"identifier:%@",appID);
        NSLog(@"form_id:%@",preChatFormId);
    }
    return  cusArgnsmdParams;
}

+(void) verifyAccessTokenFromViewController : (id)cusArgObViewControllerThatContainsTheCallBackFunctions withOnSuccessCallBack:(SEL) cusArgSelOnSuccess andOnFailureCallBack: (SEL) cusArgSelOnFailure {
    
    //preparing url
    NSString* cusStrUrl = [NSString stringWithFormat:@"%@/authenticateInAppWidget", [CUSApiHelperChat fetchBaseApiUrl]];
    
    //preparing params
    NSMutableDictionary * cusNsdParams = [[NSMutableDictionary alloc] init];
    
    //[CUSApiHelperChat addCommonParams:cusNsdParams];
    
    ModelAccessTokenChat *mtempAccessToken= [[Cus360Chat sharedInstance] getAccessTokenChat] ;
    
    if(mtempAccessToken!=nil&& ![HomerUtils stringIsEmpty:mtempAccessToken.cusNsstrAccessToken])
    {
        [cusNsdParams setObject:mtempAccessToken.cusNsstrAccessToken forKey:@"access_token"];
    }
    [cusNsdParams setObject:[[Cus360Chat sharedInstance] getAppApiKey] forKey:@"api_key"];
    NSString* appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    [cusNsdParams setObject:appID forKey:@"identifier"];
    
    //executing post request ....
    [HomerUtils executePostForUrl:cusStrUrl withParams:cusNsdParams fromViewController:cusArgObViewControllerThatContainsTheCallBackFunctions  withOnSuccessCallBack:cusArgSelOnSuccess andOnFailureCallBack:cusArgSelOnFailure];
    
};

+(void)parseAccessTokenSuccessResponse:(id)cusArgResponseObject
{
    //parsing data
    NSDictionary* cusNsdResponseAccessToken  = (NSDictionary *)cusArgResponseObject;
    NSDictionary* cusNsdProductData = (NSDictionary*)[[cusNsdResponseAccessToken objectForKey:@"response"] objectForKey:@"product_data"];
    NSString* cusNsstrSenderId =[cusNsdProductData objectForKey:@"project_number"];
    //    NSString* cusNsstrChatUrl =[cusNsdProductData objectForKey:@"chat_url"];
    
    //    NSDictionary* cusNsdAccess_tokens = (NSDictionary*)[[cusNsdResponseAccessToken objectForKey:@"response"] objectForKey:@"access_tokens"];
    
    NSDictionary* cusNsdAccess_token_helpdesk = (NSDictionary*)[[[cusNsdResponseAccessToken objectForKey:@"response"] objectForKey:@"access_tokens"]objectForKey:@"chat"];
    
    ModelAccessTokenChat * mTempAccessToken = [[ModelAccessTokenChat alloc] init];
    mTempAccessToken.cusNsstrId = [cusNsdAccess_token_helpdesk objectForKey:@"id"];
    mTempAccessToken.cusNsstrAccessToken = [cusNsdAccess_token_helpdesk objectForKey:@"access_token"];
    
    [[Cus360Chat sharedInstance] setAccessTokenChat:mTempAccessToken];
    NSLog(@"AccessTokenChat: %@ ", [[Cus360Chat sharedInstance] getAccessTokenChat].cusNsstrAccessToken);
    //setting Cus360 required variables...!!!
    [[Cus360Chat sharedInstance] setSenderId:cusNsstrSenderId];
    NSLog(@"SenderId: %@ ", [[Cus360Chat sharedInstance] getSenderId]);
    
    [[Cus360Chat sharedInstance] setHasAccessTokenBeenChanged:NO];
}

+(void)saveVisitorInfo : (id)cusArgObViewControllerThatContainsTheCallBackFunctions withOnSuccessCallBack:(SEL) cusArgSelOnSuccess andOnFailureCallBack: (SEL) cusArgSelOnFailure withParams:(NSMutableDictionary*) visitorInfo{
    
    //preparing url
    NSString* cusStrUrl = [NSString stringWithFormat:@"%@/visitorInfo",[CUSApiHelperChat fetchBaseApiUrl]];
    
    NSMutableDictionary* cusNsmdJsonParams = [[NSMutableDictionary alloc] init];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:visitorInfo
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        
    }
    //preparing params
    [cusNsmdJsonParams setObject:jsonString forKey:@"visitorInfo"];
    
    [cusNsmdJsonParams setObject:@"inapp" forKey:@"source"];
    [cusNsmdJsonParams setObject:@"0" forKey:@"domain_id"];
    NSMutableDictionary* cusNsmdParams = [[NSMutableDictionary alloc] init];
    
    jsonData = [NSJSONSerialization dataWithJSONObject:cusNsmdJsonParams
                                               options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                 error:&error];
    jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [CUSApiHelperChat addCommonParams:cusNsmdParams];
    [cusNsmdParams setObject:jsonString forKey:@"params"];
    
    //executing post request ....
    [HomerUtils executePostForUrl:cusStrUrl withParams:cusNsmdParams fromViewController:cusArgObViewControllerThatContainsTheCallBackFunctions  withOnSuccessCallBack:cusArgSelOnSuccess andOnFailureCallBack:cusArgSelOnFailure];
}

+(void) getPreChatForm : (id)cusArgObViewControllerThatContainsTheCallBackFunctions withOnSuccessCallBack:(SEL) cusArgSelOnSuccess andOnFailureCallBack: (SEL) cusArgSelOnFailure {
    
    //preparing url
    ModelAccessTokenChat *chatToken = [[Cus360Chat sharedInstance] getAccessTokenChat];
    NSString *url=[[NSString alloc] init];
    
   // [[NSUserDefaults standardUserDefaults] setObject:preChatFormId forKey:@"inapp_prechat_form_id"];
   // [[NSUserDefaults standardUserDefaults] setObject:status forKey:@"widget_status"];
    NSString *status = [[NSUserDefaults standardUserDefaults] objectForKey:@"widget_status"];
    NSString *prechatFormId = [[NSUserDefaults standardUserDefaults] objectForKey:@"inapp_prechat_form_id"];
    if ([status isEqualToString:@"online"]) {
        url = [NSString stringWithFormat:@"%@/getPrechatForm?access_token=%@",[CUSApiHelperChat fetchBaseApiUrl],chatToken.cusNsstrAccessToken];
    }
    else{
        url = [NSString stringWithFormat:@"%@/getPrechatOfflineForm?access_token=%@",[CUSApiHelperChat fetchBaseApiUrl],chatToken.cusNsstrAccessToken];
    }
    
    //preparing params
    NSMutableDictionary* cusNsmdParams = [[NSMutableDictionary alloc] init];
    
    [CUSApiHelperChat addCommonParams:cusNsmdParams];
    [cusNsmdParams setObject:@"inapp" forKey:@"source"];
    [cusNsmdParams setObject:prechatFormId forKey:@"form_id"];
    //[cusNsmdParams setObject:[[Cus360HelpDesk sharedInstance] getVisitorIDId] forKey:@"visitor_id"];
    
    //executing post request ....
    [HomerUtils executePostForUrl:url withParams:cusNsmdParams fromViewController:cusArgObViewControllerThatContainsTheCallBackFunctions  withOnSuccessCallBack:cusArgSelOnSuccess andOnFailureCallBack:cusArgSelOnFailure];
}


+(void)changeStatus : (id)cusArgObViewControllerThatContainsTheCallBackFunctions withOnSuccessCallBack:(SEL) cusArgSelOnSuccess andOnFailureCallBack: (SEL) cusArgSelOnFailure withParams:(NSString*) status{
    
    //preparing url
    NSString* cusStrUrl = [NSString stringWithFormat:@"%@/changeStatus",[CUSApiHelperChat fetchBaseApiUrl]];
    
    NSMutableDictionary* cusNsmdJsonParams = [[NSMutableDictionary alloc] init];
    [cusNsmdJsonParams setObject:status forKey:@"status"];
    
//    [cusNsmdJsonParams setObject:[[Cus360 sharedInstance] getGCMRegId] forKey:@"uid"];
      NSString *prechat_id= [[NSUserDefaults standardUserDefaults] objectForKey:@"prechat_id"];
//    NSString *agent_jid=[[NSUserDefaults standardUserDefaults] objectForKey:@"agent_jid"];
    [cusNsmdJsonParams setObject:prechat_id forKey:@"prechat_id"];
    
//    [cusNsmdJsonParams setObject:agent_jid forKey:@"agent_jid"];     [cusNsmdJsonParams setObject:@"agent" forKey:@"closedBy"];
//    [cusNsmdJsonParams setObject:@"inapp" forKey:@"source"];
      NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:cusNsmdJsonParams
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        
    }
    //preparing params
    NSMutableDictionary* cusNsmdParams = [[NSMutableDictionary alloc] init];
    
    [CUSApiHelperChat addCommonParams:cusNsmdParams];
    [cusNsmdParams setObject:jsonString forKey:@"params"];
//    NSLog(@"params:%@",jsonString);
    
    //executing post request ....
    [HomerUtils executePostForUrl:cusStrUrl withParams:cusNsmdParams fromViewController:cusArgObViewControllerThatContainsTheCallBackFunctions  withOnSuccessCallBack:cusArgSelOnSuccess andOnFailureCallBack:cusArgSelOnFailure];
}

/*
 +(void) fetchListOfTicketsFromViewController : (id)cusArgObViewControllerThatContainsTheCallBackFunctions withOnSuccessCallBack:(SEL) cusArgSelOnSuccess andOnFailureCallBack: (SEL) cusArgSelOnFailure withParams:(NSString*) mEmail{

    //preparing url
    NSString* cusStrUrl = [NSString stringWithFormat:@"%@/getTicketlist",[CUSApiHelper fetchBaseApiUrl]];

    NSMutableDictionary* cusNsmdJsonParams = [[NSMutableDictionary alloc] init];
    [cusNsmdJsonParams setObject:mEmail forKey:@"email"];

    [cusNsmdJsonParams setObject:[[Cus360 sharedInstance] getGCMRegId] forKey:@"uid"];

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:cusNsmdJsonParams
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {

    }
    //preparing params
    NSMutableDictionary* cusNsmdParams = [[NSMutableDictionary alloc] init];

    [CUSApiHelper addCommonParams:cusNsmdParams];
    [cusNsmdParams setObject:jsonString forKey:@"params"];
    NSLog(@"params:%@",jsonString);
    
    //executing post request ....
    [HomerUtils executePostForUrl:cusStrUrl withParams:cusNsmdParams fromViewController:cusArgObViewControllerThatContainsTheCallBackFunctions  withOnSuccessCallBack:cusArgSelOnSuccess andOnFailureCallBack:cusArgSelOnFailure];


};
*/

+(void)getPreChatHistory : (id)cusArgObViewControllerThatContainsTheCallBackFunctions withOnSuccessCallBack:(SEL) cusArgSelOnSuccess andOnFailureCallBack: (SEL) cusArgSelOnFailure withParams:(NSString *) emailID{
    
    //preparing url
    NSString* cusStrUrl = [NSString stringWithFormat:@"%@/getPreChats",[CUSApiHelperChat fetchBaseApiUrl]];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:emailID forKey:@"email"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    //preparing params
    NSMutableDictionary* cusNsmdJsonParams = [[NSMutableDictionary alloc] init];

    ModelAccessTokenChat *mtempAccessToken= [[Cus360Chat sharedInstance] getAccessTokenChat] ;
    
    if(mtempAccessToken!=nil&& ![HomerUtils stringIsEmpty:mtempAccessToken.cusNsstrAccessToken])
    {
        [cusNsmdJsonParams setObject:mtempAccessToken.cusNsstrAccessToken forKey:@"access_token"];
    }
    [cusNsmdJsonParams setObject:[[Cus360Chat sharedInstance] getAppApiKey] forKey:@"api_key"];
    NSString* appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    [cusNsmdJsonParams setObject:appID forKey:@"identifier"];
    [cusNsmdJsonParams setObject:@"inapp" forKey:@"source"];
    [cusNsmdJsonParams setObject:jsonString forKey:@"params"];

    
    //executing post request ....
    [HomerUtils executePostForUrl:cusStrUrl withParams:cusNsmdJsonParams fromViewController:cusArgObViewControllerThatContainsTheCallBackFunctions  withOnSuccessCallBack:cusArgSelOnSuccess andOnFailureCallBack:cusArgSelOnFailure];
}

+(void)getChatEvents : (id)cusArgObViewControllerThatContainsTheCallBackFunctions withOnSuccessCallBack:(SEL) cusArgSelOnSuccess andOnFailureCallBack: (SEL) cusArgSelOnFailure withParams:(NSString *) messageID{
    
    //preparing url
    NSString* cusStrUrl = [NSString stringWithFormat:@"%@/getChatEvents",[CUSApiHelperChat fetchBaseApiUrl]];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:messageID forKey:@"id"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    //preparing params
    NSMutableDictionary* cusNsmdJsonParams = [[NSMutableDictionary alloc] init];
    
    ModelAccessTokenChat *mtempAccessToken= [[Cus360Chat sharedInstance] getAccessTokenChat] ;
    
    if(mtempAccessToken!=nil&& ![HomerUtils stringIsEmpty:mtempAccessToken.cusNsstrAccessToken])
    {
        [cusNsmdJsonParams setObject:mtempAccessToken.cusNsstrAccessToken forKey:@"access_token"];
    }
    [cusNsmdJsonParams setObject:[[Cus360Chat sharedInstance] getAppApiKey] forKey:@"api_key"];
    NSString* appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    [cusNsmdJsonParams setObject:appID forKey:@"identifier"];
    [cusNsmdJsonParams setObject:@"inapp" forKey:@"source"];
    [cusNsmdJsonParams setObject:jsonString forKey:@"params"];
    
    
    //executing post request ....
    [HomerUtils executePostForUrl:cusStrUrl withParams:cusNsmdJsonParams fromViewController:cusArgObViewControllerThatContainsTheCallBackFunctions  withOnSuccessCallBack:cusArgSelOnSuccess andOnFailureCallBack:cusArgSelOnFailure];
}

+(bool) checkIfFetchDataWasSuccess:(id)cusArgResponseObject{

    //parsing data
    NSDictionary* cusNsdResponseAccessToken  = (NSDictionary *)cusArgResponseObject;
    NSNumber* cusNsnumSuccess = [cusNsdResponseAccessToken objectForKey:@"success"] ;
    return cusNsnumSuccess.boolValue;
};


+(NSDictionary*) fetchResponseKeyFromResponse:(id)cusArgResponseObject{

    //parsing data
    NSDictionary* cusNsdResponseAccessToken  = (NSDictionary *)cusArgResponseObject;
    NSDictionary* cusNsdResponse = (NSDictionary*)[cusNsdResponseAccessToken objectForKey:@"response"];
    return cusNsdResponse;
};

+(NSString*)base64forData:(NSData*)theData {

    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];

    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;

    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;

            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }

        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }

    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}
@end
