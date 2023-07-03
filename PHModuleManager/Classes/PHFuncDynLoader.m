//
//  PHFuncDynLoader.m
//  PHModuleManager
//
//  Created by xinph on 2023/7/3.
//

#import "PHFuncDynLoader.h"
#include <mach-o/getsect.h>
#include <mach-o/loader.h>
#include <mach-o/dyld.h>
#include <dlfcn.h>

static NSMutableArray<NSValue *> * getsecdata(char *section) {
    Dl_info info;
    int ret = dladdr("main", &info);
    if(ret == 0){
        // fatal error
    }
    NSMutableArray *arr = [NSMutableArray array];
#ifndef __LP64__
    const struct mach_header *mhp = (struct mach_header*)info.dli_fbase;
    unsigned long size = 0;
    uint32_t *memory = (uint32_t*)getsectiondata(mhp, "__DATA", section, &size);
#else /* defined(__LP64__) */
    const struct mach_header_64 *mhp = (struct mach_header_64*)info.dli_fbase;
    unsigned long size = 0;
    uint64_t *memory = (uint64_t *)getsectiondata(mhp, "__DATA", section, &size);
#endif /* defined(__LP64__) */
    
    struct ph_loader_func_data *datas = (struct ph_loader_func_data *)memory;
    for(unsigned int idx = 0; idx < size/sizeof(struct ph_loader_func_data); ++idx){
        struct ph_loader_func_data data = datas[idx];
        if (data.key && data.ptr) {
            NSValue *value = [NSValue valueWithBytes:&data objCType:@encode(struct ph_loader_func_data)];
            [arr addObject:value];
        }
    }
    return arr;
}

// 兼容动态库，但比较耗时
//static NSMutableArray<NSValue *> * getsecdata2(char *section) {
//    int num = _dyld_image_count();
//    NSMutableArray *arr = [NSMutableArray array];
//    NSString *appBundleName = [NSBundle mainBundle].infoDictionary[@"CFBundleName"];
//    for (int i = 0; i < num; i++) {
//        const char *name = _dyld_get_image_name(i);
//        if (strstr(name, [appBundleName UTF8String]) == NULL) {
//            continue;
//        }
//        const struct mach_header *header = _dyld_get_image_header(i);
//        // printf("%d name: %s\n", i, name);
//
//        Dl_info info;
//        dladdr(header, &info);
//    #ifndef __LP64__
//        const struct mach_header *mhp = (struct mach_header*)info.dli_fbase;
//        unsigned long size = 0;
//        uint32_t *memory = (uint32_t*)getsectiondata(mhp, "__DATA", section, &size);
//    #else /* defined(__LP64__) */
//        const struct mach_header_64 *mhp = (struct mach_header_64*)info.dli_fbase;
//        unsigned long size = 0;
//        uint64_t *memory = (uint64_t *)getsectiondata(mhp, "__DATA", section, &size);
//    #endif /* defined(__LP64__) */
//
//        struct ph_loader_func_data *datas = (struct ph_loader_func_data *)memory;
//        for(unsigned int idx = 0; idx < size/sizeof(struct ph_loader_func_data); ++idx){
//            struct ph_loader_func_data data = datas[idx];
//            if (data.key && data.ptr) {
//                NSValue *value = [NSValue valueWithBytes:&data objCType:@encode(struct ph_loader_func_data)];
//                [arr addObject:value];
//            }
//        }
//    }
//    return arr;
//}


@implementation PHFuncDynLoader {
    NSMutableDictionary<NSString *, NSArray *> *_map;
}

+ (instancetype)sharedInstance {
    static PHFuncDynLoader *instance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        instance = [[PHFuncDynLoader alloc] init];
        instance->_map = [NSMutableDictionary dictionary];
    });
    return instance;
}

- (void)exeFucForKey:(char *)key {
    NSString *sKey = [NSString stringWithCString:key encoding:NSUTF8StringEncoding];
    if (!_map[sKey]) {
        NSMutableArray *mArr = getsecdata(key);
        [mArr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            struct ph_loader_func_data data1; struct ph_loader_func_data data2;
            [obj1 getValue:&data1]; [obj2 getValue:&data2];
            return data1.priority < data2.priority;
        }];
        _map[sKey] = mArr;
    }
    for (NSValue *value in _map[sKey]) {
        struct ph_loader_func_data data;
        [value getValue:&data];
        
        data.ptr();
    }
}

@end
