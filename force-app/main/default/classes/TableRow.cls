public with sharing class TableRow {
    private Task__c task;
    private Billing_Rule__c billingRule;
    private Integer rowNumber;
    private Map<Date, Time__c> dateToTimeSpend= new Map<Date, Time__c>();

    public TableRow(Task__c task, Billing_Rule__c billingRule, List<Time__c> times, Integer rowNumber, Date startOfWeek){
        this.task = task;
        this.billingRule = billingRule;
        this.rowNumber = rowNumber;
        fillTimeSpendToDayColumn(startOfWeek);
        if(times != null){
            setExistingTimesToColumn(times);
        }
    }

    public List<Time__c> getTimeSpendsCol(){
        return this.dateToTimeSpend.values();
    }

    public Task__c getTask(){
        return this.task;
    }
    
    public Billing_Rule__c getBillingRule(){
        return this.billingRule;
    }
    
    public Integer getRowNumber(){
        return this.rowNumber;
    }

    private void fillTimeSpendToDayColumn(Date startOfWeek){
        for(Integer i =0; i<7; i++){
            Date currentDate = startOfWeek.addDays(i);
            this.dateToTimeSpend.put(currentDate, new Time__c(Date__c = currentDate));
        }
    }

    private void setExistingTimesToColumn(List<Time__c> times){
        for(Time__c tm : times){
            this.dateToTimeSpend.put(tm.Date__c, tm);
        }
    }
}