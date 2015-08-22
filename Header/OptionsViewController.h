//
//  OptionsViewController.h
//  InAppChat
//
//  Created by customer360 on 28/07/15.
//
//

#import <UIKit/UIKit.h>
#import "CusChatUiViewControllerBase.h"

@interface OptionsViewController : CusChatUiViewControllerBase

- (void)renderRadioForDictionary:(NSDictionary *)elements selectedElement:(NSArray *)array withDelegate:(UIViewController *)deleg;
- (void)renderDropdownForDictionary:(NSDictionary *)elements selectedElement:(NSArray *)array withDelegate:(UIViewController *)deleg;
- (void)renderCheckboxForDictionary:(NSDictionary *)elements selectedElement:(NSArray *)array withDelegate:(UIViewController *)deleg;
@end

@protocol OptionViewDelegates <NSObject>
- (void)optionViewRadio:(NSArray *)selectedElement;
- (void)optionViewDropdown:(NSArray *)selectedElement;
- (void)optionViewCheckbox:(NSArray *)selectedElement;
@end