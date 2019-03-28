@isTest
global class AvailityAuthProvider_Mock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        //System.assertEquals('https://api.availity.com/availity/v1/token', req.getEndpoint());
        //System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();

        // Get value from test
        String access_token = AvailityAuthProvider_Test.access_token;
        res.setHeader('Content-Type', 'application/json');

        // @TODO format me correctly
        res.setBody('{"access_token":"' + access_token + '"}');
        //res.setMethod('GET');
        res.setStatusCode(200);
        return res;
    }
}