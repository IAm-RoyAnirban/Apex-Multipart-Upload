/**
 * @author            : Anirban Roy
 * @description       : Core File Upload Handler class for GDrive and OpenAI
 * @Created on        : 10-12-2023
 * @last modified by  : 11-12-2024
**/

public class FileUploader {
    
    public static void handleUpload(List<ContentDocumentLink> cdlList) {
        for(ContentDocumentLink cdlItem: cdlList) {
            ContentDocumentLink cdl = [SELECT Id, ContentDocument.ContentSize, ContentDocument.FileExtension, ContentDocument.FileType,
                                       ContentDocument.LatestPublishedVersion.Id, ContentDocument.LatestPublishedVersion.Title,
                                       ContentDocument.LatestPublishedVersion.FileExtension, ContentDocument.LatestPublishedVersion.VersionData
                                       FROM ContentDocumentLink WHERE Id =: cdlItem.Id];
            
            ContentDocument cDoc = cdl.ContentDocument;
            // File size restricted 11 MB. You can add other conditions, like verifying the fileTypes with cDoc.FileExtension
            if(cDoc.ContentSize < 200 || cDoc.ContentSize > 11534336 || cDoc.FileType == 'SNOTE') {
                continue;
            }
            ContentVersion cVersion = cdl.ContentDocument.LatestPublishedVersion;
            String base64File = EncodingUtil.base64Encode(cVersion.VersionData);
            String file_name = cVersion.Title + '.' + cVersion.FileExtension;
            
            String endpoint1 = 'files';
            uploadToVectorStore(file_name, EncodingUtil.base64Decode(base64File), cVersion.Id, endpoint1);
            
            String endpoint2 = 'upload/drive/v3/files?uploadType=multipart';
            uploadtoGDrive(file_name, EncodingUtil.base64Decode(base64File), cVersion.Id, endpoint2);
        }
    }
    
    @future(callout=true)
    private static void uploadToVectorStore(String file_name, Blob file_body, Id version_id, String endPoint) {
        String boundary = '----------------------------741e90d31eff';
        String header = '--' + boundary + '\n' +
            'Content-Disposition: form-data; name="purpose"\n\nassistants\n' +
            '--' + boundary + '\n' +
            'Content-Disposition: form-data; name="file"; filename="' + file_name + '";\n' +
            'Content-Type: application/octet-stream';
        
        String footer = '--'+boundary+'--';
        String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        while(headerEncoded.endsWith('='))
        {
            header+=' ';
            headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        }
        String bodyEncoded = EncodingUtil.base64Encode(file_body);
        
        Blob bodyBlob = null;
        String last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4,bodyEncoded.length());
      
        if(last4Bytes.endsWith('==')) {
            last4Bytes = last4Bytes.substring(0,2) + '0K';
            bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
        }
        else if(last4Bytes.endsWith('=')) {
            last4Bytes = last4Bytes.substring(0,3) + 'N';
            bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
            footer = '\n' + footer;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
        }
        else {
            footer = '\r\n' + footer;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
        }
        
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type','multipart/form-data; boundary='+boundary);
        req.setMethod('POST');
        req.setEndpoint('callout:ChatGPT_Access/' + endpoint);
        req.setBodyAsBlob(bodyBlob);
        req.setTimeout(120000);
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        Integer statusCode = res.getStatusCode();
        GPTResponseDetail responseWrapper = (GPTResponseDetail) JSON.deserialize(res.getBody(), GPTResponseDetail.class);
        
        if(statusCode == 200) {
            System.debug('file ID: ' + responseWrapper.id);
            //now update the ID in the system!
        }
        else {
            System.debug('Error Message: ' + responseWrapper.error.message);
            System.debug('Error Code: ' + responseWrapper.error.code);
        }
    }
    
    @future(callout=true)
    private static void uploadtoGDrive(String file_name, Blob file_body, Id version_id, String endPoint) {
        String formattedTime = DateTime.now().format();
        String metadataJson = '{"name":"' + file_name + '","description":"This file was uploaded to Salesforce on ' + formattedTime + '"}';
        
        String boundary = '----------------------------741e90d31eff';
        String header = '--' + boundary + '\n' +
            'Content-Disposition: form-data; name="metadata"; filename="fileMetadata.json"\n' +
            'Content-Type: application/json\n\n' + metadataJson + '\n' +
            '--' + boundary + '\n' +
            'Content-Disposition: form-data; name="file"; filename="' + file_name + '"\n' +
            'Content-Type: application/octet-stream\n\n';
        
        String footer = '--'+boundary+'--';
        String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        while(headerEncoded.endsWith('='))
        {
            header+=' ';
            headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        }
        String bodyEncoded = EncodingUtil.base64Encode(file_body);
        
        Blob bodyBlob = null;
        String last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4,bodyEncoded.length());
        
        if(last4Bytes.endsWith('==')) {
            last4Bytes = last4Bytes.substring(0,2) + '0K';
            bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
        }
        else if(last4Bytes.endsWith('=')) {
            last4Bytes = last4Bytes.substring(0,3) + 'N';
            bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
            footer = '\n' + footer;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
        }
        else {
            footer = '\r\n' + footer;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
        }
        
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type','multipart/form-data; boundary='+boundary);
        req.setMethod('POST');
        req.setEndpoint('callout:DriveSync_Access/' + endpoint);
        req.setBodyAsBlob(bodyBlob);
        req.setTimeout(120000);
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        Integer statusCode = res.getStatusCode();
        DriveResponseDetail responseWrapper = (DriveResponseDetail) JSON.deserialize(res.getBody(), DriveResponseDetail.class);
        
        System.debug('=> ' + statusCode);
        if(statusCode == 200) {
            System.debug('file ID: ' + responseWrapper.id);
            //now update the ID in the system!
        }
        else {
            System.debug('Error Message: ' + responseWrapper.error.message);
            System.debug('Error Code: ' + responseWrapper.error.code);
        }
    }
    
    public class GPTResponseDetail {
        public String id;
        public GPTError error;
    }
    
    public class GPTError {
        public String code;			//error code
        public String message;		//error message
    }
    
    public class DriveResponseDetail {
        public String id;
        public DriveError error;
    }
    
    public class DriveError {
        public Integer code;		//error code
        public String message;		//error message
    }
}