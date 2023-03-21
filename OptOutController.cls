public without sharing class OptOutController {
    @AuraEnabled(cacheable=true)
    public static String getEmailByCid(String cid) {
        String email = null;
        List<Contact> contacts = [SELECT Id, Email FROM Contact WHERE cid__c = :cid LIMIT 1];
        if (!contacts.isEmpty()) {
            email = contacts[0].Email;
        } else {
            List<Lead> leads = [SELECT Id, Email FROM Lead WHERE cid__c = :cid LIMIT 1];
            if (!leads.isEmpty()) {
                email = leads[0].Email;
            }
        }
        return email;
    }

    @AuraEnabled
    public static void optOut(String cid) {
        List<Contact> contacts = [SELECT Id, HasOptedOutOfEmail FROM Contact WHERE cid__c = :cid];
        List<Lead> leads = [SELECT Id, HasOptedOutOfEmail FROM Lead WHERE cid__c = :cid];
        for (Contact c : contacts) {
            c.HasOptedOutOfEmail = true;
            //c.Email_Opt_In__c = false;
        }
        for (Lead l : leads) {
            l.HasOptedOutOfEmail = true;
            l.Email_Opt_In__c = false;
        }
        update contacts;
        update leads;
    }

    @AuraEnabled
    public static void optIn(String cid) {
        List<Contact> contacts = [SELECT Id, HasOptedOutOfEmail FROM Contact WHERE cid__c = :cid];
        List<Lead> leads = [SELECT Id, HasOptedOutOfEmail FROM Lead WHERE cid__c = :cid];
        for (Contact c : contacts) {
            c.HasOptedOutOfEmail = false;
            //c.Email_Opt_In__c = true;
        }
        for (Lead l : leads) {
            l.HasOptedOutOfEmail = false;
            l.Email_Opt_In__c = true;
        }
        update contacts;
        update leads;
    }
}
