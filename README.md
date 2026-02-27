
🛒 Smart Retail POS System (Salesforce)
=======================================

A full-stack, role-based **Point of Sale (POS)** system built on Salesforce using **Apex, Lightning Web Components (LWC), Triggers, and Reports**.

This project simulates a real-world retail store environment with multi-cashier operations, real-time inventory tracking, and manager-level analytics.

✨ Features
-----------

### 🧾 Order Management

*   Create orders with multiple products
    
*   Order lifecycle: **Draft → Completed**
    
*   Mandatory customer selection before checkout
    
*   Automatic cart reset after successful order
    

### 📦 Inventory Management

*   Real-time stock deduction on order creation
    
*   Stock restoration on order cancellation
    
*   Concurrency-safe logic for multiple cashiers
    
*   Bulk-safe Apex trigger implementation
    

### 👤 Customer Management

*   Dynamic customer search (live lookup)
    
*   Inline customer creation from POS screen
    
*   Duplicate-safe customer creation (backend + DB validation)
    

### 🖥 POS Interface (LWC)

*   Live product search
    
*   Add / Remove / Increase / Decrease cart items
    
*   Automatic total calculation
    
*   Loading spinner & toast notifications
    
*   Clean dropdown-based customer selection
    

### 📊 Reports & Dashboards

*   Today's Total Sales (Metric)
    
*   Low Stock Report
    
*   Row-level formula:Available\_Stock\_\_c - Reorder\_Level\_\_c
    
*   Conditional formatting for inventory alerts
    

### 📥 Bulk Product Import

*   External ID (SKU) enabled
    
*   Upsert support via Data Import Wizard / Data Loader
    
*   Manager-level inventory upload capability
    
## 🏢 Role-Based Application Design

Two separate Lightning Apps were designed to simulate real retail operations:

### 🧾 Cashier App (Smart Retail POS)
- Access to Smart Retail POS (LWC)
- Product Search & Cart Management
- Customer Selection & Inline Creation
- Cannot access Reports or Dashboards
- Cannot directly modify inventory

### 🧑‍💼 Manager App (Smart Retail System)
- Access to Reports & Dashboards
- Inventory oversight
- Low-stock monitoring
- Bulk product import capability
- Sales analytics access

This separation ensures clean operational boundaries and mimics real-world retail system design.

🏗 Architecture
---------------

### Custom Objects

*   Retail\_Product\_\_c
    
*   Retail\_Customer\_\_c
    
*   Retail\_Order\_\_c
    
*   Retail\_Order\_Item\_\_c
    

### Relationships

*   Order → Lookup → Customer
    
*   Order Item → Lookup → Order
    
*   Order Item → Lookup → Product
    

⚙️ Backend Design
-----------------

### Apex Controller

*   RetailPOSController
    
*   Declared as without sharing for operational consistency
    
*   Uses @AuraEnabled methods for LWC communication
    
*   Wrapper class used for bulk-safe order item processing
    

### Stock Management

*   Apex Triggers used instead of Flows
    
*   Handles:
    
    *   Before Insert (Order Items)
        
    *   Before Update
        
    *   After Update (Order Status)
        
*   SOQL moved outside loops (bulk-safe)
    
*   Prevents SOQL-in-loop anti-pattern
    

🔐 Security Model
-----------------

### Profiles

*   Retail Cashier
    
*   Retail Manager
    

### Cashier

*   Access to POS interface
    
*   Cannot access reports/dashboards
    
*   Cannot modify inventory directly
    

### Manager

*   Access to reports & dashboards
    
*   Can upload products
    
*   Inventory oversight
    

🧠 Key Technical Highlights
---------------------------

*   Bulk-safe Apex design
    
*   Concurrency handling for multi-user operations
    
*   Duplicate-safe customer creation
    
*   Profile-based access control
    
*   Real-time LWC ↔ Apex communication
    
*   Clean separation of UI and business logic
    
*   Database-level uniqueness enforcement
    

🛠 Tech Stack
-------------

*   Salesforce Developer Org
    
*   Apex
    
*   Lightning Web Components (LWC)
    
*   SOQL
    
*   Triggers
    
*   Data Import Wizard
    
*   Reports & Dashboards
    

📂 Project Structure
--------------------
```
force-app/
  main/
    default/
      classes/
        RetailPOSController.cls
      lwc/
        retailPos/
          retailPos.html
          retailPos.js
          retailPos.css
      triggers/
        RetailOrderItemTrigger.trigger
```
        
🧪 Setup Instructions (Salesforce DX)
-------------------------------------

### 1️⃣ Clone the repository

```
git clone <your-repo-url>
cd <repo-name>
```

### 2️⃣ Authorize Salesforce Org

```
sfdx auth:web:login
```

### 3️⃣ Deploy Source to Org

```
sfdx force:source:deploy -p force-app
```

### 4️⃣ Assign Profiles & Open App

*   Assign Retail Cashier / Retail Manager profile
    
*   Open **Smart Retail POS** app from App Launcher
    

🎯 Learning Outcomes
--------------------

This project demonstrates:

*   System design in Salesforce
    
*   Bulkification best practices
    
*   Record-level vs object-level security
    
*   Real-world POS workflow modeling
    
*   Multi-user concurrency handling
    
*   Scalable inventory management
    

🚀 Future Improvements
----------------------

*   AI Assistant inside POS (Agentforce integration)
    
*   Multi-store support
    
*   Barcode scanning integration
    
*   Payment gateway simulation
    
*   Advanced sales analytics
    

👤 Author
---------

**Mohammad Haji**
Salesforce | Apex | LWC | System Design 
