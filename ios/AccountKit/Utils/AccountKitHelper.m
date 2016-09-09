/**
 * Copyright 2016 Marcel Piestansky (http://marpies.com)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "AccountKitHelper.h"
#import "AIRAccountKit.h"
#import "AccountKitEvent.h"

@implementation AccountKitHelper {
    AKFAccountKit* mAccountKit;
    UIViewController<AKFViewController>* mPendingLoginViewController;
    NSString* mAuthorizationCode;
}

# pragma mark - Public API

- (id) initWithResponseType:(NSString*) responseType {
    [AIRAccountKit log:@"AccountKitHelper::init"];
    
    self = [super init];
    
    if( self != nil ) {
        if (mAccountKit == nil) {
            mAccountKit = [[AKFAccountKit alloc] initWithResponseType:[self getResponseType:responseType]];
            [AIRAccountKit dispatchEvent:AK_INIT];
        }
    }
    
    return self;
}

# pragma mark - Private API

- (AKFResponseType) getResponseType:(NSString*) responseType {
    if( [responseType isEqualToString:@"accessToken"] ) return AKFResponseTypeAccessToken;
    return AKFResponseTypeAuthorizationCode;
}

# pragma mark - AKFViewControllerDelegate

/*!
 @abstract Called when the login completes with an authorization code response type.
 
 @param viewController the AKFViewController that was used
 @param code the authorization code that can be exchanged for an access token with the app secret
 @param state the state param value that was passed in at the beginning of the flow
 */
- (void)viewController:(UIViewController<AKFViewController> *)viewController didCompleteLoginWithAuthorizationCode:(NSString *)code state:(NSString *)state {
    
}

/*!
 @abstract Called when the login completes with an access token response type.
 
 @param viewController the AKFViewController that was used
 @param accessToken the access token for the logged in account
 @param state the state param value that was passed in at the beginning of the flow
 */
- (void)viewController:(UIViewController<AKFViewController> *)viewController didCompleteLoginWithAccessToken:(id<AKFAccessToken>)accessToken state:(NSString *)state {
    
}

/*!
 @abstract Called when the login failes with an error
 
 @param viewController the AKFViewController that was used
 @param error the error that occurred
 */
- (void)viewController:(UIViewController<AKFViewController> *)viewController didFailWithError:(NSError *)error {
    
}

/*!
 @abstract Called when the login flow is cancelled through the UI.
 
 @param viewController the AKFViewController that was used
 */
- (void)viewControllerDidCancel:(UIViewController<AKFViewController> *)viewController {
    
}

@end
