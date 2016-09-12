package com.marpies.ane.facebook.accountkit {

    /**
     * This class represents an immutable access token for using AccountKit APIs.
     * It also includes associated metadata such as expiration date.
     */
    public class AKAccessToken {

        /**
         * @private
         */
        internal var mAccountId:String;
        /**
         * @private
         */
        internal var mApplicationId:String;
        /**
         * @private
         */
        internal var mToken:String;
        /**
         * @private
         */
        internal var mLastRefresh:Date;
        /**
         * @private
         */
        internal var mTokenRefreshIntervalInSeconds:Number;

        /**
         * @private
         */
        public function AKAccessToken() {
        }

        /**
         * @private
         */
        internal static function fromJSON( json:Object ):AKAccessToken {
            if( json is String ) {
                json = JSON.parse( json as String );
            }
            var accessToken:AKAccessToken = new AKAccessToken();
            accessToken.mAccountId = json.accountId;
            accessToken.mApplicationId = json.applicationId;
            accessToken.mToken = json.token;
            var lastRefresh:Date = new Date();
            lastRefresh.time = json.lastRefreshTime;
            accessToken.mLastRefresh = lastRefresh;
            accessToken.mTokenRefreshIntervalInSeconds = json.tokenRefreshIntervalInSeconds;
            return accessToken;
        }

        /**
         * The AccountKit account id associated with this access token.
         */
        public function get accountId():String {
            return mAccountId;
        }

        /**
         * The ID of the Facebook Application associated with this access token.
         */
        public function get applicationId():String {
            return mApplicationId;
        }

        /**
         * The access token string obtained from AccountKit.
         */
        public function get token():String {
            return mToken;
        }

        /**
         * The last time the token was refreshed (or when it was first obtained).
         */
        public function get lastRefresh():Date {
            return mLastRefresh;
        }

        /**
         * The interval at which tokens should be refreshed.
         */
        public function get tokenRefreshIntervalInSeconds():Number {
            return mTokenRefreshIntervalInSeconds;
        }

    }

}
