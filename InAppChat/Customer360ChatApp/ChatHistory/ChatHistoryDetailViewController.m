//
//  ChatHistoryDetailViewController.m
//  InAppChat
//
//  Created by Customer360 on 30/06/15.
//
//

#import "ChatHistoryDetailViewController.h"
#import "CusChatMessageCell.h"
#import "CUSApiHelperChat.h"
#import "Cus360Chat.h"

@interface ChatHistoryDetailViewController ()
{
    float CusChatscreenW;
    NSString *agentName;
    NSString *chatEndBy;
    int noOfMsgs;
}

@end

@implementation ChatHistoryDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _messages = [[NSMutableArray alloc] init];
    CusChatscreenW = [UIScreen mainScreen].bounds.size.width;
    
    _messageArray = [_messageDict objectForKey:@"response"];
    [self prepareArray];
    
    //NSLog(@"messagge array = %@", _messages);
}
-(void)viewWillAppear:(BOOL)animated
{
    [self loadNavigationBar];
    [self performSubClassWork];
}

-(void)viewDidAppear:(BOOL)animated
{
//    if (noOfMsgs<5) {
//        UILabel *title = [[UILabel alloc] init];
//        title.frame = CGRectMake(46, [UIScreen mainScreen].bounds.size.height/2, CusChatscreenW-92,34 );
//        title.numberOfLines=0;
//        title.font = [UIFont systemFontOfSize:14.0f];
//        title.textAlignment = NSTextAlignmentCenter;
//        title.text= @"No conversation is recorded for this chat.";
//        title.backgroundColor = [UIColor colorWithRed:188.0/255.0 green:235.0/255.0 blue:189.0/255.0 alpha:1.0];
//        title.textColor = [UIColor colorWithRed:41.0/255.0 green:89.0/255.0 blue:0.0/255.0 alpha:1.0];
//        [[title layer] setCornerRadius:4.0f];
//        [[title layer] setMasksToBounds:YES];
//        [self.view addSubview:title];
//    }
}

-(void)prepareArray{
    noOfMsgs = [_messageArray count];
    for (int i=0; i<noOfMsgs; i++) {
        NSDictionary *tempDict = [_messageArray objectAtIndex:i];
        if ([[tempDict objectForKey:@"event"] isEqualToString:@"agent_joined_chat"])
            continue;
        if ([[tempDict objectForKey:@"message"] isEqualToString:@"Pre chat form message"])
            continue;
        
        NSString *body = [tempDict objectForKey:@"message"];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:body forKey:@"strContent"];
        [dict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"photoUrl"] forKey:@"strIcon"];
        //[dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"agent_name"] forKey:@"strName"];
        if ([[tempDict objectForKey:@"initiator"] isEqualToString:@"customer"]) {
            [dict setObject:@"1" forKey:@"from"];
        }else{
            [dict setObject:@"2" forKey:@"from"];
            agentName = [tempDict objectForKey:@"from"];
            [dict setObject:agentName forKey:@"strName"];
        }
        CusChatMessage *newMessage = [[CusChatMessage alloc] initWithDict:dict];
        [_messages addObject:newMessage];
    }
    
    NSDictionary *tempDic = [_messageArray lastObject];
    if ([[tempDic objectForKey:@"event"] isEqualToString:@"chat_ended_by_visitor"])
        chatEndBy = @"You";
    else
        chatEndBy = [tempDic objectForKey:@"from"];
}

-(void)performSubClassWork
{
    //[CUSApiHelperChat getChatEvents:self withOnSuccessCallBack:@selector(doONSccuessfullyFetchedPreChatDetails:) andOnFailureCallBack:@selector(doONFailToFetchPreChatDetails:) withParams:@"id here"];
}

-(void)loadNavigationBar{
    [super loadNavigationBar];
    UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:[NSString stringWithFormat:@"Chat History"]];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 55, 50)];
    
    [btn setImage:[UIImage imageNamed:@"leftArrow"] forState:UIControlStateNormal];
    [btn setTitle:@"Back" forState:UIControlStateNormal];
    //btn.titleLabel.font = [UIFont fontWithName:@"chalkdust" size:15.0];
    [btn setTitleColor:[self colorWithHexString:[[Cus360Chat sharedInstance] getNavigationBarTitleColor]] forState:UIControlStateNormal];
    btn.imageEdgeInsets = UIEdgeInsetsMake(0, -btn.imageView.frame.size.width, 0, btn.imageView.frame.size.width);
    btn.titleEdgeInsets = UIEdgeInsetsMake(0, -btn.titleLabel.frame.size.width, 0, -btn.titleLabel.frame.size.width);
    [btn addTarget:self action:@selector(goBackTohostoryPage) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *myBackButton = [[UIBarButtonItem alloc] initWithCustomView:btn];

    //UIBarButtonItem *myBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(goBackTohostoryPage)];
    
    //NSDictionary *attrb = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"chalkdust" size:15.0], NSFontAttributeName, [self colorWithHexString:[[Cus360Chat sharedInstance] getNavigationBarTitleColor]], NSForegroundColorAttributeName, nil];
    NSDictionary *attrb = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:16], NSFontAttributeName, [self colorWithHexString:[[Cus360Chat sharedInstance] getNavigationBarTitleColor]], NSForegroundColorAttributeName, nil];
    
    [myBackButton setTitleTextAttributes:attrb forState:UIControlStateNormal];
    item.leftBarButtonItem =myBackButton;
    [self.cusUiNbNavBar popNavigationItemAnimated:NO];
    [self.cusUiNbNavBar pushNavigationItem:item animated:NO];
    [self.view addSubview:self.cusUiNbNavBar];
}

-(void)goBackTohostoryPage
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - tableView dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.messages.count+1;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0 || indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
        
        UITableViewCell* cell  = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TitleLable"];
        if(noOfMsgs<5 && [_messages count]<2){
            UILabel *title = [[UILabel alloc] init];
            title.frame = CGRectMake(46, [UIScreen mainScreen].bounds.size.height/2, CusChatscreenW-92,34 );
            title.numberOfLines=0;
            title.font = [UIFont systemFontOfSize:14.0f];
            title.textAlignment = NSTextAlignmentCenter;
            title.text= @"No conversation is recorded for this chat.";
            title.backgroundColor = [UIColor colorWithRed:188.0/255.0 green:235.0/255.0 blue:189.0/255.0 alpha:1.0];
            title.textColor = [UIColor colorWithRed:41.0/255.0 green:89.0/255.0 blue:0.0/255.0 alpha:1.0];
            [[title layer] setCornerRadius:4.0f];
            [[title layer] setMasksToBounds:YES];
            [self.view addSubview:title];
            return cell;
        }
        UILabel *title = [[UILabel alloc] init];
        title.frame = CGRectMake(46, 4, CusChatscreenW-92,34 );
        title.numberOfLines=0;
        title.font = [UIFont systemFontOfSize:14.0f];
        title.textAlignment = NSTextAlignmentCenter;
        if (indexPath.row == 0) {
            title.text=[NSString stringWithFormat:@"%@ (Customer Support Agent) joined the chat", agentName];
        }else{
            if ([chatEndBy isEqualToString:@"You"])
                title.text=[NSString stringWithFormat:@"%@ left the chat", chatEndBy];
            else
                title.text=[NSString stringWithFormat:@"%@ (Customer Support Agent) left the chat", chatEndBy];
        }
        title.backgroundColor = [UIColor colorWithRed:188.0/255.0 green:235.0/255.0 blue:189.0/255.0 alpha:1.0];
        title.textColor = [UIColor colorWithRed:41.0/255.0 green:89.0/255.0 blue:0.0/255.0 alpha:1.0];
        [[title layer] setCornerRadius:4.0f];
        [[title layer] setMasksToBounds:YES];
        //          [title sizeToFit];
        [cell.contentView addSubview:title];
        //CGPoint ctr = CGPointMake(0, [self.view bounds].size.height/2);
        return cell;
    }
    
//    CusChatMessage * joined = [_messages objectAtIndex:indexPath.row-1];
//    if ([joined.strContent rangeOfString:@"C360:Agent_Joined"].length>0)
//    {
//        UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TransferLable"];
//        //        if (cell == nil) {
//        
//        UILabel *title = [[UILabel alloc] init];
//        title.frame = CGRectMake(46, 4, CusChatscreenW-92,34 );
//        title.numberOfLines=0;
//        title.font = [UIFont systemFontOfSize:14.0f];
//        title.textAlignment = NSTextAlignmentCenter;
//        title.text=[NSString stringWithFormat:@"Your Chat is transferred to %@. Agent joined the chat", [[NSUserDefaults standardUserDefaults] objectForKey:@"agent_name"]];
//        title.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
//        [[title layer] setCornerRadius:4.0f];
//        [[title layer] setMasksToBounds:YES];
//        //        [title sizeToFit];
//        [cell.contentView addSubview:title];
//        //    }
//        return cell;
//    }
    CusChatMessageCell *msgcell;
    if (msgcell == nil)
    {
        msgcell = [[ CusChatMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellID"];
        [msgcell setMessage:[_messages objectAtIndex:indexPath.row-1]];
    }
    return msgcell;
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

@end
