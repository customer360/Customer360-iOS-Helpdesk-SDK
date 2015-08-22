//
//  Cus360ChatHistoryCellController.h
//  InAppChat
//
//  Created by customer360 on 22/08/15.
//
//

#import <UIKit/UIKit.h>

@interface Cus360ChatHistoryCellController : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *lastMessageLabel;

- (void)renderCellWithDictionary:(NSDictionary *)cusDict;

@end
