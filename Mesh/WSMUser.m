//
//  WSMUser.m
//  Mesh
//
//  Created by Cristian Monterroza on 7/26/14.
//  Copyright (c) 2014 daheins. All rights reserved.
//

#import "WSMUser.h"

@implementation WSMUser

#define localUsersDB @"local_users"
#define defaultUserDocument @"default_user"
#define defaultUserProperty @"userID"

@dynamic username;
@dynamic facebook;
@dynamic twitter;

+ (WSMUser *)defaultUser {
    NSError *error;
    CBLDatabase *db = [[CBLManager sharedInstance] databaseNamed:localUsersDB error:&error];
    CBLDocument *doc = [db documentWithID:defaultUserDocument];
    if (doc[defaultUserProperty]) {
        CBLDocument *userDocument = [db documentWithID:doc[defaultUserProperty]];
        if (userDocument) {
            WSMUser *user = [WSMUser modelForDocument:userDocument];
            if (user) {
                [user registerLocalDatabaseViews];
                return user;
            }
        }
    }
    return nil;
}

+ (WSMUser *)createDefaultUserWithProperties:(NSDictionary *)properties {
    NSMutableDictionary *mutableProperties = properties.mutableCopy;
    NSLog(@"Creating a user with these properties: %@", mutableProperties);
    NSString *userID = mutableProperties[@"_id"];
    NSAssert(userID, @"ID Property is necessary!");
    //Create a brand new Default User
    CBLDatabase *usersDB = [[CBLManager sharedInstance] databaseNamed:localUsersDB
                                                                error:nil];
    CBLDocument *userDocument = [usersDB documentWithID:userID];
    
    [mutableProperties removeObjectForKey:@"_id"];
    [userDocument putProperties:mutableProperties error:nil];
    
    WSMUser *newDefaultUser = [[WSMUser alloc] initWithDocument:userDocument];
    [newDefaultUser save:nil];
    
    [WSMUser setDefaultUser:newDefaultUser];
    return newDefaultUser;
}

+ (WSMUser *)userWithProperties:(NSDictionary *)properties {
    NSMutableDictionary *mutableProperties = properties.mutableCopy;
    NSAssert(mutableProperties[@"_id"], @"ID Property is necessary!");
    //Create a brand new Default User
    __block WSMUser *newUser;
    NSData *contents;
    if (mutableProperties[@"avatar"]) {
        NSLog(@"We got avatar data!");
        contents = [[NSData alloc] initWithBase64EncodedString:mutableProperties[@"avatar"]
                                                       options:NSDataBase64DecodingIgnoreUnknownCharacters];
        [mutableProperties removeObjectForKey:@"avatar"];
    } else {
        NSLog(@"We DID NOT avatar data!");
    }
    
    dispatch_semaphore_t putSemaphore = dispatch_semaphore_create(0);
    [[CBLManager sharedInstance] doAsync:^{
        CBLDatabase *usersDB = [[CBLManager sharedInstance] databaseNamed:localUsersDB
                                                                    error:nil];
        CBLDocument *userDocument = [usersDB documentWithID:mutableProperties[@"_id"]];
        
        [mutableProperties removeObjectForKey:@"_id"];
        if (userDocument.properties) {
            CBLUnsavedRevision *newRevision = userDocument.newRevision;
            newRevision.properties = mutableProperties;
            [newRevision save:nil];
        } else {
            [userDocument putProperties:mutableProperties error:nil];
        }
        newUser = [[WSMUser alloc] initWithDocument:userDocument];
        if (contents) {
            NSLog(@"We get image content!");
            [newUser setAttachmentNamed:@"avatar" withContentType:@"image/jpeg" content:contents];
        } else {
            NSLog(@"For some reasonwe don't get the contents...");
        }
        
        [newUser save:nil];
        dispatch_semaphore_signal(putSemaphore);
    }];
    dispatch_semaphore_wait(putSemaphore, DISPATCH_TIME_FOREVER);
    return newUser;
}

+ (WSMUser *)existingUserWithID:(NSString *)userID {
    NSError *error;
    CBLManager *sharedCBLManager = [CBLManager sharedInstance];
    CBLDatabase *allUserDatabases = [sharedCBLManager databaseNamed:localUsersDB
                                                              error:&error];
    NSAssert(!error, @"Must provide a local_users database");
    CBLDocument *userDocument = [allUserDatabases existingDocumentWithID:userID];
    return userDocument ? [WSMUser modelForDocument: userDocument]: nil;
}

+ (void)setDefaultUser:(WSMUser *)user {
    NSError *error;
    CBLManager *sharedCBLManager = [CBLManager sharedInstance];
    CBLDatabase *db = [sharedCBLManager databaseNamed:localUsersDB
                                                error:&error];
    
    CBLUnsavedRevision *doc = [[db documentWithID:defaultUserDocument] newRevision];
    
    doc[defaultUserProperty] = user.docID;
    [doc save:&error];
    
    NSAssert(!error, @"Default user not saved!");
    
    [user registerLocalDatabaseViews];
}

- (void)registerLocalDatabaseViews {
    CBLDatabase *database = [[CBLManager sharedInstance] databaseNamed:self.localDatabaseName
                                                                 error:nil];
    // Register stuff...
}

- (NSString *)localDatabaseName {
    return [NSString stringWithFormat:@"u_%@", self.document.documentID.lowercaseString];
}

- (void)addParams:(NSDictionary *)params {
    CBLUnsavedRevision *newRev = self.document.newRevision;
    [newRev setProperties:params.mutableCopy];
    [newRev save:nil];
}

@end
