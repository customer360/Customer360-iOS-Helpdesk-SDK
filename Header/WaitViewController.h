//
//  ViewController.h
//  InAppChat
//
//  Created by Anveshan Technologies on 03/03/15.
//
//

#import <UIKit/UIKit.h>
#import "CusChatUiViewControllerBase.h"
@interface WaitViewController : CusChatUiViewControllerBase
{

    NSTimer *pingTimer;

}
@property (strong, nonatomic) IBOutlet UIImageView *waitingScreenImageView;
@end
