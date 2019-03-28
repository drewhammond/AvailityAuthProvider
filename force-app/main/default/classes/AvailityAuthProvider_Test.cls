/**
 * Created by drewhammond on 1/7/18.
 */

@IsTest
public class AvailityAuthProvider_Test {


    public static String authProvider = 'Availity';
    public static String customMetadataTypeApiName = 'Availity_Setting__mdt';
    public static String stateToPropagate = 'TEST_STATE';
    public static String oauth_token = 'TEST_TOKEN';
    public static String state = 'TEST_TOKEN';
    public static String client_id;
    public static String client_secret = 'ABC123';
    public static String access_token_url = 'TEST_ACCESS_TOKEN_URL';
    public static String callback_url = '';
    public static String refresh_token = 'secret';
    public static String access_token = 'TEST_ACCESS_TOKEN';
    public static String user_name = 'Availity User';


    /**
     * Define mock configuration values
     *
     * @return
     */
    private static Map<String, String> setupAuthProviderConfig() {
        Map<String, String> authProviderConfiguration = new Map<String, String>();

        authProviderConfiguration.put('Client_ID__c', client_id);
        authProviderConfiguration.put('Client_Secret__c', client_secret);
        authProviderConfiguration.put('Access_Token_URL__c', access_token_url);
        authProviderConfiguration.put('Callback_URL__c', callback_url);

        return authProviderConfiguration;
    }


    @IsTest static void testIntiateMethod() {
        AvailityAuthProvider availityAuthProvider = new AvailityAuthProvider();
        Map<String, String> authProviderConfiguration = setupAuthProviderConfig();

        PageReference expected = new PageReference(authProviderConfiguration.get('Callback_URL__c') + '?state=' + stateToPropagate);
        PageReference actual = availityAuthProvider.initiate(authProviderConfiguration, stateToPropagate);

        System.assertEquals(expected.getUrl(), actual.getUrl());
    }

    @IsTest static void testgetUserInfoMethod() {

        AvailityAuthProvider availityAuthProvider = new AvailityAuthProvider();
        Map<String, String> authProviderConfiguration = setupAuthProviderConfig();

        Auth.UserData expected = new Auth.UserData(null, null, null, null, null, null, user_name, null, authProvider, null, new Map<String, String>());
        Auth.UserData actual = availityAuthProvider.getUserInfo(authProviderConfiguration, new Auth.AuthProviderTokenResponse('Availity', oauth_token, null, state));

        // @TODO: Do we really need to compare each value individually? Optimize me
        System.assertEquals(expected.firstName, actual.firstName);
        System.assertEquals(expected.lastName, actual.lastName);
        System.assertEquals(expected.fullName, actual.fullName);
        System.assertEquals(expected.provider, actual.provider);
        System.assertEquals(expected.siteLoginUrl, actual.siteLoginUrl);
        System.assertEquals(expected.username, actual.username);
        System.assertEquals(expected.email, actual.email);
        System.assertEquals(expected.identifier, actual.identifier);
        System.assertEquals(expected.link, actual.link);
        System.assertEquals(expected.attributeMap, actual.attributeMap);

    }

    @IsTest static void testgetCustomMetadataTypeMethod() {
        AvailityAuthProvider availityAuthProvider = new AvailityAuthProvider();

        String expected = customMetadataTypeApiName;
        String actual = availityAuthProvider.getCustomMetadataType();

        System.assertEquals(expected, actual);
    }


    @IsTest static void testhandleCallbackMethod() {
        AvailityAuthProvider availityAuthProvider = new AvailityAuthProvider();
        Map<String, String> authProviderConfiguration = new Map<String, String>();

        authProviderConfiguration.put('Client_ID__c', client_id);
        authProviderConfiguration.put('Client_Secret__c', client_secret);
        authProviderConfiguration.put('Access_Token_URL__c', access_token_url);

        Test.setMock(HttpCalloutMock.class, new AvailityAuthProvider_Mock());

        Map<String, String> queryParams = new Map<String, String>();
        queryParams.put('code', 'code');
        queryParams.put('state', state);

        Auth.AuthProviderCallbackState callbackState = new Auth.AuthProviderCallbackState(null, null, queryParams);
        Auth.AuthProviderTokenResponse expected = new Auth.AuthProviderTokenResponse(authProvider, access_token, 'secret', state);
        Auth.AuthProviderTokenResponse actual = availityAuthProvider.handleCallback(authProviderConfiguration, callbackState);

        System.assertEquals(expected.oauthSecretOrRefreshToken, actual.oauthSecretOrRefreshToken);
        System.assertEquals(expected.oauthToken, actual.oauthToken);
        System.assertEquals(expected.provider, actual.provider);
        System.assertEquals(expected.state, actual.state);
    }


    @IsTest static void testRefreshMethod() {
        AvailityAuthProvider availityAuthProvider = new AvailityAuthProvider();
        Map<String, String> authProviderConfiguration = new Map<String, String>();

        authProviderConfiguration.put('Client_ID__c', client_id);
        authProviderConfiguration.put('Client_Secret__c', client_secret);
        authProviderConfiguration.put('Access_Token_URL__c', access_token_url);

        Test.setMock(HttpCalloutMock.class, new AvailityAuthProvider_Mock());

        Auth.OAuthRefreshResult expectedResult = new Auth.OauthRefreshResult(access_token, refresh_token);
        Auth.OAuthRefreshResult actualResult = availityAuthProvider.refresh(authProviderConfiguration, refresh_token);

        System.assertEquals(expectedResult.accessToken, actualResult.accessToken);
        System.assertEquals(expectedResult.refreshToken, actualResult.refreshToken);
        System.assertEquals(expectedResult.error, actualResult.error);
    }
}

