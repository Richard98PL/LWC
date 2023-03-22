public without sharing class OptOutController {
    @AuraEnabled
    public static String getEmailByCid(String cid, String ip, String device, String language) {
        createMarketingActivityLog('subscription_page_visit', cid, ip, device, language);
        createLogEvent('Subscription Page Visit', cid);
        return getEmailByCidWithoutInsertingLog(cid);
    }

    private static void createLogEvent(String title, String cid) {
        List<SObject> sobjects = new List<SObject>();
        sobjects.addAll([SELECT Id FROM Lead WHERE IsConverted = FALSE AND cid__c != NULL AND cid__c = :cid]);
        sobjects.addAll([SELECT Id FROM Contact WHERE cid__c != NULL AND cid__c = :cid]);

        List<Event> events = new List<Event>();
        for(SObject record : sobjects){
            Event event = new Event();
            event.Subject = title;
            event.Description = 'cid: ' + cid;
            event.WhoId = record.Id;
            event.WhatId = null; // Set to null if you don't have a related record
            event.ActivityDateTime = System.now();
            event.DurationInMinutes = 1;
            events.add(event);
        }

        Database.insert(events, false);
    }

    @AuraEnabled
    public static void optOut(String cid, String ip, String device, String language) {
        createMarketingActivityLog('subscription_page_opt_out', cid, ip, device, language);
        createLogEvent('Opt Out', cid);

        List<Contact> contacts = [SELECT Id, HasOptedOutOfEmail FROM Contact WHERE cid__c = :cid];
        List<Lead> leads = [SELECT Id, HasOptedOutOfEmail FROM Lead WHERE cid__c = :cid AND IsConverted = FALSE];
        for (Contact c : contacts) {
            c.HasOptedOutOfEmail = true;
            //c.Email_Opt_In__c = false;
            c.Contact_status__c = 'Do not contact';
        }
        for (Lead l : leads) {
            l.HasOptedOutOfEmail = true;
            l.Email_Opt_In__c = false;
            l.Status = 'Do not contact';
        }
        update contacts;
        update leads;
    }

    @AuraEnabled
    public static void optIn(String cid, String ip, String device, String language) {
        createMarketingActivityLog('subscription_page_opt_in', cid, ip, device, language);
        createLogEvent('Opt In', cid);

        List<Contact> contacts = [SELECT Id, HasOptedOutOfEmail FROM Contact WHERE cid__c = :cid];
        List<Lead> leads = [SELECT Id, HasOptedOutOfEmail FROM Lead WHERE cid__c = :cid AND IsConverted = FALSE];
        for (Contact c : contacts) {
            c.HasOptedOutOfEmail = false;
            //c.Email_Opt_In__c = true;
            c.Contact_status__c = 'Contacted';
        }
        for (Lead l : leads) {
            l.HasOptedOutOfEmail = false;
            l.Email_Opt_In__c = true;
            l.Status = 'Contacted';
        }
        update contacts;
        update leads;
    }

    @AuraEnabled
    public static String getEmailByCidWithoutInsertingLog(String cid){
        String email = null;
        List<Contact> contacts = [SELECT Id, Email FROM Contact WHERE cid__c = :cid LIMIT 1];
        if (!contacts.isEmpty()) {
            email = contacts[0].Email;
        } else {
            List<Lead> leads = [SELECT Id, Email FROM Lead WHERE cid__c = :cid AND IsConverted = FALSE LIMIT 1];
            if (!leads.isEmpty()) {
                email = leads[0].Email;
            }
        }

        return email;
    }

    public static void createMarketingActivityLog(String activity, String cid, String ip, String device, String language){
        if(String.isBlank(cid)){
            return;
        }

        insert new Marketing_Cloud_Activity_Log__c(
                Customer_Activity__c = activity,
                Payload__c = '{}',
                Timestamp__c = Datetime.now(),
                URL__c = 'https://www.sentimeter.one/preferences/s/?cid=' + cid,
                Email__c = getEmailByCidWithoutInsertingLog(cid),
                Log__c = '{' + '\n' + '   "cid": "' + cid + '",'
                        + '\n' + '   "ip": "' + ip +
                        + '\n' + '   "device": "' + device +
                        + '\n' + '   "language": "' + language +
                        '"\n' + '}',
                Client_IP__c = ip,
                Customer_device__c = device,
                Customer_language__c = language
        );
    }
}
