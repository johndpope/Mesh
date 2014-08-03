//
//  WSMEditableTableViewCell.h
//  rendezvous
//
//  Created by Cristian Monterroza on 7/24/14.
//
//

#import <UIKit/UIKit.h>

@class WSMUser;

@interface WSMEditableTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UITextField *detailTextField;

- (void)prepareForUsername:(id<UITextFieldDelegate>)delegate;
- (void)prepareForPassword:(id<UITextFieldDelegate>)delegate;

@end
