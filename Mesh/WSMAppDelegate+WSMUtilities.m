//
//  AppDelegate.m
//  Mesh
//
//  Created by Cristian Monterroza on 7/17/14.
//
//

#import "WSMAppDelegate+WSMUtilities.h"

@implementation WSMUIAppDelegate (WSMUtilties)



#pragma mark - AppDelegate Helper Methods

+ (NSString *)ver {
    NSDictionary *info = NSBundle.mainBundle.infoDictionary;
    return [NSString stringWithFormat:@"%@ (Version: %@ Build: %@)",
            info[@"CFBundleName"],
            info[@"CFBundleShortVersionString"],
            info[@"CFBundleVersion"]];
}

+ (NSString *)defaultDatabaseDirectory {
    return  [[[NSBundle mainBundle] bundlePath] stringByAppendingString: @"/Contents/Databases"];
}

@end
