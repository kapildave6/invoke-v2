#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Run `block`, catching any Objective-C exception (NSException) it raises. Returns the exception's
/// reason — or its name if there is no reason — when one is caught, or nil if the block completes
/// normally.
///
/// Swift's `do/catch` only catches Swift `Error`s, NOT Objective-C `NSException`s. AppKit/Foundation
/// (e.g. activating an NSLayoutConstraint across views with no common ancestor, an unrecognized
/// selector, a bad SF Symbol) throw NSExceptions, which otherwise propagate past Swift and abort the
/// process. Wrapping the risky work in this lets Swift recover and show a fallback instead of crashing.
NSString * _Nullable InvokeCatchException(NS_NOESCAPE void (^block)(void));

NS_ASSUME_NONNULL_END
