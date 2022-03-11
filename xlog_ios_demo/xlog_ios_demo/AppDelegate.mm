//
//  AppDelegate.m
//  xlog_ios_demo
//
//  Created by 逸风 on 2022/3/5.
//

#import "AppDelegate.h"
#import "JRXlogManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //这里没有登录，应该登录成功后 重新close 及初始化一遍
    //should login success do this code
    [[JRXlogManager shared] closeXlog];
    [[JRXlogManager shared] initXlog:[@"test_xlog_userId" UTF8String] pathName:XlogDirName];
    
    [[JRXlogManager shared] infoLogWithTag:JRDebugMessage Content:@"App init()"];
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
