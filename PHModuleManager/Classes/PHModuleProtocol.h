//
//  PHModuleProtocol.h
//  PHModuleManager
//
//  Created by xinph on 2023/7/4.
//

#import <Foundation/Foundation.h>
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
#import <UserNotifications/UserNotifications.h>
#endif

NS_ASSUME_NONNULL_BEGIN

#define PHModulSecName        "PHMods"
#define PHRegisterModule(name) char * yc_##name##_mod __attribute((used, section("__DATA," PHModulSecName ))) = #name;

// 调用优先级(值越大优先级越高)
typedef NS_ENUM(NSUInteger, PHModulePriority){
    PHModulePriorityLow = 250,
    PHModulePriorityDefault = 500,
    PHModulePriorityHigh = 750,
};

/// 各组件在App的生命周期函数回调的实现
@protocol PHModuleProtocol <NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate>

@optional
/// 组件实现的生命周期函数被调用的优先级（默认：PHModulePriorityDefault）
/// 在Module初始化时被调用
- (NSUInteger)priority;

@end

NS_ASSUME_NONNULL_END
