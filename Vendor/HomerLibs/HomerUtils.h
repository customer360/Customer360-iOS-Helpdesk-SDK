//
//  HomerUtils.h
//  Customer360SDK
//
//  Created by Customer360 on 03/12/14.
//  Copyright (c) 2014 Customer360. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HomerUtils : NSObject

+(BOOL) stringIsEmpty:(NSString *) aString;

+ (BOOL)stringIsAValidEmailAddress:(NSString *)aString;

+(void) executePostForUrl:(NSString*) cusArgStrUrl withParams:(NSDictionary*) cusArgNsdParams fromViewController:(id) cusArgObViewControllerThatContainsTheCallBackFunctions withOnSuccessCallBack:(SEL) cusArgSelOnSuccess andOnFailureCallBack:(SEL)cusArgFailure;

+(CGRect)getCurrentScreenBoundsDependOnOrientation;

+ (void)hideView:(UIView *)cusArgUivToBeHidden;

+ (void)showView:(UIView *)cusArgUivToBeShown Frame:(CGRect)cusArgCgrectFrame;

+(NSString *)yesButWhichDeviceIsIt;

+(CGFloat)getScaledSizeBasedOnDevice:(CGFloat)cusArgFloatSizeForclassicIphone;

@end
