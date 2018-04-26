//
//  RUIExceptionCatcher.m
//  ReactantLiveUI
//
//  Created by Tadeas Kriz on 13/04/2018.
//

#import "RUIExceptionCatcher.h"

@implementation RUIExceptionCatcher

+(nullable id)catchExceptionIn:(nonnull id (^)(void))block error:(NSError**)errorPtr {
    @try {
        return block();
    }
    @catch (id exception) {
        NSError* error = [[NSError alloc] initWithDomain: @"org.brightify.reactantui"
                                                    code: 1
                                                userInfo: @{ @"exception": exception }];
        *errorPtr = error;
        return nil;
    }

}

@end
