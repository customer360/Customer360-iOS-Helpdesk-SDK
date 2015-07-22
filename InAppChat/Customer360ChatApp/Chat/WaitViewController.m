//
//  ViewController.m
//  InAppChat
//
//  Created by Anveshan Technologies on 03/03/15.
//
//
#import "XMPPStream.h"
#import "Cus360Chat.h"
#import "CUSApiHelperChat.h"
#import "WaitViewController.h"
#import "XMPPFramework.h"
#import "XMPPPing.h"
//#include "CusChatAppDelegate.h"
@interface WaitViewController ()<XMPPStreamDelegate,XMPPPingDelegate,UIAlertViewDelegate>
@property (nonatomic, strong)XMPPStream* xmppstream;
@end

@implementation WaitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
//    [self loadNavigationBar];
//    [self performSubClassWork];
    // Do any additional setup after loading the view from its nib.
    if ([Cus360Chat sharedInstance].cusStrWaitingScreenImageName != nil) {
        self.waitingScreenImageView.image = [UIImage imageNamed:[Cus360Chat sharedInstance].cusStrWaitingScreenImageName];
    }
}/*
- (XMPPStream *)xmppStream {
    return [[Cus360Chat sharedInstance] xmppStream];
}*/

-(void)viewWillAppear:(BOOL)animated{

    [self loadNavigationBarItem];
    [self performSubClassWork];
    //[self loadScreenElement];
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"WaitingView -> viewWillDisappear");
}
- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"WaitingView -> viewDidDisappear");
}

-(void)loadNavigationBarItem{
    
    UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@"Connecting..."];
    
    UIBarButtonItem *leftItem = [self getNavigationBackButtonWithTarget:self action:@selector(finishThisPage)];

    [self loadNavigationBarWithItem:item leftItem:leftItem rightItem:nil];
}

-(void)performSubClassWork{

    [[Cus360Chat sharedInstance] connect];

}

- (void)loadScreenElement
{
    float screenWidth = [[UIScreen mainScreen] bounds].size.width;
    float screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    //----------------
    // Image...
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"waiting"]];
    [self.view addSubview:imgView];
    CGRect frame = imgView.frame;
    frame.origin.x = screenWidth/2;
    frame.origin.y = screenHeight/4;
    imgView.frame = frame;
}

/*-(void)sendPing{
    XMPPPing *new = [[XMPPPing alloc] init];
    [new addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)];
    NSString *toJID = [[NSUserDefaults standardUserDefaults] objectForKey:@"agent_jid"];
    if (toJID)
    {
        [new activate:[self xmppStream]];
        [new sendPingToJID:[XMPPJID jidWithString:toJID]];
    }
}*/

-(void)finishThisPage{

    [[Cus360Chat sharedInstance] disconnect];
    [super finishThisPage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark -XMPP
/*
-(void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence{
    
    if ([presence.type isEqualToString:@"unavailable"]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Agents" message:@"Sorry currently no agents are Online" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        
        [CUSApiHelperChat changeStatus:self withOnSuccessCallBack:@selector(finishThisPage) andOnFailureCallBack:@selector(finishThisPage) withParams:@"missed"];
    }
}

-(void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{


    NSString *body = [message body];
    if ([body rangeOfString:@"c360: no_agent_online"].length>0) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Agents" message:@"Sorry currently no agents are Online" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        
        [CUSApiHelperChat changeStatus:self withOnSuccessCallBack:@selector(finishThisPage) andOnFailureCallBack:@selector(finishThisPage) withParams:@"missed"];
    }

}
- (void)xmppStream:(XMPPStream *)sender didReceiveError:(NSXMLElement *)error{
    //    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Failed" message:@"Unable to connect to server. Please retry connecting" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    
    NSLog(@"Unable to connect to server. Check xmppStream.hostName , %@", error);
    
}



- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    //    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
   
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Failed" message:@"Unable to connect to server. Please retry connecting" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    
        NSLog(@"Unable to connect to server. Check xmppStream.hostName , %@", error);
    
}
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{

    [self finishThisPage];
}*/
@end
