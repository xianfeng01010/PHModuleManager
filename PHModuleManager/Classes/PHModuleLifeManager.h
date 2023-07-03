//
//  PHModuleLifeManager.h
//  PHModuleManager
//
//  Created by xinph on 2023/7/3.
//

#import <Foundation/Foundation.h>
#import "PHModuleProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/// 组件生命周期函数调用管理
@interface PHModuleLifeManager : NSObject

+ (instancetype)sharedManager;

/// 遍历所有已注册的组件
/// @param block 回调
- (void)enumerateRegistedModuleUsingBlock:(void (NS_NOESCAPE ^)(id<PHModuleProtocol> obj, NSUInteger idx, BOOL *stop))block;

@end


NS_ASSUME_NONNULL_END
