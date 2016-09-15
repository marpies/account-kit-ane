# Account Kit | Native extension for Adobe AIR (iOS &amp; Android)

[Account Kit](https://developers.facebook.com/docs/accountkit/overview) helps people quickly and easily register and log into your app using their phone number or email address as a passwordless credential. Account Kit is powered by Facebook's email and SMS sending infrastructure for reliable scalable performance with global reach. Using email and phone number authentication doesn't require a Facebook account, and is the ideal alternative to a social login.

Development of this extension is supported by [Master Tigra, Inc.](https://github.com/mastertigra)

## Native SDK versions

* iOS `v4.15.0`
* Android `v4.15.0`

## Features

* User-friendly login via email or SMS
* Storing custom user preferences
* Retrieving AccountKit account data

## AIR SDK bugs

Note: AIR SDK currently lacks a feature that negatively affects this extension's usability. Due to that you are required to make a minor modification to the SDK on your machine, and the extension cannot run on Android 4. Please, leave a vote in the bug reports below to help the usability of this and other extensions:

* [Bug 4189538 - Outdated Android AppCompat resources](https://bugbase.adobe.com/index.cfm?event=bug&id=4189538)
* [Bug 4189540 - Specify extra parameters to aapt tool when creating APK](https://bugbase.adobe.com/index.cfm?event=bug&id=4189540) 

## Getting started

Start by creating a Facebook app in the [Facebook developer dashboard](https://developers.facebook.com/apps/). Next, add AccountKit product from the dashboard menu on the left. Write down your Facebook app ID and AccountKit client token.

### Modify Android resources

AccountKit SDK for Android requires Android resources which contain your Facebook app ID and AccountKit client token. These resources are part of the extension package and must be specified when building APK file, thus you will need to repackage the extension with resources that hold your information. If you do not intend to target Android platform then use the [extension package from the bin directory](bin/) and skip over to **Additions to AIR descriptor** section. To modify the resources, open the file [strings.xml](android/com.marpies.ane.facebook.accountkit-res/values/strings.xml) and replace the placeholders with actual values from the developer dashboard:

* `{FACEBOOK_APP_ID}` with your Facebook app ID
* `{ACCOUNT_KIT_CLIENT_TOKEN}` with your AccountKit client token

Update [build.properties](build/build.properties) variables `air.sdk` and `gradle.exec` to point to AIR SDK 20+ root directory and to [Gradle](https://gradle.org/gradle-download/) executable. Navigate to the [build](build/) directory from the command line and run `ant all` to build and package the extension.

### Modify AIR SDK library

The AccountKit SDK for Android uses AppCompat resources for styling UI activities presented to the user. AIR SDK uses older version of these resources which must be removed from the AIR SDK to avoid conflict with newer version. Since the following steps directly modify the SDK, I suggest you create a copy of the SDK directory, mark it as patched and only use it for apps where AccountKit ANE is included.

Download `runtimeClasses.jar` for your AIR SDK version (22 or 23) from the [air_sdk_patch](air_sdk_patch/) directory. Copy and paste it to `AIR_SDK_patched/lib/android/lib`, replacing the existing file.   

### Additions to AIR descriptor

Add the extension's ID to the `extensions` element.

```xml
<extensions>
    <extensionID>com.marpies.ane.facebook.accountkit</extensionID>
</extensions>
```

If you are targeting Android, add the following extensions from [this repository](https://github.com/marpies/android-dependency-anes) as well (unless you know these libraries are included by some other extensions):

```xml
<extensions>
    <extensionID>com.marpies.ane.androidsupport</extensionID>
    <extensionID>com.marpies.ane.androidsupport.appcompat</extensionID>
    <extensionID>com.marpies.ane.androidsupport.design</extensionID>
    <extensionID>com.marpies.ane.androidsupport.recyclerview</extensionID>
</extensions>
```

For iOS support, look for the `iPhone` element and make sure it contains the following `InfoAdditions`:

```xml
<iPhone>
    <InfoAdditions>
        <![CDATA[
        <key>CFBundleURLTypes</key>
        <array>
            <dict>
                <key>CFBundleURLSchemes</key>
                    <array>
                        <string>ak{FACEBOOK_APP_ID}</string>
                    </array>
            </dict>
        </array>

        <key>AccountKitClientToken</key>
        <string>{ACCOUNT_KIT_CLIENT_TOKEN}</string>

        <key>MinimumOSVersion</key>
        <string>7.0</string>
        ]]>
    </InfoAdditions>

    ...
</iPhone>
```
In the snippet above, replace:

* `{FACEBOOK_APP_ID}` with your Facebook app ID
* `{ACCOUNT_KIT_CLIENT_TOKEN}` with your AccountKit client token

For Android support, modify `manifestAdditions` element so that it contains the following meta-data and activities. Note the meta-data `com.facebook.accountkit.FacebookAppEventsEnabled` requires [Facebook SDK](https://github.com/marpies/AIRFacebook-ANE) to be included in your app; alternatively you can set the value to `false` to disable event logging made by AccountKit SDK.

```xml
<android>
    <manifestAdditions>
        <![CDATA[
        <manifest android:installLocation="auto">

            <uses-permission android:name="android.permission.INTERNET"/>

            <!-- OPTIONAL: allows the SDK to pre-fill user email and phone number when launching login activity -->
            <uses-permission android:name="android.permission.RECEIVE_SMS" />
            <uses-permission android:name="android.permission.READ_PHONE_STATE" />
            <uses-permission android:name="android.permission.GET_ACCOUNTS" />

            <application>

                <!-- AccountKit BEGIN -->
                <meta-data android:name="com.facebook.accountkit.ApplicationName" android:value="@string/app_name" />
                <meta-data android:name="com.facebook.sdk.ApplicationId" android:value="@string/FACEBOOK_APP_ID" />
                <meta-data android:name="com.facebook.accountkit.ClientToken" android:value="@string/ACCOUNT_KIT_CLIENT_TOKEN" />
                <!-- Optional event logging -->
                <meta-data android:name="com.facebook.accountkit.FacebookAppEventsEnabled" android:value="true" />

                <activity
                    android:name="com.facebook.accountkit.ui.AccountKitActivity"
                    android:label="@string/com_accountkit_button_log_in"
                    android:launchMode="singleTop"
                    android:theme="@style/Theme.AccountKit"
                    android:windowSoftInputMode="adjustResize">
                    <intent-filter>
                        <action android:name="android.intent.action.VIEW" />
                        <category android:name="android.intent.category.DEFAULT" />
                        <category android:name="android.intent.category.BROWSABLE" />
                        <data android:scheme="@string/ak_login_protocol_scheme" />
                    </intent-filter>
                </activity>
                <activity
                    android:name="com.facebook.accountkit.ui.AccountKitEmailRedirectActivity"
                    android:exported="true"
                    android:noHistory="true" />
                <!-- AccountKit END -->

            </application>

        </manifest>
        ]]>
    </manifestAdditions>
</android>
```

Finally, add the [AccountKit ANE](bin/com.marpies.ane.facebook.accountkit.ane) or [SWC](bin/com.marpies.ane.facebook.accountkit.swc) package from the [bin directory](bin/) to your project so that your IDE can work with it. The additional Android library ANEs are only necessary during packaging.

## API overview

### Initialization

Initialize the extension using the `init` method that accepts the following parameters:

* `loginType` - determines whether you app receives access token or authorization code only, see [AKResponseType class](actionscript/src/com/marpies/ane/facebook/accountkit/AKResponseType.as)
* `initCallback` - function that will be called when the SDK is initialized
* `showLogs` - set to `true` to enable extension logs

```as3
AccountKit.init( AKResponseType.ACCESS_TOKEN, onAccountKitInitialized, true );

private function onAccountKitInitialized():void {
    trace( "AccountKit SDK initialized" );
}
```

Once the SDK is initialized, you can see if there is a user currently logged by checking the access token:

```as3
var token:AKAccessToken = AccountKit.accessToken;
if( token != null ) {
    trace( "AccountKit user is logged in: " + token.accountId );
    trace( "Last refresh: " + token.lastRefresh );
}
```

### Login

You can initiate user login by calling the `login` method along with a configuration object:

```as3
var config:AKConfiguration = new AKConfiguration();
config.loginType = AKLoginType.EMAIL; // or AKLoginType.PHONE to login via SMS
config.initialAuthState = "random-nonce";
config.initialEmail = "hello@example.com"; // prefill user's email manually
config.setInitialPhoneNumber( "US", "1234567890"); // prefill user's phone number manually
// Values below apply to Android only
config.defaultCountryCode = "US"; // default country code shown in the SMS login flow
config.enableFacebookNotification = true; // receive confirmation via Facebook notification
config.titleType = AKTitleType.APP_NAME; // or AKTitleType.LOGIN
config.enableReadPhoneState = true; // prefill user's phone number automatically
config.receiveSms = true; // prefill confirmation code automatically
config.smsWhiteList = new <String>["US", "NL"]; // list of allowed country codes for SMS
config.smsBlackList = new <String>["UK"]; // list of excluded country codes for SMS

...

AccountKit.login( config, onAccountKitLoginResult );

private function onAccountKitLoginResult( result:AKLoginResult ):void {
    trace( "AccountKit login result" );
    if( result.wasCancelled ) {
        trace( "> was cancelled" );
    } else if( result.errorMessage != null ) {
        trace( "> failed: " + result.errorMessage );
    } else {
        trace( "> is success | auth state: " + result.authorizationState ); // check to match 'config.initialAuthState'
        // either accessToken or authorizationCode will be set depending on the AKResponseType used when initializing the extension
        trace( "> accessToken: " + result.accessToken );
        trace( "> authorizationCode: " + result.authorizationCode );
    }
}
```

### Account details

To retrieve details about current account, call:

```as3
AccountKit.getCurrentAccount( onAccountKitAccountRetrieved );

private function onAccountKitAccountRetrieved( account:AKAccount, errorMessage:String ):void {
    if( errorMessage != null ) {
        trace( "Error getting account info: " + errorMessage );
    } else {
        trace( "Account id: " + account.id );
        trace( "Account email: " + account.email );
        trace( "Account phoneNumber: " + account.phoneNumber );
        trace( "Account phoneNumberCountryCode: " + account.phoneNumberCountryCode );
    }
}
```

### User preferences

You may store up to 100 key/value pairs per user. A key is a string of up to 100 characters; allowed characters are uppercase and lowercase letters, numerals, and the underscore. A value is a string of up to 1000 characters.

To interact with user preferences, get the [AKAccountPreferences](actionscript/src/com/marpies/ane/facebook/accountkit/AKAccountPreferences.as) object using `AccountKit.accountPreferences`. To set a user preference, call:
```as3
AccountKit.accountPreferences.setPreference( "key", "value", onAccountKitPreferenceSet );

private function onAccountKitPreferenceSet( key:String, value:String, errorMessage:String ):void {
    if( errorMessage != null ) {
        trace( "Error setting pref: " + errorMessage );
    } else {
        trace( "Set pref: " + key + " -> " + value );
    }
}
```

To load a preference, call:
```as3
AccountKit.accountPreferences.loadPreference( "key", onAccountKitPreferenceLoaded );

private function onAccountKitPreferenceLoaded( key:String, value:String, errorMessage:String ):void {
    if( errorMessage != null ) {
        trace( "Error loading pref: " + errorMessage );
    } else {
        trace( "Loaded pref: " + key + " -> " + value );
    }
}
```

To delete a preference, call:
```as3
AccountKit.accountPreferences.deletePreference( "key", onAccountKitPreferenceLoaded );

private function onAccountKitPreferenceDeleted( key:String, errorMessage:String ):void {
    if( errorMessage != null ) {
        trace( "Error deleting pref: " + errorMessage );
    } else {
        trace( "Deleted pref: " + key );
    }
}
```

To load all preferences, call:

```as3
AccountKit.accountPreferences.loadPreferences( onAccountKitPreferencesLoaded );

private function onAccountKitPreferencesLoaded( preferences:Object, errorMessage:String ):void {
    if( errorMessage != null ) {
        trace( "Error loading pref: " + errorMessage );
    } else {
        trace( "Loaded all preferences:" );
        for( var key:String in preferences ) {
            trace( "Preference", key, "has value", preferences[key] );
        }
    }
}
```

## Requirements

* iOS 7+
* Android 5+ (your app will work on Android 4, but the AccountKit functionality will not be available)
* Adobe AIR 20+

## Documentation
Generated ActionScript documentation is available in the [docs](docs/) directory, or can be generated by running `ant asdoc` from the [build](build/) directory.

## Build ANE
ANT build scripts are available in the [build](build/) directory. Edit [build.properties](build/build.properties) to correspond with your local setup.

## Author

The ANE has been developed by [Marcel Piestansky](https://twitter.com/marpies) and is distributed under [Apache License, version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html).

## Changelog

#### September 14, 2016 (v1.0.0)

* Public release
