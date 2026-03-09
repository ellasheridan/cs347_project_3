DROP DATABASE IF EXISTS ptrs_db;
CREATE DATABASE ptrs_db;
USE ptrs_db;

CREATE TABLE district (
    district_id INT PRIMARY KEY,
    district_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE citizen_user (
    user_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    street_address VARCHAR(120) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100)
);

CREATE TABLE pothole (
    pothole_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    report_date DATE NOT NULL,
    street_address VARCHAR(120) NOT NULL,
    street_location ENUM('middle','curb','intersection','shoulder','lane edge') NOT NULL,
    district_id INT NOT NULL,
    pothole_size TINYINT NOT NULL,
    repair_priority VARCHAR(10) AS (
        CASE
            WHEN pothole_size >= 8 THEN 'High'
            WHEN pothole_size >= 5 THEN 'Medium'
            ELSE 'Low'
        END
    ) STORED,
    CONSTRAINT chk_pothole_size CHECK (pothole_size BETWEEN 1 AND 10),
    CONSTRAINT fk_pothole_user FOREIGN KEY (user_id) REFERENCES citizen_user(user_id),
    CONSTRAINT fk_pothole_district FOREIGN KEY (district_id) REFERENCES district(district_id)
);

CREATE TABLE work_crew (
    crew_id INT PRIMARY KEY,
    crew_name VARCHAR(60) NOT NULL UNIQUE,
    crew_size INT NOT NULL,
    CONSTRAINT chk_crew_size CHECK (crew_size > 0)
);

CREATE TABLE equipment (
    equipment_id INT PRIMARY KEY,
    equipment_name VARCHAR(60) NOT NULL UNIQUE,
    equipment_type VARCHAR(40) NOT NULL,
    hourly_rate DECIMAL(8,2) NOT NULL,
    availability_status ENUM('available','in use','maintenance') NOT NULL,
    CONSTRAINT chk_equipment_rate CHECK (hourly_rate >= 0)
);

CREATE TABLE work_order (
    work_order_id INT PRIMARY KEY,
    pothole_id INT NOT NULL UNIQUE,
    crew_id INT NOT NULL,
    assigned_date DATE NOT NULL,
    completed_date DATE,
    hours_applied DECIMAL(5,2) NOT NULL,
    pothole_status ENUM('in progress','repaired','not repaired') NOT NULL,
    filler_material_lbs DECIMAL(8,2) NOT NULL,
    labor_rate_per_person DECIMAL(8,2) NOT NULL,
    material_cost_per_lb DECIMAL(8,2) NOT NULL,
    CONSTRAINT chk_hours CHECK (hours_applied >= 0),
    CONSTRAINT chk_filler CHECK (filler_material_lbs >= 0),
    CONSTRAINT chk_labor_rate CHECK (labor_rate_per_person >= 0),
    CONSTRAINT chk_material_rate CHECK (material_cost_per_lb >= 0),
    CONSTRAINT fk_work_order_pothole FOREIGN KEY (pothole_id) REFERENCES pothole(pothole_id),
    CONSTRAINT fk_work_order_crew FOREIGN KEY (crew_id) REFERENCES work_crew(crew_id)
);

CREATE TABLE work_order_equipment (
    work_order_id INT NOT NULL,
    equipment_id INT NOT NULL,
    usage_hours DECIMAL(5,2) NOT NULL,
    PRIMARY KEY (work_order_id, equipment_id),
    CONSTRAINT chk_usage_hours CHECK (usage_hours >= 0),
    CONSTRAINT fk_woe_work_order FOREIGN KEY (work_order_id) REFERENCES work_order(work_order_id),
    CONSTRAINT fk_woe_equipment FOREIGN KEY (equipment_id) REFERENCES equipment(equipment_id)
);

CREATE TABLE property_damage_claim (
    claim_id INT PRIMARY KEY,
    pothole_id INT NOT NULL,
    claimant_name VARCHAR(100) NOT NULL,
    claimant_address VARCHAR(120) NOT NULL,
    claimant_phone VARCHAR(20) NOT NULL,
    damage_type VARCHAR(80) NOT NULL,
    damage_amount DECIMAL(10,2) NOT NULL,
    claim_date DATE NOT NULL,
    claim_status ENUM('filed','under review','approved','rejected') NOT NULL,
    CONSTRAINT chk_damage_amount CHECK (damage_amount >= 0),
    CONSTRAINT fk_claim_pothole FOREIGN KEY (pothole_id) REFERENCES pothole(pothole_id)
);

-- Example load commands (adjust file paths for your machine / MySQL setup)
-- LOAD DATA LOCAL INFILE 'district.csv' INTO TABLE district
-- FIELDS TERMINATED BY ',' ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS;
