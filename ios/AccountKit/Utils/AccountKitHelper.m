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
#import <AIRExtHelpers/MPFREObjectUtils.h>
#import <AIRExtHelpers/MPStringUtils.h>
#import "AccountKitEvent.h"
#import "AKAccessTokenUtils.h"

@implementation AccountKitHelper {
    AKFAccountKit* mAccountKit;
    UIViewController<AKFViewController>* mPendingLoginViewController;
    NSString* mAuthorizationCode;
    int mCallbackId;
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

- (void) loginWithConfiguration:(FREObject) config callbackId:(int) callbackId {
    NSString* loginType = [self getStringProperty:config properyName:@"loginType"];
    NSString* phoneNumber = [self getStringProperty:config properyName:@"initialPhoneNumber"];
    NSString* phoneNumberCountryCode = [self getStringProperty:config properyName:@"initialPhoneNumberCountryCode"];
    NSString* email = [self getStringProperty:config properyName:@"initialEmail"];
    NSString* authState = [self getStringProperty:config properyName:@"initialAuthState"];
    mCallbackId = callbackId;
    
    [AIRAccountKit log:[NSString stringWithFormat:@"AccountKit login type: %@ state: %@", loginType, authState]];
    
    /* Login with email view controller */
    if( [loginType isEqualToString:@"email"] ) {
        [self loginWithEmail:email authState:authState];
    }
    /* Login with phone view controller */
    else {
        [self loginWithPhoneNumber:phoneNumber countryCode:phoneNumberCountryCode authState:authState];
    }
}

- (void) logout {
    [AIRAccountKit log:@"AccountKitHelper::logout"];
    [mAccountKit logOut];
}

- (NSString*) getAccessTokenJSON {
    id<AKFAccessToken> accessToken = [mAccountKit currentAccessToken];
    if( accessToken == nil ) return nil;
    return [AKAccessTokenUtils toJSON:accessToken];
}

# pragma mark - Private API

- (void) loginWithEmail:(nullable NSString*) email authState:(nullable NSString*) authState {
    [AIRAccountKit log:@"Showing AccountKit email view controller"];
    UIViewController<AKFViewController>* vc = [mAccountKit viewControllerForEmailLoginWithEmail:email state:authState];
    [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:vc animated:YES completion:^{
        [AIRAccountKit log:@"AccountKit email login view controller shown"];
    }];
    vc.delegate = self;
}

- (void) loginWithPhoneNumber:(nullable NSString*) phoneNumber countryCode:(nullable NSString*) phoneNumberCountryCode authState:(nullable NSString*) authState {
    [AIRAccountKit log:@"Showing AccountKit phone view controller"];
    AKFPhoneNumber* phone = nil;
    if( phoneNumber != nil && phoneNumberCountryCode != nil ) {
        phone = [[AKFPhoneNumber alloc] initWithCountryCode:phoneNumberCountryCode phoneNumber:phoneNumber];
    }
    UIViewController<AKFViewController>* vc = [mAccountKit viewControllerForPhoneLoginWithPhoneNumber:phone state:authState];
    [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:vc animated:YES completion:^{
        [AIRAccountKit log:@"AccountKit phone login view controller shown"];
    }];
}

- (AKFResponseType) getResponseType:(NSString*) responseType {
    if( [responseType isEqualToString:@"accessToken"] ) return AKFResponseTypeAccessToken;
    return AKFResponseTypeAuthorizationCode;
}

- (NSString*) getStringProperty:(FREObject) object properyName:(NSString*) propertyName {
    FREObject value;
    if( FREGetObjectProperty(object, (const uint8_t*)[propertyName UTF8String], &value, nil) == FRE_OK ) {
        if( value == nil ) return nil;
        return [MPFREObjectUtils getNSString:value];
    }
    return nil;
}

# pragma mark - AKFViewControllerDelegate

/*!
 @abstract Called when the login completes with an authorization code response type.
 
 @param viewController the AKFViewController that was used
 @param code the authorization code that can be exchanged for an access token with the app secret
 @param state the state param value that was passed in at the beginning of the flow
 */
- (void)viewController:(UIViewController<AKFViewController> *)viewController didCompleteLoginWithAuthorizationCode:(NSString *)code state:(NSString *)state {
    [AIRAccountKit log:[NSString stringWithFormat:@"AccountKit::didCompleteLoginWithAuthorizationCode %@ state: %@", code, state]];
    NSMutableDictionary* response = [NSMutableDictionary dictionary];
    response[@"authState"] = state;
    response[@"authCode"] = code;
    response[@"callbackId"] = @(mCallbackId);
    [AIRAccountKit dispatchEvent:AK_LOGIN_SUCCESS withMessage:[MPStringUtils getJSONString:response]];
    mCallbackId = -1;
}

/*!
 @abstract Called when the login completes with an access token response type.
 
 @param viewController the AKFViewController that was used
 @param accessToken the access token for the logged in account
 @param state the state param value that was passed in at the beginning of the flow
 */
- (void)viewController:(UIViewController<AKFViewController> *)viewController didCompleteLoginWithAccessToken:(id<AKFAccessToken>)accessToken state:(NSString *)state {
    [AIRAccountKit log:[NSString stringWithFormat:@"AccountKit::didCompleteLoginWithAccessToken %@ state: %@", accessToken, state]];
    NSMutableDictionary* response = [NSMutableDictionary dictionary];
    response[@"authState"] = state;
    response[@"accessToken"] = [AKAccessTokenUtils toJSON:accessToken];
    response[@"callbackId"] = @(mCallbackId);
    [AIRAccountKit dispatchEvent:AK_LOGIN_SUCCESS withMessage:[MPStringUtils getJSONString:response]];
    mCallbackId = -1;
}

/*!
 @abstract Called when the login failes with an error
 
 @param viewController the AKFViewController that was used
 @param error the error that occurred
 */
- (void)viewController:(UIViewController<AKFViewController> *)viewController didFailWithError:(NSError *)error {
    [AIRAccountKit log:[NSString stringWithFormat:@"AccountKit::didFailWithError %@", error.localizedDescription]];
    [AIRAccountKit dispatchEvent:AK_LOGIN_ERROR withMessage:[MPStringUtils getEventErrorJSONString:mCallbackId errorMessage:error.localizedDescription]];
    mCallbackId = -1;
}

/*!
 @abstract Called when the login flow is cancelled through the UI.
 
 @param viewController the AKFViewController that was used
 */
- (void)viewControllerDidCancel:(UIViewController<AKFViewController> *)viewController {
    [AIRAccountKit log:@"AccountKit::viewControllerDidCancel"];
    [AIRAccountKit dispatchEvent:AK_LOGIN_CANCEL withMessage:[NSString stringWithFormat:@"%i", mCallbackId]];
    mCallbackId = -1;
}

@end
