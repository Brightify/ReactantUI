//
//  RUIExceptionCatcher.h
//  ReactantLiveUI
//
//  Created by Tadeas Kriz on 13/04/2018.
//

#import <Foundation/Foundation.h>

@interface RUIExceptionCatcher: NSObject

+(nullable id)catchExceptionIn:(nonnull __attribute__((noescape)) id _Nonnull (^)(void))block error:(NSError* _Nullable*_Nullable)errorPtr;

@end
