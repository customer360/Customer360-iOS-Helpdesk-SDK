//
//  CUSUiViewControllerBase.h
//  Customer360SDK
//
//  Created by Customer360 on 02/12/14.
//  Copyright (c) 2014 Customer360. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface CusChatUiViewControllerBase : UIViewController

@property (nonatomic,strong)UINavigationBar * cusUiNbNavBar;
@property (nonatomic,strong)NSNumber * cusNsnumBoolIsVisible;
@property (nonatomic,strong) NSMutableArray* cusNsmaAttachments;


- (void)loadNavigationBar;

- (UIBarButtonItem*)getNavigationBackButtonWithTarget:(id)target action:(SEL)action;

- (void)doOnAccessTokenVerified:(id)cusArgResponseObject;

- (void)doOnNetworkTaskFailed:(id)cusArgerror;

- (void)showErrorFromResponse:(id)cusArgIdResposeObject;

- (void)performSubClassWork;

- (void)showAlert:(NSString *)cusArgIdMessage;

- (void)finishThisPage;

- (void)addSubViewToAVerticleScrollView:(UIScrollView *)cusArgUisv viewToBeAdded:(UIView *)cusArgUiv offSetHeight:(CGFloat)cusArgOffsetHeight offSetWdith:(CGFloat)cusArgOffsetWidth;


- (CGRect)getCurrentScreenBoundsBasedOnOrientation;

- (void)hideKeyBoard;

- (void)setOnClickListener:(UIView *)cusArgUiv withSelector:(SEL)cusArgSelector;

- (BOOL)isInternetAvail;

- (void)showActivityIndicator;

- (void)hideActivityIndicator;

-(UIColor *)colorWithHexString:(NSString *)stringToConvert;
@end
