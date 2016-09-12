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

import android.content.Intent;
import com.adobe.air.AndroidActivityWrapper;
import com.adobe.air.IActivityResultCallback;
import com.adobe.fre.*;
import com.facebook.accountkit.AccountKitLoginResult;
import com.facebook.accountkit.PhoneNumber;
import com.facebook.accountkit.ui.AccountKitActivity;
import com.facebook.accountkit.ui.AccountKitConfiguration;
import com.facebook.accountkit.ui.LoginType;
import com.marpies.ane.facebook.accountkit.data.AccountKitEvent;
import com.marpies.ane.facebook.accountkit.utils.*;
import org.json.JSONException;
import org.json.JSONObject;

public class LoginFunction extends BaseFunction implements IActivityResultCallback {

	private static final int AK_APP_REQUEST_CODE = 4871;

	private int mCallbackId;

	@Override
	public FREObject call( FREContext context, FREObject[] args ) {
		super.call( context, args );

		FREObject configuration = args[0];
		mCallbackId = FREObjectUtils.getInt( args[1] );

		String loginTypeString = FREObjectUtils.getStringProperty( configuration, "loginType" );
		AIR.log( "AccountKit::login via " + loginTypeString );

		/* Create intent to launch AccountKit activity */
		final Intent intent = new Intent( AIR.getContext().getActivity(), AccountKitActivity.class );
		AccountKitConfiguration.AccountKitConfigurationBuilder configurationBuilder =
				new AccountKitConfiguration.AccountKitConfigurationBuilder(
						getLoginType( loginTypeString ),
						AccountKitHelper.getInstance().getResponseType() );
		/* Parse the rest of the configuration object */
		AccountKitConfiguration config = parseAccountKitConfiguration( configuration, configurationBuilder );
		intent.putExtra( AccountKitActivity.ACCOUNT_KIT_ACTIVITY_CONFIGURATION, config );

		AndroidActivityWrapper.GetAndroidActivityWrapper().addActivityResultListener( this );

		AIR.log( "Starting AccountKitActivity" );
		AIR.startActivityForResult( intent, AK_APP_REQUEST_CODE );

		return null;
	}

	@Override
	public void onActivityResult( int requestCode, int resultCode, Intent data ) {
		if( requestCode == AK_APP_REQUEST_CODE ) {
			AccountKitLoginResult loginResult = data.getParcelableExtra( AccountKitLoginResult.RESULT_KEY );
			/* Error logging in */
			if( loginResult.getError() != null ) {
				AIR.log( "AccountKit | login error: " + loginResult.getError().getErrorType().getMessage() );
				AIR.dispatchEvent( AccountKitEvent.LOGIN_ERROR, StringUtils.getEventErrorJSON( mCallbackId, loginResult.getError().getErrorType().getMessage() ) );
			}
			/* Login cancelled */
			else if( loginResult.wasCancelled() ) {
				AIR.log( "AccountKit | login cancelled" );
				AIR.dispatchEvent( AccountKitEvent.LOGIN_CANCEL, String.valueOf( mCallbackId ) );
			}
			/* Login success */
			else {
				AIR.log( "AccountKit | final auth state: " + loginResult.getFinalAuthorizationState() );
				JSONObject response = new JSONObject();
				if( loginResult.getAccessToken() != null ) {
					addToResponse( response, "accessToken", AKAccessTokenUtils.toJSON( loginResult.getAccessToken() ) );
					AIR.log( "AccountKit | login got access token: " + loginResult.getAccessToken().getAccountId() );
					// access token is accessible using AccountKit.getCurrentAccessToken(), no need to store it manually
				} else if( loginResult.getAuthorizationCode() != null ) {
					addToResponse( response, "authCode", loginResult.getAuthorizationCode() );
					AIR.log( "AccountKit | login got auth code: " + loginResult.getAuthorizationCode() );
					/* Store the auth code, official sample app uses loginResult.getAuthorizationCode().substring( 0, 10 ) */
					AccountKitHelper.getInstance().setAuthorizationCode( loginResult.getAuthorizationCode() );
				}

				AIR.log( "AccountKit | success logging in" );
				/* Dispatch response */
				String authState = (loginResult.getFinalAuthorizationState() == null) ? "" : loginResult.getFinalAuthorizationState();
				addToResponse( response, "authState", authState );
				addToResponse( response, "callbackId", mCallbackId );
				AIR.dispatchEvent( AccountKitEvent.LOGIN_SUCCESS, response.toString() );
			}

			AndroidActivityWrapper.GetAndroidActivityWrapper().removeActivityResultListener( this );
		}
	}

	private void addToResponse( JSONObject response, String key, Object value ) {
		try {
			response.put( key, value );
		} catch( JSONException e ) {
			e.printStackTrace();
		}
	}

	private AccountKitConfiguration parseAccountKitConfiguration( FREObject configuration, AccountKitConfiguration.AccountKitConfigurationBuilder configurationBuilder ) {
		/* Initial auth state */
		String initialAuthState = FREObjectUtils.getStringProperty( configuration, "initialAuthState" );
		if( initialAuthState != null ) {
			AIR.log( "ParseConfig - configurationBuilder.setInitialAuthState" );
			configurationBuilder.setInitialAuthState( initialAuthState );
		}
		/* Initial email */
		String initialEmail = FREObjectUtils.getStringProperty( configuration, "initialEmail" );
		if( initialEmail != null ) {
			AIR.log( "ParseConfig - configurationBuilder.setInitialEmail" );
			configurationBuilder.setInitialEmail( initialEmail );
		}
		/* Default country code */
		String defaultCountryCode = FREObjectUtils.getStringProperty( configuration, "defaultCountryCode" );
		if( defaultCountryCode != null ) {
			AIR.log( "ParseConfig - configurationBuilder.setDefaultCountryCode" );
			configurationBuilder.setDefaultCountryCode( defaultCountryCode );
		}
		/* Title type */
		String titleType = FREObjectUtils.getStringProperty( configuration, "titleType" );
		if( titleType != null ) {
			AIR.log( "ParseConfig - configurationBuilder.setTitleType" );
			configurationBuilder.setTitleType( getTitleType( titleType ) );
		}
		/* Initial phone number */
		String phoneNumber = FREObjectUtils.getStringProperty( configuration, "initialPhoneNumber" );
		String phoneNumberCountryCode = FREObjectUtils.getStringProperty( configuration, "initialPhoneNumberCountryCode" );
		if( phoneNumber != null && phoneNumberCountryCode != null ) {
			AIR.log( "ParseConfig - configurationBuilder.setInitialPhoneNumber" );
			configurationBuilder.setInitialPhoneNumber( new PhoneNumber( phoneNumberCountryCode, phoneNumber ) );
		}
		/* Facebook notification */
		Boolean enableFBNotification = FREObjectUtils.getBooleanProperty( configuration, "enableFacebookNotification" );
		if( enableFBNotification != null ) {
			AIR.log( "ParseConfig - configurationBuilder.setFacebookNotificationsEnabled" );
			configurationBuilder.setFacebookNotificationsEnabled( enableFBNotification );
		}
		/* Read phone state */
		Boolean enableReadPhoneState = FREObjectUtils.getBooleanProperty( configuration, "enableReadPhoneState" );
		if( enableReadPhoneState != null ) {
			AIR.log( "ParseConfig - configurationBuilder.setReadPhoneStateEnabled" );
			configurationBuilder.setReadPhoneStateEnabled( enableReadPhoneState );
		}
		/* Receive SMS */
		Boolean receiveSMS = FREObjectUtils.getBooleanProperty( configuration, "receiveSms" );
		if( receiveSMS != null ) {
			AIR.log( "ParseConfig - configurationBuilder.setReceiveSMS" );
			configurationBuilder.setReceiveSMS( receiveSMS );
		}
		/* SMS white list */
		String[] smsWhiteList = FREObjectUtils.getArrayStringProperty( configuration, "smsWhiteList" );
		if( smsWhiteList != null ) {
			AIR.log( "ParseConfig - configurationBuilder.setSMSWhitelist" );
			configurationBuilder.setSMSWhitelist( smsWhiteList );
		}
		/* SMS black list */
		String[] smsBlackList = FREObjectUtils.getArrayStringProperty( configuration, "smsBlackList" );
		if( smsBlackList != null ) {
			AIR.log( "ParseConfig - configurationBuilder.setSMSBlacklist" );
			configurationBuilder.setSMSBlacklist( smsBlackList );
		}
		return configurationBuilder.build();
	}

	private LoginType getLoginType( String loginType ) {
		if( loginType.equals( "email" ) ) return LoginType.EMAIL;
		return LoginType.PHONE;
	}

	private AccountKitActivity.TitleType getTitleType( String titleType ) {
		if( titleType.equals( "appName" ) ) return AccountKitActivity.TitleType.APP_NAME;
		return AccountKitActivity.TitleType.LOGIN;
	}

}

