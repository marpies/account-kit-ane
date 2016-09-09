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

package com.marpies.ane.facebook.accountkit.utils;

import com.facebook.accountkit.AccountKit;
import com.marpies.ane.facebook.accountkit.data.AccountKitEvent;

public class AccountKitHelper implements AccountKit.InitializeCallback {

	private String mResponseType;

	private static AccountKitHelper mInstance = new AccountKitHelper();

	public static AccountKitHelper getInstance() {
		return mInstance;
	}

	private AccountKitHelper() {
	}

	/**
	 *
	 *
	 * Public API
	 *
	 *
	 */

	public void initializeWithResponseType( String responseType ) {
		AIR.log( "AccountKitHelper::initialize" );
		mResponseType = responseType;

		AccountKit.initialize( AIR.getContext().getActivity(), this );
	}

	@Override
	public void onInitialized() {
		AIR.log( "AccountKitHelper::onInitialized" );
		AIR.dispatchEvent( AccountKitEvent.INIT );
	}

}
