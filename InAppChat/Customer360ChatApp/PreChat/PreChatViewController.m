//
//  PreChatViewController.m
//  Customer360SDK
//
//  Created by Anveshan Technologies on 30/01/15.
//  Copyright (c) 2015 Customer360. All rights reserved.
//
#import "CUSApiHelperChat.h"
#import "PreChatViewController.h"
#import "Cus360Chat.h"
#import "RadioButton.h"
#import "HomerUtils.h"
#import "ModelAccessTokenChat.h"
#import "WaitViewController.h"
#import "CUSThankYouViewController.h"
#import "Cus360ChatHistoryController.h"


@interface PreChatViewController () <UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UIScrollViewDelegate,UITextViewDelegate>
{
    RadioButton *RadioButtonNumber;
    NSMutableArray *checkBoxArray;
    NSString *preChatMessage;
    NSString *status ;
}

@end

@implementation PreChatViewController

@synthesize address = address;
@synthesize phoneNo = phoneNo;
//@synthesize dropdown = dropdown;
@synthesize email = email;
@synthesize name = name;
@synthesize dict = dict;
@synthesize pickerView = pickerView;
@synthesize question = question ;
@synthesize arrViews = arrViews;
@synthesize arrPickerData = arrPickerData ;

- (void)viewDidLoad
{
    [super viewDidLoad];
    UITapGestureRecognizer *onViewTapHideKeyBoard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
    [onViewTapHideKeyBoard setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:onViewTapHideKeyBoard];
    screenW = [UIScreen mainScreen].bounds.size.width;
    
    [CUSApiHelperChat verifyAccessTokenFromViewController:self withOnSuccessCallBack:@selector(doOnAccessTokenVerified:) andOnFailureCallBack:@selector(doOnNetworkTaskFailed:)];
    [self registerForKeyboardNotifications];
    //    [self hideActivityIndicator];
}

-(void)hideKeyBoard
{
    //NSLog(@"Keyboard hide on TAP :-) ");
    [self.view endEditing:TRUE];
}


-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    //     self.PreChatscrollView.contentOffset = CGPointMake(0, 0);
    _cusChatUITextField = [[NSMutableArray alloc]init];
    _cusChatUITextView = [[NSMutableArray alloc]init];
    _cusChatUITextFieldSelect = [[NSMutableArray alloc] init];
    _cusChatUITextFieldDate= [[NSMutableArray alloc] init];
    _cusChatUITextFieldTime= [[NSMutableArray alloc] init];
    [self showActivityIndicator];
    [self loadNavigationBar];
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}
// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.PreChatscrollView.contentInset = contentInsets;
    self.PreChatscrollView.scrollIndicatorInsets = contentInsets;
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.PreChatscrollView.contentInset = contentInsets;
    self.PreChatscrollView.scrollIndicatorInsets = contentInsets;
}

-(void)finishThisPage{
    [self.PreChatscrollView removeFromSuperview];
    [super finishThisPage];
}

-(void)doOnAccessTokenVerified:(id)cusArgResponseObject
{
    //    [self showActivityIndicator];
    if([CUSApiHelperChat checkIfFetchDataWasSuccess:cusArgResponseObject])
    {
        [CUSApiHelperChat parseAccessTokenSuccessResponse:cusArgResponseObject];
        YOriginPoint =44;
        NSDictionary *online = (NSDictionary*)cusArgResponseObject;
        NSDictionary *chatAdvanceSetting = [[NSDictionary alloc]init];
        chatAdvanceSetting = [[online objectForKey:@"response"] objectForKey:@"chatAdvanceSetting"];
        NSString *company_display_name = [chatAdvanceSetting objectForKey:@"company_display_name"];
        [[NSUserDefaults standardUserDefaults]setObject:company_display_name forKey:@"company_display_name"];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"agent_name"];
        NSString* display_agent_name = [chatAdvanceSetting valueForKey:@"display_agent_name"];
        BOOL display_agent = [display_agent_name boolValue];
        [[NSUserDefaults standardUserDefaults]setBool:display_agent forKey:@"display_agent_name"];
        status = [[online objectForKey:@"response" ] objectForKey:@"widgets_status"];
        
        NSString *preChatFormId = [[online objectForKey:@"response"] objectForKey:@"inapp_prechat_form_id"];
        [[NSUserDefaults standardUserDefaults] setObject:preChatFormId forKey:@"inapp_prechat_form_id"];
        [[NSUserDefaults standardUserDefaults] setObject:status forKey:@"widget_status"];
        
        if (!display_agent)
        {
            [[NSUserDefaults standardUserDefaults]setObject:company_display_name forKey:@"agent_name"];
        }
        
        if ([status isEqualToString:@"online"])
        preChatMessage =[[online objectForKey:@"response"] objectForKey: @"prechat_online_message"];
        else
        preChatMessage =[[online objectForKey:@"response"] objectForKey: @"prechat_offline_message"];
        
        NSMutableDictionary* visitorInfo=[[Cus360Chat sharedInstance]saveinfo];
        [CUSApiHelperChat saveVisitorInfo:self withOnSuccessCallBack:@selector(saveSuccess) andOnFailureCallBack:@selector(saveFailed) withParams:visitorInfo];
    }
    else
    {
        [self showErrorFromResponse:cusArgResponseObject];
    }
    //    [self hideActivityIndicator];
};
-(void)saveSuccess{
    
    [self performSubClassWork];
}
-(void)saveFailed{
    
    [self performSubClassWork];
}

-(void)doOnNetworkTaskFailed:(id)cusArgerror{
    
    [self hideActivityIndicator];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ooops"
                                                        message:[cusArgerror localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}


-(void)loadNavigationBar{
    [super loadNavigationBar];
    
    UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@"Chat"];
    
    UIBarButtonItem *myBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(finishThisPage)];
    
    //UIBarButtonItem *myRightChatHistoryBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"chat.png"] style:UIBarButtonItemStylePlain target:self action:@selector(goToChatHistoryController)];
    // NSDictionary *attrb = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"chalkdust" size:15.0], NSFontAttributeName, [self colorWithHexString:[[Cus360Chat sharedInstance] getNavigationBarTitleColor]], NSForegroundColorAttributeName, nil];
    NSDictionary *attrb = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:16], NSFontAttributeName, [self colorWithHexString:[[Cus360Chat sharedInstance] getNavigationBarTitleColor]], NSForegroundColorAttributeName, nil];
    
    if (![HomerUtils stringIsEmpty:[[Cus360Chat sharedInstance] getUserEmailId]]) {
        UIBarButtonItem *myRightChatHistoryBtn = [[UIBarButtonItem alloc] initWithTitle:@"Chat History" style:UIBarButtonItemStylePlain target:self action:@selector(goToChatHistoryController)];
        [myRightChatHistoryBtn setTitleTextAttributes:attrb forState:UIControlStateNormal];
        item.rightBarButtonItem = myRightChatHistoryBtn;
    }
    
    [myBackButton setTitleTextAttributes:attrb forState:UIControlStateNormal];
    item.leftBarButtonItem = myBackButton;
    
    [self.cusUiNbNavBar popNavigationItemAnimated:NO];
    
    [self.cusUiNbNavBar pushNavigationItem:item animated:NO];
    [self.view addSubview:self.cusUiNbNavBar];
}

-(void)performSubClassWork
{
    [CUSApiHelperChat getPreChatForm:self withOnSuccessCallBack:@selector(doONSccuessfullyFetchedPrechatForm:) andOnFailureCallBack:@selector(doONFailToFetchedPrechatForm:)];
    
    // NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    //[params setObject:@"Shashikant@customer360.co" forKey:@"email"];
    
    //[CUSApiHelperChat getPreChatHistory:self withOnSuccessCallBack:@selector(doONSccuessfullyFetchedPreChatHistory:) andOnFailureCallBack:@selector(doONFailToFetchPreChatHistory:) withParams:@"shashikant@customer360.co"];
    
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
    // Do something...
    
    //    _PreChatscrollView = [[UIScrollView alloc]init];
    //    _PreChatscrollView.delegate=self;
    
    //    [_PreChatscrollView setFrame:[[UIScreen mainScreen] bounds] ];
    //    _scrollView.backgroundColor = [UIColor redColor];
    //    [self.view addSubview:self.scrollView];
    
    //    ModelAccessTokenChat *chatToken = [[Cus360Chat sharedInstance] getAccessTokenChat];
    //    NSString *url=[[NSString alloc] init];
    //
    //    if ([status isEqualToString:@"online"]) {
    //        url = [NSString stringWithFormat:@"%@/getPrechatForm?access_token=%@",[CUSApiHelperChat fetchBaseApiUrl],chatToken.cusNsstrAccessToken];
    //    }
    //    else{
    //        url = [NSString stringWithFormat:@"%@/getPrechatOfflineForm?access_token=%@",[CUSApiHelperChat fetchBaseApiUrl],chatToken.cusNsstrAccessToken];
    //    }
    //
    //    //3e47205aaf6b61fbd9e94bb243830e48
    //    NSURL *getresponse = [NSURL URLWithString:url];
    //    NSError *error = nil;
    //
    //    data = [NSData dataWithContentsOfURL:getresponse options:NSDataReadingUncached error:&error];
    //    dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
}
-(void)goToChatHistoryController{
    Cus360ChatHistoryController *vc = [[Cus360ChatHistoryController alloc] initWithNibName:@"Cus360ChatHistoryController" bundle:nil];
    
    [self presentViewController:vc animated:YES completion:nil];
}

//-(void)doONSccuessfullyFetchedPreChatHistory:(id)cusArgIdResponseObject{
//    NSLog(@"%@", cusArgIdResponseObject);
//    Cus360ChatHistoryController *vc = [[Cus360ChatHistoryController alloc] initWithNibName:@"Cus360ChatHistoryController" bundle:nil];
//
//    [self presentViewController:vc animated:YES completion:nil];
//}
//-(void)doONFailToFetchPreChatHistory:(id)cusArgIdResponseObject{
//    NSLog(@"%@", cusArgIdResponseObject);
//}

-(void)doONSccuessfullyFetchedPrechatForm:(id)cusArgIdResponseObject{
    dict = cusArgIdResponseObject;
    NSLog(@"Dictonary = %@",dict);
    
    if (dict) {
        arrViews =[[dict objectForKey:@"response"]objectForKey:@"form"];
        
        if ([Cus360Chat sharedInstance].cusBoolEnableAutoFormSubmit && arrViews.count == 3 && [[Cus360Chat sharedInstance] getUserEmailId]!=nil) {
            [self autoSubmitPreChatForm];
            return;
        }
        
        UILabel *statusLable = [[UILabel alloc]init];
        statusLable.font = [UIFont systemFontOfSize:16.0f];
        statusLable.frame =CGRectMake(16, 30, [[UIScreen mainScreen] bounds].size.width-20, 30);
        [statusLable setNumberOfLines:0];
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        style.alignment = NSTextAlignmentLeft;
        style.firstLineHeadIndent = 8.0f;
        style.headIndent = 8.0f;
        style.tailIndent = -8.0f;
        
        if (![HomerUtils stringIsEmpty:[Cus360Chat sharedInstance].cusStrPreChatOfflineMessage] && [status isEqualToString:@"offline"]) {
            preChatMessage = [Cus360Chat sharedInstance].cusStrPreChatOfflineMessage;
        }
        else if ((![HomerUtils stringIsEmpty:[Cus360Chat sharedInstance].cusStrPreChatOnlineMessage] && [status isEqualToString:@"online"])){
            preChatMessage = [Cus360Chat sharedInstance].cusStrPreChatOnlineMessage;
        }
        
        NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:preChatMessage attributes:@{ NSParagraphStyleAttributeName : style,NSFontAttributeName: [UIFont systemFontOfSize:17.0]}];
        statusLable.attributedText = attrText;
        CGRect new = [statusLable.attributedText boundingRectWithSize:CGSizeMake(screenW-32, CGFLOAT_MAX) options:(NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin)  context:nil];
        
        if (new.size.height>30)
        {
            statusLable.frame =CGRectMake(16, 30, screenW-20, new.size.height);
        }
        [statusLable setNumberOfLines:0];
        YOriginPoint += statusLable.frame.size.height+24;
        UIView *LableView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenW, YOriginPoint-24)];
        if (![HomerUtils stringIsEmpty:[[Cus360Chat sharedInstance] getPreChatOfflineMsgBackgroundColor]]) {
            [LableView setBackgroundColor:[self colorWithHexString:[[Cus360Chat sharedInstance] getPreChatOfflineMsgBackgroundColor]]];
        }else
        [LableView setBackgroundColor:[UIColor colorWithRed:223.0/255.0 green:223.0/255.0 blue:223.0/255.0 alpha:0.6f]];
        
        [LableView addSubview:statusLable];
        
        [self.PreChatscrollView addSubview:LableView];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, LableView.frame.size.height, screenW, 1)];
        line.backgroundColor = [UIColor blackColor];
        line.alpha = 0.06f;
        [self.PreChatscrollView addSubview:line];

        
        for (int i=1; i<=arrViews.count; i++) {
            
            NSDictionary *element =[[arrViews objectAtIndex:i-1]objectForKey:@"question_container"] ;
            NSString *elementToRender = [element objectForKey:@"type"];
            
            NSString *customFields = [element objectForKey:@"cus_info"];
            
            if (![customFields isKindOfClass:[NSNull class]]){
                
                if ([customFields isEqualToString:@"phone_number"]) {
                    
                    [self makePhoneNumberBox:element];
                }
                if ([customFields isEqualToString:@"address"]) {
                    
                    [self makeAddressBox:element];
                }
            }
            else if ([elementToRender isEqualToString:@"textInput"]) {
                
                [self makeTextInputBox:element];
            }
            
            else if ([elementToRender isEqualToString:@"textArea"]) {
                [self makeTextAreaBox:element];
            }
            else if ([elementToRender isEqualToString:@"date"]){
                
                [self makeDateBox:element];
            }
            else if ([elementToRender isEqualToString:@"time"]){
                
                [self makeTimeBox:element];
            }
            else if ([elementToRender isEqualToString:@"radio"]) {
                
                [self makeRadioButtonBox:element];
            }
            
            else if ([elementToRender isEqualToString:@"checkbox"]){
                
                [self makeCheckBox:element];
            }
            else if ([elementToRender isEqualToString:@"chat_email"]){
                
                [self makeEmailBox:element];
            }
            else if ([elementToRender isEqualToString:@"chat_name"]){
                
                [self makeNameBox:element];
            }
            
            else if ([elementToRender isEqualToString:@"select"]){
                
                [self makeDropDownBox:element];
            }
            
            else if ([elementToRender isEqualToString:@"chat_pre_message"]){
                
                [self makeQuestionBox:element];
            }
        }
        YOriginPoint+=60;
        UIButton *submit = [[UIButton alloc] init];
        [submit setTitle:@"START CHATTING" forState:UIControlStateNormal];
        [submit setFrame:CGRectMake(0, 0, 180, 40)];
        [submit setCenter:CGPointMake(_PreChatscrollView.frame.size.width/2, YOriginPoint)];
        [submit setBackgroundColor:[UIColor colorWithRed:89.0/255.0 green:89.0/255.0 blue:89.0/255.0 alpha:1.0]];
        [submit.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
        [submit showsTouchWhenHighlighted];
        [submit setTitleEdgeInsets:UIEdgeInsetsMake(16, 24, 16, 24)];
        [submit.layer setCornerRadius:3.0f];
        [_PreChatscrollView addSubview:submit];
        [submit addTarget:self action:@selector(submit:) forControlEvents:UIControlEventTouchUpInside];
        
        //**** Do not disturb this statement position or scrollview won't work. ***///
        //**** YOriginPoint increament after each element is rendered on screen. **///
        _PreChatscrollView.contentSize = CGSizeMake(self.PreChatscrollView.frame.size.width, YOriginPoint+100);
    }
    
    else{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Failure" message:@"Please check your internet connection and retry." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    // Do any additional setup after loading the view from its nib.
    [self hideActivityIndicator];
}

-(void)doONFailToFetchedPrechatForm:(id)cusArgIdResponseObject{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





//---------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------
//*************************  RENDERED  VIEW  BOX  ***************


#pragma mark - *** Render View ***

- (UIView*)makeDefaultBox:(NSDictionary*)element withTextField:(BOOL)isTextField
{
    int boxHeight = 64;
    
    //------------------------------
    //Box's main view...
    UIView *boxView = [[UIView alloc] initWithFrame:CGRectMake(self.PreChatscrollView.frame.origin.x, YOriginPoint, self.PreChatscrollView.frame.size.width, boxHeight)];
    YOriginPoint += boxHeight;
    [self.PreChatscrollView addSubview:boxView];
    
    
    //------------------------------
    //Box's Label...
    UILabel *boxLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 16, 200, 15)];
    [boxLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:14]];
    boxLabel.textColor = [UIColor colorWithRed:136.0/255.0 green:136.0/255.0 blue:136.0/255.0 alpha:1.0f];
    
    if ([[element objectForKey:@"required"]isEqualToString:@""])
    {
        boxLabel.text = [element objectForKey:@"question"];
    }else
    {
        boxLabel.text = [NSString stringWithFormat:@"%@ *",[element objectForKey:@"question"]];
    }
    
    [boxView addSubview:boxLabel];
    
    
    //------------------------------
    //Box's Text Field OR UILabel...
    
    if(isTextField)
    {
        UITextField *boxDescription  = [[UITextField alloc] initWithFrame:CGRectMake(16, 16, screenW-32 , 40)];
        //    boxDescription.text = @"Prasad";
        [boxDescription setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:15]];
        boxDescription.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
        boxDescription.delegate=self;
        //    boxDescription.backgroundColor = [UIColor cyanColor];
        NSNumber *tagNo =[element objectForKey:@"question_id"];
        [boxDescription setTag:tagNo.integerValue];
        boxDescription.placeholder = [element objectForKey:@"e_help_text"];
        [boxView addSubview:boxDescription];
    }else
    {
        UILabel *boxDescription = [[UILabel alloc] initWithFrame:CGRectMake(16, 32, screenW-32 , 24)];
        boxDescription.text = @"this is label description";
        [boxDescription setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:15]];
        boxDescription.textAlignment = NSTextAlignmentLeft;
        [boxView addSubview:boxDescription];
    }
    
    //------------------------------
    //Box's end line...
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 63, screenW-32, 1)];
    line.backgroundColor = [UIColor colorWithRed:221.0/255.0f green:221.0/255.0f blue:221.0/255.0f alpha:1.0f];
    [boxView addSubview:line];
    
    return boxView;
}

-(UITextField*)subViewOfKindUITextField:(UIView*)parentView
{
    for (UIView *view in parentView.subviews) {
        if([view isKindOfClass:[UITextField class]]){
            return (UITextField*)view;
        }
    }
    
    return [[UITextField alloc] init];
}

-(void)makeTimeBox:(NSDictionary*)element{

    UIView *boxView = [self makeDefaultBox:element withTextField:YES];
    
    UITextField *cusDateInput = [self subViewOfKindUITextField:boxView];
    [_cusChatUITextFieldTime addObject:cusDateInput];
}

-(void)makeDateBox:(NSDictionary*)element{

    UIView *boxView = [self makeDefaultBox:element withTextField:YES];
    
    UITextField *cusDateInput = [self subViewOfKindUITextField:boxView];
    [_cusChatUITextFieldDate addObject:cusDateInput];
}

-(void)makeTextInputBox:(NSDictionary*)element{
   /*
    //    NSLog(@"%@", element);
    UIView *new = [[UIView alloc]initWithFrame:CGRectMake(self.PreChatscrollView.frame.origin.x, YOriginPoint, self.PreChatscrollView.frame.size.width, 64)];
    YOriginPoint+=64 ;//16+32+8
    [new setBackgroundColor:[UIColor lightTextColor]];
    
    [self.PreChatscrollView addSubview:new];
    
    UITextField *cusTextInput  = [[UITextField alloc] init];
    //    cusTextInput.text = @"Prasad";
    [cusTextInput setFrame:CGRectMake(16, 16, screenW-32, 24)];
    cusTextInput.delegate=self;
    NSNumber *tagNo =[element objectForKey:@"question_id"];
    int tage = tagNo.integerValue;
    [cusTextInput setTag:tage];
    NSString *placeholder = [element objectForKey:@"e_help_text"];
    if (![[element objectForKey:@"required"]isEqualToString:@""]) {
        placeholder = [placeholder stringByAppendingString:@" *"];
    }
    
    cusTextInput.placeholder = placeholder;
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 48,screenW-32 , 1)];
    line.backgroundColor = [UIColor colorWithRed:221.0/255.0f green:221.0/255.0f blue:221.0/255.0f alpha:1.0f];
    [new addSubview:line];
    cusTextInput.font = [UIFont systemFontOfSize:15];
    cusTextInput.borderStyle = UITextBorderStyleNone;
    //  [new addSubview:nameLable];
    [_cusChatUITextField addObject:cusTextInput];
    [new addSubview:cusTextInput];
    */
}


-(void)makeTextAreaBox:(NSDictionary*)element
{
    /*
    UIView *new = [[UIView alloc]initWithFrame:CGRectMake(self.PreChatscrollView.frame.origin.x, YOriginPoint, self.PreChatscrollView.frame.size.width, 120)];
    //    YOriginPoint+=120;
    //    [new setBackgroundColor:[UIColor lightTextColor]];
    [self.PreChatscrollView addSubview:new];
    
    UILabel *nameLable = [[UILabel alloc] init];
    [nameLable setFrame:CGRectMake(16, 16, 200, 24)];
    nameLable.font = [UIFont boldSystemFontOfSize:17];
    nameLable.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0f];
    
    if ([[element objectForKey:@"required"]isEqualToString:@""]) {
        nameLable.text = [element objectForKey:@"question"];
    }
    else {
        nameLable.text = [NSString stringWithFormat:@"%@ *",[element objectForKey:@"question"]];
    }
    CGRect size = [nameLable.text boundingRectWithSize:CGSizeMake(screenW-32, CGFLOAT_MAX) options:(NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:17.0]} context:nil];
    if (size.size.height>24)
    {
        nameLable.frame =CGRectMake(16, 8, size.size.width, size.size.height);
        [nameLable setNumberOfLines:0];
    }else{
        nameLable.frame =CGRectMake(16, 8, size.size.width, 24);
    }
    
    [new addSubview:nameLable];
    
    UITextView *custextArea = [[UITextView alloc] init];
    [custextArea setFrame:CGRectMake(16, nameLable.frame.origin.y+nameLable.frame.size.height+8, screenW-32, 72)];//8+24+8+72+8
    custextArea.delegate = self;
    custextArea.font = [UIFont systemFontOfSize:15];
    NSNumber *tagNo =[element objectForKey:@"question_id"];
    int tage = tagNo.integerValue;
    [custextArea setTag:tage];
    //     question.layer.borderWidth=0.5f;
    //    question.layer.cornerRadius=5.0f;
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, custextArea.frame.origin.y+custextArea.frame.size.height+8 ,screenW-32 , 1)];
    line.backgroundColor = [UIColor colorWithRed:221.0/255.0f green:221.0/255.0f blue:221.0/255.0f alpha:1.0f];
    
    [new addSubview:line];
    YOriginPoint+=line.frame.origin.y+10;
    [new setFrame:CGRectMake(new.frame.origin.x, new.frame.origin.y,  screenW, line.frame.origin.y+11)];
    
    [new addSubview:custextArea];
    [_cusChatUITextView addObject:custextArea];
    //    NSLog(@"makeQuestionBox");
     */
}


-(void)makePhoneNumberBox:(NSDictionary *)element {
    /*
    //    NSLog(@"%@", element);
    UIView *new = [[UIView alloc]initWithFrame:CGRectMake(self.PreChatscrollView.frame.origin.x, YOriginPoint, self.PreChatscrollView.frame.size.width, 64)];
    YOriginPoint+=64 ;//16+32+8
    [new setBackgroundColor:[UIColor lightTextColor]];
    
    [self.PreChatscrollView addSubview:new];
    
    phoneNo = [[UITextField alloc] init];
    [phoneNo setFrame:CGRectMake(16, 16, screenW-32, 24)];
    phoneNo.delegate=self;
    phoneNo.keyboardType = UIKeyboardTypeNumberPad;
    NSString *placeholder =[element objectForKey:@"e_help_text"];
    if (![[element objectForKey:@"required"]isEqualToString:@""]) {
        placeholder = [placeholder stringByAppendingString:@" *"];
    }
    
    phoneNo.placeholder = placeholder;
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 48,screenW-32 , 1)];
    line.backgroundColor = [UIColor colorWithRed:221.0/255.0f green:221.0/255.0f blue:221.0/255.0f alpha:1.0f];
    [new addSubview:line];
    phoneNo.font = [UIFont systemFontOfSize:15];
    phoneNo.borderStyle = UITextBorderStyleNone;
    //  [new addSubview:nameLable];
    [new addSubview:phoneNo];
     */
}
-(void)makeAddressBox:(NSDictionary *)element {
    /*
    //    NSLog(@"%@", element);
    UIView *new = [[UIView alloc]initWithFrame:CGRectMake(self.PreChatscrollView.frame.origin.x, YOriginPoint, self.PreChatscrollView.frame.size.width, 64)];
    YOriginPoint+=64;
    [new setBackgroundColor:[UIColor lightTextColor]];
    [self.PreChatscrollView addSubview:new];
    address = [[UITextField alloc] init];
    [address setFrame:CGRectMake(16, 16, screenW-32, 24)];
    address.delegate=self;
    NSString *placeholder =[element objectForKey:@"e_help_text"];
    if (![[element objectForKey:@"required"]isEqualToString:@""]) {
        placeholder = [placeholder stringByAppendingString:@" *"];
    }
    
    address.placeholder = placeholder;
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 48,screenW-32 , 1)];
    line.backgroundColor = [UIColor colorWithRed:221.0/255.0f green:221.0/255.0f blue:221.0/255.0f alpha:1.0f];
    address.font = [UIFont systemFontOfSize:15];
    [new addSubview:line];
    address.borderStyle = UITextBorderStyleNone;
    [new addSubview:address];
     */
}

-(void)makeNameBox:(NSDictionary *)element {
    
    UIView *boxView = [self makeDefaultBox:element withTextField:YES];
    
    name = [self subViewOfKindUITextField:boxView];
    [name setReturnKeyType:UIReturnKeyDone];
    name.autocorrectionType = UITextAutocorrectionTypeNo;
    name.tag = 1;
    
    if (![HomerUtils stringIsEmpty:[Cus360Chat sharedInstance].cusStrUserName])
        name.text = [Cus360Chat sharedInstance].cusStrUserName;
    
}

-(void)makeEmailBox:(NSDictionary *)element
{/*
    UIView *new = [[UIView alloc]initWithFrame:CGRectMake(self.PreChatscrollView.frame.origin.x, YOriginPoint, self.PreChatscrollView.frame.size.width, 64)];
    YOriginPoint+=64;
    [new setBackgroundColor:[UIColor lightTextColor]];
    
    [self.PreChatscrollView addSubview:new];
    email = [[UITextField alloc] init];
    [email setFrame:CGRectMake(16, 16, screenW-32, 24)];
    email.keyboardType =UIKeyboardTypeEmailAddress;
    //    email.text = @"xyz@xyz.com";
    email.delegate=self;
    email.borderStyle = UITextBorderStyleNone;
    email.font = [UIFont systemFontOfSize:15];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 48,screenW-32 , 1)];
    line.backgroundColor = [UIColor colorWithRed:221.0/255.0f green:221.0/255.0f blue:221.0/255.0f alpha:1.0f];
    
    if (![HomerUtils stringIsEmpty:[Cus360Chat sharedInstance].cusStrDeveloperEmaiId]) {
        email.text = [Cus360Chat sharedInstance].cusStrDeveloperEmaiId;
    }else{
        if (![HomerUtils stringIsEmpty:[[Cus360Chat sharedInstance] getUserEmailId]]) {
            email.text = [[Cus360Chat sharedInstance] getUserEmailId];
        }else{
            NSString *placeholder =[element objectForKey:@"e_help_text"];
            email.placeholder = [placeholder stringByAppendingString:@" *"];
        }
    }
    
    //    [new addSubview:nameLable];
    [new addSubview:email];
    [new addSubview:line];
    
    //    NSLog(@"makeEmailBox");
    */
}


-(void)makeRadioButtonBox:(NSDictionary *)element{
    /*
    UIView *new = [[UIView alloc]initWithFrame:CGRectMake(self.PreChatscrollView.frame.origin.x, YOriginPoint, self.PreChatscrollView.frame.size.width, 160)];
    
    YOriginPoint+=160;
    
    [new setBackgroundColor:[UIColor lightTextColor]];
    [self.PreChatscrollView addSubview:new];
    
    UILabel *nameLable = [[UILabel alloc] init];
    [nameLable setFrame:CGRectMake(16, 16, 200, 24)];
    nameLable.font = [UIFont boldSystemFontOfSize:17];
    nameLable.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0f];
    
    if ([[element objectForKey:@"required"]isEqualToString:@""])
    {
        nameLable.text = [element objectForKey:@"question"];
    }
    else {
        nameLable.text = [NSString stringWithFormat:@"%@ *",[element objectForKey:@"question"]];
    }
    CGRect size = [nameLable.text boundingRectWithSize:CGSizeMake(screenW-32, CGFLOAT_MAX) options:(NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:17.0]} context:nil];
    if (size.size.height>24)
    {
        nameLable.frame =CGRectMake(16, 8, size.size.width, size.size.height);
        [nameLable setNumberOfLines:0];
    }else{
        nameLable.frame =CGRectMake(16, 8, size.size.width, 24);
    }
    [new addSubview:nameLable];
    NSMutableArray* buttons = [NSMutableArray arrayWithCapacity:[[element objectForKey:@"answers"] count]];
    
    NSMutableArray * buttonTitles = [[NSMutableArray alloc]initWithArray:[element objectForKey:@"answers"]];
    
    CGRect btnRect =CGRectMake(20, nameLable.frame.origin.y+nameLable.frame.size.height+8, 200, 30);
    for (int option = 0; option<buttonTitles.count; option++)
    {
        NSString* optionTitle = [[buttonTitles objectAtIndex:option]objectForKey:@"answer"];
        RadioButton* btn = [[RadioButton alloc] initWithFrame:btnRect];
        [btn addTarget:self action:@selector(onRadioButtonValueChanged:) forControlEvents:UIControlEventValueChanged];
        //        btnRect.origin.y += 40;
        
        [btn setTitle:optionTitle forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [btn setImage:[UIImage imageNamed:@"radio-default"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"radio-selected"] forState:UIControlStateSelected];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 0);
        [new addSubview:btn];
        
        btnRect.origin.y += 40;
        
        if (isgreater(btnRect.origin.y + btnRect.size.height, new.frame.size.height))
        {
            [new setFrame:CGRectMake(new.frame.origin.x, new.frame.origin.y, new.frame.size.width, new.frame.size.height+btnRect.size.height+10)];
            YOriginPoint+=btnRect.size.height+10;
        }
        
        [buttons addObject:btn];
    }
    [buttons[0] setGroupButtons:buttons];
    
    
    //    NSLog(@"makeRadioButtons");
    */
}
-(void)onRadioButtonValueChanged:(RadioButton*)button
{
    
    RadioButtonNumber = button.selectedButton;
}


-(void)makeCheckBox:(NSDictionary *)element{
    /*
    UIView *new = [[UIView alloc]initWithFrame:CGRectMake(self.PreChatscrollView.frame.origin.x, YOriginPoint, self.PreChatscrollView.frame.size.width, 160)];
    YOriginPoint+=160;
    [new setBackgroundColor:[UIColor lightTextColor]];
    
    [self.PreChatscrollView addSubview:new];
    
    UILabel *nameLable = [[UILabel alloc] init];
    [nameLable setFrame:CGRectMake(16, 16, 200, 24)];
    nameLable.font = [UIFont boldSystemFontOfSize:17];
    nameLable.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0f];
    
    if ([[element objectForKey:@"required"]isEqualToString:@""]) {
        nameLable.text = [element objectForKey:@"question"];
    }
    else {
        nameLable.text = [NSString stringWithFormat:@"%@ *",[element objectForKey:@"question"]];
    }
    CGRect size = [nameLable.text boundingRectWithSize:CGSizeMake(screenW-32, CGFLOAT_MAX) options:(NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:17.0]} context:nil];
    if (size.size.height>24)
    {
        nameLable.frame =CGRectMake(16, 8, size.size.width, size.size.height);
        [nameLable setNumberOfLines:0];
    }else{
        nameLable.frame =CGRectMake(16, 8, size.size.width, 24);
    }
    
    [new addSubview:nameLable];
    
    checkBoxArray = [[NSMutableArray alloc]init];
    NSMutableArray *buttons = [NSMutableArray arrayWithCapacity:[[element objectForKey:@"answers"]  count]];
    NSMutableArray *buttonTitles = [[NSMutableArray alloc]initWithArray:[element objectForKey:@"answers"]];
    
    CGRect btnRect = CGRectMake(20, nameLable.frame.origin.y+nameLable.frame.size.height+8, 200, 30);
    
    for (int option = 0; option<buttonTitles.count; option++)
    {
        UIButton *checkbox = [[UIButton alloc] init];
        [checkbox setFrame:btnRect];
        NSString* optionTitle = [[buttonTitles objectAtIndex:option]objectForKey:@"answer"];
        [checkbox setTitle:optionTitle forState:UIControlStateNormal];
        [checkbox setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        checkbox.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        
        NSString* optionTag = [[buttonTitles objectAtIndex:option]objectForKey:@"answer_id"];
        [checkbox setTag:optionTag.integerValue];
        
        // 20x20 is the size of the checckbox that you want
        // create 2 images sizes 20x20 , one empty square and
        // another of the same square with the checkmark in it
        // Create 2 UIImages with these new images, then:
        
        [checkbox setImage:[UIImage imageNamed:@"checkbox-default"]
                  forState:UIControlStateNormal];
        [checkbox setImage:[UIImage imageNamed:@"checkbox-selected"]
                  forState:UIControlStateSelected];
        checkbox.adjustsImageWhenHighlighted=YES;
        checkbox.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        checkbox.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 0);
        [checkbox addTarget:self action:@selector(checkboxSelected:) forControlEvents:UIControlEventTouchUpInside];
        [new addSubview:checkbox];
        [buttons addObject:checkbox];
        btnRect.origin.y += 40;
        
        if (isgreater(btnRect.origin.y + btnRect.size.height, new.frame.size.height))
        {
            [new setFrame:CGRectMake(new.frame.origin.x, new.frame.origin.y, new.frame.size.width, new.frame.size.height+btnRect.size.height+10)];
            YOriginPoint+=btnRect.size.height+10;
        }
    }
    
    //    NSLog(@"makeChekBoxes");
    */
}
-(void)checkboxSelected:(UIButton *)sender
{
    if (![sender isSelected]) {
        [sender setSelected:YES];
        [checkBoxArray addObject:sender ];
    }
    else
    {
        [sender setSelected:NO];
        [checkBoxArray removeObject:sender];
    }
}


-(void)makeQuestionBox:(NSDictionary *)element{
    /*
    UIView *new = [[UIView alloc]initWithFrame:CGRectMake(self.PreChatscrollView.frame.origin.x, YOriginPoint, self.PreChatscrollView.frame.size.width, 120)];
    //    YOriginPoint+=120;
    //    [new setBackgroundColor:[UIColor lightTextColor]];
    
    [self.PreChatscrollView addSubview:new];
    
    
    UILabel *nameLable = [[UILabel alloc] init];
    [nameLable setFrame:CGRectMake(16, 16, 200, 24)];
    nameLable.font = [UIFont boldSystemFontOfSize:17];
    nameLable.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0f];
    
    if ([[element objectForKey:@"required"]isEqualToString:@""]) {
        nameLable.text = [element objectForKey:@"question"];
    }
    else {
        nameLable.text = [NSString stringWithFormat:@"%@ *",[element objectForKey:@"question"]];
    }
    CGRect size = [nameLable.text boundingRectWithSize:CGSizeMake(screenW-32, CGFLOAT_MAX) options:(NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:17.0]} context:nil];
    if (size.size.height>24)
    {
        nameLable.frame =CGRectMake(16, 8, size.size.width, size.size.height);
        [nameLable setNumberOfLines:0];
    }else{
        nameLable.frame =CGRectMake(16, 8, size.size.width, 24);
    }
    
    [new addSubview:nameLable];
    
    question= [[UITextView alloc] init];
    [question setFrame:CGRectMake(16, nameLable.frame.origin.y+nameLable.frame.size.height+8, screenW-32, 72)];//8+24+8+72+8
    question.delegate = self;
    question.font = [UIFont systemFontOfSize:15];
    if (![HomerUtils stringIsEmpty:[Cus360Chat sharedInstance].cusStrUserFeedback]) {
        question.text = [Cus360Chat sharedInstance].cusStrUserFeedback;
    }
    //    question.text = @"jadkf hagsdfjhasfjkhsdfjkahsdg";
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, question.frame.origin.y+question.frame.size.height+8 ,screenW-32 , 1)];
    line.backgroundColor = [UIColor colorWithRed:221.0/255.0f green:221.0/255.0f blue:221.0/255.0f alpha:1.0f];
    
    [new addSubview:line];
    YOriginPoint+=line.frame.origin.y+10;
    [new setFrame:CGRectMake(new.frame.origin.x, new.frame.origin.y,  screenW, line.frame.origin.y+11)];
    
    [new addSubview:question];
    */
}

-(void)makeDropDownBox:(NSDictionary *)element{
    /*
    //    NSLog(@"%@", element);
    
    UIView *new = [[UIView alloc]initWithFrame:CGRectMake(self.PreChatscrollView.frame.origin.x, YOriginPoint, self.PreChatscrollView.frame.size.width, 64)];
    //    YOriginPoint+=64;
    [new setBackgroundColor:[UIColor lightTextColor]];
    
    [self.PreChatscrollView addSubview:new];
    UILabel *nameLable = [[UILabel alloc] init];
    [nameLable setFrame:CGRectMake(16, 16, 200, 24)];
    nameLable.font = [UIFont boldSystemFontOfSize:17];
    nameLable.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0f];
    
    if ([[element objectForKey:@"required"]isEqualToString:@""]) {
        nameLable.text = [element objectForKey:@"question"];
    }
    else {
        nameLable.text = [NSString stringWithFormat:@"%@ *",[element objectForKey:@"question"]];
    }
    CGRect size = [nameLable.text boundingRectWithSize:CGSizeMake(screenW-32, CGFLOAT_MAX) options:(NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:17.0]} context:nil];
    if (size.size.height>24)
    {
        nameLable.frame =CGRectMake(16, 8, size.size.width, size.size.height);
        [nameLable setNumberOfLines:0];
    }else{
        nameLable.frame =CGRectMake(16, 8, size.size.width, 24);
    }
    
    [new addSubview:nameLable];
    UITextField* dropdown= [[UITextField alloc] init];
    
    NSNumber *tagNo =[element objectForKey:@"question_id"];
    int tage = tagNo.integerValue;
    [dropdown setTag:tage];
    //    dropdown.tag = 1;
    dropdown.delegate=self;
    [dropdown setFrame:CGRectMake(16, nameLable.frame.origin.y+nameLable.frame.size.height+8, screenW-32, 24)];
    dropdown.borderStyle = UITextBorderStyleNone;
    NSString *placeholder =[element objectForKey:@"e_help_text"];
    if (![[element objectForKey:@"required"]isEqualToString:@""]) {
        placeholder = [placeholder stringByAppendingString:@" *"];
    }
    //    dropdown.placeholder = placeholder;
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(dropdown.frame)+8,screenW-32 , 1)];
    line.backgroundColor = [UIColor colorWithRed:221.0/255.0f green:221.0/255.0f blue:221.0/255.0f alpha:1.0f];
    
    [new addSubview:line];
    
    [new addSubview:dropdown];
    [_cusChatUITextFieldSelect addObject:dropdown];
    
    UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(screenW-48, CGRectGetMinY(dropdown.frame), 12,12 )];
    arrow.image = [UIImage imageNamed:@"arrow"];
    [new addSubview:arrow];
    YOriginPoint+=line.frame.origin.y+10;
    [new setFrame:CGRectMake(new.frame.origin.x, new.frame.origin.y,  screenW, line.frame.origin.y+11)];
    //    [new addSubview:error];
    //    NSLog(@"makeDropDownBox");
    */
    
    UIView *boxView = [self makeDefaultBox:element withTextField:NO];
}



//*************************  END  ***************
//---------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------





#pragma mark - sumbit process
-(BOOL)validateAllElements{
    
    UIAlertView *alert;
    for (int i=1; i<=arrViews.count; i++)
    {
        NSDictionary *elements =[[arrViews objectAtIndex:i-1]objectForKey:@"question_container"] ;
        NSString *elementToCheck = [elements objectForKey:@"type"];
        NSString *parameter = [elements objectForKey:@"question_id"];
        
        if (![[elements objectForKey:@"custom_validation"]isKindOfClass:[NSNull class]]) {
            if ([[elements objectForKey:@"cus_info"]isEqualToString:@"phone_number"]) {
                
                NSString *custom_validation=[elements objectForKey:@"custom_validation"];
                NSData *validation = [custom_validation dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *valid  = [NSJSONSerialization JSONObjectWithData:validation options:0 error:nil];
                if ([valid objectForKey:@"noOfDigit"]) {
                    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
                    f.numberStyle = NSNumberFormatterDecimalStyle;
                    NSNumber * noOfDigit = [f numberFromString:[valid objectForKey:@"noOfDigit"]];
                    if(! (phoneNo.text.length==noOfDigit.integerValue))
                    {
                        alert = [[UIAlertView alloc] initWithTitle: [elements objectForKey:@"question"] message:@"Please enter appropriate response" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        return NO;
                    }
                }
            }
        }
        if (![[elements objectForKey:@"required"]isEqualToString:@""])
        {
            if ([elementToCheck isEqualToString:@"textInput"])
            {
                for (int P =0; P<_cusChatUITextField.count; P++)
                {
                    int tagNo = [[_cusChatUITextField objectAtIndex:P] tag];
                    NSString *tagString= [NSString stringWithFormat:@"%d",tagNo];
                    if ([parameter isEqualToString:tagString])
                    {
                        UITextField *textField = (UITextField*)[_cusChatUITextField objectAtIndex:P];
                        if ([textField.text isEqualToString:@""]) {
                            alert = [[UIAlertView alloc] initWithTitle: [elements objectForKey:@"question"] message:@"Please enter appropriate response" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                            [alert show];
                            return NO;
                        }
                        break;
                    }
                }
            }
            if ([elementToCheck isEqualToString:@"textArea"])
            {
                for (int P =0; P<_cusChatUITextView.count; P++)
                {
                    int tagNo = [[_cusChatUITextView objectAtIndex:P] tag];
                    NSString *tagString= [NSString stringWithFormat:@"%d",tagNo];
                    if ([parameter isEqualToString:tagString])
                    {
                        UITextView *textView = (UITextView*)[_cusChatUITextView objectAtIndex:P];
                        if ([textView.text isEqualToString:@""]) {
                            alert = [[UIAlertView alloc] initWithTitle: [elements objectForKey:@"question"] message:@"Please enter appropriate response" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                            [alert show];
                            return NO;
                        }
                        break;
                    }
                }
            }
            else if ([elementToCheck isEqualToString:@"radio"])
            {
                if (RadioButtonNumber == nil) {
                    alert = [[UIAlertView alloc] initWithTitle: [elements objectForKey:@"question"] message:@"Please select appropriate option" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    return NO;
                }
            }
            else if ([elementToCheck isEqualToString:@"checkbox"]){
                
                if (checkBoxArray.count == 0)
                {
                    alert = [[UIAlertView alloc] initWithTitle:[elements objectForKey:@"question"] message:@"Please select appropriate option" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    return NO;
                }
            }
            else if ([elementToCheck isEqualToString:@"chat_email"]){
                
                if (![self NSStringIsValidEmail:email.text]) {
                    
                    alert = [[UIAlertView alloc] initWithTitle:[elements objectForKey:@"question"] message:@"Please enter valid email ID" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    return NO;
                }
            }
            else if ([elementToCheck isEqualToString:@"chat_name"]){
                
                if ([HomerUtils stringIsEmpty:name.text])
                {
                    alert = [[UIAlertView alloc] initWithTitle:[elements objectForKey:@"question"]message:@"Please fill the name field" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }
                return NO;
                
            }
            
            else if ([elementToCheck isEqualToString:@"select"]){
                for (int P =0; P<_cusChatUITextFieldSelect.count; P++)
                {
                    int tagNo = [[_cusChatUITextFieldSelect objectAtIndex:P] tag];
                    NSString *tagString= [NSString stringWithFormat:@"%d",tagNo];
                    if ([parameter isEqualToString:tagString])
                    {
                        UITextField *textView = (UITextField*)[_cusChatUITextFieldSelect objectAtIndex:P];
                        if ([textView.text isEqualToString:@""]) {
                            alert = [[UIAlertView alloc] initWithTitle: [elements objectForKey:@"question"] message:@"Please enter appropriate response" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                            [alert show];
                            return NO;
                        }
                        break;
                    }
                }
            }
            
            else if ([elementToCheck isEqualToString:@"chat_pre_message"])
            {
                if ([HomerUtils stringIsEmpty:question.text])
                {
                    alert = [[UIAlertView alloc] initWithTitle:[elements objectForKey:@"question"] message:@"Please enter appropriate response" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    return NO;
                    
                }
            }
            
            
            else if ([elementToCheck isEqualToString:@"date"]){
                for (int P =0; P<_cusChatUITextFieldDate.count; P++)
                {
                    int tagNo = [[_cusChatUITextFieldDate objectAtIndex:P] tag];
                    NSString *tagString= [NSString stringWithFormat:@"%d",tagNo];
                    if ([parameter isEqualToString:tagString])
                    {
                        UITextField *textView = (UITextField*)[_cusChatUITextFieldDate objectAtIndex:P];
                        if ([textView.text isEqualToString:@""]) {
                            alert = [[UIAlertView alloc] initWithTitle: [elements objectForKey:@"question"] message:[NSString stringWithFormat:@"Please enter %@",[elements objectForKey:@"question"]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                            [alert show];
                            return NO;
                        }
                        break;
                    }
                }
            }
            else if ([elementToCheck isEqualToString:@"time"]){
                for (int P =0; P<_cusChatUITextFieldTime.count; P++)
                {
                    int tagNo = [[_cusChatUITextFieldTime objectAtIndex:P] tag];
                    NSString *tagString= [NSString stringWithFormat:@"%d",tagNo];
                    if ([parameter isEqualToString:tagString])
                    {
                        UITextField *textView = (UITextField*)[_cusChatUITextFieldTime objectAtIndex:P];
                        if ([textView.text isEqualToString:@""]) {
                            alert = [[UIAlertView alloc] initWithTitle: [elements objectForKey:@"question"] message:[NSString stringWithFormat:@"Please enter %@",[elements objectForKey:@"question"]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                            [alert show];
                            return NO;
                        }
                        break;
                    }
                }
            }
        }
    }
    return YES;
}

-(void)submitParams
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    for (int i=1; i<=arrViews.count; i++) {
        
        NSDictionary *element =[[arrViews objectAtIndex:i-1]objectForKey:@"question_container"] ;
        NSString *parameter = [element objectForKey:@"question_id"];
        
        NSString *elementToRender = [element objectForKey:@"type"];
        
        NSString *customFields = [element objectForKey:@"cus_info"];
        
        if (![customFields isKindOfClass:[NSNull class]]) {
            if ([customFields isEqualToString:@"phone_number"]) {
                if ([phoneNo.text isEqualToString:@""]) {
                    
                    [params setObject:@"" forKey:[NSString stringWithFormat:@"queId_%@",parameter]];
                }
                else
                {
                    [params setObject:phoneNo.text forKey:[NSString stringWithFormat:@"queId_%@",parameter]];
                }
            }
            if ([customFields isEqualToString:@"address"]) {
                if ([address.text isEqualToString:@""]) {
                    
                    [params setObject:@"" forKey:[NSString stringWithFormat:@"queId_%@",parameter]];
                }
                else
                {
                    [params setObject:address.text forKey:[NSString stringWithFormat:@"queId_%@",parameter]];
                }
            }
        }
        else if ([elementToRender isEqualToString:@"textArea"])
        {
            for (int P =0; P<_cusChatUITextView.count; P++)
            {
                int tagNo = [[_cusChatUITextView objectAtIndex:P] tag];
                NSString *tagString= [NSString stringWithFormat:@"%d",tagNo];
                if ([parameter isEqualToString:tagString])
                {
                    UITextView *textView = (UITextView*)[_cusChatUITextView objectAtIndex:P];
                    if ([textView.text isEqualToString:@""])
                    {
                        [params setObject:@"" forKey:[NSString stringWithFormat:@"queId_%@",parameter]];
                    }
                    else
                    {
                        [params setObject:textView.text forKey:[NSString stringWithFormat:@"queId_%@",parameter]];
                    }
                    break;
                }
            }
        }
        else if ([elementToRender isEqualToString:@"textInput"])
        {
            for (int P =0; P<_cusChatUITextField.count; P++)
            {
                int tagNo = [[_cusChatUITextField objectAtIndex:P] tag];
                NSString *tagString= [NSString stringWithFormat:@"%d",tagNo];
                if ([parameter isEqualToString:tagString])
                {
                    UITextField *textField = (UITextField*)[_cusChatUITextField objectAtIndex:P];
                    if ([textField.text isEqualToString:@""]) {
                        
                        [params setObject:@"" forKey:[NSString stringWithFormat:@"queId_%@",parameter]];
                    }
                    else
                    {
                        [params setObject:textField.text forKey:[NSString stringWithFormat:@"queId_%@",parameter]];
                    }
                    break;
                }
            }
        }
        else if ([elementToRender isEqualToString:@"date"])
        {
            for (int P =0; P<_cusChatUITextFieldDate.count; P++)
            {
                int tagNo = [[_cusChatUITextFieldDate objectAtIndex:P] tag];
                NSString *tagString= [NSString stringWithFormat:@"%d",tagNo];
                if ([parameter isEqualToString:tagString])
                {
                    UITextField *textField = (UITextField*)[_cusChatUITextFieldDate objectAtIndex:P];
                    if ([textField.text isEqualToString:@""]) {
                        
                        [params setObject:@"" forKey:[NSString stringWithFormat:@"queId_%@",parameter]];
                    }
                    else
                    {
                        [params setObject:textField.text forKey:[NSString stringWithFormat:@"queId_%@",parameter]];
                    }
                    break;
                }
            }
        }
        else if ([elementToRender isEqualToString:@"time"])
        {
            for (int P =0; P<_cusChatUITextFieldTime.count; P++)
            {
                int tagNo = [[_cusChatUITextFieldTime objectAtIndex:P] tag];
                NSString *tagString= [NSString stringWithFormat:@"%d",tagNo];
                if ([parameter isEqualToString:tagString])
                {
                    UITextField *textField = (UITextField*)[_cusChatUITextFieldTime objectAtIndex:P];
                    if ([textField.text isEqualToString:@""]) {
                        
                        [params setObject:@"" forKey:[NSString stringWithFormat:@"queId_%@",parameter]];
                    }
                    else
                    {
                        [params setObject:textField.text forKey:[NSString stringWithFormat:@"queId_%@",parameter]];
                    }
                    break;
                }
            }
        }
        else if ([elementToRender isEqualToString:@"radio"])
        {
            NSMutableArray *answers = (NSMutableArray*)[element objectForKey:@"answers"];
            NSMutableArray *radButtons = [[NSMutableArray alloc]init];
            
            for (int j=0; j<answers.count; j++)
            {
                [radButtons addObject:[[answers objectAtIndex:j] objectForKey:@"answer"]];
            }
            NSString* optionTitle = RadioButtonNumber.titleLabel.text;
            NSUInteger i =0;
            for (i = 0; i<radButtons.count; i++) {
                if ([optionTitle isEqualToString:[radButtons objectAtIndex:i]]) {
                    break;
                }
            }
            if (i==radButtons.count) {
                
            }else{
                [params setObject:[[answers objectAtIndex:i] objectForKey:@"answer_id"] forKey:[NSString stringWithFormat:@"queId_%@",parameter]];
            }
        }
        else if ([elementToRender isEqualToString:@"checkbox"]){
            //            NSMutableArray *answers = (NSMutableArray*)[element objectForKey:@"answers"];
            NSMutableArray *checks = [[NSMutableArray alloc]init];
            for (int j=0; j<checkBoxArray.count; j++)
            {
                [checks addObject:[NSString stringWithFormat:@"%d",(int)[[checkBoxArray objectAtIndex:j] tag]]];
            }
            [params setObject:checks forKey:[NSString stringWithFormat:@"queId_%@",parameter]];
        }
        else if ([elementToRender isEqualToString:@"chat_email"]){
            if ([email.text isEqualToString:@""]) {
                
                [params setObject:@"" forKey:[NSString stringWithFormat:@"queId_%@",parameter]];
            }
            else
            {
                [params setObject:email.text forKey:[NSString stringWithFormat:@"queId_%@",parameter]];
            }
        }
        else if ([elementToRender isEqualToString:@"chat_name"]){
            if ([name.text isEqualToString:@""]) {
                NSString* name_from_email = email.text;
                name_from_email = [name_from_email substringToIndex:[name_from_email rangeOfString:@"@"].location];
                [params setObject:name_from_email forKey:[NSString stringWithFormat:@"queId_%@",parameter]];
            } else
            {
                [params setObject:name.text forKey:[NSString stringWithFormat:@"queId_%@",parameter]];
            }
        }
        
        else if ([elementToRender isEqualToString:@"select"])
        {
            for (int P =0; P<_cusChatUITextFieldSelect.count; P++)
            {
                int tagNo = [[_cusChatUITextFieldSelect objectAtIndex:P] tag];
                NSString *tagString= [NSString stringWithFormat:@"%d",tagNo];
                if ([parameter isEqualToString:tagString])
                {
                    UITextField *textField = (UITextField*)[_cusChatUITextFieldSelect objectAtIndex:P];
                    if ([textField.text isEqualToString:@""]) {
                        [params setObject:@"" forKey:[NSString stringWithFormat:@"queId_%@",parameter]];
                    }
                    else
                    {
                        NSMutableArray *answers = (NSMutableArray*)[element objectForKey:@"answers"];
                        NSMutableArray *dropdownOpts = [[NSMutableArray alloc]init];
                        for (int j=0; j<answers.count; j++)
                        {
                            [dropdownOpts addObject:[[answers objectAtIndex:j] objectForKey:@"answer"]];
                        }
                        //                        NSLog(@"Dropdown text = %@", textField.text);
                        NSString *dropdownOption = textField.text;
                        NSUInteger i = 0;
                        for (i = 0; i<dropdownOpts.count; i++) {
                            if ([dropdownOption isEqualToString:[dropdownOpts objectAtIndex:i]]) {
                                break;
                            }
                        }
                        [params setObject:[[answers objectAtIndex:i] objectForKey:@"answer_id"] forKey:[NSString stringWithFormat:@"queId_%@",parameter]];
                    }
                    break;
                }
            }
        }
        
        else if ([elementToRender isEqualToString:@"chat_pre_message"]){
            if ([question.text isEqualToString:@""])
            {
                [params setObject:@"" forKey:[NSString stringWithFormat:@"queId_%@",parameter]];
            }
            else{
                [params setObject:question.text forKey:[NSString stringWithFormat:@"queId_%@",parameter]];
            }
        }
    }
    
    [self executeSavePreChat:params];
}

-(void)autoSubmitPreChatForm{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    for (int i=1; i<=arrViews.count; i++) {
        
        NSDictionary *element =[[arrViews objectAtIndex:i-1]objectForKey:@"question_container"] ;
        NSString *parameter = [element objectForKey:@"question_id"];
        
        NSString *elementToRender = [element objectForKey:@"type"];
        
        if ([elementToRender isEqualToString:@"chat_email"]){
            [params setObject:[[Cus360Chat sharedInstance] getUserEmailId] forKey:[NSString stringWithFormat:@"queId_%@",parameter]];
        }
        else if ([elementToRender isEqualToString:@"chat_name"]) {
            if ([HomerUtils stringIsEmpty:[Cus360Chat sharedInstance].cusStrUserName]) {
                NSString *emailStr = [[Cus360Chat sharedInstance] getUserEmailId];
                emailStr = [emailStr substringWithRange: NSMakeRange(0, [emailStr rangeOfString: @"@"].location)];
                [params setObject:emailStr forKey:[NSString stringWithFormat:@"queId_%@",parameter]];
            } else {
                [params setObject:[Cus360Chat sharedInstance].cusStrUserName forKey:[NSString stringWithFormat:@"queId_%@",parameter]];
            }
        }
        else if ([elementToRender isEqualToString:@"chat_pre_message"]){
            if ([HomerUtils stringIsEmpty:[Cus360Chat sharedInstance].cusStrUserFeedback]) {
                NSString *subString = @"I have an query. Can you help me?";
                [params setObject:subString forKey:[NSString stringWithFormat:@"queId_%@",parameter]];
            } else {
                [params setObject:[Cus360Chat sharedInstance].cusStrUserFeedback forKey:[NSString stringWithFormat:@"queId_%@",parameter]];
            }
        }
    }
    
    [self executeSavePreChat:params];
}
-(void)executeSavePreChat:(NSMutableDictionary*)formData{
    
    NSMutableDictionary *form = [[NSMutableDictionary alloc]init];
    [form setObject:formData forKey:@"form"];
    [form setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"rid"]forKey:@"rid"];
    //[form setObject:@"" forKey:@"jid"];
    NSString *preChatFormId = [[NSUserDefaults standardUserDefaults] objectForKey:@"inapp_prechat_form_id"];
    [form setObject:preChatFormId forKey:@"form_id"];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MMddyyyyHHmmss"];
    NSDate *now = [NSDate date];
    NSString *dateString = [format stringFromDate:now];
    
    [[NSUserDefaults standardUserDefaults] setObject:dateString forKey:@"msgThread"];
    
    [form setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"msgThread"] forKey:@"msgThread"];
    [form setObject:@"inapp" forKey:@"source"];
    
    NSMutableDictionary *finalParam = [[NSMutableDictionary alloc] init];
    //[finalParam setObject:[[Cus360Chat sharedInstance] getAccessTokenChat].cusNsstrAccessToken forKey:@"access_token"];
    [CUSApiHelperChat addCommonParams:finalParam];
    //
    //    [finalParam setObject:form forKey:@"params"];
    /*     {
     "access_token":3e47205aaf6b61fbd9e94bb243830e48,
     params:{"form":{"queId_16765":"sxbdsfrt","queId_16766":"Dsgrr@ddd.fddd","queId_16767":"Flashback","queId_16772":"10608","queId_16773":["10613","10614"]},"rid":"cef04ff02719599cc169e5f0c242b2a0","jid":null,"msgThread":"d69dd7d5e0391aff3c194cbd29aae10e","source":"web_widget"}
     params:{"form":{"queId_16765":"rohit","queId_16772":"10609","queId_16773":["10613","10614"],"queId_16766":"rohit+unique@customer360.co","queId_16767":"testing"},"rid":"cef04ff02719599cc169e5f0c242b2a0","jid":null,"msgThread":"d69dd7d5e0391aff3c194cbd29aae10e","source":"web_widget"}
     access_token:3e47205aaf6b61fbd9e94bb243830e48
     */
    
    NSString *url =[NSString stringWithFormat:@"%@/savePrechat",[CUSApiHelperChat fetchBaseApiUrl]];
    NSError *error= nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:form
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [finalParam setObject:jsonString forKey:@"params"];
    [finalParam setObject:@"inapp" forKey:@"source"];
    
    [HomerUtils executePostForUrl:url withParams:finalParam fromViewController:self withOnSuccessCallBack:@selector(sucess:) andOnFailureCallBack:@selector(failed:)];
}

-(void)successSave:(id)sucess
{
    WaitViewController *wait = [[WaitViewController alloc] initWithNibName:@"WaitViewController" bundle:nil];
    [self presentViewController:wait animated:YES completion:nil];
}

-(void) failed: (id)failed
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Connection Failed " message:[failed localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    NSLog(@"failed");
}
-(void) sucess:(id)success{
    
    if ([CUSApiHelperChat checkIfFetchDataWasSuccess:success]) {
        if ([status isEqualToString:@"online"])
        {
            NSDictionary *responseDict = (NSDictionary*)success;
            NSString *error = [responseDict objectForKey:@"error"];
            if (error) {
                [self BannedUser];
            }else
            {
                NSString *jid = [[responseDict objectForKey:@"response"] objectForKey:@"jid"];
                NSString *prechat_id = [[responseDict objectForKey:@"response"] objectForKey:@"prechat_id"];
                [[NSUserDefaults standardUserDefaults] setObject:prechat_id forKey:@"prechat_id"];
                [[NSUserDefaults standardUserDefaults] setObject:jid forKey:cusConstStrKeyJID];
                [[NSUserDefaults standardUserDefaults]setObject:@"asdasdasd@34" forKey:cusConstStrKeyPassword];
                [self successSave:success];
                
                if ([HomerUtils stringIsEmpty:[[Cus360Chat sharedInstance] getUserEmailId]]) {
                    [[Cus360Chat sharedInstance] setUserEmailId:email.text];
                }
            }
        }
        else{
            self.cusNsdCreateTicketResponseObject=(NSDictionary*)success ;
            
            [self openThankYouPage];
            
            if ([HomerUtils stringIsEmpty:[[Cus360Chat sharedInstance] getUserEmailId]]) {
                [[Cus360Chat sharedInstance] setUserEmailId:email.text];
            }
        }
    }else
    {
        [self showErrorFromResponse:success];
    }
}

-(void)BannedUser{
    
    UIView *thankYou = [[UIView alloc]init];
    [thankYou setFrame:self.PreChatscrollView.frame];
    thankYou.backgroundColor =[UIColor whiteColor];
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(133, 80, 334, 366)];
    contentView.backgroundColor =[UIColor whiteColor];
    [thankYou addSubview:contentView];
    
    NSString * bannedText = @"One of our Agent has added you to a restricted list. As a result, you are banned from starting a chat. If you believe this is wrongly done, please reach out to us at our support email ID";
    
    UITextView *response = [[UITextView alloc] initWithFrame:CGRectMake(38, 10, 262, 30)];
    //    [[response layer] setBorderColor:[[UIColor grayColor] CGColor]];
    //    [[response layer] setBorderWidth:0.5 ];
    //    [[response layer] setCornerRadius:5];
    
    NSMutableAttributedString *attText1 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"User Banned from Chat"] attributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:43.0/255.0 green:96.0/255.0 blue:222.0/255.0 alpha:1.0],  NSFontAttributeName : [UIFont boldSystemFontOfSize:20.0]}];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    [attText1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attText1.length)];
    
    
    response.attributedText = attText1;
    //    response.text = @"User Banned from Chat";
    [contentView addSubview:response];
    
    UILabel *thankYouLable = [[UILabel alloc] initWithFrame:CGRectMake(38, 50, 262, 100)];
    //    thankYouLable.textColor =[UIColor colorWithRed:166.0/255.0 green:166.0/255.0 blue:166.0/255.0 alpha:1.0];
    thankYouLable.textAlignment = NSTextAlignmentCenter;
    [thankYouLable setFont:[UIFont systemFontOfSize:14.0f]];
    thankYouLable.text = bannedText;
    thankYouLable.numberOfLines = 0;
    
    [contentView addSubview:thankYouLable];
    
    UIButton *close = [[UIButton alloc] initWithFrame:CGRectMake(127, 200, 85, 30)];
    close.backgroundColor = [UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1.0];
    [close.layer setCornerRadius:3.0F];
    [close setTitle:@"Close" forState:UIControlStateNormal];
    [close setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [close addTarget:self action:@selector(finishThisPage) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:close];
    [contentView setCenter:thankYou.center];
    [self.view addSubview:thankYou];
    [self.PreChatscrollView removeFromSuperview];
    [self.view bringSubviewToFront:thankYou];
    
    
}
-(void)openThankYouPage
{
    //    [self finishThisPage];
    CUSThankYouViewController * myCustomViewController=[[CUSThankYouViewController alloc] initWithNibName:@"CUSThankYouViewController" bundle:nil];
    myCustomViewController.cusNsmdTicketIdResponseobject = self.cusNsdCreateTicketResponseObject;
    myCustomViewController.online = false;
    [self presentViewController:myCustomViewController animated:YES completion:nil];
}


-(IBAction) submit :(id)sender{
    
    if ([self validateAllElements]) {
        
        [self submitParams];
    }
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    //[self hideKeyBoard];
}
#pragma mark - scrollView delegate

//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//{
//    //[self cancelTouched:nil];
//}
#pragma  mark - Email Validation
-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

#pragma mark - textView Delegate
//-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
//    return YES;
//}
//-(BOOL)textViewShouldEndEditing:(UITextView *)textView{
//    return YES;
//}
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    //    if (textView.superview.frame.origin.y+80>[HomerUtils getScaledSizeBasedOnDevice:250]) {
    //
    //        float yOffset = textView.superview.frame.origin.y-[HomerUtils getScaledSizeBasedOnDevice:100];
    //        [_PreChatscrollView setContentOffset:CGPointMake(0, yOffset) animated:NO];
    //    }
}
-(void)textViewDidEndEditing:(UITextView *)textView{
    
    //self.PreChatscrollView.contentOffset = CGPointMake(0, 0);
}

#pragma mark - TextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // TAGs...
    // 1 -> Name TextField
    if(textField.tag == 1)
    {
        [textField resignFirstResponder];
        return YES;
    }
    
    return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    //    if (textField.superview.frame.origin.y+30>[HomerUtils getScaledSizeBasedOnDevice:250]) {
    //
    //        float yOffset = textField.superview.frame.origin.y-[HomerUtils getScaledSizeBasedOnDevice:100];
    //        [_PreChatscrollView setContentOffset:CGPointMake(0, yOffset) animated:NO];
    //    }
    
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    
    //    if (textField.superview.frame.origin.y+30>[HomerUtils getScaledSizeBasedOnDevice:250]) {
    
    //   float yOffset = textField.superview.frame.origin.y-[HomerUtils getScaledSizeBasedOnDevice:100];
    //        [_PreChatscrollView setContentOffset:CGPointMake(0, yOffset) animated:NO];
    //self.PreChatscrollView.contentOffset = CGPointMake(0, 0);
    //    }
    
    return YES;
    
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSMutableArray *  barItems = [[NSMutableArray alloc] init];
    arrPickerData=[[NSMutableArray alloc]init];
    for (int i=1; i<=arrViews.count; i++)
    {
        NSDictionary *element =[[arrViews objectAtIndex:i-1]objectForKey:@"question_container"] ;
        NSString *isDropDown = [element objectForKey:@"type"];
        if ([isDropDown isEqualToString:@"select"])
        {
            pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            CGRect frame = pickerView.frame;
            frame.size.height-=54;
            [pickerView setFrame:frame];
            
            pickerView.dataSource = self;
            pickerView.delegate = self;
            UIToolbar*  mypickerToolbar;
            UIBarButtonItem *cancelBtn,*doneBtn,*flexSpace;
            
            mypickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 56)];
            mypickerToolbar.barStyle = UIBarStyleDefault;
            [mypickerToolbar sizeToFit];
            
            for (int P = 0; P<_cusChatUITextFieldSelect.count ; P++)
            {
                NSNumber *tagNo =[element objectForKey:@"question_id"];
                int tage = tagNo.integerValue;
                if (textField.tag==tage)
                {
                    cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelTouched:)];
                    [barItems addObject:cancelBtn];
                    flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
                    [barItems addObject:flexSpace];
                    doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(pickerDoneClicked)];
                    [barItems addObject:doneBtn];
                    [mypickerToolbar setItems:barItems animated:YES];
                    [textField setTintColor:[UIColor clearColor]];
                    NSMutableArray *answers = (NSMutableArray*)[element objectForKey:@"answers"];
                    pickerView.hidden=NO;
                    [ pickerView  setShowsSelectionIndicator:YES];
                    textField.inputView =  pickerView;
                    textField.inputAccessoryView = mypickerToolbar;
                    
                    for (int j=0; j<answers.count; j++)
                    {
                        [arrPickerData addObject:[[answers objectAtIndex:j] objectForKey:@"answer"]];
                    }
                    break;
                }
            }
            [pickerView reloadAllComponents];
        }
        else if ([isDropDown isEqualToString:@"date"])
        {
            
            UIDatePicker *datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
            CGRect frame = datePicker.frame;
            frame.size.height-=54;
            [datePicker setFrame:frame];
            datePicker.datePickerMode = UIDatePickerModeDate;
            
            UIToolbar*  mypickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 56)];
            mypickerToolbar.barStyle = UIBarStyleDefault;
            [mypickerToolbar sizeToFit];
            for (int P = 0; P<_cusChatUITextFieldDate.count ; P++)
            {
                NSNumber *tagNo =[element objectForKey:@"question_id"];
                int tage = tagNo.integerValue;
                if (textField.tag==tage)
                {
                    UIBarButtonItem *cancelBtn,*doneBtn,*flexSpace;
                    cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelTouched:)];
                    [barItems addObject:cancelBtn];
                    flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
                    [barItems addObject:flexSpace];
                    doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dateDoneClicked)];
                    [barItems addObject:doneBtn];
                    [mypickerToolbar setItems:barItems animated:YES];
                    [textField setTintColor:[UIColor clearColor]];
                    [textField setInputView:datePicker];
                    [textField setInputAccessoryView:mypickerToolbar];
                }
            }
        }
        else if ([isDropDown isEqualToString:@"time"])
        {
            
            UIDatePicker *datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
            CGRect frame = datePicker.frame;
            frame.size.height-=54;
            [datePicker setFrame:frame];
            datePicker.datePickerMode = UIDatePickerModeTime;
            
            UIToolbar*  mypickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 56)];
            mypickerToolbar.barStyle = UIBarStyleDefault;
            [mypickerToolbar sizeToFit];
            
            for (int P = 0; P<_cusChatUITextFieldTime.count ; P++)
            {
                NSNumber *tagNo =[element objectForKey:@"question_id"];
                int tage = tagNo.integerValue;
                if (textField.tag==tage)
                {
                    UIBarButtonItem *cancelBtn,*doneBtn,*flexSpace;
                    cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:    self action:@selector(cancelTouched:)];
                    [barItems addObject:cancelBtn];
                    flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace     target:self action:nil];
                    [barItems addObject:flexSpace];
                    doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(timeDoneClicked)];
                    [barItems addObject:doneBtn];
                    [mypickerToolbar setItems:barItems animated:YES];
                    [textField setTintColor:[UIColor clearColor]];
                    [textField setInputView:datePicker];
                    [textField setInputAccessoryView:mypickerToolbar];
                }
            }
        }
    }
}
#pragma mark pickerDoneClicked Methods

-(void)pickerDoneClicked
{
    for (int i =0; i<_cusChatUITextFieldSelect.count; i++)
    {
        UITextField * send = [_cusChatUITextFieldSelect objectAtIndex:i];
        if([send isEditing]){
            send.text =[arrPickerData objectAtIndex:[pickerView selectedRowInComponent:0]];
            break;
        }
    }
    [self.view endEditing:YES];
}

- (void)cancelTouched:(id)sender
{
    //    _scrollView.contentSize = CGSizeMake(320, 1500);
    [self.view endEditing:YES];
}
#pragma mark - UIDatePicker
-(void)dateDoneClicked
{
    
    for (int i =0; i<_cusChatUITextFieldDate.count; i++)
    {
        UITextField * send = [_cusChatUITextFieldDate objectAtIndex:i];
        if([send isEditing]){
            UIDatePicker* new =(UIDatePicker*)send.inputView;
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"MMM dd yyyy"];
            send.text = [NSString stringWithFormat:@"%@", [formatter stringFromDate:[new date]]];
            break;
        }
    }
    [self.view endEditing:YES];
    
}
-(void)timeDoneClicked
{
    
    for (int i =0; i<_cusChatUITextFieldTime.count; i++)
    {
        UITextField * send = [_cusChatUITextFieldTime objectAtIndex:i];
        if([send isEditing]){
            UIDatePicker* new =(UIDatePicker*)send.inputView;
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            [formatter setTimeStyle:NSDateFormatterShortStyle];
            send.text = [NSString stringWithFormat:@"%@", [formatter stringFromDate:[new date]]];
            break;
        }
    }
    [self.view endEditing:YES];
    
}


#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [arrPickerData count];
}

#pragma mark - UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *item = [arrPickerData objectAtIndex:row];
    
    return item;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // perform some action
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
