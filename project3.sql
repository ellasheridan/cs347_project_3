USE ptrs_db;

-- Report 1: Users and the number of potholes each user has reported.
SELECT u.user_id,
       CONCAT(u.first_name, ' ', u.last_name) AS citizen_name,
       COUNT(p.pothole_id) AS potholes_reported
FROM citizen_user u
LEFT JOIN pothole p ON u.user_id = p.user_id
GROUP BY u.user_id, u.first_name, u.last_name
ORDER BY potholes_reported DESC, citizen_name;

-- Report 2: Open high-priority potholes by district, showing location details for repair planning.
SELECT d.district_name,
       p.pothole_id,
       p.street_address,
       p.street_location,
       p.pothole_size,
       p.repair_priority,
       wo.pothole_status
FROM pothole p
JOIN district d ON p.district_id = d.district_id
JOIN work_order wo ON p.pothole_id = wo.pothole_id
WHERE p.repair_priority = 'High'
  AND wo.pothole_status <> 'repaired'
ORDER BY d.district_name, p.pothole_size DESC;

-- Report 3: Work orders with computed total repair cost based on labor, material, and equipment usage.
SELECT wo.work_order_id,
       wo.pothole_id,
       wc.crew_name,
       wo.pothole_status,
       wo.hours_applied,
       wc.crew_size,
       wo.filler_material_lbs,
       ROUND((wo.hours_applied * wc.crew_size * wo.labor_rate_per_person)
           + (wo.filler_material_lbs * wo.material_cost_per_lb)
           + COALESCE(SUM(woe.usage_hours * e.hourly_rate), 0), 2) AS total_repair_cost
FROM work_order wo
JOIN work_crew wc ON wo.crew_id = wc.crew_id
LEFT JOIN work_order_equipment woe ON wo.work_order_id = woe.work_order_id
LEFT JOIN equipment e ON woe.equipment_id = e.equipment_id
GROUP BY wo.work_order_id, wo.pothole_id, wc.crew_name, wo.pothole_status,
         wo.hours_applied, wc.crew_size, wo.filler_material_lbs,
         wo.labor_rate_per_person, wo.material_cost_per_lb
ORDER BY total_repair_cost DESC;

-- Report 4: Property damage claims above $300, with related pothole and repair status information.
SELECT c.claim_id,
       c.claimant_name,
       c.damage_type,
       c.damage_amount,
       p.pothole_id,
       p.street_address,
       wo.pothole_status
FROM property_damage_claim c
JOIN pothole p ON c.pothole_id = p.pothole_id
JOIN work_order wo ON p.pothole_id = wo.pothole_id
WHERE c.damage_amount > 300
ORDER BY c.damage_amount DESC;

-- Report 5: Work crew workload summary, showing assigned work orders and total repair hours.
SELECT wc.crew_id,
       wc.crew_name,
       wc.crew_size,
       COUNT(wo.work_order_id) AS assigned_work_orders,
       COALESCE(SUM(wo.hours_applied), 0) AS total_hours_applied
FROM work_crew wc
LEFT JOIN work_order wo ON wc.crew_id = wo.crew_id
GROUP BY wc.crew_id, wc.crew_name, wc.crew_size
ORDER BY total_hours_applied DESC, assigned_work_orders DESC;

-- Report 6: Equipment utilization across work orders, including hours used and related pothole count.
SELECT e.equipment_id,
       e.equipment_name,
       e.equipment_type,
       COUNT(DISTINCT woe.work_order_id) AS work_orders_used_on,
       COALESCE(SUM(woe.usage_hours), 0) AS total_usage_hours
FROM equipment e
LEFT JOIN work_order_equipment woe ON e.equipment_id = woe.equipment_id
GROUP BY e.equipment_id, e.equipment_name, e.equipment_type
ORDER BY total_usage_hours DESC, e.equipment_name;

-- Report 7: Average repair completion time in days for repaired potholes by district.
SELECT d.district_name,
       COUNT(*) AS repaired_potholes,
       ROUND(AVG(DATEDIFF(wo.completed_date, wo.assigned_date)), 2) AS avg_days_to_repair
FROM work_order wo
JOIN pothole p ON wo.pothole_id = p.pothole_id
JOIN district d ON p.district_id = d.district_id
WHERE wo.pothole_status = 'repaired'
  AND wo.completed_date IS NOT NULL
GROUP BY d.district_name
ORDER BY avg_days_to_repair;
