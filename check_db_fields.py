#!/usr/bin/env python
"""Script to check if new fields exist in database tables"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.local')
django.setup()

from django.db import connection

def check_table_fields(table_name, fields):
    cursor = connection.cursor()
    cursor.execute("""
        SELECT column_name, data_type, character_maximum_length, is_nullable
        FROM information_schema.columns 
        WHERE table_name = %s AND column_name = ANY(%s)
        ORDER BY column_name
    """, [table_name, fields])
    
    results = cursor.fetchall()
    print(f"\n{table_name} table:")
    if results:
        for row in results:
            col_name, data_type, max_length, nullable = row
            length_info = f"({max_length})" if max_length else ""
            null_info = "NULL" if nullable == "YES" else "NOT NULL"
            print(f"  ✓ {col_name}: {data_type}{length_info} {null_info}")
    else:
        print(f"  ✗ Fields not found in database!")
    return len(results)

# Check PreOrder table
print("=" * 60)
print("Checking database for new entity type fields...")
print("=" * 60)

preorder_fields = ['entity_type', 'jshshir', 'stir', 'mfo']
order_fields = ['entity_type', 'jshshir', 'stir', 'mfo']

preorder_count = check_table_fields('yuktashish_orders_preorder', preorder_fields)
order_count = check_table_fields('yuktashish_orders_order', order_fields)

print("\n" + "=" * 60)
if preorder_count == 4 and order_count == 4:
    print("✓ SUCCESS: All 4 fields exist in both tables!")
else:
    print(f"⚠ WARNING: Found {preorder_count}/4 in PreOrder, {order_count}/4 in Order")
print("=" * 60)



