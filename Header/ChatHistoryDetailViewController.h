//
//  ChatHistoryDetailViewController.h
//  InAppChat
//
//  Created by Customer360 on 30/06/15.
//
//

#import "CusChatUiViewControllerBase.h"

@interface ChatHistoryDetailViewController : CusChatUiViewControllerBase<UITableViewDelegate, UITableViewDataSource>
{
    //NSString *messageID;
}
@property (strong, nonatomic) IBOutlet UITableView *cusDetailsChatTableView;
@property (strong, nonatomic) NSMutableDictionary *messageDict;
@property (strong, nonatomic) NSMutableArray *messageArray;
@property (strong, nonatomic) NSMutableArray *messages;
@end
