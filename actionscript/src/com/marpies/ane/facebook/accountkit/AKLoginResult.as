package com.marpies.ane.facebook.accountkit {

    /**
     * Represents the result of login process.
     */
    public class AKLoginResult {

        /**
         * @private
         */
        internal var mCancelled:Boolean;
        /**
         * @private
         */
        internal var mErrorMessage:String;
        /**
         * @private
         */
        internal var mAuthorizationCode:String;
        /**
         * @private
         */
        internal var mAuthorizationState:String;
        /**
         * @private
         */
        internal var mAccessToken:AKAccessToken;

        /**
         * @private
         */
        public function AKLoginResult() {
        }

        /**
         * The login process was cancelled.
         */
        public function get wasCancelled():Boolean {
            return mCancelled;
        }

        /**
         * Error message of any problem that may have occurred.
         */
        public function get errorMessage():String {
            return mErrorMessage;
        }

        /**
         * If login was successful then the final authorization state is returned.
         * This value should match the value passed to <code>AKConfiguration.initialAuthState</code>.
         *
         * @see com.marpies.ane.facebook.accountkit.AKConfiguration#initialAuthState
         */
        public function get authorizationState():String {
            return mAuthorizationState;
        }

        /**
         * If login was successful, and AccountKit was initialized with response type of <code>AKResponseType.AUTHORIZATION_CODE</code>
         * then the authorization code obtained during the login will be returned.
         *
         * @see com.marpies.ane.facebook.accountkit.AKResponseType
         */
        public function get authorizationCode():String {
            return mAuthorizationCode;
        }

        /**
         * If login was successful, and AccountKit was initialized with response type of <code>AKResponseType.ACCESS_TOKEN</code>
         * then the access token obtained during the login will be returned.
         *
         * <p>It can also be retrieved using AccountKit.accessToken</p>
         *
         * @see com.marpies.ane.facebook.accountkit.AccountKit#accessToken
         * @see com.marpies.ane.facebook.accountkit.AKResponseType
         */
        public function get accessToken():AKAccessToken {
            return mAccessToken;
        }

    }

}
