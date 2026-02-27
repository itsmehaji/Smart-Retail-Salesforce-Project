public without sharing class RetailPOSController {

    // =====================================
    // Fetch Active Products
    // =====================================
    @AuraEnabled(cacheable=true)
    public static List<Retail_Product__c> getActiveProducts(String searchKey) {

        if (String.isBlank(searchKey)) {
            return new List<Retail_Product__c>();
        }

        String searchPattern = '%' + searchKey + '%';

        return [
            SELECT Id, Name, Price__c, Available_Stock__c
            FROM Retail_Product__c
            WHERE Is_Active__c = true
            AND Name LIKE :searchPattern
            ORDER BY Name
            LIMIT 50
        ];
    }


    // =====================================
    // Search Customers
    // =====================================
    @AuraEnabled(cacheable=true)
    public static List<Retail_Customer__c> searchCustomers(String searchKey) {

        if (String.isBlank(searchKey)) {
            return new List<Retail_Customer__c>();
        }

        String searchPattern = '%' + searchKey + '%';

        return [
            SELECT Id, Name
            FROM Retail_Customer__c
            WHERE Name LIKE :searchPattern
            ORDER BY Name
            LIMIT 10
        ];
    }


    // =====================================
    // Create Customer (Duplicate Safe)
    // =====================================
    @AuraEnabled
    public static Retail_Customer__c createCustomer(String customerName) {

        if (String.isBlank(customerName)) {
            throw new AuraHandledException('Customer name cannot be empty.');
        }

        String cleanName = customerName.trim();

        // Case insensitive check
        List<Retail_Customer__c> existing = [
            SELECT Id, Name
            FROM Retail_Customer__c
            WHERE Name = :cleanName
            LIMIT 1
        ];

        if (!existing.isEmpty()) {
            throw new AuraHandledException('Customer already exists.');
        }

        try {

            Retail_Customer__c newCustomer = new Retail_Customer__c(
                Name = cleanName
            );

            insert newCustomer;

            return newCustomer;

        } catch (DmlException e) {
            throw new AuraHandledException('Customer already exists.');
        }
    }


    // =====================================
    // Create Order + Order Items
    // =====================================
    @AuraEnabled
    public static Id createOrder(
        Id customerId,
        List<OrderItemWrapper> cartItems
    ) {

        if (customerId == null) {
            throw new AuraHandledException('Customer is required.');
        }

        if (cartItems == null || cartItems.isEmpty()) {
            throw new AuraHandledException('Cart cannot be empty.');
        }

        Retail_Order__c order = new Retail_Order__c(
            Retail_Customer__c = customerId,
            Status__c = 'Draft'
        );

        insert order;

        List<Retail_Order_Item__c> orderItemsToInsert = new List<Retail_Order_Item__c>();

        for (OrderItemWrapper item : cartItems) {

            orderItemsToInsert.add(new Retail_Order_Item__c(
                Retail_Order__c = order.Id,
                Retail_Product__c = item.productId,
                Quantity__c = item.quantity,
                Unit_Price__c = item.unitPrice
            ));
        }

        insert orderItemsToInsert;

        order.Status__c = 'Completed';
        update order;

        return order.Id;
    }


    // =====================================
    // Wrapper Class
    // =====================================
    public class OrderItemWrapper {

        @AuraEnabled public Id productId { get; set; }
        @AuraEnabled public Decimal quantity { get; set; }
        @AuraEnabled public Decimal unitPrice { get; set; }
    }
}