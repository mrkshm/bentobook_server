SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: active_storage_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_attachments (
    id bigint NOT NULL,
    name character varying NOT NULL,
    record_type character varying NOT NULL,
    record_id bigint NOT NULL,
    blob_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL
);


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_attachments_id_seq OWNED BY public.active_storage_attachments.id;


--
-- Name: active_storage_blobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_blobs (
    id bigint NOT NULL,
    key character varying NOT NULL,
    filename character varying NOT NULL,
    content_type character varying,
    metadata text,
    service_name character varying NOT NULL,
    byte_size bigint NOT NULL,
    checksum character varying,
    created_at timestamp(6) without time zone NOT NULL
);


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_blobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_blobs_id_seq OWNED BY public.active_storage_blobs.id;


--
-- Name: active_storage_variant_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_variant_records (
    id bigint NOT NULL,
    blob_id bigint NOT NULL,
    variation_digest character varying NOT NULL
);


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_variant_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_variant_records_id_seq OWNED BY public.active_storage_variant_records.id;


--
-- Name: allowlisted_jwts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.allowlisted_jwts (
    id bigint NOT NULL,
    jti character varying NOT NULL,
    exp timestamp(6) without time zone,
    user_id bigint NOT NULL,
    metadata json,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    aud character varying
);


--
-- Name: allowlisted_jwts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.allowlisted_jwts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: allowlisted_jwts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.allowlisted_jwts_id_seq OWNED BY public.allowlisted_jwts.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contacts (
    id bigint NOT NULL,
    name character varying,
    email character varying,
    city character varying,
    country character varying,
    phone character varying,
    notes text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    organization_id bigint NOT NULL
);


--
-- Name: contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.contacts_id_seq OWNED BY public.contacts.id;


--
-- Name: cuisine_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cuisine_categories (
    id bigint NOT NULL,
    name character varying NOT NULL,
    display_order integer DEFAULT 0,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: cuisine_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cuisine_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cuisine_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cuisine_categories_id_seq OWNED BY public.cuisine_categories.id;


--
-- Name: cuisine_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cuisine_types (
    id bigint NOT NULL,
    name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    display_order integer DEFAULT 0,
    cuisine_category_id bigint NOT NULL
);


--
-- Name: cuisine_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cuisine_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cuisine_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cuisine_types_id_seq OWNED BY public.cuisine_types.id;


--
-- Name: google_restaurants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.google_restaurants (
    id bigint NOT NULL,
    name character varying,
    google_place_id character varying,
    address text,
    latitude numeric(10,8),
    longitude numeric(11,8),
    street character varying,
    street_number character varying,
    postal_code character varying,
    city character varying,
    state character varying,
    country character varying,
    phone_number character varying,
    url character varying,
    business_status character varying,
    google_rating double precision,
    google_ratings_total integer,
    price_level integer,
    opening_hours json,
    google_updated_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    location public.geometry(Point,4326)
);


--
-- Name: google_restaurants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.google_restaurants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: google_restaurants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.google_restaurants_id_seq OWNED BY public.google_restaurants.id;


--
-- Name: images; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.images (
    id bigint NOT NULL,
    imageable_type character varying NOT NULL,
    imageable_id bigint NOT NULL,
    is_cover boolean,
    title character varying,
    description text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: images_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.images_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.images_id_seq OWNED BY public.images.id;


--
-- Name: list_restaurants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.list_restaurants (
    id bigint NOT NULL,
    list_id bigint NOT NULL,
    restaurant_id bigint NOT NULL,
    "position" integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: list_restaurants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.list_restaurants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: list_restaurants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.list_restaurants_id_seq OWNED BY public.list_restaurants.id;


--
-- Name: lists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lists (
    id bigint NOT NULL,
    name character varying NOT NULL,
    description text,
    visibility integer DEFAULT 0,
    premium boolean DEFAULT false,
    "position" integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    organization_id bigint NOT NULL,
    creator_id bigint NOT NULL
);


--
-- Name: lists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lists_id_seq OWNED BY public.lists.id;


--
-- Name: memberships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.memberships (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    organization_id bigint NOT NULL,
    role character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: memberships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.memberships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: memberships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.memberships_id_seq OWNED BY public.memberships.id;


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organizations (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    username character varying,
    name character varying,
    about text,
    email character varying,
    preferred_currency_symbol character varying
);


--
-- Name: organizations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.organizations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.organizations_id_seq OWNED BY public.organizations.id;


--
-- Name: pg_search_documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pg_search_documents (
    id bigint NOT NULL,
    content text,
    searchable_type character varying,
    searchable_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: pg_search_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pg_search_documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pg_search_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pg_search_documents_id_seq OWNED BY public.pg_search_documents.id;


--
-- Name: restaurant_copies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.restaurant_copies (
    id bigint NOT NULL,
    restaurant_id bigint NOT NULL,
    copied_restaurant_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    organization_id bigint NOT NULL
);


--
-- Name: restaurant_copies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.restaurant_copies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: restaurant_copies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.restaurant_copies_id_seq OWNED BY public.restaurant_copies.id;


--
-- Name: restaurants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.restaurants (
    id bigint NOT NULL,
    name character varying,
    address text,
    latitude numeric(10,8),
    longitude numeric(11,8),
    notes text,
    google_restaurant_id bigint,
    cuisine_type_id bigint,
    street character varying,
    street_number character varying,
    postal_code character varying,
    city character varying,
    state character varying,
    country character varying,
    phone_number character varying,
    url character varying,
    business_status character varying,
    rating integer,
    price_level integer,
    opening_hours json,
    favorite boolean DEFAULT false,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    original_restaurant_id bigint,
    organization_id bigint,
    tsv tsvector
);


--
-- Name: restaurants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.restaurants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: restaurants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.restaurants_id_seq OWNED BY public.restaurants.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: shares; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shares (
    id bigint NOT NULL,
    creator_id bigint NOT NULL,
    shareable_type character varying NOT NULL,
    shareable_id bigint NOT NULL,
    permission integer DEFAULT 0,
    status integer DEFAULT 0,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    reshareable boolean DEFAULT true NOT NULL,
    source_organization_id bigint NOT NULL,
    target_organization_id bigint NOT NULL
);


--
-- Name: shares_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.shares_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shares_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.shares_id_seq OWNED BY public.shares.id;


--
-- Name: taggings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.taggings (
    id bigint NOT NULL,
    tag_id bigint,
    taggable_type character varying,
    taggable_id bigint,
    tagger_type character varying,
    tagger_id bigint,
    context character varying(128),
    created_at timestamp without time zone,
    tenant character varying(128)
);


--
-- Name: taggings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.taggings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taggings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.taggings_id_seq OWNED BY public.taggings.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tags (
    id bigint NOT NULL,
    name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    taggings_count integer DEFAULT 0
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tags_id_seq OWNED BY public.tags.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp(6) without time zone,
    remember_created_at timestamp(6) without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp(6) without time zone,
    last_sign_in_at timestamp(6) without time zone,
    current_sign_in_ip character varying,
    last_sign_in_ip character varying,
    confirmation_token character varying,
    confirmed_at timestamp(6) without time zone,
    confirmation_sent_at timestamp(6) without time zone,
    unconfirmed_email character varying,
    failed_attempts integer DEFAULT 0 NOT NULL,
    unlock_token character varying,
    locked_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    language character varying DEFAULT 'en'::character varying,
    theme character varying DEFAULT 'light'::character varying,
    first_name character varying,
    last_name character varying
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: visit_contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.visit_contacts (
    id bigint NOT NULL,
    visit_id bigint NOT NULL,
    contact_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: visit_contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.visit_contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: visit_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.visit_contacts_id_seq OWNED BY public.visit_contacts.id;


--
-- Name: visits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.visits (
    id bigint NOT NULL,
    date date,
    title character varying,
    notes text,
    restaurant_id bigint NOT NULL,
    rating integer,
    price_paid_cents integer,
    price_paid_currency character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    time_of_day time without time zone NOT NULL,
    organization_id bigint NOT NULL
);


--
-- Name: visits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.visits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: visits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.visits_id_seq OWNED BY public.visits.id;


--
-- Name: active_storage_attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments ALTER COLUMN id SET DEFAULT nextval('public.active_storage_attachments_id_seq'::regclass);


--
-- Name: active_storage_blobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs ALTER COLUMN id SET DEFAULT nextval('public.active_storage_blobs_id_seq'::regclass);


--
-- Name: active_storage_variant_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records ALTER COLUMN id SET DEFAULT nextval('public.active_storage_variant_records_id_seq'::regclass);


--
-- Name: allowlisted_jwts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.allowlisted_jwts ALTER COLUMN id SET DEFAULT nextval('public.allowlisted_jwts_id_seq'::regclass);


--
-- Name: contacts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contacts ALTER COLUMN id SET DEFAULT nextval('public.contacts_id_seq'::regclass);


--
-- Name: cuisine_categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cuisine_categories ALTER COLUMN id SET DEFAULT nextval('public.cuisine_categories_id_seq'::regclass);


--
-- Name: cuisine_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cuisine_types ALTER COLUMN id SET DEFAULT nextval('public.cuisine_types_id_seq'::regclass);


--
-- Name: google_restaurants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.google_restaurants ALTER COLUMN id SET DEFAULT nextval('public.google_restaurants_id_seq'::regclass);


--
-- Name: images id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.images ALTER COLUMN id SET DEFAULT nextval('public.images_id_seq'::regclass);


--
-- Name: list_restaurants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.list_restaurants ALTER COLUMN id SET DEFAULT nextval('public.list_restaurants_id_seq'::regclass);


--
-- Name: lists id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lists ALTER COLUMN id SET DEFAULT nextval('public.lists_id_seq'::regclass);


--
-- Name: memberships id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memberships ALTER COLUMN id SET DEFAULT nextval('public.memberships_id_seq'::regclass);


--
-- Name: organizations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations ALTER COLUMN id SET DEFAULT nextval('public.organizations_id_seq'::regclass);


--
-- Name: pg_search_documents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pg_search_documents ALTER COLUMN id SET DEFAULT nextval('public.pg_search_documents_id_seq'::regclass);


--
-- Name: restaurant_copies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restaurant_copies ALTER COLUMN id SET DEFAULT nextval('public.restaurant_copies_id_seq'::regclass);


--
-- Name: restaurants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restaurants ALTER COLUMN id SET DEFAULT nextval('public.restaurants_id_seq'::regclass);


--
-- Name: shares id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shares ALTER COLUMN id SET DEFAULT nextval('public.shares_id_seq'::regclass);


--
-- Name: taggings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.taggings ALTER COLUMN id SET DEFAULT nextval('public.taggings_id_seq'::regclass);


--
-- Name: tags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags ALTER COLUMN id SET DEFAULT nextval('public.tags_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: visit_contacts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.visit_contacts ALTER COLUMN id SET DEFAULT nextval('public.visit_contacts_id_seq'::regclass);


--
-- Name: visits id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.visits ALTER COLUMN id SET DEFAULT nextval('public.visits_id_seq'::regclass);


--
-- Name: active_storage_attachments active_storage_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT active_storage_attachments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_blobs active_storage_blobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs
    ADD CONSTRAINT active_storage_blobs_pkey PRIMARY KEY (id);


--
-- Name: active_storage_variant_records active_storage_variant_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT active_storage_variant_records_pkey PRIMARY KEY (id);


--
-- Name: allowlisted_jwts allowlisted_jwts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.allowlisted_jwts
    ADD CONSTRAINT allowlisted_jwts_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: contacts contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_pkey PRIMARY KEY (id);


--
-- Name: cuisine_categories cuisine_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cuisine_categories
    ADD CONSTRAINT cuisine_categories_pkey PRIMARY KEY (id);


--
-- Name: cuisine_types cuisine_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cuisine_types
    ADD CONSTRAINT cuisine_types_pkey PRIMARY KEY (id);


--
-- Name: google_restaurants google_restaurants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.google_restaurants
    ADD CONSTRAINT google_restaurants_pkey PRIMARY KEY (id);


--
-- Name: images images_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.images
    ADD CONSTRAINT images_pkey PRIMARY KEY (id);


--
-- Name: list_restaurants list_restaurants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.list_restaurants
    ADD CONSTRAINT list_restaurants_pkey PRIMARY KEY (id);


--
-- Name: lists lists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lists
    ADD CONSTRAINT lists_pkey PRIMARY KEY (id);


--
-- Name: memberships memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memberships
    ADD CONSTRAINT memberships_pkey PRIMARY KEY (id);


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: pg_search_documents pg_search_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pg_search_documents
    ADD CONSTRAINT pg_search_documents_pkey PRIMARY KEY (id);


--
-- Name: restaurant_copies restaurant_copies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restaurant_copies
    ADD CONSTRAINT restaurant_copies_pkey PRIMARY KEY (id);


--
-- Name: restaurants restaurants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restaurants
    ADD CONSTRAINT restaurants_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: shares shares_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shares
    ADD CONSTRAINT shares_pkey PRIMARY KEY (id);


--
-- Name: taggings taggings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.taggings
    ADD CONSTRAINT taggings_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: visit_contacts visit_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.visit_contacts
    ADD CONSTRAINT visit_contacts_pkey PRIMARY KEY (id);


--
-- Name: visits visits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.visits
    ADD CONSTRAINT visits_pkey PRIMARY KEY (id);


--
-- Name: index_active_storage_attachments_on_blob_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_storage_attachments_on_blob_id ON public.active_storage_attachments USING btree (blob_id);


--
-- Name: index_active_storage_attachments_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_attachments_uniqueness ON public.active_storage_attachments USING btree (record_type, record_id, name, blob_id);


--
-- Name: index_active_storage_blobs_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_blobs_on_key ON public.active_storage_blobs USING btree (key);


--
-- Name: index_active_storage_variant_records_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_variant_records_uniqueness ON public.active_storage_variant_records USING btree (blob_id, variation_digest);


--
-- Name: index_allowlisted_jwts_on_aud_and_jti; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_allowlisted_jwts_on_aud_and_jti ON public.allowlisted_jwts USING btree (aud, jti);


--
-- Name: index_allowlisted_jwts_on_exp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_allowlisted_jwts_on_exp ON public.allowlisted_jwts USING btree (exp);


--
-- Name: index_allowlisted_jwts_on_jti; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_allowlisted_jwts_on_jti ON public.allowlisted_jwts USING btree (jti);


--
-- Name: index_allowlisted_jwts_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_allowlisted_jwts_on_user_id ON public.allowlisted_jwts USING btree (user_id);


--
-- Name: index_contacts_on_name_and_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_contacts_on_name_and_organization_id ON public.contacts USING btree (name, organization_id);


--
-- Name: index_contacts_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contacts_on_organization_id ON public.contacts USING btree (organization_id);


--
-- Name: index_cuisine_categories_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_cuisine_categories_on_name ON public.cuisine_categories USING btree (name);


--
-- Name: index_cuisine_types_on_cuisine_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cuisine_types_on_cuisine_category_id ON public.cuisine_types USING btree (cuisine_category_id);


--
-- Name: index_cuisine_types_on_display_order; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cuisine_types_on_display_order ON public.cuisine_types USING btree (display_order);


--
-- Name: index_cuisine_types_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_cuisine_types_on_name ON public.cuisine_types USING btree (name);


--
-- Name: index_google_restaurants_on_address; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_google_restaurants_on_address ON public.google_restaurants USING btree (address);


--
-- Name: index_google_restaurants_on_city; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_google_restaurants_on_city ON public.google_restaurants USING btree (city);


--
-- Name: index_google_restaurants_on_google_place_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_google_restaurants_on_google_place_id ON public.google_restaurants USING btree (google_place_id);


--
-- Name: index_google_restaurants_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_google_restaurants_on_id ON public.google_restaurants USING btree (id);


--
-- Name: index_google_restaurants_on_location; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_google_restaurants_on_location ON public.google_restaurants USING gist (location);


--
-- Name: index_google_restaurants_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_google_restaurants_on_name ON public.google_restaurants USING btree (name);


--
-- Name: index_images_on_imageable; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_images_on_imageable ON public.images USING btree (imageable_type, imageable_id);


--
-- Name: index_list_restaurants_on_list_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_list_restaurants_on_list_id ON public.list_restaurants USING btree (list_id);


--
-- Name: index_list_restaurants_on_list_id_and_restaurant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_list_restaurants_on_list_id_and_restaurant_id ON public.list_restaurants USING btree (list_id, restaurant_id);


--
-- Name: index_list_restaurants_on_restaurant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_list_restaurants_on_restaurant_id ON public.list_restaurants USING btree (restaurant_id);


--
-- Name: index_lists_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lists_on_creator_id ON public.lists USING btree (creator_id);


--
-- Name: index_lists_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lists_on_organization_id ON public.lists USING btree (organization_id);


--
-- Name: index_memberships_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_memberships_on_organization_id ON public.memberships USING btree (organization_id);


--
-- Name: index_memberships_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_memberships_on_user_id ON public.memberships USING btree (user_id);


--
-- Name: index_pg_search_documents_on_searchable; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pg_search_documents_on_searchable ON public.pg_search_documents USING btree (searchable_type, searchable_id);


--
-- Name: index_restaurant_copies_on_copied_restaurant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_restaurant_copies_on_copied_restaurant_id ON public.restaurant_copies USING btree (copied_restaurant_id);


--
-- Name: index_restaurant_copies_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_restaurant_copies_on_organization_id ON public.restaurant_copies USING btree (organization_id);


--
-- Name: index_restaurant_copies_on_organization_id_and_restaurant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_restaurant_copies_on_organization_id_and_restaurant_id ON public.restaurant_copies USING btree (organization_id, restaurant_id);


--
-- Name: index_restaurant_copies_on_restaurant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_restaurant_copies_on_restaurant_id ON public.restaurant_copies USING btree (restaurant_id);


--
-- Name: index_restaurants_on_address; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_restaurants_on_address ON public.restaurants USING btree (address);


--
-- Name: index_restaurants_on_business_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_restaurants_on_business_status ON public.restaurants USING btree (business_status);


--
-- Name: index_restaurants_on_city; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_restaurants_on_city ON public.restaurants USING btree (city);


--
-- Name: index_restaurants_on_cuisine_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_restaurants_on_cuisine_type_id ON public.restaurants USING btree (cuisine_type_id);


--
-- Name: index_restaurants_on_favorite; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_restaurants_on_favorite ON public.restaurants USING btree (favorite);


--
-- Name: index_restaurants_on_google_restaurant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_restaurants_on_google_restaurant_id ON public.restaurants USING btree (google_restaurant_id);


--
-- Name: index_restaurants_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_restaurants_on_name ON public.restaurants USING btree (name);


--
-- Name: index_restaurants_on_notes; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_restaurants_on_notes ON public.restaurants USING btree (notes);


--
-- Name: index_restaurants_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_restaurants_on_organization_id ON public.restaurants USING btree (organization_id);


--
-- Name: index_restaurants_on_original_restaurant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_restaurants_on_original_restaurant_id ON public.restaurants USING btree (original_restaurant_id);


--
-- Name: index_shares_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shares_on_creator_id ON public.shares USING btree (creator_id);


--
-- Name: index_shares_on_organizations_and_shareable; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shares_on_organizations_and_shareable ON public.shares USING btree (source_organization_id, target_organization_id, shareable_type, shareable_id);


--
-- Name: index_shares_on_shareable; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shares_on_shareable ON public.shares USING btree (shareable_type, shareable_id);


--
-- Name: index_shares_on_source_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shares_on_source_organization_id ON public.shares USING btree (source_organization_id);


--
-- Name: index_shares_on_target_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shares_on_target_organization_id ON public.shares USING btree (target_organization_id);


--
-- Name: index_taggings_on_context; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_taggings_on_context ON public.taggings USING btree (context);


--
-- Name: index_taggings_on_tag_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_taggings_on_tag_id ON public.taggings USING btree (tag_id);


--
-- Name: index_taggings_on_taggable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_taggings_on_taggable_id ON public.taggings USING btree (taggable_id);


--
-- Name: index_taggings_on_taggable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_taggings_on_taggable_type ON public.taggings USING btree (taggable_type);


--
-- Name: index_taggings_on_taggable_type_and_taggable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_taggings_on_taggable_type_and_taggable_id ON public.taggings USING btree (taggable_type, taggable_id);


--
-- Name: index_taggings_on_tagger_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_taggings_on_tagger_id ON public.taggings USING btree (tagger_id);


--
-- Name: index_taggings_on_tagger_id_and_tagger_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_taggings_on_tagger_id_and_tagger_type ON public.taggings USING btree (tagger_id, tagger_type);


--
-- Name: index_taggings_on_tagger_type_and_tagger_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_taggings_on_tagger_type_and_tagger_id ON public.taggings USING btree (tagger_type, tagger_id);


--
-- Name: index_taggings_on_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_taggings_on_tenant ON public.taggings USING btree (tenant);


--
-- Name: index_tags_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_tags_on_name ON public.tags USING btree (name);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON public.users USING btree (confirmation_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: index_users_on_unlock_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_unlock_token ON public.users USING btree (unlock_token);


--
-- Name: index_visit_contacts_on_contact_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_visit_contacts_on_contact_id ON public.visit_contacts USING btree (contact_id);


--
-- Name: index_visit_contacts_on_visit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_visit_contacts_on_visit_id ON public.visit_contacts USING btree (visit_id);


--
-- Name: index_visits_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_visits_on_organization_id ON public.visits USING btree (organization_id);


--
-- Name: index_visits_on_restaurant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_visits_on_restaurant_id ON public.visits USING btree (restaurant_id);


--
-- Name: restaurants_tsv_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX restaurants_tsv_idx ON public.restaurants USING gin (tsv);


--
-- Name: taggings_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX taggings_idx ON public.taggings USING btree (tag_id, taggable_id, taggable_type, context, tagger_id, tagger_type);


--
-- Name: taggings_idy; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX taggings_idy ON public.taggings USING btree (taggable_id, taggable_type, tagger_id, context);


--
-- Name: taggings_taggable_context_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX taggings_taggable_context_idx ON public.taggings USING btree (taggable_id, taggable_type, context);


--
-- Name: restaurants tsvectorupdate; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE ON public.restaurants FOR EACH ROW EXECUTE FUNCTION tsvector_update_trigger('tsv', 'pg_catalog.english', 'name', 'address');


--
-- Name: list_restaurants fk_list_restaurants_list; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.list_restaurants
    ADD CONSTRAINT fk_list_restaurants_list FOREIGN KEY (list_id) REFERENCES public.lists(id) ON DELETE CASCADE;


--
-- Name: list_restaurants fk_list_restaurants_restaurant; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.list_restaurants
    ADD CONSTRAINT fk_list_restaurants_restaurant FOREIGN KEY (restaurant_id) REFERENCES public.restaurants(id) ON DELETE CASCADE;


--
-- Name: restaurant_copies fk_rails_0ee957d258; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restaurant_copies
    ADD CONSTRAINT fk_rails_0ee957d258 FOREIGN KEY (copied_restaurant_id) REFERENCES public.restaurants(id);


--
-- Name: restaurants fk_rails_1289b51deb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restaurants
    ADD CONSTRAINT fk_rails_1289b51deb FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: cuisine_types fk_rails_2c9f9d97a8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cuisine_types
    ADD CONSTRAINT fk_rails_2c9f9d97a8 FOREIGN KEY (cuisine_category_id) REFERENCES public.cuisine_categories(id);


--
-- Name: restaurant_copies fk_rails_3ea502fa9a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restaurant_copies
    ADD CONSTRAINT fk_rails_3ea502fa9a FOREIGN KEY (restaurant_id) REFERENCES public.restaurants(id);


--
-- Name: shares fk_rails_434dff91a6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shares
    ADD CONSTRAINT fk_rails_434dff91a6 FOREIGN KEY (source_organization_id) REFERENCES public.organizations(id);


--
-- Name: shares fk_rails_5d388a8a85; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shares
    ADD CONSTRAINT fk_rails_5d388a8a85 FOREIGN KEY (creator_id) REFERENCES public.users(id);


--
-- Name: memberships fk_rails_64267aab58; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memberships
    ADD CONSTRAINT fk_rails_64267aab58 FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: restaurants fk_rails_6459e3b9d7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restaurants
    ADD CONSTRAINT fk_rails_6459e3b9d7 FOREIGN KEY (google_restaurant_id) REFERENCES public.google_restaurants(id);


--
-- Name: visits fk_rails_6efda2cfb2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.visits
    ADD CONSTRAINT fk_rails_6efda2cfb2 FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: restaurant_copies fk_rails_6f10117c5e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restaurant_copies
    ADD CONSTRAINT fk_rails_6f10117c5e FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: allowlisted_jwts fk_rails_77afa78cd5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.allowlisted_jwts
    ADD CONSTRAINT fk_rails_77afa78cd5 FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: memberships fk_rails_99326fb65d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memberships
    ADD CONSTRAINT fk_rails_99326fb65d FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: active_storage_variant_records fk_rails_993965df05; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT fk_rails_993965df05 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: taggings fk_rails_9fcd2e236b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.taggings
    ADD CONSTRAINT fk_rails_9fcd2e236b FOREIGN KEY (tag_id) REFERENCES public.tags(id);


--
-- Name: visits fk_rails_9feab3f441; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.visits
    ADD CONSTRAINT fk_rails_9feab3f441 FOREIGN KEY (restaurant_id) REFERENCES public.restaurants(id);


--
-- Name: lists fk_rails_aee8c45fb9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lists
    ADD CONSTRAINT fk_rails_aee8c45fb9 FOREIGN KEY (creator_id) REFERENCES public.users(id);


--
-- Name: visit_contacts fk_rails_b4070a404c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.visit_contacts
    ADD CONSTRAINT fk_rails_b4070a404c FOREIGN KEY (contact_id) REFERENCES public.contacts(id);


--
-- Name: contacts fk_rails_b7db93c1c3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT fk_rails_b7db93c1c3 FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: restaurants fk_rails_c2e9970bf8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restaurants
    ADD CONSTRAINT fk_rails_c2e9970bf8 FOREIGN KEY (cuisine_type_id) REFERENCES public.cuisine_types(id);


--
-- Name: active_storage_attachments fk_rails_c3b3935057; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT fk_rails_c3b3935057 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: list_restaurants fk_rails_c63a738d79; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.list_restaurants
    ADD CONSTRAINT fk_rails_c63a738d79 FOREIGN KEY (restaurant_id) REFERENCES public.restaurants(id);


--
-- Name: restaurants fk_rails_cd30f1f5a1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restaurants
    ADD CONSTRAINT fk_rails_cd30f1f5a1 FOREIGN KEY (original_restaurant_id) REFERENCES public.restaurants(id);


--
-- Name: lists fk_rails_dff59680c7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lists
    ADD CONSTRAINT fk_rails_dff59680c7 FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: list_restaurants fk_rails_e68366fbf6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.list_restaurants
    ADD CONSTRAINT fk_rails_e68366fbf6 FOREIGN KEY (list_id) REFERENCES public.lists(id);


--
-- Name: visit_contacts fk_rails_f5c4153bfb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.visit_contacts
    ADD CONSTRAINT fk_rails_f5c4153bfb FOREIGN KEY (visit_id) REFERENCES public.visits(id);


--
-- Name: shares fk_rails_f921f753a8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shares
    ADD CONSTRAINT fk_rails_f921f753a8 FOREIGN KEY (target_organization_id) REFERENCES public.organizations(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20250704143511'),
('20250630154325'),
('20250624133403'),
('20250624132727'),
('20250624130031'),
('20250624125433'),
('20250624123817'),
('20250624123753'),
('20250411153415'),
('20250411153403'),
('20250411153340'),
('20250410085443'),
('20250409092831'),
('20250409092723'),
('20250409091829'),
('20250407143100'),
('20250405165559'),
('20250404133041'),
('20250404124930'),
('20250404124651'),
('20250404124537'),
('20250404112449'),
('20250404091747'),
('20250404091131'),
('20250403223501'),
('20250403223500'),
('20250403210140'),
('20250403210139'),
('20250403210138'),
('20250403150436'),
('20250403140909'),
('20250403140810'),
('20250403140711'),
('20250319140828'),
('20241129140719'),
('20241122082306'),
('20241121201805'),
('20241120092910'),
('20241120092858'),
('20241114110224'),
('20241111083840'),
('20241105103121'),
('20241103172330'),
('20241005155941'),
('20241005155817'),
('20241005155763'),
('20241005155762'),
('20241005155761'),
('20241005155760'),
('20241005155759'),
('20241005155758'),
('20241005155757'),
('20241005154422'),
('20241005154410'),
('20241005154400'),
('20241005154343'),
('20241005154223'),
('20241005153816'),
('20241005153558'),
('20241005153514'),
('20241005153458'),
('20241005153435'),
('20241005151426');

