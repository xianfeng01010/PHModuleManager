//
//  PHMediator.h
//  PHModuleManager
//
//  Created by xinph on 2023/7/3.
//

/**
 * 一个scheme链接应由这几部分组成 scheme://host/path?query，其中
 * Scheme:代表公司，例如：腾讯为：tencent://
 * Host:代表对于公司的产品线，例如：腾讯公司下的微信app为：wechat;腾讯公司下的qq app为：qq
 * Path:代表产品线下具体的业务线，例如：腾讯微信下的聊天：chat, 资讯：news
 * 同时Path这部分也可以定位到具体的页面
 * 完整的scheme链接：
 * tencent://wechat/news/shipin?id=245&cityid=201
 * 远程方法命名规则，需要与Path去除@“/”与@“.”,字符串保持一致
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PHMediatorError){
    PHMediatorErrorParam = 10,
};


FOUNDATION_EXPORT NSString * const PHMediatorSwiftTargetModuleName;

/// schema路由跳转支持
@interface PHMediator : NSObject

+ (instancetype)sharedInstance;

/// 远程调用
/// @param url url 如果url中包含特殊字符比如中文要先encode
/// @Example    [PHMediatorShared bptRouteOpenUrl:@"bitauto.yicheapp://yicheapp/BPCarModelService/bpc_openUsedCarListWithParam?serialId=212421"];
- (nullable id)openUrl:(NSString *)url;

/// 远程调用
/// @param url url
/// @param completion 方法执行的回调
- (nullable id)openUrl:(NSString *)url completion:(nullable void (^)(NSDictionary * _Nullable result))completion;

/// 本地调用
/// @param targetName 类名
/// @param actionName 方法名
/// @param params 方法参数
/// @param shouldCacheTarget 是否缓存对应的类 默认NO
- (nullable id)performTarget:(NSString *)targetName action:(NSString *)actionName params:(nullable NSDictionary *)params shouldCacheTarget:(BOOL)shouldCacheTarget;

@end

NS_ASSUME_NONNULL_END
