//
//  WSMAuthViewController.m
//  Mesh
//
//  Created by Cristian Monterroza on 7/30/14.
//  Copyright (c) 2014 wrkstrm. All rights reserved.
//

#import "WSMAuthViewController.h"
#import "WSMEditableTableViewCell.h"
#import "WSMCameraButton.h"

@interface WSMAuthViewController () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

#pragma mark - Controller State.
@property (nonatomic) WSMAuthControllerType controllerType;
@property (nonatomic) WSMAuthTableViewState tableViewState;
@property (nonatomic) CGPoint tableViewCenter;

@property (nonatomic, strong) NSString *username, *password;

@property (nonatomic, strong) UIImage *profileImage;
@property (nonatomic, strong) IBOutlet WSMCameraButton *cameraButton;
@property (nonatomic, strong) IBOutlet UITextView *instructionsLabel;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end

@implementation WSMAuthViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (!(self = [super initWithCoder:aDecoder])) return nil;
    _tableViewState = kWSMAuthTableViewStateHidden;
    return self;
}

- (WSMAuthControllerType)controllerType {
    return self.currentUser ? kWSMAuthControllerTypeSignIn : kWSMAuthControllerTypeSignUp;
}

#define editableCell @"WSMEditableTableViewCell"

- (void)loadView {
    [super loadView];
    self.editing = NO;
    self.title = self.controllerType ? @"Sign Up" : @"Sign In";
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"WSMEditableTableViewCell" bundle:nil]
         forCellReuseIdentifier:editableCell];
    
    @weakify(self);
    [[[NSNotificationCenter.defaultCenter rac_addObserverForName:UIKeyboardWillShowNotification object:nil]
      takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification *notification) {
        @strongify(self);
        if (self.tableViewState == kWSMAuthTableViewStateShown) {
            CGRect keyboardRect = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
            
            CGFloat duration = 0.9, damping = 0.8;
            [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:damping
                  initialSpringVelocity:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
                      self.tableView.frame = CGRectOffset(self.tableView.frame, 0, -CGRectGetHeight(keyboardRect));
                  } completion:^(BOOL finished) {}];
            self.tableViewState = kWSMAuthTableViewStateRaised;
        }
    }];
    
    [[[NSNotificationCenter.defaultCenter rac_addObserverForName:UIKeyboardWillHideNotification object:nil]
      takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification *notification) {
        @strongify(self);
        CGRect keyboardRect = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        
        CGFloat duration = 0.9, damping = 0.8;
        [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:damping
              initialSpringVelocity:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
                  self.tableView.frame = CGRectOffset(self.tableView.frame, 0, CGRectGetHeight(keyboardRect));
              } completion:^(BOOL finished) {}];
        self.tableViewState = kWSMAuthTableViewStateShown;
    }];
    
    self.tableViewCenter = self.tableView.center;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"TableViewFrame: %@", NSStringFromCGRect(self.tableView.frame));
    self.tableView.alpha = 0;
    [self.tableView setFrame:CGRectOffset(self.tableView.frame, 0,
                                          CGRectGetHeight([[UIScreen mainScreen] bounds]) / 2)];
    NSLog(@"TableViewFrame: %@", NSStringFromCGRect(self.tableView.frame));
    switch (self.controllerType) {
        case kWSMAuthControllerTypeSignUp: {
            NSAssert(!self.currentUser, @"We should not be signing up right now");
            NSLog(@"We are signing up!");
        } break;
        default: {
            NSAssert((self.controllerType == kWSMAuthControllerTypeSignIn && self.currentUser),
                     @"We should have a user.");
            
            CBLAttachment *pictureAttachment = [self.currentUser attachmentNamed:@"avatar"];
            self.profileImage = [UIImage imageWithData:pictureAttachment.content];
            NSLog(@"Trying to set picture of user: %@", self.profileImage);
            
            self.cameraButton.layer.cornerRadius = self.cameraButton.bounds.size.height / 2;
            self.cameraButton.backgroundColor = [SKColor clearColor];
            self.cameraButton.clipsToBounds = YES;
            self.cameraButton.enabled = YES;
            self.cameraButton.layer.masksToBounds = YES;
            [self.cameraButton setImage:self.profileImage forState:UIControlStateNormal];
        } break;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (IBAction)pickProfilePicture:(UIButton *)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = (id<UINavigationControllerDelegate, UIImagePickerControllerDelegate>)self;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    picker.modalPresentationStyle = UIModalPresentationFullScreen;
    picker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [self presentViewController:picker animated:YES completion: ^{}];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)Picker {
    [self dismissViewControllerAnimated:YES completion:^{
        [[[UIAlertView alloc] initWithTitle:@"Pic Please!"
                                    message:@"A profile picture is required to sign up!"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.profileImage = [[UIImage resizeImage:info[UIImagePickerControllerOriginalImage]
                                     newSize:CGSizeMake(200, 200)] imageRotatedByDegrees:90.0f];
    self.cameraButton.layer.cornerRadius = self.cameraButton.bounds.size.height / 2;
    self.cameraButton.backgroundColor = [SKColor clearColor];
    self.cameraButton.clipsToBounds = YES;
    [self.cameraButton setImage:self.profileImage forState:UIControlStateNormal];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self showTableViewAnimation];
        switch (self.controllerType) {
            case kWSMAuthControllerTypeSignUp: {
                self.instructionsLabel.text = @"Great! Now chose a username and confirm a password!";
            } break;
            default: {
                self.instructionsLabel.text = @"Welcome back, sign back into chat (please!)";
            } break;
        }
        self.instructionsLabel.font = [UIFont boldSystemFontOfSize:17];
        self.instructionsLabel.textAlignment = NSTextAlignmentCenter;
    }];
}

#pragma mark - Animations

- (void)showTableViewAnimation {
    if (self.tableViewState != kWSMAuthTableViewStateHidden) return;
    CGFloat duration = 1.5, damping = 0.75;
    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:damping
          initialSpringVelocity:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^
     {
         self.tableView.alpha = 1.0;
         self.tableView.center = CGPointMake(self.tableView.center.x, self.tableViewCenter.y);
     } completion:^(BOOL finished) {}];
    
    self.tableViewState = kWSMAuthTableViewStateShown;
}

#pragma mark - WSMTableViewDelegate

- (void)authenticateWithUsername:(NSString *)username password:(NSString *)password {
    __block BOOL authenticationSuccess = NO;
    switch (self.controllerType) {
        case kWSMAuthControllerTypeSignUp: {
            [[LYRClient sharedClient] signupWithUsername:username password:password firstName:nil
                                                lastName:nil emailAddress:nil phoneNumber:nil
                                              completion:^(NSError *error)
             {
                 if (error) {
                     NSLog(@"Authentication failed with error: %@", error);
                 } else {
                     authenticationSuccess = YES;
                     LYRUserInfo *info = [[LYRClient sharedClient] userInfo];
                     NSLog(@"Sign UP successful. Authenticated as: %@", info);
                     NSString *uupc = info.identifier;
                     LYRAddress *address = info.addresses[0];
                     NSString *userAddress = [address.stringRepresentation stringByReplacingOccurrencesOfString:@"Address "
                                                                                                     withString:@""];
                     NSDictionary *validParams = @{@"_id":uupc, @"uupc":uupc,
                                                   @"address": userAddress, @"username":username};
                     
                     WSMUser *user = [[WSMUserManager sharedInstance] createDefaultUserWithParams:validParams];

                     NSData *compressedPic;
                     WSM_LAZY(compressedPic, UIImageJPEGRepresentation(self.profileImage, 0.8f));
                     WSM_LAZY(compressedPic, UIImagePNGRepresentation(self.profileImage));
                     if (!compressedPic) {
                         [[[UIAlertView alloc] initWithTitle:@"Could not Compress Picture"
                                                     message:@"We tried JPEG and PNG"
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil] show];
                     } else {
                         NSString *attachmentName = [NSString stringWithFormat:@"avatar"]; //, (long) (user.attachmentNames.count+1)];
                         [user setAttachmentNamed:attachmentName withContentType:@"image/jpeg"
                                          content:compressedPic];
                         
                         DDLogError(@"We saved a picture: %@", attachmentName);
                         [user save: nil];
                         if ([[WSMUserManager sharedInstance] currentUser]) {
                             //                             [self patchImage:compressedPic];
                         } else {
                             //                             [self postImage:compressedPic];
                         }
                     }
                     [user setAttachmentNamed:@"avatar"
                              withContentType:@"image/jpeg"
                                      content:UIImageJPEGRepresentation(self.profileImage, 0.8f)];
                     
                     [self dismissViewControllerAnimated:YES completion:^{
                         if ([self.parentViewController respondsToSelector:@selector(authenticated)]) {
                             [self.parentViewController performSelector:@selector(authenticated)
                                                             withObject:self
                                                             afterDelay:0.0f];
                         }
                         
                     }];
                 }
             }];
        } break;
        default: {
            if (self.currentUser.username != username) {
                [[[UIAlertView alloc] initWithTitle:@"I haven't gotten this far!"
                                            message:@"You are signing in as someone new!"
                                           delegate:nil
                                  cancelButtonTitle:@"The wrong pic will be broadcast!"
                                  otherButtonTitles:nil] show];
            } else {
                [[LYRClient sharedClient] authenticateWithUsername:username password:password
                                                        completion:^(NSError *error)
                 {
                     if (error) {
                         NSLog(@"Damn: %@",  error);
                     } else {
                         [self dismissViewControllerAnimated:YES completion:^{
                             if ([self.parentViewController respondsToSelector:@selector(authenticated)]) {
                                 [self.parentViewController performSelector:@selector(authenticated)
                                                                 withObject:self
                                                                 afterDelay:0.0f];
                             }
                         }];
                     }
                 }];
            }
        } break;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.controllerType == kWSMAuthControllerTypeSignIn ? 2 : 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.controllerType == kWSMAuthControllerTypeSignIn ? @"Sign In" : @"Sign Up";
}

#define usernameTag 0
#define passwordTag 1

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WSMEditableTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:editableCell
                                                                     forIndexPath:indexPath];
    
    cell.tag = indexPath.row;
    switch (indexPath.row) {
        case usernameTag: {
            [cell prepareForUsername:self];
            cell.detailTextField.text = self.currentUser.username;
        } break;
        default: {
            [cell prepareForPassword:self];
        }
    }
    return cell;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    switch (textField.tag) {
        case usernameTag:{
            NSLog(@"Username Return.");
            WSMEditableTableViewCell *nextCell = (WSMEditableTableViewCell *)[self.tableView
                                                                              cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1
                                                                                                                       inSection:0]];
            [nextCell.detailTextField becomeFirstResponder];
            return YES;
        } break;
        case passwordTag: {
            if (self.controllerType == kWSMAuthControllerTypeSignUp) {
                WSMEditableTableViewCell *nextCell = (WSMEditableTableViewCell *)[self.tableView
                                                                                  cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2
                                                                                                                           inSection:0]];
                [nextCell.detailTextField becomeFirstResponder];
            } else {
                WSMEditableTableViewCell *usernameCell = (WSMEditableTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                WSMEditableTableViewCell *passwordCell = (WSMEditableTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                if (usernameCell.detailTextField.text && passwordCell.detailTextField.text) {
                    [textField endEditing:YES];
                    NSString *trimmedUsername = [usernameCell.detailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    NSString *trimmedPassword = [passwordCell.detailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    NSLog(@"Sending: %@, %@", trimmedUsername, trimmedPassword);
                    [self authenticateWithUsername:trimmedUsername password:trimmedPassword];
                    return YES;
                } else {
                    return NO;
                }
            }
        } break;
        default:{
            WSMEditableTableViewCell *usernameCell = (WSMEditableTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            WSMEditableTableViewCell *passwordCell = (WSMEditableTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
            WSMEditableTableViewCell *confirmCell = (WSMEditableTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
            BOOL passwordMatch = [passwordCell.detailTextField.text isEqualToString:confirmCell.detailTextField.text];
            if (usernameCell.detailTextField.text && passwordMatch) {
                [textField endEditing:YES];
                NSString *trimmedUsername = [usernameCell.detailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                NSString *password = passwordCell.detailTextField.text;
                [self authenticateWithUsername:trimmedUsername password:password];
                return YES;
            } else {
                return NO;
            }
        }break;
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"Destination: %@", segue.destinationViewController);
    if ([segue.identifier isEqualToString:@""]) {
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
