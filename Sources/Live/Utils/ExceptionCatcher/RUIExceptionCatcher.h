//
//  RUIExceptionCatcher.h
//  ReactantLiveUI
//
//  Created by Tadeas Kriz on 13/04/2018.
//

#import <Foundation/Foundation.h>

@interface RUIExceptionCatcher: NSObject

+(nullable id)catchExceptionIn:(__attribute__((noescape)) id (^)(void))block error:(NSError* _Nullable*_Nullable)errorPtr;

@end
