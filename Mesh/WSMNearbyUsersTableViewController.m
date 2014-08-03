//
//  WSMNearbyUsersTableViewController.m
//  Mesh
//
//  Created by Cristian Monterroza on 7/29/14.
//  Copyright (c) 2014 daheins. All rights reserved.
//

#import "WSMNearbyUsersTableViewController.h"
#import "WSMUserTableViewCell.h"

@interface WSMNearbyUsersTableViewController ()

@end

@implementation WSMNearbyUsersTableViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (!(self = [super initWithCoder:aDecoder])) return nil;
    self.title = @"Encounters";
    return self;
}

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
        default: return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"userCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    WSMUser *user = [self userForIndexPath:indexPath];
    
    cell.textLabel.text = user.username;
    cell.detailTextLabel.text = @"This will be a profile.";
    if (user.attachmentNames.count) {
        NSLog(@"We have a picture...");
        __block NSData *content;
        //        [[CBLManager sharedInstance] doAsync:^{
        content = [[user attachmentNamed:@"avatar"] content];
        
        //            dispatch_async(dispatch_get_main_queue(), ^{
        //                NSLog(@"We should have the image content now: %@", content);
        UIImage *image = [UIImage imageWithData:content];
        NSLog(@"Where is this image: %@", image);
        cell.imageView.image = [UIImage imageWithData:content];
        //            });
        //        }];
    } else {
        NSLog(@"We don't have a picture: %@", user.document.properties);
        NSLog(@"Attachments: %@", user.attachmentNames);
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}
- (WSMUser *) userForIndexPath: (NSIndexPath *) path {
    return WSMUserManager.sharedInstance.nearbyUsers[path.row];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            [self performSegueWithIdentifier:@"userProfile"
                                      sender:[self userForIndexPath:indexPath]];
            break;
            
        default: break;
    }
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"userProfile"]) {
        [segue.destinationViewController setUser:sender];
    }
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
