public class RowValidationUtil {
    
    public static Boolean validateColumnsInRow(List<TableRow> tableRows){
   		return validateTaskCol(tableRows);
    }
    
    public static Boolean validateTaskCol(List<TableRow> tableRows){
        System.debug('Validate task col');
        List <Integer> errorRows = new List<Integer>();
        for(TableRow tr : tableRows){
            System.debug('Task name '+ tr.getTask().Name);
            if(tr.getTask().Name == null){
            	errorRows.add(tr.getRowNumber()+1);
            }
        }
        if(errorRows.size() > 0){
            System.debug('Please check errors in ' + errorRows + ' rows');
        	ApexPages.addmessage(new ApexPages.message(
                ApexPages.severity.WARNING,'Please check errors in ' + errorRows + ' rows, task fields must not be empty'));
            return false;
        }
        return true;
    }
    
    
}