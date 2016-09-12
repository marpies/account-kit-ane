package com.marpies.ane.facebook.accountkit {

    /**
     * AccountKit login configuration.
     */
    public class AKConfiguration {

        private var mLoginType:String;
        private var mInitialAuthState:String;
        private var mInitialEmail:String;
        private var mDefaultCountryCode:String;
        private var mInitialPhoneNumber:String;
        private var mEnableFacebookNotification:Boolean;
        private var mTitleType:String;
        private var mEnableReadPhoneState:Boolean;
        private var mReceiveSms:Boolean;
        private var mSmsWhiteList:Vector.<String>;
        private var mSmsBlackList:Vector.<String>;

        /**
         * @private
         */
        public function AKConfiguration() {
            mReceiveSms = true;
            mEnableReadPhoneState = true;
            mEnableFacebookNotification = true;
            mLoginType = AKLoginType.EMAIL;
            mTitleType = AKTitleType.LOGIN;
        }

        /**
         * Determines whether user will login via email or phone number.
         *
         * @default com.marpies.ane.facebook.accountkit.AKLoginType#EMAIL
         *
         * @see com.marpies.ane.facebook.accountkit.AKLoginType
         */
        public function get loginType():String {
            return mLoginType;
        }

        /**
         * @private
         */
        public function set loginType( loginType:String ):void {
            if( !AKLoginType.isValid( loginType ) ) throw new ArgumentError( "Parameter loginType must be one of the values defined in AKLoginType class." );
            mLoginType = loginType;
        }

        /**
         * A developer-generated nonce used to verify that the received response matches the request.
         * Fill this with a random value at runtime; when the login callback is triggered and it is successful,
         * check that <code>AKLoginResult.authorizationState</code> matches the value set in this method.
         *
         * @see com.marpies.ane.facebook.accountkit.AKLoginResult#authorizationState
         */
        public function get initialAuthState():String {
            return mInitialAuthState;
        }

        /**
         * @private
         */
        public function set initialAuthState( value:String ):void {
            mInitialAuthState = value;
        }

        /**
         * Pre-fill the user's email address in the email login flow.
         */
        public function get initialEmail():String {
            return mInitialEmail;
        }

        /**
         * @private
         */
        public function set initialEmail( value:String ):void {
            mInitialEmail = value;
        }

        /**
         * The default country code shown in the SMS login flow.
         */
        public function get defaultCountryCode():String {
            return mDefaultCountryCode;
        }

        /**
         * @private
         */
        public function set defaultCountryCode( value:String ):void {
            mDefaultCountryCode = value;
        }

        /**
         * Pre-fill the user's phone number in the SMS login flow.
         */
        public function get initialPhoneNumber():String {
            return mInitialPhoneNumber;
        }

        /**
         * @private
         */
        public function set initialPhoneNumber( value:String ):void {
            mInitialPhoneNumber = value;
        }

        /**
         * If this flag is set, Account Kit offers the user the option to receive their confirmation message via
         * a Facebook notification in the event of an SMS failure, if their phone number is associated with their
         * Facebook account. The associated phone number must be the primary phone number for that Facebook account.
         *
         * @default true
         */
        public function get enableFacebookNotification():Boolean {
            return mEnableFacebookNotification;
        }

        /**
         * @private
         */
        public function set enableFacebookNotification( value:Boolean ):void {
            mEnableFacebookNotification = value;
        }

        /**
         * Set to <code>AKTitleType.APP_NAME</code> to use your application's name as the title for the login
         * screen, or <code>AKTitleType.LOGIN</code> to use a localized translation of "Login" as the title.
         *
         * @default com.marpies.ane.facebook.accountkit.AKTitleType#LOGIN
         *
         * @see com.marpies.ane.facebook.accountkit.AKTitleType
         */
        public function get titleType():String {
            return mTitleType;
        }

        /**
         * @private
         */
        public function set titleType( titleType:String ):void {
            if( !AKTitleType.isValid( titleType ) ) throw new ArgumentError( "Parameter titleType must be one of the values defined in AKTitleType class." );
            mTitleType = titleType;
        }

        /**
         * If the <code>READ_PHONE_STATE</code> permission is granted and this flag is true, the app will pre-fill the
         * user's phone number in the SMS login flow. Set to false if you wish to use the <code>READ_PHONE_STATE</code>
         * permission yourself, but you do not want the user's phone number pre-filled by Account Kit.
         *
         * @default true
         */
        public function get enableReadPhoneState():Boolean {
            return mEnableReadPhoneState;
        }

        /**
         * @private
         */
        public function set enableReadPhoneState( value:Boolean ):void {
            mEnableReadPhoneState = value;
        }

        /**
         * If the <code>RECEIVE_SMS</code> permission is granted and this flag is true, the app will automatically
         * read the Account Kit confirmation SMS and pre-fill the confirmation code in the SMS login flow.
         * Set to false if you wish to use the <code>RECEIVE_SMS</code> permission yourself, but you do not want
         * the SMS confirmation code pre-filled by Account Kit.
         *
         * @default true
         */
        public function get receiveSms():Boolean {
            return mReceiveSms;
        }

        /**
         * @private
         */
        public function set receiveSms( value:Boolean ):void {
            mReceiveSms = value;
        }

        /**
         * Use this to specify a list of permitted country codes for use in the SMS login flow.
         * The value is an array of short country codes as defined by ISO 3166-1 Alpha 2.
         * To restrict availability to just the US (+1) and The Netherlands (+31), pass in ["US", "NL"].
         *
         * @see http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
         */
        public function get smsWhiteList():Vector.<String> {
            return mSmsWhiteList;
        }

        /**
         * @private
         */
        public function set smsWhiteList( value:Vector.<String> ):void {
            mSmsWhiteList = value;
        }

        /**
         * Use this to specify a list of country codes to exclude during the SMS login flow.
         * Only the country codes in the blacklist are unavailable. People can still use the rest of Account Kit's
         * supported country codes. If a country code appears in both the whitelist and the blacklist, the blacklist
         * takes precedence and the country code is not available. Just like the whitelist, the value is an array of
         * short country codes as defined by ISO 3166-1 Alpha 2.
         *
         * @see http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
         */
        public function get smsBlackList():Vector.<String> {
            return mSmsBlackList;
        }

        /**
         * @private
         */
        public function set smsBlackList( value:Vector.<String> ):void {
            mSmsBlackList = value;
        }

    }

}
