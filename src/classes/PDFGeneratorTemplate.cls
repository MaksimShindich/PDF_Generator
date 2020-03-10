/**
 * Created by User on 25.02.2020.
 */

public with sharing class PDFGeneratorTemplate {

    public String titleName { get; set; }
    public List <Section> sectionList { get; set; }
    public String imageRendered {get;set;}

    public class Section {
        public String sectionName { get; set; }
        public List <String> fieldNameList { get; set; }
        public Decimal numberColumn {get;set;}

    }


}


