//
//  CUSUiViewControllerBase.h
//  Customer360SDK
//
//  Created by Customer360 on 02/12/14.
//  Copyright (c) 2014 Customer360. All rights reserved.
//
#import <UIKit/UIKit.h>
#define FIRST_CELL_GAP 64
#define LAST_CELL_GAP 32
#define GROUPING_CELL_GAP 20
#define NON_GROUPING_CELL_GAP 36


@interface CusChatUiViewControllerBase : UIViewController

@property (nonatomic,strong)UINavigationBar * cusUiNbNavBar;
@property (nonatomic,strong)NSNumber * cusNsnumBoolIsVisible;
@property (nonatomic,strong) NSMutableArray* cusNsmaAttachments;


- (void)loadNavigationBar;

- (void)loadNavigationBarWithItem:(UINavigationItem*)item leftItem:(UIBarButtonItem*)leftItem rightItem:(UIBarButtonItem*)rightItem;

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
