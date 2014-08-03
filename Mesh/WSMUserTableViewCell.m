//
//  WSUserTableViewCell.m
//  Mesh
//
//  Created by Cristian Monterroza on 7/29/14.
//  Copyright (c) 2014 daheins. All rights reserved.
//

#import "WSMUserTableViewCell.h"

@implementation WSMUserTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setupForUser:(WSMUser *)user {
    self.textLabel.text = user.username;
    self.detailTextLabel.text = @"Hi!";
    
    NSData *content;
    content = [[user attachmentNamed:@"avatar"] content];
    
    if (!content) {
        NSLog(@"We don't have a picture: %@", user.document.properties);
        NSLog(@"Attachments: %@", user.attachmentNames);
    }
    self.imageView.image = [UIImage imageWithData:content];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
