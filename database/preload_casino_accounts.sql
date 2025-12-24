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

-- Insert or update the 11 pre-loaded casino accounts
-- Account 1: admin_nexus (UNLIMITED balance)
INSERT INTO user_wallets (username, balance, is_unlimited, account_type)
VALUES ('admin_nexus', 999999999.99, true, 'admin')
ON CONFLICT (username) 
DO UPDATE SET 
    balance = 999999999.99,
    is_unlimited = true,
    account_type = 'admin',
    updated_at = NOW();

-- Account 2: casino_vip_01 (High Roller)
INSERT INTO user_wallets (username, balance, is_unlimited, account_type)
VALUES ('casino_vip_01', 100000.00, false, 'vip')
ON CONFLICT (username) 
DO UPDATE SET 
    balance = 100000.00,
    account_type = 'vip',
    updated_at = NOW();

-- Account 3: casino_vip_02 (High Roller)
INSERT INTO user_wallets (username, balance, is_unlimited, account_type)
VALUES ('casino_vip_02', 75000.00, false, 'vip')
ON CONFLICT (username) 
DO UPDATE SET 
    balance = 75000.00,
    account_type = 'vip',
    updated_at = NOW();

-- Account 4: casino_vip_03 (High Roller)
INSERT INTO user_wallets (username, balance, is_unlimited, account_type)
VALUES ('casino_vip_03', 50000.00, false, 'vip')
ON CONFLICT (username) 
DO UPDATE SET 
    balance = 50000.00,
    account_type = 'vip',
    updated_at = NOW();

-- Account 5: casino_pro_01 (Professional Player)
INSERT INTO user_wallets (username, balance, is_unlimited, account_type)
VALUES ('casino_pro_01', 25000.00, false, 'professional')
ON CONFLICT (username) 
DO UPDATE SET 
    balance = 25000.00,
    account_type = 'professional',
    updated_at = NOW();

-- Account 6: casino_pro_02 (Professional Player)
INSERT INTO user_wallets (username, balance, is_unlimited, account_type)
VALUES ('casino_pro_02', 20000.00, false, 'professional')
ON CONFLICT (username) 
DO UPDATE SET 
    balance = 20000.00,
    account_type = 'professional',
    updated_at = NOW();

-- Account 7: casino_player_01 (Regular Player)
INSERT INTO user_wallets (username, balance, is_unlimited, account_type)
VALUES ('casino_player_01', 10000.00, false, 'regular')
ON CONFLICT (username) 
DO UPDATE SET 
    balance = 10000.00,
    account_type = 'regular',
    updated_at = NOW();

-- Account 8: casino_player_02 (Regular Player)
INSERT INTO user_wallets (username, balance, is_unlimited, account_type)
VALUES ('casino_player_02', 10000.00, false, 'regular')
ON CONFLICT (username) 
DO UPDATE SET 
    balance = 10000.00,
    account_type = 'regular',
    updated_at = NOW();

-- Account 9: casino_player_03 (Regular Player)
INSERT INTO user_wallets (username, balance, is_unlimited, account_type)
VALUES ('casino_player_03', 5000.00, false, 'regular')
ON CONFLICT (username) 
DO UPDATE SET 
    balance = 5000.00,
    account_type = 'regular',
    updated_at = NOW();

-- Account 10: casino_test_01 (Test Account)
INSERT INTO user_wallets (username, balance, is_unlimited, account_type)
VALUES ('casino_test_01', 5000.00, false, 'test')
ON CONFLICT (username) 
DO UPDATE SET 
    balance = 5000.00,
    account_type = 'test',
    updated_at = NOW();

-- Account 11: casino_demo (Demo Account)
INSERT INTO user_wallets (username, balance, is_unlimited, account_type)
VALUES ('casino_demo', 1000.00, false, 'demo')
ON CONFLICT (username) 
DO UPDATE SET 
    balance = 1000.00,
    account_type = 'demo',
    updated_at = NOW();

-- Log initial balance transactions for all accounts
INSERT INTO wallet_transactions (username, amount, transaction_type, balance_after, description)
VALUES 
    ('admin_nexus', 999999999.99, 'initial_load', 999999999.99, 'Admin account - Unlimited balance'),
    ('casino_vip_01', 100000.00, 'initial_load', 100000.00, 'VIP High Roller account'),
    ('casino_vip_02', 75000.00, 'initial_load', 75000.00, 'VIP High Roller account'),
    ('casino_vip_03', 50000.00, 'initial_load', 50000.00, 'VIP High Roller account'),
    ('casino_pro_01', 25000.00, 'initial_load', 25000.00, 'Professional player account'),
    ('casino_pro_02', 20000.00, 'initial_load', 20000.00, 'Professional player account'),
    ('casino_player_01', 10000.00, 'initial_load', 10000.00, 'Regular player account'),
    ('casino_player_02', 10000.00, 'initial_load', 10000.00, 'Regular player account'),
    ('casino_player_03', 5000.00, 'initial_load', 5000.00, 'Regular player account'),
    ('casino_test_01', 5000.00, 'initial_load', 5000.00, 'Test account'),
    ('casino_demo', 1000.00, 'initial_load', 1000.00, 'Demo account')
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
        WHEN 'professional' THEN 3
        WHEN 'regular' THEN 4
        WHEN 'test' THEN 5
        WHEN 'demo' THEN 6
    END,
    balance DESC;
