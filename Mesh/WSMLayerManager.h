//
//  WSMLayerManager.h
//  rendezvous
//
//  Created by Cristian Monterroza on 7/24/14.
//
//

#import "WSMUserManager.h"

@interface WSMLayerManager : NSObject <WSMCapabilityProvider, LYRClientDelegate>

+ (instancetype) sharedInstance; 

@end
