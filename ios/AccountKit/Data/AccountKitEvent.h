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

#ifndef AccountKitEvent_h
#define AccountKitEvent_h

#import <Foundation/Foundation.h>

static NSString* const AK_INIT = @"init";
static NSString* const AK_LOGIN_SUCCESS = @"loginSuccess";
static NSString* const AK_LOGIN_CANCEL = @"loginCancel";
static NSString* const AK_LOGIN_ERROR = @"loginError";
static NSString* const AK_ACCOUNT_REQUEST = @"accountRequest";
static NSString* const AK_SET_PREFERENCE = @"setPreference";
static NSString* const AK_LOAD_PREFERENCE = @"loadPreference";
static NSString* const AK_DELETE_PREFERENCE = @"deletePreference";
static NSString* const AK_LOAD_PREFERENCES = @"loadPreferences";

#endif /* AccountKitEvent_h */
