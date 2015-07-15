//
//  MessageCell.m
//  ChatForText
//
//  Created by Anveshan Technologies on 12/03/15.
//
//

#import "CusChatMessageCell.h"
#import "CusChatMessage.h"
#import "CusChatMessageFrame.h"
#import "NSString+HTML.h"
#import "Cus360Chat.h"


@interface CusChatMessageCell ()
{
    UIView *headImageBackView;
}
@end

@implementation CusChatMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        headImageBackView = [[UIView alloc]init];
        headImageBackView.layer.cornerRadius = 22;
        headImageBackView.layer.masksToBounds = YES;
//        headImageBackView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.4];
        [self.contentView addSubview:headImageBackView];
        self.btnHeadImage = [[AsyncImageView alloc] init];
//        self.btnHeadImage.layer.cornerRadius = 16;
        self.btnHeadImage.layer.masksToBounds = YES;
        

        [headImageBackView addSubview:self.btnHeadImage];

        [self.contentView addSubview:headImageBackView];
        
        self.labelName = [[UILabel alloc] init];
        self.labelName.font = ChatTimeFont;
        [self.contentView addSubview:self.labelName];
        }
    return self;
}

-(void)setMessage:(CusChatMessage *)message{

    _message = message;
    CusChatMessageFrame *newFrame = [[CusChatMessageFrame alloc] init];
//    [_btnContent setText:message.strContent];
    [newFrame setMessage:_message];
    [self setMessageFrame:newFrame];
}

- (void)setMessageFrame:(CusChatMessageFrame *)messageFrame{

    _messageFrame = messageFrame;
    CusChatMessage *message = _message;
    headImageBackView.frame = messageFrame.iconF;
      NSString *content =  [[[message.strContent stringByStrippingTags] stringByRemovingNewLinesAndWhitespace] stringByDecodingHTMLEntities];
    self.btnHeadImage.frame = CGRectMake(4, 4, 32, 32);
    self.btnHeadImage.center = headImageBackView.center;
    if (message.from == MessageFromMe) {
//setBackgroundImageForState:UIControlStateNormal withURL:[NSURL URLWithString:message.strIcon]];
//        headImageBackView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.4];

        [self.btnHeadImage setImage:[UIImage imageNamed:@"customer128"]];
//        customer128
//        cus_consumer_icon
        
    }else{
//        NSURL *photo = [NSURL URLWithString:message.strIcon];
        
        if (![message.strIcon isEqualToString:@"undefined"]) {
                    [self.btnHeadImage setImageURL:[NSURL URLWithString:message.strIcon] ];
        }
        else {
            [self.btnHeadImage setImage:[UIImage imageNamed:@"agent128"]];
        }
//        [self.btnHeadImage setBackgroundImageForState:UIControlStateNormal withURL:[NSURL URLWithString:message.strIcon]];
        
    }
    if (message.from == MessageFromMe) {

        self.labelName.frame = CGRectMake(10 , 4, 50, messageFrame.nameF.size.height);
        self.labelName.text = @"Me";
        self.labelName.textColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    }
    else
    {
        NSString *name =message.strName;
        if ([name rangeOfString:@"("].length >0) {
        name = [name substringToIndex:[name rangeOfString:@"("].location];            
        }
        NSString *agent = name;
        CGRect content = [agent boundingRectWithSize:CGSizeMake(self.frame.size.width-120, CGFLOAT_MAX) options:(NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:15.0]} context:nil];
        self.labelName.numberOfLines =0;
        self.labelName.text = agent;
        self.labelName.frame = CGRectMake(10, 4, content.size.width, messageFrame.nameF.size.height);
        self.labelName.textColor = [UIColor colorWithRed:119.0/255.0 green:119.0/255.0 blue:119.0/255.0 alpha:1.0f];
        
    }
    self.labelName.textAlignment = NSTextAlignmentLeft;

    CAShapeLayer * maskLayer = [CAShapeLayer layer];
    UIView *bgView = [[UIView alloc] init];
    bgView.frame = CGRectMake(messageFrame.nameF.origin.x , messageFrame.nameF.origin.y,MAX(messageFrame.contentF.size.width+10 , self.labelName.frame.size.width+10) ,messageFrame.contentF.size.height);
    
    self.btnContent = [[CusChatMessageContent alloc] initWithFrame:CGRectMake(8, messageFrame.nameF.origin.y+8,messageFrame.contentF.size.width , messageFrame.contentF.size.height)];
    self.btnContent.dataDetectorTypes = UIDataDetectorTypeAll;
    self.btnContent.editable = NO;

    //*******/ Just to check frames
//        self.labelName.layer.borderColor = [UIColor blueColor].CGColor;
//        self.labelName.layer.borderWidth = 1.0f;
//        self.btnContent.layer.borderColor = [UIColor blueColor].CGColor;
//        self.btnContent.layer.borderWidth = 1.0f;

    if (message.from == MessageFromMe) {
        self.btnContent.isMyMessage = YES;
        [self.btnContent setTextColor:[UIColor whiteColor]];
        [bgView setBackgroundColor:[self colorWithHexString:[[Cus360Chat sharedInstance] getNavigationBarColor]]];
        maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:bgView.bounds
                                               byRoundingCorners:UIRectCornerBottomRight|UIRectCornerBottomLeft|UIRectCornerTopLeft
                                                     cornerRadii:CGSizeMake(8, 8)].CGPath;
        bgView.layer.mask = maskLayer;
    }
    else
    {
        self.btnContent.isMyMessage = NO;
        [self.btnContent setTextColor:[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0f]];
        [bgView setBackgroundColor:[UIColor colorWithRed:208.0/255.0 green:208.0/255.0 blue:208.0/255.0 alpha:1.0]];
        maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:bgView.bounds
                                               byRoundingCorners:UIRectCornerBottomRight|UIRectCornerBottomLeft|UIRectCornerTopRight
                                                     cornerRadii:CGSizeMake(8, 8)].CGPath;
        bgView.layer.mask = maskLayer;
    }
    
  
    _btnContent.text = content;
    _btnContent.scrollEnabled = NO;
    _btnContent.backgroundColor = [UIColor clearColor];
    _btnContent.font = ChatContentFont;

    
//**** ADD Views to cell
    [self.contentView addSubview:_btnHeadImage];
    [bgView addSubview:self.btnContent];
    [bgView addSubview:self.labelName];
    [self.contentView addSubview:bgView];
}


-(UIColor *)colorWithHexString:(NSString *)stringToConvert
{
    NSString *noHashString = [stringToConvert stringByReplacingOccurrencesOfString:@"#" withString:@""]; // remove the #
    NSScanner *scanner = [NSScanner scannerWithString:noHashString];
    [scanner setCharactersToBeSkipped:[NSCharacterSet symbolCharacterSet]]; // remove + and $
    unsigned hex;
    if (![scanner scanHexInt:&hex]) return nil;
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    return [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:1.0f];
}

@end



