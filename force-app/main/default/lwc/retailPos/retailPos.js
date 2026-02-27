import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getActiveProducts from '@salesforce/apex/RetailPOSController.getActiveProducts';
import createOrder from '@salesforce/apex/RetailPOSController.createOrder';
import searchCustomers from '@salesforce/apex/RetailPOSController.searchCustomers';
import createCustomer from '@salesforce/apex/RetailPOSController.createCustomer';

export default class RetailPos extends LightningElement {

    @track products = [];
    @track cartItems = [];
    @track cartTotal = 0;
    @track isLoading = false;

    customerSearchKey = '';
    customerResults = [];
    selectedCustomerId = null;

    /* ================= CUSTOMER SEARCH ================= */

    handleCustomerSearch(event) {
        this.customerSearchKey = event.target.value;

        if (this.customerSearchKey.length < 2) {
            this.customerResults = [];
            return;
        }

        searchCustomers({ searchKey: this.customerSearchKey })
            .then(result => {
                this.customerResults = result;
            })
            .catch(error => {
                console.error(error);
            });
    }

    handleCustomerSelect(event) {
        this.selectedCustomerId = event.currentTarget.dataset.id;
        this.customerSearchKey = event.currentTarget.dataset.name;
        this.customerResults = [];
    }

    handleCreateCustomer() {

        if (!this.customerSearchKey || this.customerSearchKey.trim() === '') {
            return;
        }

        this.isLoading = true;

        createCustomer({ customerName: this.customerSearchKey })
            .then(newCustomer => {

                this.selectedCustomerId = newCustomer.Id;
                this.customerSearchKey = newCustomer.Name;
                this.customerResults = [];

                this.showToast('Success', 'Customer created successfully!', 'success');

            })
            .catch(error => {

                this.showToast(
                    'Error',
                    error.body?.message || 'Customer already exists.',
                    'error'
                );

            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    get showCreateOption() {
        return this.customerSearchKey &&
               this.customerResults.length === 0;
    }

    /* ================= PRODUCT SEARCH ================= */

    handleSearch(event) {
        const searchKey = event.target.value;

        if (!searchKey) {
            this.products = [];
            return;
        }

        getActiveProducts({ searchKey })
            .then(result => {
                this.products = result.map(p => ({
                    ...p,
                    isOutOfStock: p.Available_Stock__c === 0
                }));
            })
            .catch(error => {
                console.error(error);
            });
    }

    /* ================= CART ================= */

    addToCart(event) {
        const productId = event.target.dataset.id;
        const product = this.products.find(p => p.Id === productId);

        let existingItem = this.cartItems.find(item => item.productId === productId);

        if (existingItem) {
            if (existingItem.quantity < product.Available_Stock__c) {
                existingItem.quantity += 1;
                existingItem.lineTotal = existingItem.quantity * existingItem.unitPrice;
            } else {
                this.showToast('Stock Limit', 'Not enough stock available.', 'warning');
                return;
            }
        } else {
            if (product.Available_Stock__c <= 0) {
                this.showToast('Out of Stock', 'This product is out of stock.', 'error');
                return;
            }

            this.cartItems.push({
                productId: product.Id,
                name: product.Name,
                quantity: 1,
                unitPrice: product.Price__c,
                lineTotal: product.Price__c,
                stock: product.Available_Stock__c
            });
        }

        this.cartItems = [...this.cartItems];
        this.calculateTotal();
        this.products = [];
    }

    increaseQty(event) {
        const productId = event.target.dataset.id;
        let item = this.cartItems.find(i => i.productId === productId);

        if (item && item.quantity < item.stock) {
            item.quantity += 1;
            item.lineTotal = item.quantity * item.unitPrice;
        }

        this.cartItems = [...this.cartItems];
        this.calculateTotal();
    }

    decreaseQty(event) {
        const productId = event.target.dataset.id;
        let item = this.cartItems.find(i => i.productId === productId);

        if (item && item.quantity > 1) {
            item.quantity -= 1;
            item.lineTotal = item.quantity * item.unitPrice;
        }

        this.cartItems = [...this.cartItems];
        this.calculateTotal();
    }

    removeFromCart(event) {
        const productId = event.target.dataset.id;
        this.cartItems = this.cartItems.filter(
            item => item.productId !== productId
        );
        this.calculateTotal();
    }

    clearCart() {
        this.cartItems = [];
        this.cartTotal = 0;
    }

    calculateTotal() {
        this.cartTotal = this.cartItems.reduce(
            (sum, item) => sum + item.lineTotal,
            0
        );
    }

    /* ================= CHECKOUT ================= */

    handleCheckout() {

        if (!this.selectedCustomerId) {
            this.showToast('Error', 'Please select a customer.', 'error');
            return;
        }

        if (this.cartItems.length === 0) {
            return;
        }

        this.isLoading = true;

        const cleanCart = this.cartItems.map(item => ({
            productId: item.productId,
            quantity: Number(item.quantity),
            unitPrice: Number(item.unitPrice)
        }));

        createOrder({
            customerId: this.selectedCustomerId,
            cartItems: cleanCart
        })
        .then(() => {

            this.showToast('Success', 'Order created successfully!', 'success');

            this.cartItems = [];
            this.cartTotal = 0;
            this.products = [];
            this.selectedCustomerId = null;
            this.customerSearchKey = '';

        })
        .catch(error => {
            console.error(error);
            this.showToast('Error', 'Order failed.', 'error');
        })
        .finally(() => {
            this.isLoading = false;
        });
    }

    get isCheckoutDisabled() {
        return this.cartItems.length === 0;
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }
}