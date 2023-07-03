//
//  PHServiceManager.h
//  PHModuleManager
//
//  Created by xinph on 2023/7/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 组件化-Protocol-Service映射（PHXXXProtocol -> PHXXXService）
@interface PHServiceManager : NSObject

/// Debug 环境调用未实现的协议是否允许Assert， 默认NO
/// @note 设置为YES时，调用未实现的协议会crash，有助于开发阶段的调试
@property (nonatomic, assign) BOOL safeMode;

+ (instancetype)sharedManager;

/// 根据协议创建一个Service (shouldCache:YES)
/// @param aProtocol 协议
- (nullable id)createService:(Protocol *)aProtocol;

/// 根据协议创建一个Service
/// 根据类名自动匹配（PHXXXProtocol -> PHXXXService）
/// @param aProtocol 协议
/// @param shouldCache 是否缓存
- (nullable id)createService:(Protocol *)aProtocol shouldCache:(BOOL)shouldCache;

/// 当默认Protocol:Service的字符串映射不匹配时，使用此方法实现自定义映射
/// 同时也可用于组件大升级时，通过外部开关切换同一个Protocol对应的Service
/// @param protocol 协议
/// @param service 实现
- (void)customMapWithProtocol:(Protocol *)protocol service:(Class)service;

/// 当默认Protocol:Service的字符串映射不匹配时，使用此方法实现自定义批量映射 ()
/// @param items 需要自定义映射的字典
/// @example 比如说在初始化阶段执行
/// [[PHServiceManager sharedManager] customProtocolServiceMapWithItems:@{
/// @"BPYProtocoal": @"BPYService",
/// @"BPYClipProtocoal": @"BPYClipService",
/// }];
- (void)customProtocolServiceMapWithItems:(NSDictionary <NSString *, NSString *> *)items;

@end

NS_ASSUME_NONNULL_END
