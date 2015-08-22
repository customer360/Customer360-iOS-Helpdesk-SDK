//
//  PreChatViewController.h
//  Customer360SDK
//
//  Created by Anveshan Technologies on 30/01/15.
//  Copyright (c) 2015 Customer360. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CusChatUiViewControllerBase.h"

@interface PreChatViewController :CusChatUiViewControllerBase // //UIViewController //
{
//    BOOL checkBoxSelected;
    int YOriginPoint;
    CGFloat screenW;
    //NSMutableArray *newOptArray;
    
 NSData *data,*data1;
}
@property (nonatomic, strong) IBOutlet UIScrollView *PreChatscrollView;
@property (nonatomic, strong) UITextField *dropdown,*email,*name,*phoneNo, *address;
@property (nonatomic, strong) UITextView *question;
@property (nonatomic, strong) NSDictionary *dict;
@property (nonatomic, strong) NSArray *arrViews;
@property (nonatomic, strong) NSMutableArray *arrPickerData;
@property (nonatomic, strong) UIPickerView *pickerView;
//@property (nonatomic, strong) UITextView *question;
@property (strong ,nonatomic) NSDictionary * cusNsdCreateTicketResponseObject;
@property (strong, nonatomic) NSMutableArray * cusChatUITextField;
@property (strong, nonatomic) NSMutableArray * cusChatUITextView;
@property (strong, nonatomic) NSMutableArray * cusChatUITextFieldSelect;
@property (strong, nonatomic) NSMutableArray * cusChatUITextFieldDate;
@property (strong, nonatomic) NSMutableArray * cusChatUITextFieldTime;
//@property (strong, nonatomic) NSMutableArray *checkBoxArray;
@property (nonatomic,strong)NSMutableArray *myOptArray;

@end
