# BentoBook API Routes

This document provides an overview of all API endpoints available in the BentoBook application.

## General Routes

- `POST /subscribe` - Create a new subscription
- `GET /configurations/ios_v1` - Get iOS v1 configuration

## API v1 Endpoints

All API endpoints are namespaced under `/api/v1` and return JSON responses.

### Authentication & Session Management

- `POST /api/v1/sessions` - Create a new session (login)
- `GET /api/v1/sessions` - List all sessions
- `DELETE /api/v1/session` - Logout current session
- `DELETE /api/v1/sessions/:id` - Logout specific session
- `DELETE /api/v1/sessions` - Logout all other sessions
- `POST /api/v1/refresh_token` - Refresh authentication token
- `POST /api/v1/register` - Register a new user

### Profile Management

- `GET /api/v1/profile` - Get user profile
- `PATCH /api/v1/profile` - Update profile
- `PUT /api/v1/profile` - Update profile (alternate)
- `PATCH /api/v1/profile/avatar` - Update profile avatar
- `DELETE /api/v1/profile/avatar` - Delete profile avatar
- `GET /api/v1/profiles/search` - Search profiles
- `PATCH /api/v1/profile/locale` - Change user locale
- `PATCH /api/v1/profile/theme` - Change user theme
- `POST /api/v1/usernames/verify` - Verify username availability

### Restaurants

- `GET /api/v1/restaurants` - List restaurants
- `POST /api/v1/restaurants` - Create restaurant
- `GET /api/v1/restaurants/:id` - Show restaurant
- `PATCH /api/v1/restaurants/:id` - Update restaurant
- `PUT /api/v1/restaurants/:id` - Update restaurant (alternate)
- `DELETE /api/v1/restaurants/:id` - Delete restaurant
- `POST /api/v1/restaurants/:id/add_tag` - Add tag to restaurant
- `DELETE /api/v1/restaurants/:id/remove_tag` - Remove tag from restaurant
- `PATCH /api/v1/restaurants/:id/update_rating` - Update restaurant rating

#### Restaurant Images

- `POST /api/v1/restaurants/:restaurant_id/images` - Add image to restaurant
- `DELETE /api/v1/restaurants/:restaurant_id/images/:id` - Remove image from restaurant

### Contacts

- `GET /api/v1/contacts` - List contacts
- `POST /api/v1/contacts` - Create contact
- `GET /api/v1/contacts/:id` - Show contact
- `PATCH /api/v1/contacts/:id` - Update contact
- `PUT /api/v1/contacts/:id` - Update contact (alternate)
- `DELETE /api/v1/contacts/:id` - Delete contact
- `GET /api/v1/contacts/search` - Search contacts

### Visits

- `GET /api/v1/visits` - List visits
- `POST /api/v1/visits` - Create visit
- `GET /api/v1/visits/:id` - Show visit
- `PATCH /api/v1/visits/:id` - Update visit
- `PUT /api/v1/visits/:id` - Update visit (alternate)
- `DELETE /api/v1/visits/:id` - Delete visit

#### Visit Images

- `POST /api/v1/visits/:visit_id/images` - Add image to visit
- `DELETE /api/v1/visits/:visit_id/images/:id` - Remove image from visit

### Images

- `DELETE /api/v1/images/:id` - Delete image

### Shares

- `GET /api/v1/shares` - List shares
- `DELETE /api/v1/shares/:id` - Delete share
- `POST /api/v1/shares/:id/accept` - Accept share
- `POST /api/v1/shares/:id/decline` - Decline share
- `POST /api/v1/shares/accept_all` - Accept all shares
- `POST /api/v1/shares/decline_all` - Decline all shares

### Lists

- `GET /api/v1/lists` - List lists
- `POST /api/v1/lists` - Create list
- `GET /api/v1/lists/:id` - Show list
- `PATCH /api/v1/lists/:id` - Update list
- `PUT /api/v1/lists/:id` - Update list (alternate)
- `DELETE /api/v1/lists/:id` - Delete list
- `GET /api/v1/lists/:id/export` - Export list

#### List Restaurants

- `POST /api/v1/lists/:list_id/restaurants` - Add restaurant to list
- `DELETE /api/v1/lists/:list_id/restaurants/:id` - Remove restaurant from list

#### List Shares

- `GET /api/v1/lists/:list_id/shares` - List shares for a list
- `POST /api/v1/lists/:list_id/shares` - Create share for a list