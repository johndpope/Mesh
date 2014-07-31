//
//  WSMAppDelegate.h
//  Mesh
//
//  Created by Cristian Monterroza on 7/17/14.
//
//


#if TARGET_OS_IPHONE
@interface WSMUIAppDelegate (WSMUtilties)
#else
@interface WSMNSAppDelegate (WSMUtilties)
#endif


+ (NSString *)ver;

@end
