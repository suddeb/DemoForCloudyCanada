public class EmailUtility{
    public static Boolean sendEmail(String emailTo, String emailCC, String emailSubject, String emailBody){
        //Flag to track whether email is sent successfully
        Boolean isSuccess = false;
        
        //Body of attachment in email. It can be replaced with standard sf attachment
        Blob body = Blob.valueOf('Sample Body for email attachment');
        
        //Creating email attachmentattachment specifying content type and file name   
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        attach.setContentType('text/plain');
        attach.setFileName('testAttachment.txt');
   
        //Setting attachment as non-inline attachment.
        attach.setInline(false);
        //Assigning blob to email body
        attach.Body = body;
        
        //Creating singleEmailMessage object
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setUseSignature(false);
        
        //Splitting TO email addresses and adding in array
        String[] toAddresses = new String[]{};
        for(String emailId:emailTo.split(',')){
            if(emailId != null && emailId !=''&& emailId != ' '){
                toAddresses.add(emailId.trim());
            }
        }
        //Assigning TO address array
        mail.setToAddresses(toAddresses);
        
        //Splitting CC email addresses and adding in array
        String[] ccAddresses = new String[]{};
        if(emailCC!= null){
            for(String emailId:emailCC.split(',')){
                if(emailId != null && emailId !=''&& emailId != ' '){
                    ccAddresses.add(emailId);
                }
            }
        }
        
        //Assigning CC address array        
        mail.setCCAddresses(ccAddresses);
        //Setting reply to email address
        //mail.setReplyTo('replyto email address');
        mail.setSubject(emailSubject);
        //Setting content of the email
        mail.setPlainTextBody((emailBody==null?'This email body is empty':emailBody));
        //Optionally you can use below line to add HTML formatted body for email
        //mail.setHtmlBody('<h1>Dear User</h1>');
        //Assigning attachment to email
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach }); 
    
        //Sending email. If any execption occurs, it will be displayed in page
        try{
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });  
            if(results[0].success){
                isSuccess = TRUE;
            }else{
                isSuccess = FALSE;
            }
        } catch(Exception ex){
            isSuccess = FALSE;
        }
    return isSuccess;
    }
}
