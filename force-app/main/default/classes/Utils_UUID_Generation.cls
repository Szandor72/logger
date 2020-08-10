public with sharing class Utils_UUID_Generation {
    // prettier-ignore
    static List<String> hexMap = new List<String> {
        '0', '1', '2', '3', '4', '5', '6', '7',
        '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'
    };
    public static String newGuid() {
        String randomStringAsHex = EncodingUtil.ConvertTohex(Crypto.GenerateAESKey(128));

        String versionHexBits = randomStringAsHex.SubString(14, 16); // 7th bit
        String variantHexBits = randomStringAsHex.SubString(18, 20); // 9th bit

        Integer versionIntBits = convertHexToInt(versionHexBits);
        Integer variantIntBits = convertHexToInt(variantHexBits);

        Integer versionShiftedIntBits = versionIntBits & 15 | 64; // (i & 0x0f) | 0x40
        Integer variantShiftedIntBits = variantIntBits & 63 | 128; // (i & 0x3f) | 0x80

        String versionShiftedHexBits = convertIntToHex(versionShiftedIntBits); // Always begins with 4
        String variantShiftedHexBits = convertIntToHex(variantShiftedIntBits); // Always begins with one of 8,9,a,b

        String guid =
            randomStringAsHex.SubString(0, 8) +
            '-' +
            randomStringAsHex.SubString(8, 12) +
            '-' +
            versionShiftedHexBits +
            randomStringAsHex.SubString(14, 16) +
            '-' +
            variantShiftedHexBits +
            randomStringAsHex.SubString(18, 20) +
            '-' +
            randomStringAsHex.substring(20);

        return guid;
    }

    static Integer convertHexToInt(String hex) {
        Integer d0 = hexMap.IndexOf(hex.Substring(1, 2));
        Integer d1 = hexMap.IndexOf(hex.Substring(0, 1));

        Integer intval = d0 + (d1 * 16);
        return intval;
    }

    static String convertIntToHex(Integer intval) {
        // https://stackoverflow.com/a/13465128
        String hs0 = hexMap.Get(intval & 15); // i & 0x0f
        String hs1 = hexMap.Get(((intval >> 4) & 15)); //(i >> 4) & 0x0f
        return hs1 + hs0;
    }
}
