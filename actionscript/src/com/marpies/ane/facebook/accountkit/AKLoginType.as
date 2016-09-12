package com.marpies.ane.facebook.accountkit {

    /**
     * The type of login.
     */
    public class AKLoginType {

        /**
         * Log in with an email address.
         */
        public static const EMAIL:String = "email";

        /**
         * Log in with a phone number.
         */
        public static const PHONE:String = "phone";

        /**
         * @private
         */
        internal static function isValid( value:String ):Boolean {
            return (value == PHONE) || (value == EMAIL);
        }

    }

}
