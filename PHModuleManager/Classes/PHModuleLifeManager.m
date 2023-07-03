//
//  PHModuleLifeManager.m
//  PHModuleManager
//
//  Created by xinph on 2023/7/3.
//

#import "PHModuleLifeManager.h"
#import <mach-o/getsect.h>
#import <mach-o/loader.h>
#import <mach-o/dyld.h>
#import <dlfcn.h>

@interface PHModuleLifeManager ()
@property (nonatomic, strong) NSMutableArray *modules;
@end

@implementation PHModuleLifeManager

#pragma mark - Public
+ (instancetype)sharedManager {
    static id sharedManager = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedManager = [[PHModuleLifeManager alloc] init];
    });
    return sharedManager;
}

- (void)enumerateRegistedModuleUsingBlock:(void (NS_NOESCAPE ^)(id<PHModuleProtocol> obj, NSUInteger idx, BOOL *stop))block {
    [self.modules enumerateObjectsUsingBlock:block];
}

#pragma mark - Private
- (NSMutableArray *)modules {
    if (!_modules) {
        _modules = allRegistedModules();
    }
    return _modules;
}

static NSMutableArray<id>* allRegistedModules() {
    NSMutableArray<NSString *> *modules = readModuleFromMach(PHModulSecName);
    NSMutableArray *mArr = [NSMutableArray arrayWithCapacity:modules.count];
    for (NSString *moduleName in modules) {
        Class class = NSClassFromString(moduleName);
        id moduleInstance = [[class alloc] init];
        [mArr addObject:moduleInstance];
    }
    [mArr sortUsingComparator:^NSComparisonResult(id<PHModuleProtocol> _Nonnull obj1, id<PHModuleProtocol> _Nonnull obj2) {
        NSUInteger priority1 = PHModulePriorityDefault;
        NSUInteger priority2 = PHModulePriorityDefault;
        if ([obj1 respondsToSelector:@selector(priority)]) {
            priority1 = [obj1 priority];
        }
        if ([obj2 respondsToSelector:@selector(priority)]) {
            priority2 = [obj2 priority];
        }
        return priority1 < priority2;
    }];
    return mArr;
}

static NSMutableArray<NSString *>* readModuleFromMach(char *section) {
    NSMutableArray *modules = [NSMutableArray arrayWithCapacity:50];
    Dl_info info;
    dladdr(readModuleFromMach, &info);
    
#ifndef __LP64__
    const struct mach_header *mhp = (struct mach_header*)info.dli_fbase;
    unsigned long size = 0;
    uint32_t *memory = (uint32_t*)getsectiondata(mhp, "__DATA", section, & size);
#else
    const struct mach_header_64 *mhp = (struct mach_header_64*)info.dli_fbase;
    unsigned long size = 0;
    uint64_t *memory = (uint64_t *)getsectiondata(mhp, "__DATA", section, & size);
#endif
    
    for(unsigned int idx = 0; idx < size/sizeof(void *); ++idx){
        char *string = (char *)memory[idx];
        NSString *str = [NSString stringWithUTF8String:string];
        if (str) {
            [modules addObject:str];
        } else {
            continue;
        }
    }
    return modules;
}

@end
