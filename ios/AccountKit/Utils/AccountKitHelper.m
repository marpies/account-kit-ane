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
    AKFAccountPreferences* mPreferences;
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

- (void) getCurrentAccount:(int) callbackId {
    /* Querying account when user is not logged in results in (error == nil) and (account.id == nil)
     * so we do not even make that request and respond with an error right away */
    if( [mAccountKit currentAccessToken] == nil ) {
        [AIRAccountKit log:@"AccountKitHelper | cannot request account, no user is logged in"];
        [AIRAccountKit dispatchEvent:AK_ACCOUNT_REQUEST withMessage:[MPStringUtils getEventErrorJSONString:callbackId errorMessage:@"User is not logged in."]];
        return;
    }
    [mAccountKit requestAccount:^(id<AKFAccount>  _Nullable account, NSError * _Nullable error) {
        if( error == nil ) {
            [AIRAccountKit log:@"AccountKitHelper | success retrieving account info"];
            NSMutableDictionary* response = [NSMutableDictionary dictionary];
            response[@"id"] = [account accountID];
            if( [account emailAddress] != nil ) {
                response[@"email"] = [account emailAddress];
            }
            /* Even though [account phoneNumber] may not be nil, its properties (phoneNumber, countryCode) may be nil so we must check it */
            if( ([account phoneNumber] != nil) && ([[account phoneNumber] phoneNumber] != nil) && ([[account phoneNumber] countryCode] != nil) ) {
                response[@"phoneNumber"] = [[account phoneNumber] phoneNumber];
                response[@"phoneNumberCountryCode"] = [[account phoneNumber] countryCode];
            }
            response[@"callbackId"] = @(callbackId);
            [AIRAccountKit dispatchEvent:AK_ACCOUNT_REQUEST withMessage:[MPStringUtils getJSONString:response]];
        } else {
            [AIRAccountKit log:[NSString stringWithFormat:@"AccountKitHelper | error retrieving account info: %@", error.localizedDescription]];
            [AIRAccountKit dispatchEvent:AK_ACCOUNT_REQUEST withMessage:[MPStringUtils getEventErrorJSONString:callbackId errorMessage:error.localizedDescription]];
        }
    }];
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

# pragma mark - Account preferences

- (void) setPreference:(nonnull NSString*) key value:(nonnull NSString*) value callbackId:(int) callbackId {
    mPreferences = [mAccountKit accountPreferences];
    if( mPreferences == nil ) {
        [AIRAccountKit dispatchEvent:AK_SET_PREFERENCE withMessage:[MPStringUtils getEventErrorJSONString:callbackId errorMessage:@"User is not logged in, cannot set preference."]];
        return;
    }
    mPreferences.delegate = self;
    mCallbackId = callbackId;
    [mPreferences setPreferenceForKey:key value:value];
}

- (void) deletePreference:(nonnull NSString*) key callbackId:(int) callbackId {
    mPreferences = [mAccountKit accountPreferences];
    if( mPreferences == nil ) {
        [AIRAccountKit dispatchEvent:AK_DELETE_PREFERENCE withMessage:[MPStringUtils getEventErrorJSONString:callbackId errorMessage:@"User is not logged in, cannot delete preference."]];
        return;
    }
    mPreferences.delegate = self;
    mCallbackId = callbackId;
    [mPreferences deletePreferenceForKey:key];
}

- (void) loadPreference:(nonnull NSString*) key callbackId:(int) callbackId {
    mPreferences = [mAccountKit accountPreferences];
    if( mPreferences == nil ) {
        [AIRAccountKit dispatchEvent:AK_LOAD_PREFERENCE withMessage:[MPStringUtils getEventErrorJSONString:callbackId errorMessage:@"User is not logged in, cannot load preference."]];
        return;
    }
    mPreferences.delegate = self;
    mCallbackId = callbackId;
    [mPreferences loadPreferenceForKey:key];
}

- (void) loadPreferences:(int) callbackId {
    mPreferences = [mAccountKit accountPreferences];
    if( mPreferences == nil ) {
        [AIRAccountKit dispatchEvent:AK_LOAD_PREFERENCES withMessage:[MPStringUtils getEventErrorJSONString:callbackId errorMessage:@"User is not logged in, cannot load preferences."]];
        return;
    }
    mPreferences.delegate = self;
    mCallbackId = callbackId;
    [mPreferences loadPreferences];
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

# pragma mark - AKFAccountPreferencesDelegate

/*!
 @abstract Notifies the delegate that a single preference was deleted.
 
 @param accountPreferences The AKFAccountPreferences instance that deleted the preference.
 @param key The key for the deleted preference.
 @param error The error if the preference could not be deleted.
 */
- (void)accountPreferences:(nonnull AKFAccountPreferences *)accountPreferences
 didDeletePreferenceForKey:(nonnull NSString *)key
                     error:(nullable NSError *)error {
    if( error != nil ) {
        [AIRAccountKit log:[NSString stringWithFormat:@"AccountKit | failed to delete preference: %@", error.localizedDescription]];
        [AIRAccountKit dispatchEvent:AK_DELETE_PREFERENCE withMessage:[MPStringUtils getEventErrorJSONString:mCallbackId errorMessage:error.localizedDescription]];
    } else {
        [AIRAccountKit log:@"AccountKit | successfully deleted preference"];
        NSMutableDictionary* response = [NSMutableDictionary dictionary];
        response[@"callbackId"] = @(mCallbackId);
        response[@"key"] = key;
        [AIRAccountKit dispatchEvent:AK_DELETE_PREFERENCE withMessage:[MPStringUtils getJSONString:response]];
    }
    mCallbackId = -1;
}

/*!
 @abstract Notifies the delegate that preferences were loaded.
 
 @param accountPreferences The AKFAccountPreferences instance that loaded the preferences.
 @param preferences The dictionary of preferences.
 @param error The error if the preferences could not be loaded.
 */
- (void)accountPreferences:(nonnull AKFAccountPreferences *)accountPreferences
        didLoadPreferences:(nullable NSDictionary<NSString *, NSString *> *)preferences
                     error:(nullable NSError *)error {
    if( error != nil ) {
        [AIRAccountKit log:[NSString stringWithFormat:@"AccountKit | failed to load preferences: %@", error.localizedDescription]];
        [AIRAccountKit dispatchEvent:AK_LOAD_PREFERENCES withMessage:[MPStringUtils getEventErrorJSONString:mCallbackId errorMessage:error.localizedDescription]];
    } else {
        [AIRAccountKit log:@"AccountKit | successfully loaded preferences"];
        NSDictionary* prefs = (preferences == nil) ? [NSDictionary dictionary] : [preferences copy];
        NSMutableArray* prefsArray = [NSMutableArray array];
        for( NSString* key in prefs ) {
            [prefsArray addObject:key];
            [prefsArray addObject:preferences[key]];
        }
        NSMutableDictionary* response = [NSMutableDictionary dictionary];
        response[@"callbackId"] = @(mCallbackId);
        response[@"preferences"] = prefsArray;
        [AIRAccountKit dispatchEvent:AK_LOAD_PREFERENCES withMessage:[MPStringUtils getJSONString:response]];
    }
    mCallbackId = -1;
}

/*!
 @abstract Notifies the delegate that a single preference was loaded.
 
 @param accountPreferences The AKFAccountPreferences instance that loaded the preference.
 @param key The key for the loaded preference.
 @param value The value for the loaded preference.
 @param error The error if the preference could not be loaded.
 */
- (void)accountPreferences:(nonnull AKFAccountPreferences *)accountPreferences
   didLoadPreferenceForKey:(nonnull NSString *)key
                     value:(nullable NSString *)value
                     error:(nullable NSError *)error {
    if( error != nil ) {
        [AIRAccountKit log:[NSString stringWithFormat:@"AccountKit | failed to load preference: %@", error.localizedDescription]];
        [AIRAccountKit dispatchEvent:AK_LOAD_PREFERENCE withMessage:[MPStringUtils getEventErrorJSONString:mCallbackId errorMessage:error.localizedDescription]];
    } else {
        if( value == nil ) {
            [AIRAccountKit log:[NSString stringWithFormat:@"Value for key '%@' not found.", key]];
            [AIRAccountKit dispatchEvent:AK_LOAD_PREFERENCE withMessage:[MPStringUtils getEventErrorJSONString:mCallbackId errorMessage:[NSString stringWithFormat:@"Value for key '%@' not found.", key]]];
        } else {
            [AIRAccountKit log:@"AccountKit | successfully loaded preference"];
            NSMutableDictionary* response = [NSMutableDictionary dictionary];
            response[@"callbackId"] = @(mCallbackId);
            response[@"key"] = key;
            response[@"value"] = value;
            [AIRAccountKit dispatchEvent:AK_LOAD_PREFERENCE withMessage:[MPStringUtils getJSONString:response]];
        }
    }
    mCallbackId = -1;

}

/*!
 @abstract Notifies the delegate that a single preference was set.
 
 @param accountPreferences The AKFAccountPreferences instance that set the preference.
 @param key The key for the set preference.
 @param value The value for the set preference.
 @param error The error if the preference could not be set.
 */
- (void)accountPreferences:(nonnull AKFAccountPreferences *)accountPreferences
    didSetPreferenceForKey:(nonnull NSString *)key
                     value:(nonnull NSString *)value
                     error:(nullable NSError *)error {
    if( error != nil ) {
        [AIRAccountKit log:[NSString stringWithFormat:@"AccountKit | failed to set preference: %@", error.localizedDescription]];
        [AIRAccountKit dispatchEvent:AK_SET_PREFERENCE withMessage:[MPStringUtils getEventErrorJSONString:mCallbackId errorMessage:error.localizedDescription]];
    } else {
        [AIRAccountKit log:@"AccountKit | successfully set preference"];
        NSMutableDictionary* response = [NSMutableDictionary dictionary];
        response[@"callbackId"] = @(mCallbackId);
        response[@"key"] = key;
        response[@"value"] = value;
        [AIRAccountKit dispatchEvent:AK_SET_PREFERENCE withMessage:[MPStringUtils getJSONString:response]];
    }
    mCallbackId = -1;
}

@end
