//
//  AppDelegate.m
//  CJWCoreTextDemo
//
//  Created by Jiawei Dong on 2020/1/6.
//  Copyright © 2020 ai.cc. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "JWCrashReportCore.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
//    #if DEBUG
//    //or oc
//    [[NSBundle bundleWithPath:@"/Applications/InjectionIII.app/Contents/Resources/iOSInjection.bundle"] load];
    
//    #endif
//    [[JWCrashReportCore sharedInstance] thaw];

    self.window = [UIWindow new];
    [self.window makeKeyAndVisible];
    ViewController *vc = [[ViewController alloc]init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = nav;
    
    return YES;
}


@end
