-- BentoBook Database Schema Specification
-- Created by: mrkshm
-- Date: 2025-03-25

/*
AUTHENTICATION & USERS
---------------------
Core tables for user management and authentication.
*/

-- Core user authentication
CREATE TABLE users (
    id UUID PRIMARY KEY,  -- For privacy/security reasons
    email VARCHAR(255) UNIQUE NOT NULL,  -- Login identifier
    username VARCHAR(150) UNIQUE NOT NULL,  -- Public display name
    password_hash VARCHAR(255) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    is_staff BOOLEAN NOT NULL DEFAULT FALSE,
    is_superuser BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL,
    last_login TIMESTAMPTZ
);

-- Extended user information
CREATE TABLE profiles (
    user_id UUID PRIMARY KEY,  -- This is both PK and FK
    preferred_language VARCHAR(10) NOT NULL DEFAULT 'en',  -- User's preferred language
    preferred_theme VARCHAR(10) NOT NULL DEFAULT 'light',  -- User's preferred theme
    bio TEXT,  -- Optional user description
    first_name TEXT,  -- Optional, user's first name
    last_name TEXT,  -- Optional, user's last name
    location VARCHAR(100),  -- Optional, user's general location
    notification_preferences JSONB NOT NULL,  -- Flexible notification settings
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

/*
IMPLEMENTATION NOTES
-------------------
1. All timestamps should be stored in UTC
2. UUIDs preferred over sequential IDs for privacy
3. Implement updated_at triggers for all tables
4. Consider adding indexes based on access patterns
5. Profile deletion should cascade from user deletion
6. JSONB used for flexible notification settings structure
*/