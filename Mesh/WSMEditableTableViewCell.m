//
//  WSMEditableTableViewCell.m
//  rendezvous
//
//  Created by Cristian Monterroza on 7/24/14.
//
//

#import "WSMEditableTableViewCell.h"

@interface WSMEditableTableViewCell () <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UILabel *textLabel;

@end

@implementation WSMEditableTableViewCell

@synthesize detailTextField = _detailTextField, textLabel = _textLabel;

- (void)awakeFromNib {
    // Initialization code
}

- (void)prepareForUsername:(id<UITextFieldDelegate>)delegate {
    self.textLabel.text = @"Username";
    self.detailTextField.placeholder = @"CoolName";
    self.detailTextField.delegate = delegate;
    self.detailTextField.returnKeyType = UIReturnKeyNext;
    self.userInteractionEnabled = YES;
    self.detailTextField.tag = self.tag;
}

- (void)prepareForPassword:(id<UITextFieldDelegate>)delegate {
    self.textLabel.text = @"Password";
    self.detailTextField.placeholder = @"********";
    self.detailTextField.delegate = delegate;
    self.detailTextField.secureTextEntry = YES;
    self.userInteractionEnabled = YES;
    self.detailTextField.keyboardType = UIKeyboardTypeAlphabet;
    self.detailTextField.returnKeyType = UIReturnKeyDone;
    self.detailTextField.tag = self.tag;
}
/*
 When the table view becomes editable, the cell should:
 Hide the location label (so that the Delete button does not overlap it)
 Enable the name field (to make it editable)
 Set a placeholder for the tags field (so the user knows to tap to edit tags)
 The inverse applies when the table view has finished editing.
 */

- (void)willTransitionToState:(UITableViewCellStateMask)state {
    [super willTransitionToState:state];
    if (state & UITableViewCellStateEditingMask) {
        self.textLabel.hidden = NO;
        self.detailTextField.enabled = YES;
    }
}

- (void)didTransitionToState:(UITableViewCellStateMask)state {
    [super didTransitionToState:state];
    if (!(state & UITableViewCellStateEditingMask)) {
        self.textLabel.hidden = NO;
        self.detailTextField.enabled = NO;
    }
}

- (void)viewDidUnload {
    self.textLabel = nil;
    self.detailTextField = nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
