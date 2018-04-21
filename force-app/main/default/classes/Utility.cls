public with sharing class Utility {
    private static Organization Org {get { if(org == null) {
        return [SELECT IsSandbox FROM Organization LIMIT 1];
    } else { return org; } } set;}
    private static URL baseURL = System.URL.getSalesforceBaseUrl();
    public static Boolean isProduction = !Org.isSandbox;
    public static Boolean isSandbox = Org.isSandbox;
    public static Boolean isDevOrg = String.ValueOf(baseURL).contains('-dev-ed.my'); 

    public static String getUniqueId() {
        String milliseconds = String.ValueOf(System.Now().getTime()); //unix timestamp
        Blob pseudoHash = Blob.ValueOf(milliseconds + String.ValueOf(Crypto.getRandomInteger()));
        String uniqueString = EncodingUtil.convertToHex(pseudoHash);
        uniqueString = uniqueString.length() > 255 ? uniqueString.substring(0,255) : uniqueString;
        return uniqueString;
    }
}
