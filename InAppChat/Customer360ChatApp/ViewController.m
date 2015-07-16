//
//  ViewController.m
//  Customer360ChatApp
//
//  Created by Anveshan Technologies on 03/03/15.
//
//

#import "ViewController.h"
#import "Cus360Chat.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSMutableDictionary* myNsmdDictionary = [[NSMutableDictionary alloc]init];
    
    [myNsmdDictionary setObject:cusChatConstStrValueEnvironmentTypeTEST forKey:cusConstStrKeyEnvironmentType];
    
    //[myNsmdDictionary setObject:@"#2B3B61" forKey:cusChatConstStrKeyNavbarColor];
    //[myNsmdDictionary setObject:@"abc@abc.com" forKey:cusConstStrKeyDeveloperEmailId];  // Rygh@yuck.com
    //[myNsmdDictionary setObject:@"Shashikant" forKey:cusConstStrKeyUserName];
    //[myNsmdDictionary setObject:@"User Feedback goes Here." forKey:cusConstStrKeyFeedback];
//    [myNsmdDictionary setObject:@"#000000" forKey:cusChatConstStrKeyNavBarTitleColor];
//    [myNsmdDictionary setObject:@"#000000" forKey:cusConstStrKeyNavBarGradientColorFirst];
//    [myNsmdDictionary setObject:@"#ffffff" forKey:cusConstStrKeyNavBarGradientColorSecond];
    
    //[myNsmdDictionary setObject:@"customer128" forKey:cusConstStrKeyWaitingScreenImageName];
    //[myNsmdDictionary setObject:@"Pre-Chat Offline Message Here." forKey:cusConstStrKeyPreChatOfflineMessage];
    //[myNsmdDictionary setObject:@"Pre-Chat Online Message Here." forKey:cusConstStrKeyPreChatOnlineMessage];
//    [myNsmdDictionary setObject:@"#E1F5A9" forKey:cusConstStrKeyPreChatHeaderMsgBackgroundColor];
    //[myNsmdDictionary setObject:@"#0000ff" forKey:cusConstStrKeyPreChatHeaderMsgBackgroundColor];
//    [myNsmdDictionary setObject:@"YES" forKey:mStrKeyEnableAutoFormSubmit];
    
    NSLog(@"value of bool %hhd", [Cus360Chat sharedInstance].cusBoolEnableAutoFormSubmit);
    [[Cus360Chat sharedInstance] install:@"66250f27c76322ff46abb96e543e9043" withOptions:myNsmdDictionary];
    NSLog(@"value of bool %hhd", [Cus360Chat sharedInstance].cusBoolEnableAutoFormSubmit);
}

//    App ids of different companies
//  rules = 5191a01af8af8579a114eab40b159a73r
// in app chat test1 = 31c685726e74f6e8572b03940367e7c6
//     customer 360 = 24b459746a971259ef10fd52494af63e
//    juust recharg = e6e2cc24c4222ddf65c0126d5dc73cb5
//      nexus = f30b5317c4e049ef929d70bdf5bfc124
//    shield = 215a12a9b07a598d0350888f8a3ceff4
//    your zcompany = af2e12ewthdddrw54f354dcc
//    customersupport = af2e12e5rsff4f354dcc
//    test1= af2e12ewthdddrererrw54f354dcc
//    test = 77172b7a1d8868384f2cec8f7b009665
//testcopany = 59a3109837c544124e7e49036fc28a2f

//test = af2e12ewthdddrererrw54f354dcc
//comp = 17031c882f8347b751e3c4741f59b38f
//formmanager1 = e231d061ee3866b37dcb07195c88a950
//miracle = 4f8c7c8518ae25c97ed7a5c8da331742
//form89  = 742f9f8019c8facf5d7377b834a5d6b5
//fm2 = 66250f27c76322ff46abb96e543e9043 chat
//shield = 4d9f8cb5147da9404a97b3602256f430
//zakas = 1e229bc480dbd19b8df5a850c9d78a78

-(IBAction)launchChatModule :(id)sender
{
    [[Cus360Chat sharedInstance] launchChatModule:self];
}

//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 100)];
//    CAGradientLayer *gradient = [CAGradientLayer layer];
//    gradient.frame = view.bounds;
//    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor yellowColor] CGColor], (id)[[UIColor whiteColor] CGColor], nil];
//    [view.layer insertSublayer:gradient atIndex:0];
//    [self.view addSubview:view];

//    NSArray *fontFamilies = [UIFont familyNames];
//    for (int i = 0; i < [fontFamilies count]; i++)
//    {
//        NSString *fontFamily = [fontFamilies objectAtIndex:i];
//        NSArray *fontNames = [UIFont fontNamesForFamilyName:[fontFamilies objectAtIndex:i]];
//        NSLog (@"%d)Family = %@: FontName = %@", i, fontFamily, fontNames);
//    }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
