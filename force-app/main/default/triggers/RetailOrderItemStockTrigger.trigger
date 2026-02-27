trigger RetailOrderItemStockTrigger 
on Retail_Order_Item__c (before insert, before update, before delete) {

    Set<Id> productIds = new Set<Id>();

    // Collect Product IDs from appropriate context
    if(Trigger.isInsert || Trigger.isUpdate) {
        for(Retail_Order_Item__c item : Trigger.new) {
            if(item.Retail_Product__c != null) {
                productIds.add(item.Retail_Product__c);
            }
        }
    }

    if(Trigger.isDelete) {
        for(Retail_Order_Item__c item : Trigger.old) {
            if(item.Retail_Product__c != null) {
                productIds.add(item.Retail_Product__c);
            }
        }
    }

    if(productIds.isEmpty()) return;

    Map<Id, Retail_Product__c> productMap = new Map<Id, Retail_Product__c>(
        [SELECT Id, Available_Stock__c 
         FROM Retail_Product__c 
         WHERE Id IN :productIds]
    );

    // HANDLE INSERT & UPDATE
    if(Trigger.isInsert || Trigger.isUpdate) {

        for(Retail_Order_Item__c item : Trigger.new) {

            Retail_Product__c product = productMap.get(item.Retail_Product__c);

            if(product == null) {
                item.addError('Product not found.');
                continue;
            }

            Decimal oldQuantity = 0;

            if(Trigger.isUpdate && Trigger.oldMap.containsKey(item.Id)) {
                oldQuantity = Trigger.oldMap.get(item.Id).Quantity__c;
            }

            Decimal quantityDifference = item.Quantity__c - oldQuantity;

            if(quantityDifference > 0) {
                if(quantityDifference > product.Available_Stock__c) {
                    item.addError('Insufficient stock available.');
                } else {
                    product.Available_Stock__c -= quantityDifference;
                }
            }
            else if(quantityDifference < 0) {
                product.Available_Stock__c += Math.abs(quantityDifference);
            }
        }
    }

    // HANDLE DELETE
    if(Trigger.isDelete) {

        for(Retail_Order_Item__c item : Trigger.old) {

            Retail_Product__c product = productMap.get(item.Retail_Product__c);

            if(product != null) {
                product.Available_Stock__c += item.Quantity__c;
            }
        }
    }

    update productMap.values();
}