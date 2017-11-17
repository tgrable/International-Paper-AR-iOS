//
//  AppDelegate.m
//  InternationalPaper
//
//  Created by Timothy C Grable on 8/20/15.
//  Copyright (c) 2015 Trekk Design. All rights reserved.
//

#import "AppDelegate.h"
#import <sys/utsname.h>

//DeviceList
#define HARDWARE @{@"i386": @"Simulator",@"x86_64": @"Simulator",@"iPod1,1": @"iPod Touch",@"iPod2,1": @"iPod Touch 2nd Generation",@"iPod3,1": @"iPod Touch 3rd Generation",@"iPod4,1": @"iPod Touch 4th Generation",@"iPhone1,1": @"iPhone",@"iPhone1,2": @"iPhone 3G",@"iPhone2,1": @"iPhone 3GS",@"iPhone3,1": @"iPhone 4",@"iPhone4,1": @"iPhone 4S",@"iPhone5,1": @"iPhone 5",@"iPhone5,2": @"iPhone 5",@"iPhone5,3": @"iPhone 5c",@"iPhone5,4": @"iPhone 5c",@"iPhone6,1": @"iPhone 5s",@"iPhone6,2": @"iPhone 5s",@"iPad1,1": @"iPad",@"iPad2,1": @"iPad 2",@"iPad3,1": @"iPad 3rd Generation ",@"iPad3,4": @"iPad 4th Generation ",@"iPad2,5": @"iPad Mini",@"iPad4,4": @"iPad Mini 2nd Generation - Wifi",@"iPad4,5": @"iPad Mini 2nd Generation - Cellular",@"iPad4,1": @"iPad Air 5th Generation - Wifi",@"iPad4,2": @"iPad Air 5th Generation - Cellular",@"iPad6,3" : @"iPad Pro", @"iPhone7,1": @"iPhone 6 Plus",@"iPhone7,2": @"iPhone 6", @"iPhone8,1": @"iPhone 6s", @"iPhone8,2": @"iPhone 6s Plus", @"iPhone8,3": @"iPhone SE (GSM+CDMA)", @"iPhone8,4": @"iPhone SE (GSM)", @"iPhone9,1": @"iPhone 7", @"iPhone9,2": @"iPhone 7 Plus", @"iPhone9,3": @"iPhone 7", @"iPhone9,4": @"iPhone 7 Plus", @"iPhone10,1": @"iPhone 8", @"iPhone10,2": @"iPhone 8 Plus", @"iPhone10,3": @"iPhone X", @"iPhone10,4": @"iPhone 8", @"iPhone10,5": @"iPhone 8 Plus", @"iPhone10,6": @"iPhone X Plus", @"iPad6,4" : @"iPad Pro", @"iPad6,7" : @"iPad Pro", @"iPad6,8" : @"iPad Pro", @"iPad6,11" : @"iPad (2017)", @"iPad6,12" : @"iPad (2017)", @"iPad7,1" : @"iPad Pro 2G", @"iPad7,2" : @"iPad Pro 2G", @"iPad7,3" : @"iPad Pro 10.5-inch", @"iPad7,4" : @"iPad Pro 10.5-inch"}

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (NSString *)platformType {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *device = [HARDWARE objectForKey:[NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding]];
    return device;
}

@end
