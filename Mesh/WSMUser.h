//
//  WSMUser.h
//  Mesh
//
//  Created by Cristian Monterroza on 7/26/14.
//  Copyright (c) 2014 wrkstrm. All rights reserved.
//

#import "WSMModel.h"

#define localUsersDB @"local_users"
#define defaultUserDocument @"default_user"
#define defaultUserProperty @"userID"


@interface WSMUser : WSMModel

@property (nonatomic, strong) NSString *username;

+ (WSMUser *)defaultUser;

+ (void)setDefaultUser:(WSMUser *)user;

+ (WSMUser *)createDefaultUserWithProperties:(NSDictionary *)properties;

+ (WSMUser *)userWithProperties:(NSDictionary *)properties;

+ (WSMUser *)existingUserWithID:(NSString *)userID;

- (void)addParams:(NSDictionary *)params;

- (NSString *)localDatabaseName;

@end
