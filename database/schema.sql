CREATE TABLE CUSTOMER (

    customer_id BIGINT AUTO_INCREMENT PRIMARY KEY,

    name VARCHAR(100) NOT NULL,

    date_of_birth DATE NOT NULL,

    mobile VARCHAR(10) NOT NULL UNIQUE,

    address VARCHAR(255) NOT NULL,

    kyc_details JSON,

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_mobile
        CHECK (mobile REGEXP '^[0-9]{10}$')

);

CREATE TABLE LOAN_APPLICATION (

    application_id BIGINT AUTO_INCREMENT PRIMARY KEY,

    application_number VARCHAR(30) NOT NULL UNIQUE,

    customer_id BIGINT NOT NULL,

    product ENUM('PERSONAL', 'EDUCATION') NOT NULL,

    branch_code VARCHAR(20) NOT NULL,

    branch_name VARCHAR(100) NOT NULL,

    requested_amount DECIMAL(15,2) NOT NULL,

    approved_amount DECIMAL(15,2),

    tenure_months INT NOT NULL,

    monthly_income DECIMAL(15,2) NOT NULL,

    existing_monthly_obligations DECIMAL(15,2)
        NOT NULL DEFAULT 0,

    annual_interest_rate DECIMAL(5,2) NOT NULL,

    proposed_emi DECIMAL(15,2),

    foir_percentage DECIMAL(7,2),

    eligible BOOLEAN,

    eligibility_reasons JSON,

    status ENUM(
        'DRAFT',
        'UNDER_REVIEW',
        'APPROVED',
        'REJECTED',
        'DISBURSED',
        'EXIT'
    ) NOT NULL DEFAULT 'DRAFT',

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    submitted_at DATETIME,

    decided_at DATETIME,

    reviewer_code VARCHAR(50),

    decision_reason VARCHAR(500),
    
    active_customer_id BIGINT
	GENERATED ALWAYS AS (

    	CASE
        	WHEN status IN (
            	'DRAFT',
            	'UNDER_REVIEW',
            	'APPROVED'
        	)
        	THEN customer_id

        	ELSE NULL
    	END
	) STORED,

	UNIQUE KEY uq_active_customer_product (
    	active_customer_id,
    	product
	),

    FOREIGN KEY (customer_id)
        REFERENCES CUSTOMER(customer_id),

    CONSTRAINT chk_requested_amount
        CHECK (requested_amount > 0),

    CONSTRAINT chk_approved_amount
        CHECK (approved_amount IS NULL OR approved_amount > 0),

    CONSTRAINT chk_tenure
        CHECK (tenure_months > 0),

    CONSTRAINT chk_income
        CHECK (monthly_income > 0),

    CONSTRAINT chk_obligations
        CHECK (existing_monthly_obligations >= 0),

    CONSTRAINT chk_interest
        CHECK (annual_interest_rate > 0),

    INDEX idx_application_status (status),

    INDEX idx_application_product (product),

    INDEX idx_application_branch (branch_code)

);

CREATE TABLE DISBURSEMENT (

    disbursement_id BIGINT AUTO_INCREMENT PRIMARY KEY,

    application_id BIGINT NOT NULL UNIQUE,

    reference VARCHAR(60) NOT NULL UNIQUE,

    amount DECIMAL(15,2) NOT NULL,

    disbursed_at DATETIME NOT NULL,

    FOREIGN KEY (application_id)
        REFERENCES LOAN_APPLICATION(application_id),

    CONSTRAINT chk_disbursement_amount
        CHECK (amount > 0)

);

CREATE TABLE APPLICATION_HISTORY (

    history_id BIGINT AUTO_INCREMENT PRIMARY KEY,

    application_id BIGINT NOT NULL,

    action VARCHAR(50) NOT NULL,

    old_status VARCHAR(30),

    new_status VARCHAR(30),

    performed_by VARCHAR(50) NOT NULL,

    performed_at DATETIME NOT NULL,

    remarks VARCHAR(500),

    FOREIGN KEY (application_id)
        REFERENCES LOAN_APPLICATION(application_id),

    INDEX idx_history_application (application_id)

);

CREATE TABLE SYSTEM_ALERTS (

    alert_id BIGINT AUTO_INCREMENT PRIMARY KEY,

    application_id BIGINT NOT NULL,

    alert_type VARCHAR(50) NOT NULL,

    created_at DATETIME NOT NULL,

    FOREIGN KEY (application_id)
        REFERENCES LOAN_APPLICATION(application_id),

    CONSTRAINT uq_application_alert
        UNIQUE (application_id, alert_type)

);

CREATE TABLE UTILITY_RUN (

    run_id BIGINT AUTO_INCREMENT PRIMARY KEY,

    utility_name VARCHAR(100) NOT NULL,

    started_at DATETIME NOT NULL,

    completed_at DATETIME,

    result VARCHAR(30),

    applications_processed INT DEFAULT 0,

    alerts_created INT DEFAULT 0,

    error_message TEXT

);

CREATE TABLE NG_CORE_BANKING (

    core_banking_id BIGINT AUTO_INCREMENT PRIMARY KEY,

    customer_id BIGINT NOT NULL,

    application_id BIGINT NOT NULL UNIQUE,

    customer_name VARCHAR(100) NOT NULL,

    address VARCHAR(255) NOT NULL,

    dob DATE NOT NULL,

    kyc_details JSON,

    approved_amount DECIMAL(15,2) NOT NULL,

    disbursed_amount DECIMAL(15,2) NOT NULL,

    disbursed_date DATETIME NOT NULL,

    pushed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (customer_id)
        REFERENCES CUSTOMER(customer_id),

    FOREIGN KEY (application_id)
        REFERENCES LOAN_APPLICATION(application_id),

    CONSTRAINT chk_core_amounts
        CHECK (
            approved_amount > 0
            AND disbursed_amount > 0
        )

);