//
//  ChatViewController.m
//  InAppChat
//
//  Created by Anveshan Technologies on 12/03/15.
//
//
#import "CusChatAppDelegate.h"
#import "ChatViewController.h"
#import "XMPPStream.h"
#import "XMPPMessage.h"
#import "XMPPFramework.h"
#import "XMPPPing.h"
#import "XMPPAutoPing.h"
#import "HomerUtils.h"
#import "Cus360Chat.h"
#import "PostChatViewController.h"
#import "CUSApiHelperChat.h"
//#import "LocationTracker.h"

@interface ChatViewController ()<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,XMPPStreamDelegate,UIAlertViewDelegate,XMPPPingDelegate>
{
    CGFloat CusChatscreenW;
    BOOL network, showplaceholder,showPostChat;
}
@property (weak, nonatomic) IBOutlet UITableView *chatTableView;
//@property LocationTracker * locationTracker;
@property (nonatomic) NSTimer* locationUpdateTimer;
@end

@implementation ChatViewController
/*
-(CusChatAppDelegate *)appDelegate{

    return (CusChatAppDelegate*)[UIApplication sharedApplication].delegate ;
}*/
- (XMPPStream *)xmppStream {
    return [[Cus360Chat sharedInstance] xmppStream];
}

-(void)setPlaceHolder{
    
    _sendBtn.userInteractionEnabled = NO;
    _messageField.text = NSLocalizedString(@"Type Message...", @"placeholder");
    _messageField.textColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.2];
    showplaceholder = YES;
}
-(void)viewWillAppear:(BOOL)animated{

    showPostChat=true;
    [self loadNavigationBar];
    [self performSubClassWork];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    UITapGestureRecognizer *onViewTapHideKeyBoard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
    [onViewTapHideKeyBoard setCancelsTouchesInView:NO];
    [self.chatTableView addGestureRecognizer:onViewTapHideKeyBoard];
    self.chatTableView.delegate = self;
    self.chatTableView.dataSource = self;
    [self.chatTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    CusChatscreenW = [UIScreen mainScreen].bounds.size.width;
    _messages = [[NSMutableArray alloc ] init];

    XMPPStream *current = [self xmppStream];
    [current resendMyPresence];
    [[self xmppStream] addDelegate:self delegateQueue:dispatch_get_main_queue()];
     _typing.hidden =YES;

    pingTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(sendPing) userInfo:nil repeats:YES];
    [pingTimer fire];
    [self hideActivityIndicator];
    [self setPlaceHolder];
    
   /* {
        
        self.locationTracker = [[LocationTracker alloc]init];
        [self.locationTracker startLocationTracking];
        
        //Send the best location to server every 60 seconds
        //You may adjust the time interval depends on the need of your app.
        NSTimeInterval time = 30.0;
        self.locationUpdateTimer =
        [NSTimer scheduledTimerWithTimeInterval:time
                                         target:self
                                       selector:@selector(updateLocation)
                                       userInfo:nil
                                        repeats:YES];
    }
    [NSTimer scheduledTimerWithTimeInterval:15.0
//                                     target:self
//                                   selector:@selector(isInternetAvail)
//                                   userInfo:nil
//                                    repeats:YES];
//         
//    [[NSNotificationCenter defaultCenter] addObserver:self                                             selector:@selector(finishThisPage)                                                 name:UIApplicationWillTerminateNotification                                               object:nil];*/

}
/*
-(void)updateLocation {
    NSLog(@"updateLocation");
    XMPPPing *new = [[XMPPPing alloc] initWithDispatchQueue:dispatch_get_main_queue()];
    NSString *toJID = [[NSUserDefaults standardUserDefaults] objectForKey:@"agent_jid"];
    [new sendPingToJID:[XMPPJID jidWithString:toJID]];
    
//    [self.locationTracker updateLocationToServer];
}

*/
-(void)sendPing{
    XMPPPing *new = [[XMPPPing alloc] init];
    [new addDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSString *toJID = [[NSUserDefaults standardUserDefaults] objectForKey:@"agent_jid"];
        [new activate:[self xmppStream]];
    [new sendPingToServer];
//    [new sendPingToJID:[XMPPJID jidWithString:toJID]];
}

-(void)loadNavigationBar{
    [super loadNavigationBar];
    UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:[NSString stringWithFormat:@"Live Chat Support"]];
    
    UIBarButtonItem *myBackButton = [[UIBarButtonItem alloc] initWithTitle:@"End Chat" style:UIBarButtonItemStylePlain target:self action:@selector(confirmFinish)];
//    UIBarButtonItem *attach = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cus_attach_photo.png"] style:UIBarButtonItemStylePlain target:self action:@selector(doOnSendImageButtonClicked) ];
//    item.rightBarButtonItem =attach;
    
    //NSDictionary *attrb = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"chalkdust" size:15.0], NSFontAttributeName, [self colorWithHexString:[[Cus360Chat sharedInstance] getNavigationBarTitleColor]], NSForegroundColorAttributeName, nil];
    NSDictionary *attrb = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:16], NSFontAttributeName, [self colorWithHexString:[[Cus360Chat sharedInstance] getNavigationBarTitleColor]], NSForegroundColorAttributeName, nil];

    [myBackButton setTitleTextAttributes:attrb forState:UIControlStateNormal];
    
    item.leftBarButtonItem =myBackButton;
    [self.cusUiNbNavBar popNavigationItemAnimated:NO];
    [self.cusUiNbNavBar pushNavigationItem:item animated:NO];
    [self.view addSubview:self.cusUiNbNavBar];
}
-(void)confirmFinish {

    UIAlertView *end_alert = [[UIAlertView alloc] initWithTitle:@"End Chat " message:@"Are you sure you want to end the chat?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [end_alert show];
}

-(void)finishThisPage{
    NSString *toJID = [[NSUserDefaults standardUserDefaults] objectForKey:@"agent_jid"];
    XMPPMessage * message = [XMPPMessage messageWithType:@"chat" to:[XMPPJID jidWithString:toJID]];
    [message addBody:@"C360:END_CHAT - Chat terminated by visitor"];
    [message addThread:[[NSUserDefaults standardUserDefaults] objectForKey:@"msgThread"]];
    [[self xmppStream] sendElement:message];
    [pingTimer invalidate];
    [[Cus360Chat sharedInstance] disconnect];
    [self finishConversation];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)tableViewScrollToBottom
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messages.count inSection:0];
    [self.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}
#pragma mark - stream delegate 
-(void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error{

    NSLog(@"%@",error);
}


-(void)makeRateButton:(id)isDropped
{
    UILabel *leftChat = [[UILabel alloc] initWithFrame:CGRectMake(46, 0, CusChatscreenW-92,34)];
    leftChat.text = @"Agent left the chat";
    leftChat.textAlignment =NSTextAlignmentCenter;
    leftChat.font =[UIFont systemFontOfSize:14];
    [leftChat setCenter:CGPointMake(self.chatTableView.center.x,20)];
    leftChat.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
       [[leftChat layer] setCornerRadius:4.0f];
    [[leftChat layer] setMasksToBounds:YES];
    
    
    UIView *footerView = [[UIView alloc] init];
    if ([isDropped isKindOfClass:[NSString class]])
        if ([isDropped isEqualToString:@"not"])
        {
            UIButton *rate = [UIButton buttonWithType:UIButtonTypeSystem];
            [rate setFrame:CGRectMake(0, 60, 250, 40)];
            [rate setCenter:CGPointMake(self.chatTableView.center.x, 72)];
        [rate setTitle:@"Please Rate Us!" forState:UIControlStateNormal];
        [rate.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
        rate.backgroundColor = [UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1.0];
        rate.layer.cornerRadius = 3.0f;
        [rate setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [rate addTarget:self action:@selector(finishThisPage) forControlEvents:UIControlEventAllTouchEvents];
        rate.userInteractionEnabled= YES;
        [footerView addSubview:rate];
    }
    
    [footerView addSubview:leftChat];
    footerView.frame =CGRectMake(0, 300, 100, 100);
    [self.chatTableView setTableFooterView:footerView];
    if (_chatTableView.contentSize.height+20>=self.chatTableView.bounds.size.height)
    {
        int inset = 72;
        [self.chatTableView setContentOffset:CGPointMake(0, self.chatTableView.contentSize.height-self.chatTableView.bounds.size.height + inset) animated:YES];
        _chatTableView.contentInset = UIEdgeInsetsMake(0, 0, inset < 0 ? 0 : inset, 0);
        _chatTableView.scrollIndicatorInsets = _chatTableView.contentInset;
    }
    self.messageField.editable =NO;
    self.sendBtn.userInteractionEnabled =NO;
    [[Cus360Chat sharedInstance] disconnect];
}
-(void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    if ([presence.type isEqualToString:@"unavailable"]&![[[presence from]bare]isEqualToString:[[[self xmppStream] myJID] bare]]) {
//        NSLog(@"chatscreen presence = %@",[presence prettyXMLString]);
        showPostChat = false;
        _typing.hidden =YES;
        [CUSApiHelperChat changeStatus:self withOnSuccessCallBack:@selector(makeRateButton:) andOnFailureCallBack:@selector(makeRateButton:) withParams:@"dropped"];
    }
}
-(IBAction)sendMessage:(id)sender{
///////////
    if (![_messageField.text isEqualToString:@""]) {
        NSString* parseMessage = _messageField.text;
        
        parseMessage = [parseMessage stringByReplacingOccurrencesOfString:@"\n" withString:@" "]; 
        NSString *toJID = [[NSUserDefaults standardUserDefaults] objectForKey:@"agent_jid"];
        XMPPMessage * message = [XMPPMessage messageWithType:@"chat" to:[XMPPJID jidWithString:toJID]];
        [message addBody:parseMessage];
        [message addThread:[[NSUserDefaults standardUserDefaults] objectForKey:@"msgThread"]];
        [[self xmppStream] sendElement:message];
    
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:parseMessage forKey:@"strContent"];
        [dict setObject:@"" forKey:@"strIcon"];
        [dict setObject:@"Me" forKey:@"strName"];
        [dict setObject:@"1" forKey:@"from"];
    
        CusChatMessage *newMessage = [[CusChatMessage alloc] initWithDict:dict];
        [_messages addObject:newMessage];
        [_chatTableView reloadData];
        [self tableViewScrollToBottom];
        [_messageField resignFirstResponder];
        [_messageField endEditing:YES];
        [self setPlaceHolder];
    }
}
-(void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{

    NSString* agent_name = [[NSUserDefaults standardUserDefaults]objectForKey:@"agent_name"];
    NSString *displayName = [message fromStr];
    NSString *body = [message body] ;
/////Server replies same message as acknowledgement to our message hence
    if (![[[[self xmppStream] myJID] bare] isEqualToString:displayName])
    {
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
            [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(sendPing) userInfo:nil repeats:YES];
            if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
                [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound categories:nil]];
            }
            if ([message isChatMessageWithBody])
            {
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            localNotification.alertAction = @"Ok";
//            localNotification.alertBody = [NSString stringWithFormat:@"From: %@\n\n%@",displayName,body];
                  localNotification.alertBody =@"New Message";
                [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:body forKey:@"strContent"];
            [dict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"photoUrl" ]forKey:@"strIcon"];
            [dict setObject:agent_name forKey:@"strName"];
            [dict setObject:@"2" forKey:@"from"];
            CusChatMessage *newMessage = [[CusChatMessage alloc] initWithDict:dict];
            [_messages addObject:newMessage];
                [_chatTableView reloadData];
                [self tableViewScrollToBottom];
                _typing.hidden =YES;
            }
        }
        else
        {
            if (body == nil){
                if ([[[message childAtIndex:0]name]isEqualToString:@"composing"])
                {
                    _typing.hidden =NO;
                }
                else
                {
                    _typing.hidden =YES;

                }
            }
            else if ([body isEqualToString:@"C360:END_CHAT - Chat terminated by agent"])
            {
                showPostChat = true;
                [self makeRateButton:@"not"];
            }
        else
        {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:body forKey:@"strContent"];
            [dict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"photoUrl"]forKey:@"strIcon"];
            [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"agent_name"] forKey:@"strName"];
            [dict setObject:@"2" forKey:@"from"];
            CusChatMessage *newMessage = [[CusChatMessage alloc] initWithDict:dict];
            [_messages addObject:newMessage];
            
            [_chatTableView reloadData];
            [self tableViewScrollToBottom];
             _typing.hidden =YES;
        }
        }
    }
}

-(void)finishConversation
{
    if (!showPostChat) {
        
        [super finishThisPage];
    }
    else{
    PostChatViewController *postChatViewController = [[PostChatViewController alloc] initWithNibName:@"PostChatViewController" bundle:nil];
//    [[[Cus360Chat sharedInstance] cusBaseView]dismissViewControllerAnimated:YES completion:^{
        [self presentViewController:postChatViewController animated:NO completion:nil];
    }
//}   ];
}
#pragma mark - tableView dataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.messages.count+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (indexPath.row!=0)
    {
        CusChatMessage *new = [_messages objectAtIndex:indexPath.row-1];
        if ([new.strContent rangeOfString:@"C360:Agent_Joined"].length>0)
        {
            return 50.0;
        }
        CGRect content = [(NSString*)new.strContent boundingRectWithSize:CGSizeMake(CusChatscreenW-130, CGFLOAT_MAX) options:(NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin)  attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15.0]} context:nil];
        
        if (![new.strContent isKindOfClass:[NSString class]]) {
            return content.size.height;
        }
        return content.size.height + 48;
    }
    else
    return 40.0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    
    if (indexPath.row == 0) {
        
        UITableViewCell* cell  = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TitleLable"];
            UILabel *title = [[UILabel alloc] init];
            title.frame = CGRectMake(46, 4, CusChatscreenW-92,34 );
            title.numberOfLines=0;
            title.font = [UIFont systemFontOfSize:14.0f];
            title.textAlignment = NSTextAlignmentCenter;
            title.text=[NSString stringWithFormat:@"%@ joined the chat", _agentName];
            title.backgroundColor = [UIColor colorWithRed:188.0/255.0 green:235.0/255.0 blue:189.0/255.0 alpha:1.0];
            title.textColor = [UIColor colorWithRed:41.0/255.0 green:89.0/255.0 blue:0.0/255.0 alpha:1.0];
            [[title layer] setCornerRadius:4.0f];
            [[title layer] setMasksToBounds:YES];
//          [title sizeToFit];
            [cell.contentView addSubview:title];
        return cell;
    }
    
    CusChatMessage * joined = [_messages objectAtIndex:indexPath.row-1];
    if ([joined.strContent rangeOfString:@"C360:Agent_Joined"].length>0)
    {
       UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TransferLable"];
//        if (cell == nil) {
        
        UILabel *title = [[UILabel alloc] init];
        title.frame = CGRectMake(46, 4, CusChatscreenW-92,34 );
        title.numberOfLines=0;
        title.font = [UIFont systemFontOfSize:14.0f];
        title.textAlignment = NSTextAlignmentCenter;
        title.text=[NSString stringWithFormat:@"Your Chat is transferred to %@. Agent joined the chat", [[NSUserDefaults standardUserDefaults] objectForKey:@"agent_name"]];
        title.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
        [[title layer] setCornerRadius:4.0f];
        [[title layer] setMasksToBounds:YES];
        //        [title sizeToFit];
        [cell.contentView addSubview:title];
//    }
        return cell;
        
    }
    CusChatMessageCell *msgcell;
    if (msgcell == nil)
    {
        msgcell = [[ CusChatMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellID"];
        [msgcell setMessage:[_messages objectAtIndex:indexPath.row-1]];
    }
    return msgcell;
    
}


#pragma mark - UITextView Delgates


-(void)textViewDidBeginEditing:(UITextView *)textView
{    if (showplaceholder)
    {
        textView.textColor = [UIColor blackColor];
        textView.text = @"";
        showplaceholder = NO;
    }
    _sendBtn.userInteractionEnabled = YES;
  //  float yOffset = _baseView.frame.origin.y-250;
    //[_scrollView setContentOffset:CGPointMake(0, yOffset) animated:NO];
    
    self.baseView.frame = CGRectMake(self.baseView.frame.origin.x, (self.baseView.frame.origin.y-[HomerUtils getScaledSizeBasedOnDevice:250]),self.baseView.frame.size.width, self.baseView.frame.size.height);
    

       self.chatTableView.frame = CGRectMake(self.chatTableView.frame.origin.x, (self.chatTableView.frame.origin.y), self.chatTableView.frame.size.width, (self.baseView.frame.origin.y-self.chatTableView.frame.origin.y-2));
    [self tableViewScrollToBottom];
    
   //<message xmlns="jabber:client" id="msg84" from="user_65948@test1.c360dev.in" type="chat" to="user8a32739b13a848423a8b4e8fbb653123test1c360devin@test1.c360dev.in/tigase-214"><composing xmlns="http://jabber.org/protocol/chatstates"/></message>
    //    <composing xmlns="http://jabber.org/protocol/chatstates"/>
//    [self.cusUibtvBubbleTableView scrollBubbleViewToBottomAnimated:YES];

    
}

-(void)textViewDidEndEditing:(UITextView *)textView{
   
//    [_messageField resignFirstResponder];
    if (_messageField.text.length == 0) {
        [self setPlaceHolder];
    }
    self.baseView.frame = CGRectMake(self.baseView.frame.origin.x, (self.baseView.frame.origin.y+[HomerUtils getScaledSizeBasedOnDevice:250]), self.baseView.frame.size.width, self.baseView.frame.size.height);
    self.chatTableView.frame = CGRectMake(self.chatTableView.frame.origin.x, self.chatTableView.frame.origin.y, self.chatTableView.frame.size.width, (self.baseView.frame.origin.y+self.chatTableView.frame.origin.y+2));
    [self tableViewScrollToBottom];
   
    /*
    _sendBtn.userInteractionEnabled = YES;
    float yOffset = _baseView.frame.origin.y+250;
    [_scrollView setContentOffset:CGPointMake(0, 0) animated:NO];*/

}
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    
    
    DDXMLElement *composing = [[DDXMLElement alloc]initWithName:@"composing" xmlns:@"http://jabber.org/protocol/chatstates"];
    XMPPJID *toID = [XMPPJID jidWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"agent_jid"]];
    XMPPMessage *typing= [[XMPPMessage alloc]initWithType:@"chat" to:toID elementID:@"msg84" child:composing];
    [[self xmppStream] sendElement:typing];
    

    return YES;
}
-(BOOL)textViewShouldEndEditing:(UITextView *)textView{
    
    return YES;
    
}

#pragma mark - alertview 

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{

    if (buttonIndex == 1) {
//        NSLog(@"yes");
        [self finishThisPage];
    }
//    else{
////        NSLog(@"No");
//    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - chat stream timer 

//

@end
