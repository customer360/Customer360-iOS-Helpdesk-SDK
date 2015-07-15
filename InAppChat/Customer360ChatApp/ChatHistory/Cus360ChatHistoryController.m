//
//  Cus360ChatHistoryController.m
//  InAppChat
//
//  Created by Customer360 on 29/06/15.
//
//

#import "Cus360ChatHistoryController.h"
#import "CUSApiHelperChat.h"
#import "Cus360ChatHistoryCellControllerTableViewCell.h"
#import "ChatHistoryDetailViewController.h"
#import "Cus360Chat.h"

@interface Cus360ChatHistoryController ()

@end

@implementation Cus360ChatHistoryController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.cusChatHistoryListingTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self loadNavigationBar];
    [self performSubClassWork];
    [self showActivityIndicator];
}

- (void)viewWillAppear:(BOOL)animated{
    // _CusChatHistoryArray = [[NSMutableArray alloc] init];
}

-(void)loadNavigationBar{
    [super loadNavigationBar];
    
    UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@""];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    
    [btn setImage:[UIImage imageNamed:@"leftArrow"] forState:UIControlStateNormal];
    [btn setTitle:@"Chat History" forState:UIControlStateNormal];
    //btn.titleLabel.font = [UIFont fontWithName:@"chalkdust" size:15.0];
    [btn setTitleColor:[self colorWithHexString:[[Cus360Chat sharedInstance] getNavigationBarTitleColor]] forState:UIControlStateNormal];
    btn.imageEdgeInsets = UIEdgeInsetsMake(0, -btn.imageView.frame.size.width, 0, btn.imageView.frame.size.width);
    btn.titleEdgeInsets = UIEdgeInsetsMake(0, -btn.titleLabel.frame.size.width, 0, -btn.titleLabel.frame.size.width);
    [btn addTarget:self action:@selector(finishThisPage) forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *myBackButton = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    //UIBarButtonItem *myBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Chat History" style:UIBarButtonItemStylePlain target:self action:@selector(finishThisPage)];
    
    item.leftBarButtonItem =myBackButton;
    [self.cusUiNbNavBar popNavigationItemAnimated:NO];
    
    [self.cusUiNbNavBar pushNavigationItem:item animated:NO];
    [self.view addSubview:self.cusUiNbNavBar];
}

-(void)performSubClassWork{
    NSString *emailID = [[Cus360Chat sharedInstance] getUserEmailId];
    [CUSApiHelperChat getPreChatHistory:self withOnSuccessCallBack:@selector(doONSccuessfullyFetchedPreChatHistory:) andOnFailureCallBack:@selector(doONFailToFetchPreChatHistory:) withParams:emailID];
}

-(void)doONSccuessfullyFetchedPreChatHistory:(id)cusArgIdResponseObject{
    NSLog(@"%@", cusArgIdResponseObject);
    
    [self hideActivityIndicator];
    
    if ([CUSApiHelperChat checkIfFetchDataWasSuccess:cusArgIdResponseObject]) {
        _CusChatHistoryArray = [cusArgIdResponseObject objectForKey:@"response"];
        NSLog(@"array %@", _CusChatHistoryArray);
        
        [self.cusChatHistoryListingTableView reloadData];
    }
}
-(void)doONFailToFetchPreChatHistory:(id)cusArgIdResponseObject{
    NSLog(@"%@", cusArgIdResponseObject);
    [self hideActivityIndicator];
}

#pragma mark - Table View Delegates

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger noOfCells = [self.CusChatHistoryArray count];
    return noOfCells;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //    if ([[UIDevice currentDevice].model isEqualToString:@"iPad"]) {
    //        return 80;
    //    }
    return 78;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* cusNsDict = [self.CusChatHistoryArray objectAtIndex:indexPath.row];
    
    static NSString *simpleTableIdentifier = @"reuseIdentifire";
    
    Cus360ChatHistoryCellControllerTableViewCell *cell = (Cus360ChatHistoryCellControllerTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"Cus360ChatHistoryCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    cell.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 78);
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.historyCellImage.image = [UIImage imageNamed:@"chat.png"];
    NSString *text = [cusNsDict objectForKey:@"message"];
    text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    cell.messageLabel.text = text;
    cell.dateTimeLabel.text = [cusNsDict objectForKey:@"time"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *msgID = [[_CusChatHistoryArray objectAtIndex:indexPath.row] objectForKey:@"id"];
    [CUSApiHelperChat getChatEvents:self withOnSuccessCallBack:@selector(doONSccuessfullyFetchedPreChatDetails:) andOnFailureCallBack:@selector(doONFailToFetchPreChatDetails:) withParams:msgID];
    [self showActivityIndicator];
}

-(void)doONSccuessfullyFetchedPreChatDetails:(id)cusArgIdResponseObject{
    NSLog(@"%@", cusArgIdResponseObject);
    
    if ([CUSApiHelperChat checkIfFetchDataWasSuccess:cusArgIdResponseObject]) {
        
        ChatHistoryDetailViewController *chatVC = [[ChatHistoryDetailViewController alloc] initWithNibName:@"ChatHistoryDetailViewController" bundle:nil];
        chatVC.messageDict = (NSMutableDictionary *)cusArgIdResponseObject;
        [self presentViewController:chatVC animated:YES completion:nil];
    }else
    {
        [self showErrorFromResponse:cusArgIdResponseObject];
    }
    [self hideActivityIndicator];
}

-(void)doONFailToFetchPreChatDetails:(id)cusArgIdResponseObject{
    NSLog(@"%@", cusArgIdResponseObject);
    [self hideActivityIndicator];
    //[self showErrorFromResponse:cusArgIdResponseObject];
}

#pragma mark ----
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
