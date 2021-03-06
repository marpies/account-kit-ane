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

#import <Foundation/Foundation.h>
#import <AccountKit/AccountKit.h>
#import <AIRExtHelpers/FlashRuntimeExtensions.h>

@interface AccountKitHelper : NSObject<AKFViewControllerDelegate, AKFAccountPreferencesDelegate>

- (nullable id) initWithResponseType:(nonnull NSString*) responseType;
- (void) loginWithConfiguration:(nonnull FREObject) config callbackId:(int) callbackId;
- (void) getCurrentAccount:(int) callbackId;
- (void) logout;
- (nullable NSString*) getAccessTokenJSON;

- (void) setPreference:(nonnull NSString*) key value:(nonnull NSString*) value callbackId:(int) callbackId;
- (void) deletePreference:(nonnull NSString*) key callbackId:(int) callbackId;
- (void) loadPreference:(nonnull NSString*) key callbackId:(int) callbackId;
- (void) loadPreferences:(int) callbackId;

@end
