# 🧠 System Documentation (Auto Generated)

## 🔹 ACCOUNTS SYSTEM

### 📦 Tables
- account_audit_logs
- account_business_profiles
- account_kyc_documents
- account_members
- account_partners
- account_payout_profiles
- account_subscriptions
- accounts

### ⚡ Behaviors
- AFTER UPDATE on account_kyc_documents → kyc_verified_trigger()
- BEFORE DELETE on account_members → prevent_owner_delete()
- BEFORE UPDATE on account_members → prevent_owner_role_update()
- AFTER UPDATE on account_payout_profiles → payout_verified_trigger()
- AFTER INSERT on accounts → account_created_trigger()
- AFTER INSERT on accounts → audit_account_created()
- AFTER INSERT on accounts → assign_default_subscription()

---

## 🔹 MISC SYSTEM

### 📦 Tables
- addresses
- amenity_catalog
- cancellation_policies
- facility_catalog
- plan_limits
- properties
- subscription_plans
- terrain_catalog
- user_profiles
- users

### ⚡ Behaviors
- BEFORE INSERT on addresses → handle_address_geography()
- BEFORE INSERT on addresses → update_address_location()
- BEFORE INSERT on properties → sync_property_location()
- BEFORE UPDATE on user_profiles → update_timestamp()

---

## 🔹 RULES SYSTEM

### 📦 Tables
- entity_rules
- rule_categories
- rule_templates
- rules
- template_rules

---

## 🔹 EXPERIENCES SYSTEM

### 📦 Tables
- experience_properties
- experience_units
- experiences

---

## 🔹 MEDIA SYSTEM

### 📦 Tables
- media_assets
- media_links

---

## 🔹 PROPERTIES SYSTEM

### 📦 Tables
- property_addons
- property_claims
- property_facilities
- property_google_data
- property_members
- property_seasons
- property_terrains
- property_transfers
- property_transport_hubs
- property_units
- property_verifications

---

## 🔹 UNITS SYSTEM

### 📦 Tables
- unit_amenities
- unit_availability_exceptions
- unit_availability_schedules
- unit_cancellation_policies
- unit_categories
- unit_context
- unit_food_options
- unit_pricing_components
- unit_pricing_plans
- unit_space_configs
- unit_stay_configs
- unit_type_catalog
- unit_types

---

