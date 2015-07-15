//
//  CUSUiViewControllerBase.m
//  Customer360SDK
//
//  Created by Customer360 on 02/12/14.
//  Copyright (c) 2014 Customer360. All rights reserved.
//

#import "CusChatUiViewControllerBase.h"
#import "CUSApiHelperChat.h"
#import "Cus360Chat.h"
#import "AFNetworkReachabilityManager.h"
#import "ModelAccessTokenChat.h"
#import "SVProgressHUD.h"

#define IsIOS8 (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1)
@interface CusChatUiViewControllerBase ()

@end

@implementation CusChatUiViewControllerBase

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    [self hideActivityIndicator];
}

-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];

    [SVProgressHUD setForegroundColor:[UIColor cyanColor]];
    [SVProgressHUD setBackgroundColor:[UIColor clearColor]];

//    [self showActivityIndicator];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    //We are now invisible
    self.cusNsnumBoolIsVisible = [[NSNumber alloc] initWithBool:false];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //We are now visible
    self.cusNsnumBoolIsVisible = [[NSNumber alloc] initWithBool:true];
//    CusAppDelegate *appDelegate = (CusAppDelegate *)[[UIApplication sharedApplication] delegate];
//    appDelegate.cusPresentViewController=self;

//    [self hideActivityIndicator];
}
/**
  * loadNavigationBar is a fucntion which is called in all view controller because we hide the default navigation bar of the user and show a custom navigationbar, hence any modifcation to the navbar should happen here
  */
-(void)loadNavigationBar{

    self.navigationController.navigationBar.hidden = YES;

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    //CGFloat screenHeight = screenRect.size.height;
//    [[UINavigationBar appearance] setTitleTextAttributes:
//     [NSDictionary dictionaryWithObjectsAndKeys:
//      [UIColor blackColor], NSForegroundColorAttributeName,
//      [UIFont fontWithName:@"ArialMT" size:16.0], NSFontAttributeName,nil]];
    self.cusUiNbNavBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 64)];
    self.cusUiNbNavBar.barTintColor = [self colorWithHexString:[[Cus360Chat sharedInstance] getNavigationBarColor]];

   //NSDictionary *attributes = [NSDictionary dictionaryWithObject:[self colorWithHexString:[[Cus360Chat sharedInstance] getNavigationBarTitleColor]]forKey:NSForegroundColorAttributeName];
   // NSDictionary *attrb = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"chalkdust" size:15.0], NSFontAttributeName, [self colorWithHexString:[[Cus360Chat sharedInstance] getNavigationBarTitleColor]], NSForegroundColorAttributeName, nil];
    NSDictionary *attrb = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:16], NSFontAttributeName, [self colorWithHexString:[[Cus360Chat sharedInstance] getNavigationBarTitleColor]], NSForegroundColorAttributeName, nil];

    [self.cusUiNbNavBar setTitleTextAttributes:attrb];
    
    self.cusUiNbNavBar.tintColor= [self colorWithHexString:[[Cus360Chat sharedInstance] getNavigationBarColor]];

    //UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 64)];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.cusUiNbNavBar.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[self colorWithHexString:[[Cus360Chat sharedInstance] getGradientColorFirst]] CGColor], (id)[[self colorWithHexString:[[Cus360Chat sharedInstance] getGradientColorSecond]] CGColor], nil];
    //[view.layer insertSublayer:gradient atIndex:0];
    //[self.cusUiNbNavBar addSubview:view];
    [self.cusUiNbNavBar.layer insertSublayer:gradient atIndex:1];
}

#pragma -Load Fucntions

/**
* performSubClassWork if an overriden function from base view controller , it is the main entry level function for all view controllers ...this fucntion is called automatically from the base controller in view will appear method and everycontroller shouldut it's initialisation code here
*/
-(void)performSubClassWork{


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(UIColor *)colorWithHexString:(NSString *)stringToConvert
{
    NSString *noHashString = [stringToConvert stringByReplacingOccurrencesOfString:@"#" withString:@""]; // remove the #
    NSScanner *scanner = [NSScanner scannerWithString:noHashString];
    [scanner setCharactersToBeSkipped:[NSCharacterSet symbolCharacterSet]]; // remove + and $
    
    unsigned hex;
    if (![scanner scanHexInt:&hex]) return nil;
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    return [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:1.0f];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (NSUInteger)supportedInterfaceOrientations {
    
        return UIInterfaceOrientationMaskPortrait;
    
}
-(void)showErrorFromResponse:(id)cusArgIdResposeObject{

    [self hideActivityIndicator];

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ooops" message:[CUSApiHelperChat fetchResponseKeyFromResponse:cusArgIdResposeObject]delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alertView show];
}

-(void)showAlert:(NSString *)cusArgIdMessage{

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ooops"
                                                        message:cusArgIdMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

-(void)finishThisPage{
    
    self.cusNsnumBoolIsVisible = [[NSNumber alloc] initWithBool:false];
    [[Cus360Chat sharedInstance].cusBaseView dismissViewControllerAnimated:YES completion:nil];
    [self hideActivityIndicator];
}

-(void)addSubViewToAVerticleScrollView:(UIScrollView *)cusArgUisv viewToBeAdded:(UIView *)cusArgUiv offSetHeight:(CGFloat)cusArgOffsetHeight offSetWdith:(CGFloat)cusArgOffsetWidth{

    //calculate new content height of scrollview
    CGFloat subviewHeight =  cusArgUiv.frame.size.height;
    CGFloat scrollViewHeight = cusArgUisv.contentSize.height;
    CGFloat offsetHeight = cusArgOffsetHeight;
    CGFloat newHeight = subviewHeight+scrollViewHeight+offsetHeight;

    //calculate new content width of scrollview
    CGFloat subviewWidth =  cusArgUiv.frame.size.width;
    CGFloat scrollViewWidth = cusArgUisv.contentSize.width;
    CGFloat offsetWidth = cusArgOffsetWidth;
    CGFloat newWidth;
    if(scrollViewHeight<subviewWidth){

        newWidth= subviewHeight+offsetWidth;

    }
    
    else
    {
        newWidth = scrollViewWidth;
    }
    //change the origin of the subview to fit below the last element already present
    
    CGFloat yOriginOffset = 0;
    if([cusArgUisv subviews].count>0)
    {
        UIView * viewLast =[[cusArgUisv subviews] objectAtIndex:[cusArgUisv subviews].count-1];
        yOriginOffset = viewLast.frame.origin.y+viewLast.frame.size.height+cusArgOffsetHeight;
    }
    
    [cusArgUiv setFrame:CGRectMake(8, yOriginOffset , scrollViewWidth, subviewHeight)];

    //change the width of Subview to be added so that it fits in the screen size and the scrollview doesn't scroll horizontally ..
    CGRect subviewFrame = cusArgUiv.frame;
    //if (subviewFrame.size.width>[self getCurrentScreenBoundsBasedOnOrientation].size.width) {
    subviewFrame.size.width = [self getCurrentScreenBoundsBasedOnOrientation].size.width;
    [cusArgUiv setFrame:subviewFrame];
//    }
    //add Subview to scrollview finally..
    [cusArgUisv addSubview:cusArgUiv];
    [cusArgUisv setContentSize:CGSizeMake([self getCurrentScreenBoundsBasedOnOrientation].size.width-8, newHeight)];
    [cusArgUisv setFrame:CGRectMake(0, 0, [self getCurrentScreenBoundsBasedOnOrientation].size.width-8, [self getCurrentScreenBoundsBasedOnOrientation].size.height)];

}

-(CGRect)getCurrentScreenBoundsBasedOnOrientation
{

    CGRect screenBounds = [UIScreen mainScreen].bounds ;
    if(IsIOS8)
    {
        return screenBounds ;
    }
    CGFloat width = CGRectGetWidth(screenBounds)  ;
    CGFloat height = CGRectGetHeight(screenBounds) ;
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;

    if(UIInterfaceOrientationIsPortrait(interfaceOrientation)){
        screenBounds.size = CGSizeMake(width, height);
    }else if(UIInterfaceOrientationIsLandscape(interfaceOrientation)){
        screenBounds.size = CGSizeMake(height, width);
    }
    return screenBounds ;
}

-(void)hideKeyBoard
{
    //NSLog(@"Keyboard hide on TAP :-) ");
    [self.view endEditing:TRUE];
}

-(void)setOnClickListener:(UIView *)cusArgUiv withSelector:(SEL) cusArgSelector{
    
    cusArgUiv.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:cusArgSelector];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [cusArgUiv addGestureRecognizer:tapGestureRecognizer];
  

}

- (BOOL)isInternetAvail{
//    return [AFNetworkReachabilityManager sharedManager].reachable;
    NSError* error = nil;
    NSString* text = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.google.com"] encoding:NSASCIIStringEncoding error:&error];
    return ( text != NULL ) ? YES : NO;
}

-(void)showActivityIndicator{
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [SVProgressHUD show];
    
}

-(void)hideActivityIndicator{

    [SVProgressHUD dismiss];
}


@end