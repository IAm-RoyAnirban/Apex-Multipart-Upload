/**
 * @author            : Anirban Roy
 * @description       : Test class for Trigger and file Uploader
 * @Created on        : 10-12-2023
 * @last modified by  : 11-12-2024
**/

@isTest
public class FileUploaderTest {
    
    @testSetup
    static void setup() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        String uid = UUID.randomUUID().toString().substring(0, 8);
        User user = new User(Alias = uid, Email = uid+'@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'TestUser',
                             LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = p.Id, TimeZoneSidKey = 'America/Los_Angeles',
                             UserName = uid + '@testorg.com');
        insert user;
    }
    
    /* Single Success Test, as the mock payload for success callout is same */
    @isTest
    private static void testUploadSuccess() {
        ContentVersion cVersion = new ContentVersion(Title = 'Test Document 1', PathOnClient = 'TestDocument1.pdf', IsMajorVersion = true);
        
        // To increase contentVersion size more than 200 bytes
        cVersion.VersionData = Blob.valueOf('Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.');
        
        User user = [SELECT Id FROM User WHERE LastName = 'TestUser' LIMIT 1];
        System.runAs(user) {
            Test.startTest();
            
            Test.setMock(HttpCalloutMock.class, new SuccessMock());
            insert cVersion;
            
            List<ContentDocument> cDocs = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            Assert.areEqual(cDocs.size(), 1, 'Test Assertion failed. - 1');
            
            Test.stopTest();
        }
    }
    
    @isTest
    private static void testUploadGPTError() {
        ContentVersion cVersion = new ContentVersion(Title = 'Test Document 2', PathOnClient = 'TestDocument2.pdf', IsMajorVersion = true);
        
        // To increase contentVersion size more than 200 bytes
        cVersion.VersionData = Blob.valueOf('Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.');
        
        User user = [SELECT Id FROM User WHERE LastName = 'TestUser' LIMIT 1];
        System.runAs(user) {
            Test.startTest();
            
            Test.setMock(HttpCalloutMock.class, new GPTErrorMock());
            insert cVersion;
            
            List<ContentDocument> cDocs = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            Assert.areEqual(cDocs.size(), 1, 'Test Assertion failed. - 2');
            
            Test.stopTest();
        }
    }
    
    /* Test method to test Gdrive API Upload Error. Enable uploadtoGDrive() method. */
    @isTest
    private static void testUploadGdriveError() {
        ContentVersion cVersion = new ContentVersion(Title = 'Test Document 3', PathOnClient = 'TestDocument3.pdf', IsMajorVersion = true);
        
        // To increase contentVersion size more than 200 bytes
        cVersion.VersionData = Blob.valueOf('Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.');
        
        User user = [SELECT Id FROM User WHERE LastName = 'TestUser' LIMIT 1];
        System.runAs(user) {
            Test.startTest();
            
            Test.setMock(HttpCalloutMock.class, new GDriveErrorMock());
            insert cVersion;
            
            List<ContentDocument> cDocs = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            Assert.areEqual(cDocs.size(), 1, 'Test Assertion failed. - 3');
            
            Test.stopTest();
        }
    }

    /**
     * Mock implementation for a successful HTTP callout response.
     * This mock is same for Both OpenAI or GDrive API, as both returns the File ID in same JSON Response format.
	*/
    public class SuccessMock implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"id":"file_123"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    // Mock implementation for OpenAI Error HTTP callout response
    public class GPTErrorMock implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"error":{"message":"This is a sample Error","code":"SAMPLE_ERROR"}}');
            res.setStatusCode(400);
            return res;
        }
    }
    
    // Mock implementation for Google Drive Error HTTP callout response
    public class GDriveErrorMock implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"error":{"message":"This is a sample Error","code":400}}');
            res.setStatusCode(400);
            return res;
        }
    }
}