//
//  AppDelegate.m
//  Simple Caculator
//
//  Created by 吴韬 on 17/2/9.
//  Copyright © 2017年 吴韬. All rights reserved.
//

#import "AppDelegate.h"
#import "WTIMainViewController.h"
#import "WTICaculatorStore.h"
#import "Setting.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey: everLunchedKey]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey: everLunchedKey];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey: firstLunchKey];
    }
    else{
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey: firstLunchKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    self.window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    WTIMainViewController *mvc = [[WTIMainViewController alloc]
                                  initWithNibName: @"WTIMainViewController"
                                  bundle: nil];
    
    self.window.rootViewController = mvc;
    self.window.backgroundColor = [UIColor clearColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [[WTICaculatorStore shareString] saveData];
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

@end
