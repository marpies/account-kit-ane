package com.marpies.ane.facebook.accountkit {

    /**
     * Title type for the AccountKit login screen.
     */
    public class AKTitleType {

        /**
         * Use your application's name as the title for the login screen.
         */
        public static const APP_NAME:String = "appName";

        /**
         * Use a localized translation of "Login to {application_name}" as the title for the login screen.
         */
        public static const LOGIN:String = "login";

        /**
         * @private
         */
        internal static function isValid( value:String ):Boolean {
            return (value == APP_NAME) || (value == LOGIN);
        }

    }

}
