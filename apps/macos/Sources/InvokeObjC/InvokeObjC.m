#import "InvokeObjC.h"

NSString * _Nullable InvokeCatchException(NS_NOESCAPE void (^block)(void)) {
    @try {
        block();
        return nil;
    }
    @catch (NSException *exception) {
        return exception.reason ?: exception.name ?: @"unknown Objective-C exception";
    }
}
