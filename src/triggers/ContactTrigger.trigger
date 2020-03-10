/**
 * Created by User on 17.02.2020.
 */
trigger ContactTrigger on Contact (after insert , before delete ) {
    if (Trigger.isInsert) {
        Map<String, String> priority = new Map<String, String>{
                'Primary' => 'High', 'Secondary' => 'Medium', 'Tertiary' => 'Low'
        };
        Set<Id> accountIdSet = new Set<Id>();
        for (Contact contactRecord : Trigger.new) {

            accountIdSet.add(contactRecord.AccountId);

        }
        List<Account> accountList = new List<Account>([SELECT Id, OwnerId FROM Account WHERE Id IN :accountIdSet]);
        system.debug(accountIdSet);
        Map<Id, Account> accountMap = new Map<Id, Account>();
        for (Account accountRecord : accountList) {
            accountMap.put(accountRecord.Id, accountRecord);

        }

        List<Case> csList = new List<Case>();
        for (Contact con : trigger.new) {
            Case cs = new Case();
            cs.Priority = priority.get(con.Level__c);
            cs.Status = 'Working';
            cs.Origin = 'New Contact';
            cs.ContactId = con.Id;
            if (cs.AccountId != null) {
                cs.AccountId = con.AccountId;
                Account currentAccount = accountMap.get(con.AccountId);
                cs.OwnerId = currentAccount.OwnerId;
            }

            csList.add(cs);
        }
        insert csList;
    }
    if (Trigger.isDelete) {

        List<Case> csList = [select Id, ContactId from Case where ContactId in :trigger.old];
        if (csList != null && csList.size() != 0) {
            delete csList;
        }
    }
}




