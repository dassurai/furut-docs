create extension if not exists "hypopg" with schema "extensions";

create extension if not exists "index_advisor" with schema "extensions";

create extension if not exists "postgis" with schema "extensions";

drop extension if exists "pg_net";

create extension if not exists "pg_trgm" with schema "public";

create type "public"."add_on_status" as enum ('DRAFT', 'PUBLISHED');

create type "public"."add_on_type" as enum ('QUANTITY', 'PER_PERSON');

create type "public"."bookable_unit_type" as enum ('UNIT_BASED', 'CAPACITY_BASED', 'TIME_BASED');

create type "public"."meal_serving_location" as enum ('RESTAURANT', 'COMMON_DINING', 'PRIVATE_DINING');

create type "public"."meal_type" as enum ('BREAKFAST', 'LUNCH', 'DINNER', 'SNACKS', 'WELCOME_DRINK');

create type "public"."pricing_basis" as enum ('PER_STAY', 'PER_PERSON', 'PER_SPOT');

create type "public"."property_audit_event" as enum ('PROPERTY_CREATED', 'PROPERTY_UPDATED', 'PROPERTY_VERIFICATION_SUBMITTED', 'PROPERTY_VERIFIED', 'PROPERTY_PUBLISHED', 'PROPERTY_SUSPENDED', 'ADD_ON_CREATED', 'ADD_ON_PUBLISHED');

create type "public"."property_status" as enum ('DRAFT', 'VERIFICATION_PENDING', 'PUBLISHED', 'SUSPENDED');

create type "public"."property_type" as enum ('STAY', 'VENUE');

create type "public"."rule_category" as enum ('CHECKIN', 'NOISE', 'SMOKING', 'PETS', 'GUESTS', 'SAFETY', 'ENVIRONMENT', 'CLEANLINESS', 'ACCESS', 'AMENITIES', 'DINING', 'PARKING', 'CONDUCT', 'DAMAGE', 'LEGAL');

create type "public"."rule_control_type" as enum ('TOGGLE', 'TIME_RANGE', 'NUMERIC', 'RADIO', 'MULTI_SELECT', 'LOCKED');

create type "public"."stay_pricing_model" as enum ('UNIT_PER_NIGHT', 'PERSON_PER_NIGHT', 'WORKATION');

create type "public"."user_type" as enum ('guest', 'host', 'admin');


  create table "public"."account_audit_logs" (
    "id" uuid not null default gen_random_uuid(),
    "account_id" uuid not null,
    "event" text not null,
    "actor_id" uuid,
    "metadata" jsonb,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."account_audit_logs" enable row level security;


  create table "public"."account_business_profiles" (
    "account_id" uuid not null,
    "legal_name" text,
    "registration_number" text,
    "tax_id" text,
    "support_email" text,
    "support_phone" text,
    "registered_address_id" uuid,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."account_business_profiles" enable row level security;


  create table "public"."account_kyc_documents" (
    "id" uuid not null default gen_random_uuid(),
    "account_id" uuid not null,
    "document_type" text not null,
    "document_url" text not null,
    "verification_status" text not null default 'PENDING'::text,
    "uploaded_at" timestamp with time zone default now(),
    "verified_at" timestamp with time zone,
    "rejected_reason" text,
    "verified_by" uuid,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."account_kyc_documents" enable row level security;


  create table "public"."account_members" (
    "id" uuid not null default gen_random_uuid(),
    "account_id" uuid not null,
    "user_id" uuid not null,
    "role" text not null,
    "status" text not null default 'ACTIVE'::text,
    "joined_at" timestamp with time zone default now()
      );


alter table "public"."account_members" enable row level security;


  create table "public"."account_partners" (
    "id" uuid not null default gen_random_uuid(),
    "host_account_id" uuid not null,
    "partner_account_id" uuid not null,
    "commission_rate" numeric(5,2) not null default 0,
    "status" text not null default 'ACTIVE'::text,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."account_partners" enable row level security;


  create table "public"."account_payout_profiles" (
    "id" uuid not null default gen_random_uuid(),
    "account_id" uuid not null,
    "account_holder_name" text not null,
    "bank_name" text not null,
    "account_number" text not null,
    "ifsc_code" text not null,
    "currency" text not null default 'INR'::text,
    "is_active" boolean not null default true,
    "verification_status" text not null default 'PENDING'::text,
    "created_at" timestamp with time zone default now(),
    "verified_at" timestamp with time zone
      );


alter table "public"."account_payout_profiles" enable row level security;


  create table "public"."account_subscriptions" (
    "id" uuid not null default gen_random_uuid(),
    "account_id" uuid not null,
    "plan_id" uuid not null,
    "billing_cycle" text not null default 'MONTHLY'::text,
    "status" text not null default 'ACTIVE'::text,
    "started_at" timestamp with time zone default now(),
    "expires_at" timestamp with time zone,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."account_subscriptions" enable row level security;


  create table "public"."accounts" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "slug" text not null,
    "type" text not null,
    "status" text not null default 'PENDING_COMPLIENCE'::text,
    "country" text not null default 'India'::text,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."accounts" enable row level security;


  create table "public"."addresses" (
    "id" uuid not null default gen_random_uuid(),
    "country" text not null,
    "state" text not null,
    "district" text,
    "city" text,
    "locality" text,
    "postal_code" text,
    "line1" text,
    "line2" text,
    "latitude" numeric(9,6),
    "longitude" numeric(9,6),
    "created_at" timestamp with time zone default now(),
    "location" extensions.geography(Point,4326),
    "created_by" uuid,
    "g_place_id" text,
    "google_place_types" text[],
    "label" text
      );


alter table "public"."addresses" enable row level security;


  create table "public"."amenity_catalog" (
    "id" uuid not null default gen_random_uuid(),
    "key" text not null,
    "name" text not null,
    "description" text,
    "created_at" timestamp with time zone default now(),
    "category" text,
    "icon" text,
    "applies_to" text
      );


alter table "public"."amenity_catalog" enable row level security;


  create table "public"."cancellation_policies" (
    "id" uuid not null default gen_random_uuid(),
    "property_id" uuid not null,
    "name" text not null,
    "policy_type" text not null,
    "full_refund_days" integer not null,
    "partial_refund_start" integer,
    "partial_refund_end" integer,
    "partial_refund_percent" integer,
    "advance_percent" integer not null default 30,
    "advance_non_refundable" boolean default false,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."cancellation_policies" enable row level security;


  create table "public"."entity_rules" (
    "id" uuid not null default gen_random_uuid(),
    "entity_type" text not null,
    "entity_id" uuid not null,
    "rule_id" uuid not null,
    "is_enabled" boolean default true,
    "value_override" jsonb,
    "custom_text" text,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."entity_rules" enable row level security;


  create table "public"."experience_properties" (
    "id" uuid not null default gen_random_uuid(),
    "experience_id" uuid not null,
    "property_id" uuid not null,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."experience_properties" enable row level security;


  create table "public"."experience_units" (
    "id" uuid not null default gen_random_uuid(),
    "experience_id" uuid not null,
    "unit_id" uuid not null,
    "role" text,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."experience_units" enable row level security;


  create table "public"."experiences" (
    "id" uuid not null default gen_random_uuid(),
    "host_account_id" uuid not null,
    "title" text not null,
    "description" text,
    "duration_minutes" integer,
    "experience_type" text,
    "status" text default 'DRAFT'::text,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."experiences" enable row level security;


  create table "public"."facility_catalog" (
    "id" uuid not null default gen_random_uuid(),
    "key" text not null,
    "name" text not null,
    "description" text,
    "created_at" timestamp with time zone default now(),
    "icon" text,
    "category" text,
    "is_popular" boolean default false,
    "sort_order" integer default 0
      );


alter table "public"."facility_catalog" enable row level security;


  create table "public"."media_assets" (
    "id" uuid not null default gen_random_uuid(),
    "account_id" uuid not null,
    "url" text not null,
    "media_type" text not null,
    "size_bytes" bigint,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."media_assets" enable row level security;


  create table "public"."media_links" (
    "id" uuid not null default gen_random_uuid(),
    "media_id" uuid not null,
    "entity_type" text not null,
    "entity_id" uuid not null,
    "sort_order" integer default 0,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."media_links" enable row level security;


  create table "public"."plan_limits" (
    "id" uuid not null default gen_random_uuid(),
    "plan_id" uuid not null,
    "feature_key" text not null,
    "feature_value" text not null
      );


alter table "public"."plan_limits" enable row level security;


  create table "public"."properties" (
    "id" uuid not null default gen_random_uuid(),
    "account_id" uuid not null,
    "address_id" uuid not null,
    "name" text not null,
    "slug" text not null,
    "google_place_types" text[] default '{}'::text[],
    "status" text not null default 'DRAFT'::text,
    "description" text,
    "location" extensions.geography(Point,4326),
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "google_place_id" text,
    "has_google_place" boolean default false,
    "created_by" uuid,
    "listing_source" text,
    "ownership_status" text default 'OWNED'::text,
    "creation_step" smallint default 0,
    "canonical_property_id" uuid,
    "deleted_at" timestamp with time zone,
    "is_google_business" boolean default false,
    "metadata" jsonb default '{}'::jsonb
      );


alter table "public"."properties" enable row level security;


  create table "public"."property_addons" (
    "id" uuid not null default gen_random_uuid(),
    "property_id" uuid not null,
    "name" text not null,
    "description" text,
    "addon_type" text not null,
    "pricing_type" text not null,
    "status" text not null default 'DRAFT'::text,
    "created_by" uuid,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."property_addons" enable row level security;


  create table "public"."property_claims" (
    "id" uuid not null default gen_random_uuid(),
    "property_id" uuid,
    "user_id" uuid,
    "status" text,
    "created_at" timestamp with time zone default now(),
    "resolved_at" timestamp with time zone,
    "resolved_by" uuid
      );


alter table "public"."property_claims" enable row level security;


  create table "public"."property_facilities" (
    "id" uuid not null default gen_random_uuid(),
    "property_id" uuid not null,
    "facility_id" uuid not null,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."property_facilities" enable row level security;


  create table "public"."property_google_data" (
    "id" uuid not null default gen_random_uuid(),
    "property_id" uuid,
    "google_place_id" text not null,
    "name" text,
    "formatted_address" text,
    "latitude" double precision,
    "longitude" double precision,
    "rating" numeric,
    "user_ratings_total" integer,
    "types" text[],
    "raw" jsonb,
    "last_synced_at" timestamp with time zone default now(),
    "created_at" timestamp with time zone default now()
      );


alter table "public"."property_google_data" enable row level security;


  create table "public"."property_members" (
    "id" uuid not null default gen_random_uuid(),
    "property_id" uuid not null,
    "user_id" uuid not null,
    "role" text not null,
    "status" text not null default 'ACTIVE'::text,
    "joined_at" timestamp with time zone default now()
      );


alter table "public"."property_members" enable row level security;


  create table "public"."property_seasons" (
    "id" uuid not null default gen_random_uuid(),
    "property_id" uuid not null,
    "season" text not null,
    "highlight" text,
    "created_at" timestamp with time zone default now(),
    "tags" text[],
    "notes" text,
    "image" text
      );


alter table "public"."property_seasons" enable row level security;


  create table "public"."property_terrains" (
    "id" uuid not null default gen_random_uuid(),
    "property_id" uuid not null,
    "terrain_id" uuid not null,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."property_terrains" enable row level security;


  create table "public"."property_transfers" (
    "id" uuid not null default gen_random_uuid(),
    "property_id" uuid not null,
    "from_account_id" uuid not null,
    "to_account_id" uuid not null,
    "initiated_by" uuid not null,
    "accepted_by" uuid,
    "status" text not null,
    "reason" text,
    "created_at" timestamp with time zone default now(),
    "completed_at" timestamp with time zone
      );


alter table "public"."property_transfers" enable row level security;


  create table "public"."property_transport_hubs" (
    "id" uuid not null default gen_random_uuid(),
    "property_id" uuid not null,
    "hub_type" text not null,
    "name" text not null,
    "distance_km" numeric(6,2),
    "travel_time_minutes" integer,
    "notes" text,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."property_transport_hubs" enable row level security;


  create table "public"."property_units" (
    "id" uuid not null default gen_random_uuid(),
    "property_id" uuid not null,
    "name" text not null,
    "unit_count" integer,
    "description" text,
    "status" text not null default 'ACTIVE'::text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "unit_type_id" uuid not null,
    "is_sleep_enabled" boolean default true,
    "is_bookable" boolean default true
      );


alter table "public"."property_units" enable row level security;


  create table "public"."property_verifications" (
    "id" uuid not null default gen_random_uuid(),
    "property_id" uuid not null,
    "verification_status" text not null,
    "verified_by" uuid,
    "notes" text,
    "verified_at" timestamp with time zone,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."property_verifications" enable row level security;


  create table "public"."rule_categories" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "description" text,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."rule_categories" enable row level security;


  create table "public"."rule_templates" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "description" text,
    "applies_to" text not null,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."rule_templates" enable row level security;


  create table "public"."rules" (
    "id" uuid not null default gen_random_uuid(),
    "category_id" uuid not null,
    "key" text not null,
    "label" text not null,
    "type" text not null,
    "default_value" jsonb,
    "description" text,
    "is_locked" boolean default false,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."rules" enable row level security;


  create table "public"."subscription_plans" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "description" text,
    "monthly_price" numeric(10,2) default 0,
    "yearly_price" numeric(10,2) default 0,
    "currency" text default 'INR'::text,
    "is_active" boolean default true,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."subscription_plans" enable row level security;


  create table "public"."template_rules" (
    "id" uuid not null default gen_random_uuid(),
    "template_id" uuid not null,
    "rule_id" uuid not null,
    "is_enabled" boolean default true,
    "default_value" jsonb,
    "custom_text" text,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."template_rules" enable row level security;


  create table "public"."terrain_catalog" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "description" text,
    "icon" text,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."terrain_catalog" enable row level security;


  create table "public"."unit_amenities" (
    "id" uuid not null default gen_random_uuid(),
    "unit_id" uuid not null,
    "amenity_id" uuid not null,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."unit_amenities" enable row level security;


  create table "public"."unit_availability_exceptions" (
    "id" uuid not null default gen_random_uuid(),
    "unit_id" uuid not null,
    "date" date not null,
    "open_time" time without time zone,
    "close_time" time without time zone,
    "is_closed" boolean default false,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."unit_availability_exceptions" enable row level security;


  create table "public"."unit_availability_schedules" (
    "id" uuid not null default gen_random_uuid(),
    "unit_id" uuid not null,
    "day_of_week" integer not null,
    "open_time" time without time zone not null,
    "close_time" time without time zone not null,
    "is_closed" boolean default false,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."unit_availability_schedules" enable row level security;


  create table "public"."unit_cancellation_policies" (
    "id" uuid not null default gen_random_uuid(),
    "unit_id" uuid not null,
    "policy_id" uuid not null,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."unit_cancellation_policies" enable row level security;


  create table "public"."unit_categories" (
    "id" uuid not null default gen_random_uuid(),
    "key" text not null,
    "name" text not null,
    "description" text,
    "image_url" text,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."unit_categories" enable row level security;


  create table "public"."unit_context" (
    "unit_id" uuid not null,
    "primary_intent" text,
    "usage_mode" text,
    "space_shape" text,
    "sleep_distribution" text,
    "bathroom_distribution" text,
    "kitchen_model" text,
    "access_model" text,
    "availability_model" text,
    "privacy_model" text,
    "experience_type" text,
    "is_composable" boolean default false,
    "is_primary_unit" boolean default true,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."unit_context" enable row level security;


  create table "public"."unit_food_options" (
    "id" uuid not null default gen_random_uuid(),
    "unit_id" uuid not null,
    "meal_types" text[] not null,
    "is_included" boolean not null default true,
    "serving_types" text[],
    "created_at" timestamp with time zone default now()
      );


alter table "public"."unit_food_options" enable row level security;


  create table "public"."unit_pricing_components" (
    "id" uuid not null default gen_random_uuid(),
    "pricing_plan_id" uuid not null,
    "component_type" text not null,
    "label" text,
    "price" numeric not null,
    "metadata" jsonb,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."unit_pricing_components" enable row level security;


  create table "public"."unit_pricing_plans" (
    "id" uuid not null default gen_random_uuid(),
    "unit_id" uuid not null,
    "name" text not null,
    "pricing_model" text not null,
    "currency" text not null default 'INR'::text,
    "is_default" boolean not null default false,
    "is_active" boolean not null default true,
    "start_date" date,
    "end_date" date,
    "created_at" timestamp with time zone default now(),
    "is_food_included" boolean not null default false,
    "pricing_behavior" text
      );


alter table "public"."unit_pricing_plans" enable row level security;


  create table "public"."unit_space_configs" (
    "unit_id" uuid not null,
    "opens_at" time without time zone,
    "closes_at" time without time zone,
    "min_hours" integer default 1,
    "max_capacity" integer,
    "created_at" timestamp with time zone default now(),
    "usage_type" text
      );


alter table "public"."unit_space_configs" enable row level security;


  create table "public"."unit_stay_configs" (
    "unit_id" uuid not null,
    "check_in_time" time without time zone,
    "check_out_time" time without time zone,
    "min_nights" integer default 1,
    "max_nights" integer,
    "max_guests" integer,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."unit_stay_configs" enable row level security;


  create table "public"."unit_type_catalog" (
    "id" uuid not null default gen_random_uuid(),
    "category_id" uuid not null,
    "key" text not null,
    "name" text not null,
    "description" text,
    "image_url" text,
    "booking_mode" text not null,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."unit_type_catalog" enable row level security;


  create table "public"."unit_types" (
    "id" uuid not null default gen_random_uuid(),
    "key" text not null,
    "label" text not null,
    "description" text,
    "created_at" timestamp with time zone default now(),
    "default_intent" text,
    "default_space_shape" text,
    "default_sleep_distribution" text
      );


alter table "public"."unit_types" enable row level security;


  create table "public"."user_profiles" (
    "user_id" uuid not null,
    "full_name" text not null,
    "about" text,
    "languages" text[],
    "alternative_phone" text,
    "user_type" text[],
    "app_source" text,
    "updated_at" timestamp with time zone not null default now(),
    "avatar" character varying
      );


alter table "public"."user_profiles" enable row level security;


  create table "public"."users" (
    "id" uuid not null default gen_random_uuid(),
    "firebase_uid" text not null,
    "email" text not null,
    "phone" text not null,
    "phone_verified" boolean not null default false,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."users" enable row level security;

CREATE UNIQUE INDEX account_audit_logs_pkey ON public.account_audit_logs USING btree (id);

CREATE UNIQUE INDEX account_business_profiles_pkey ON public.account_business_profiles USING btree (account_id);

CREATE UNIQUE INDEX account_kyc_documents_pkey ON public.account_kyc_documents USING btree (id);

CREATE UNIQUE INDEX account_members_pkey ON public.account_members USING btree (id);

CREATE UNIQUE INDEX account_members_unique ON public.account_members USING btree (account_id, user_id);

CREATE UNIQUE INDEX account_partners_pkey ON public.account_partners USING btree (id);

CREATE UNIQUE INDEX account_payout_profiles_pkey ON public.account_payout_profiles USING btree (id);

CREATE UNIQUE INDEX account_subscriptions_pkey ON public.account_subscriptions USING btree (id);

CREATE UNIQUE INDEX accounts_pkey ON public.accounts USING btree (id);

CREATE UNIQUE INDEX accounts_slug_key ON public.accounts USING btree (slug);

CREATE UNIQUE INDEX addresses_pkey ON public.addresses USING btree (id);

CREATE UNIQUE INDEX amenity_catalog_key_key ON public.amenity_catalog USING btree (key);

CREATE UNIQUE INDEX amenity_catalog_pkey ON public.amenity_catalog USING btree (id);

CREATE UNIQUE INDEX cancellation_policies_pkey ON public.cancellation_policies USING btree (id);

CREATE UNIQUE INDEX entity_rules_pkey ON public.entity_rules USING btree (id);

CREATE UNIQUE INDEX experience_properties_pkey ON public.experience_properties USING btree (id);

CREATE UNIQUE INDEX experience_units_pkey ON public.experience_units USING btree (id);

CREATE UNIQUE INDEX experiences_pkey ON public.experiences USING btree (id);

CREATE UNIQUE INDEX facility_catalog_key_key ON public.facility_catalog USING btree (key);

CREATE UNIQUE INDEX facility_catalog_pkey ON public.facility_catalog USING btree (id);

CREATE INDEX idx_account_audit_logs_account ON public.account_audit_logs USING btree (account_id);

CREATE INDEX idx_account_audit_logs_event ON public.account_audit_logs USING btree (event);

CREATE INDEX idx_account_business_profiles_account ON public.account_business_profiles USING btree (account_id);

CREATE INDEX idx_account_kyc_account ON public.account_kyc_documents USING btree (account_id);

CREATE INDEX idx_account_kyc_type ON public.account_kyc_documents USING btree (document_type);

CREATE INDEX idx_account_members_account ON public.account_members USING btree (account_id);

CREATE INDEX idx_account_members_user ON public.account_members USING btree (user_id);

CREATE INDEX idx_account_partners_host ON public.account_partners USING btree (host_account_id);

CREATE INDEX idx_account_partners_partner ON public.account_partners USING btree (partner_account_id);

CREATE INDEX idx_account_payout_profiles_account ON public.account_payout_profiles USING btree (account_id);

CREATE INDEX idx_account_subscriptions_account ON public.account_subscriptions USING btree (account_id);

CREATE INDEX idx_account_subscriptions_status ON public.account_subscriptions USING btree (status);

CREATE INDEX idx_accounts_country ON public.accounts USING btree (country);

CREATE INDEX idx_accounts_status ON public.accounts USING btree (status);

CREATE INDEX idx_accounts_type ON public.accounts USING btree (type);

CREATE INDEX idx_addresses_city ON public.addresses USING btree (city);

CREATE INDEX idx_addresses_city_trgm ON public.addresses USING gin (city public.gin_trgm_ops);

CREATE INDEX idx_addresses_composite ON public.addresses USING btree (g_place_id, created_by);

CREATE INDEX idx_addresses_country ON public.addresses USING btree (country);

CREATE INDEX idx_addresses_district ON public.addresses USING btree (district);

CREATE INDEX idx_addresses_line1_trgm ON public.addresses USING gin (line1 public.gin_trgm_ops);

CREATE INDEX idx_addresses_location ON public.addresses USING gist (location);

CREATE INDEX idx_addresses_state ON public.addresses USING btree (state);

CREATE INDEX idx_cancellation_policies_property ON public.cancellation_policies USING btree (property_id);

CREATE INDEX idx_entity_rules_entity ON public.entity_rules USING btree (entity_type, entity_id);

CREATE INDEX idx_entity_rules_rule ON public.entity_rules USING btree (rule_id);

CREATE INDEX idx_experiences_host ON public.experiences USING btree (host_account_id);

CREATE INDEX idx_google_place_id ON public.property_google_data USING btree (google_place_id);

CREATE INDEX idx_google_types_gin ON public.property_google_data USING gin (types);

CREATE INDEX idx_media_assets_account ON public.media_assets USING btree (account_id);

CREATE INDEX idx_media_links_entity ON public.media_links USING btree (entity_type, entity_id);

CREATE UNIQUE INDEX idx_one_host_per_property ON public.property_members USING btree (property_id) WHERE (role = 'HOST'::text);

CREATE INDEX idx_plan_limits_plan ON public.plan_limits USING btree (plan_id);

CREATE INDEX idx_properties_account ON public.properties USING btree (account_id);

CREATE UNIQUE INDEX idx_properties_google_place_unique ON public.properties USING btree (google_place_id) WHERE (google_place_id IS NOT NULL);

CREATE INDEX idx_properties_location ON public.properties USING gist (location);

CREATE INDEX idx_properties_name ON public.properties USING btree (lower(name));

CREATE UNIQUE INDEX idx_properties_name_address_unique ON public.properties USING btree (lower(name), address_id) WHERE (google_place_id IS NULL);

CREATE INDEX idx_properties_place_types_gin ON public.properties USING gin (google_place_types);

CREATE INDEX idx_properties_search ON public.properties USING gin (to_tsvector('simple'::regconfig, ((name || ' '::text) || COALESCE(description, ''::text))));

CREATE UNIQUE INDEX idx_properties_slug_unique ON public.properties USING btree (slug);

CREATE INDEX idx_properties_status ON public.properties USING btree (status);

CREATE UNIQUE INDEX idx_property_addon_name_unique ON public.property_addons USING btree (property_id, name);

CREATE INDEX idx_property_addons_property ON public.property_addons USING btree (property_id);

CREATE UNIQUE INDEX idx_property_facility_unique ON public.property_facilities USING btree (property_id, facility_id);

CREATE UNIQUE INDEX idx_property_member_unique ON public.property_members USING btree (property_id, user_id);

CREATE INDEX idx_property_seasons_property ON public.property_seasons USING btree (property_id);

CREATE INDEX idx_property_transfers_property ON public.property_transfers USING btree (property_id);

CREATE INDEX idx_property_transport_property ON public.property_transport_hubs USING btree (property_id);

CREATE INDEX idx_property_units_property ON public.property_units USING btree (property_id);

CREATE INDEX idx_property_units_unit_type ON public.property_units USING btree (unit_type_id);

CREATE INDEX idx_property_verifications_property ON public.property_verifications USING btree (property_id);

CREATE INDEX idx_subscription_plans_active ON public.subscription_plans USING btree (is_active);

CREATE UNIQUE INDEX idx_unique_pending_claim ON public.property_claims USING btree (property_id, user_id) WHERE (status = 'PENDING'::text);

CREATE UNIQUE INDEX idx_unit_amenity_unique ON public.unit_amenities USING btree (unit_id, amenity_id);

CREATE UNIQUE INDEX idx_unit_cancellation_policy_unique ON public.unit_cancellation_policies USING btree (unit_id);

CREATE INDEX idx_unit_pricing_plans_unit ON public.unit_pricing_plans USING btree (unit_id);

CREATE INDEX idx_user_profiles_user_id ON public.user_profiles USING btree (user_id);

CREATE INDEX idx_users_email ON public.users USING btree (email);

CREATE INDEX idx_users_firebase_uid ON public.users USING btree (firebase_uid);

CREATE INDEX idx_users_phone ON public.users USING btree (phone);

CREATE UNIQUE INDEX media_assets_pkey ON public.media_assets USING btree (id);

CREATE UNIQUE INDEX media_links_pkey ON public.media_links USING btree (id);

CREATE UNIQUE INDEX one_active_payout_profile ON public.account_payout_profiles USING btree (account_id) WHERE (is_active = true);

CREATE UNIQUE INDEX one_active_subscription_per_account ON public.account_subscriptions USING btree (account_id) WHERE (status = 'ACTIVE'::text);

CREATE UNIQUE INDEX one_default_plan_per_unit ON public.unit_pricing_plans USING btree (unit_id) WHERE (is_default = true);

CREATE UNIQUE INDEX one_host_per_property ON public.property_members USING btree (property_id) WHERE (role = 'HOST'::text);

CREATE UNIQUE INDEX one_owner_per_account ON public.account_members USING btree (account_id) WHERE (role = 'OWNER'::text);

CREATE UNIQUE INDEX one_verified_doc_per_type ON public.account_kyc_documents USING btree (account_id, document_type) WHERE (verification_status = 'VERIFIED'::text);

CREATE UNIQUE INDEX plan_feature_unique ON public.plan_limits USING btree (plan_id, feature_key);

CREATE UNIQUE INDEX plan_limits_pkey ON public.plan_limits USING btree (id);

CREATE UNIQUE INDEX properties_pkey ON public.properties USING btree (id);

CREATE UNIQUE INDEX properties_slug_key ON public.properties USING btree (slug);

CREATE UNIQUE INDEX property_addons_pkey ON public.property_addons USING btree (id);

CREATE UNIQUE INDEX property_claims_pkey ON public.property_claims USING btree (id);

CREATE UNIQUE INDEX property_facilities_pkey ON public.property_facilities USING btree (id);

CREATE UNIQUE INDEX property_google_data_pkey ON public.property_google_data USING btree (id);

CREATE UNIQUE INDEX property_members_pkey ON public.property_members USING btree (id);

CREATE UNIQUE INDEX property_seasons_pkey ON public.property_seasons USING btree (id);

CREATE UNIQUE INDEX property_terrains_pkey ON public.property_terrains USING btree (id);

CREATE UNIQUE INDEX property_terrains_property_id_terrain_id_key ON public.property_terrains USING btree (property_id, terrain_id);

CREATE UNIQUE INDEX property_transfers_pkey ON public.property_transfers USING btree (id);

CREATE UNIQUE INDEX property_transport_hubs_pkey ON public.property_transport_hubs USING btree (id);

CREATE UNIQUE INDEX property_units_pkey ON public.property_units USING btree (id);

CREATE UNIQUE INDEX property_verifications_pkey ON public.property_verifications USING btree (id);

CREATE UNIQUE INDEX rule_categories_pkey ON public.rule_categories USING btree (id);

CREATE UNIQUE INDEX rule_templates_pkey ON public.rule_templates USING btree (id);

CREATE UNIQUE INDEX rules_key_key ON public.rules USING btree (key);

CREATE UNIQUE INDEX rules_pkey ON public.rules USING btree (id);

CREATE UNIQUE INDEX subscription_plans_name_key ON public.subscription_plans USING btree (name);

CREATE UNIQUE INDEX subscription_plans_pkey ON public.subscription_plans USING btree (id);

CREATE UNIQUE INDEX template_rules_pkey ON public.template_rules USING btree (id);

CREATE UNIQUE INDEX terrain_catalog_name_key ON public.terrain_catalog USING btree (name);

CREATE UNIQUE INDEX terrain_catalog_pkey ON public.terrain_catalog USING btree (id);

CREATE UNIQUE INDEX unique_partner_relationship ON public.account_partners USING btree (host_account_id, partner_account_id);

CREATE UNIQUE INDEX unique_property_season ON public.property_seasons USING btree (property_id, season);

CREATE UNIQUE INDEX unit_amenities_pkey ON public.unit_amenities USING btree (id);

CREATE UNIQUE INDEX unit_availability_exceptions_pkey ON public.unit_availability_exceptions USING btree (id);

CREATE UNIQUE INDEX unit_availability_schedules_pkey ON public.unit_availability_schedules USING btree (id);

CREATE UNIQUE INDEX unit_cancellation_policies_pkey ON public.unit_cancellation_policies USING btree (id);

CREATE UNIQUE INDEX unit_categories_key_key ON public.unit_categories USING btree (key);

CREATE UNIQUE INDEX unit_categories_pkey ON public.unit_categories USING btree (id);

CREATE UNIQUE INDEX unit_context_pkey ON public.unit_context USING btree (unit_id);

CREATE UNIQUE INDEX unit_food_options_pkey ON public.unit_food_options USING btree (id);

CREATE UNIQUE INDEX unit_pricing_components_pkey ON public.unit_pricing_components USING btree (id);

CREATE UNIQUE INDEX unit_pricing_plans_pkey ON public.unit_pricing_plans USING btree (id);

CREATE UNIQUE INDEX unit_space_configs_pkey ON public.unit_space_configs USING btree (unit_id);

CREATE UNIQUE INDEX unit_stay_configs_pkey ON public.unit_stay_configs USING btree (unit_id);

CREATE UNIQUE INDEX unit_type_catalog_key_key ON public.unit_type_catalog USING btree (key);

CREATE UNIQUE INDEX unit_type_catalog_pkey ON public.unit_type_catalog USING btree (id);

CREATE UNIQUE INDEX unit_types_key_key ON public.unit_types USING btree (key);

CREATE UNIQUE INDEX unit_types_pkey ON public.unit_types USING btree (id);

CREATE UNIQUE INDEX user_profiles_pkey ON public.user_profiles USING btree (user_id);

CREATE UNIQUE INDEX users_email_key ON public.users USING btree (email);

CREATE UNIQUE INDEX users_email_unique ON public.users USING btree (email);

CREATE UNIQUE INDEX users_firebase_uid_key ON public.users USING btree (firebase_uid);

CREATE UNIQUE INDEX users_phone_key ON public.users USING btree (phone);

CREATE UNIQUE INDEX users_phone_unique ON public.users USING btree (phone);

CREATE UNIQUE INDEX users_pkey ON public.users USING btree (id);

alter table "public"."account_audit_logs" add constraint "account_audit_logs_pkey" PRIMARY KEY using index "account_audit_logs_pkey";

alter table "public"."account_business_profiles" add constraint "account_business_profiles_pkey" PRIMARY KEY using index "account_business_profiles_pkey";

alter table "public"."account_kyc_documents" add constraint "account_kyc_documents_pkey" PRIMARY KEY using index "account_kyc_documents_pkey";

alter table "public"."account_members" add constraint "account_members_pkey" PRIMARY KEY using index "account_members_pkey";

alter table "public"."account_partners" add constraint "account_partners_pkey" PRIMARY KEY using index "account_partners_pkey";

alter table "public"."account_payout_profiles" add constraint "account_payout_profiles_pkey" PRIMARY KEY using index "account_payout_profiles_pkey";

alter table "public"."account_subscriptions" add constraint "account_subscriptions_pkey" PRIMARY KEY using index "account_subscriptions_pkey";

alter table "public"."accounts" add constraint "accounts_pkey" PRIMARY KEY using index "accounts_pkey";

alter table "public"."addresses" add constraint "addresses_pkey" PRIMARY KEY using index "addresses_pkey";

alter table "public"."amenity_catalog" add constraint "amenity_catalog_pkey" PRIMARY KEY using index "amenity_catalog_pkey";

alter table "public"."cancellation_policies" add constraint "cancellation_policies_pkey" PRIMARY KEY using index "cancellation_policies_pkey";

alter table "public"."entity_rules" add constraint "entity_rules_pkey" PRIMARY KEY using index "entity_rules_pkey";

alter table "public"."experience_properties" add constraint "experience_properties_pkey" PRIMARY KEY using index "experience_properties_pkey";

alter table "public"."experience_units" add constraint "experience_units_pkey" PRIMARY KEY using index "experience_units_pkey";

alter table "public"."experiences" add constraint "experiences_pkey" PRIMARY KEY using index "experiences_pkey";

alter table "public"."facility_catalog" add constraint "facility_catalog_pkey" PRIMARY KEY using index "facility_catalog_pkey";

alter table "public"."media_assets" add constraint "media_assets_pkey" PRIMARY KEY using index "media_assets_pkey";

alter table "public"."media_links" add constraint "media_links_pkey" PRIMARY KEY using index "media_links_pkey";

alter table "public"."plan_limits" add constraint "plan_limits_pkey" PRIMARY KEY using index "plan_limits_pkey";

alter table "public"."properties" add constraint "properties_pkey" PRIMARY KEY using index "properties_pkey";

alter table "public"."property_addons" add constraint "property_addons_pkey" PRIMARY KEY using index "property_addons_pkey";

alter table "public"."property_claims" add constraint "property_claims_pkey" PRIMARY KEY using index "property_claims_pkey";

alter table "public"."property_facilities" add constraint "property_facilities_pkey" PRIMARY KEY using index "property_facilities_pkey";

alter table "public"."property_google_data" add constraint "property_google_data_pkey" PRIMARY KEY using index "property_google_data_pkey";

alter table "public"."property_members" add constraint "property_members_pkey" PRIMARY KEY using index "property_members_pkey";

alter table "public"."property_seasons" add constraint "property_seasons_pkey" PRIMARY KEY using index "property_seasons_pkey";

alter table "public"."property_terrains" add constraint "property_terrains_pkey" PRIMARY KEY using index "property_terrains_pkey";

alter table "public"."property_transfers" add constraint "property_transfers_pkey" PRIMARY KEY using index "property_transfers_pkey";

alter table "public"."property_transport_hubs" add constraint "property_transport_hubs_pkey" PRIMARY KEY using index "property_transport_hubs_pkey";

alter table "public"."property_units" add constraint "property_units_pkey" PRIMARY KEY using index "property_units_pkey";

alter table "public"."property_verifications" add constraint "property_verifications_pkey" PRIMARY KEY using index "property_verifications_pkey";

alter table "public"."rule_categories" add constraint "rule_categories_pkey" PRIMARY KEY using index "rule_categories_pkey";

alter table "public"."rule_templates" add constraint "rule_templates_pkey" PRIMARY KEY using index "rule_templates_pkey";

alter table "public"."rules" add constraint "rules_pkey" PRIMARY KEY using index "rules_pkey";

alter table "public"."subscription_plans" add constraint "subscription_plans_pkey" PRIMARY KEY using index "subscription_plans_pkey";

alter table "public"."template_rules" add constraint "template_rules_pkey" PRIMARY KEY using index "template_rules_pkey";

alter table "public"."terrain_catalog" add constraint "terrain_catalog_pkey" PRIMARY KEY using index "terrain_catalog_pkey";

alter table "public"."unit_amenities" add constraint "unit_amenities_pkey" PRIMARY KEY using index "unit_amenities_pkey";

alter table "public"."unit_availability_exceptions" add constraint "unit_availability_exceptions_pkey" PRIMARY KEY using index "unit_availability_exceptions_pkey";

alter table "public"."unit_availability_schedules" add constraint "unit_availability_schedules_pkey" PRIMARY KEY using index "unit_availability_schedules_pkey";

alter table "public"."unit_cancellation_policies" add constraint "unit_cancellation_policies_pkey" PRIMARY KEY using index "unit_cancellation_policies_pkey";

alter table "public"."unit_categories" add constraint "unit_categories_pkey" PRIMARY KEY using index "unit_categories_pkey";

alter table "public"."unit_context" add constraint "unit_context_pkey" PRIMARY KEY using index "unit_context_pkey";

alter table "public"."unit_food_options" add constraint "unit_food_options_pkey" PRIMARY KEY using index "unit_food_options_pkey";

alter table "public"."unit_pricing_components" add constraint "unit_pricing_components_pkey" PRIMARY KEY using index "unit_pricing_components_pkey";

alter table "public"."unit_pricing_plans" add constraint "unit_pricing_plans_pkey" PRIMARY KEY using index "unit_pricing_plans_pkey";

alter table "public"."unit_space_configs" add constraint "unit_space_configs_pkey" PRIMARY KEY using index "unit_space_configs_pkey";

alter table "public"."unit_stay_configs" add constraint "unit_stay_configs_pkey" PRIMARY KEY using index "unit_stay_configs_pkey";

alter table "public"."unit_type_catalog" add constraint "unit_type_catalog_pkey" PRIMARY KEY using index "unit_type_catalog_pkey";

alter table "public"."unit_types" add constraint "unit_types_pkey" PRIMARY KEY using index "unit_types_pkey";

alter table "public"."user_profiles" add constraint "user_profiles_pkey" PRIMARY KEY using index "user_profiles_pkey";

alter table "public"."users" add constraint "users_pkey" PRIMARY KEY using index "users_pkey";

alter table "public"."account_audit_logs" add constraint "account_audit_logs_account_fkey" FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE not valid;

alter table "public"."account_audit_logs" validate constraint "account_audit_logs_account_fkey";

alter table "public"."account_audit_logs" add constraint "account_audit_logs_actor_fkey" FOREIGN KEY (actor_id) REFERENCES public.users(id) not valid;

alter table "public"."account_audit_logs" validate constraint "account_audit_logs_actor_fkey";

alter table "public"."account_business_profiles" add constraint "account_business_profiles_account_fkey" FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE not valid;

alter table "public"."account_business_profiles" validate constraint "account_business_profiles_account_fkey";

alter table "public"."account_kyc_documents" add constraint "account_kyc_documents_account_fkey" FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE not valid;

alter table "public"."account_kyc_documents" validate constraint "account_kyc_documents_account_fkey";

alter table "public"."account_kyc_documents" add constraint "account_kyc_documents_status_check" CHECK ((verification_status = ANY (ARRAY['PENDING'::text, 'VERIFIED'::text, 'REJECTED'::text]))) not valid;

alter table "public"."account_kyc_documents" validate constraint "account_kyc_documents_status_check";

alter table "public"."account_kyc_documents" add constraint "account_kyc_documents_verified_by_fkey" FOREIGN KEY (verified_by) REFERENCES public.users(id) not valid;

alter table "public"."account_kyc_documents" validate constraint "account_kyc_documents_verified_by_fkey";

alter table "public"."account_members" add constraint "account_members_account_id_fkey" FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE not valid;

alter table "public"."account_members" validate constraint "account_members_account_id_fkey";

alter table "public"."account_members" add constraint "account_members_role_check" CHECK ((role = ANY (ARRAY['OWNER'::text, 'MEMBER'::text]))) not valid;

alter table "public"."account_members" validate constraint "account_members_role_check";

alter table "public"."account_members" add constraint "account_members_status_check" CHECK ((status = ANY (ARRAY['INVITED'::text, 'ACTIVE'::text, 'SUSPENDED'::text]))) not valid;

alter table "public"."account_members" validate constraint "account_members_status_check";

alter table "public"."account_members" add constraint "account_members_unique" UNIQUE using index "account_members_unique";

alter table "public"."account_members" add constraint "account_members_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE not valid;

alter table "public"."account_members" validate constraint "account_members_user_id_fkey";

alter table "public"."account_partners" add constraint "account_partners_host_fkey" FOREIGN KEY (host_account_id) REFERENCES public.accounts(id) ON DELETE CASCADE not valid;

alter table "public"."account_partners" validate constraint "account_partners_host_fkey";

alter table "public"."account_partners" add constraint "account_partners_not_self" CHECK ((host_account_id <> partner_account_id)) not valid;

alter table "public"."account_partners" validate constraint "account_partners_not_self";

alter table "public"."account_partners" add constraint "account_partners_partner_fkey" FOREIGN KEY (partner_account_id) REFERENCES public.accounts(id) ON DELETE CASCADE not valid;

alter table "public"."account_partners" validate constraint "account_partners_partner_fkey";

alter table "public"."account_partners" add constraint "account_partners_status_check" CHECK ((status = ANY (ARRAY['ACTIVE'::text, 'SUSPENDED'::text, 'TERMINATED'::text]))) not valid;

alter table "public"."account_partners" validate constraint "account_partners_status_check";

alter table "public"."account_payout_profiles" add constraint "account_payout_profiles_account_fkey" FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE not valid;

alter table "public"."account_payout_profiles" validate constraint "account_payout_profiles_account_fkey";

alter table "public"."account_payout_profiles" add constraint "account_payout_profiles_status_check" CHECK ((verification_status = ANY (ARRAY['PENDING'::text, 'VERIFIED'::text, 'REJECTED'::text]))) not valid;

alter table "public"."account_payout_profiles" validate constraint "account_payout_profiles_status_check";

alter table "public"."account_subscriptions" add constraint "account_subscriptions_account_id_fkey" FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE not valid;

alter table "public"."account_subscriptions" validate constraint "account_subscriptions_account_id_fkey";

alter table "public"."account_subscriptions" add constraint "account_subscriptions_billing_cycle_check" CHECK ((billing_cycle = ANY (ARRAY['MONTHLY'::text, 'YEARLY'::text]))) not valid;

alter table "public"."account_subscriptions" validate constraint "account_subscriptions_billing_cycle_check";

alter table "public"."account_subscriptions" add constraint "account_subscriptions_plan_id_fkey" FOREIGN KEY (plan_id) REFERENCES public.subscription_plans(id) not valid;

alter table "public"."account_subscriptions" validate constraint "account_subscriptions_plan_id_fkey";

alter table "public"."account_subscriptions" add constraint "account_subscriptions_status_check" CHECK ((status = ANY (ARRAY['ACTIVE'::text, 'PAST_DUE'::text, 'CANCELLED'::text, 'EXPIRED'::text]))) not valid;

alter table "public"."account_subscriptions" validate constraint "account_subscriptions_status_check";

alter table "public"."accounts" add constraint "accounts_slug_format" CHECK ((slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'::text)) not valid;

alter table "public"."accounts" validate constraint "accounts_slug_format";

alter table "public"."accounts" add constraint "accounts_slug_key" UNIQUE using index "accounts_slug_key";

alter table "public"."accounts" add constraint "accounts_status_check" CHECK ((status = ANY (ARRAY['PENDING_COMPLIENCE'::text, 'ACTIVE'::text, 'SUSPENDED'::text, 'CLOSED'::text]))) not valid;

alter table "public"."accounts" validate constraint "accounts_status_check";

alter table "public"."accounts" add constraint "accounts_type_check" CHECK ((type = ANY (ARRAY['INDIVIDUAL'::text, 'BUSINESS'::text, 'AGENCY'::text]))) not valid;

alter table "public"."accounts" validate constraint "accounts_type_check";

alter table "public"."addresses" add constraint "addresses_created_by_fkey" FOREIGN KEY (created_by) REFERENCES public.users(id) not valid;

alter table "public"."addresses" validate constraint "addresses_created_by_fkey";

alter table "public"."amenity_catalog" add constraint "amenity_catalog_key_key" UNIQUE using index "amenity_catalog_key_key";

alter table "public"."cancellation_policies" add constraint "cancellation_policies_policy_type_check" CHECK ((policy_type = ANY (ARRAY['FLEXI'::text, 'MODERATE'::text, 'STRICT'::text, 'CUSTOM'::text]))) not valid;

alter table "public"."cancellation_policies" validate constraint "cancellation_policies_policy_type_check";

alter table "public"."cancellation_policies" add constraint "cancellation_policies_property_id_fkey" FOREIGN KEY (property_id) REFERENCES public.properties(id) ON DELETE CASCADE not valid;

alter table "public"."cancellation_policies" validate constraint "cancellation_policies_property_id_fkey";

alter table "public"."entity_rules" add constraint "check_entity_type" CHECK ((entity_type = ANY (ARRAY['PROPERTY'::text, 'UNIT'::text, 'EXPERIENCE'::text]))) not valid;

alter table "public"."entity_rules" validate constraint "check_entity_type";

alter table "public"."entity_rules" add constraint "fk_entity_rule_rule" FOREIGN KEY (rule_id) REFERENCES public.rules(id) not valid;

alter table "public"."entity_rules" validate constraint "fk_entity_rule_rule";

alter table "public"."experience_properties" add constraint "fk_exp_prop_exp" FOREIGN KEY (experience_id) REFERENCES public.experiences(id) ON DELETE CASCADE not valid;

alter table "public"."experience_properties" validate constraint "fk_exp_prop_exp";

alter table "public"."experience_properties" add constraint "fk_exp_prop_property" FOREIGN KEY (property_id) REFERENCES public.properties(id) ON DELETE CASCADE not valid;

alter table "public"."experience_properties" validate constraint "fk_exp_prop_property";

alter table "public"."experience_units" add constraint "check_experience_unit_role" CHECK ((role = ANY (ARRAY['VENUE'::text, 'STAY'::text, 'SUPPORT'::text]))) not valid;

alter table "public"."experience_units" validate constraint "check_experience_unit_role";

alter table "public"."experience_units" add constraint "fk_exp_unit_exp" FOREIGN KEY (experience_id) REFERENCES public.experiences(id) ON DELETE CASCADE not valid;

alter table "public"."experience_units" validate constraint "fk_exp_unit_exp";

alter table "public"."experience_units" add constraint "fk_exp_unit_unit" FOREIGN KEY (unit_id) REFERENCES public.property_units(id) ON DELETE CASCADE not valid;

alter table "public"."experience_units" validate constraint "fk_exp_unit_unit";

alter table "public"."experiences" add constraint "fk_experience_host" FOREIGN KEY (host_account_id) REFERENCES public.accounts(id) not valid;

alter table "public"."experiences" validate constraint "fk_experience_host";

alter table "public"."facility_catalog" add constraint "facility_catalog_key_key" UNIQUE using index "facility_catalog_key_key";

alter table "public"."media_assets" add constraint "media_assets_account_id_fkey" FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE not valid;

alter table "public"."media_assets" validate constraint "media_assets_account_id_fkey";

alter table "public"."media_assets" add constraint "media_assets_media_type_check" CHECK ((media_type = ANY (ARRAY['IMAGE'::text, 'VIDEO'::text, 'DOCUMENT'::text]))) not valid;

alter table "public"."media_assets" validate constraint "media_assets_media_type_check";

alter table "public"."media_links" add constraint "media_links_entity_type_check" CHECK ((entity_type = ANY (ARRAY['PROPERTY'::text, 'UNIT'::text, 'ADDON'::text, 'EXPERIENCE'::text, 'FACILITY'::text]))) not valid;

alter table "public"."media_links" validate constraint "media_links_entity_type_check";

alter table "public"."media_links" add constraint "media_links_media_id_fkey" FOREIGN KEY (media_id) REFERENCES public.media_assets(id) ON DELETE CASCADE not valid;

alter table "public"."media_links" validate constraint "media_links_media_id_fkey";

alter table "public"."plan_limits" add constraint "plan_limits_plan_id_fkey" FOREIGN KEY (plan_id) REFERENCES public.subscription_plans(id) ON DELETE CASCADE not valid;

alter table "public"."plan_limits" validate constraint "plan_limits_plan_id_fkey";

alter table "public"."properties" add constraint "properties_account_id_fkey" FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE not valid;

alter table "public"."properties" validate constraint "properties_account_id_fkey";

alter table "public"."properties" add constraint "properties_address_id_fkey" FOREIGN KEY (address_id) REFERENCES public.addresses(id) not valid;

alter table "public"."properties" validate constraint "properties_address_id_fkey";

alter table "public"."properties" add constraint "properties_canonical_fkey" FOREIGN KEY (canonical_property_id) REFERENCES public.properties(id) not valid;

alter table "public"."properties" validate constraint "properties_canonical_fkey";

alter table "public"."properties" add constraint "properties_created_by_fkey" FOREIGN KEY (created_by) REFERENCES public.users(id) not valid;

alter table "public"."properties" validate constraint "properties_created_by_fkey";

alter table "public"."properties" add constraint "properties_creation_step_check" CHECK (((creation_step >= 0) AND (creation_step <= 6))) not valid;

alter table "public"."properties" validate constraint "properties_creation_step_check";

alter table "public"."properties" add constraint "properties_listing_source_check" CHECK ((listing_source = ANY (ARRAY['HOST'::text, 'PARTNER'::text, 'ADMIN'::text]))) not valid;

alter table "public"."properties" validate constraint "properties_listing_source_check";

alter table "public"."properties" add constraint "properties_ownership_status_check" CHECK ((ownership_status = ANY (ARRAY['OWNED'::text, 'CLAIM_REQUESTED'::text, 'UNVERIFIED'::text]))) not valid;

alter table "public"."properties" validate constraint "properties_ownership_status_check";

alter table "public"."properties" add constraint "properties_slug_format" CHECK ((slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'::text)) not valid;

alter table "public"."properties" validate constraint "properties_slug_format";

alter table "public"."properties" add constraint "properties_slug_key" UNIQUE using index "properties_slug_key";

alter table "public"."properties" add constraint "properties_status_check" CHECK ((status = ANY (ARRAY['DRAFT'::text, 'VERIFICATION_PENDING'::text, 'PUBLISHED'::text, 'SUSPENDED'::text, 'DELETED'::text]))) not valid;

alter table "public"."properties" validate constraint "properties_status_check";

alter table "public"."property_addons" add constraint "property_addons_addon_type_check" CHECK ((addon_type = ANY (ARRAY['SERVICE'::text, 'EQUIPMENT'::text, 'TRANSPORT'::text]))) not valid;

alter table "public"."property_addons" validate constraint "property_addons_addon_type_check";

alter table "public"."property_addons" add constraint "property_addons_pricing_type_check" CHECK ((pricing_type = ANY (ARRAY['PER_PERSON'::text, 'PER_UNIT'::text, 'QUANTITY'::text]))) not valid;

alter table "public"."property_addons" validate constraint "property_addons_pricing_type_check";

alter table "public"."property_addons" add constraint "property_addons_property_id_fkey" FOREIGN KEY (property_id) REFERENCES public.properties(id) ON DELETE CASCADE not valid;

alter table "public"."property_addons" validate constraint "property_addons_property_id_fkey";

alter table "public"."property_addons" add constraint "property_addons_status_check" CHECK ((status = ANY (ARRAY['DRAFT'::text, 'PUBLISHED'::text, 'SUSPENDED'::text]))) not valid;

alter table "public"."property_addons" validate constraint "property_addons_status_check";

alter table "public"."property_claims" add constraint "property_claims_property_id_fkey" FOREIGN KEY (property_id) REFERENCES public.properties(id) not valid;

alter table "public"."property_claims" validate constraint "property_claims_property_id_fkey";

alter table "public"."property_claims" add constraint "property_claims_status_check" CHECK ((status = ANY (ARRAY['PENDING'::text, 'APPROVED'::text, 'REJECTED'::text]))) not valid;

alter table "public"."property_claims" validate constraint "property_claims_status_check";

alter table "public"."property_facilities" add constraint "property_facilities_facility_id_fkey" FOREIGN KEY (facility_id) REFERENCES public.facility_catalog(id) not valid;

alter table "public"."property_facilities" validate constraint "property_facilities_facility_id_fkey";

alter table "public"."property_facilities" add constraint "property_facilities_property_id_fkey" FOREIGN KEY (property_id) REFERENCES public.properties(id) ON DELETE CASCADE not valid;

alter table "public"."property_facilities" validate constraint "property_facilities_property_id_fkey";

alter table "public"."property_google_data" add constraint "property_google_data_property_id_fkey" FOREIGN KEY (property_id) REFERENCES public.properties(id) ON DELETE CASCADE not valid;

alter table "public"."property_google_data" validate constraint "property_google_data_property_id_fkey";

alter table "public"."property_members" add constraint "property_members_property_id_fkey" FOREIGN KEY (property_id) REFERENCES public.properties(id) ON DELETE CASCADE not valid;

alter table "public"."property_members" validate constraint "property_members_property_id_fkey";

alter table "public"."property_members" add constraint "property_members_role_check" CHECK ((role = ANY (ARRAY['HOST'::text, 'CO_HOST'::text, 'STEWARD'::text]))) not valid;

alter table "public"."property_members" validate constraint "property_members_role_check";

alter table "public"."property_members" add constraint "property_members_status_check" CHECK ((status = ANY (ARRAY['INVITED'::text, 'ACTIVE'::text, 'SUSPENDED'::text]))) not valid;

alter table "public"."property_members" validate constraint "property_members_status_check";

alter table "public"."property_members" add constraint "property_members_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE not valid;

alter table "public"."property_members" validate constraint "property_members_user_id_fkey";

alter table "public"."property_seasons" add constraint "property_seasons_property_id_fkey" FOREIGN KEY (property_id) REFERENCES public.properties(id) ON DELETE CASCADE not valid;

alter table "public"."property_seasons" validate constraint "property_seasons_property_id_fkey";

alter table "public"."property_seasons" add constraint "unique_property_season" UNIQUE using index "unique_property_season";

alter table "public"."property_terrains" add constraint "property_terrains_property_id_fkey" FOREIGN KEY (property_id) REFERENCES public.properties(id) ON DELETE CASCADE not valid;

alter table "public"."property_terrains" validate constraint "property_terrains_property_id_fkey";

alter table "public"."property_terrains" add constraint "property_terrains_property_id_terrain_id_key" UNIQUE using index "property_terrains_property_id_terrain_id_key";

alter table "public"."property_terrains" add constraint "property_terrains_terrain_id_fkey" FOREIGN KEY (terrain_id) REFERENCES public.terrain_catalog(id) not valid;

alter table "public"."property_terrains" validate constraint "property_terrains_terrain_id_fkey";

alter table "public"."property_transfers" add constraint "property_transfers_accepted_by_fkey" FOREIGN KEY (accepted_by) REFERENCES public.users(id) not valid;

alter table "public"."property_transfers" validate constraint "property_transfers_accepted_by_fkey";

alter table "public"."property_transfers" add constraint "property_transfers_from_account_id_fkey" FOREIGN KEY (from_account_id) REFERENCES public.accounts(id) not valid;

alter table "public"."property_transfers" validate constraint "property_transfers_from_account_id_fkey";

alter table "public"."property_transfers" add constraint "property_transfers_initiated_by_fkey" FOREIGN KEY (initiated_by) REFERENCES public.users(id) not valid;

alter table "public"."property_transfers" validate constraint "property_transfers_initiated_by_fkey";

alter table "public"."property_transfers" add constraint "property_transfers_property_id_fkey" FOREIGN KEY (property_id) REFERENCES public.properties(id) ON DELETE CASCADE not valid;

alter table "public"."property_transfers" validate constraint "property_transfers_property_id_fkey";

alter table "public"."property_transfers" add constraint "property_transfers_status_check" CHECK ((status = ANY (ARRAY['INITIATED'::text, 'APPROVED'::text, 'COMPLETED'::text, 'CANCELLED'::text]))) not valid;

alter table "public"."property_transfers" validate constraint "property_transfers_status_check";

alter table "public"."property_transfers" add constraint "property_transfers_to_account_id_fkey" FOREIGN KEY (to_account_id) REFERENCES public.accounts(id) not valid;

alter table "public"."property_transfers" validate constraint "property_transfers_to_account_id_fkey";

alter table "public"."property_transport_hubs" add constraint "property_transport_hubs_hub_type_check" CHECK ((hub_type = ANY (ARRAY['AIRPORT'::text, 'RAILWAY_STATION'::text, 'BUS_STATION'::text, 'PORT'::text, 'TAXI_STAND'::text]))) not valid;

alter table "public"."property_transport_hubs" validate constraint "property_transport_hubs_hub_type_check";

alter table "public"."property_transport_hubs" add constraint "property_transport_hubs_property_id_fkey" FOREIGN KEY (property_id) REFERENCES public.properties(id) ON DELETE CASCADE not valid;

alter table "public"."property_transport_hubs" validate constraint "property_transport_hubs_property_id_fkey";

alter table "public"."property_units" add constraint "check_unit_type_valid" CHECK ((unit_type_id IS NOT NULL)) not valid;

alter table "public"."property_units" validate constraint "check_unit_type_valid";

alter table "public"."property_units" add constraint "property_units_property_id_fkey" FOREIGN KEY (property_id) REFERENCES public.properties(id) ON DELETE CASCADE not valid;

alter table "public"."property_units" validate constraint "property_units_property_id_fkey";

alter table "public"."property_units" add constraint "property_units_status_check" CHECK ((status = ANY (ARRAY['ACTIVE'::text, 'INACTIVE'::text]))) not valid;

alter table "public"."property_units" validate constraint "property_units_status_check";

alter table "public"."property_units" add constraint "property_units_unit_type_fkey" FOREIGN KEY (unit_type_id) REFERENCES public.unit_types(id) not valid;

alter table "public"."property_units" validate constraint "property_units_unit_type_fkey";

alter table "public"."property_verifications" add constraint "property_verifications_property_id_fkey" FOREIGN KEY (property_id) REFERENCES public.properties(id) ON DELETE CASCADE not valid;

alter table "public"."property_verifications" validate constraint "property_verifications_property_id_fkey";

alter table "public"."property_verifications" add constraint "property_verifications_verification_status_check" CHECK ((verification_status = ANY (ARRAY['PENDING'::text, 'APPROVED'::text, 'REJECTED'::text]))) not valid;

alter table "public"."property_verifications" validate constraint "property_verifications_verification_status_check";

alter table "public"."property_verifications" add constraint "property_verifications_verified_by_fkey" FOREIGN KEY (verified_by) REFERENCES public.users(id) not valid;

alter table "public"."property_verifications" validate constraint "property_verifications_verified_by_fkey";

alter table "public"."rules" add constraint "fk_rule_category" FOREIGN KEY (category_id) REFERENCES public.rule_categories(id) not valid;

alter table "public"."rules" validate constraint "fk_rule_category";

alter table "public"."rules" add constraint "rules_key_key" UNIQUE using index "rules_key_key";

alter table "public"."subscription_plans" add constraint "subscription_plans_name_key" UNIQUE using index "subscription_plans_name_key";

alter table "public"."template_rules" add constraint "fk_template" FOREIGN KEY (template_id) REFERENCES public.rule_templates(id) ON DELETE CASCADE not valid;

alter table "public"."template_rules" validate constraint "fk_template";

alter table "public"."template_rules" add constraint "fk_template_rule" FOREIGN KEY (rule_id) REFERENCES public.rules(id) ON DELETE CASCADE not valid;

alter table "public"."template_rules" validate constraint "fk_template_rule";

alter table "public"."terrain_catalog" add constraint "terrain_catalog_name_key" UNIQUE using index "terrain_catalog_name_key";

alter table "public"."unit_amenities" add constraint "unit_amenities_amenity_id_fkey" FOREIGN KEY (amenity_id) REFERENCES public.amenity_catalog(id) not valid;

alter table "public"."unit_amenities" validate constraint "unit_amenities_amenity_id_fkey";

alter table "public"."unit_amenities" add constraint "unit_amenities_unit_id_fkey" FOREIGN KEY (unit_id) REFERENCES public.property_units(id) ON DELETE CASCADE not valid;

alter table "public"."unit_amenities" validate constraint "unit_amenities_unit_id_fkey";

alter table "public"."unit_availability_exceptions" add constraint "unit_availability_exceptions_unit_id_fkey" FOREIGN KEY (unit_id) REFERENCES public.property_units(id) not valid;

alter table "public"."unit_availability_exceptions" validate constraint "unit_availability_exceptions_unit_id_fkey";

alter table "public"."unit_availability_schedules" add constraint "unit_availability_schedules_day_of_week_check" CHECK (((day_of_week >= 0) AND (day_of_week <= 6))) not valid;

alter table "public"."unit_availability_schedules" validate constraint "unit_availability_schedules_day_of_week_check";

alter table "public"."unit_availability_schedules" add constraint "unit_availability_schedules_unit_fkey" FOREIGN KEY (unit_id) REFERENCES public.property_units(id) not valid;

alter table "public"."unit_availability_schedules" validate constraint "unit_availability_schedules_unit_fkey";

alter table "public"."unit_cancellation_policies" add constraint "unit_cancellation_policies_policy_id_fkey" FOREIGN KEY (policy_id) REFERENCES public.cancellation_policies(id) ON DELETE CASCADE not valid;

alter table "public"."unit_cancellation_policies" validate constraint "unit_cancellation_policies_policy_id_fkey";

alter table "public"."unit_cancellation_policies" add constraint "unit_cancellation_policies_unit_id_fkey" FOREIGN KEY (unit_id) REFERENCES public.property_units(id) ON DELETE CASCADE not valid;

alter table "public"."unit_cancellation_policies" validate constraint "unit_cancellation_policies_unit_id_fkey";

alter table "public"."unit_categories" add constraint "unit_categories_key_key" UNIQUE using index "unit_categories_key_key";

alter table "public"."unit_context" add constraint "unit_context_access_model_check" CHECK ((access_model = ANY (ARRAY['bookable'::text, 'ticketed'::text, 'open_access'::text]))) not valid;

alter table "public"."unit_context" validate constraint "unit_context_access_model_check";

alter table "public"."unit_context" add constraint "unit_context_availability_model_check" CHECK ((availability_model = ANY (ARRAY['always_open'::text, 'time_slot'::text, 'scheduled'::text]))) not valid;

alter table "public"."unit_context" validate constraint "unit_context_availability_model_check";

alter table "public"."unit_context" add constraint "unit_context_bathroom_distribution_check" CHECK ((bathroom_distribution = ANY (ARRAY['none'::text, 'single_private'::text, 'multiple_private'::text, 'shared_block'::text, 'external_basic'::text]))) not valid;

alter table "public"."unit_context" validate constraint "unit_context_bathroom_distribution_check";

alter table "public"."unit_context" add constraint "unit_context_experience_type_check" CHECK ((experience_type = ANY (ARRAY['standard'::text, 'homely'::text, 'experiential'::text, 'raw'::text]))) not valid;

alter table "public"."unit_context" validate constraint "unit_context_experience_type_check";

alter table "public"."unit_context" add constraint "unit_context_kitchen_model_check" CHECK ((kitchen_model = ANY (ARRAY['none'::text, 'private'::text, 'shared'::text]))) not valid;

alter table "public"."unit_context" validate constraint "unit_context_kitchen_model_check";

alter table "public"."unit_context" add constraint "unit_context_primary_intent_check" CHECK ((primary_intent = ANY (ARRAY['stay'::text, 'event'::text, 'food'::text, 'work'::text, 'experience'::text]))) not valid;

alter table "public"."unit_context" validate constraint "unit_context_primary_intent_check";

alter table "public"."unit_context" add constraint "unit_context_privacy_model_check" CHECK ((privacy_model = ANY (ARRAY['private'::text, 'semi_private'::text, 'shared'::text, 'open'::text]))) not valid;

alter table "public"."unit_context" validate constraint "unit_context_privacy_model_check";

alter table "public"."unit_context" add constraint "unit_context_sleep_distribution_check" CHECK ((sleep_distribution = ANY (ARRAY['none'::text, 'single_point'::text, 'multi_point'::text, 'shared_pool'::text]))) not valid;

alter table "public"."unit_context" validate constraint "unit_context_sleep_distribution_check";

alter table "public"."unit_context" add constraint "unit_context_space_shape_check" CHECK ((space_shape = ANY (ARRAY['atomic'::text, 'segmented'::text, 'distributed'::text, 'open'::text]))) not valid;

alter table "public"."unit_context" validate constraint "unit_context_space_shape_check";

alter table "public"."unit_context" add constraint "unit_context_unit_id_fkey" FOREIGN KEY (unit_id) REFERENCES public.property_units(id) ON DELETE CASCADE not valid;

alter table "public"."unit_context" validate constraint "unit_context_unit_id_fkey";

alter table "public"."unit_context" add constraint "unit_context_usage_mode_check" CHECK ((usage_mode = ANY (ARRAY['overnight'::text, 'hourly'::text, 'full_day'::text, 'multi_day'::text]))) not valid;

alter table "public"."unit_context" validate constraint "unit_context_usage_mode_check";

alter table "public"."unit_food_options" add constraint "unit_food_options_unit_id_fkey" FOREIGN KEY (unit_id) REFERENCES public.property_units(id) ON DELETE CASCADE not valid;

alter table "public"."unit_food_options" validate constraint "unit_food_options_unit_id_fkey";

alter table "public"."unit_pricing_components" add constraint "check_component_type" CHECK ((component_type = ANY (ARRAY['BASE'::text, 'EXTRA_GUEST'::text, 'ADULT'::text, 'CHILD'::text, 'SLOT'::text, 'LONG_STAY_DISCOUNT'::text]))) not valid;

alter table "public"."unit_pricing_components" validate constraint "check_component_type";

alter table "public"."unit_pricing_components" add constraint "fk_pricing_plan" FOREIGN KEY (pricing_plan_id) REFERENCES public.unit_pricing_plans(id) ON DELETE CASCADE not valid;

alter table "public"."unit_pricing_components" validate constraint "fk_pricing_plan";

alter table "public"."unit_pricing_plans" add constraint "unit_pricing_plans_pricing_model_check" CHECK ((pricing_model = ANY (ARRAY['PER_NIGHT'::text, 'PER_PERSON'::text, 'PER_EVENT'::text, 'PER_HOUR'::text, 'HALF_DAY'::text, 'FULL_DAY'::text]))) not valid;

alter table "public"."unit_pricing_plans" validate constraint "unit_pricing_plans_pricing_model_check";

alter table "public"."unit_pricing_plans" add constraint "unit_pricing_plans_unit_id_fkey" FOREIGN KEY (unit_id) REFERENCES public.property_units(id) ON DELETE CASCADE not valid;

alter table "public"."unit_pricing_plans" validate constraint "unit_pricing_plans_unit_id_fkey";

alter table "public"."unit_space_configs" add constraint "fk_unit_space" FOREIGN KEY (unit_id) REFERENCES public.property_units(id) ON DELETE CASCADE not valid;

alter table "public"."unit_space_configs" validate constraint "fk_unit_space";

alter table "public"."unit_stay_configs" add constraint "fk_unit_stay" FOREIGN KEY (unit_id) REFERENCES public.property_units(id) ON DELETE CASCADE not valid;

alter table "public"."unit_stay_configs" validate constraint "fk_unit_stay";

alter table "public"."unit_type_catalog" add constraint "unit_type_booking_mode_check" CHECK ((booking_mode = ANY (ARRAY['PER_NIGHT'::text, 'PER_PERSON'::text, 'PER_EVENT'::text, 'PER_HOUR'::text, 'HALF_DAY'::text, 'FULL_DAY'::text]))) not valid;

alter table "public"."unit_type_catalog" validate constraint "unit_type_booking_mode_check";

alter table "public"."unit_type_catalog" add constraint "unit_type_catalog_category_id_fkey" FOREIGN KEY (category_id) REFERENCES public.unit_categories(id) ON DELETE CASCADE not valid;

alter table "public"."unit_type_catalog" validate constraint "unit_type_catalog_category_id_fkey";

alter table "public"."unit_type_catalog" add constraint "unit_type_catalog_key_key" UNIQUE using index "unit_type_catalog_key_key";

alter table "public"."unit_types" add constraint "unit_types_key_key" UNIQUE using index "unit_types_key_key";

alter table "public"."user_profiles" add constraint "user_profiles_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE not valid;

alter table "public"."user_profiles" validate constraint "user_profiles_user_id_fkey";

alter table "public"."users" add constraint "users_email_format_check" CHECK ((POSITION(('@'::text) IN (email)) > 1)) not valid;

alter table "public"."users" validate constraint "users_email_format_check";

alter table "public"."users" add constraint "users_email_key" UNIQUE using index "users_email_key";

alter table "public"."users" add constraint "users_email_unique" UNIQUE using index "users_email_unique";

alter table "public"."users" add constraint "users_firebase_uid_key" UNIQUE using index "users_firebase_uid_key";

alter table "public"."users" add constraint "users_phone_key" UNIQUE using index "users_phone_key";

alter table "public"."users" add constraint "users_phone_unique" UNIQUE using index "users_phone_unique";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.account_created_trigger()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
  perform log_account_event(
    new.id,
    'ACCOUNT_CREATED',
    auth.uid(),
    jsonb_build_object(
      'account_name', new.name,
      'account_type', new.type
    )
  );

  return new;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.activate_account_if_compliant(p_account_id uuid)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
begin

  if check_account_compliance(p_account_id) then
    update accounts
    set status = 'ACTIVE'
    where id = p_account_id
    and status = 'PENDING_COMPLIENCE';
  end if;

end;
$function$
;

CREATE OR REPLACE FUNCTION public.assign_default_subscription()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$begin

  insert into account_subscriptions (
    account_id,
    plan_id,
    billing_cycle,
    status,
    started_at
  )
  values (
    new.id,
    '174d187d-a071-462b-bb4a-5be1791026c4',
    'MONTHLY',
    'ACTIVE',
    now()
  );

  return new;

end;$function$
;

CREATE OR REPLACE FUNCTION public.audit_account_created()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
  perform log_account_event(
    new.id,
    'ACCOUNT_CREATED',
    null,
    jsonb_build_object(
      'account_name', new.name,
      'account_type', new.type
    )
  );

  return new;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.audit_trigger_function()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
  insert into account_audit_logs(
    action,
    table_name,
    record_id,
    changed_by,
    metadata
  )
  values (
    TG_OP,
    TG_TABLE_NAME,
    NEW.id,
    auth.uid(),
    row_to_json(NEW)
  );

  return NEW;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.check_account_compliance(p_account_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
declare
  business_exists boolean;
  verified_docs integer;
  payout_verified boolean;
begin

  -- business profile exists
  select exists (
    select 1
    from account_business_profiles
    where account_id = p_account_id
  ) into business_exists;

  -- verified KYC documents
  select count(*)
  from account_kyc_documents
  where account_id = p_account_id
  and verification_status = 'VERIFIED'
  into verified_docs;

  -- payout account verified
  select exists (
    select 1
    from account_payout_profiles
    where account_id = p_account_id
    and verification_status = 'VERIFIED'
  ) into payout_verified;

  if business_exists and verified_docs > 0 and payout_verified then
    return true;
  end if;

  return false;

end;
$function$
;

CREATE OR REPLACE FUNCTION public.check_duplicate_property(lat numeric, lng numeric, radius_meters integer)
 RETURNS TABLE(id uuid, name text, slug text, distance_meters numeric)
 LANGUAGE sql
AS $function$
SELECT
  id,
  name,
  slug,
  ST_Distance(
    location,
    ST_SetSRID(ST_MakePoint(lng, lat),4326)::geography
  ) AS distance_meters
FROM properties
WHERE ST_DWithin(
  location,
  ST_SetSRID(ST_MakePoint(lng, lat),4326)::geography,
  radius_meters
);
$function$
;

CREATE OR REPLACE FUNCTION public.claim_property(p_property_id uuid, p_user_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  v_has_owner boolean;
BEGIN

  -- Check if property already has a HOST
  SELECT EXISTS (
    SELECT 1 FROM public.property_members
    WHERE property_id = p_property_id
      AND role = 'HOST'
      AND status = 'ACTIVE'
  ) INTO v_has_owner;

  IF v_has_owner THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Property already has an owner'
    );
  END IF;

  -- Assign HOST
  INSERT INTO public.property_members (
    property_id,
    user_id,
    role,
    status
  )
  VALUES (
    p_property_id,
    p_user_id,
    'HOST',
    'ACTIVE'
  );

  RETURN jsonb_build_object(
    'success', true,
    'message', 'You are now the owner'
  );

END;
$function$
;

CREATE OR REPLACE FUNCTION public.create_default_subscription()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$begin
  insert into account_subscriptions (
    account_id,
    plan_id,
    status
  )
  values (
    new.id,
    (
      select id
      from subscription_plans
      where name = 'Free'
      limit 1
    ),
    'ACTIVE'
  );

  return new;
end;$function$
;

CREATE OR REPLACE FUNCTION public.create_or_get_property(payload jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$DECLARE
  -- Inputs
  p_name text := payload->>'name';
  p_account_id uuid := (payload->>'account_id')::uuid;
  p_user_id uuid := (payload->>'user_id')::uuid;
  p_description text := payload->>'description';
  p_listing_source text := COALESCE(payload->>'listing_source', 'HOST');

  -- Address
  p_line1 text := payload#>>'{address,line1}';
  p_line2 text := payload#>>'{address,line2}';
  p_city text := payload#>>'{address,city}';
  p_state text := payload#>>'{address,state}';
  p_country text := payload#>>'{address,country}';
  p_postal_code text := payload#>>'{address,postal_code}';
  p_lat numeric := (payload#>>'{address,lat}')::numeric;
  p_lng numeric := (payload#>>'{address,lng}')::numeric;
  p_locality text := payload#>>'{address,locality}';
  p_district text := payload#>>'{address,district}';
  p_label text := payload#>>'{address,label}';

  -- Google
  p_google_place_id text := payload#>>'{google,place_id}';
  p_google_types text[] := 
    CASE 
      WHEN jsonb_typeof(payload#>'{google,types}') = 'array'
      THEN ARRAY(
        SELECT jsonb_array_elements_text(payload#>'{google,types}')
      )
      ELSE ARRAY[]::text[]
    END;
  p_google_rating numeric := (payload#>>'{google,rating}')::numeric;
  p_google_user_ratings_total int := (payload#>>'{google,user_ratings_total}')::int;
  p_google_formatted_address text := payload#>>'{google,formatted_address}';

  -- Metadata
  p_metadata jsonb := payload->'metadata';

  -- Internal
  v_property_id uuid;
  v_address_id uuid;
  v_slug text;
  v_existing_property uuid;
  v_existing_role text;
  v_has_owner boolean;

BEGIN

  ------------------------------------------------------------------
  -- 🔐 Validate user belongs to account
  ------------------------------------------------------------------
  IF NOT EXISTS (
    SELECT 1 FROM public.account_members
    WHERE account_id = p_account_id
      AND user_id = p_user_id
      AND status = 'ACTIVE'
  ) THEN
    RAISE EXCEPTION 'User is not part of the account';
  END IF;

  ------------------------------------------------------------------
  -- 🔍 Step 1: Exact Google match
  ------------------------------------------------------------------
  IF p_google_place_id IS NOT NULL THEN
    SELECT id INTO v_existing_property
    FROM public.properties
    WHERE google_place_id = p_google_place_id
    LIMIT 1;
  END IF;

  ------------------------------------------------------------------
  -- 🔍 Step 2: Fallback match (name + geo)
  ------------------------------------------------------------------
  IF v_existing_property IS NULL AND p_lat IS NOT NULL AND p_lng IS NOT NULL THEN
    SELECT id INTO v_existing_property
    FROM public.properties
    WHERE LOWER(name) = LOWER(p_name)
    AND ST_DWithin(
      location,
      ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography,
      50
    )
    LIMIT 1;
  END IF;

  ------------------------------------------------------------------
  -- 🧠 EXISTING PROPERTY FLOW (DETECTION ONLY)
  ------------------------------------------------------------------
  IF v_existing_property IS NOT NULL THEN
    v_property_id := v_existing_property;

    -- Check membership
    SELECT role INTO v_existing_role
    FROM public.property_members
    WHERE property_id = v_property_id
      AND user_id = p_user_id
      AND status = 'ACTIVE'
    LIMIT 1;

    -- Already member
    IF v_existing_role IS NOT NULL THEN
      RETURN jsonb_build_object(
        'property_id', v_property_id,
        'is_new', false,
        'is_member', true,
        'role', v_existing_role,
        'action', 'CONTINUE',
        'message', 'Already a member'
      );
    END IF;

    -- Check if property has owner
    SELECT EXISTS (
      SELECT 1 FROM public.property_members
      WHERE property_id = v_property_id
        AND role = 'HOST'
        AND status = 'ACTIVE'
    ) INTO v_has_owner;

    -- No owner → suggest auto claim
    IF NOT v_has_owner THEN
      RETURN jsonb_build_object(
        'property_id', v_property_id,
        'is_new', false,
        'is_member', false,
        'action', 'AUTO_CLAIM',
        'message', 'No owner exists'
      );
    END IF;

    -- Owner exists → request access
    RETURN jsonb_build_object(
      'property_id', v_property_id,
      'is_new', false,
      'is_member', false,
      'action', 'REQUEST_ACCESS',
      'message', 'Property already owned'
    );
  END IF;

  ------------------------------------------------------------------
  -- 🏗️ CREATE FLOW
  ------------------------------------------------------------------

  INSERT INTO public.addresses (
    country, state, district, city, locality,
    postal_code, line1, line2,
    latitude, longitude,
    location,
    created_by,
    g_place_id,
    google_place_types,
    label
  )
  VALUES (
    p_country, p_state, p_district, p_city, p_locality,
    p_postal_code, p_line1, p_line2,
    p_lat, p_lng,
    ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography,
    p_user_id,
    p_google_place_id,
    p_google_types,
    p_label
  )
  RETURNING id INTO v_address_id;

  ------------------------------------------------------------------
  -- Slug
  ------------------------------------------------------------------
  v_slug := regexp_replace(lower(p_name), '[^a-z0-9]+', '-', 'g');
  v_slug := trim(both '-' from v_slug);

  IF v_slug = '' THEN
    v_slug := 'property-' || substring(gen_random_uuid()::text, 1, 6);
  END IF;

  IF EXISTS (SELECT 1 FROM public.properties WHERE slug = v_slug) THEN
    v_slug := v_slug || '-' || substring(gen_random_uuid()::text, 1, 6);
  END IF;

  ------------------------------------------------------------------
  -- Create Property
  ------------------------------------------------------------------
  INSERT INTO public.properties (
    name,
    slug,
    account_id,
    address_id,
    created_by,
    description,
    google_place_id,
    has_google_place,
    google_place_types,
    location,
    listing_source,
    ownership_status,
    status,
    creation_step,
    metadata,
    is_google_business
  )
  VALUES (
    p_name,
    v_slug,
    p_account_id,
    v_address_id,
    p_user_id,
    p_description,
    p_google_place_id,
    (p_google_place_id IS NOT NULL),
    p_google_types,
    ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography,
    p_listing_source,
    'OWNED',
    'DRAFT',
    1,
    COALESCE(p_metadata, '{}'::jsonb),
    (p_google_place_id IS NOT NULL)
  )
  RETURNING id INTO v_property_id;

  ------------------------------------------------------------------
  -- Assign HOST (ONLY for new property)
  ------------------------------------------------------------------
  INSERT INTO public.property_members (
    property_id,
    user_id,
    role,
    status
  )
  VALUES (
    v_property_id,
    p_user_id,
    'HOST',
    'ACTIVE'
  );

  ------------------------------------------------------------------
  -- Return
  ------------------------------------------------------------------
  RETURN jsonb_build_object(
    'property_id', v_property_id,
    'is_new', true,
    'action', 'CONTINUE',
    'message', 'Property created successfully'
  );

END;$function$
;

CREATE OR REPLACE FUNCTION public.create_property_with_address(p_name text, p_slug text, p_country text, p_state text, p_city text, p_postal_code text, p_address_line text, p_lat double precision, p_lng double precision, p_account_id uuid, p_user_id uuid, p_google_place_id text, p_has_google_place boolean)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$DECLARE
  v_address_id uuid;
  v_property_id uuid;
BEGIN
  -- 1. Create address
  INSERT INTO public.addresses (
    country, state, city, postal_code, line1, latitude, longitude, location, place_id, created_by
  )
  VALUES (
    p_country, p_state, p_city, p_postal_code, p_address_line, p_lat, p_lng, ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography, p_place_id, p_user_id
  )
  RETURNING id INTO v_address_id;

  -- 2. Create property (Now populates the 'location' geography column)
  INSERT INTO public.properties (
    name, 
    slug, 
    address_id, 
    account_id, 
    created_by, 
    google_place_id, 
    has_google_place, 
    location
  )
  VALUES (
    p_name, 
    p_slug, 
    v_address_id, 
    p_account_id, 
    p_user_id, 
    p_google_place_id, 
    p_has_google_place, 
    ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography -- Note: Lng first
  )
  RETURNING id INTO v_property_id;

  -- 3. Seed rules
  PERFORM public.seed_property_rules(v_property_id);

  -- 4. Return the result
  RETURN v_property_id;
END;$function$
;

CREATE OR REPLACE FUNCTION public.ensure_account_has_host()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM account_members
    WHERE account_id = NEW.id
    AND role = 'HOST'
  ) THEN
    RAISE EXCEPTION 'Account must have exactly one HOST member';
  END IF;

  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.handle_address_geography()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  -- Automatically update the geography point whenever lat/lng changes
  IF NEW.latitude IS NOT NULL AND NEW.longitude IS NOT NULL THEN
    NEW.location := ST_SetSRID(ST_MakePoint(NEW.longitude, NEW.latitude), 4326)::geography;
  END IF;
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.kyc_verified_trigger()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin

  if new.verification_status = 'VERIFIED' then
    perform activate_account_if_compliant(new.account_id);
  end if;

  return new;

end;
$function$
;

CREATE OR REPLACE FUNCTION public.log_account_event(p_account_id uuid, p_event text, p_actor uuid, p_metadata jsonb)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  insert into public.account_audit_logs (
    account_id,
    event,
    actor_id,
    metadata
  )
  values (
    p_account_id,
    p_event,
    p_actor,
    p_metadata
  );
end;
$function$
;

CREATE OR REPLACE FUNCTION public.payout_verified_trigger()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin

  if new.verification_status = 'VERIFIED' then
    perform activate_account_if_compliant(new.account_id);
  end if;

  return new;

end;
$function$
;

CREATE OR REPLACE FUNCTION public.prevent_account_status_change()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN

  -- Prevent suspension with active bookings
  IF NEW.status = 'SUSPENDED' THEN
    IF EXISTS (
      SELECT 1 FROM bookings
      WHERE account_id = NEW.id
      AND status IN ('CONFIRMED','ACTIVE')
    ) THEN
      RAISE EXCEPTION 'Cannot suspend account with active bookings';
    END IF;
  END IF;

  -- Prevent closing with active bookings
  IF NEW.status = 'CLOSED' THEN
    IF EXISTS (
      SELECT 1 FROM bookings
      WHERE account_id = NEW.id
      AND status IN ('CONFIRMED','ACTIVE')
    ) THEN
      RAISE EXCEPTION 'Cannot close account with active bookings';
    END IF;
  END IF;

  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.prevent_host_deletion()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  IF OLD.role = 'HOST' THEN
    RAISE EXCEPTION 'Cannot delete HOST. Use ownership transfer.';
  END IF;

  RETURN OLD;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.prevent_host_role_update()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  -- If existing role is HOST and someone tries to change it
  IF OLD.role = 'HOST' AND NEW.role <> 'HOST' THEN
    -- Allow only when special flag is set
    IF current_setting('app.allow_owner_transfer', true) IS DISTINCT FROM 'true' THEN
      RAISE EXCEPTION 'Cannot modify HOST role directly. Use ownership transfer.';
    END IF;
  END IF;

  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.prevent_owner_delete()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
  if old.role = 'OWNER' then
    raise exception 'Owner cannot be removed. Transfer ownership first.';
  end if;

  return old;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.prevent_owner_removal()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  IF OLD.role = 'HOST' THEN
    RAISE EXCEPTION 'Account Owner cannot be removed';
  END IF;

  RETURN OLD;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.prevent_owner_role_update()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
  if old.role = 'OWNER' and new.role <> 'OWNER' then
    raise exception 'Owner role cannot be downgraded. Transfer ownership instead.';
  end if;

  return new;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.prevent_suspend_with_bookings()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  IF NEW.status = 'SUSPENDED' THEN
    IF EXISTS (
      SELECT 1 FROM bookings
      WHERE account_id = NEW.id
      AND status IN ('CONFIRMED','ACTIVE')
    ) THEN
      RAISE EXCEPTION 'Cannot suspend account with active bookings';
    END IF;
  END IF;

  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.request_property_access(p_property_id uuid, p_user_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN

  -- Insert claim request (prevent duplicate pending)
  INSERT INTO public.property_claims (
    property_id,
    user_id,
    status
  )
  VALUES (
    p_property_id,
    p_user_id,
    'PENDING'
  )
  ON CONFLICT DO NOTHING;

  RETURN jsonb_build_object(
    'success', true,
    'message', 'Request submitted'
  );

END;
$function$
;

CREATE OR REPLACE FUNCTION public.reset_dev_data()
 RETURNS void
 LANGUAGE sql
AS $function$TRUNCATE TABLE
account_audit_logs,
account_business_profiles,
account_kyc_documents,
account_members,
account_partners,
account_payout_profiles,
account_subscriptions,
accounts,
addresses,
properties,
property_members,
property_seasons,
property_terrains,
property_facilities,
property_addons,
property_transport_hubs,
property_transfers,
property_verifications,
property_units,
unit_amenities,
unit_cancellation_policies,
cancellation_policies,
media_links,
media_assets,
users,
user_profiles
RESTART IDENTITY CASCADE;$function$
;

create or replace view "public"."resolved_unit_rules" as  SELECT pu.id AS unit_id,
    r.key,
    r.label,
    COALESCE(er_unit.value_override, er_property.value_override, r.default_value) AS final_value
   FROM ((((public.property_units pu
     JOIN public.properties p ON ((pu.property_id = p.id)))
     CROSS JOIN public.rules r)
     LEFT JOIN public.entity_rules er_unit ON (((er_unit.rule_id = r.id) AND (er_unit.entity_type = 'UNIT'::text) AND (er_unit.entity_id = pu.id))))
     LEFT JOIN public.entity_rules er_property ON (((er_property.rule_id = r.id) AND (er_property.entity_type = 'PROPERTY'::text) AND (er_property.entity_id = p.id))));


CREATE OR REPLACE FUNCTION public.rls_auto_enable()
 RETURNS event_trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog'
AS $function$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN
    SELECT *
    FROM pg_event_trigger_ddl_commands()
    WHERE command_tag IN ('CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO')
      AND object_type IN ('table','partitioned table')
  LOOP
     IF cmd.schema_name IS NOT NULL AND cmd.schema_name IN ('public') AND cmd.schema_name NOT IN ('pg_catalog','information_schema') AND cmd.schema_name NOT LIKE 'pg_toast%' AND cmd.schema_name NOT LIKE 'pg_temp%' THEN
      BEGIN
        EXECUTE format('alter table if exists %s enable row level security', cmd.object_identity);
        RAISE LOG 'rls_auto_enable: enabled RLS on %', cmd.object_identity;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE LOG 'rls_auto_enable: failed to enable RLS on %', cmd.object_identity;
      END;
     ELSE
        RAISE LOG 'rls_auto_enable: skip % (either system schema or not in enforced list: %.)', cmd.object_identity, cmd.schema_name;
     END IF;
  END LOOP;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.seed_property_rules(p_property_id uuid)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
  INSERT INTO public.property_rules (property_id, rule_key)
  SELECT p_property_id, pc.rule_key
  FROM public.policy_catalog pc
  ON CONFLICT (property_id, rule_key) DO NOTHING;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.sync_account_owner()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  IF NEW.role = 'HOST' THEN
    UPDATE accounts
    SET owner_user_id = NEW.user_id
    WHERE id = NEW.account_id;
  END IF;

  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.sync_property_location()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  NEW.location := (
    SELECT location FROM public.addresses WHERE id = NEW.address_id
  );
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.transfer_account_ownership(p_account_id uuid, p_new_owner_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_current_owner uuid;
  v_caller uuid := auth.uid();
  v_is_admin boolean := (auth.jwt() ->> 'role') = 'admin';
BEGIN
  -- Ensure caller exists
  IF v_caller IS NULL THEN
    RAISE EXCEPTION 'Authentication required';
  END IF;

  -- Get current owner
  SELECT user_id INTO v_current_owner
  FROM account_members
  WHERE account_id = p_account_id
  AND role = 'HOST';

  IF v_current_owner IS NULL THEN
    RAISE EXCEPTION 'No current HOST found';
  END IF;

  -- Permission check
  IF v_caller <> v_current_owner AND NOT v_is_admin THEN
    RAISE EXCEPTION 'Only current HOST or system admin can transfer ownership';
  END IF;

  -- Ensure new owner is ACTIVE member
  IF NOT EXISTS (
    SELECT 1 FROM account_members
    WHERE account_id = p_account_id
    AND user_id = p_new_owner_id
    AND status = 'ACTIVE'
  ) THEN
    RAISE EXCEPTION 'New owner must be an ACTIVE member';
  END IF;

  -- Enable temporary bypass
  PERFORM set_config('app.allow_owner_transfer', 'true', true);

  -- Downgrade current owner
  UPDATE account_members
  SET role = 'CO_HOST'
  WHERE account_id = p_account_id
  AND user_id = v_current_owner;

  -- Promote new owner
  UPDATE account_members
  SET role = 'HOST'
  WHERE account_id = p_account_id
  AND user_id = p_new_owner_id;

  -- Audit
  INSERT INTO account_audit_logs (
    account_id,
    event,
    actor_id,
    metadata
  )
  VALUES (
    p_account_id,
    'OWNER_TRANSFERRED',
    v_caller,
    jsonb_build_object(
      'previous_owner', v_current_owner,
      'new_owner', p_new_owner_id
    )
  );

END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_address_location()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  IF NEW.latitude IS NOT NULL AND NEW.longitude IS NOT NULL THEN
    NEW.location := ST_SetSRID(ST_MakePoint(NEW.longitude, NEW.latitude), 4326)::geography;
  END IF;
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_timestamp()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$function$
;

grant delete on table "public"."account_audit_logs" to "anon";

grant insert on table "public"."account_audit_logs" to "anon";

grant references on table "public"."account_audit_logs" to "anon";

grant select on table "public"."account_audit_logs" to "anon";

grant trigger on table "public"."account_audit_logs" to "anon";

grant truncate on table "public"."account_audit_logs" to "anon";

grant update on table "public"."account_audit_logs" to "anon";

grant delete on table "public"."account_audit_logs" to "authenticated";

grant insert on table "public"."account_audit_logs" to "authenticated";

grant references on table "public"."account_audit_logs" to "authenticated";

grant select on table "public"."account_audit_logs" to "authenticated";

grant trigger on table "public"."account_audit_logs" to "authenticated";

grant truncate on table "public"."account_audit_logs" to "authenticated";

grant update on table "public"."account_audit_logs" to "authenticated";

grant delete on table "public"."account_audit_logs" to "service_role";

grant insert on table "public"."account_audit_logs" to "service_role";

grant references on table "public"."account_audit_logs" to "service_role";

grant select on table "public"."account_audit_logs" to "service_role";

grant trigger on table "public"."account_audit_logs" to "service_role";

grant truncate on table "public"."account_audit_logs" to "service_role";

grant update on table "public"."account_audit_logs" to "service_role";

grant delete on table "public"."account_business_profiles" to "anon";

grant insert on table "public"."account_business_profiles" to "anon";

grant references on table "public"."account_business_profiles" to "anon";

grant select on table "public"."account_business_profiles" to "anon";

grant trigger on table "public"."account_business_profiles" to "anon";

grant truncate on table "public"."account_business_profiles" to "anon";

grant update on table "public"."account_business_profiles" to "anon";

grant delete on table "public"."account_business_profiles" to "authenticated";

grant insert on table "public"."account_business_profiles" to "authenticated";

grant references on table "public"."account_business_profiles" to "authenticated";

grant select on table "public"."account_business_profiles" to "authenticated";

grant trigger on table "public"."account_business_profiles" to "authenticated";

grant truncate on table "public"."account_business_profiles" to "authenticated";

grant update on table "public"."account_business_profiles" to "authenticated";

grant delete on table "public"."account_business_profiles" to "service_role";

grant insert on table "public"."account_business_profiles" to "service_role";

grant references on table "public"."account_business_profiles" to "service_role";

grant select on table "public"."account_business_profiles" to "service_role";

grant trigger on table "public"."account_business_profiles" to "service_role";

grant truncate on table "public"."account_business_profiles" to "service_role";

grant update on table "public"."account_business_profiles" to "service_role";

grant delete on table "public"."account_kyc_documents" to "anon";

grant insert on table "public"."account_kyc_documents" to "anon";

grant references on table "public"."account_kyc_documents" to "anon";

grant select on table "public"."account_kyc_documents" to "anon";

grant trigger on table "public"."account_kyc_documents" to "anon";

grant truncate on table "public"."account_kyc_documents" to "anon";

grant update on table "public"."account_kyc_documents" to "anon";

grant delete on table "public"."account_kyc_documents" to "authenticated";

grant insert on table "public"."account_kyc_documents" to "authenticated";

grant references on table "public"."account_kyc_documents" to "authenticated";

grant select on table "public"."account_kyc_documents" to "authenticated";

grant trigger on table "public"."account_kyc_documents" to "authenticated";

grant truncate on table "public"."account_kyc_documents" to "authenticated";

grant update on table "public"."account_kyc_documents" to "authenticated";

grant delete on table "public"."account_kyc_documents" to "service_role";

grant insert on table "public"."account_kyc_documents" to "service_role";

grant references on table "public"."account_kyc_documents" to "service_role";

grant select on table "public"."account_kyc_documents" to "service_role";

grant trigger on table "public"."account_kyc_documents" to "service_role";

grant truncate on table "public"."account_kyc_documents" to "service_role";

grant update on table "public"."account_kyc_documents" to "service_role";

grant delete on table "public"."account_members" to "anon";

grant insert on table "public"."account_members" to "anon";

grant references on table "public"."account_members" to "anon";

grant select on table "public"."account_members" to "anon";

grant trigger on table "public"."account_members" to "anon";

grant truncate on table "public"."account_members" to "anon";

grant update on table "public"."account_members" to "anon";

grant delete on table "public"."account_members" to "authenticated";

grant insert on table "public"."account_members" to "authenticated";

grant references on table "public"."account_members" to "authenticated";

grant select on table "public"."account_members" to "authenticated";

grant trigger on table "public"."account_members" to "authenticated";

grant truncate on table "public"."account_members" to "authenticated";

grant update on table "public"."account_members" to "authenticated";

grant delete on table "public"."account_members" to "service_role";

grant insert on table "public"."account_members" to "service_role";

grant references on table "public"."account_members" to "service_role";

grant select on table "public"."account_members" to "service_role";

grant trigger on table "public"."account_members" to "service_role";

grant truncate on table "public"."account_members" to "service_role";

grant update on table "public"."account_members" to "service_role";

grant delete on table "public"."account_partners" to "anon";

grant insert on table "public"."account_partners" to "anon";

grant references on table "public"."account_partners" to "anon";

grant select on table "public"."account_partners" to "anon";

grant trigger on table "public"."account_partners" to "anon";

grant truncate on table "public"."account_partners" to "anon";

grant update on table "public"."account_partners" to "anon";

grant delete on table "public"."account_partners" to "authenticated";

grant insert on table "public"."account_partners" to "authenticated";

grant references on table "public"."account_partners" to "authenticated";

grant select on table "public"."account_partners" to "authenticated";

grant trigger on table "public"."account_partners" to "authenticated";

grant truncate on table "public"."account_partners" to "authenticated";

grant update on table "public"."account_partners" to "authenticated";

grant delete on table "public"."account_partners" to "service_role";

grant insert on table "public"."account_partners" to "service_role";

grant references on table "public"."account_partners" to "service_role";

grant select on table "public"."account_partners" to "service_role";

grant trigger on table "public"."account_partners" to "service_role";

grant truncate on table "public"."account_partners" to "service_role";

grant update on table "public"."account_partners" to "service_role";

grant delete on table "public"."account_payout_profiles" to "anon";

grant insert on table "public"."account_payout_profiles" to "anon";

grant references on table "public"."account_payout_profiles" to "anon";

grant select on table "public"."account_payout_profiles" to "anon";

grant trigger on table "public"."account_payout_profiles" to "anon";

grant truncate on table "public"."account_payout_profiles" to "anon";

grant update on table "public"."account_payout_profiles" to "anon";

grant delete on table "public"."account_payout_profiles" to "authenticated";

grant insert on table "public"."account_payout_profiles" to "authenticated";

grant references on table "public"."account_payout_profiles" to "authenticated";

grant select on table "public"."account_payout_profiles" to "authenticated";

grant trigger on table "public"."account_payout_profiles" to "authenticated";

grant truncate on table "public"."account_payout_profiles" to "authenticated";

grant update on table "public"."account_payout_profiles" to "authenticated";

grant delete on table "public"."account_payout_profiles" to "service_role";

grant insert on table "public"."account_payout_profiles" to "service_role";

grant references on table "public"."account_payout_profiles" to "service_role";

grant select on table "public"."account_payout_profiles" to "service_role";

grant trigger on table "public"."account_payout_profiles" to "service_role";

grant truncate on table "public"."account_payout_profiles" to "service_role";

grant update on table "public"."account_payout_profiles" to "service_role";

grant delete on table "public"."account_subscriptions" to "anon";

grant insert on table "public"."account_subscriptions" to "anon";

grant references on table "public"."account_subscriptions" to "anon";

grant select on table "public"."account_subscriptions" to "anon";

grant trigger on table "public"."account_subscriptions" to "anon";

grant truncate on table "public"."account_subscriptions" to "anon";

grant update on table "public"."account_subscriptions" to "anon";

grant delete on table "public"."account_subscriptions" to "authenticated";

grant insert on table "public"."account_subscriptions" to "authenticated";

grant references on table "public"."account_subscriptions" to "authenticated";

grant select on table "public"."account_subscriptions" to "authenticated";

grant trigger on table "public"."account_subscriptions" to "authenticated";

grant truncate on table "public"."account_subscriptions" to "authenticated";

grant update on table "public"."account_subscriptions" to "authenticated";

grant delete on table "public"."account_subscriptions" to "service_role";

grant insert on table "public"."account_subscriptions" to "service_role";

grant references on table "public"."account_subscriptions" to "service_role";

grant select on table "public"."account_subscriptions" to "service_role";

grant trigger on table "public"."account_subscriptions" to "service_role";

grant truncate on table "public"."account_subscriptions" to "service_role";

grant update on table "public"."account_subscriptions" to "service_role";

grant delete on table "public"."accounts" to "anon";

grant insert on table "public"."accounts" to "anon";

grant references on table "public"."accounts" to "anon";

grant select on table "public"."accounts" to "anon";

grant trigger on table "public"."accounts" to "anon";

grant truncate on table "public"."accounts" to "anon";

grant update on table "public"."accounts" to "anon";

grant delete on table "public"."accounts" to "authenticated";

grant insert on table "public"."accounts" to "authenticated";

grant references on table "public"."accounts" to "authenticated";

grant select on table "public"."accounts" to "authenticated";

grant trigger on table "public"."accounts" to "authenticated";

grant truncate on table "public"."accounts" to "authenticated";

grant update on table "public"."accounts" to "authenticated";

grant delete on table "public"."accounts" to "service_role";

grant insert on table "public"."accounts" to "service_role";

grant references on table "public"."accounts" to "service_role";

grant select on table "public"."accounts" to "service_role";

grant trigger on table "public"."accounts" to "service_role";

grant truncate on table "public"."accounts" to "service_role";

grant update on table "public"."accounts" to "service_role";

grant delete on table "public"."addresses" to "anon";

grant insert on table "public"."addresses" to "anon";

grant references on table "public"."addresses" to "anon";

grant select on table "public"."addresses" to "anon";

grant trigger on table "public"."addresses" to "anon";

grant truncate on table "public"."addresses" to "anon";

grant update on table "public"."addresses" to "anon";

grant delete on table "public"."addresses" to "authenticated";

grant insert on table "public"."addresses" to "authenticated";

grant references on table "public"."addresses" to "authenticated";

grant select on table "public"."addresses" to "authenticated";

grant trigger on table "public"."addresses" to "authenticated";

grant truncate on table "public"."addresses" to "authenticated";

grant update on table "public"."addresses" to "authenticated";

grant delete on table "public"."addresses" to "service_role";

grant insert on table "public"."addresses" to "service_role";

grant references on table "public"."addresses" to "service_role";

grant select on table "public"."addresses" to "service_role";

grant trigger on table "public"."addresses" to "service_role";

grant truncate on table "public"."addresses" to "service_role";

grant update on table "public"."addresses" to "service_role";

grant delete on table "public"."amenity_catalog" to "anon";

grant insert on table "public"."amenity_catalog" to "anon";

grant references on table "public"."amenity_catalog" to "anon";

grant select on table "public"."amenity_catalog" to "anon";

grant trigger on table "public"."amenity_catalog" to "anon";

grant truncate on table "public"."amenity_catalog" to "anon";

grant update on table "public"."amenity_catalog" to "anon";

grant delete on table "public"."amenity_catalog" to "authenticated";

grant insert on table "public"."amenity_catalog" to "authenticated";

grant references on table "public"."amenity_catalog" to "authenticated";

grant select on table "public"."amenity_catalog" to "authenticated";

grant trigger on table "public"."amenity_catalog" to "authenticated";

grant truncate on table "public"."amenity_catalog" to "authenticated";

grant update on table "public"."amenity_catalog" to "authenticated";

grant delete on table "public"."amenity_catalog" to "service_role";

grant insert on table "public"."amenity_catalog" to "service_role";

grant references on table "public"."amenity_catalog" to "service_role";

grant select on table "public"."amenity_catalog" to "service_role";

grant trigger on table "public"."amenity_catalog" to "service_role";

grant truncate on table "public"."amenity_catalog" to "service_role";

grant update on table "public"."amenity_catalog" to "service_role";

grant delete on table "public"."cancellation_policies" to "anon";

grant insert on table "public"."cancellation_policies" to "anon";

grant references on table "public"."cancellation_policies" to "anon";

grant select on table "public"."cancellation_policies" to "anon";

grant trigger on table "public"."cancellation_policies" to "anon";

grant truncate on table "public"."cancellation_policies" to "anon";

grant update on table "public"."cancellation_policies" to "anon";

grant delete on table "public"."cancellation_policies" to "authenticated";

grant insert on table "public"."cancellation_policies" to "authenticated";

grant references on table "public"."cancellation_policies" to "authenticated";

grant select on table "public"."cancellation_policies" to "authenticated";

grant trigger on table "public"."cancellation_policies" to "authenticated";

grant truncate on table "public"."cancellation_policies" to "authenticated";

grant update on table "public"."cancellation_policies" to "authenticated";

grant delete on table "public"."cancellation_policies" to "service_role";

grant insert on table "public"."cancellation_policies" to "service_role";

grant references on table "public"."cancellation_policies" to "service_role";

grant select on table "public"."cancellation_policies" to "service_role";

grant trigger on table "public"."cancellation_policies" to "service_role";

grant truncate on table "public"."cancellation_policies" to "service_role";

grant update on table "public"."cancellation_policies" to "service_role";

grant delete on table "public"."entity_rules" to "anon";

grant insert on table "public"."entity_rules" to "anon";

grant references on table "public"."entity_rules" to "anon";

grant select on table "public"."entity_rules" to "anon";

grant trigger on table "public"."entity_rules" to "anon";

grant truncate on table "public"."entity_rules" to "anon";

grant update on table "public"."entity_rules" to "anon";

grant delete on table "public"."entity_rules" to "authenticated";

grant insert on table "public"."entity_rules" to "authenticated";

grant references on table "public"."entity_rules" to "authenticated";

grant select on table "public"."entity_rules" to "authenticated";

grant trigger on table "public"."entity_rules" to "authenticated";

grant truncate on table "public"."entity_rules" to "authenticated";

grant update on table "public"."entity_rules" to "authenticated";

grant delete on table "public"."entity_rules" to "service_role";

grant insert on table "public"."entity_rules" to "service_role";

grant references on table "public"."entity_rules" to "service_role";

grant select on table "public"."entity_rules" to "service_role";

grant trigger on table "public"."entity_rules" to "service_role";

grant truncate on table "public"."entity_rules" to "service_role";

grant update on table "public"."entity_rules" to "service_role";

grant delete on table "public"."experience_properties" to "anon";

grant insert on table "public"."experience_properties" to "anon";

grant references on table "public"."experience_properties" to "anon";

grant select on table "public"."experience_properties" to "anon";

grant trigger on table "public"."experience_properties" to "anon";

grant truncate on table "public"."experience_properties" to "anon";

grant update on table "public"."experience_properties" to "anon";

grant delete on table "public"."experience_properties" to "authenticated";

grant insert on table "public"."experience_properties" to "authenticated";

grant references on table "public"."experience_properties" to "authenticated";

grant select on table "public"."experience_properties" to "authenticated";

grant trigger on table "public"."experience_properties" to "authenticated";

grant truncate on table "public"."experience_properties" to "authenticated";

grant update on table "public"."experience_properties" to "authenticated";

grant delete on table "public"."experience_properties" to "service_role";

grant insert on table "public"."experience_properties" to "service_role";

grant references on table "public"."experience_properties" to "service_role";

grant select on table "public"."experience_properties" to "service_role";

grant trigger on table "public"."experience_properties" to "service_role";

grant truncate on table "public"."experience_properties" to "service_role";

grant update on table "public"."experience_properties" to "service_role";

grant delete on table "public"."experience_units" to "anon";

grant insert on table "public"."experience_units" to "anon";

grant references on table "public"."experience_units" to "anon";

grant select on table "public"."experience_units" to "anon";

grant trigger on table "public"."experience_units" to "anon";

grant truncate on table "public"."experience_units" to "anon";

grant update on table "public"."experience_units" to "anon";

grant delete on table "public"."experience_units" to "authenticated";

grant insert on table "public"."experience_units" to "authenticated";

grant references on table "public"."experience_units" to "authenticated";

grant select on table "public"."experience_units" to "authenticated";

grant trigger on table "public"."experience_units" to "authenticated";

grant truncate on table "public"."experience_units" to "authenticated";

grant update on table "public"."experience_units" to "authenticated";

grant delete on table "public"."experience_units" to "service_role";

grant insert on table "public"."experience_units" to "service_role";

grant references on table "public"."experience_units" to "service_role";

grant select on table "public"."experience_units" to "service_role";

grant trigger on table "public"."experience_units" to "service_role";

grant truncate on table "public"."experience_units" to "service_role";

grant update on table "public"."experience_units" to "service_role";

grant delete on table "public"."experiences" to "anon";

grant insert on table "public"."experiences" to "anon";

grant references on table "public"."experiences" to "anon";

grant select on table "public"."experiences" to "anon";

grant trigger on table "public"."experiences" to "anon";

grant truncate on table "public"."experiences" to "anon";

grant update on table "public"."experiences" to "anon";

grant delete on table "public"."experiences" to "authenticated";

grant insert on table "public"."experiences" to "authenticated";

grant references on table "public"."experiences" to "authenticated";

grant select on table "public"."experiences" to "authenticated";

grant trigger on table "public"."experiences" to "authenticated";

grant truncate on table "public"."experiences" to "authenticated";

grant update on table "public"."experiences" to "authenticated";

grant delete on table "public"."experiences" to "service_role";

grant insert on table "public"."experiences" to "service_role";

grant references on table "public"."experiences" to "service_role";

grant select on table "public"."experiences" to "service_role";

grant trigger on table "public"."experiences" to "service_role";

grant truncate on table "public"."experiences" to "service_role";

grant update on table "public"."experiences" to "service_role";

grant delete on table "public"."facility_catalog" to "anon";

grant insert on table "public"."facility_catalog" to "anon";

grant references on table "public"."facility_catalog" to "anon";

grant select on table "public"."facility_catalog" to "anon";

grant trigger on table "public"."facility_catalog" to "anon";

grant truncate on table "public"."facility_catalog" to "anon";

grant update on table "public"."facility_catalog" to "anon";

grant delete on table "public"."facility_catalog" to "authenticated";

grant insert on table "public"."facility_catalog" to "authenticated";

grant references on table "public"."facility_catalog" to "authenticated";

grant select on table "public"."facility_catalog" to "authenticated";

grant trigger on table "public"."facility_catalog" to "authenticated";

grant truncate on table "public"."facility_catalog" to "authenticated";

grant update on table "public"."facility_catalog" to "authenticated";

grant delete on table "public"."facility_catalog" to "service_role";

grant insert on table "public"."facility_catalog" to "service_role";

grant references on table "public"."facility_catalog" to "service_role";

grant select on table "public"."facility_catalog" to "service_role";

grant trigger on table "public"."facility_catalog" to "service_role";

grant truncate on table "public"."facility_catalog" to "service_role";

grant update on table "public"."facility_catalog" to "service_role";

grant delete on table "public"."media_assets" to "anon";

grant insert on table "public"."media_assets" to "anon";

grant references on table "public"."media_assets" to "anon";

grant select on table "public"."media_assets" to "anon";

grant trigger on table "public"."media_assets" to "anon";

grant truncate on table "public"."media_assets" to "anon";

grant update on table "public"."media_assets" to "anon";

grant delete on table "public"."media_assets" to "authenticated";

grant insert on table "public"."media_assets" to "authenticated";

grant references on table "public"."media_assets" to "authenticated";

grant select on table "public"."media_assets" to "authenticated";

grant trigger on table "public"."media_assets" to "authenticated";

grant truncate on table "public"."media_assets" to "authenticated";

grant update on table "public"."media_assets" to "authenticated";

grant delete on table "public"."media_assets" to "service_role";

grant insert on table "public"."media_assets" to "service_role";

grant references on table "public"."media_assets" to "service_role";

grant select on table "public"."media_assets" to "service_role";

grant trigger on table "public"."media_assets" to "service_role";

grant truncate on table "public"."media_assets" to "service_role";

grant update on table "public"."media_assets" to "service_role";

grant delete on table "public"."media_links" to "anon";

grant insert on table "public"."media_links" to "anon";

grant references on table "public"."media_links" to "anon";

grant select on table "public"."media_links" to "anon";

grant trigger on table "public"."media_links" to "anon";

grant truncate on table "public"."media_links" to "anon";

grant update on table "public"."media_links" to "anon";

grant delete on table "public"."media_links" to "authenticated";

grant insert on table "public"."media_links" to "authenticated";

grant references on table "public"."media_links" to "authenticated";

grant select on table "public"."media_links" to "authenticated";

grant trigger on table "public"."media_links" to "authenticated";

grant truncate on table "public"."media_links" to "authenticated";

grant update on table "public"."media_links" to "authenticated";

grant delete on table "public"."media_links" to "service_role";

grant insert on table "public"."media_links" to "service_role";

grant references on table "public"."media_links" to "service_role";

grant select on table "public"."media_links" to "service_role";

grant trigger on table "public"."media_links" to "service_role";

grant truncate on table "public"."media_links" to "service_role";

grant update on table "public"."media_links" to "service_role";

grant delete on table "public"."plan_limits" to "anon";

grant insert on table "public"."plan_limits" to "anon";

grant references on table "public"."plan_limits" to "anon";

grant select on table "public"."plan_limits" to "anon";

grant trigger on table "public"."plan_limits" to "anon";

grant truncate on table "public"."plan_limits" to "anon";

grant update on table "public"."plan_limits" to "anon";

grant delete on table "public"."plan_limits" to "authenticated";

grant insert on table "public"."plan_limits" to "authenticated";

grant references on table "public"."plan_limits" to "authenticated";

grant select on table "public"."plan_limits" to "authenticated";

grant trigger on table "public"."plan_limits" to "authenticated";

grant truncate on table "public"."plan_limits" to "authenticated";

grant update on table "public"."plan_limits" to "authenticated";

grant delete on table "public"."plan_limits" to "service_role";

grant insert on table "public"."plan_limits" to "service_role";

grant references on table "public"."plan_limits" to "service_role";

grant select on table "public"."plan_limits" to "service_role";

grant trigger on table "public"."plan_limits" to "service_role";

grant truncate on table "public"."plan_limits" to "service_role";

grant update on table "public"."plan_limits" to "service_role";

grant delete on table "public"."properties" to "anon";

grant insert on table "public"."properties" to "anon";

grant references on table "public"."properties" to "anon";

grant select on table "public"."properties" to "anon";

grant trigger on table "public"."properties" to "anon";

grant truncate on table "public"."properties" to "anon";

grant update on table "public"."properties" to "anon";

grant delete on table "public"."properties" to "authenticated";

grant insert on table "public"."properties" to "authenticated";

grant references on table "public"."properties" to "authenticated";

grant select on table "public"."properties" to "authenticated";

grant trigger on table "public"."properties" to "authenticated";

grant truncate on table "public"."properties" to "authenticated";

grant update on table "public"."properties" to "authenticated";

grant delete on table "public"."properties" to "service_role";

grant insert on table "public"."properties" to "service_role";

grant references on table "public"."properties" to "service_role";

grant select on table "public"."properties" to "service_role";

grant trigger on table "public"."properties" to "service_role";

grant truncate on table "public"."properties" to "service_role";

grant update on table "public"."properties" to "service_role";

grant delete on table "public"."property_addons" to "anon";

grant insert on table "public"."property_addons" to "anon";

grant references on table "public"."property_addons" to "anon";

grant select on table "public"."property_addons" to "anon";

grant trigger on table "public"."property_addons" to "anon";

grant truncate on table "public"."property_addons" to "anon";

grant update on table "public"."property_addons" to "anon";

grant delete on table "public"."property_addons" to "authenticated";

grant insert on table "public"."property_addons" to "authenticated";

grant references on table "public"."property_addons" to "authenticated";

grant select on table "public"."property_addons" to "authenticated";

grant trigger on table "public"."property_addons" to "authenticated";

grant truncate on table "public"."property_addons" to "authenticated";

grant update on table "public"."property_addons" to "authenticated";

grant delete on table "public"."property_addons" to "service_role";

grant insert on table "public"."property_addons" to "service_role";

grant references on table "public"."property_addons" to "service_role";

grant select on table "public"."property_addons" to "service_role";

grant trigger on table "public"."property_addons" to "service_role";

grant truncate on table "public"."property_addons" to "service_role";

grant update on table "public"."property_addons" to "service_role";

grant delete on table "public"."property_claims" to "anon";

grant insert on table "public"."property_claims" to "anon";

grant references on table "public"."property_claims" to "anon";

grant select on table "public"."property_claims" to "anon";

grant trigger on table "public"."property_claims" to "anon";

grant truncate on table "public"."property_claims" to "anon";

grant update on table "public"."property_claims" to "anon";

grant delete on table "public"."property_claims" to "authenticated";

grant insert on table "public"."property_claims" to "authenticated";

grant references on table "public"."property_claims" to "authenticated";

grant select on table "public"."property_claims" to "authenticated";

grant trigger on table "public"."property_claims" to "authenticated";

grant truncate on table "public"."property_claims" to "authenticated";

grant update on table "public"."property_claims" to "authenticated";

grant delete on table "public"."property_claims" to "service_role";

grant insert on table "public"."property_claims" to "service_role";

grant references on table "public"."property_claims" to "service_role";

grant select on table "public"."property_claims" to "service_role";

grant trigger on table "public"."property_claims" to "service_role";

grant truncate on table "public"."property_claims" to "service_role";

grant update on table "public"."property_claims" to "service_role";

grant delete on table "public"."property_facilities" to "anon";

grant insert on table "public"."property_facilities" to "anon";

grant references on table "public"."property_facilities" to "anon";

grant select on table "public"."property_facilities" to "anon";

grant trigger on table "public"."property_facilities" to "anon";

grant truncate on table "public"."property_facilities" to "anon";

grant update on table "public"."property_facilities" to "anon";

grant delete on table "public"."property_facilities" to "authenticated";

grant insert on table "public"."property_facilities" to "authenticated";

grant references on table "public"."property_facilities" to "authenticated";

grant select on table "public"."property_facilities" to "authenticated";

grant trigger on table "public"."property_facilities" to "authenticated";

grant truncate on table "public"."property_facilities" to "authenticated";

grant update on table "public"."property_facilities" to "authenticated";

grant delete on table "public"."property_facilities" to "service_role";

grant insert on table "public"."property_facilities" to "service_role";

grant references on table "public"."property_facilities" to "service_role";

grant select on table "public"."property_facilities" to "service_role";

grant trigger on table "public"."property_facilities" to "service_role";

grant truncate on table "public"."property_facilities" to "service_role";

grant update on table "public"."property_facilities" to "service_role";

grant delete on table "public"."property_google_data" to "anon";

grant insert on table "public"."property_google_data" to "anon";

grant references on table "public"."property_google_data" to "anon";

grant select on table "public"."property_google_data" to "anon";

grant trigger on table "public"."property_google_data" to "anon";

grant truncate on table "public"."property_google_data" to "anon";

grant update on table "public"."property_google_data" to "anon";

grant delete on table "public"."property_google_data" to "authenticated";

grant insert on table "public"."property_google_data" to "authenticated";

grant references on table "public"."property_google_data" to "authenticated";

grant select on table "public"."property_google_data" to "authenticated";

grant trigger on table "public"."property_google_data" to "authenticated";

grant truncate on table "public"."property_google_data" to "authenticated";

grant update on table "public"."property_google_data" to "authenticated";

grant delete on table "public"."property_google_data" to "service_role";

grant insert on table "public"."property_google_data" to "service_role";

grant references on table "public"."property_google_data" to "service_role";

grant select on table "public"."property_google_data" to "service_role";

grant trigger on table "public"."property_google_data" to "service_role";

grant truncate on table "public"."property_google_data" to "service_role";

grant update on table "public"."property_google_data" to "service_role";

grant delete on table "public"."property_members" to "anon";

grant insert on table "public"."property_members" to "anon";

grant references on table "public"."property_members" to "anon";

grant select on table "public"."property_members" to "anon";

grant trigger on table "public"."property_members" to "anon";

grant truncate on table "public"."property_members" to "anon";

grant update on table "public"."property_members" to "anon";

grant delete on table "public"."property_members" to "authenticated";

grant insert on table "public"."property_members" to "authenticated";

grant references on table "public"."property_members" to "authenticated";

grant select on table "public"."property_members" to "authenticated";

grant trigger on table "public"."property_members" to "authenticated";

grant truncate on table "public"."property_members" to "authenticated";

grant update on table "public"."property_members" to "authenticated";

grant delete on table "public"."property_members" to "service_role";

grant insert on table "public"."property_members" to "service_role";

grant references on table "public"."property_members" to "service_role";

grant select on table "public"."property_members" to "service_role";

grant trigger on table "public"."property_members" to "service_role";

grant truncate on table "public"."property_members" to "service_role";

grant update on table "public"."property_members" to "service_role";

grant delete on table "public"."property_seasons" to "anon";

grant insert on table "public"."property_seasons" to "anon";

grant references on table "public"."property_seasons" to "anon";

grant select on table "public"."property_seasons" to "anon";

grant trigger on table "public"."property_seasons" to "anon";

grant truncate on table "public"."property_seasons" to "anon";

grant update on table "public"."property_seasons" to "anon";

grant delete on table "public"."property_seasons" to "authenticated";

grant insert on table "public"."property_seasons" to "authenticated";

grant references on table "public"."property_seasons" to "authenticated";

grant select on table "public"."property_seasons" to "authenticated";

grant trigger on table "public"."property_seasons" to "authenticated";

grant truncate on table "public"."property_seasons" to "authenticated";

grant update on table "public"."property_seasons" to "authenticated";

grant delete on table "public"."property_seasons" to "service_role";

grant insert on table "public"."property_seasons" to "service_role";

grant references on table "public"."property_seasons" to "service_role";

grant select on table "public"."property_seasons" to "service_role";

grant trigger on table "public"."property_seasons" to "service_role";

grant truncate on table "public"."property_seasons" to "service_role";

grant update on table "public"."property_seasons" to "service_role";

grant delete on table "public"."property_terrains" to "anon";

grant insert on table "public"."property_terrains" to "anon";

grant references on table "public"."property_terrains" to "anon";

grant select on table "public"."property_terrains" to "anon";

grant trigger on table "public"."property_terrains" to "anon";

grant truncate on table "public"."property_terrains" to "anon";

grant update on table "public"."property_terrains" to "anon";

grant delete on table "public"."property_terrains" to "authenticated";

grant insert on table "public"."property_terrains" to "authenticated";

grant references on table "public"."property_terrains" to "authenticated";

grant select on table "public"."property_terrains" to "authenticated";

grant trigger on table "public"."property_terrains" to "authenticated";

grant truncate on table "public"."property_terrains" to "authenticated";

grant update on table "public"."property_terrains" to "authenticated";

grant delete on table "public"."property_terrains" to "service_role";

grant insert on table "public"."property_terrains" to "service_role";

grant references on table "public"."property_terrains" to "service_role";

grant select on table "public"."property_terrains" to "service_role";

grant trigger on table "public"."property_terrains" to "service_role";

grant truncate on table "public"."property_terrains" to "service_role";

grant update on table "public"."property_terrains" to "service_role";

grant delete on table "public"."property_transfers" to "anon";

grant insert on table "public"."property_transfers" to "anon";

grant references on table "public"."property_transfers" to "anon";

grant select on table "public"."property_transfers" to "anon";

grant trigger on table "public"."property_transfers" to "anon";

grant truncate on table "public"."property_transfers" to "anon";

grant update on table "public"."property_transfers" to "anon";

grant delete on table "public"."property_transfers" to "authenticated";

grant insert on table "public"."property_transfers" to "authenticated";

grant references on table "public"."property_transfers" to "authenticated";

grant select on table "public"."property_transfers" to "authenticated";

grant trigger on table "public"."property_transfers" to "authenticated";

grant truncate on table "public"."property_transfers" to "authenticated";

grant update on table "public"."property_transfers" to "authenticated";

grant delete on table "public"."property_transfers" to "service_role";

grant insert on table "public"."property_transfers" to "service_role";

grant references on table "public"."property_transfers" to "service_role";

grant select on table "public"."property_transfers" to "service_role";

grant trigger on table "public"."property_transfers" to "service_role";

grant truncate on table "public"."property_transfers" to "service_role";

grant update on table "public"."property_transfers" to "service_role";

grant delete on table "public"."property_transport_hubs" to "anon";

grant insert on table "public"."property_transport_hubs" to "anon";

grant references on table "public"."property_transport_hubs" to "anon";

grant select on table "public"."property_transport_hubs" to "anon";

grant trigger on table "public"."property_transport_hubs" to "anon";

grant truncate on table "public"."property_transport_hubs" to "anon";

grant update on table "public"."property_transport_hubs" to "anon";

grant delete on table "public"."property_transport_hubs" to "authenticated";

grant insert on table "public"."property_transport_hubs" to "authenticated";

grant references on table "public"."property_transport_hubs" to "authenticated";

grant select on table "public"."property_transport_hubs" to "authenticated";

grant trigger on table "public"."property_transport_hubs" to "authenticated";

grant truncate on table "public"."property_transport_hubs" to "authenticated";

grant update on table "public"."property_transport_hubs" to "authenticated";

grant delete on table "public"."property_transport_hubs" to "service_role";

grant insert on table "public"."property_transport_hubs" to "service_role";

grant references on table "public"."property_transport_hubs" to "service_role";

grant select on table "public"."property_transport_hubs" to "service_role";

grant trigger on table "public"."property_transport_hubs" to "service_role";

grant truncate on table "public"."property_transport_hubs" to "service_role";

grant update on table "public"."property_transport_hubs" to "service_role";

grant delete on table "public"."property_units" to "anon";

grant insert on table "public"."property_units" to "anon";

grant references on table "public"."property_units" to "anon";

grant select on table "public"."property_units" to "anon";

grant trigger on table "public"."property_units" to "anon";

grant truncate on table "public"."property_units" to "anon";

grant update on table "public"."property_units" to "anon";

grant delete on table "public"."property_units" to "authenticated";

grant insert on table "public"."property_units" to "authenticated";

grant references on table "public"."property_units" to "authenticated";

grant select on table "public"."property_units" to "authenticated";

grant trigger on table "public"."property_units" to "authenticated";

grant truncate on table "public"."property_units" to "authenticated";

grant update on table "public"."property_units" to "authenticated";

grant delete on table "public"."property_units" to "service_role";

grant insert on table "public"."property_units" to "service_role";

grant references on table "public"."property_units" to "service_role";

grant select on table "public"."property_units" to "service_role";

grant trigger on table "public"."property_units" to "service_role";

grant truncate on table "public"."property_units" to "service_role";

grant update on table "public"."property_units" to "service_role";

grant delete on table "public"."property_verifications" to "anon";

grant insert on table "public"."property_verifications" to "anon";

grant references on table "public"."property_verifications" to "anon";

grant select on table "public"."property_verifications" to "anon";

grant trigger on table "public"."property_verifications" to "anon";

grant truncate on table "public"."property_verifications" to "anon";

grant update on table "public"."property_verifications" to "anon";

grant delete on table "public"."property_verifications" to "authenticated";

grant insert on table "public"."property_verifications" to "authenticated";

grant references on table "public"."property_verifications" to "authenticated";

grant select on table "public"."property_verifications" to "authenticated";

grant trigger on table "public"."property_verifications" to "authenticated";

grant truncate on table "public"."property_verifications" to "authenticated";

grant update on table "public"."property_verifications" to "authenticated";

grant delete on table "public"."property_verifications" to "service_role";

grant insert on table "public"."property_verifications" to "service_role";

grant references on table "public"."property_verifications" to "service_role";

grant select on table "public"."property_verifications" to "service_role";

grant trigger on table "public"."property_verifications" to "service_role";

grant truncate on table "public"."property_verifications" to "service_role";

grant update on table "public"."property_verifications" to "service_role";

grant delete on table "public"."rule_categories" to "anon";

grant insert on table "public"."rule_categories" to "anon";

grant references on table "public"."rule_categories" to "anon";

grant select on table "public"."rule_categories" to "anon";

grant trigger on table "public"."rule_categories" to "anon";

grant truncate on table "public"."rule_categories" to "anon";

grant update on table "public"."rule_categories" to "anon";

grant delete on table "public"."rule_categories" to "authenticated";

grant insert on table "public"."rule_categories" to "authenticated";

grant references on table "public"."rule_categories" to "authenticated";

grant select on table "public"."rule_categories" to "authenticated";

grant trigger on table "public"."rule_categories" to "authenticated";

grant truncate on table "public"."rule_categories" to "authenticated";

grant update on table "public"."rule_categories" to "authenticated";

grant delete on table "public"."rule_categories" to "service_role";

grant insert on table "public"."rule_categories" to "service_role";

grant references on table "public"."rule_categories" to "service_role";

grant select on table "public"."rule_categories" to "service_role";

grant trigger on table "public"."rule_categories" to "service_role";

grant truncate on table "public"."rule_categories" to "service_role";

grant update on table "public"."rule_categories" to "service_role";

grant delete on table "public"."rule_templates" to "anon";

grant insert on table "public"."rule_templates" to "anon";

grant references on table "public"."rule_templates" to "anon";

grant select on table "public"."rule_templates" to "anon";

grant trigger on table "public"."rule_templates" to "anon";

grant truncate on table "public"."rule_templates" to "anon";

grant update on table "public"."rule_templates" to "anon";

grant delete on table "public"."rule_templates" to "authenticated";

grant insert on table "public"."rule_templates" to "authenticated";

grant references on table "public"."rule_templates" to "authenticated";

grant select on table "public"."rule_templates" to "authenticated";

grant trigger on table "public"."rule_templates" to "authenticated";

grant truncate on table "public"."rule_templates" to "authenticated";

grant update on table "public"."rule_templates" to "authenticated";

grant delete on table "public"."rule_templates" to "service_role";

grant insert on table "public"."rule_templates" to "service_role";

grant references on table "public"."rule_templates" to "service_role";

grant select on table "public"."rule_templates" to "service_role";

grant trigger on table "public"."rule_templates" to "service_role";

grant truncate on table "public"."rule_templates" to "service_role";

grant update on table "public"."rule_templates" to "service_role";

grant delete on table "public"."rules" to "anon";

grant insert on table "public"."rules" to "anon";

grant references on table "public"."rules" to "anon";

grant select on table "public"."rules" to "anon";

grant trigger on table "public"."rules" to "anon";

grant truncate on table "public"."rules" to "anon";

grant update on table "public"."rules" to "anon";

grant delete on table "public"."rules" to "authenticated";

grant insert on table "public"."rules" to "authenticated";

grant references on table "public"."rules" to "authenticated";

grant select on table "public"."rules" to "authenticated";

grant trigger on table "public"."rules" to "authenticated";

grant truncate on table "public"."rules" to "authenticated";

grant update on table "public"."rules" to "authenticated";

grant delete on table "public"."rules" to "service_role";

grant insert on table "public"."rules" to "service_role";

grant references on table "public"."rules" to "service_role";

grant select on table "public"."rules" to "service_role";

grant trigger on table "public"."rules" to "service_role";

grant truncate on table "public"."rules" to "service_role";

grant update on table "public"."rules" to "service_role";

grant delete on table "public"."subscription_plans" to "anon";

grant insert on table "public"."subscription_plans" to "anon";

grant references on table "public"."subscription_plans" to "anon";

grant select on table "public"."subscription_plans" to "anon";

grant trigger on table "public"."subscription_plans" to "anon";

grant truncate on table "public"."subscription_plans" to "anon";

grant update on table "public"."subscription_plans" to "anon";

grant delete on table "public"."subscription_plans" to "authenticated";

grant insert on table "public"."subscription_plans" to "authenticated";

grant references on table "public"."subscription_plans" to "authenticated";

grant select on table "public"."subscription_plans" to "authenticated";

grant trigger on table "public"."subscription_plans" to "authenticated";

grant truncate on table "public"."subscription_plans" to "authenticated";

grant update on table "public"."subscription_plans" to "authenticated";

grant delete on table "public"."subscription_plans" to "service_role";

grant insert on table "public"."subscription_plans" to "service_role";

grant references on table "public"."subscription_plans" to "service_role";

grant select on table "public"."subscription_plans" to "service_role";

grant trigger on table "public"."subscription_plans" to "service_role";

grant truncate on table "public"."subscription_plans" to "service_role";

grant update on table "public"."subscription_plans" to "service_role";

grant delete on table "public"."template_rules" to "anon";

grant insert on table "public"."template_rules" to "anon";

grant references on table "public"."template_rules" to "anon";

grant select on table "public"."template_rules" to "anon";

grant trigger on table "public"."template_rules" to "anon";

grant truncate on table "public"."template_rules" to "anon";

grant update on table "public"."template_rules" to "anon";

grant delete on table "public"."template_rules" to "authenticated";

grant insert on table "public"."template_rules" to "authenticated";

grant references on table "public"."template_rules" to "authenticated";

grant select on table "public"."template_rules" to "authenticated";

grant trigger on table "public"."template_rules" to "authenticated";

grant truncate on table "public"."template_rules" to "authenticated";

grant update on table "public"."template_rules" to "authenticated";

grant delete on table "public"."template_rules" to "service_role";

grant insert on table "public"."template_rules" to "service_role";

grant references on table "public"."template_rules" to "service_role";

grant select on table "public"."template_rules" to "service_role";

grant trigger on table "public"."template_rules" to "service_role";

grant truncate on table "public"."template_rules" to "service_role";

grant update on table "public"."template_rules" to "service_role";

grant delete on table "public"."terrain_catalog" to "anon";

grant insert on table "public"."terrain_catalog" to "anon";

grant references on table "public"."terrain_catalog" to "anon";

grant select on table "public"."terrain_catalog" to "anon";

grant trigger on table "public"."terrain_catalog" to "anon";

grant truncate on table "public"."terrain_catalog" to "anon";

grant update on table "public"."terrain_catalog" to "anon";

grant delete on table "public"."terrain_catalog" to "authenticated";

grant insert on table "public"."terrain_catalog" to "authenticated";

grant references on table "public"."terrain_catalog" to "authenticated";

grant select on table "public"."terrain_catalog" to "authenticated";

grant trigger on table "public"."terrain_catalog" to "authenticated";

grant truncate on table "public"."terrain_catalog" to "authenticated";

grant update on table "public"."terrain_catalog" to "authenticated";

grant delete on table "public"."terrain_catalog" to "service_role";

grant insert on table "public"."terrain_catalog" to "service_role";

grant references on table "public"."terrain_catalog" to "service_role";

grant select on table "public"."terrain_catalog" to "service_role";

grant trigger on table "public"."terrain_catalog" to "service_role";

grant truncate on table "public"."terrain_catalog" to "service_role";

grant update on table "public"."terrain_catalog" to "service_role";

grant delete on table "public"."unit_amenities" to "anon";

grant insert on table "public"."unit_amenities" to "anon";

grant references on table "public"."unit_amenities" to "anon";

grant select on table "public"."unit_amenities" to "anon";

grant trigger on table "public"."unit_amenities" to "anon";

grant truncate on table "public"."unit_amenities" to "anon";

grant update on table "public"."unit_amenities" to "anon";

grant delete on table "public"."unit_amenities" to "authenticated";

grant insert on table "public"."unit_amenities" to "authenticated";

grant references on table "public"."unit_amenities" to "authenticated";

grant select on table "public"."unit_amenities" to "authenticated";

grant trigger on table "public"."unit_amenities" to "authenticated";

grant truncate on table "public"."unit_amenities" to "authenticated";

grant update on table "public"."unit_amenities" to "authenticated";

grant delete on table "public"."unit_amenities" to "service_role";

grant insert on table "public"."unit_amenities" to "service_role";

grant references on table "public"."unit_amenities" to "service_role";

grant select on table "public"."unit_amenities" to "service_role";

grant trigger on table "public"."unit_amenities" to "service_role";

grant truncate on table "public"."unit_amenities" to "service_role";

grant update on table "public"."unit_amenities" to "service_role";

grant delete on table "public"."unit_availability_exceptions" to "anon";

grant insert on table "public"."unit_availability_exceptions" to "anon";

grant references on table "public"."unit_availability_exceptions" to "anon";

grant select on table "public"."unit_availability_exceptions" to "anon";

grant trigger on table "public"."unit_availability_exceptions" to "anon";

grant truncate on table "public"."unit_availability_exceptions" to "anon";

grant update on table "public"."unit_availability_exceptions" to "anon";

grant delete on table "public"."unit_availability_exceptions" to "authenticated";

grant insert on table "public"."unit_availability_exceptions" to "authenticated";

grant references on table "public"."unit_availability_exceptions" to "authenticated";

grant select on table "public"."unit_availability_exceptions" to "authenticated";

grant trigger on table "public"."unit_availability_exceptions" to "authenticated";

grant truncate on table "public"."unit_availability_exceptions" to "authenticated";

grant update on table "public"."unit_availability_exceptions" to "authenticated";

grant delete on table "public"."unit_availability_exceptions" to "service_role";

grant insert on table "public"."unit_availability_exceptions" to "service_role";

grant references on table "public"."unit_availability_exceptions" to "service_role";

grant select on table "public"."unit_availability_exceptions" to "service_role";

grant trigger on table "public"."unit_availability_exceptions" to "service_role";

grant truncate on table "public"."unit_availability_exceptions" to "service_role";

grant update on table "public"."unit_availability_exceptions" to "service_role";

grant delete on table "public"."unit_availability_schedules" to "anon";

grant insert on table "public"."unit_availability_schedules" to "anon";

grant references on table "public"."unit_availability_schedules" to "anon";

grant select on table "public"."unit_availability_schedules" to "anon";

grant trigger on table "public"."unit_availability_schedules" to "anon";

grant truncate on table "public"."unit_availability_schedules" to "anon";

grant update on table "public"."unit_availability_schedules" to "anon";

grant delete on table "public"."unit_availability_schedules" to "authenticated";

grant insert on table "public"."unit_availability_schedules" to "authenticated";

grant references on table "public"."unit_availability_schedules" to "authenticated";

grant select on table "public"."unit_availability_schedules" to "authenticated";

grant trigger on table "public"."unit_availability_schedules" to "authenticated";

grant truncate on table "public"."unit_availability_schedules" to "authenticated";

grant update on table "public"."unit_availability_schedules" to "authenticated";

grant delete on table "public"."unit_availability_schedules" to "service_role";

grant insert on table "public"."unit_availability_schedules" to "service_role";

grant references on table "public"."unit_availability_schedules" to "service_role";

grant select on table "public"."unit_availability_schedules" to "service_role";

grant trigger on table "public"."unit_availability_schedules" to "service_role";

grant truncate on table "public"."unit_availability_schedules" to "service_role";

grant update on table "public"."unit_availability_schedules" to "service_role";

grant delete on table "public"."unit_cancellation_policies" to "anon";

grant insert on table "public"."unit_cancellation_policies" to "anon";

grant references on table "public"."unit_cancellation_policies" to "anon";

grant select on table "public"."unit_cancellation_policies" to "anon";

grant trigger on table "public"."unit_cancellation_policies" to "anon";

grant truncate on table "public"."unit_cancellation_policies" to "anon";

grant update on table "public"."unit_cancellation_policies" to "anon";

grant delete on table "public"."unit_cancellation_policies" to "authenticated";

grant insert on table "public"."unit_cancellation_policies" to "authenticated";

grant references on table "public"."unit_cancellation_policies" to "authenticated";

grant select on table "public"."unit_cancellation_policies" to "authenticated";

grant trigger on table "public"."unit_cancellation_policies" to "authenticated";

grant truncate on table "public"."unit_cancellation_policies" to "authenticated";

grant update on table "public"."unit_cancellation_policies" to "authenticated";

grant delete on table "public"."unit_cancellation_policies" to "service_role";

grant insert on table "public"."unit_cancellation_policies" to "service_role";

grant references on table "public"."unit_cancellation_policies" to "service_role";

grant select on table "public"."unit_cancellation_policies" to "service_role";

grant trigger on table "public"."unit_cancellation_policies" to "service_role";

grant truncate on table "public"."unit_cancellation_policies" to "service_role";

grant update on table "public"."unit_cancellation_policies" to "service_role";

grant delete on table "public"."unit_categories" to "anon";

grant insert on table "public"."unit_categories" to "anon";

grant references on table "public"."unit_categories" to "anon";

grant select on table "public"."unit_categories" to "anon";

grant trigger on table "public"."unit_categories" to "anon";

grant truncate on table "public"."unit_categories" to "anon";

grant update on table "public"."unit_categories" to "anon";

grant delete on table "public"."unit_categories" to "authenticated";

grant insert on table "public"."unit_categories" to "authenticated";

grant references on table "public"."unit_categories" to "authenticated";

grant select on table "public"."unit_categories" to "authenticated";

grant trigger on table "public"."unit_categories" to "authenticated";

grant truncate on table "public"."unit_categories" to "authenticated";

grant update on table "public"."unit_categories" to "authenticated";

grant delete on table "public"."unit_categories" to "service_role";

grant insert on table "public"."unit_categories" to "service_role";

grant references on table "public"."unit_categories" to "service_role";

grant select on table "public"."unit_categories" to "service_role";

grant trigger on table "public"."unit_categories" to "service_role";

grant truncate on table "public"."unit_categories" to "service_role";

grant update on table "public"."unit_categories" to "service_role";

grant delete on table "public"."unit_context" to "anon";

grant insert on table "public"."unit_context" to "anon";

grant references on table "public"."unit_context" to "anon";

grant select on table "public"."unit_context" to "anon";

grant trigger on table "public"."unit_context" to "anon";

grant truncate on table "public"."unit_context" to "anon";

grant update on table "public"."unit_context" to "anon";

grant delete on table "public"."unit_context" to "authenticated";

grant insert on table "public"."unit_context" to "authenticated";

grant references on table "public"."unit_context" to "authenticated";

grant select on table "public"."unit_context" to "authenticated";

grant trigger on table "public"."unit_context" to "authenticated";

grant truncate on table "public"."unit_context" to "authenticated";

grant update on table "public"."unit_context" to "authenticated";

grant delete on table "public"."unit_context" to "service_role";

grant insert on table "public"."unit_context" to "service_role";

grant references on table "public"."unit_context" to "service_role";

grant select on table "public"."unit_context" to "service_role";

grant trigger on table "public"."unit_context" to "service_role";

grant truncate on table "public"."unit_context" to "service_role";

grant update on table "public"."unit_context" to "service_role";

grant delete on table "public"."unit_food_options" to "anon";

grant insert on table "public"."unit_food_options" to "anon";

grant references on table "public"."unit_food_options" to "anon";

grant select on table "public"."unit_food_options" to "anon";

grant trigger on table "public"."unit_food_options" to "anon";

grant truncate on table "public"."unit_food_options" to "anon";

grant update on table "public"."unit_food_options" to "anon";

grant delete on table "public"."unit_food_options" to "authenticated";

grant insert on table "public"."unit_food_options" to "authenticated";

grant references on table "public"."unit_food_options" to "authenticated";

grant select on table "public"."unit_food_options" to "authenticated";

grant trigger on table "public"."unit_food_options" to "authenticated";

grant truncate on table "public"."unit_food_options" to "authenticated";

grant update on table "public"."unit_food_options" to "authenticated";

grant delete on table "public"."unit_food_options" to "service_role";

grant insert on table "public"."unit_food_options" to "service_role";

grant references on table "public"."unit_food_options" to "service_role";

grant select on table "public"."unit_food_options" to "service_role";

grant trigger on table "public"."unit_food_options" to "service_role";

grant truncate on table "public"."unit_food_options" to "service_role";

grant update on table "public"."unit_food_options" to "service_role";

grant delete on table "public"."unit_pricing_components" to "anon";

grant insert on table "public"."unit_pricing_components" to "anon";

grant references on table "public"."unit_pricing_components" to "anon";

grant select on table "public"."unit_pricing_components" to "anon";

grant trigger on table "public"."unit_pricing_components" to "anon";

grant truncate on table "public"."unit_pricing_components" to "anon";

grant update on table "public"."unit_pricing_components" to "anon";

grant delete on table "public"."unit_pricing_components" to "authenticated";

grant insert on table "public"."unit_pricing_components" to "authenticated";

grant references on table "public"."unit_pricing_components" to "authenticated";

grant select on table "public"."unit_pricing_components" to "authenticated";

grant trigger on table "public"."unit_pricing_components" to "authenticated";

grant truncate on table "public"."unit_pricing_components" to "authenticated";

grant update on table "public"."unit_pricing_components" to "authenticated";

grant delete on table "public"."unit_pricing_components" to "service_role";

grant insert on table "public"."unit_pricing_components" to "service_role";

grant references on table "public"."unit_pricing_components" to "service_role";

grant select on table "public"."unit_pricing_components" to "service_role";

grant trigger on table "public"."unit_pricing_components" to "service_role";

grant truncate on table "public"."unit_pricing_components" to "service_role";

grant update on table "public"."unit_pricing_components" to "service_role";

grant delete on table "public"."unit_pricing_plans" to "anon";

grant insert on table "public"."unit_pricing_plans" to "anon";

grant references on table "public"."unit_pricing_plans" to "anon";

grant select on table "public"."unit_pricing_plans" to "anon";

grant trigger on table "public"."unit_pricing_plans" to "anon";

grant truncate on table "public"."unit_pricing_plans" to "anon";

grant update on table "public"."unit_pricing_plans" to "anon";

grant delete on table "public"."unit_pricing_plans" to "authenticated";

grant insert on table "public"."unit_pricing_plans" to "authenticated";

grant references on table "public"."unit_pricing_plans" to "authenticated";

grant select on table "public"."unit_pricing_plans" to "authenticated";

grant trigger on table "public"."unit_pricing_plans" to "authenticated";

grant truncate on table "public"."unit_pricing_plans" to "authenticated";

grant update on table "public"."unit_pricing_plans" to "authenticated";

grant delete on table "public"."unit_pricing_plans" to "service_role";

grant insert on table "public"."unit_pricing_plans" to "service_role";

grant references on table "public"."unit_pricing_plans" to "service_role";

grant select on table "public"."unit_pricing_plans" to "service_role";

grant trigger on table "public"."unit_pricing_plans" to "service_role";

grant truncate on table "public"."unit_pricing_plans" to "service_role";

grant update on table "public"."unit_pricing_plans" to "service_role";

grant delete on table "public"."unit_space_configs" to "anon";

grant insert on table "public"."unit_space_configs" to "anon";

grant references on table "public"."unit_space_configs" to "anon";

grant select on table "public"."unit_space_configs" to "anon";

grant trigger on table "public"."unit_space_configs" to "anon";

grant truncate on table "public"."unit_space_configs" to "anon";

grant update on table "public"."unit_space_configs" to "anon";

grant delete on table "public"."unit_space_configs" to "authenticated";

grant insert on table "public"."unit_space_configs" to "authenticated";

grant references on table "public"."unit_space_configs" to "authenticated";

grant select on table "public"."unit_space_configs" to "authenticated";

grant trigger on table "public"."unit_space_configs" to "authenticated";

grant truncate on table "public"."unit_space_configs" to "authenticated";

grant update on table "public"."unit_space_configs" to "authenticated";

grant delete on table "public"."unit_space_configs" to "service_role";

grant insert on table "public"."unit_space_configs" to "service_role";

grant references on table "public"."unit_space_configs" to "service_role";

grant select on table "public"."unit_space_configs" to "service_role";

grant trigger on table "public"."unit_space_configs" to "service_role";

grant truncate on table "public"."unit_space_configs" to "service_role";

grant update on table "public"."unit_space_configs" to "service_role";

grant delete on table "public"."unit_stay_configs" to "anon";

grant insert on table "public"."unit_stay_configs" to "anon";

grant references on table "public"."unit_stay_configs" to "anon";

grant select on table "public"."unit_stay_configs" to "anon";

grant trigger on table "public"."unit_stay_configs" to "anon";

grant truncate on table "public"."unit_stay_configs" to "anon";

grant update on table "public"."unit_stay_configs" to "anon";

grant delete on table "public"."unit_stay_configs" to "authenticated";

grant insert on table "public"."unit_stay_configs" to "authenticated";

grant references on table "public"."unit_stay_configs" to "authenticated";

grant select on table "public"."unit_stay_configs" to "authenticated";

grant trigger on table "public"."unit_stay_configs" to "authenticated";

grant truncate on table "public"."unit_stay_configs" to "authenticated";

grant update on table "public"."unit_stay_configs" to "authenticated";

grant delete on table "public"."unit_stay_configs" to "service_role";

grant insert on table "public"."unit_stay_configs" to "service_role";

grant references on table "public"."unit_stay_configs" to "service_role";

grant select on table "public"."unit_stay_configs" to "service_role";

grant trigger on table "public"."unit_stay_configs" to "service_role";

grant truncate on table "public"."unit_stay_configs" to "service_role";

grant update on table "public"."unit_stay_configs" to "service_role";

grant delete on table "public"."unit_type_catalog" to "anon";

grant insert on table "public"."unit_type_catalog" to "anon";

grant references on table "public"."unit_type_catalog" to "anon";

grant select on table "public"."unit_type_catalog" to "anon";

grant trigger on table "public"."unit_type_catalog" to "anon";

grant truncate on table "public"."unit_type_catalog" to "anon";

grant update on table "public"."unit_type_catalog" to "anon";

grant delete on table "public"."unit_type_catalog" to "authenticated";

grant insert on table "public"."unit_type_catalog" to "authenticated";

grant references on table "public"."unit_type_catalog" to "authenticated";

grant select on table "public"."unit_type_catalog" to "authenticated";

grant trigger on table "public"."unit_type_catalog" to "authenticated";

grant truncate on table "public"."unit_type_catalog" to "authenticated";

grant update on table "public"."unit_type_catalog" to "authenticated";

grant delete on table "public"."unit_type_catalog" to "service_role";

grant insert on table "public"."unit_type_catalog" to "service_role";

grant references on table "public"."unit_type_catalog" to "service_role";

grant select on table "public"."unit_type_catalog" to "service_role";

grant trigger on table "public"."unit_type_catalog" to "service_role";

grant truncate on table "public"."unit_type_catalog" to "service_role";

grant update on table "public"."unit_type_catalog" to "service_role";

grant delete on table "public"."unit_types" to "anon";

grant insert on table "public"."unit_types" to "anon";

grant references on table "public"."unit_types" to "anon";

grant select on table "public"."unit_types" to "anon";

grant trigger on table "public"."unit_types" to "anon";

grant truncate on table "public"."unit_types" to "anon";

grant update on table "public"."unit_types" to "anon";

grant delete on table "public"."unit_types" to "authenticated";

grant insert on table "public"."unit_types" to "authenticated";

grant references on table "public"."unit_types" to "authenticated";

grant select on table "public"."unit_types" to "authenticated";

grant trigger on table "public"."unit_types" to "authenticated";

grant truncate on table "public"."unit_types" to "authenticated";

grant update on table "public"."unit_types" to "authenticated";

grant delete on table "public"."unit_types" to "service_role";

grant insert on table "public"."unit_types" to "service_role";

grant references on table "public"."unit_types" to "service_role";

grant select on table "public"."unit_types" to "service_role";

grant trigger on table "public"."unit_types" to "service_role";

grant truncate on table "public"."unit_types" to "service_role";

grant update on table "public"."unit_types" to "service_role";

grant delete on table "public"."user_profiles" to "anon";

grant insert on table "public"."user_profiles" to "anon";

grant references on table "public"."user_profiles" to "anon";

grant select on table "public"."user_profiles" to "anon";

grant trigger on table "public"."user_profiles" to "anon";

grant truncate on table "public"."user_profiles" to "anon";

grant update on table "public"."user_profiles" to "anon";

grant delete on table "public"."user_profiles" to "authenticated";

grant insert on table "public"."user_profiles" to "authenticated";

grant references on table "public"."user_profiles" to "authenticated";

grant select on table "public"."user_profiles" to "authenticated";

grant trigger on table "public"."user_profiles" to "authenticated";

grant truncate on table "public"."user_profiles" to "authenticated";

grant update on table "public"."user_profiles" to "authenticated";

grant delete on table "public"."user_profiles" to "service_role";

grant insert on table "public"."user_profiles" to "service_role";

grant references on table "public"."user_profiles" to "service_role";

grant select on table "public"."user_profiles" to "service_role";

grant trigger on table "public"."user_profiles" to "service_role";

grant truncate on table "public"."user_profiles" to "service_role";

grant update on table "public"."user_profiles" to "service_role";

grant delete on table "public"."users" to "anon";

grant insert on table "public"."users" to "anon";

grant references on table "public"."users" to "anon";

grant select on table "public"."users" to "anon";

grant trigger on table "public"."users" to "anon";

grant truncate on table "public"."users" to "anon";

grant update on table "public"."users" to "anon";

grant delete on table "public"."users" to "authenticated";

grant insert on table "public"."users" to "authenticated";

grant references on table "public"."users" to "authenticated";

grant select on table "public"."users" to "authenticated";

grant trigger on table "public"."users" to "authenticated";

grant truncate on table "public"."users" to "authenticated";

grant update on table "public"."users" to "authenticated";

grant delete on table "public"."users" to "service_role";

grant insert on table "public"."users" to "service_role";

grant references on table "public"."users" to "service_role";

grant select on table "public"."users" to "service_role";

grant trigger on table "public"."users" to "service_role";

grant truncate on table "public"."users" to "service_role";

grant update on table "public"."users" to "service_role";


  create policy "dev_allow_all_audit_logs"
  on "public"."account_audit_logs"
  as permissive
  for all
  to anon
using (true)
with check (true);



  create policy "dev_full_access_anon_account_audit_logs"
  on "public"."account_audit_logs"
  as permissive
  for all
  to anon
using (true)
with check (true);



  create policy "dev_full_access_anon_account_business_profiles"
  on "public"."account_business_profiles"
  as permissive
  for all
  to anon
using (true)
with check (true);



  create policy "dev_full_access_anon_account_kyc_documents"
  on "public"."account_kyc_documents"
  as permissive
  for all
  to anon
using (true)
with check (true);



  create policy "dev_full_access_anon_account_members"
  on "public"."account_members"
  as permissive
  for all
  to anon
using (true)
with check (true);



  create policy "dev_full_access_anon_account_partners"
  on "public"."account_partners"
  as permissive
  for all
  to anon
using (true)
with check (true);



  create policy "dev_full_access_anon_account_payout_profiles"
  on "public"."account_payout_profiles"
  as permissive
  for all
  to anon
using (true)
with check (true);



  create policy "dev_full_access_anon_account_subscriptions"
  on "public"."account_subscriptions"
  as permissive
  for all
  to anon
using (true)
with check (true);



  create policy "dev_full_access_anon_accounts"
  on "public"."accounts"
  as permissive
  for all
  to anon
using (true)
with check (true);



  create policy "dev_allow_all_addresses"
  on "public"."addresses"
  as permissive
  for all
  to anon
using (true)
with check (true);



  create policy "dev_full_access_anon_addresses"
  on "public"."addresses"
  as permissive
  for all
  to anon
using (true)
with check (true);



  create policy "dev_full_access_anon_amenity_catalog"
  on "public"."amenity_catalog"
  as permissive
  for all
  to anon
using (true)
with check (true);



  create policy "dev_full_access_anon_cancellation_policies"
  on "public"."cancellation_policies"
  as permissive
  for all
  to anon
using (true)
with check (true);



  create policy "dev_full_access_anon_facility_catalog"
  on "public"."facility_catalog"
  as permissive
  for all
  to anon
using (true)
with check (true);



  create policy "dev_full_access_anon_media_assets"
  on "public"."media_assets"
  as permissive
  for all
  to anon
using (true)
with check (true);



  create policy "dev_full_access_anon_media_links"
  on "public"."media_links"
  as permissive
  for all
  to anon
using (true)
with check (true);



  create policy "dev_full_access_anon_plan_limits"
  on "public"."plan_limits"
  as permissive
  for all
  to anon
using (true)
with check (true);



  create policy "dev_allow_all_properties"
  on "public"."properties"
  as permissive
  for all
  to anon
using (true)
with check (true);



  create policy "dev_full_access_anon_properties"
  on "public"."properties"
  as permissive
  for all
  to anon
using (true)
with check (true);



  create policy "dev_full_access_anon_property_addons"
  on "public"."property_addons"
  as permissive
  for all
  to anon
using (true)
with check (true);



  create policy "dev_full_access_anon_property_facilities"
  on "public"."property_facilities"
  as permissive
  for all
  to anon
using (true)
with check (true);



  create policy "dev_allow_all_google_data"
  on "public"."property_google_data"
  as permissive
  for all
  to anon
using (true)
with check (true);



  create policy "dev_allow_all_property_members"
  on "public"."property_members"
  as permissive
  for all
  to anon
using (true)
with check (true);



  create policy "dev_full_access_anon_property_members"
  on "public"."property_members"
  as permissive
  for all
  to anon
using (true)
with check (true);



  create policy "dev_full_access_anon_property_seasons"
  on "public"."property_seasons"
  as permissive
  for all
  to anon
using (true)
with check (true);



  create policy "dev_full_access_anon_property_terrains"
  on "public"."property_terrains"
  as permissive
  for all
  to anon
using (true)
with check (true);



  create policy "dev_full_access_anon_property_transfers"
  on "public"."property_transfers"
  as permissive
  for all
  to anon
using (true)
with check (true);



  create policy "dev_full_access_anon_property_transport_hubs"
  on "public"."property_transport_hubs"
  as permissive
  for all
  to anon
using (true)
with check (true);



  create policy "dev_full_access_anon_property_units"
  on "public"."property_units"
  as permissive
  for all
  to anon
using (true)
with check (true);



  create policy "dev_allow_all_verifications"
  on "public"."property_verifications"
  as permissive
  for all
  to anon
using (true)
with check (true);



  create policy "dev_full_access_anon_property_verifications"
  on "public"."property_verifications"
  as permissive
  for all
  to anon
using (true)
with check (true);



  create policy "dev_full_access_anon_subscription_plans"
  on "public"."subscription_plans"
  as permissive
  for all
  to anon
using (true)
with check (true);



  create policy "dev_full_access_anon_terrain_catalog"
  on "public"."terrain_catalog"
  as permissive
  for all
  to anon
using (true)
with check (true);



  create policy "dev_full_access_anon_unit_amenities"
  on "public"."unit_amenities"
  as permissive
  for all
  to anon
using (true)
with check (true);



  create policy "dev_full_access_anon_unit_availability_exceptions"
  on "public"."unit_availability_exceptions"
  as permissive
  for all
  to anon
using (true)
with check (true);



  create policy "dev_full_access_anon_unit_availability_schedules"
  on "public"."unit_availability_schedules"
  as permissive
  for all
  to anon
using (true)
with check (true);



  create policy "dev_full_access_anon_unit_cancellation_policies"
  on "public"."unit_cancellation_policies"
  as permissive
  for all
  to anon
using (true)
with check (true);



  create policy "dev_full_access_anon_unit_categories"
  on "public"."unit_categories"
  as permissive
  for all
  to anon
using (true)
with check (true);



  create policy "dev_full_access_anon_unit_food_options"
  on "public"."unit_food_options"
  as permissive
  for all
  to anon
using (true)
with check (true);



  create policy "dev_full_access_anon_unit_pricing_plans"
  on "public"."unit_pricing_plans"
  as permissive
  for all
  to anon
using (true)
with check (true);



  create policy "dev_full_access_anon_unit_type_catalog"
  on "public"."unit_type_catalog"
  as permissive
  for all
  to anon
using (true)
with check (true);



  create policy "dev_full_access_anon_user_profiles"
  on "public"."user_profiles"
  as permissive
  for all
  to anon
using (true)
with check (true);



  create policy "dev_full_access_anon_users"
  on "public"."users"
  as permissive
  for all
  to anon
using (true)
with check (true);


CREATE TRIGGER trg_kyc_verified AFTER UPDATE ON public.account_kyc_documents FOR EACH ROW EXECUTE FUNCTION public.kyc_verified_trigger();

CREATE TRIGGER trg_prevent_owner_delete BEFORE DELETE ON public.account_members FOR EACH ROW EXECUTE FUNCTION public.prevent_owner_delete();

CREATE TRIGGER trg_prevent_owner_update BEFORE UPDATE ON public.account_members FOR EACH ROW EXECUTE FUNCTION public.prevent_owner_role_update();

CREATE TRIGGER trg_payout_verified AFTER UPDATE ON public.account_payout_profiles FOR EACH ROW EXECUTE FUNCTION public.payout_verified_trigger();

CREATE TRIGGER account_created_audit AFTER INSERT ON public.accounts FOR EACH ROW EXECUTE FUNCTION public.account_created_trigger();

CREATE TRIGGER trg_account_created AFTER INSERT ON public.accounts FOR EACH ROW EXECUTE FUNCTION public.audit_account_created();

CREATE TRIGGER trg_assign_default_subscription AFTER INSERT ON public.accounts FOR EACH ROW EXECUTE FUNCTION public.assign_default_subscription();

CREATE TRIGGER tr_address_geo_sync BEFORE INSERT OR UPDATE OF latitude, longitude ON public.addresses FOR EACH ROW EXECUTE FUNCTION public.handle_address_geography();

CREATE TRIGGER tr_update_address_location BEFORE INSERT OR UPDATE OF latitude, longitude ON public.addresses FOR EACH ROW EXECUTE FUNCTION public.update_address_location();

CREATE TRIGGER trg_sync_property_location BEFORE INSERT OR UPDATE OF address_id ON public.properties FOR EACH ROW EXECUTE FUNCTION public.sync_property_location();

CREATE TRIGGER trg_user_profiles_updated_at BEFORE UPDATE ON public.user_profiles FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


  create policy "anon 2482c_0"
  on "storage"."objects"
  as permissive
  for select
  to anon, authenticated
using ((bucket_id = 'temp'::text));



  create policy "anon 2482c_1"
  on "storage"."objects"
  as permissive
  for insert
  to anon, authenticated
with check ((bucket_id = 'temp'::text));



  create policy "anon 2482c_2"
  on "storage"."objects"
  as permissive
  for update
  to anon, authenticated
using ((bucket_id = 'temp'::text));



  create policy "anon 2482c_3"
  on "storage"."objects"
  as permissive
  for delete
  to anon, authenticated
using ((bucket_id = 'temp'::text));



