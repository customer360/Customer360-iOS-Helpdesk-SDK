//
//  Cus360ChatHistoryController.h
//  InAppChat
//
//  Created by Customer360 on 29/06/15.
//
//

#import <UIKit/UIKit.h>
#import "CusChatUiViewControllerBase.h"

@interface Cus360ChatHistoryController : CusChatUiViewControllerBase<UITableViewDelegate, UITableViewDataSource>
{
    
}

@property (strong, nonatomic) NSMutableArray *CusChatHistoryArray;
@property (strong, nonatomic) IBOutlet UITableView *cusChatHistoryListingTableView;

@end
