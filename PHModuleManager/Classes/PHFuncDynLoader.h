//
//  PHFuncDynLoader.h
//  PHModuleManager
//
//  Created by xinph on 2023/7/3.
//

/**
 无侵入函数指针动态调用器 可以直接调用预先注入到macho DATA的任意函数指针
 
 使用场景：
 1）对于部分函数调用，可能比较消耗资源，又想在app启动后较早的调用，但是不想放在appDelegate的生命周期回调内（依赖注入方式）
 2）统一调度函数的调用，便于函数的耗时统计（用作+ load的替换，可以衡量函数+load耗时）
 （支持静态库的集成方式）（非framework）
 
 Sample Code:
        
 // 1. 编译期注入（可以指定优先级，值越大优先级越高）
 PH_DYN_LOADER_HOMED {
    // code...
    NSLog(@"将函数实现代码注入到'homed'，在'homed'阶段此函数会被调用");
 }
    
 // 2.调用
 // 在首页控制器执行注入到'homed'的函数
 - (void)viewDidLoad {
    [super viewDidLoad];
    [[PHFuncDynLoader sharedInstance] exeFucForKey:PH_STAGE_HOMED];
 }
 
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (*func_def)(void);

struct ph_loader_func_data {
    char        *key;       ///< 标识调用阶段
    uint32_t    priority;   ///< 优先级
    func_def    ptr;        ///< 函数地址
};

#define PH_DYN_LOADER_FUNC(stage, priority) \
static void _ph_func_##stage##_##priority##_0(void); \
 \
__attribute__((used, section("__DATA," #stage ))) static const struct ph_loader_func_data __ph_loader_##stage##_##priority##_0 = (struct ph_loader_func_data){#stage, priority, (void *)(&_ph_func_##stage##_##priority##_0)}; \
 \
static void _ph_func_##stage##_##priority##_0(void)

#define PH_DYN_LOADER_KEY_LAUNCH_0         "launch0"
#define PH_DYN_LOADER_KEY_LAUNCH_1         "launch1"
#define PH_DYN_LOADER_KEY_HOME             "home"

#define PH_DYN_LOADER_LAUNCH_0             PH_DYN_LOADER_FUNC(launch0, 500)   // didFinishLaunchingWithOptions刚开始时执行
#define PH_DYN_LOADER_LAUNCH_1             PH_DYN_LOADER_FUNC(launch1, 500)   // didFinishLaunchingWithOptions将完成时执行
#define PH_DYN_LOADER_HOME                 PH_DYN_LOADER_FUNC(home, 500)      // 执行的时机比较靠后，启动后在首页阶段执行

/// 无侵入动态调用器 可以直接调用预先注入到macho DATA段的函数指针
@interface PHFuncDynLoader : NSObject

+ (instancetype)sharedInstance;

/// 调用注入到某个key的所有函数指针
/// @param key 已经通过宏注入到macho的key，编译期注册
/// @example [[PHFuncDynLoader sharedInstance] exeFucForKey:PH_DYN_LOADER_KEY_LAUNCH_0];
- (void)exeFucForKey:(char *)key;

@end


NS_ASSUME_NONNULL_END
