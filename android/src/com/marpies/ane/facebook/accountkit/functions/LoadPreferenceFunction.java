/*
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

package com.marpies.ane.facebook.accountkit.functions;

import android.support.annotation.Nullable;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREObject;
import com.facebook.accountkit.AccountKit;
import com.facebook.accountkit.AccountKitError;
import com.facebook.accountkit.AccountPreferences;
import com.marpies.ane.facebook.accountkit.data.AccountKitEvent;
import com.marpies.ane.facebook.accountkit.utils.AIR;
import com.marpies.ane.facebook.accountkit.utils.FREObjectUtils;
import com.marpies.ane.facebook.accountkit.utils.JSONUtils;
import com.marpies.ane.facebook.accountkit.utils.StringUtils;
import org.json.JSONException;
import org.json.JSONObject;

public class LoadPreferenceFunction extends BaseFunction {

	@Override
	public FREObject call( FREContext context, FREObject[] args ) {
		super.call( context, args );

		AIR.log( "AccountKit::loadPreference" );
		final int callbackId = FREObjectUtils.getInt( args[1] );

		/* User is not logged in, cannot load preference */
		if( AccountKit.getCurrentAccessToken() == null ) {
			dispatchError( callbackId, "User is not logged in, cannot load preference." );
			return null;
		}

		String prefKey = FREObjectUtils.getString( args[0] );
		AccountKit.getAccountPreferences().loadPreference( prefKey, new AccountPreferences.OnLoadPreferenceListener() {
			@Override
			public void onLoadPreference( String key, @Nullable String value, @Nullable AccountKitError accountKitError ) {
				if( accountKitError != null ) {
					dispatchError( callbackId, accountKitError.getErrorType().getMessage() );
				} else {
					if( value == null ) {
						dispatchError( callbackId, "Value for key '" + key + "' not found." );
						return;
					}
					AIR.log( "AccountKit | successfully loaded preference" );
					JSONObject response = new JSONObject();
					JSONUtils.addToJSON( response, "callbackId", callbackId );
					JSONUtils.addToJSON( response, "key", key );
					JSONUtils.addToJSON( response, "value", value );
					AIR.dispatchEvent( AccountKitEvent.LOAD_PREFERENCE, response.toString() );
				}
			}
		} );

		return null;
	}

	private void dispatchError( int callbackId, String message ) {
		AIR.log( "AccountKit | failed to load preference: " + message );
		AIR.dispatchEvent( AccountKitEvent.LOAD_PREFERENCE, StringUtils.getEventErrorJSON( callbackId, message ) );
	}

}

