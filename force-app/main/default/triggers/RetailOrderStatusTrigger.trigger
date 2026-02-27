trigger RetailOrderStatusTrigger 
on Retail_Order__c (before update, before delete) {

    Set<Id> restoreOrderIds = new Set<Id>();

    // ========================
    // HANDLE STATUS UPDATE
    // ========================
    if(Trigger.isUpdate) {

        for(Retail_Order__c order : Trigger.new) {

            Retail_Order__c oldOrder = Trigger.oldMap.get(order.Id);

            if(order.Status__c == 'Cancelled' &&
               oldOrder.Status__c != 'Cancelled') {

                restoreOrderIds.add(order.Id);
            }
        }
    }

    // ========================
    // HANDLE DELETE
    // ========================
    if(Trigger.isDelete) {

        for(Retail_Order__c order : Trigger.old) {

            if(order.Status__c == 'Completed') {

                order.addError('Completed orders cannot be deleted.');

            } else if(order.Status__c == 'Draft') {
                restoreOrderIds.add(order.Id);
            }
        }
    }

    if(restoreOrderIds.isEmpty()) return;

    // Fetch Order Items
    List<Retail_Order_Item__c> orderItems = [
        SELECT Id, Quantity__c, Retail_Product__c
        FROM Retail_Order_Item__c
        WHERE Retail_Order__c IN :restoreOrderIds
    ];

    Set<Id> productIds = new Set<Id>();

    for(Retail_Order_Item__c item : orderItems) {
        productIds.add(item.Retail_Product__c);
    }

    if(productIds.isEmpty()) return;

    Map<Id, Retail_Product__c> productMap = new Map<Id, Retail_Product__c>(
        [SELECT Id, Available_Stock__c
         FROM Retail_Product__c
         WHERE Id IN :productIds]
    );

    for(Retail_Order_Item__c item : orderItems) {

        Retail_Product__c product = productMap.get(item.Retail_Product__c);

        if(product != null) {
            product.Available_Stock__c += item.Quantity__c;
        }
    }

    update productMap.values();
}