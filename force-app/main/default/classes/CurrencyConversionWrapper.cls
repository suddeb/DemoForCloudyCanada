public with sharing class CurrencyConversionWrapper {
    public Double USD_CAD;

    
    public static CurrencyConversionWrapper parse(String json) {
        return (CurrencyConversionWrapper) System.JSON.deserialize(json, CurrencyConversionWrapper.class);
    }
}