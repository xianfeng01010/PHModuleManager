//
//  PHModuleLifeManager+AppDelegate.h
//  PHModuleManager
//
//  Created by xinph on 2023/7/4.
//

#import "PHModuleLifeManager.h"
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
#import <UserNotifications/UserNotifications.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface PHModuleLifeManager (AppDelegate)

#pragma mark - AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

- (void)applicationWillResignActive:(UIApplication *)application;

- (void)applicationDidEnterBackground:(UIApplication *)application;

- (void)applicationWillEnterForeground:(UIApplication *)application;

- (void)applicationDidBecomeActive:(UIApplication *)application;

- (void)applicationWillTerminate:(UIApplication *)application;

#pragma mark - Notification
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
/// iOS10新增：处理前台收到通知的代理方法
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler API_AVAILABLE(ios(10.0));

/// iOS10新增：处理后台点击通知的代理方法
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler API_AVAILABLE(ios(10.0));
#endif

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification;

#pragma mark - Active
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler API_AVAILABLE(ios(9.0));

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * __nullable restorableObjects))restorationHandler;

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler API_DEPRECATED("Use a BGAppRefreshTask in the BackgroundTasks framework instead", ios(7.0, 13.0), tvos(11.0, 13.0));

#pragma mark - OpenURL
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options API_AVAILABLE(ios(9.0));

@end

NS_ASSUME_NONNULL_END
