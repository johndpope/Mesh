//
//  WSMLocalUserViews.m
//  Mesh
//
//  Created by Cristian Monterroza on 8/24/14.
//  Copyright (c) 2014 wrkstrm. All rights reserved.
//

#import "WSMLocalUserViews.h"

NSString *const kWSMViewEncounteredUserView = @"encounteredUserView";

@implementation WSMLocalUserViews
#define defaultUserUUID @"defaultUserUUID"

+ (NSDictionary *)instanceVariablesForViewNamed:(NSString *)name {
    if (name == kWSMViewEncounteredUserView) {
        WSMUser *user = [WSMUser defaultUser];
        if (user) {
            return @{defaultUserUUID : user.docID};
        }
    }
    return nil;
}

+ (void)setMapBlockForView:(CBLView *)view instanceVariables:(NSDictionary *)variables {
    NSLog(@"This gets called.");
    if ([view.name isEqualToString: kWSMViewEncounteredUserView]) {
        NSLog(@"We have the view name.");
        NSString *userUUID = variables[defaultUserUUID];
        NSLog(@"UserUUID = %@", userUUID);
        NSLog(@"View: %@", view);
        [view setMapBlock:^(NSDictionary *doc, CBLMapEmitBlock emit) {
            NSLog(@"We set the map block.");
            NSString *docMapID = doc[@"_id"];
            if (![userUUID isEqualToString:docMapID]) {
                emit(doc[@"id"], doc[@"username"]);
            }
            NSLog(@"Whaaat.");
        } version:@"v0.1"];
    }
}

+ (NSTimeInterval)nextVersionForView:(NSString *)name {
    return 0;
}

@end
