public with sharing class Utility {
    private static Organization Org {get { if(org == null) {
        return [SELECT IsSandbox FROM Organization LIMIT 1];
    } else { return org; } } set;}
    private static URL baseURL = System.URL.getSalesforceBaseUrl();
    public static Boolean isProduction = !Org.isSandbox;
    public static Boolean isSandbox = Org.isSandbox;
    public static Boolean isDevOrg = String.ValueOf(baseURL).contains('-dev-ed.my'); 
}
