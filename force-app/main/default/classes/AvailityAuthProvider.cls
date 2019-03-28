/**
 * Availity Auth Provider for Named Credentials
 * Copyright 2018 Drew Hammond
 */
global class AvailityAuthProvider extends Auth.AuthProviderPluginClass {

    private String authProvider = 'Availity';

    private String customMetadataTypeApiName = 'Availity_Setting__mdt';

    public String client_id;
    public String client_secret;
    public String access_token_url;


    // Name for the generic username displayed in the named credential configuration.
    private String user_name = 'Availity User';

    public class AvailityResponse {
        public String token_type;
        public String access_token;
        public Integer expires_in;
        public String scope;
    }

    //name of custom metadata type to embed configuration fields in auth provider
    global String getCustomMetadataType() {
        return customMetadataTypeApiName;
    }

    /**
     * Initiate the authentication by redirecting back to the callback URL immediately - No user interaction required
     *
     * @param authProviderConfiguration
     * @param stateToPropagate
     *
     * @return
     */
    public PageReference initiate(Map<string, string> authProviderConfiguration, String stateToPropagate) {
        return new PageReference(authProviderConfiguration.get('Callback_URL__c') + '?state=' + stateToPropagate);
    }

    /**
     * Handle auth callback and use named credential configuration to fetch a fresh access token
     *
     * @param authProviderConfiguration
     * @param state
     *
     * @return
     */
    public Auth.AuthProviderTokenResponse handleCallback(Map<string, string> authProviderConfiguration, Auth.AuthProviderCallbackState state) {
        return new Auth.AuthProviderTokenResponse(authProvider, fetchToken(authProviderConfiguration), 'secret', state.queryParameters.get('state'));
    }

    /**
     * "Refresh" our access token by just retrieving a new one the same way we do initially. No refresh token required.
     *
     * @param authProviderConfiguration
     * @param refreshToken
     *
     * @return
     */
    public override Auth.OAuthRefreshResult refresh(Map<String, String> authProviderConfiguration, String refreshToken) {
        return new Auth.OAuthRefreshResult(fetchToken(authProviderConfiguration), 'secret');
    }

    /**
     * Return dummy response since there is no user attached to this type of authentication
     *
     * @param authProviderConfiguration
     * @param response
     *
     * @return
     */
    public Auth.UserData getUserInfo(Map<string, string> authProviderConfiguration, Auth.AuthProviderTokenResponse response) {
        return new Auth.UserData(null, null, null, null, null, null, user_name, null, authProvider, null, new Map<String, String>());
    }

    /**
     * Perform actual callout to token endpoint to retrieve a new access token
     *
     * @param authProviderConfiguration
     *
     * @return
     */
    private String fetchToken(Map<String, String> authProviderConfiguration) {

        client_id = authProviderConfiguration.get('Client_ID__c');
        client_secret = authProviderConfiguration.get('Client_Secret__c');
        access_token_url = authProviderConfiguration.get('Access_Token_URL__c');

        // Fetch access token
        HttpRequest req = new HttpRequest();

        String body = 'grant_type=client_credentials&client_id=' + client_id + '&client_secret=' + client_secret + '&scope=hipaa';

        req.setEndpoint(access_token_url);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('Accept', 'application/json');
        req.setMethod('POST');
        req.setBody(body);

        HTTPResponse res = new Http().send(req);

        String token = deserializeToken(res);

        return token;
    }

    /**
     * Deserialize response and return only access token as a string
     *
     * @param res
     *
     * @return
     */
    private String deserializeToken(HTTPResponse res) {

        String responseBody = res.getBody();

        AvailityResponse parsedResponse = (AvailityResponse) System.JSON.deserialize(responseBody, AvailityResponse.class);

        return parsedResponse.access_token;
    }

}