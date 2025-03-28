# BentoBook

## General

DO NOT install new gems or dependencies without asking first.

## Base Setup

This is a Rails 8 app setup with Vite. We are using Tailwind CSS for styling and Tailwind UI for components. (There are still DaisyUI components present but we will weed them out.)
We use good dev practices Hotwire, Stimulus, Turbo. We also have AlpineJS installed, but just like Daisy UI we will remove it ASAP.

## File Locations

Since this is a Vite / Rails setup, the frontend code is located in the `app/frontend` directory. Javascript controllers are located in the `app/frontend/controllers` directory.

## Domain Models

### Restaurants
Restaurants are the central model of the application. Users can add restaurants, rate them, add notes, and organize them into lists.

### Visits
Visits represent a user's visit to a restaurant. A visit has a date and time (stored as separate date and time_of_day fields), can have a rating, price paid, notes, and can be associated with contacts the user dined with.

### Lists
Lists are collections of restaurants. They can be shared with other users with different permission levels.

## Some Gems

- Devise for auth
- ViewComponents for some UI
- Money-Rails for handling currency
- PgSearch for full-text search
