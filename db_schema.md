# BentoBook Database Schema

This document provides a human-readable overview of the BentoBook database schema.

## User Management

### Users
- **id**: bigint, primary key
- **email**: varchar, unique, not null
- **encrypted_password**: varchar, not null
- **reset_password_token**: varchar, unique
- **reset_password_sent_at**: timestamp
- **remember_created_at**: timestamp
- **sign_in_count**: integer, not null, default 0
- **current_sign_in_at**: timestamp
- **last_sign_in_at**: timestamp
- **current_sign_in_ip**: varchar
- **last_sign_in_ip**: varchar
- **confirmation_token**: varchar, unique
- **confirmed_at**: timestamp
- **confirmation_sent_at**: timestamp
- **unconfirmed_email**: varchar
- **failed_attempts**: integer, not null, default 0
- **unlock_token**: varchar, unique
- **locked_at**: timestamp
- **created_at**: timestamp, not null
- **updated_at**: timestamp, not null

### Profiles
- **id**: bigint, primary key
- **user_id**: bigint, not null (FK → users.id)
- **username**: varchar
- **first_name**: varchar
- **last_name**: varchar
- **about**: text
- **preferred_language**: varchar, default 'en'
- **preferred_theme**: varchar, default 'light'
- **created_at**: timestamp, not null
- **updated_at**: timestamp, not null
- *Indexes*: user_id

### User Sessions
- **id**: bigint, primary key
- **user_id**: bigint, not null (FK → users.id)
- **jti**: varchar, unique, not null
- **client_name**: varchar, not null
- **last_used_at**: timestamp, not null
- **ip_address**: varchar
- **user_agent**: varchar
- **active**: boolean, not null, default true
- **suspicious**: boolean, default false
- **device_type**: varchar
- **os_name**: varchar
- **os_version**: varchar
- **browser_name**: varchar
- **browser_version**: varchar
- **last_ip_address**: varchar
- **location_country**: varchar
- **created_at**: timestamp, not null
- **updated_at**: timestamp, not null
- *Indexes*: user_id, jti, active, last_used_at, suspicious, user_id/client_name, device_type

## Restaurant Data

### Restaurants
- **id**: bigint, primary key
- **name**: varchar
- **address**: text, indexed
- **latitude**: numeric(10,8)
- **longitude**: numeric(11,8)
- **notes**: text, indexed
- **user_id**: bigint (FK → users.id)
- **google_restaurant_id**: bigint (FK → google_restaurants.id)
- **cuisine_type_id**: bigint (FK → cuisine_types.id)
- **street**: varchar
- **street_number**: varchar
- **postal_code**: varchar
- **city**: varchar, indexed
- **state**: varchar
- **country**: varchar
- **phone_number**: varchar
- **url**: varchar
- **business_status**: varchar
- **rating**: integer
- **price_level**: integer
- **opening_hours**: json
- **favorite**: boolean, default false, indexed
- **original_restaurant_id**: bigint (FK → restaurants.id)
- **created_at**: timestamp, not null
- **updated_at**: timestamp, not null
- *Unique Indexes*: user_id/google_restaurant_id
- *Indexes*: name, notes, favorite, cuisine_type_id

### Google Restaurants
- **id**: bigint, primary key
- **name**: varchar, indexed
- **google_place_id**: varchar, unique
- **address**: text, indexed
- **latitude**: numeric(10,8)
- **longitude**: numeric(11,8)
- **location**: geometry(Point,4326), indexed
- **street**: varchar
- **street_number**: varchar
- **postal_code**: varchar
- **city**: varchar, indexed
- **state**: varchar
- **country**: varchar
- **phone_number**: varchar
- **url**: varchar
- **business_status**: varchar
- **google_rating**: double precision
- **google_ratings_total**: integer
- **price_level**: integer
- **opening_hours**: json
- **google_updated_at**: timestamp
- **created_at**: timestamp, not null
- **updated_at**: timestamp, not null

### Cuisine Types
- **id**: bigint, primary key
- **name**: varchar, unique
- **created_at**: timestamp, not null
- **updated_at**: timestamp, not null

### Restaurant Copies
- **id**: bigint, primary key
- **user_id**: bigint, not null (FK → users.id)
- **restaurant_id**: bigint, not null (FK → restaurants.id)
- **copied_restaurant_id**: bigint, not null (FK → restaurants.id)
- **created_at**: timestamp, not null
- **updated_at**: timestamp, not null
- *Unique Indexes*: user_id/restaurant_id

## Lists and Sharing

### Lists
- **id**: bigint, primary key
- **name**: varchar, not null
- **description**: text
- **owner_type**: varchar, not null
- **owner_id**: bigint, not null
- **visibility**: integer, default 0
- **premium**: boolean, default false
- **position**: integer
- **created_at**: timestamp, not null
- **updated_at**: timestamp, not null
- *Indexes*: owner_type/owner_id

### List Restaurants
- **id**: bigint, primary key
- **list_id**: bigint, not null (FK → lists.id)
- **restaurant_id**: bigint, not null (FK → restaurants.id)
- **position**: integer
- **created_at**: timestamp, not null
- **updated_at**: timestamp, not null
- *Unique Indexes*: list_id/restaurant_id

### Shares
- **id**: bigint, primary key
- **creator_id**: bigint, not null (FK → users.id)
- **recipient_id**: bigint, not null (FK → users.id)
- **shareable_type**: varchar, not null
- **shareable_id**: bigint, not null
- **permission**: integer, default 0
- **status**: integer, default 0
- **reshareable**: boolean, default true, not null
- **created_at**: timestamp, not null
- **updated_at**: timestamp, not null
- *Unique Indexes*: creator_id/recipient_id/shareable_type/shareable_id
- *Indexes*: creator_id, recipient_id, shareable_type/shareable_id

## Visits and Contacts

### Visits
- **id**: bigint, primary key
- **date**: date
- **title**: varchar
- **notes**: text
- **user_id**: bigint, not null (FK → users.id)
- **restaurant_id**: bigint, not null (FK → restaurants.id)
- **rating**: integer
- **price_paid_cents**: integer
- **price_paid_currency**: varchar
- **created_at**: timestamp, not null
- **updated_at**: timestamp, not null
- *Indexes*: user_id, restaurant_id

### Contacts
- **id**: bigint, primary key
- **name**: varchar
- **email**: varchar
- **city**: varchar
- **country**: varchar
- **phone**: varchar
- **notes**: text
- **user_id**: bigint, not null (FK → users.id)
- **created_at**: timestamp, not null
- **updated_at**: timestamp, not null
- *Indexes*: user_id

### Visit Contacts
- **id**: bigint, primary key
- **visit_id**: bigint, not null (FK → visits.id)
- **contact_id**: bigint, not null (FK → contacts.id)
- **created_at**: timestamp, not null
- **updated_at**: timestamp, not null
- *Indexes*: visit_id, contact_id

## Images and Storage

### Images
- **id**: bigint, primary key
- **imageable_type**: varchar, not null
- **imageable_id**: bigint, not null
- **is_cover**: boolean
- **title**: varchar
- **description**: text
- **created_at**: timestamp, not null
- **updated_at**: timestamp, not null
- *Indexes*: imageable_type/imageable_id

### Active Storage (Blobs, Attachments, Variants)
- **active_storage_blobs**: Stores metadata for uploaded files
- **active_storage_attachments**: Links blobs to application records
- **active_storage_variant_records**: Tracks variants of original images

## Organizations

### Organizations
- **id**: bigint, primary key
- **created_at**: timestamp, not null
- **updated_at**: timestamp, not null

### Memberships
- **id**: bigint, primary key
- **user_id**: bigint, not null (FK → users.id)
- **organization_id**: bigint, not null (FK → organizations.id)
- **role**: varchar
- **created_at**: timestamp, not null
- **updated_at**: timestamp, not null
- *Indexes*: user_id, organization_id

## Tagging System

### Tags
- **id**: bigint, primary key
- **name**: varchar, unique
- **taggings_count**: integer, default 0
- **created_at**: timestamp, not null
- **updated_at**: timestamp, not null

### Taggings
- **id**: bigint, primary key
- **tag_id**: bigint (FK → tags.id)
- **taggable_type**: varchar
- **taggable_id**: bigint
- **tagger_type**: varchar
- **tagger_id**: bigint
- **context**: varchar(128)
- **tenant**: varchar(128)
- **created_at**: timestamp
- *Unique Indexes*: tag_id/taggable_id/taggable_type/context/tagger_id/tagger_type
- *Indexes*: Various combinations of the fields

## Search

### PG Search Documents
- **id**: bigint, primary key
- **content**: text
- **searchable_type**: varchar
- **searchable_id**: bigint
- **created_at**: timestamp, not null
- **updated_at**: timestamp, not null
- *Indexes*: searchable_type/searchable_id