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

/*
RESTAURANTS
----------
Core tables for restaurant data management.
*/

-- Restaurant information
CREATE TABLE restaurants (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    address TEXT,
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    notes TEXT,
    user_id UUID NOT NULL,  -- Restaurant creator
    cuisine_type_id UUID,  -- Optional cuisine type
    street VARCHAR(255),
    street_number VARCHAR(50),
    postal_code VARCHAR(50),
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    phone_number VARCHAR(100),
    url VARCHAR(255),
    business_status VARCHAR(50),
    rating INTEGER,  -- User rating, not Google rating
    price_level INTEGER,
    opening_hours JSONB,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (cuisine_type_id) REFERENCES cuisine_types(id)
);

/*
VISITS
-----
Tables for tracking restaurant visits.
*/

-- Visit records
CREATE TABLE visits (
    id UUID PRIMARY KEY,
    date DATE NOT NULL,  -- Visit date
    time_of_day TIME NOT NULL,  -- Time of visit
    title VARCHAR(255),
    notes TEXT,
    user_id UUID NOT NULL,  -- Visit creator
    restaurant_id UUID NOT NULL,  -- Restaurant visited
    rating INTEGER,  -- User rating (1-5)
    price_paid_cents INTEGER,
    price_paid_currency VARCHAR(3),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id)
);