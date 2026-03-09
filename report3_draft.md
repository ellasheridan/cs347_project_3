# Project 3 Report Draft: Pothole Tracking and Repair System (PTRS)

## Overview
This database was designed for the Austin Department of Public Works to support the Pothole Tracking and Repair System (PTRS). The database stores data about citizens who report potholes, pothole reports, repair work orders, work crews, equipment used during repairs, and any related property damage claims.

## Design Choices
The design follows the relational model and keeps all tables in BCNF. To maintain normalization, data that belongs to one entity is stored only once:

- **Citizen information** is stored in `citizen_user`.
- **Districts** are stored in `district` and each pothole references one district.
- **Pothole reports** are stored in `pothole`.
- **Work crews** are stored in `work_crew`.
- **Equipment** is stored in `equipment`.
- **Work orders** are stored in `work_order` and each work order is tied to exactly one pothole.
- Because one work order can use multiple pieces of equipment and one piece of equipment can be used on many work orders, the many-to-many relationship is implemented with `work_order_equipment`.
- **Property damage claims** are stored in `property_damage_claim`, and multiple claims may be associated with the same pothole.

## Assumptions
1. **District determination**: the application determines the district from the street address and stores the resulting `district_id` in the pothole table.
2. **Repair priority**: repair priority is automatically derived from pothole size using a generated column:
   - 1-4 = Low
   - 5-7 = Medium
   - 8-10 = High
3. **Cost of repair** is computed in queries rather than stored directly, based on labor, filler material, and equipment usage. This avoids storing a derivable value and keeps the design normalized.
4. The assignment description says a work order includes pothole size and location, but those attributes are already stored in `pothole`. To preserve BCNF, the work order references the pothole and the application can retrieve size and location by joining the two tables.

## Table Purposes
### `district`
Stores the city districts used for routing reports and summarizing repair activity.

### `citizen_user`
Stores the users who submit pothole reports.

### `pothole`
Stores each pothole report, including address, size, street position, district, and generated priority.

### `work_crew`
Stores each repair crew and the number of workers assigned to that crew.

### `equipment`
Stores repair equipment and its hourly operating cost.

### `work_order`
Stores repair activity for each pothole, including the assigned crew, hours worked, material used, and repair status.

### `work_order_equipment`
Stores which equipment items were used on each work order and for how many hours.

### `property_damage_claim`
Stores citizen-reported damage caused by a pothole.

## Relationships
- One citizen can report many potholes; each pothole is reported by one citizen.
- One district can contain many potholes; each pothole belongs to one district.
- One pothole has one associated work order; each work order belongs to one pothole.
- One work crew can be assigned many work orders; each work order is assigned to one work crew.
- One work order can use many equipment items, and one equipment item can be used on many work orders.
- One pothole can have zero, one, or many property damage claims.

## E-R Diagram Notes
In Lucidchart, include the following for each table:
- table name
- all column names
- data types
- primary keys
- foreign keys
- minimum and maximum cardinalities on each relationship

Suggested cardinalities:
- `citizen_user` 1 to many `pothole`
- `district` 1 to many `pothole`
- `pothole` 1 to 1 `work_order`
- `work_crew` 1 to many `work_order`
- `work_order` many to many `equipment` through `work_order_equipment`
- `pothole` 1 to many `property_damage_claim`
