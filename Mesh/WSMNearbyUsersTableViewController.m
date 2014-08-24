//
//  WSMNearbyUsersTableViewController.m
//  Mesh
//
//  Created by Cristian Monterroza on 7/29/14.
//  Copyright (c) 2014 wrkstrm. All rights reserved.
//

#import "WSMNearbyUsersTableViewController.h"
#import "WSMUserTableViewCell.h"
#import "WSMMessagingViewController.h"

@interface WSMNearbyUsersTableViewController ()

@property (nonatomic, strong) NSArray *encounteredUsers;

@end

@implementation WSMNearbyUsersTableViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (!(self = [super initWithCoder:aDecoder])) return nil;
    self.title = @"Encounters";
    return self;
}

#pragma mark - Lazy Instantiation

#define userCell @"WSMUserTableViewCell"

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:userCell bundle:nil]
         forCellReuseIdentifier:userCell];
    
    [[RACObserve(WSMUserManager.sharedInstance, nearbyUsers) takeUntil: self.rac_willDeallocSignal]
     subscribeNext:^(NSArray *users) {
         NSLog(@"Reloading TableView with: %@", users);
         dispatch_async(dispatch_get_main_queue(), ^{
             [self.tableView reloadSections:[[NSIndexSet alloc] initWithIndex:0]
                           withRowAnimation:UITableViewRowAnimationTop];
         });
     }];
    
    self.clearsSelectionOnViewWillAppear = YES;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: {
            return @"Nearby Users";
        } break;
        default: return @"Past Encounters";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: {
            NSLog(@"Row Count: %lu", (unsigned long)WSMUserManager.sharedInstance.nearbyUsers.count);
            return (NSInteger) WSMUserManager.sharedInstance.nearbyUsers.count;
        } break;
        case 1: {
            return (NSInteger) WSMUserManager.sharedInstance.encounteredUsers.count - 1;
        }
        default: return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WSMUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:userCell forIndexPath:indexPath];
    [cell setupForUser:[self userForIndexPath:indexPath]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (WSMUser *)userForIndexPath: (NSIndexPath *)path {
    switch (path.section) {
        case 0:{
            return (WSMUser *)WSMUserManager.sharedInstance.nearbyUsers[(NSUInteger)path.row];
        } break;
        case 1:{
            return (WSMUser *)WSMUserManager.sharedInstance.encounteredUsers[(NSUInteger)path.row];
        } break;
        default: return nil; break;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            [self performSegueWithIdentifier:@"messagingSegue"
                                      sender:[self userForIndexPath:indexPath]];
            break;
        default: break;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"messagingSegue"]) {
        WSMMessagingViewController *messagingController = (WSMMessagingViewController *) segue.destinationViewController;
        messagingController.recipient = (WSMUser *)sender;
    }
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
