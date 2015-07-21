//
//  PreChatOptionsVC.m
//  InAppChat
//
//  Created by customer360 on 20/07/15.
//
//

#import "PreChatOptionsVC.h"

@interface PreChatOptionsVC ()
{
    NSString *screenType;
    UILabel *parentBoxLabel;
    NSMutableArray *selectedBoxArray;
}

@property (weak, nonatomic) IBOutlet UIScrollView *optionScrollViewController;

@end

@implementation PreChatOptionsVC

- (void)viewDidLoad {
    //[super viewDidLoad];
    float width = [[UIScreen mainScreen] bounds].size.width;
    CGRect thisFrame = self.view.frame;
    thisFrame.origin.x = width;
    self.view.frame = thisFrame;
    
    selectedBoxArray = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super hideActivityIndicator];
}


//--------------------------------------------------------------------------
//--------------------------------------------------------------------------
#pragma mark - private Methods

- (void)viewSlideIn
{
    CGRect thisFrame = self.view.frame;
    thisFrame.origin.x = 0;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.view.frame = thisFrame;
                     }
                     completion:^(BOOL finished){
                         //[self viewSlideOut];
                     }];
}

- (void)viewSlideOut
{
    float width = [[UIScreen mainScreen] bounds].size.width;
    CGRect thisFrame = self.view.frame;
    thisFrame.origin.x = width;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.view.frame = thisFrame;
                     }
                     completion:^(BOOL finished){
                         [self finishThis];
                     }];
}

- (void)finishThis
{
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self checkBoxCallback:selectedBoxArray];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}




//--------------------------------------------------------------------------
//--------------------------------------------------------------------------
#pragma mark - public Methods

- (void)renderElement:(NSDictionary *)element withViewBox:(UIView *)view
{
    screenType = [element objectForKey:@"type"];
    parentBoxLabel = (UILabel*)[view viewWithTag:10];

    
    ///---------------------------------------------------------
    // Render Navigation Bar
    NSString *itemTitle = [NSString stringWithFormat:@"%@",[element objectForKey:@"question"]];
    UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:itemTitle];
    UIBarButtonItem *leftItem = [super getNavigationBackButtonWithTarget:self action:@selector(viewSlideOut)];
    [super loadNavigationBarWithItem:item leftItem:leftItem rightItem:nil];
    
    
    
    //---------------------------------------------------------
    // Render Options
    int boxYPos = 0;
    int boxHeight = 64;
    CGFloat scrollViewW = self.optionScrollViewController.frame.size.width;
    
    NSMutableArray *buttonTitles = [[NSMutableArray alloc]initWithArray:[element objectForKey:@"answers"]];
    
    for(int i=0; i<buttonTitles.count; i++)
    {
        //------------------------------
        //Box's main view...
        UIView *boxView = [[UIView alloc] initWithFrame:CGRectMake(0, boxYPos, scrollViewW, boxHeight)];
//        boxView.backgroundColor = [UIColor cyanColor];
        boxYPos += boxHeight;
        [self.optionScrollViewController addSubview:boxView];
        NSString* optionTag = [[buttonTitles objectAtIndex:i]objectForKey:@"answer_id"];
        [boxView setTag:optionTag.integerValue];
        
        
        //------------------------------
        //Box's  UILabel...
        UILabel *boxLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 16, scrollViewW-32 , 24)];
        //    boxLabel.backgroundColor = [UIColor yellowColor];
        boxLabel.text = [[buttonTitles objectAtIndex:i]objectForKey:@"answer"];
        [boxLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
        boxLabel.textColor = [UIColor colorWithRed:136.0/255.0 green:136.0/255.0 blue:136.0/255.0 alpha:1.0f];
        boxLabel.textAlignment = NSTextAlignmentLeft;
        boxLabel.tag = 1;
        [boxView addSubview:boxLabel];
        
        
        //------------------------------
        //Box's  Image...
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkbox"]];
        CGRect imgFrame = imgView.frame;
        imgFrame.origin.x = scrollViewW - 32 - imgFrame.size.width;
        imgFrame.origin.y = 24;
        [imgView setFrame:imgFrame];
        imgView.tag = 2;
        imgView.hidden = TRUE;
        [boxView addSubview:imgView];
        
        //------------------------------
        //Box's end line...
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 63, scrollViewW, 1)];
        line.backgroundColor = [UIColor colorWithRed:221.0/255.0f green:221.0/255.0f blue:221.0/255.0f alpha:1.0f];
        [boxView addSubview:line];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBoxFunc:)];
        [boxView addGestureRecognizer:singleTap];
    }
    
    self.optionScrollViewController.contentSize = CGSizeMake(scrollViewW, boxYPos);
    [self viewSlideIn];
}

- (void)tapBoxFunc:(UITapGestureRecognizer *)recognizer
{
    if([screenType isEqualToString:@"radio"] || [screenType isEqualToString:@"select"])
        [self uncheckAllBox];
    
    UIImageView *checkBox =  (UIImageView*)[recognizer.view viewWithTag:2];
    checkBox.hidden = !checkBox.hidden;
    
    UILabel *label = (UILabel*)[recognizer.view viewWithTag:1];
    if(checkBox.hidden)
    {
        label.textColor = [UIColor colorWithRed:136.0/255.0 green:136.0/255.0 blue:136.0/255.0 alpha:1.0f];
        [selectedBoxArray removeObject:recognizer.view];
    }else
    {
        label.textColor = [UIColor colorWithRed:0.0/255.0 green:121.0/255.0 blue:255.0/255.0 alpha:0.6f];
        [selectedBoxArray addObject:recognizer.view];
    }
    
    
    //-----------------
    // set label in the previous view Box...
    
    [self setParentBoxLabel];
}

- (void)uncheckAllBox
{
    for(int i=0; i<selectedBoxArray.count; i++)
    {
        UIView *view = (UIView*)[selectedBoxArray objectAtIndex:i];
        
        UIImageView *checkBox =  (UIImageView*)[view viewWithTag:2];
        checkBox.hidden = TRUE;
        
        UILabel *label = (UILabel*)[view viewWithTag:1];
        label.textColor = [UIColor colorWithRed:136.0/255.0 green:136.0/255.0 blue:136.0/255.0 alpha:1.0f];
    }
    
    [selectedBoxArray removeAllObjects];
}

- (void)setParentBoxLabel
{
    if(selectedBoxArray.count <= 0)
    {
        parentBoxLabel.text =@"";
        return;
    }
    
    NSString *checkedItems = [[NSString alloc] init];
    for(int i=0; i<selectedBoxArray.count; i++)
    {
        UIView *checkedView = [selectedBoxArray objectAtIndex:i];
        UILabel *label = (UILabel*)[checkedView viewWithTag:1];
        if(i!=0)
            checkedItems = [checkedItems stringByAppendingString:@", "];
        
        checkedItems = [checkedItems stringByAppendingString:label.text];
    }
    parentBoxLabel.text = checkedItems;
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
