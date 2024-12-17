/**
 * @author            : Anirban Roy
 * @description       : ContentDocumentLink onInsert Trigger with file upload handler
 * @Created on        : 10-12-2023
 * @last modified by  : 11-12-2024
**/

trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert) {
    
    if(Trigger.isAfter && Trigger.isInsert) {
        FileUploader.handleUpload(Trigger.new);
    }
}