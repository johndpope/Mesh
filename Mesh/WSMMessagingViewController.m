//
//  WSMMessagingViewController.m
//  Mesh
//
//  Created by Cristian Monterroza on 8/23/14.
//  Copyright (c) 2014 wrkstrm. All rights reserved.
//

#import "WSMMessagingViewController.h"

@interface WSMMessagingViewController ()

@property (strong, nonatomic) NSMutableArray *dataSource;

@end

@implementation WSMMessagingViewController



- (void)viewDidLoad;
{
    [super viewDidLoad];

    self.tableView.dataSource = (id <UITableViewDataSource>) self;
//    self.tableView.dataSource = (id <UITableViewDataSource>) self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 1;
}

- (void)messageInputView:(SOMessageInputView *)inputView didSendMessage:(NSString *)message;
{
    NSLog(@"sdfjalsdkfjsldkfjlsdkfjsdl");
    NSLog(@"sdfjalsdkfjsldkfjlsdkfjsdl");
    NSLog(@"sdfjalsdkfjsldkfjlsdkfjsdl");
    NSLog(@"sdfjalsdkfjsldkfjlsdkfjsdl");
    NSLog(@"sdfjalsdkfjsldkfjlsdkfjsdl");
    NSLog(@"sdfjalsdkfjsldkfjlsdkfjsdl");
    NSLog(@"sdfjalsdkfjsldkfjlsdkfjsdl");
    NSLog(@"sdfjalsdkfjsldkfjlsdkfjsdl");
    NSLog(@"sdfjalsdkfjsldkfjlsdkfjsdl");
    NSLog(@"sdfjalsdkfjsldkfjlsdkfjsdl");
    
    
}

@end
