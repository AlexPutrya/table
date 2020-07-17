public with sharing class TableController {
    public List<TableRow> tableRows{get; private set;}
    public String selectedConsultantId{get;set;}
    public Integer selectedRow{get;set;}
    public Date selectedDate{
        get{
            if (selectedDate == null) return Date.today();
            return selectedDate;
        }
        set;
    }

    public List<Integer> weekDayNums{ get{return DateHelper.getWeekDayNums();} }
    public List<String> weekDayNames{ get{return DateHelper.getWeekDayNames();} }
    
    public List<SelectOption> consultants {
        get{
            List<SelectOption> options = new List<SelectOption>();
            for(Contact con: [select id, Name from Contact]){
                options.add(new SelectOption(con.Id, con.Name));
            }
            return options;
        }
    }

    public TableController(){
    	initTableData();
    }

    public void initTableData(){
        clearRows();
        fillRows();
    }

    public void fillRows(){
        Set<Id> billingRuleSet = new Set<Id>();
        Set<Id> taskInTimeSet = new Set<Id>();
        Map<Id, List<Time__c>> taskIdToTimes = new Map<Id, List<Time__c>>();
        Date startDateOfWeek =DateHelper.getStartDateOfWeek(this.selectedDate);
        Date endDateOfWeek = DateHelper.getEndDateOfWeek(this.selectedDate);
        System.debug('start '+startDateOfWeek);
        System.debug('end '+endDateOfWeek);
        
        List<Task__c> tasks = [select id, Name, Project__c, Billing_Rule__c from Task__c where Consultant__c = :this.selectedConsultantId];
        List<Time__c> times = [select id, Billing_Rule__c, Project__c, Task__c, Date__c, Time_spend__c
                                from Time__c 
                                where Task__c in :tasks
                                AND (Date__c >= :startDateOfWeek AND Date__c <= :endDateOfWeek)];
        
        for(Time__c tm : times){
            billingRuleSet.add(tm.Billing_Rule__c);
            taskInTimeSet.add(tm.Task__c);
            if(taskIdToTimes.get(tm.Task__c) != null){
                taskIdToTimes.get(tm.Task__c).add(tm);
            }else{
                taskIdToTimes.put(tm.Task__c, new List<Time__c>{tm});
            }
        }

        Map<Id, Billing_Rule__c> billingMap = new Map<Id, Billing_Rule__c>([select id, Non_billable__c from Billing_Rule__c where Id in :billingRuleSet]);
        
        Integer rowNumber = 0;
        for(Task__c task : tasks){
            if(taskInTimeSet.contains(task.Id)){
           		this.tableRows.add(new TableRow(task,
                                                billingMap.get(task.Billing_Rule__c),
                                                taskIdToTimes.get(task.Id), rowNumber, startDateOfWeek));
                rowNumber++;
            }
        }  
    }
    
    public void addRow(){
        Integer rowNumber = this.tableRows.size();
        TableRow tr = new TableRow(
            new Task__c(Consultant__c = this.selectedConsultantId),
            new Billing_Rule__c(),
            new List<Time__c>(),
            rowNumber,
            DateHelper.getStartDateOfWeek(this.selectedDate));

        this.tableRows.add(tr);
    }
    
    public void saveChanges(){
        if(RowValidationUtil.validateColumnsInRow(this.tableRows)){
        	upsertTasks();
            upsertTimes();
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Save successfull'));   
        }
    }

    public void upsertTasks(){
        List<Task__c> tasksToUpsert = new List<Task__c>();
        for(TableRow tr: this.tableRows){
        	tasksToUpsert.add(tr.getTask());
        }
        upsert tasksToUpsert;
    }
    
    public void upsertTimes(){
        List<Time__c> timesToUpsert = new List<Time__c>();
        for(TableRow tr: this.tableRows){
            Task__c task = tr.getTask();
            for(Time__c tm: tr.getTimeSpendsCol()){
                if(tm.Time_spend__c != null){
                    tm.Task__c = task.id;
                    tm.Project__c = task.Project__c;
                    tm.Billing_Rule__c = task.Billing_Rule__c;
                    timesToUpsert.add(tm);
                }
            }
        }
        if(timesToUpsert.size() > 0 ) upsert timesToUpsert;
        initTableData();
    }

    public void deleteTask(){
        TableRow rowToDelete = this.tableRows.remove(this.selectedRow);
        Task__c taskToDelete= rowToDelete.getTask();
        List<Time__c> timesToDelete = [select id from Time__c where Task__c = :taskToDelete.Id];
        if(taskToDelete.Id != null){
            try{
                delete taskToDelete;
                delete timesToDelete;
            }catch(DmlException e){
                System.debug(e.getMessage());
            }
            initTableData();
        }
    }
    
    public void clearRows(){
        this.tableRows = new List<TableRow>();
    }
}