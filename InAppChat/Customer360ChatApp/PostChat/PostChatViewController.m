//
//  PostChatViewController.m
//  InAppChat
//
//  Created by Anveshan Technologies on 20/03/15.
//
//

#import "PostChatViewController.h"
#import "CUSApiHelperChat.h"
#import "Cus360Chat.h"
#import "RadioButton.h"
#import "HomerUtils.h"
#import "ModelAccessTokenChat.h"
#import "WaitViewController.h"
#import "DLStarRatingControl.h"
#import "CUSThankYouViewController.h"

@interface PostChatViewController ()<UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UIScrollViewDelegate,UITextViewDelegate,DLStarRatingDelegate>
{
    RadioButton *RadioButtonNumber;
    NSMutableArray *checkBoxArray;
    RadioButton *smileyButton;
    CGFloat starRating;
    
}

@end



@implementation PostChatViewController

@synthesize CSATdropdown = CSATdropdown;
@synthesize name = name;
@synthesize dict = dict;
@synthesize pickerView = pickerView;
@synthesize feedback = feedback ;
@synthesize arrViews = arrViews;
@synthesize arrPickerData = arrPickerData ;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    screenW = [UIScreen mainScreen].bounds.size.width;
    UITapGestureRecognizer *onViewTapHideKeyBoard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
    [onViewTapHideKeyBoard setCancelsTouchesInView:NO];
    
    _cusCSATUITextField = [[NSMutableArray alloc]init];
    _cusCSATUITextView = [[NSMutableArray alloc]init];
    _cusCSATUITextFieldSelect = [[NSMutableArray alloc] init];
    _cusCSATStarRating= [[NSMutableArray alloc] init];
    _cusCSATSmileyScales= [[NSMutableArray alloc] init];
    [self.view addGestureRecognizer:onViewTapHideKeyBoard];
    [self performSubClassWork];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    //    [self showActivityIndicator];
    
    [self loadNavigationBarItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)finishThisPage{
    
    [self.CSATscrollView removeFromSuperview];
    [super finishThisPage];
}


-(void)loadNavigationBarItem{
    
    UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@"Please Rate Us"];
    
    UIBarButtonItem *leftItem = [self getNavigationBackButtonWithTarget:self action:@selector(finishThisPage)];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStylePlain target:self action:@selector(submitForm)];
    
    [self loadNavigationBarWithItem:item leftItem:leftItem rightItem:rightItem];
}



#pragma mark - *** Render View ***

- (UIView*)makeDefaultBox:(NSDictionary*)element iconImage:(NSString*)icon
{
    
    NSString *boxType = [element objectForKey:@"type"];
    NSLog(@"boxType = %@",boxType);
    int boxHeight = 64;
    
    //------------------------------
    //Box's main view...
    UIView *boxView = [[UIView alloc] initWithFrame:CGRectMake(self.CSATscrollView.frame.origin.x, YOriginPoint, self.CSATscrollView.frame.size.width, boxHeight)];
    YOriginPoint += boxHeight;
    [self.CSATscrollView addSubview:boxView];
    
    
    //------------------------------
    //Box's Label...
    UILabel *boxLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 16, self.CSATscrollView.frame.size.width, 15)];
    [boxLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:14]];
    boxLabel.textColor = [UIColor colorWithRed:136.0/255.0 green:136.0/255.0 blue:136.0/255.0 alpha:1.0f];
    
    if ([[element objectForKey:@"required"]isEqualToString:@""])
    {
        boxLabel.text = [element objectForKey:@"question"];
    }else
    {
        boxLabel.text = [NSString stringWithFormat:@"%@ *",[element objectForKey:@"question"]];
        
        NSMutableAttributedString *attrib = [[NSMutableAttributedString alloc] initWithString:boxLabel.text];
        [attrib addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(boxLabel.text.length-1, 1)];
        [boxLabel setAttributedText:attrib];
    }
    
    [boxView addSubview:boxLabel];
    
    
    //------------------------------
    //Box's Text Field OR UILabel...
    
    if([boxType isEqualToString:@"textInput"] || [boxType isEqualToString:@"customer_feedback"])
    {
        UITextField *boxDescription  = [[UITextField alloc] initWithFrame:CGRectMake(16, 16, screenW-32 , 40)];
        //    boxDescription.text = @"Prasad";
        [boxDescription setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
        boxDescription.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
        boxDescription.delegate=self;
        //    boxDescription.backgroundColor = [UIColor cyanColor];
        NSNumber *tagNo =[element objectForKey:@"question_id"];
        [boxDescription setTag:tagNo.integerValue];
        boxDescription.placeholder = [element objectForKey:@"e_help_text"];
        [boxView addSubview:boxDescription];
    }else if([boxType isEqualToString:@"checkbox"] || [boxType isEqualToString:@"radio"] || [boxType isEqualToString:@"select"])
    {
        UILabel *boxDescription = [[UILabel alloc] initWithFrame:CGRectMake(16, 32, screenW-32 , 24)];
//        boxDescription.text = @"this is label description";
        [boxDescription setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
        boxDescription.textAlignment = NSTextAlignmentLeft;
        [boxDescription setTag:10];
        [boxView addSubview:boxDescription];
    }
    
    
    
    //------------------------------
    //Box's Image...
    if(icon)
    {
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:icon]];
        CGRect imgFrame = imgView.frame;
        imgFrame.origin.x = screenW - 32 - imgFrame.size.width;
        imgFrame.origin.y = 16;
        [imgView setFrame:imgFrame];
        [boxView addSubview:imgView];
    }
    
    //------------------------------
    //Box's end line...
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 63, screenW, 1)];
    line.backgroundColor = [UIColor colorWithRed:221.0/255.0f green:221.0/255.0f blue:221.0/255.0f alpha:1.0f];
    [boxView addSubview:line];
    
    return boxView;
}


- (void)makeTextInputBox:(NSDictionary*)element
{
    [self makeDefaultBox:element iconImage:nil];
}

- (void)makeFeedbackBox:(NSDictionary*)element
{
    [self makeDefaultBox:element iconImage:nil];
}

- (void)makeCheckBox:(NSDictionary*)element
{
    [self makeDefaultBox:element iconImage:@"select"];
}

- (void)makeRadioBox:(NSDictionary*)element
{
    [self makeDefaultBox:element iconImage:@"select"];
}

- (void)makeDropdownBox:(NSDictionary*)element
{
    [self makeDefaultBox:element iconImage:@"select"];
}

- (void)makeStarBox:(NSDictionary*)element
{
    UIView *viewBox = [self makeDefaultBox:element iconImage:nil];
    
    //--------
    // add stars..
    DLStarRatingControl *customNumberOfStars = [[DLStarRatingControl alloc] initWithFrame:viewBox.bounds andStars:5 atHeight:24];
    customNumberOfStars.delegate = self;
    NSNumber *tagNo =[element objectForKey:@"question_id"];
    int tage = tagNo.integerValue;
    
    customNumberOfStars.tag = tage;
    //    customNumberOfStars.backgroundColor = [UIColor groupTableViewBackgroundColor];
    customNumberOfStars.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [_cusCSATStarRating addObject:customNumberOfStars];
    [viewBox addSubview:customNumberOfStars];
}
-(void)newRating:(DLStarRatingControl *)control rating:(float)rating
{
    //    self.stars.text = [NSString stringWithFormat:@"%0.1f star rating",rating];
    starRating = rating;
}


- (void)makeSmileyBox:(NSDictionary*)element
{
    UIView *viewBox = [self makeDefaultBox:element iconImage:nil];
    
    //-----------------------------
    // add Smiley functionality...
    NSMutableArray* button2 = [NSMutableArray arrayWithCapacity:[[element objectForKey:@"answers"] count]];
    CGRect btnRect =CGRectMake(16, 32, 30, 30);
    for (int option = 0; option<5; option++)
    {
        RadioButton* btn = [[RadioButton alloc] initWithFrame:btnRect];
        
        [btn addTarget:self action:@selector(onSmileyClicked:) forControlEvents:UIControlEventValueChanged];
        
        btnRect.origin.x += 48;
        //        [btn setTitle:optionTitle forState:UIControlStateNormal];
        //        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        //        btn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        
        switch (option) {
            case 0:
                
                [btn setBackgroundImage:[UIImage imageNamed:@"smiley-excellent-outline"] forState:UIControlStateNormal];
                [btn setBackgroundImage:[UIImage imageNamed:@"smiley-excellent"] forState:UIControlStateSelected];
                break;
            case 1:
                [btn setBackgroundImage:[UIImage imageNamed:@"smiley-good-outline"] forState:UIControlStateNormal];
                [btn setBackgroundImage:[UIImage imageNamed:@"smiley-good"] forState:UIControlStateSelected];
                break;
            case 2:
                [btn setBackgroundImage:[UIImage imageNamed:@"smiley-average-outline"] forState:UIControlStateNormal];
                [btn setBackgroundImage:[UIImage imageNamed:@"smiley-average"] forState:UIControlStateSelected];
                break;
            case 3:
                [btn setBackgroundImage:[UIImage imageNamed:@"smiley-sad-outline"] forState:UIControlStateNormal];
                [btn setBackgroundImage:[UIImage imageNamed:@"smiley-sad"] forState:UIControlStateSelected];
                break;
            case 4:
                [btn setBackgroundImage:[UIImage imageNamed:@"smiley-worst-outline"] forState:UIControlStateNormal];
                [btn setBackgroundImage:[UIImage imageNamed:@"smiley-worst"] forState:UIControlStateSelected];
                break;
            default:
                break;
        }
        
        //        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        //        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 0);
        
        [viewBox addSubview:btn];
        [button2 addObject:btn];
    }
    NSNumber *tagNo =[element objectForKey:@"question_id"];
    int tage = tagNo.integerValue;
    [button2[0] setTag:tage];
    [button2[0] setGroupButtons:button2];
    [_cusCSATSmileyScales addObject:button2];
}

-(void)performSubClassWork
{
    
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
    // Do something...
    
    //    _scrollView = [[UIScrollView alloc]init];
    //    _CSATscrollView.delegate=self;
    
    [_CSATscrollView setFrame:[[UIScreen mainScreen] bounds] ];
    //    _scrollView.backgroundColor = [UIColor redColor];
    //    [self.view addSubview:self.scrollView];
    
    CSATdropdown= [[UITextField alloc] init];
    ModelAccessTokenChat *chatToken = [[Cus360Chat sharedInstance] getAccessTokenChat];
    
    NSString *url= [NSString stringWithFormat:@"%@/getPostchatForm?access_token=%@",[CUSApiHelperChat fetchBaseApiUrl],chatToken.cusNsstrAccessToken];
    //3e47205aaf6b61fbd9e94bb243830e48
    NSURL *getresponse = [NSURL URLWithString:url];
    
    //    NSURL *getresponse = [NSURL URLWithString:@"http://app.customer360.co/widget/getPrechatForm?access_token=8c484ca3a3a0ebf2b2b1c5d1b70721f4"];
    //    NSURLRequest *preChatRequest = [[NSURLRequest alloc] initWithURL:getresponse];
    //    NSURLConnection *Connect = [[NSURLConnection alloc] initWithRequest:preChatRequest delegate:self startImmediately:NO];
    
    //    data = [[NSData alloc] initWithContentsOfURL:getresponse];
    
    NSError *error = nil;
    
    data = [NSData dataWithContentsOfURL:getresponse options:NSDataReadingUncached error:&error];
    dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    //        NSLog(@"dict is : %@",dict);
    
    if (dict!=nil) {
        arrViews =[[dict objectForKey:@"response"]objectForKey:@"form"];
        
        //YOriginPoint = 64;
        for (int i=1; i<=arrViews.count; i++) {
            
            NSDictionary *element =[[arrViews objectAtIndex:i-1]objectForKey:@"question_container"] ;
            NSString *elementToRender = [[[arrViews objectAtIndex:i-1]objectForKey:@"question_container"] objectForKey:@"type"];
            if ([elementToRender isEqualToString:@"radio"]) {
                
                [self makeRadioBox:element];
            }
            else if ([elementToRender isEqualToString:@"checkbox"]){
                
                [self makeCheckBox:element];
            }
            else if ([elementToRender isEqualToString:@"textArea"]){
                NSLog(@"->textArea");
                //[self makeTextArea:element];
            }
            else if ([elementToRender isEqualToString:@"textInput"]){
                NSLog(@"->textInput");
                [self makeTextInputBox:element];
            }
            
            else if ([elementToRender isEqualToString:@"select"]){
                
                [self makeDropdownBox:element];
            }
            
            else if ([elementToRender isEqualToString:@"customer_feedback"]){
                NSLog(@"->customer_feedback");
                [self makeFeedbackBox:element];
            }
            else if ([elementToRender isEqualToString:@"five_star_rating"]){
                [self makeStarBox:element];
            }
            else if ([elementToRender isEqualToString:@"smiley"])
            {
                [self makeSmileyBox:element];
            }
        }
//        YOriginPoint+=60;
//        UIButton *submit = [[UIButton alloc] init];
//        [submit setTitle:@"SUBMIT" forState:UIControlStateNormal];
//        [submit setFrame:CGRectMake(0, 0, 180, 40)];
//        [submit setCenter:CGPointMake(_CSATscrollView.frame.size.width/2, YOriginPoint-32)];
//        [submit setBackgroundColor:[UIColor colorWithRed:89.0/255.0 green:89.0/255.0 blue:89.0/255.0 alpha:1.0]];
//        [submit.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
//        [submit setTitleEdgeInsets:UIEdgeInsetsMake(16, 24, 16, 24)];
//        [submit.layer setCornerRadius:3.0f];
//        [_CSATscrollView addSubview:submit];
//        [submit addTarget:self action:@selector(submit:) forControlEvents:UIControlEventTouchUpInside];
        
        
        //**** Do not disturb this statement position or scrollview won't work. ***///
        //**** YOriginPoint increament after each element is rendered on screen. **///
        _CSATscrollView.contentSize = CGSizeMake(self.CSATscrollView.frame.size.width, YOriginPoint+10);
        // Do any additional setup after loading the view from its nib.
        [self hideActivityIndicator];
        
    }
}


/*
#pragma mark- Render View
-(void)makeTextInput:(NSDictionary*)element{
    
    //    NSLog(@"%@", element);
    UIView *new = [[UIView alloc]initWithFrame:CGRectMake(self.CSATscrollView.frame.origin.x, YOriginPoint, self.CSATscrollView.frame.size.width, 64)];
    YOriginPoint+=64 ;//16+32+8
    [new setBackgroundColor:[UIColor lightTextColor]];
    
    [self.CSATscrollView addSubview:new];
    
    UITextField *cusTextInput  = [[UITextField alloc] init];
    //    cusTextInput.text = @"Prasad";
    [cusTextInput setFrame:CGRectMake(16, 16, screenW-32, 24)];
    cusTextInput.delegate=self;
    NSNumber *tagNo =[element objectForKey:@"question_id"];
    int tage = tagNo.integerValue;
    [cusTextInput setTag:tage];
    NSString *placeholder =[element objectForKey:@"e_help_text"];
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
    [_cusCSATUITextField addObject:cusTextInput];
    [new addSubview:cusTextInput];
    
}
-(void)makeTextArea:(NSDictionary*)element
{
    UIView *new = [[UIView alloc]initWithFrame:CGRectMake(self.CSATscrollView.frame.origin.x, YOriginPoint, self.CSATscrollView.frame.size.width, 120)];
    //    YOriginPoint+=120;
    //    [new setBackgroundColor:[UIColor lightTextColor]];
    [self.CSATscrollView addSubview:new];
    
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
    [_cusCSATUITextView addObject:custextArea];
    //    NSLog(@"makeQuestionBox");
    
}


#pragma mark - RadioButtons
-(void)makeRadioButtons:(NSDictionary *)element{
    
    UIView *new = [[UIView alloc]initWithFrame:CGRectMake(self.CSATscrollView.frame.origin.x, YOriginPoint, self.CSATscrollView.frame.size.width, 160)];
    
    YOriginPoint+=160;
    
    [new setBackgroundColor:[UIColor lightTextColor]];
    [self.CSATscrollView addSubview:new];
    
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
    }
    
    [new addSubview:nameLable];
    
    
    NSMutableArray* buttons = [NSMutableArray arrayWithCapacity:[[element objectForKey:@"answers"] count]];
    
    NSMutableArray * buttonTitles = [[NSMutableArray alloc]initWithArray:[element objectForKey:@"answers"]];
    
    CGRect btnRect =CGRectMake(20,nameLable.frame.origin.y+nameLable.frame.size.height+8, 200, 30);
    for (int option = 0; option<buttonTitles.count; option++)
    {
        NSString* optionTitle = [[buttonTitles objectAtIndex:option]objectForKey:@"answer"];
        
        RadioButton* btn = [[RadioButton alloc] initWithFrame:btnRect];
        
        [btn addTarget:self action:@selector(onRadioButtonValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        
        [btn setTitle:optionTitle forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [btn setImage:[UIImage imageNamed:@"radio-default"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"radio-selected"] forState:UIControlStateSelected];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 0);
        [new addSubview:btn];
        btnRect.origin.y += 40;
        
        if (isgreater(btnRect.origin.y + btnRect.size.height, new.frame.size.height))
        {
            [new setFrame:CGRectMake(new.frame.origin.x, new.frame.origin.y, new.frame.size.width, new.frame.size.height+btnRect.size.height)];
            YOriginPoint+=btnRect.size.height;
        }
        
        [buttons addObject:btn];
    }
    [buttons[0] setGroupButtons:buttons];
    [new addSubview:nameLable];
    
    //    NSLog(@"makeRadioButtons");
    
}
-(void)onRadioButtonValueChanged:(RadioButton*)button
{
    
    RadioButtonNumber = button.selectedButton;
}
#pragma mark -CheckBoxes
-(void)makeChekBoxes:(NSDictionary *)element{
    
    UIView *new = [[UIView alloc]initWithFrame:CGRectMake(self.CSATscrollView.frame.origin.x, YOriginPoint, self.CSATscrollView.frame.size.width, 160)];
    YOriginPoint+=160;
    [new setBackgroundColor:[UIColor lightTextColor]];
    
    [self.CSATscrollView addSubview:new];
    UILabel *nameLable = [[UILabel alloc] init];
    [nameLable setFrame:CGRectMake(16, 16, screenW-32, 24)];
    [nameLable setFont:[UIFont boldSystemFontOfSize:17.0f]];
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
        [checkbox setTitleColor:[UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        checkbox.titleLabel.font = [UIFont systemFontOfSize:15];
        
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
        checkbox.titleLabel.textColor = [UIColor colorWithRed:85/255 green:85/255 blue:85/255 alpha:1.0];
        checkbox.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        checkbox.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 0);
        [checkbox addTarget:self action:@selector(checkboxSelected:) forControlEvents:UIControlEventTouchUpInside];
        [new addSubview:checkbox];
        [buttons addObject:checkbox];
        btnRect.origin.y += 40;
        
        if (isgreater(btnRect.origin.y + btnRect.size.height, new.frame.size.height))
        {
            [new setFrame:CGRectMake(new.frame.origin.x, new.frame.origin.y, new.frame.size.width, new.frame.size.height+btnRect.size.height)];
            YOriginPoint+=btnRect.size.height;
        }
        
    }
    
    
    
    //    NSLog(@"makeChekBoxes");
    
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
#pragma mark - text area

-(void)makeQuestionBox:(NSDictionary *)element{
    UIView *new = [[UIView alloc]initWithFrame:CGRectMake(self.CSATscrollView.frame.origin.x, YOriginPoint, self.CSATscrollView.frame.size.width, 120)];
    
    [new setBackgroundColor:[UIColor lightTextColor]];
    
    [self.CSATscrollView addSubview:new];
    
    UILabel *nameLable = [[UILabel alloc] init];
    [nameLable setFrame:CGRectMake(16, 16, screenW-32, 24)];
    [nameLable setFont:[UIFont boldSystemFontOfSize:17.0f]];
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
    }
    
    [new addSubview:nameLable];
    
    feedback= [[UITextView alloc] init];
    [feedback setFrame:CGRectMake(16, nameLable.frame.origin.y+nameLable.frame.size.height+8, screenW-32, 72)];
    //8+24+8+72+8
    
    //    question.text = @"Write your feedback";
    //    question.textColor = [UIColor colorWithRed:196.0/255.0 green:196.0/255.0 blue:196.0/255.0 alpha:1.0];
    feedback.delegate = self;
    feedback.font = [UIFont systemFontOfSize:15.0f];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, feedback.frame.origin.y+feedback.frame.size.height+8 ,screenW-32 , 1)];
    line.backgroundColor = [UIColor colorWithRed:221.0/255.0f green:221.0/255.0f blue:221.0/255.0f alpha:1.0f];
    
    [new addSubview:line];
    [new addSubview:feedback];
    YOriginPoint+=line.frame.origin.y+10;
    [new setFrame:CGRectMake(new.frame.origin.x, new.frame.origin.y,  screenW, line.frame.origin.y+11)];
    
    //    [new addSubview:error];
    
    //
    //    NSLog(@"makeQuestionBox");
    
}

-(void)makeDropDownBox:(NSDictionary *)element{
    
    //    NSLog(@"%@", element);
    
    UIView *new = [[UIView alloc]initWithFrame:CGRectMake(self.CSATscrollView.frame.origin.x, YOriginPoint, self.CSATscrollView.frame.size.width, 64)];
    //    YOriginPoint+=64;
    [new setBackgroundColor:[UIColor lightTextColor]];
    
    [self.CSATscrollView addSubview:new];
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
    [_cusCSATUITextFieldSelect addObject:dropdown];
    
    UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(screenW-48, CGRectGetMinY(dropdown.frame), 12,12 )];
    arrow.image = [UIImage imageNamed:@"arrow"];
    [new addSubview:arrow];
    YOriginPoint+=line.frame.origin.y+10;
    [new setFrame:CGRectMake(new.frame.origin.x, new.frame.origin.y,  screenW, line.frame.origin.y+11)];
    //    [new addSubview:error];
    //    NSLog(@"makeDropDownBox");
    
}

#pragma mark - implementation DLStarRatingControl

-(void)makeStarView:(NSDictionary*)element {
    
    UIView *new = [[UIView alloc]initWithFrame:CGRectMake(self.CSATscrollView.frame.origin.x, YOriginPoint, self.CSATscrollView.frame.size.width, 88)];
    YOriginPoint+=88;
    [new setBackgroundColor:[UIColor lightTextColor]];
    [self.CSATscrollView addSubview:new];
    UILabel *nameLable = [[UILabel alloc] init];
    [nameLable setFrame:CGRectMake(16, 16, screenW-32, 24)];
    [nameLable setFont:[UIFont boldSystemFontOfSize:17.0f]];
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
    }
    [new addSubview:nameLable];
    DLStarRatingControl *customNumberOfStars = [[DLStarRatingControl alloc] initWithFrame:new.bounds andStars:5 atHeight:(nameLable.frame.origin.y+nameLable.frame.size.height+4)];
    customNumberOfStars.delegate = self;
    NSNumber *tagNo =[element objectForKey:@"question_id"];
    int tage = tagNo.integerValue;
    
    customNumberOfStars.tag = tage;
    //    customNumberOfStars.backgroundColor = [UIColor groupTableViewBackgroundColor];
    customNumberOfStars.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [_cusCSATStarRating addObject:customNumberOfStars];
    [new addSubview:customNumberOfStars];
}



*/

#pragma mark - Smiely response
-(void)makeSmiley:(NSDictionary *)element{
    UIView *new = [[UIView alloc]initWithFrame:CGRectMake(self.CSATscrollView.frame.origin.x, YOriginPoint, self.CSATscrollView.frame.size.width, 112)];
    
    YOriginPoint+=112;
    
    [new setBackgroundColor:[UIColor lightTextColor]];
    [self.CSATscrollView addSubview:new];
    
    UILabel *nameLable = [[UILabel alloc] init];
    [nameLable setFrame:CGRectMake(16, 16, screenW-32, 24)];
    [nameLable setFont:[UIFont boldSystemFontOfSize:17.0f]];
    nameLable.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0f];
    
    if ([[element objectForKey:@"required"]isEqualToString:@""]) {
        nameLable.text = [element objectForKey:@"question"];
    }
    else
    {
        nameLable.text = [NSString stringWithFormat:@"%@ *",[element objectForKey:@"question"]];
    }
    
    CGRect size = [nameLable.text boundingRectWithSize:CGSizeMake(screenW-32, CGFLOAT_MAX) options:(NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:17.0]} context:nil];
    nameLable.frame =CGRectMake(16, 8, size.size.width, size.size.height);
    if (size.size.height>24)
    {
        nameLable.frame =CGRectMake(16, 8, size.size.width, size.size.height);
        [nameLable setNumberOfLines:0];
    }
    
    [new addSubview:nameLable];
    NSMutableArray* button2 = [NSMutableArray arrayWithCapacity:[[element objectForKey:@"answers"] count]];
    
    //NSMutableArray * buttonTitles = [[NSMutableArray alloc] initWithArray:[element objectForKey:@"answers"]];
    
    CGRect btnRect =CGRectMake(16, nameLable.frame.origin.y+nameLable.frame.size.height+8, 30, 30);
    for (int option = 0; option<5; option++)
    {
        RadioButton* btn = [[RadioButton alloc] initWithFrame:btnRect];
        
        [btn addTarget:self action:@selector(onSmileyClicked:) forControlEvents:UIControlEventValueChanged];
        
        btnRect.origin.x += 46;
        //        [btn setTitle:optionTitle forState:UIControlStateNormal];
        //        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        //        btn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        
        switch (option) {
            case 0:
                
                [btn setBackgroundImage:[UIImage imageNamed:@"excellent"] forState:UIControlStateNormal];
                [btn setBackgroundImage:[UIImage imageNamed:@"excellent-active"] forState:UIControlStateSelected];
                break;
            case 1:
                [btn setBackgroundImage:[UIImage imageNamed:@"good"] forState:UIControlStateNormal];
                [btn setBackgroundImage:[UIImage imageNamed:@"good-active"]
                               forState:UIControlStateSelected];
                break;
            case 2:
                [btn setBackgroundImage:[UIImage imageNamed:@"average"] forState:UIControlStateNormal];
                [btn setBackgroundImage:[UIImage imageNamed:@"average-active"] forState:UIControlStateSelected];
                break;
            case 3:
                [btn setBackgroundImage:[UIImage imageNamed:@"bad"]
                               forState:UIControlStateNormal];
                [btn setBackgroundImage:[UIImage imageNamed:@"bad-active"]
                               forState:UIControlStateSelected];
                break;
            case 4:
                [btn setBackgroundImage:[UIImage imageNamed:@"worst"] forState:UIControlStateNormal];
                [btn setBackgroundImage:[UIImage imageNamed:@"worst-active"] forState:UIControlStateSelected];
                break;
            default:
                break;
        }
        
        //        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        //        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 0);
        
        [new addSubview:btn];
        [button2 addObject:btn];
    }
    NSNumber *tagNo =[element objectForKey:@"question_id"];
    int tage = tagNo.integerValue;
    [button2[0] setTag:tage];
    [button2[0] setGroupButtons:button2];
    [_cusCSATSmileyScales addObject:button2];
    //    NSLog(@"makeRadioButtons");
}


-(void)onSmileyClicked :(RadioButton*)button {
    
    smileyButton = button.selectedButton;
}


#pragma mark - sumbit process
-(BOOL)validateAllElements{
    
    UIAlertView *alert;
    for (int i=1; i<=arrViews.count; i++)
    {
        NSDictionary *elements =[[arrViews objectAtIndex:i-1]objectForKey:@"question_container"] ;
        NSString *elementToCheck = [elements objectForKey:@"type"];
        NSString *parameter = [elements objectForKey:@"question_id"];
        
        if (![[elements objectForKey:@"required"]isEqualToString:@""])
        {
            if ([elementToCheck isEqualToString:@"radio"])
            {
                if (RadioButtonNumber == nil) {
                    alert = [[UIAlertView alloc] initWithTitle:[elements objectForKey:@"question"] message:@"Please select an appropriate option" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    return NO;
                }
            }
            else if ([elementToCheck isEqualToString:@"checkbox"]){
                
                if (checkBoxArray.count == 0)
                {
                    alert = [[UIAlertView alloc] initWithTitle:[elements objectForKey:@"question"] message:@"Please select an appropriate option" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    return NO;
                }
            }
            
            else if ([elementToCheck isEqualToString:@"textInput"])
            {
                for (int P =0; P<_cusCSATUITextField.count; P++)
                {
                    int tagNo = [[_cusCSATUITextField objectAtIndex:P] tag];
                    NSString *tagString= [NSString stringWithFormat:@"%d",tagNo];
                    if ([parameter isEqualToString:tagString])
                    {
                        UITextField *textField = (UITextField*)[_cusCSATUITextField objectAtIndex:P];
                        if ([textField.text isEqualToString:@""]) {
                            alert = [[UIAlertView alloc] initWithTitle: [elements objectForKey:@"question"] message:@"Please enter appropriate response" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                            [alert show];
                            return NO;
                        }
                        break;
                    }
                }
            }
            else if ([elementToCheck isEqualToString:@"textArea"])
            {
                for (int P =0; P<_cusCSATUITextView.count; P++)
                {
                    int tagNo = [[_cusCSATUITextView objectAtIndex:P] tag];
                    NSString *tagString= [NSString stringWithFormat:@"%d",tagNo];
                    if ([parameter isEqualToString:tagString])
                    {
                        UITextView *textView = (UITextView*)[_cusCSATUITextView objectAtIndex:P];
                        if ([textView.text isEqualToString:@""]) {
                            alert = [[UIAlertView alloc] initWithTitle: [elements objectForKey:@"question"] message:@"Please enter appropriate response" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                            [alert show];
                            return NO;
                        }
                        break;
                    }
                }
            }
            else if ([elementToCheck isEqualToString:@"select"]){
                for (int P =0; P<_cusCSATUITextFieldSelect.count; P++)
                {
                    int tagNo = [[_cusCSATUITextFieldSelect objectAtIndex:P] tag];
                    NSString *tagString= [NSString stringWithFormat:@"%d",tagNo];
                    if ([parameter isEqualToString:tagString])
                    {
                        UITextField *textView = (UITextField*)[_cusCSATUITextFieldSelect objectAtIndex:P];
                        if ([textView.text isEqualToString:@""]) {
                            alert = [[UIAlertView alloc] initWithTitle: [elements objectForKey:@"question"] message:@"Please enter appropriate response" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                            [alert show];
                            return NO;
                        }
                        break;
                    }
                }
            }
            else if ([elementToCheck isEqualToString:@"customer_feedback"]){
                
                if ([HomerUtils stringIsEmpty:feedback.text])
                {
                    alert = [[UIAlertView alloc] initWithTitle:[elements objectForKey:@"question"] message:@"Please Let us know your Comments/ Feedback/ Suggestions" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    return NO;
                    
                }
            }
            else if ([elementToCheck isEqualToString:@"five_star_rating"]){
                
                for (int P =0; P<_cusCSATStarRating.count; P++)
                {
                    int tagNo = [[_cusCSATStarRating objectAtIndex:P] tag];
                    NSString *tagString= [NSString stringWithFormat:@"%d",tagNo];
                    if ([parameter isEqualToString:tagString])
                    {
                        DLStarRatingControl *starView = (DLStarRatingControl*)[_cusCSATStarRating objectAtIndex:P];
                        if (starView.rating == 0.0) {
                            
                            alert = [[UIAlertView alloc] initWithTitle:[elements objectForKey:@"question"] message:@"Please rate the service with some stars" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                            [alert show];
                            return NO;
                        }
                    }
                }
            }/*
              else if ([elementToCheck isEqualToString:@"smiley"])
              {
              for (int P =0; P<_cusCSATSmileyScales.count; P++)
              {
              int tagNo = [[[_cusCSATSmileyScales objectAtIndex:P]objectAtIndex:0] tag];
              NSString *tagString= [NSString stringWithFormat:@"%d",tagNo];
              NSMutableArray *smileyView = (NSMutableArray*)[_cusCSATSmileyScales objectAtIndex:P];
              if ([parameter isEqualToString:tagString])
              {
              RadioButton *button= [smileyView objectAtIndex:P];
              if (![button selectedButton]) {
              //
              //                        }[button selectedButton];
              //
              //                    if (smileyButton == nil) {
              //
              
              alert = [[UIAlertView alloc] initWithTitle:[elements objectForKey:@"question"] message:@"Please rate the service with some smile" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
              [alert show];
              return NO;
              
              }
              }
              }
              }*/
        }
    }
    return YES;
    
}

-(void)submitParams{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    for (int i=1; i<=arrViews.count; i++) {
        
        NSDictionary *element =[[arrViews objectAtIndex:i-1]objectForKey:@"question_container"] ;
        NSString *parameter = [element objectForKey:@"question_id"];
        
        NSString *elementToRender = [element objectForKey:@"type"];
        if ([elementToRender isEqualToString:@"radio"])
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
                    [params setObject:[[answers objectAtIndex:i] objectForKey:@"answer_id"] forKey:[NSString stringWithFormat:@"queId_%@",parameter]];
                    break;
                }
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
        else if ([elementToRender isEqualToString:@"textArea"])
        {
            for (int P =0; P<_cusCSATUITextView.count; P++)
            {
                int tagNo = [[_cusCSATUITextView objectAtIndex:P] tag];
                NSString *tagString= [NSString stringWithFormat:@"%d",tagNo];
                if ([parameter isEqualToString:tagString])
                {
                    UITextView *textView = (UITextView*)[_cusCSATUITextField objectAtIndex:P];
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
            for (int P =0; P<_cusCSATUITextField.count; P++)
            {
                int tagNo = [[_cusCSATUITextField objectAtIndex:P] tag];
                NSString *tagString= [NSString stringWithFormat:@"%d",tagNo];
                if ([parameter isEqualToString:tagString])
                {
                    UITextField *textField = (UITextField*)[_cusCSATUITextField objectAtIndex:P];
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
        else if ([elementToRender isEqualToString:@"select"])
        {
            for (int P =0; P<_cusCSATUITextFieldSelect.count; P++)
            {
                int tagNo = [[_cusCSATUITextFieldSelect objectAtIndex:P] tag];
                NSString *tagString= [NSString stringWithFormat:@"%d",tagNo];
                if ([parameter isEqualToString:tagString])
                {
                    UITextField *textField = (UITextField*)[_cusCSATUITextFieldSelect objectAtIndex:P];
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
                        NSLog(@"Dropdown text = %@", textField.text);
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
        
        else if ([elementToRender isEqualToString:@"customer_feedback"]){
            if ([feedback.text isEqualToString:@""])
            {
                [params setObject:@"" forKey:[NSString stringWithFormat:@"queId_%@",parameter]];
            }
            else{
                [params setObject:feedback.text forKey:[NSString stringWithFormat:@"queId_%@",parameter]];
            }
        }
        else if ([elementToRender isEqualToString:@"five_star_rating"]){
            for (int P =0; P<_cusCSATStarRating.count; P++)
            {
                int tagNo = [[_cusCSATStarRating objectAtIndex:P] tag];
                NSString *tagString= [NSString stringWithFormat:@"%d",tagNo];
                if ([parameter isEqualToString:tagString])
                {
                    DLStarRatingControl *starView = (DLStarRatingControl*)[_cusCSATStarRating objectAtIndex:P];
                    if (starView.rating == 0.0) {
                        [params setObject:@"" forKey:[NSString stringWithFormat:@"queId_%@",parameter]];
                    }
                    else{
                        [params setObject:[NSNumber numberWithFloat:starView.rating] forKey:[NSString stringWithFormat:@"queId_%@",parameter]];
                    }
                }
            }
        }
        else if ([elementToRender isEqualToString:@"smiley"])
        {
            NSMutableArray *answers = (NSMutableArray*)[element objectForKey:@"answers"];
            NSMutableArray *radButtons = [[NSMutableArray alloc]init];
            
            for (int j=0; j<answers.count; j++)
            {
                [radButtons addObject:[[answers objectAtIndex:j] objectForKey:@"answer"]];
            }
            //            NSString* optionTitle = ;// .titleLabel.text;
            NSUInteger i =[smileyButton.groupButtons indexOfObjectIdenticalTo:smileyButton];
            /*for (i = 0; i<radButtons.count; i++) {
             if ([optionTitle isEqualToString:[radButtons objectAtIndex:i]]) {
             break;
             }
             }*/
            [params setObject:[NSNumber numberWithInteger:i] forKey:[NSString stringWithFormat:@"queId_%@",parameter]];
        }
        
    }
    
    NSMutableDictionary *form = [[NSMutableDictionary alloc]init];
    [form setObject:params forKey:@"form"];
    
    [form setObject:@"0" forKey:@"domain_id"];
    [form setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"prechat_id"] forKey:@"prechat_id"];
    [form setObject:@"inapp" forKey:@"source"];
    
    
    NSMutableDictionary *finalParam = [[NSMutableDictionary alloc] init];
    
    //
    [finalParam setObject:[[Cus360Chat sharedInstance] getAccessTokenChat].cusNsstrAccessToken forKey:@"access_token"];
    //
    //    [finalParam setObject:form forKey:@"params"];
    /*
     
     {
     "access_token":3e47205aaf6b61fbd9e94bb243830e48,
     params:{"form":{"queId_16765":"sxbdsfrt","queId_16766":"Dsgrr@ddd.fddd","queId_16767":"Flashback","queId_16772":"10608","queId_16773":["10613","10614"]},"rid":"cef04ff02719599cc169e5f0c242b2a0","jid":null,"msgThread":"d69dd7d5e0391aff3c194cbd29aae10e","source":"web_widget"}
     params:{"form":{"queId_16765":"rohit","queId_16772":"10609","queId_16773":["10613","10614"],"queId_16766":"rohit+unique@customer360.co","queId_16767":"testing"},"rid":"cef04ff02719599cc169e5f0c242b2a0","jid":null,"msgThread":"d69dd7d5e0391aff3c194cbd29aae10e","source":"web_widget"}
     access_token:3e47205aaf6b61fbd9e94bb243830e48
     */
    
    NSString *url =[NSString stringWithFormat:@"%@/savePostChat",[CUSApiHelperChat fetchBaseApiUrl]];
    NSError *error= nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:form
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [finalParam setObject:jsonString forKey:@"params"];
    
    [HomerUtils executePostForUrl:url withParams:finalParam fromViewController:self withOnSuccessCallBack:@selector(sucess:) andOnFailureCallBack:@selector(failed:)];
    
    //http://c360dev.in/c360qa/widget/savePostChat
    
}

-(void) sucess:(id)success{
    
    _cusNsdCreateTicketResponseObject =(NSDictionary*) success;
    [self openThankYouPage];
}

-(void)openThankYouPage
{
    //    [self finishThisPage];
    CUSThankYouViewController * myCustomViewController=[[CUSThankYouViewController alloc] initWithNibName:@"CUSThankYouViewController" bundle:nil];
    myCustomViewController.cusNsmdTicketIdResponseobject = self.cusNsdCreateTicketResponseObject;
    myCustomViewController.online = true;
    //        myCustomViewController.cusCreateTicketViewController = self;
    [self presentViewController:myCustomViewController animated:YES completion:nil];
    
}

/*
 NSDictionary *responseDict = (NSDictionary*)success;
 NSString *jid = [[responseDict objectForKey:@"response"] objectForKey:@"jid"];
 NSString *prechat_id = [[responseDict objectForKey:@"response"] objectForKey:@"prechat_id"];
 
 [[NSUserDefaults standardUserDefaults] setObject:prechat_id forKey:@"prechat_id"];
 [[NSUserDefaults standardUserDefaults] setObject:jid forKey:cusConstStrKeyJID];
 //    [[NSUserDefaults standardUserDefaults] setObject:@"asdasdasd@34" forKey:cusConstStrKeyPassword];
 
 
 WaitViewController *wait = [[WaitViewController alloc] initWithNibName:@"WaitViewController" bundle:nil];
 [self presentViewController:wait animated:YES completion:nil];
 
 //   `` [self dismissViewControllerAnimated:YES completion:nil];
 //    NSLog(@"success = %@",success);
 */


-(void) failed: (id)failed{
    
    NSLog(@"failed");
    [UIView animateWithDuration:0.05 animations:^{
        [[[Cus360Chat sharedInstance]cusBaseView] dismissViewControllerAnimated:NO completion:nil];
    }];
}


-(IBAction) submit :(id)sender{
    
    [self submitForm];
}

- (void)submitForm
{
    if ([self validateAllElements])
        [self submitParams];
}
#pragma mark - scrollView delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self cancelTouched:nil];
}

#pragma mark - textView Delegate
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if (textView.superview.frame.origin.y+80>[HomerUtils getScaledSizeBasedOnDevice:250]) {
        
        float yOffset = textView.superview.frame.origin.y-[HomerUtils getScaledSizeBasedOnDevice:100];
        [_CSATscrollView setContentOffset:CGPointMake(0, yOffset) animated:NO];
    }
}
-(void)textViewDidEndEditing:(UITextView *)textView{
    
    self.CSATscrollView.contentOffset = CGPointMake(0, 0);
    
}
#pragma mark - TextField Delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField.superview.frame.origin.y+30>[HomerUtils getScaledSizeBasedOnDevice:250]) {
        
        float yOffset = textField.superview.frame.origin.y-[HomerUtils getScaledSizeBasedOnDevice:100];
        [_CSATscrollView setContentOffset:CGPointMake(0, yOffset) animated:NO];
    }
    
    return YES;
}
-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    
    
    self.CSATscrollView.contentOffset = CGPointMake(0, 0);
    
    return YES;
    
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    CGRect frame = pickerView.frame;
    frame.size.height-=54;
    [pickerView setFrame:frame];
    
    pickerView.dataSource = self;
    pickerView.delegate = self;
    UIToolbar*  mypickerToolbar;
    NSMutableArray *barItems;
    UIBarButtonItem *cancelBtn,*doneBtn,*flexSpace;
    
    mypickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 56)];
    mypickerToolbar.barStyle = UIBarStyleDefault;
    [mypickerToolbar sizeToFit];
    
    barItems = [[NSMutableArray alloc] init];
    if (textField.tag==1)
    {
        
        cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelTouched:)];
        [barItems addObject:cancelBtn];
        
        flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        [barItems addObject:flexSpace];
        
        doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(pickerDoneClicked)];
        [barItems addObject:doneBtn];
        
        [mypickerToolbar setItems:barItems animated:YES];
        [textField setTintColor:[UIColor clearColor]];
        //        [_CSATscrollView setContentOffset:CGPointMake(0, textField.superview.frame.origin.y-150) animated:NO];
        
        
        arrPickerData=[[NSMutableArray alloc]init];
        for (int i=1; i<=arrViews.count; i++)
        {
            NSDictionary *element =[[arrViews objectAtIndex:i-1]objectForKey:@"question_container"] ;
            NSString *isDropDown = [element objectForKey:@"type"];
            
            if ([isDropDown isEqualToString:@"select"])
            {
                NSMutableArray *answers = (NSMutableArray*)[element objectForKey:@"answers"];
                //                    NSLog(@"%@",answers);
                for (int j=0; j<answers.count; j++)
                {
                    [arrPickerData addObject:[[answers objectAtIndex:j] objectForKey:@"answer"]];
                }
                break;
            }
        }
        pickerView.hidden=NO;
        [ pickerView  setShowsSelectionIndicator:YES];
        textField.inputView =  pickerView;
        textField.inputAccessoryView = mypickerToolbar;
    }
    
    //else
    //    scrollView.contentSize = CGSizeMake(320, 1135);
    [pickerView reloadAllComponents];
    
    //        return YES;
    
}
#pragma mark pickerDoneClicked Methods


-(void)pickerDoneClicked
{
    for (int i =0; i<_cusCSATUITextFieldSelect.count; i++)
    {
        UITextField * send = [_cusCSATUITextFieldSelect objectAtIndex:i];
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
