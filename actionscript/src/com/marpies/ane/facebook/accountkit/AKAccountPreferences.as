package com.marpies.ane.facebook.accountkit {

    /**
     * Accesses account preferences that are stored on the Account Kit servers
     * for the associated app and account. Access it using AccountKit.accountPreferences getter.
     */
    public class AKAccountPreferences {

        /* Singleton stuff */
        private static var mCanInitialize:Boolean;
        private static var mInstance:AKAccountPreferences;

        /**
         * @private
         */
        public function AKAccountPreferences() {
            if( !mCanInitialize ) throw new Error( "AKAccountPreferences is a singleton, use getInstance()." );
        }

        /**
         * @private
         */
        internal static function getInstance():AKAccountPreferences {
            if( !mInstance ) {
                mCanInitialize = true;
                mInstance = new AKAccountPreferences();
                mCanInitialize = false;
            }
            return mInstance;
        }

        /**
         * Loads all user preferences.
         *
         * @param callback Function with the following signature:
         * <listing version="3.0">
         * function onAccountKitPreferencesLoaded( preferences:Object, errorMessage:String ):void {
         *     if( errorMessage != null ) {
         *         trace( errorMessage );
         *     } else {
         *         for( var key:String in preferences ) {
         *             trace( "Preference", key, "has value", preferences[key] );
         *         }
         *     }
         * };
         * </listing>
         */
        public function loadPreferences( callback:Function ):void {
            AccountKit.loadPreferences( callback );
        }

        /**
         * Loads a single preference.
         *
         * @param key The key for the preference to load.
         * @param callback Function with the following signature:
         * <listing version="3.0">
         * function onAccountKitPreferenceLoaded( key:String, value:String, errorMessage:String ):void {
         *     if( errorMessage != null ) {
         *         trace( errorMessage );
         *     } else {
         *         // the preference has been loaded
         *         trace( key, value );
         *     }
         * };
         * </listing>
         */
        public function loadPreference( key:String, callback:Function ):void {
            if( key === null ) throw new ArgumentError( "Parameter key cannot be null." );

            AccountKit.loadPreference( key, callback );
        }

        /**
         * Sets a preference for the given key.
         *
         * @param key The key for the preference to set.
         * @param value The preference value.
         * @param callback Function with the following signature:
         * <listing version="3.0">
         * function onAccountKitPreferenceSet( key:String, value:String, errorMessage:String ):void {
         *     if( errorMessage != null ) {
         *         trace( errorMessage );
         *     } else {
         *         // the preference has been set
         *         trace( key, value );
         *     }
         * };
         * </listing>
         */
        public function setPreference( key:String, value:String, callback:Function ):void {
            if( key === null ) throw new ArgumentError( "Parameter key cannot be null." );
            if( value === null ) throw new ArgumentError( "Parameter value cannot be null." );

            AccountKit.setPreference( key, value, callback );
        }

        /**
         * Deletes a preference for the given key.
         *
         * @param key The key for the preference to delete.
         * @param callback Function with the following signature:
         * <listing version="3.0">
         * function onAccountKitPreferenceDeleted( key:String, errorMessage:String ):void {
         *     if( errorMessage != null ) {
         *         trace( errorMessage );
         *     } else {
         *         // the preference has been deleted
         *         trace( key );
         *     }
         * };
         * </listing>
         */
        public function deletePreference( key:String, callback:Function ):void {
            if( key === null ) throw new ArgumentError( "Parameter key cannot be null." );

            AccountKit.deletePreference( key, callback );
        }

    }

}
