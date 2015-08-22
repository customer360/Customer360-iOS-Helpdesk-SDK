//
//  PostChatViewController.h
//  InAppChat
//
//  Created by Anveshan Technologies on 20/03/15.
//
//

#import <UIKit/UIKit.h>
#import "CusChatUiViewControllerBase.h"
@interface PostChatViewController : CusChatUiViewControllerBase
{
    //    BOOL checkBoxSelected;
    int YOriginPoint;
    NSData *data,*data1;
    CGFloat screenW;
}
@property (nonatomic, strong) IBOutlet UIScrollView *CSATscrollView;
@property (nonatomic, strong) UITextField *CSATdropdown,*name;
@property (nonatomic, strong) NSDictionary *dict;
@property (nonatomic, strong) NSArray *arrViews;
@property (nonatomic, strong) NSMutableArray *arrPickerData;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UITextView *feedback;
@property (strong ,nonatomic) NSDictionary * cusNsdCreateTicketResponseObject; 
@property (strong, nonatomic) NSMutableArray * cusCSATUITextField;
@property (strong, nonatomic) NSMutableArray * cusCSATUITextView;
@property (strong, nonatomic) NSMutableArray * cusCSATUITextFieldSelect;
@property (strong, nonatomic) NSMutableArray * cusCSATStarRating;
@property (strong, nonatomic) NSMutableArray * cusCSATSmileyScales;
@end
