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

#import "AIRAccountKit.h"
#import "InitFunction.h"
#import <AIRExtHelpers/MPFREObjectUtils.h>

FREObject fbak_init( FREContext context, void* functionData, uint32_t argc, FREObject argv[] ) {
    /* Already initialized */
    if( [[AIRAccountKit sharedInstance] helper] != nil ) return nil;
    
    NSString* responseType = [MPFREObjectUtils getNSString:argv[0]];
    BOOL showLogs = [MPFREObjectUtils getBOOL:argv[1]];
    [AIRAccountKit showLogs:showLogs];
    [[AIRAccountKit sharedInstance] setHelper:[[AccountKitHelper alloc] initWithResponseType:responseType]];
    return nil;
}