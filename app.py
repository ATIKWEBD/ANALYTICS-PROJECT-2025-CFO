import pandas as pd
import numpy as np
from faker import Faker
import random
from datetime import datetime, timedelta

# Initialize Faker for realistic data
fake = Faker()

# --- Configuration ---
NUM_TRANSACTIONS = 5000
NUM_CUSTOMERS = 450
NUM_PRODUCTS = 100
NUM_SALESPEOPLE = 50

# --- 1. Generate Product Data (from ERP) ---
products = []
for i in range(NUM_PRODUCTS):
    category = random.choice(['Electronics', 'Hardware', 'Office Supplies', 'Software'])
    # Introduce SKU inconsistency
    sku_format = 'SKU-{:03d}' if random.random() > 0.1 else 'sku-{:03d}'
    sku = sku_format.format(i)
    base_cost = round(random.uniform(5.0, 500.0), 2)
    products.append({
        'SKU': sku,
        'Product_Category': category,
        'Unit_Cost': base_cost
    })
products_df = pd.DataFrame(products)
# Introduce duplicate SKUs
products_df = pd.concat([products_df, products_df.head(3)])
print("Generated Products Data...")

# --- 2. Generate Customer & Sales Team Data (from HR/CRM) ---
customers = [{'Customer_ID': i, 'Customer_Name': fake.company()} for i in range(NUM_CUSTOMERS)]
sales_team = [{'Salesperson_ID': i, 'Salesperson_Name': fake.name()} for i in range(NUM_SALESPEOPLE)]
customers_df = pd.DataFrame(customers)
sales_team_df = pd.DataFrame(sales_team)
customers_df['Salesperson_ID'] = [random.randint(0, NUM_SALESPEOPLE - 1) for _ in range(NUM_CUSTOMERS)]
print("Generated Customer and Sales Team Data...")

# --- 3. Generate Sales Transactions (from CRM) ---
transactions = []
start_date = datetime(2024, 1, 1)
for i in range(NUM_TRANSACTIONS):
    product = random.choice(products)
    sku = product['SKU']
    unit_cost = product['Unit_Cost']
    margin = random.uniform(1.2, 1.8)
    sale_price = round(unit_cost * margin, 2)
    # Introduce missing data
    if random.random() < 0.05:
      sale_price = np.nan
    transactions.append({
        'Transaction_ID': 10000 + i,
        'Customer_ID': random.randint(0, NUM_CUSTOMERS - 1),
        'SKU': sku,
        'Units_Sold': random.randint(1, 20),
        'Unit_Price': sale_price,
        'Transaction_Date': start_date + timedelta(days=random.randint(0, 364))
    })
transactions_df = pd.DataFrame(transactions)
print("Generated Sales Transactions...")

# --- 4. Generate Logistics Data (from Warehouse System) ---
logistics = []
for i in range(NUM_TRANSACTIONS):
    if random.random() > 0.03:
        logistics.append({
            'Transaction_ID': 10000 + i,
            'Shipping_Cost': round(random.uniform(10.0, 100.0), 2),
            'Delivery_Region': random.choice(['Northeast', 'South', 'Midwest', 'West'])
        })
logistics_df = pd.DataFrame(logistics)
print("Generated Logistics Data...")

# --- 5. Save to separate CSV files ---
products_df.to_csv('erp_products.csv', index=False)
customers_df.to_csv('crm_customers.csv', index=False)
sales_team_df.to_csv('hr_sales_team.csv', index=False)
transactions_df.to_csv('crm_transactions.csv', index=False)
logistics_df.to_csv('warehouse_logistics.csv', index=False)

print("\n🚀 Phase 1 Complete! Five messy CSV files have been created.")