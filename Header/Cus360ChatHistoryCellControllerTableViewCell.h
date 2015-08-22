//
//  Cus360ChatHistoryCellControllerTableViewCell.h
//  InAppChat
//
//  Created by Customer360 on 29/06/15.
//
//

#import <UIKit/UIKit.h>

@interface Cus360ChatHistoryCellControllerTableViewCell : UITableViewCell
//@property (strong, nonatomic) IBOutlet UIImageView *historyCellImage;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *lastMessageLabel;

- (void)renderCellWithDictionary:(NSDictionary *)cusDict;
@end
