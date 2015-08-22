//
//  HomerUtils.m
//  Customer360SDK
//
//  Created by Customer360 on 03/12/14.
//  Copyright (c) 2014 Customer360. All rights reserved.
//

#import "HomerUtils.h"
#import "AFHTTPRequestOperationManager.h"

@implementation HomerUtils

+ (BOOL)stringIsEmpty:(NSString *) aString {
    
    if ((NSNull *) aString == [NSNull null]) {
        return YES;
    }
    
    if (aString == nil) {
        return YES;
    } else if ([aString length] == 0) {
        return YES;
    } else {
        aString = [aString stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([aString length] == 0) {
            return YES;
        }
    }
    
    return NO;
}
+ (BOOL)stringIsAValidEmailAddress:(NSString *) aString {

      NSString *stricterFilterString = @"^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$";
//    NSString *emailRegEx = stricterFilterString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stricterFilterString];
    //Valid email address
    if ([emailTest evaluateWithObject: aString] == YES)
    {
        return YES;
    }
    else
    {
        //not valid email address
        return  NO;
    }
}
+ (void) executePostForUrl:(NSString*) cusArgStrUrl withParams:(NSDictionary*) cusArgNsdParams fromViewController:(id) cusArgObViewControllerThatContainsTheCallBackFunctions withOnSuccessCallBack:(SEL) cusArgSelOnSuccess andOnFailureCallBack:(SEL)cusArgFailure{
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
     manager.responseSerializer = [AFJSONResponseSerializer serializer];
//  manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    
//        NSLog(@"Url : %@", cusArgStrUrl);
    
        [manager POST:cusArgStrUrl parameters:cusArgNsdParams success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
       
             NSLog(@"Response : %@", responseObject);
             [cusArgObViewControllerThatContainsTheCallBackFunctions performSelector:cusArgSelOnSuccess withObject:responseObject];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        [cusArgObViewControllerThatContainsTheCallBackFunctions performSelector:cusArgFailure withObject:error];
    
    }];
}

+(CGRect)getCurrentScreenBoundsDependOnOrientation
{
    NSString *reqSysVer = @"8.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
        return [UIScreen mainScreen].bounds;
    
    CGRect screenBounds = [UIScreen mainScreen].bounds ;
    CGFloat width = CGRectGetWidth(screenBounds)  ;
    CGFloat height = CGRectGetHeight(screenBounds) ;
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if(UIInterfaceOrientationIsPortrait(interfaceOrientation)){
        screenBounds.size = CGSizeMake(width, height);
        NSLog(@"Portrait Height: %f", screenBounds.size.height);
    }else if(UIInterfaceOrientationIsLandscape(interfaceOrientation)){
        screenBounds.size = CGSizeMake(height, width);
        NSLog(@"Landscape Height: %f", screenBounds.size.height);
    }
    
    return screenBounds ;
}
+(void)hideView:(UIView *)cusArgUivToBeHidden{
    CGRect tempFrame = cusArgUivToBeHidden.frame;
    tempFrame.size = CGSizeZero;
    cusArgUivToBeHidden.frame = tempFrame;
}

+(void)showView:(UIView *)cusArgUivToBeShown Frame:(CGRect) cusArgCgrectFrame{
    [cusArgUivToBeShown setFrame:cusArgCgrectFrame];
}


+(NSString *)yesButWhichDeviceIsIt
{
    BOOL hasRetina = NO;
    if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
        CGFloat scale = [[UIScreen mainScreen] scale];
        if (scale > 1.0) {
            hasRetina = YES;
        }
    }
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (hasRetina) {
            return @"iPad retina";
        } else {
            return @"iPad";
        }
    } else {
        if (hasRetina) {
            if ([[UIScreen mainScreen] bounds].size.height == 568){
                return @"iPhone5";
            }
            else
            {
                return @"iPhone4s";
            }
        } else {
            return @"iPhone";
        }
    }
}

+(CGFloat)getScaledSizeBasedOnDevice:(CGFloat)cusArgFloatSizeForclassicIphone{
    CGFloat result = 0;
    if ([[HomerUtils yesButWhichDeviceIsIt ] isEqualToString:@"iPhone"]) {
        result = cusArgFloatSizeForclassicIphone;
    }
    else if ([[HomerUtils yesButWhichDeviceIsIt ] isEqualToString:@"iPhone4s"]) {
        result = cusArgFloatSizeForclassicIphone;
    }
    else if ([[HomerUtils yesButWhichDeviceIsIt ] isEqualToString:@"iPhone5"]) {
             result = cusArgFloatSizeForclassicIphone;
    }
    else if ([[HomerUtils yesButWhichDeviceIsIt ] isEqualToString:@"iPad"]) {
             result =(cusArgFloatSizeForclassicIphone+50);
    }
    else if ([[HomerUtils yesButWhichDeviceIsIt ] isEqualToString:@"iPad retina"]) {
             result = (cusArgFloatSizeForclassicIphone+50);
    }
    return result;
}

@end

