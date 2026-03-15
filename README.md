# CS 347 Project 3
# Team: Sodais Ghulam, Ella Sheridan

Pothole Tracking and Repair System (PTRS) database project for CS 347, Spring 2026.

## Files

- `ptrs_ddl.sql`: creates the `ptrs_db` database and all tables.
- `project3.sql`: operational report queries for the project deliverable.
- `report3_draft.md`: draft write-up for `report3.pdf`.
- `csv_data/`: sample CSV files for loading test data into each table.

## Table Load Order

Load the CSV files in this order to satisfy foreign key constraints:

1. `district.csv`
2. `citizen_user.csv`
3. `work_crew.csv`
4. `equipment.csv`
5. `pothole.csv`
6. `work_order.csv`
7. `work_order_equipment.csv`
8. `property_damage_claim.csv`

## Usage

1. Run `ptrs_ddl.sql` in MySQL to create the schema.
2. Load the CSV files into their matching tables with `LOAD DATA LOCAL INFILE` or MySQL Workbench's import tool.
3. Run `project3.sql` to generate the required operational reports.

## Notes

- `repair_priority` is a generated column derived from `pothole_size`.
- `work_order_equipment` resolves the many-to-many relationship between work orders and equipment.
- `property_damage_claim` references both the affected pothole and the citizen who filed the claim.
