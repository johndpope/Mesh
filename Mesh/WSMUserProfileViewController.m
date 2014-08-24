//
//  WSMUserProfileViewController.m
//  hottub
//
//  Created by Cristian Monterroza on 7/29/14.
//  Copyright (c) 2014 wrkstrm. All rights reserved.
//

#import "WSMUserProfileViewController.h"
#import "WSMButton.h"

@interface WSMUserProfileViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIImage *profileImage;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet WSMButton *cameraButton;

@end

@implementation WSMUserProfileViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (!(self = [super initWithCoder:aDecoder])) return nil;
    self.title = @"Profile";
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.cameraButton.layer.cornerRadius = self.cameraButton.bounds.size.height / 2;
    [self.cameraButton setImage:self.profileImage forState:UIControlStateNormal];
    [self.cameraButton setImage:self.profileImage forState:UIControlStateSelected];
}

- (UIImage *)profileImage {
    return WSM_LAZY(_profileImage, ({
        CBLAttachment *pictureAttachment = [self.currentUser attachmentNamed:@"avatar"];
        [[UIImage alloc] initWithData:pictureAttachment.content];
    }));
}

- (IBAction)pushButton:(id)sender {
    NSLog(@"Button pushed!");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Profile Info";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"info"];
    WSM_LAZY(cell, [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
                                          reuseIdentifier:@"info"]);
    cell.textLabel.text = @"Username:";
    cell.detailTextLabel.text = self.currentUser.username;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
