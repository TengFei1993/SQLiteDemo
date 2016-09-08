// .h
#define singleton_interface(class) + (instancetype)shared##class;

// .m
#define singleton_implementation(class) \
static class *_instance; \
\
+ (id)allocWithZone:(struct _NSZone *)zone \
{ \
    static dispatch_once_t onceToken; \
    dispatch_once(&onceToken, ^{ \
        _instance = [super allocWithZone:zone]; \
    }); \
\
    return _instance; \
} \
- (instancetype) init\
{\
    static dispatch_once_t onceToken;\
    dispatch_once(&onceToken, ^{\
        _instance = [super init];\
    });\
    return _instance;\
}\
\
+ (instancetype)shared##class \
{ \
    if (_instance == nil) { \
        _instance = [[class alloc] init]; \
    } \
\
    return _instance; \
}\
+ (id) copyWithZone:(struct _NSZone*)zone\
{\
    return _instance;\
}\
\
+ (id) mutablecopyWithZone:(struct _NSZone*)zone\
{\
    return _instance;\
}
