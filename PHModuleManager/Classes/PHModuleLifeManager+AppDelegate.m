//
//  PHModuleLifeManager+AppDelegate.m
//  PHModuleManager
//
//  Created by xinph on 2023/7/4.
//

#import "PHModuleLifeManager+AppDelegate.h"

@implementation PHModuleLifeManager (AppDelegate)

#pragma mark - AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self enumerateRegistedModuleUsingBlock:^(id<PHModuleProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(application:didFinishLaunchingWithOptions:)]) {
            [obj application:application didFinishLaunchingWithOptions:launchOptions];
        }
    }];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [self enumerateRegistedModuleUsingBlock:^(id<PHModuleProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(applicationWillResignActive:)]) {
            [obj applicationWillResignActive:application];
        }
    }];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self enumerateRegistedModuleUsingBlock:^(id<PHModuleProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(applicationDidEnterBackground:)]) {
            [obj applicationDidEnterBackground:application];
        }
    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [self enumerateRegistedModuleUsingBlock:^(id<PHModuleProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(applicationWillEnterForeground:)]) {
            [obj applicationWillEnterForeground:application];
        }
    }];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self enumerateRegistedModuleUsingBlock:^(id<PHModuleProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(applicationDidBecomeActive:)]) {
            [obj applicationDidBecomeActive:application];
        }
    }];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [self enumerateRegistedModuleUsingBlock:^(id<PHModuleProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(applicationWillTerminate:)]) {
            [obj applicationWillTerminate:application];
        }
    }];
}

#pragma mark - AppNotification
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [self enumerateRegistedModuleUsingBlock:^(id<PHModuleProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(application:didRegisterForRemoteNotificationsWithDeviceToken:)]) {
            [obj application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
        }
    }];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [self enumerateRegistedModuleUsingBlock:^(id<PHModuleProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(application:didReceiveRemoteNotification:)]) {
            [obj application:application didReceiveRemoteNotification:userInfo];
        }
    }];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [self enumerateRegistedModuleUsingBlock:^(id<PHModuleProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)]) {
            [obj application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
        }
    }];
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
/// iOS10新增：处理前台收到通知的代理方法
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler API_AVAILABLE(ios(10.0)) {
    [self enumerateRegistedModuleUsingBlock:^(id<PHModuleProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(userNotificationCenter:willPresentNotification:withCompletionHandler:)]) {
            [obj userNotificationCenter:center willPresentNotification:notification withCompletionHandler:completionHandler];
        }
    }];
}

/// iOS10新增：处理后台点击通知的代理方法
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler API_AVAILABLE(ios(10.0)) {
    [self enumerateRegistedModuleUsingBlock:^(id<PHModuleProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:)]) {
            [obj userNotificationCenter:center didReceiveNotificationResponse:response withCompletionHandler:completionHandler];
        }
    }];
}
#endif

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [self enumerateRegistedModuleUsingBlock:^(id<PHModuleProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(application:didReceiveLocalNotification:)]) {
            [obj application:application didReceiveLocalNotification:notification];
        }
    }];
}


#pragma mark - Active
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler API_AVAILABLE(ios(9.0)) {
    [self enumerateRegistedModuleUsingBlock:^(id<PHModuleProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(application:performActionForShortcutItem:completionHandler:)]) {
            [obj application:application performActionForShortcutItem:shortcutItem completionHandler:completionHandler];
        }
    }];
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler {
    __block BOOL shouldContinue = YES;
    [self enumerateRegistedModuleUsingBlock:^(id<PHModuleProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(application:continueUserActivity:restorationHandler:)]) {
            shouldContinue = shouldContinue && [obj application:application continueUserActivity:userActivity restorationHandler:restorationHandler];
        }
    }];
    return shouldContinue;
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler API_DEPRECATED("Use a BGAppRefreshTask in the BackgroundTasks framework instead", ios(7.0, 13.0), tvos(11.0, 13.0)) {
    [self enumerateRegistedModuleUsingBlock:^(id<PHModuleProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(application:performFetchWithCompletionHandler:)]) {
            [obj application:application performFetchWithCompletionHandler:completionHandler];
        }
    }];
}

#pragma mark - OpenURL
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options API_AVAILABLE(ios(9.0)) {
    __block BOOL shouldOpen = NO;
    [self enumerateRegistedModuleUsingBlock:^(id<PHModuleProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(application:openURL:options:)]) {
            shouldOpen = [obj application:app openURL:url options:options];
        }
        if (shouldOpen) *stop = YES;
    }];
    return shouldOpen;
}

@end
