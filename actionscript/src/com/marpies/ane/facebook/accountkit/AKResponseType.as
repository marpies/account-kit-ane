package com.marpies.ane.facebook.accountkit {

    /**
     * The type of response that will be returned from a login.
     */
    public class AKResponseType {

        /**
         * Indicates that the requested response type is an authorization code
         * that can be exchanged for an access token.
         */
        public static const AUTHORIZATION_CODE:String = "authorizationCode";

        /**
         * Indicates that the requested response type is an access token.
         */
        public static const ACCESS_TOKEN:String = "accessToken";

        /**
         * @private
         */
        internal static function isValid( value:String ):Boolean {
            return (value == ACCESS_TOKEN) || (value == AUTHORIZATION_CODE);
        }

    }

}
