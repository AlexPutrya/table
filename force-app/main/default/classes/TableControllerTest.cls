@isTest
public class TableControllerTest {
	
    @testSetup
    public static void prepareData(){
        Contact con = new Contact(FirstName = 'Alex', LastName= 'P');
        insert con;
        
        Opportunity opp = new Opportunity(Name ='Opp 1', Type='New Customer', Amount= 10000, CloseDate = Date.today(), StageName = 'ClosedWon');
        insert opp;
        
        Project__c proj = new Project__c(Name ='Project1', Opportunity__c = opp.Id, Primary_Contact__c = con.Id);
        insert proj;
        
        Billing_rule__c billRule = new Billing_rule__c(Name='BL1', Active__c = true, Client_rate__c = 5, Consultant_rate__c = 5, Non_billable__c = true, Project__c= proj.Id);
        insert billRule;
        
        Date selectedDate = Date.today();
        Date startOfWeek = DateHelper.getStartDateOfWeek(selectedDate);
        
       	List<Task__c> tasks = new List<Task__c>();
        List<Time__c> times = new List<Time__c>();
        
        for(Integer i=0; i<5; i++){
        	tasks.add(new Task__c(Name= 'Task'+i, Billing_Rule__c = billRule.Id, Consultant__c = con.Id, Project__c = proj.Id));
        }
        insert tasks;
        
        for(Task__c task : tasks){
        	for(Integer i=0; i<5; i++){
        		times.add(new Time__c(Billing_Rule__c = billRule.Id, Date__c = startOfWeek.addDays(i), Project__c  = proj.Id, Task__c = task.Id, Time_spend__c = 1));
        	}
        }
        
        insert times;
    }
    
    @isTest
    public static void testTableController(){
        Contact consultant = [select Id from Contact limit 1];
        Project__c project = [select id from Project__c limit 1];
        
        TableController table = new TableController();
        System.assertEquals(1 ,table.consultants.size(), 'Consultants and consultant list must be equals');
        
        table.selectedConsultantId = consultant.Id;
        table.selectedDate = Date.today();
        table.initTableData();
        
        List<Task__c> tasks = [select id from Task__c where Consultant__c = :consultant.Id];
        System.assertEquals( tasks.size() ,table.tableRows.size(), 'Task list must be equals table rows');
        
        Integer initialSize = table.tableRows.size();
        table.addRow();
        table.tableRows[initialSize].getTask().Project__c = project.Id;
        table.tableRows[initialSize].getTask().Name = 'New task';
        System.assertEquals( initialSize+1 ,table.tableRows.size(), 'List size must be equals after add row');
        
        List<Time__c> timesBeforeSave = [select id from Time__c where Project__c = :project.Id];
        
        List<Time__c> timesFromAddedRow = table.tableRows[initialSize].getTimeSpendsCol();
        for(Time__c tm : timesFromAddedRow){
            tm.Time_spend__c = 1;
        }
        table.saveChanges();
        List<Time__c> timesAfterSave = [select id from Time__c where Project__c = :project.Id];
        List<Task__c> tasksAfterSave = [select id from Task__c where Consultant__c = :consultant.Id];
        
        System.assertEquals( tasksAfterSave.size(), table.tableRows.size(), 'Task size after upsert must be equals');
        System.assertEquals( timesBeforeSave.size()+7, timesAfterSave.size(), 'Times size after upsert must be greater on 7');
        
        table.selectedRow = initialSize;
        table.deleteTask();
        System.assertEquals( initialSize ,table.tableRows.size(), 'List size must be equals after delete row');
        
        
    }
}