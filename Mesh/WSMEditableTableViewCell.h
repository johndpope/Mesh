//
//  WSMEditableTableViewCell.h
//  rendezvous
//
//  Created by Cristian Monterroza on 7/24/14.
//
//

@class WSMUser;

@interface WSMEditableTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UITextField *detailTextField;

- (void)prepareForUsername:(id<UITextFieldDelegate>)delegate;
- (void)prepareForPassword:(id<UITextFieldDelegate>)delegate;

@end
