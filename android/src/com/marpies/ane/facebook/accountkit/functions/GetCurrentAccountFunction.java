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

import com.adobe.fre.FREContext;
import com.adobe.fre.FREObject;
import com.facebook.accountkit.Account;
import com.facebook.accountkit.AccountKit;
import com.facebook.accountkit.AccountKitCallback;
import com.facebook.accountkit.AccountKitError;
import com.marpies.ane.facebook.accountkit.data.AccountKitEvent;
import com.marpies.ane.facebook.accountkit.utils.AIR;
import com.marpies.ane.facebook.accountkit.utils.FREObjectUtils;
import com.marpies.ane.facebook.accountkit.utils.StringUtils;
import org.json.JSONException;
import org.json.JSONObject;

public class GetCurrentAccountFunction extends BaseFunction {

	@Override
	public FREObject call( FREContext context, FREObject[] args ) {
		super.call( context, args );

		AIR.log( "AccountKit::getCurrentAccount" );
		final int callbackId = FREObjectUtils.getInt( args[0] );

		AccountKit.getCurrentAccount( new AccountKitCallback<Account>() {
			@Override
			public void onSuccess( Account account ) {
				AIR.log( "AccountKit | success retrieving account information" );
				JSONObject response = new JSONObject();
				addToResponse( response, "id", account.getId() );
				addToResponse( response, "email", account.getEmail() );
				if( account.getPhoneNumber() != null ) {
					addToResponse( response, "phoneNumber", account.getPhoneNumber().getPhoneNumber() );
					addToResponse( response, "phoneNumberCountryCode", account.getPhoneNumber().getCountryCode() );
				}
				addToResponse( response, "callbackId", callbackId );
				AIR.dispatchEvent( AccountKitEvent.ACCOUNT_REQUEST, response.toString() );
			}

			@Override
			public void onError( AccountKitError accountKitError ) {
				AIR.log( "AccountKit | error retrieving account information: " + accountKitError.getErrorType().getMessage() );
				AIR.dispatchEvent( AccountKitEvent.ACCOUNT_REQUEST, StringUtils.getEventErrorJSON( callbackId, accountKitError.getErrorType().getMessage() ) );
			}
		} );

		return null;
	}

	private void addToResponse( JSONObject response, String key, Object value ) {
		if( value != null ) {
			try {
				response.put( key, value );
			} catch( JSONException e ) {
				e.printStackTrace();
			}
		}
	}

}

