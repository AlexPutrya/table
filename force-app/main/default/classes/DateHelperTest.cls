@IsTest
public class DateHelperTest {
	
    @isTest
    public static void testWeekDateFromDate(){
    	Date currentDate = Date.today();
        Datetime dt = (DateTime) currentDate;
        System.assertEquals(DateHelper.getWeekNumFromDate(currentDate),
                            integer.valueOf(dt.format('u'))-1,
                            'Numbers must be equals');
    }
    
    @isTest
    public static void testWeekDayNums(){
        List<Integer> weekDayNums = new List<Integer>();
        for(Integer i=0; i<7; i++){
            weekDayNums.add(i);
        }
        System.assertEquals(DateHelper.getWeekDayNums() ,
                            weekDayNums,
                            'Week day numbers must be equals');
    }
    
    @isTest
    public static void testWeekDayNames(){
        System.assertEquals(DateHelper.getWeekDayNames() ,
                            DateHelper.WEEK_DAY_NUM_TO_NAME.values(),
                            'Week day names must be equals');
    }
    
    @isTest
    public static void testGetStartEndDateOfWeek(){
        Date dayOfWeek = date.newinstance(2020, 7, 15);
        Date sundayOfWeek = date.newinstance(2020, 7, 19);
        Date startOfWeek = date.newinstance(2020, 7, 13);
        
        
        System.assertEquals(DateHelper.getStartDateOfWeek(dayOfWeek),
                            startOfWeek,
                            'Start date of week must be equals for day');
        
        System.assertEquals(DateHelper.getStartDateOfWeek(sundayOfWeek),
                            startOfWeek,
                            'Start date of week must be equals for sunday');
        
        System.assertEquals(DateHelper.getEndDateOfWeek(dayOfWeek),
                            sundayOfWeek,
                            'End date of week must be equals for sunday');
        
    }
}