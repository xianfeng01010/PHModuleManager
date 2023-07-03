//
//  PHMediator.m
//  PHModuleManager
//
//  Created by xinph on 2023/7/3.
//

#import "PHMediator.h"
#import <objc/runtime.h>

#define PHMediatorLOCK(...) dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER); \
__VA_ARGS__; \
dispatch_semaphore_signal(_lock);

#define PHMediatorError(_code, _msg) [NSError errorWithDomain:NSCocoaErrorDomain code:_code userInfo:@{@"message": _msg}]

NSString * const PHMediatorSwiftTargetModuleName = @"PHMediatorSwiftTargetModuleName";

@interface PHMediator ()
@property (nonatomic, strong) NSMutableDictionary *cachedTarget;
@end

@implementation PHMediator {
    dispatch_semaphore_t _lock;
}

#pragma mark - Public
+ (instancetype)sharedInstance {
    static PHMediator *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[PHMediator alloc] init];
        instance.cachedTarget = [[NSMutableDictionary alloc] init];
        instance->_lock = dispatch_semaphore_create(1);
    });
    return instance;
}

- (id)openUrl:(NSString *)url {
    return [[PHMediator sharedInstance] openUrl:url completion:nil];
}

#pragma mark Deprecated End

- (id)openUrl:(NSString *)url completion:(void (^)(NSDictionary * _Nullable))completion {
    if (!url || ![url isKindOfClass:[NSString class]]) return nil;
    
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *URL = [NSURL URLWithString:url];
    if (!URL) return nil;
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:URL.absoluteString];
    [urlComponents.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.value && obj.name) {
            params[obj.name] = [[obj.value stringByRemovingPercentEncoding] stringByRemovingPercentEncoding];
        }
    }];
    
    NSString *actionName = [URL.path stringByReplacingOccurrencesOfString:@"/" withString:@""];
    actionName = [actionName stringByReplacingOccurrencesOfString:@"." withString:@""];
    
    id result = [self performTarget:@"PHMediator" action:actionName params:params shouldCacheTarget:NO];
    if (completion) {
        if (result) {
            completion(@{@"result": result});
        } else {
            completion(nil);
        }
    }
    return result;
}

- (id)performTarget:(NSString *)targetName action:(NSString *)actionName params:(NSDictionary *)params shouldCacheTarget:(BOOL)shouldCacheTarget {
    if (targetName == nil || actionName == nil) {
        return nil;
    }
    
    NSString *swiftModuleName = params[PHMediatorSwiftTargetModuleName];
    
    // Generate target
    NSString *targetClassString = nil;
    if (swiftModuleName.length > 0) {
        targetClassString = [NSString stringWithFormat:@"%@.%@", swiftModuleName, targetName];
    } else {
        targetClassString = [NSString stringWithFormat:@"%@", targetName];
    }
    PHMediatorLOCK(NSObject *target = self.cachedTarget[targetClassString];);
    
    if (target == nil) {
        Class targetClass = NSClassFromString(targetClassString);
        if ([targetClassString isEqualToString:@"PHMediator"]) {
            target = [PHMediator sharedInstance];
        } else {
            target = [[targetClass alloc] init];
        }
    }

    // Generate action
    NSString *actionString;
    if ([actionName rangeOfString:@":" options:NSBackwardsSearch].location != NSNotFound) {
        actionString = [NSString stringWithFormat:@"%@", actionName];
    } else {
        actionString = [NSString stringWithFormat:@"%@:", actionName];
    }
    SEL action = NSSelectorFromString(actionString);
    
    if (target == nil) {
        [self nonRespondsWithTargetString:targetClassString selectorString:actionString originParams:params];
        return nil;
    }
    
    if (shouldCacheTarget) {
        PHMediatorLOCK(self.cachedTarget[targetClassString] = target;);
    }

    if ([target respondsToSelector:action]) {
        return [self safePerformAction:action target:target params:params];
    } else {
        // 这里是处理无响应请求的地方，如果无响应，则尝试调用对应target的notFound方法统一处理
        SEL action = NSSelectorFromString(@"notFound:");
        if ([target respondsToSelector:action]) {
            return [self safePerformAction:action target:target params:params];
        } else {
            [self nonRespondsWithTargetString:targetClassString selectorString:actionString originParams:params];
            PHMediatorLOCK([self.cachedTarget removeObjectForKey:targetClassString];);
            return PHMediatorError(10, @"未找到实现");
        }
    }
}

#pragma mark - Private
- (void)nonRespondsWithTargetString:(NSString *)targetString selectorString:(NSString *)selectorString originParams:(NSDictionary *)originParams {
    SEL action = NSSelectorFromString(@"nonRespondsToSelector:");
    NSObject *target = [[NSClassFromString(@"PHTarget_Nonresponse") alloc] init];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params[@"originParams"] = originParams;
    params[@"targetString"] = targetString;
    params[@"selectorString"] = selectorString;
    
    [self safePerformAction:action target:target params:params];
}

- (id)safePerformAction:(SEL)action target:(NSObject *)target params:(NSDictionary *)params {
    NSMethodSignature* methodSig = [target methodSignatureForSelector:action];
    if(methodSig == nil) {
        return nil;
    }
    const char* retType = [methodSig methodReturnType];

    if (strcmp(retType, @encode(void)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        return nil;
    }

    if (strcmp(retType, @encode(NSInteger)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        NSInteger result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }

    if (strcmp(retType, @encode(BOOL)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        BOOL result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }

    if (strcmp(retType, @encode(CGFloat)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        CGFloat result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }

    if (strcmp(retType, @encode(NSUInteger)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        NSUInteger result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    return [target performSelector:action withObject:params];
#pragma clang diagnostic pop
}

@end

@interface PHTarget_Nonresponse : NSObject @end
@implementation PHTarget_Nonresponse

- (void)nonRespondsToSelector:(NSDictionary *)params {
    NSLog(@"未响应error: %@", params);
}

@end
