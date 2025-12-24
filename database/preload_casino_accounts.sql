-- Nexus COS - Pre-loaded Casino Accounts
-- 11 Casino accounts with NexCoin balances
-- admin_nexus has unlimited balance
-- Date: 2025-12-24

-- First, ensure user_wallets table exists with proper structure
CREATE TABLE IF NOT EXISTS user_wallets (
    id SERIAL PRIMARY KEY,
    username VARCHAR(255) UNIQUE NOT NULL,
    balance DECIMAL(20, 2) DEFAULT 1000.00,
    is_unlimited BOOLEAN DEFAULT false,
    account_type VARCHAR(50) DEFAULT 'regular',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Create wallet_transactions table if not exists
CREATE TABLE IF NOT EXISTS wallet_transactions (
    id SERIAL PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    amount DECIMAL(20, 2) NOT NULL,
    transaction_type VARCHAR(50) NOT NULL,
    balance_after DECIMAL(20, 2),
    description TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Create game_sessions table if not exists
CREATE TABLE IF NOT EXISTS game_sessions (
    id SERIAL PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    game_type VARCHAR(100) NOT NULL,
    bet_amount DECIMAL(20, 2),
    win_amount DECIMAL(20, 2),
    result VARCHAR(50),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Create users table for authentication if not exists
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Insert or update the 11 pre-loaded casino accounts with Founder Access Keys
-- Account 1: admin_nexus (UNLIMITED balance - Super Admin)
INSERT INTO user_wallets (username, balance, is_unlimited, account_type)
VALUES ('admin_nexus', 999999999.99, true, 'admin')
ON CONFLICT (username) 
DO UPDATE SET 
    balance = 999999999.99,
    is_unlimited = true,
    account_type = 'admin',
    updated_at = NOW();

-- Account 2: vip_whale_01 (VIP Whale - High Stakes)
INSERT INTO user_wallets (username, balance, is_unlimited, account_type)
VALUES ('vip_whale_01', 1000000.00, false, 'vip')
ON CONFLICT (username) 
DO UPDATE SET 
    balance = 1000000.00,
    account_type = 'vip',
    updated_at = NOW();

-- Account 3: vip_whale_02 (VIP Whale - High Stakes)
INSERT INTO user_wallets (username, balance, is_unlimited, account_type)
VALUES ('vip_whale_02', 1000000.00, false, 'vip')
ON CONFLICT (username) 
DO UPDATE SET 
    balance = 1000000.00,
    account_type = 'vip',
    updated_at = NOW();

-- Account 4: beta_tester_01 (Beta Founder - Standard)
INSERT INTO user_wallets (username, balance, is_unlimited, account_type)
VALUES ('beta_tester_01', 50000.00, false, 'beta_founder')
ON CONFLICT (username) 
DO UPDATE SET 
    balance = 50000.00,
    account_type = 'beta_founder',
    updated_at = NOW();

-- Account 5: beta_tester_02 (Beta Founder - Standard)
INSERT INTO user_wallets (username, balance, is_unlimited, account_type)
VALUES ('beta_tester_02', 50000.00, false, 'beta_founder')
ON CONFLICT (username) 
DO UPDATE SET 
    balance = 50000.00,
    account_type = 'beta_founder',
    updated_at = NOW();

-- Account 6: beta_tester_03 (Beta Founder - Standard)
INSERT INTO user_wallets (username, balance, is_unlimited, account_type)
VALUES ('beta_tester_03', 50000.00, false, 'beta_founder')
ON CONFLICT (username) 
DO UPDATE SET 
    balance = 50000.00,
    account_type = 'beta_founder',
    updated_at = NOW();

-- Account 7: beta_tester_04 (Beta Founder - Standard)
INSERT INTO user_wallets (username, balance, is_unlimited, account_type)
VALUES ('beta_tester_04', 50000.00, false, 'beta_founder')
ON CONFLICT (username) 
DO UPDATE SET 
    balance = 50000.00,
    account_type = 'beta_founder',
    updated_at = NOW();

-- Account 8: beta_tester_05 (Beta Founder - Standard)
INSERT INTO user_wallets (username, balance, is_unlimited, account_type)
VALUES ('beta_tester_05', 50000.00, false, 'beta_founder')
ON CONFLICT (username) 
DO UPDATE SET 
    balance = 50000.00,
    account_type = 'beta_founder',
    updated_at = NOW();

-- Account 9: beta_tester_06 (Beta Founder - Standard)
INSERT INTO user_wallets (username, balance, is_unlimited, account_type)
VALUES ('beta_tester_06', 50000.00, false, 'beta_founder')
ON CONFLICT (username) 
DO UPDATE SET 
    balance = 50000.00,
    account_type = 'beta_founder',
    updated_at = NOW();

-- Account 10: beta_tester_07 (Beta Founder - Standard)
INSERT INTO user_wallets (username, balance, is_unlimited, account_type)
VALUES ('beta_tester_07', 50000.00, false, 'beta_founder')
ON CONFLICT (username) 
DO UPDATE SET 
    balance = 50000.00,
    account_type = 'beta_founder',
    updated_at = NOW();

-- Account 11: beta_tester_08 (Beta Founder - Standard)
INSERT INTO user_wallets (username, balance, is_unlimited, account_type)
VALUES ('beta_tester_08', 50000.00, false, 'beta_founder')
ON CONFLICT (username) 
DO UPDATE SET 
    balance = 50000.00,
    account_type = 'beta_founder',
    updated_at = NOW();

-- Insert authentication credentials for all accounts
-- Password: WelcomeToVegas_25 (hashed using bcrypt with salt rounds=10)
-- Hash generated: $2b$10$YzvrzqSmYoDOn2mxigXNtOtLy/ksaYTvB9t1hn4waLXKVemmCnVQm
INSERT INTO users (username, password_hash)
VALUES 
    ('admin_nexus', '$2b$10$YzvrzqSmYoDOn2mxigXNtOtLy/ksaYTvB9t1hn4waLXKVemmCnVQm'),
    ('vip_whale_01', '$2b$10$YzvrzqSmYoDOn2mxigXNtOtLy/ksaYTvB9t1hn4waLXKVemmCnVQm'),
    ('vip_whale_02', '$2b$10$YzvrzqSmYoDOn2mxigXNtOtLy/ksaYTvB9t1hn4waLXKVemmCnVQm'),
    ('beta_tester_01', '$2b$10$YzvrzqSmYoDOn2mxigXNtOtLy/ksaYTvB9t1hn4waLXKVemmCnVQm'),
    ('beta_tester_02', '$2b$10$YzvrzqSmYoDOn2mxigXNtOtLy/ksaYTvB9t1hn4waLXKVemmCnVQm'),
    ('beta_tester_03', '$2b$10$YzvrzqSmYoDOn2mxigXNtOtLy/ksaYTvB9t1hn4waLXKVemmCnVQm'),
    ('beta_tester_04', '$2b$10$YzvrzqSmYoDOn2mxigXNtOtLy/ksaYTvB9t1hn4waLXKVemmCnVQm'),
    ('beta_tester_05', '$2b$10$YzvrzqSmYoDOn2mxigXNtOtLy/ksaYTvB9t1hn4waLXKVemmCnVQm'),
    ('beta_tester_06', '$2b$10$YzvrzqSmYoDOn2mxigXNtOtLy/ksaYTvB9t1hn4waLXKVemmCnVQm'),
    ('beta_tester_07', '$2b$10$YzvrzqSmYoDOn2mxigXNtOtLy/ksaYTvB9t1hn4waLXKVemmCnVQm'),
    ('beta_tester_08', '$2b$10$YzvrzqSmYoDOn2mxigXNtOtLy/ksaYTvB9t1hn4waLXKVemmCnVQm')
ON CONFLICT (username) DO UPDATE SET 
    password_hash = EXCLUDED.password_hash,
    updated_at = NOW();

-- Log initial balance transactions for all accounts
INSERT INTO wallet_transactions (username, amount, transaction_type, balance_after, description)
VALUES 
    ('admin_nexus', 999999999.99, 'initial_load', 999999999.99, 'Super Admin - Unlimited balance'),
    ('vip_whale_01', 1000000.00, 'initial_load', 1000000.00, 'VIP Whale - High Stakes'),
    ('vip_whale_02', 1000000.00, 'initial_load', 1000000.00, 'VIP Whale - High Stakes'),
    ('beta_tester_01', 50000.00, 'initial_load', 50000.00, 'Beta Founder - Standard'),
    ('beta_tester_02', 50000.00, 'initial_load', 50000.00, 'Beta Founder - Standard'),
    ('beta_tester_03', 50000.00, 'initial_load', 50000.00, 'Beta Founder - Standard'),
    ('beta_tester_04', 50000.00, 'initial_load', 50000.00, 'Beta Founder - Standard'),
    ('beta_tester_05', 50000.00, 'initial_load', 50000.00, 'Beta Founder - Standard'),
    ('beta_tester_06', 50000.00, 'initial_load', 50000.00, 'Beta Founder - Standard'),
    ('beta_tester_07', 50000.00, 'initial_load', 50000.00, 'Beta Founder - Standard'),
    ('beta_tester_08', 50000.00, 'initial_load', 50000.00, 'Beta Founder - Standard')
ON CONFLICT (id) DO NOTHING;

-- Create function to handle unlimited balance for admin_nexus
CREATE OR REPLACE FUNCTION check_unlimited_balance()
RETURNS TRIGGER AS $$
BEGIN
    -- If this is admin_nexus and balance goes below threshold, reset to unlimited
    IF NEW.username = 'admin_nexus' AND NEW.is_unlimited = true THEN
        IF NEW.balance < 999999999.99 THEN
            NEW.balance := 999999999.99;
        END IF;
    END IF;
    
    NEW.updated_at := NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for unlimited balance
DROP TRIGGER IF EXISTS unlimited_balance_trigger ON user_wallets;
CREATE TRIGGER unlimited_balance_trigger
    BEFORE UPDATE ON user_wallets
    FOR EACH ROW
    EXECUTE FUNCTION check_unlimited_balance();

-- Grant permissions
GRANT ALL PRIVILEGES ON users TO nexus_user;
GRANT ALL PRIVILEGES ON user_wallets TO nexus_user;
GRANT ALL PRIVILEGES ON wallet_transactions TO nexus_user;
GRANT ALL PRIVILEGES ON game_sessions TO nexus_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO nexus_user;

-- Display loaded accounts
SELECT 
    username,
    balance,
    CASE 
        WHEN is_unlimited THEN 'UNLIMITED' 
        ELSE TO_CHAR(balance, '999,999,999.99') || ' NC'
    END as display_balance,
    account_type,
    created_at
FROM user_wallets
ORDER BY 
    CASE account_type
        WHEN 'admin' THEN 1
        WHEN 'vip' THEN 2
        WHEN 'beta_founder' THEN 3
    END,
    balance DESC;
