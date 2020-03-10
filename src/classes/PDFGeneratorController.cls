/**
 * Created by User on 05.03.2020.
 */

public with sharing class PDFGeneratorController {
    public PDFGeneratorTemplate template { get; set; }
    public Id recordId { get; set; }
    public Id templateId { get; set; }
    public String objectName { get; set; }
    public SObject choseObject { get; set; }
    public String allFieldsString { get; set; }
    public SObjectType accountType { get; set; }

    public PDFGeneratorController() {

        //Get Id
        this.recordId = ApexPages.currentPage().getParameters().get('recordId');
        // Get template id
        this.templateId = ApexPages.currentPage().getParameters().get('templateId');
        System.debug(recordId);
        //Get the object name
        objectName = recordId.getSobjectType().getDescribe().getName();
        System.debug(objectName);


        //Get all fields on the selected object.
        List <String> AllFieldList = new List <String>();
        this.accountType = Schema.getGlobalDescribe().get(objectName);
        Map<String, Schema.SObjectField> mfields = accountType.getDescribe().fields.getMap();
        //Get string value of these fields
        for (SObjectField fieldName : mfields.values()) {
            String allField = String.valueOf(fieldName);
            AllFieldList.add(allField);
        }

        this.allFieldsString = String.join(AllFieldList, ', ');


        //Get information from object
        this.choseObject = Database.query('SELECT ' + allFieldsString +
                ' FROM ' + objectName +
                ' WHERE Id = : recordId');

        // Get Information from PDF template
        PDF_Template__c templateRecord = [
                SELECT Id, Name,Title__c, Image__c,
                (SELECT Id, Name, Section_Field__c, Number_Column__c FROM PDF_Sections__r)
                FROM PDF_Template__c
                WHERE Id = :templateId
        ];


        this.template = new PDFGeneratorTemplate();
        // Assign value : Title, Image .
        template.imageRendered = templateRecord.Image__c;
        template.titleName = templateRecord.Title__c;
        template.sectionList = new List <PDFGeneratorTemplate.Section>();



        for (PDF_Section__c sectionNameField : templateRecord.PDF_Sections__r) {

            PDFGeneratorTemplate.Section sectionField = new PDFGeneratorTemplate.Section() ;

            // Assign value Section's fields
            sectionField.sectionName = sectionNameField.Name;
            List<String> customFieldsList = sectionNameField.Section_Field__c.split(';');
            sectionField.fieldNameList = customFieldsList;
            sectionField.numberColumn = sectionNameField.Number_Column__c;

            // Add information in PDF section
            template.sectionList.add(sectionField);

        }
    }
}
