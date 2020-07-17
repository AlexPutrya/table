public with sharing class DateHelper {

    @TestVisible
    private static final Map<Integer, String> WEEK_DAY_NUM_TO_NAME = new Map<Integer, String>{0 => 'Mon',
                                                                                1 => 'Tue',
                                                                                2 => 'Wed',
                                                                                3 => 'Thu',
                                                                                4 => 'Fri',
                                                                                5 => 'Sat',
                                                                                6 => 'Sun'};
    
    // 0=mon-6=sun
    public static Integer getWeekNumFromDate(Date dateToConvert){
        Datetime dt = (DateTime) dateToConvert;
        return integer.valueOf(dt.format('u'))-1;
    }

    public static List<Integer> getWeekDayNums(){
        return new List<Integer>(WEEK_DAY_NUM_TO_NAME.keySet());
    }

    public static List<String> getWeekDayNames(){
        return WEEK_DAY_NUM_TO_NAME.values();
    }

    public static Date getStartDateOfWeek(Date currentDate){
        //convert to view (1-st day monday)
        if(isSunday(currentDate)){
            Date previewDayForSun = currentDate.addDays(-1);
            return previewDayForSun.toStartofWeek().addDays(1);
        } 
        return currentDate.toStartofWeek().addDays(1);
    }

    public static Date getEndDateOfWeek(Date currentDate){
        return getStartDateOfWeek(currentDate).addDays(6);
    }
    
    public static Boolean isSunday(Date currentDate){
        return (getWeekNumFromDate(currentDate) == 6);
    }
}