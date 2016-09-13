package com.marpies.ane.facebook.accountkit {

    /**
     * Class that represents an account.
     */
    public class AKAccount {

        /**
         * @private
         */
        internal var mEmail:String;
        /**
         * @private
         */
        internal var mId:String;
        /**
         * @private
         */
        internal var mPhoneNumber:String;
        /**
         * @private
         */
        internal var mPhoneNumberCountryCode:String;

        /**
         * @private
         */
        public function AKAccount() {
        }

        /**
         * @private
         */
        internal static function fromJSON( json:Object ):AKAccount {
            var account:AKAccount = new AKAccount();
            account.mId = json.id;
            account.mEmail = ("email" in json) ? json.email : null;
            account.mPhoneNumber = ("phoneNumber" in json) ? json.phoneNumber : null;
            account.mPhoneNumberCountryCode = ("phoneNumberCountryCode" in json) ? json.phoneNumberCountryCode : null;
            return account;
        }

        /**
         * Returns the account's ID.
         */
        public function get id():String {
            return mId;
        }

        /**
         * Returns the account's email, or <code>null</code> if the account has no email associated.
         */
        public function get email():String {
            return mEmail;
        }

        /**
         * Returns the account's phone number, or <code>null</code> if the account has no number associated.
         */
        public function get phoneNumber():String {
            return mPhoneNumber;
        }

        /**
         * Returns the account's phone number country code, or <code>null</code> if the account has no number associated.
         */
        public function get phoneNumberCountryCode():String {
            return mPhoneNumberCountryCode;
        }

    }

}
