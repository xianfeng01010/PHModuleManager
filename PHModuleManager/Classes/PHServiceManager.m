//
//  PHServiceManager.m
//  PHModuleManager
//
//  Created by xinph on 2023/7/4.
//

#import "PHServiceManager.h"

#define PHServiceLOCK(...) dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER); \
__VA_ARGS__; \
dispatch_semaphore_signal(_lock);

@interface PHServiceManager ()
@property (nonatomic, strong) NSMutableDictionary *customMapper;
@property (nonatomic, strong) NSMutableDictionary <NSString *, id> *cache;
@end

@implementation PHServiceManager{
    dispatch_semaphore_t _lock;
}

#pragma mark - Public
+ (instancetype)sharedManager {
    static PHServiceManager *sharedManager = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedManager = [[PHServiceManager alloc] init];
        sharedManager.cache = [NSMutableDictionary dictionary];
        sharedManager->_lock = dispatch_semaphore_create(1);
    });
    return sharedManager;
}

- (id)createService:(Protocol *)aProtocol {
    return [self createService:aProtocol shouldCache:YES];
}

- (id)createService:(Protocol *)aProtocol shouldCache:(BOOL)shouldCache {
    if (!aProtocol) {
        return nil;
    }
    
    NSString *protocolStr = NSStringFromProtocol(aProtocol);
    PHServiceLOCK(id intance = self.cache[protocolStr]);
    if (shouldCache && intance) {
        return intance;
    }
    Class serviceClass = [self tryMapServiceClassWithProtocol:aProtocol];
    if (!serviceClass) {
        // BPCarModelProtocol -> BPCarModelService
        NSString *serviceClassString = [protocolStr stringByReplacingOccurrencesOfString:@"Protocol" withString:@"Service"];
        serviceClass = NSClassFromString(serviceClassString);
    }
    
    if (!serviceClass) {
        NSLog(@"❌❌❌PHServiceManager未匹配到对应的Service-%@", protocolStr);
        NSAssert1(!self.safeMode, @"PHServiceManager未匹配到对应的Service-%@", protocolStr);
        return nil;
    }
    
    id serviceInstance = [[serviceClass alloc] init];
    if (serviceInstance && [serviceInstance conformsToProtocol:aProtocol]) {
        if (shouldCache) {
            PHServiceLOCK(self.cache[protocolStr] = serviceInstance;)
        }
        return serviceInstance;
    } else {
        NSLog(@"❌❌❌PHServiceManager未遵守协议-%@", protocolStr);
        NSAssert1(!self.safeMode, @"PHServiceManager 未遵守协议-%@", protocolStr);
        return nil;
    }
}

- (void)customMapWithProtocol:(Protocol *)protocol service:(Class)service {
    PHServiceLOCK([self.customMapper setObject:NSStringFromClass(service) forKey:NSStringFromProtocol(protocol)];
                   [self.cache removeObjectForKey:NSStringFromProtocol(protocol)];);
}

- (void)customProtocolServiceMapWithItems:(NSDictionary<NSString *, NSString *> *)items {
    PHServiceLOCK([self.customMapper addEntriesFromDictionary:items];
                   [self.cache removeObjectsForKeys:items.allKeys];);
}

#pragma mark - Private
- (Class)tryMapServiceClassWithProtocol:(Protocol *)aProtocol {
    PHServiceLOCK(NSString *mapClassString = self.customMapper[NSStringFromProtocol(aProtocol)];);
    return NSClassFromString(mapClassString);
}

#pragma mark - Getter
- (NSMutableDictionary *)customMapper {
    if (!_customMapper) {
        _customMapper = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    return _customMapper;
}

// 对于调用未实现的协议方法会崩溃，解决方法：1.service进行空实现 2.service的实现中增加消息转发的宏进行转发 3.添加一个基类service，在基类里面做消息转发
//#define AvoidExceptionIMP \
//- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector { \
//    if ([self respondsToSelector:aSelector]) { \
//        return [super methodSignatureForSelector:aSelector]; \
//    } \
//    return [NSMethodSignature signatureWithObjCTypes:"v@:"]; \
//} \
//- (void)forwardInvocation:(NSInvocation *)invocation { \
//    NSLog(@"❌❌❌未匹配的对应的实现-%@", NSStringFromSelector(invocation.selector)); \
//}

@end
