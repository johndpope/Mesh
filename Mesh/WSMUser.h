//
//  WSMUser.h
//  Mesh
//
//  Created by Cristian Monterroza on 7/26/14.
//  Copyright (c) 2014 daheins. All rights reserved.
//

#import "WSMModel.h"

@interface WSMUser : WSMModel

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *facebook;
@property (nonatomic, strong) NSString *twitter;

+ (WSMUser *)defaultUser;

+ (void)setDefaultUser:(WSMUser *)user;

+ (WSMUser *)createDefaultUserWithProperties:(NSDictionary *)properties;

+ (WSMUser *)userWithProperties:(NSDictionary *)properties;

+ (WSMUser *)existingUserWithID:(NSString *)userID;

- (void)addParams:(NSDictionary *)params;

- (NSString *)localDatabaseName;

@end
