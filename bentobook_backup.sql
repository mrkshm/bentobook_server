--
-- PostgreSQL database dump
--

-- Dumped from database version 16.4 (Debian 16.4-1.pgdg110+2)
-- Dumped by pg_dump version 16.4 (Debian 16.4-1.pgdg110+2)

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
-- Name: tiger; Type: SCHEMA; Schema: -; Owner: bentobook
--

CREATE SCHEMA tiger;


ALTER SCHEMA tiger OWNER TO bentobook;

--
-- Name: tiger_data; Type: SCHEMA; Schema: -; Owner: bentobook
--

CREATE SCHEMA tiger_data;


ALTER SCHEMA tiger_data OWNER TO bentobook;

--
-- Name: topology; Type: SCHEMA; Schema: -; Owner: bentobook
--

CREATE SCHEMA topology;


ALTER SCHEMA topology OWNER TO bentobook;

--
-- Name: SCHEMA topology; Type: COMMENT; Schema: -; Owner: bentobook
--

COMMENT ON SCHEMA topology IS 'PostGIS Topology schema';


--
-- Name: fuzzystrmatch; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;


--
-- Name: EXTENSION fuzzystrmatch; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- Name: postgis_tiger_geocoder; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder WITH SCHEMA tiger;


--
-- Name: EXTENSION postgis_tiger_geocoder; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis_tiger_geocoder IS 'PostGIS tiger geocoder and reverse geocoder';


--
-- Name: postgis_topology; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_topology WITH SCHEMA topology;


--
-- Name: EXTENSION postgis_topology; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis_topology IS 'PostGIS topology spatial types and functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: active_storage_attachments; Type: TABLE; Schema: public; Owner: bentobook
--

CREATE TABLE public.active_storage_attachments (
    id bigint NOT NULL,
    name character varying NOT NULL,
    record_type character varying NOT NULL,
    record_id bigint NOT NULL,
    blob_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.active_storage_attachments OWNER TO bentobook;

--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: bentobook
--

CREATE SEQUENCE public.active_storage_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.active_storage_attachments_id_seq OWNER TO bentobook;

--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bentobook
--

ALTER SEQUENCE public.active_storage_attachments_id_seq OWNED BY public.active_storage_attachments.id;


--
-- Name: active_storage_blobs; Type: TABLE; Schema: public; Owner: bentobook
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


ALTER TABLE public.active_storage_blobs OWNER TO bentobook;

--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE; Schema: public; Owner: bentobook
--

CREATE SEQUENCE public.active_storage_blobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.active_storage_blobs_id_seq OWNER TO bentobook;

--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bentobook
--

ALTER SEQUENCE public.active_storage_blobs_id_seq OWNED BY public.active_storage_blobs.id;


--
-- Name: active_storage_variant_records; Type: TABLE; Schema: public; Owner: bentobook
--

CREATE TABLE public.active_storage_variant_records (
    id bigint NOT NULL,
    blob_id bigint NOT NULL,
    variation_digest character varying NOT NULL
);


ALTER TABLE public.active_storage_variant_records OWNER TO bentobook;

--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE; Schema: public; Owner: bentobook
--

CREATE SEQUENCE public.active_storage_variant_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.active_storage_variant_records_id_seq OWNER TO bentobook;

--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bentobook
--

ALTER SEQUENCE public.active_storage_variant_records_id_seq OWNED BY public.active_storage_variant_records.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: bentobook
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.ar_internal_metadata OWNER TO bentobook;

--
-- Name: contacts; Type: TABLE; Schema: public; Owner: bentobook
--

CREATE TABLE public.contacts (
    id bigint NOT NULL,
    name character varying,
    email character varying,
    city character varying,
    country character varying,
    phone character varying,
    notes text,
    user_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.contacts OWNER TO bentobook;

--
-- Name: contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: bentobook
--

CREATE SEQUENCE public.contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.contacts_id_seq OWNER TO bentobook;

--
-- Name: contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bentobook
--

ALTER SEQUENCE public.contacts_id_seq OWNED BY public.contacts.id;


--
-- Name: cuisine_types; Type: TABLE; Schema: public; Owner: bentobook
--

CREATE TABLE public.cuisine_types (
    id bigint NOT NULL,
    name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.cuisine_types OWNER TO bentobook;

--
-- Name: cuisine_types_id_seq; Type: SEQUENCE; Schema: public; Owner: bentobook
--

CREATE SEQUENCE public.cuisine_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cuisine_types_id_seq OWNER TO bentobook;

--
-- Name: cuisine_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bentobook
--

ALTER SEQUENCE public.cuisine_types_id_seq OWNED BY public.cuisine_types.id;


--
-- Name: google_restaurants; Type: TABLE; Schema: public; Owner: bentobook
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


ALTER TABLE public.google_restaurants OWNER TO bentobook;

--
-- Name: google_restaurants_id_seq; Type: SEQUENCE; Schema: public; Owner: bentobook
--

CREATE SEQUENCE public.google_restaurants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.google_restaurants_id_seq OWNER TO bentobook;

--
-- Name: google_restaurants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bentobook
--

ALTER SEQUENCE public.google_restaurants_id_seq OWNED BY public.google_restaurants.id;


--
-- Name: images; Type: TABLE; Schema: public; Owner: bentobook
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


ALTER TABLE public.images OWNER TO bentobook;

--
-- Name: images_id_seq; Type: SEQUENCE; Schema: public; Owner: bentobook
--

CREATE SEQUENCE public.images_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.images_id_seq OWNER TO bentobook;

--
-- Name: images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bentobook
--

ALTER SEQUENCE public.images_id_seq OWNED BY public.images.id;


--
-- Name: list_restaurants; Type: TABLE; Schema: public; Owner: bentobook
--

CREATE TABLE public.list_restaurants (
    id bigint NOT NULL,
    list_id bigint NOT NULL,
    restaurant_id bigint NOT NULL,
    "position" integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.list_restaurants OWNER TO bentobook;

--
-- Name: list_restaurants_id_seq; Type: SEQUENCE; Schema: public; Owner: bentobook
--

CREATE SEQUENCE public.list_restaurants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.list_restaurants_id_seq OWNER TO bentobook;

--
-- Name: list_restaurants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bentobook
--

ALTER SEQUENCE public.list_restaurants_id_seq OWNED BY public.list_restaurants.id;


--
-- Name: lists; Type: TABLE; Schema: public; Owner: bentobook
--

CREATE TABLE public.lists (
    id bigint NOT NULL,
    name character varying NOT NULL,
    description text,
    owner_type character varying NOT NULL,
    owner_id bigint NOT NULL,
    visibility integer DEFAULT 0,
    premium boolean DEFAULT false,
    "position" integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.lists OWNER TO bentobook;

--
-- Name: lists_id_seq; Type: SEQUENCE; Schema: public; Owner: bentobook
--

CREATE SEQUENCE public.lists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lists_id_seq OWNER TO bentobook;

--
-- Name: lists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bentobook
--

ALTER SEQUENCE public.lists_id_seq OWNED BY public.lists.id;


--
-- Name: memberships; Type: TABLE; Schema: public; Owner: bentobook
--

CREATE TABLE public.memberships (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    organization_id bigint NOT NULL,
    role character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.memberships OWNER TO bentobook;

--
-- Name: memberships_id_seq; Type: SEQUENCE; Schema: public; Owner: bentobook
--

CREATE SEQUENCE public.memberships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.memberships_id_seq OWNER TO bentobook;

--
-- Name: memberships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bentobook
--

ALTER SEQUENCE public.memberships_id_seq OWNED BY public.memberships.id;


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: bentobook
--

CREATE TABLE public.organizations (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.organizations OWNER TO bentobook;

--
-- Name: organizations_id_seq; Type: SEQUENCE; Schema: public; Owner: bentobook
--

CREATE SEQUENCE public.organizations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.organizations_id_seq OWNER TO bentobook;

--
-- Name: organizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bentobook
--

ALTER SEQUENCE public.organizations_id_seq OWNED BY public.organizations.id;


--
-- Name: pg_search_documents; Type: TABLE; Schema: public; Owner: bentobook
--

CREATE TABLE public.pg_search_documents (
    id bigint NOT NULL,
    content text,
    searchable_type character varying,
    searchable_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.pg_search_documents OWNER TO bentobook;

--
-- Name: pg_search_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: bentobook
--

CREATE SEQUENCE public.pg_search_documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pg_search_documents_id_seq OWNER TO bentobook;

--
-- Name: pg_search_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bentobook
--

ALTER SEQUENCE public.pg_search_documents_id_seq OWNED BY public.pg_search_documents.id;


--
-- Name: profiles; Type: TABLE; Schema: public; Owner: bentobook
--

CREATE TABLE public.profiles (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    username character varying,
    first_name character varying,
    last_name character varying,
    about text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    preferred_language character varying DEFAULT 'en'::character varying,
    preferred_theme character varying DEFAULT 'light'::character varying
);


ALTER TABLE public.profiles OWNER TO bentobook;

--
-- Name: profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: bentobook
--

CREATE SEQUENCE public.profiles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.profiles_id_seq OWNER TO bentobook;

--
-- Name: profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bentobook
--

ALTER SEQUENCE public.profiles_id_seq OWNED BY public.profiles.id;


--
-- Name: restaurant_copies; Type: TABLE; Schema: public; Owner: bentobook
--

CREATE TABLE public.restaurant_copies (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    restaurant_id bigint NOT NULL,
    copied_restaurant_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.restaurant_copies OWNER TO bentobook;

--
-- Name: restaurant_copies_id_seq; Type: SEQUENCE; Schema: public; Owner: bentobook
--

CREATE SEQUENCE public.restaurant_copies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.restaurant_copies_id_seq OWNER TO bentobook;

--
-- Name: restaurant_copies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bentobook
--

ALTER SEQUENCE public.restaurant_copies_id_seq OWNED BY public.restaurant_copies.id;


--
-- Name: restaurants; Type: TABLE; Schema: public; Owner: bentobook
--

CREATE TABLE public.restaurants (
    id bigint NOT NULL,
    name character varying,
    address text,
    latitude numeric(10,8),
    longitude numeric(11,8),
    notes text,
    user_id bigint,
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
    original_restaurant_id bigint
);


ALTER TABLE public.restaurants OWNER TO bentobook;

--
-- Name: restaurants_id_seq; Type: SEQUENCE; Schema: public; Owner: bentobook
--

CREATE SEQUENCE public.restaurants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.restaurants_id_seq OWNER TO bentobook;

--
-- Name: restaurants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bentobook
--

ALTER SEQUENCE public.restaurants_id_seq OWNED BY public.restaurants.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: bentobook
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


ALTER TABLE public.schema_migrations OWNER TO bentobook;

--
-- Name: shares; Type: TABLE; Schema: public; Owner: bentobook
--

CREATE TABLE public.shares (
    id bigint NOT NULL,
    creator_id bigint NOT NULL,
    recipient_id bigint NOT NULL,
    shareable_type character varying NOT NULL,
    shareable_id bigint NOT NULL,
    permission integer DEFAULT 0,
    status integer DEFAULT 0,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    reshareable boolean DEFAULT true NOT NULL
);


ALTER TABLE public.shares OWNER TO bentobook;

--
-- Name: shares_id_seq; Type: SEQUENCE; Schema: public; Owner: bentobook
--

CREATE SEQUENCE public.shares_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.shares_id_seq OWNER TO bentobook;

--
-- Name: shares_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bentobook
--

ALTER SEQUENCE public.shares_id_seq OWNED BY public.shares.id;


--
-- Name: taggings; Type: TABLE; Schema: public; Owner: bentobook
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


ALTER TABLE public.taggings OWNER TO bentobook;

--
-- Name: taggings_id_seq; Type: SEQUENCE; Schema: public; Owner: bentobook
--

CREATE SEQUENCE public.taggings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.taggings_id_seq OWNER TO bentobook;

--
-- Name: taggings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bentobook
--

ALTER SEQUENCE public.taggings_id_seq OWNED BY public.taggings.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: bentobook
--

CREATE TABLE public.tags (
    id bigint NOT NULL,
    name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    taggings_count integer DEFAULT 0
);


ALTER TABLE public.tags OWNER TO bentobook;

--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: bentobook
--

CREATE SEQUENCE public.tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tags_id_seq OWNER TO bentobook;

--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bentobook
--

ALTER SEQUENCE public.tags_id_seq OWNED BY public.tags.id;


--
-- Name: user_sessions; Type: TABLE; Schema: public; Owner: bentobook
--

CREATE TABLE public.user_sessions (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    jti character varying NOT NULL,
    client_name character varying NOT NULL,
    last_used_at timestamp(6) without time zone NOT NULL,
    ip_address character varying,
    user_agent character varying,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    device_type character varying,
    os_name character varying,
    os_version character varying,
    browser_name character varying,
    browser_version character varying,
    last_ip_address character varying,
    location_country character varying,
    suspicious boolean DEFAULT false
);


ALTER TABLE public.user_sessions OWNER TO bentobook;

--
-- Name: user_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: bentobook
--

CREATE SEQUENCE public.user_sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_sessions_id_seq OWNER TO bentobook;

--
-- Name: user_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bentobook
--

ALTER SEQUENCE public.user_sessions_id_seq OWNED BY public.user_sessions.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: bentobook
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
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.users OWNER TO bentobook;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: bentobook
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO bentobook;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bentobook
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: visit_contacts; Type: TABLE; Schema: public; Owner: bentobook
--

CREATE TABLE public.visit_contacts (
    id bigint NOT NULL,
    visit_id bigint NOT NULL,
    contact_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.visit_contacts OWNER TO bentobook;

--
-- Name: visit_contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: bentobook
--

CREATE SEQUENCE public.visit_contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.visit_contacts_id_seq OWNER TO bentobook;

--
-- Name: visit_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bentobook
--

ALTER SEQUENCE public.visit_contacts_id_seq OWNED BY public.visit_contacts.id;


--
-- Name: visits; Type: TABLE; Schema: public; Owner: bentobook
--

CREATE TABLE public.visits (
    id bigint NOT NULL,
    date date,
    title character varying,
    notes text,
    user_id bigint NOT NULL,
    restaurant_id bigint NOT NULL,
    rating integer,
    price_paid_cents integer,
    price_paid_currency character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    time_of_day time without time zone NOT NULL
);


ALTER TABLE public.visits OWNER TO bentobook;

--
-- Name: visits_id_seq; Type: SEQUENCE; Schema: public; Owner: bentobook
--

CREATE SEQUENCE public.visits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.visits_id_seq OWNER TO bentobook;

--
-- Name: visits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bentobook
--

ALTER SEQUENCE public.visits_id_seq OWNED BY public.visits.id;


--
-- Name: active_storage_attachments id; Type: DEFAULT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.active_storage_attachments ALTER COLUMN id SET DEFAULT nextval('public.active_storage_attachments_id_seq'::regclass);


--
-- Name: active_storage_blobs id; Type: DEFAULT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.active_storage_blobs ALTER COLUMN id SET DEFAULT nextval('public.active_storage_blobs_id_seq'::regclass);


--
-- Name: active_storage_variant_records id; Type: DEFAULT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.active_storage_variant_records ALTER COLUMN id SET DEFAULT nextval('public.active_storage_variant_records_id_seq'::regclass);


--
-- Name: contacts id; Type: DEFAULT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.contacts ALTER COLUMN id SET DEFAULT nextval('public.contacts_id_seq'::regclass);


--
-- Name: cuisine_types id; Type: DEFAULT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.cuisine_types ALTER COLUMN id SET DEFAULT nextval('public.cuisine_types_id_seq'::regclass);


--
-- Name: google_restaurants id; Type: DEFAULT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.google_restaurants ALTER COLUMN id SET DEFAULT nextval('public.google_restaurants_id_seq'::regclass);


--
-- Name: images id; Type: DEFAULT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.images ALTER COLUMN id SET DEFAULT nextval('public.images_id_seq'::regclass);


--
-- Name: list_restaurants id; Type: DEFAULT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.list_restaurants ALTER COLUMN id SET DEFAULT nextval('public.list_restaurants_id_seq'::regclass);


--
-- Name: lists id; Type: DEFAULT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.lists ALTER COLUMN id SET DEFAULT nextval('public.lists_id_seq'::regclass);


--
-- Name: memberships id; Type: DEFAULT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.memberships ALTER COLUMN id SET DEFAULT nextval('public.memberships_id_seq'::regclass);


--
-- Name: organizations id; Type: DEFAULT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.organizations ALTER COLUMN id SET DEFAULT nextval('public.organizations_id_seq'::regclass);


--
-- Name: pg_search_documents id; Type: DEFAULT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.pg_search_documents ALTER COLUMN id SET DEFAULT nextval('public.pg_search_documents_id_seq'::regclass);


--
-- Name: profiles id; Type: DEFAULT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.profiles ALTER COLUMN id SET DEFAULT nextval('public.profiles_id_seq'::regclass);


--
-- Name: restaurant_copies id; Type: DEFAULT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.restaurant_copies ALTER COLUMN id SET DEFAULT nextval('public.restaurant_copies_id_seq'::regclass);


--
-- Name: restaurants id; Type: DEFAULT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.restaurants ALTER COLUMN id SET DEFAULT nextval('public.restaurants_id_seq'::regclass);


--
-- Name: shares id; Type: DEFAULT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.shares ALTER COLUMN id SET DEFAULT nextval('public.shares_id_seq'::regclass);


--
-- Name: taggings id; Type: DEFAULT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.taggings ALTER COLUMN id SET DEFAULT nextval('public.taggings_id_seq'::regclass);


--
-- Name: tags id; Type: DEFAULT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.tags ALTER COLUMN id SET DEFAULT nextval('public.tags_id_seq'::regclass);


--
-- Name: user_sessions id; Type: DEFAULT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.user_sessions ALTER COLUMN id SET DEFAULT nextval('public.user_sessions_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: visit_contacts id; Type: DEFAULT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.visit_contacts ALTER COLUMN id SET DEFAULT nextval('public.visit_contacts_id_seq'::regclass);


--
-- Name: visits id; Type: DEFAULT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.visits ALTER COLUMN id SET DEFAULT nextval('public.visits_id_seq'::regclass);


--
-- Data for Name: active_storage_attachments; Type: TABLE DATA; Schema: public; Owner: bentobook
--

COPY public.active_storage_attachments (id, name, record_type, record_id, blob_id, created_at) FROM stdin;
177	image	ActiveStorage::VariantRecord	145	182	2025-03-02 09:55:02.936286
2	avatar	Profile	12	3	2024-11-16 21:34:13.138656
180	image	ActiveStorage::VariantRecord	148	185	2025-03-02 09:56:20.255302
188	image	ActiveStorage::VariantRecord	157	193	2025-03-02 09:56:54.320385
191	image	ActiveStorage::VariantRecord	160	196	2025-03-02 09:56:54.600624
195	image	ActiveStorage::VariantRecord	163	200	2025-03-03 13:10:39.848635
201	avatar	Profile	3	206	2025-03-16 13:17:35.411165
11	file	Image	1	14	2024-11-28 12:16:19.545772
12	file	Image	2	15	2024-11-28 12:16:20.457543
13	file	Image	3	16	2024-11-28 12:16:20.934641
207	avatar	Contact	8	212	2025-03-16 13:26:43.61397
212	image	ActiveStorage::VariantRecord	173	217	2025-03-16 14:29:15.930824
222	image	ActiveStorage::VariantRecord	183	227	2025-03-16 14:29:21.232392
225	image	ActiveStorage::VariantRecord	186	230	2025-03-16 14:29:21.547604
226	image	ActiveStorage::VariantRecord	187	231	2025-03-16 14:29:22.587853
231	image	ActiveStorage::VariantRecord	191	236	2025-03-19 15:41:46.278236
232	image	ActiveStorage::VariantRecord	192	237	2025-03-19 15:41:53.271809
237	image	ActiveStorage::VariantRecord	197	242	2025-03-20 17:08:58.877244
243	avatar	Contact	11	248	2025-03-20 17:28:23.903512
23	file	Image	4	26	2024-11-28 13:17:07.876406
24	file	Image	5	27	2024-11-28 13:17:09.001806
25	file	Image	6	28	2024-11-28 13:17:09.547497
246	image	ActiveStorage::VariantRecord	202	251	2025-03-20 21:07:40.615114
250	image	ActiveStorage::VariantRecord	205	255	2025-03-21 08:34:00.752296
252	image	ActiveStorage::VariantRecord	207	257	2025-03-21 08:34:02.103566
255	image	ActiveStorage::VariantRecord	210	260	2025-03-24 10:23:04.79263
261	image	ActiveStorage::VariantRecord	213	266	2025-03-28 08:51:37.924882
263	image	ActiveStorage::VariantRecord	215	268	2025-03-28 08:51:38.753972
264	image	ActiveStorage::VariantRecord	216	269	2025-03-28 08:51:41.30958
266	image	ActiveStorage::VariantRecord	218	271	2025-03-28 08:51:45.911622
272	image	ActiveStorage::VariantRecord	221	277	2025-03-28 08:55:06.41707
276	image	ActiveStorage::VariantRecord	224	281	2025-03-29 13:23:17.685308
43	file	Image	7	48	2024-12-02 18:03:46.67843
46	file	Image	8	51	2024-12-02 19:35:40.501471
49	file	Image	9	54	2024-12-02 21:20:57.522183
55	file	Image	10	60	2024-12-17 22:35:32.029363
56	file	Image	11	61	2024-12-17 22:35:33.039221
57	file	Image	12	62	2024-12-17 22:35:33.484564
83	avatar	Contact	5	88	2025-02-10 17:51:55.393285
85	avatar	Contact	6	90	2025-02-10 18:01:32.863163
89	file	Image	13	94	2025-02-10 18:04:16.986085
90	file	Image	14	95	2025-02-10 18:04:17.786224
178	image	ActiveStorage::VariantRecord	146	183	2025-03-02 09:56:20.099329
181	image	ActiveStorage::VariantRecord	149	186	2025-03-02 09:56:20.291448
95	file	Image	15	100	2025-02-10 18:06:03.152498
185	image	ActiveStorage::VariantRecord	154	190	2025-03-02 09:56:51.669941
97	file	Image	16	102	2025-02-10 18:07:46.941252
98	file	Image	17	103	2025-02-10 18:07:47.472203
186	image	ActiveStorage::VariantRecord	155	191	2025-03-02 09:56:52.675411
190	image	ActiveStorage::VariantRecord	159	195	2025-03-02 09:56:54.53727
192	image	ActiveStorage::VariantRecord	161	197	2025-03-03 13:10:37.911622
193	image	ActiveStorage::VariantRecord	162	198	2025-03-03 13:10:39.052497
197	image	ActiveStorage::VariantRecord	166	202	2025-03-03 13:10:44.485657
198	image	ActiveStorage::VariantRecord	167	203	2025-03-03 23:12:27.85257
202	avatar	Contact	2	207	2025-03-16 13:18:20.731272
206	avatar	Contact	3	211	2025-03-16 13:23:41.566746
208	avatar	Contact	9	213	2025-03-16 13:27:52.778792
209	image	ActiveStorage::VariantRecord	170	214	2025-03-16 14:29:14.080891
210	image	ActiveStorage::VariantRecord	171	215	2025-03-16 14:29:15.781308
213	image	ActiveStorage::VariantRecord	174	218	2025-03-16 14:29:16.071008
214	image	ActiveStorage::VariantRecord	175	219	2025-03-16 14:29:16.15726
215	image	ActiveStorage::VariantRecord	176	220	2025-03-16 14:29:16.657311
216	image	ActiveStorage::VariantRecord	177	221	2025-03-16 14:29:16.687762
218	image	ActiveStorage::VariantRecord	179	223	2025-03-16 14:29:17.537641
219	image	ActiveStorage::VariantRecord	180	224	2025-03-16 14:29:18.236518
229	image	ActiveStorage::VariantRecord	190	234	2025-03-16 14:39:11.874414
233	image	ActiveStorage::VariantRecord	193	238	2025-03-19 18:43:40.878529
235	image	ActiveStorage::VariantRecord	195	240	2025-03-19 18:43:45.170352
238	avatar	Contact	1	243	2025-03-20 17:22:11.795625
239	file	Image	26	244	2025-03-20 17:26:57.261766
240	file	Image	27	245	2025-03-20 17:26:57.693493
242	image	ActiveStorage::VariantRecord	199	247	2025-03-20 17:27:05.149534
244	image	ActiveStorage::VariantRecord	200	249	2025-03-20 17:54:10.983198
247	file	Image	28	252	2025-03-21 08:30:29.54459
251	image	ActiveStorage::VariantRecord	206	256	2025-03-21 08:34:00.915207
253	image	ActiveStorage::VariantRecord	208	258	2025-03-24 10:23:04.539823
256	image	ActiveStorage::VariantRecord	211	261	2025-03-24 10:23:05.69138
257	image	ActiveStorage::VariantRecord	212	262	2025-03-24 10:23:16.794119
267	file	Image	32	272	2025-03-28 08:54:57.669178
268	file	Image	33	273	2025-03-28 08:54:58.12568
269	file	Image	34	274	2025-03-28 08:54:58.351351
270	image	ActiveStorage::VariantRecord	219	275	2025-03-28 08:55:04.981177
271	image	ActiveStorage::VariantRecord	220	276	2025-03-28 08:55:06.080843
273	avatar	Contact	12	278	2025-03-28 09:00:05.141703
179	image	ActiveStorage::VariantRecord	147	184	2025-03-02 09:56:20.12977
182	image	ActiveStorage::VariantRecord	150	187	2025-03-02 09:56:20.70074
183	image	ActiveStorage::VariantRecord	151	188	2025-03-02 09:56:21.328256
184	image	ActiveStorage::VariantRecord	152	189	2025-03-02 09:56:22.853797
187	image	ActiveStorage::VariantRecord	156	192	2025-03-02 09:56:53.161806
189	image	ActiveStorage::VariantRecord	158	194	2025-03-02 09:56:54.32286
194	image	ActiveStorage::VariantRecord	164	199	2025-03-03 13:10:39.845406
196	image	ActiveStorage::VariantRecord	165	201	2025-03-03 13:10:41.982648
199	image	ActiveStorage::VariantRecord	168	204	2025-03-03 23:12:29.94889
200	image	ActiveStorage::VariantRecord	169	205	2025-03-03 23:12:33.850372
203	avatar	Contact	4	208	2025-03-16 13:19:22.538159
204	avatar	Contact	7	209	2025-03-16 13:20:54.871707
211	image	ActiveStorage::VariantRecord	172	216	2025-03-16 14:29:15.904249
217	image	ActiveStorage::VariantRecord	178	222	2025-03-16 14:29:16.707836
220	image	ActiveStorage::VariantRecord	181	225	2025-03-16 14:29:20.944505
221	image	ActiveStorage::VariantRecord	182	226	2025-03-16 14:29:21.127381
116	file	Image	18	121	2025-02-12 13:12:19.050041
117	file	Image	19	122	2025-02-12 13:12:19.733173
118	file	Image	20	123	2025-02-12 13:12:20.239568
119	file	Image	21	124	2025-02-12 13:12:20.71454
120	file	Image	22	125	2025-02-12 13:12:21.244985
223	image	ActiveStorage::VariantRecord	184	228	2025-03-16 14:29:21.430648
224	image	ActiveStorage::VariantRecord	185	229	2025-03-16 14:29:21.492463
227	image	ActiveStorage::VariantRecord	188	232	2025-03-16 14:29:22.685954
228	image	ActiveStorage::VariantRecord	189	233	2025-03-16 14:29:22.914724
230	file	Image	25	235	2025-03-19 15:37:42.192962
234	image	ActiveStorage::VariantRecord	194	239	2025-03-19 18:43:41.385169
236	image	ActiveStorage::VariantRecord	196	241	2025-03-19 18:43:45.179153
241	image	ActiveStorage::VariantRecord	198	246	2025-03-20 17:27:03.730617
245	image	ActiveStorage::VariantRecord	201	250	2025-03-20 17:54:30.497897
248	image	ActiveStorage::VariantRecord	203	253	2025-03-21 08:31:12.645037
249	image	ActiveStorage::VariantRecord	204	254	2025-03-21 08:31:23.825171
254	image	ActiveStorage::VariantRecord	209	259	2025-03-24 10:23:04.634147
258	file	Image	29	263	2025-03-28 08:51:29.25233
259	file	Image	30	264	2025-03-28 08:51:29.54517
260	file	Image	31	265	2025-03-28 08:51:29.860257
262	image	ActiveStorage::VariantRecord	214	267	2025-03-28 08:51:38.230439
265	image	ActiveStorage::VariantRecord	217	270	2025-03-28 08:51:45.88598
274	image	ActiveStorage::VariantRecord	222	279	2025-03-29 13:23:11.841694
275	image	ActiveStorage::VariantRecord	223	280	2025-03-29 13:23:16.17113
174	file	Image	24	179	2025-02-28 17:22:48.563467
\.


--
-- Data for Name: active_storage_blobs; Type: TABLE DATA; Schema: public; Owner: bentobook
--

COPY public.active_storage_blobs (id, key, filename, content_type, metadata, service_name, byte_size, checksum, created_at) FROM stdin;
14	20241128121619_IMG_1754.jpeg	20241128121619_IMG_1754.jpeg	image/jpeg	{"identified":true,"width":3024,"height":4032,"analyzed":true}	amazon	3588206	cLQ/0MSkjG9s+QtpsMEMOQ==	2024-11-28 12:16:19.54212
15	20241128121620_IMG_1753.jpeg	20241128121620_IMG_1753.jpeg	image/jpeg	{"identified":true,"width":3024,"height":4032,"analyzed":true}	amazon	3774029	Y16T+Fdjiq+kfCsoUDzZKQ==	2024-11-28 12:16:20.455513
3	mspmio072drjn6wgqfruf7kos9gd	IMG_6112.jpg	image/jpeg	{"identified":true,"width":1200,"height":900,"analyzed":true}	cloudflare	357892	rGM2YWwaQuj20O8qSlqM3Q==	2024-11-16 21:34:12.648737
16	20241128121620_IMG_1752.jpeg	20241128121620_IMG_1752.jpeg	image/jpeg	{"identified":true,"width":3024,"height":4032,"analyzed":true}	amazon	3020557	/+Ui6rUk7GhwScGbOLmHeg==	2024-11-28 12:16:20.932594
26	20241128131707_IMG_1749.jpeg	20241128131707_IMG_1749.jpeg	image/jpeg	{"identified":true,"width":3024,"height":4032,"analyzed":true}	amazon	3431689	M6u+v1fK4iiUmQrL6TxWjA==	2024-11-28 13:17:07.874166
27	20241128131708_IMG_1748.jpeg	20241128131708_IMG_1748.jpeg	image/jpeg	{"identified":true,"width":3024,"height":4032,"analyzed":true}	amazon	3256244	vLetB3AnWk0mYccvm1ov/g==	2024-11-28 13:17:08.995792
28	20241128131709_IMG_1747.jpeg	20241128131709_IMG_1747.jpeg	image/jpeg	{"identified":true,"width":3024,"height":4032,"analyzed":true}	amazon	3070540	Ty2NXT3xffmSsb/iDDWz0Q==	2024-11-28 13:17:09.532632
182	h75nf7tra8wnpn6seia08cuydmul	20241128121619_IMG_1754.jpeg	image/jpeg	{"identified":true,"width":75,"height":100,"analyzed":true}	amazon	14456	vM5xFd9gxOKETj8glZFlEQ==	2025-03-02 09:55:02.923631
199	75wp3hv5s9hnkpulzb1wuzysfxky	20241217223533_IMG_0033.webp	image/webp	{"identified":true,"width":300,"height":400,"analyzed":true}	amazon	40832	95VggJKZpTMKYttT+EJskw==	2025-03-03 13:10:39.832742
201	vsyoz9io222wsbem9i4phsx7eae0	20241217223532_IMG_0034.webp	image/webp	{"identified":true,"width":150,"height":200,"analyzed":true}	amazon	23704	fOvHPIxOEc/E2ziMC5M4vg==	2025-03-03 13:10:41.977689
211	ESa7A7zPpDqdbfEwBVQe19PJ	avatar_contact_3_20250316_132341.webp	image/webp	{"identified":true,"width":739,"height":415,"analyzed":true}	amazon	65782	vK1rDv965k0LhHveJCXTGQ==	2025-03-16 13:23:41.334926
213	c6iMBwcqLGq82Qf6ddz7MiTu	avatar_contact_9_20250316_132752.webp	image/webp	{"identified":true,"width":1200,"height":900,"analyzed":true}	amazon	114552	UxoXmYqIDwQB2z/Kxl1gRQ==	2025-03-16 13:27:52.432478
234	p348up3xwbgazp1potvewe3ktsk9	avatar_profile_3_20250316_131733.webp	image/webp	{"identified":true,"width":300,"height":400,"analyzed":true}	amazon	18126	PDJTj9DHA/Yhykmef/BR+w==	2025-03-16 14:39:11.868609
248	u1dJEcrnSSrQFUrN9rEQz2MF	avatar_contact_11_20250320_172823.webp	image/webp	{"identified":true,"width":1200,"height":900,"analyzed":true}	amazon	124920	WfLNnd7I08TGOHt0xQR8AQ==	2025-03-20 17:28:23.616785
259	xemmj43vq7iy1jm53mw2lat2wx1s	avatar_contact_11_20250320_172823.webp	image/webp	{"identified":true,"width":100,"height":100,"analyzed":true}	amazon	18000	NSwlT78KHCjnm33IzM0ewA==	2025-03-24 10:23:04.63168
48	20241202180346_IMG_1755.jpeg	20241202180346_IMG_1755.jpeg	image/jpeg	{"identified":true,"width":3024,"height":4032,"analyzed":true}	amazon	2361633	t7M4cj2pHEe1J9E+tVrXcA==	2024-12-02 18:03:46.675812
51	20241202193540_IMG_1756.jpeg	20241202193540_IMG_1756.jpeg	image/jpeg	{"identified":true,"width":3024,"height":4032,"analyzed":true}	amazon	3529235	UfCEMf9JBcRDWnhBDLFcFQ==	2024-12-02 19:35:40.495632
54	20241202212057_IMG_1759.jpeg	20241202212057_IMG_1759.jpeg	image/jpeg	{"identified":true,"width":4032,"height":3024,"analyzed":true}	amazon	2777951	nfodEA+dLcmLwlcJc585jw==	2024-12-02 21:20:57.519635
60	20241217223532_IMG_0034.jpeg	20241217223532_IMG_0034.jpeg	image/jpeg	{"identified":true,"width":4284,"height":5712,"analyzed":true}	amazon	3842929	Q3FroRKJu2/cTmthl7wpVg==	2024-12-17 22:35:32.022741
61	20241217223533_IMG_0033.jpeg	20241217223533_IMG_0033.jpeg	image/jpeg	{"identified":true,"width":3024,"height":4032,"analyzed":true}	amazon	2339863	O48R1qtqMlpxXBMZQQtbOQ==	2024-12-17 22:35:33.035688
62	20241217223533_IMG_0032.jpeg	20241217223533_IMG_0032.jpeg	image/jpeg	{"identified":true,"width":5712,"height":4284,"analyzed":true}	amazon	3941214	nl8lehvyIQuTCcuy3kSQ9w==	2024-12-17 22:35:33.479809
183	82rulqsrfxfmchw1clfvb91g7xh5	20241128131707_IMG_1749.webp	image/webp	{"identified":true,"width":300,"height":400,"analyzed":true}	amazon	41526	0Q8IVTAAW6/QzvXLOeHQvw==	2025-03-02 09:56:20.087133
200	lcer8g9r1vztz6sfavodnn2yqq7x	20241217223533_IMG_0033.webp	image/webp	{"identified":true,"width":150,"height":200,"analyzed":true}	amazon	22500	W68nNCkvnTxejZVLtfcqRQ==	2025-03-03 13:10:39.840466
212	y1RYUxKHVd2Zzmo8LjtUtiP9	avatar_contact_8_20250316_132642.webp	image/webp	{"identified":true,"width":1200,"height":800,"analyzed":true}	amazon	128928	aaFgi1p0fpn2DadrW2rDXA==	2025-03-16 13:26:43.346453
235	j8dl1atv6o41mnnyix8xav1cpzo6	img_0191-800fd378.jpeg	image/jpeg	{"identified":true,"width":5712,"height":4284,"analyzed":true}	amazon	3741815	+ppWz3wGMXBjIeSn1luggA==	2025-03-19 15:37:42.174803
249	rls1qpd9qs0lib1w9gxgbulvhjn6	img_0191-800fd378.webp	image/webp	{"identified":true,"width":100,"height":100,"analyzed":true}	amazon	12554	o5j89+RKs5yVWc/N+8ZqVg==	2025-03-20 17:54:10.976528
260	fowyvmippeo502oi2x9y40x66112	img_6961-7aca3e8b.webp	image/webp	{"identified":true,"width":100,"height":100,"analyzed":true}	amazon	18812	D7Z2rW/jQO75DS1ECZwNrA==	2025-03-24 10:23:04.786085
184	6wibec9orekw9bn3l5oa2l4uabum	20241128131708_IMG_1748.webp	image/webp	{"identified":true,"width":300,"height":400,"analyzed":true}	amazon	46076	4bY8rlXZKkjeONvG9Lfxtw==	2025-03-02 09:56:20.125345
189	30bydqngimxo88bqoc3ri2y3bod1	20241128131707_IMG_1749.webp	image/webp	{"identified":true,"width":150,"height":200,"analyzed":true}	amazon	20970	Ty85EuE50tMdzhuqCZkkFQ==	2025-03-02 09:56:22.848759
192	bfiuujdcbc7n5knyc7a4oppl9or4	20241202212057_IMG_1759.webp	image/webp	{"identified":true,"width":267,"height":200,"analyzed":true}	amazon	28584	uV4W8Mi1C4zGq7wdz5E+jA==	2025-03-02 09:56:53.159775
194	s097rd3gcvabzpsjro6yy0b6phpe	20241202193540_IMG_1756.webp	image/webp	{"identified":true,"width":300,"height":400,"analyzed":true}	amazon	38922	o7Jj/9y8NhMJ6fYUDpELxA==	2025-03-02 09:56:54.318998
203	qmu6a5lxuqmziy7kw38jsf7ye0pi	20241202193540_IMG_1756.webp	image/webp	{"identified":true,"width":600,"height":800,"analyzed":true}	amazon	104282	M3xVVadg+dFYoaOwckxFwQ==	2025-03-03 23:12:27.841377
214	746k3mnfamivgy2r0uvaaksoveq4	avatar_contact_2_20250316_131819.webp	image/webp	{"identified":true,"width":100,"height":100,"analyzed":true}	amazon	30318	A6ii32lBO0R4FiudHumOgw==	2025-03-16 14:29:14.074775
215	4t2x5il9t1pvxa0ypyeoeksswbef	20250212131219_IMG_0133.webp	image/webp	{"identified":true,"width":100,"height":100,"analyzed":true}	amazon	14564	AS5rSVMD2VWn1RajhtEQ0g==	2025-03-16 14:29:15.779029
219	byi0mlf9bgzimocgdjl8mlu06s06	20250212131220_IMG_0136.webp	image/webp	{"identified":true,"width":100,"height":100,"analyzed":true}	amazon	19568	b29dpAcePW40Pa05CFe4Yw==	2025-03-16 14:29:16.135852
220	e97px4j24qxpztk40zmmjjhovm3y	20241217223533_IMG_0033.webp	image/webp	{"identified":true,"width":100,"height":100,"analyzed":true}	amazon	17208	2InTF1k1HLiaGjKGtG2CJg==	2025-03-16 14:29:16.655767
223	vf7ab3wru21f5xdt76u7h28mdqyh	20241217223533_IMG_0032.webp	image/webp	{"identified":true,"width":100,"height":100,"analyzed":true}	amazon	15004	hq2oQ0QEglZZLsemv5xNiQ==	2025-03-16 14:29:17.535293
224	dae6uf9tu94kes6bt4bzhz8nmkg7	20241217223532_IMG_0034.webp	image/webp	{"identified":true,"width":100,"height":100,"analyzed":true}	amazon	18804	V0UtUCommpqfjdEwyn1O3A==	2025-03-16 14:29:18.233649
236	ha5gq51w4w22ttio2g6h2wxfp0zh	img_0191-800fd378.webp	image/webp	{"identified":true,"width":533,"height":400,"analyzed":true}	amazon	37676	MiduzrWijH713+viCMMkAw==	2025-03-19 15:41:46.266812
237	mqqfyc6jqn0g4qnbmj2mn97aa42p	img_0191-800fd378.webp	image/webp	{"identified":true,"width":1067,"height":800,"analyzed":true}	amazon	85068	Gx9CaJW7QVc5eBqYdkG0nw==	2025-03-19 15:41:53.268549
250	44d4armqtixj0wscr5695492d15s	20250212131219_IMG_0133.webp	image/webp	{"identified":true,"width":600,"height":800,"analyzed":true}	amazon	76654	os3STjv+xxVyIU2P6qU4XQ==	2025-03-20 17:54:30.496554
262	gss4ig8trdmvkkdt2ge2xf5bp48u	img_6960-8516f7df.webp	image/webp	{"identified":true,"width":1067,"height":800,"analyzed":true}	amazon	178270	cUBlVrhmCd6L06U4WwGbAA==	2025-03-24 10:23:16.787734
185	3f8bj8khzjmg2gomvp447pq2nkkc	20241128131708_IMG_1748.webp	image/webp	{"identified":true,"width":150,"height":200,"analyzed":true}	amazon	21728	kALCcl29LwElgBg1tuRj1g==	2025-03-02 09:56:20.251307
193	iw004oilrpc69bg7tly0kfwh52s7	20241202180346_IMG_1755.webp	image/webp	{"identified":true,"width":150,"height":200,"analyzed":true}	amazon	15648	W+zN69JMZ7UXvwAFsNRoEw==	2025-03-02 09:56:54.316422
204	6djhbq7qxe4fvimy97b5oilt3ios	20241202212057_IMG_1759.webp	image/webp	{"identified":true,"width":1067,"height":800,"analyzed":true}	amazon	157440	Us1GXMHwYyhDksv0OBu18Q==	2025-03-03 23:12:29.945217
205	zf3zdec5kpf2cfpcdw4w66nqnq2z	20241202180346_IMG_1755.webp	image/webp	{"identified":true,"width":600,"height":800,"analyzed":true}	amazon	61126	iup8Hdmaxf+Pfb8ntRCrCQ==	2025-03-03 23:12:33.84482
216	uxqomawfh6tsg3hapfc0r1kx2g9o	avatar_contact_3_20250316_132341.webp	image/webp	{"identified":true,"width":100,"height":100,"analyzed":true}	amazon	3870	rhXKXMM4boUcZaRgoPVVQg==	2025-03-16 14:29:15.885303
222	0g6ii515wn0z9d32a5m8q148i0fa	avatar_contact_7_20250316_132054.webp	image/webp	{"identified":true,"width":100,"height":100,"analyzed":true}	amazon	15856	vc3R6piLXv9NKkc24LKXoA==	2025-03-16 14:29:16.704031
225	xs04ykj6n53ofchq46rhyk1i5wif	20241202212057_IMG_1759.webp	image/webp	{"identified":true,"width":100,"height":100,"analyzed":true}	amazon	19206	bh+6zfpRWLQAyCLHObEERA==	2025-03-16 14:29:20.930184
229	s4yn1fdyl2pzkfw54z2hmgbfjkrm	20241202180346_IMG_1755.webp	image/webp	{"identified":true,"width":100,"height":100,"analyzed":true}	amazon	12536	tScK9vXyIRckAMwjiDTo/Q==	2025-03-16 14:29:21.488066
238	ygpvglzd22mst4ppjy9gbuore3ma	20250212131220_IMG_0136.webp	image/webp	{"identified":true,"width":533,"height":400,"analyzed":true}	amazon	70576	P6IRYd+3Ks1bc6qenF4xQQ==	2025-03-19 18:43:40.866674
240	ul2nrfu9o1002p2d27xse3oycl2q	20250212131219_IMG_0133.webp	image/webp	{"identified":true,"width":300,"height":400,"analyzed":true}	amazon	34746	uw42k84SK4KgBbbljsitWg==	2025-03-19 18:43:45.167442
251	1kx79f7ip7xjwq1z1wx0rukzuc1v	20241128131707_IMG_1749.webp	image/webp	{"identified":true,"width":600,"height":800,"analyzed":true}	amazon	117538	cRmNgINAcgII0v1Ak7MDzQ==	2025-03-20 21:07:40.611067
265	20250328085129_IMG_7068.jpeg	img_7068-14aa3f56.jpeg	image/jpeg	{"identified":true,"width":4032,"height":3024,"analyzed":true}	amazon	3746311	/AQF2MVprsD8+J9DYI6FQQ==	2025-03-28 08:51:29.561952
263	20250328085128_IMG_7070.jpeg	img_7070-9e01c70b.jpeg	image/jpeg	{"identified":true,"width":5712,"height":4284,"analyzed":true}	amazon	6254620	a05qpFrJW7hDkl0YCf06gA==	2025-03-28 08:51:28.657696
264	20250328085129_IMG_7069.jpeg	img_7069-3e316c00.jpeg	image/jpeg	{"identified":true,"width":5712,"height":4284,"analyzed":true}	amazon	5603086	ohrjp/wIW+t/sTbibFktJw==	2025-03-28 08:51:29.27839
267	ydes2vli0bz2888jztl8b9tyafmg	img_7069-3e316c00.webp	image/webp	{"identified":true,"width":533,"height":400,"analyzed":true}	amazon	62876	2j+2tmXUUtvD9p0VxMwz8g==	2025-03-28 08:51:38.224788
270	cc5scaiaqa70xj361gf8xx0d7zx6	img_7069-3e316c00.webp	image/webp	{"identified":true,"width":1067,"height":800,"analyzed":true}	amazon	201506	FOUnXoMBo6IsR88in8WJIQ==	2025-03-28 08:51:45.883344
94	20250210180416_IMG_0056.jpeg	20250210180416_IMG_0056.jpeg	image/jpeg	{"identified":true,"width":5712,"height":4284,"analyzed":true}	amazon	5229099	YqaUSGIWLVAuVHOJMTe/6A==	2025-02-10 18:04:16.982583
95	20250210180417_IMG_0067.jpeg	20250210180417_IMG_0067.jpeg	image/jpeg	{"identified":true,"width":4284,"height":5712,"analyzed":true}	amazon	3732381	iMyd/8sOPMPTAwo5idJE/w==	2025-02-10 18:04:17.784425
100	20250210180603_mh-gr3x-2024.jpeg	20250210180603_mh-gr3x-2024.jpeg	image/jpeg	{"identified":true,"width":6000,"height":4000,"analyzed":true}	amazon	3952235	01p9zCG/l7srEbTlGtNH7g==	2025-02-10 18:06:03.150887
102	20250210180746_IMG_0066.jpeg	20250210180746_IMG_0066.jpeg	image/jpeg	{"identified":true,"width":3024,"height":4032,"analyzed":true}	amazon	2013119	iCUUv/HxDyArqOkfLTAe9w==	2025-02-10 18:07:46.938207
103	20250210180747_IMG_0044.jpeg	20250210180747_IMG_0044.jpeg	image/jpeg	{"identified":true,"width":3024,"height":4032,"analyzed":true}	amazon	1918338	vFt8vmkO6PxdR2C1V7/5KQ==	2025-02-10 18:07:47.470725
186	kk4ylxne7najid6f0h6w33racws9	20241128131709_IMG_1747.webp	image/webp	{"identified":true,"width":150,"height":200,"analyzed":true}	amazon	20404	PXREOZXMfdQ9rtgNDAhKfQ==	2025-03-02 09:56:20.2875
190	5j3wjot3qn3s9un52alw7zuimkfx	20250228172248_IMG_0050.webp	image/webp	{"identified":true,"width":600,"height":800,"analyzed":true}	amazon	64568	PY9AjJZDoj19jw2vPoSLpw==	2025-03-02 09:56:51.66762
88	dcze2tgwpw5lvjae3wxi86yfogae	mh-mf-20151201-117.jpg	image/jpeg	{"identified":true,"width":1200,"height":900,"analyzed":true}	cloudflare	161939	LcUpQcI4mB3nF5lY4Wm1WA==	2025-02-10 17:51:54.797424
191	3oq2t5ygr5mw0jtwu845pylgwo4y	20241202212057_IMG_1759.webp	image/webp	{"identified":true,"width":533,"height":400,"analyzed":true}	amazon	57318	6JrMDhK3DUbQtKdOFuT2Wg==	2025-03-02 09:56:52.67364
90	h7l4kaikufbvyl1t5vsifikdh0z5	images.jpg	image/jpeg	{"identified":true,"width":554,"height":554,"analyzed":true}	cloudflare	26395	nvyWj3vgv0oCekomIzvfDA==	2025-02-10 18:01:32.618319
195	q897rqbzdx5mmp0cz5539sfiht07	20241202180346_IMG_1755.webp	image/webp	{"identified":true,"width":300,"height":400,"analyzed":true}	amazon	25980	0WCNYayUjOtpC4xPfJ4zyw==	2025-03-02 09:56:54.535344
206	gVwM2T41UgSCap2a8BRz3ST8	avatar_profile_3_20250316_131733.webp	image/webp	{"identified":true,"width":900,"height":1200,"analyzed":true}	amazon	147694	Z2MWkBYf8Fl9ZScHUg/ojw==	2025-03-16 13:17:34.963548
217	6kp5pizxi2zcfcpo9q3p7jzd6vw9	20250212131219_IMG_0135.webp	image/webp	{"identified":true,"width":100,"height":100,"analyzed":true}	amazon	13606	bLUs3TWFfL9zedpUpteTDQ==	2025-03-16 14:29:15.914105
230	26maq2p4ric2jjfenhy7ewe29m23	20241128121620_IMG_1753.webp	image/webp	{"identified":true,"width":100,"height":100,"analyzed":true}	amazon	13632	r2+pMTNvy/32qMtAdk5S7w==	2025-03-16 14:29:21.542384
231	qidw10li0g78ykp9tdfhhwyg4wd4	20241128121620_IMG_1752.webp	image/webp	{"identified":true,"width":100,"height":100,"analyzed":true}	amazon	12852	RFoG+g4iqhOG7Fq8y7C84Q==	2025-03-16 14:29:22.585986
239	mst4waewbsqrhcahcpphnazivuvj	20250212131220_IMG_0134.webp	image/webp	{"identified":true,"width":300,"height":400,"analyzed":true}	amazon	33972	WpIzWSXkXiF0pR3b7UigKw==	2025-03-19 18:43:41.371769
241	cn66tpd2kf3hex5t19628m9fqi32	20250212131219_IMG_0135.webp	image/webp	{"identified":true,"width":300,"height":400,"analyzed":true}	amazon	32640	MSk36U8GDQR8cF+GdTeUGw==	2025-03-19 18:43:45.176434
252	m5vgiaou3ns5pi1t0kz9gzypxwxo	img_0195-56d0a79f.jpeg	image/jpeg	{"identified":true,"width":5712,"height":4284,"analyzed":true}	amazon	5023785	wXfJqDvt4vNwnlw3LaBhOQ==	2025-03-21 08:30:29.537282
256	9yeokt0cbvx65vwt64s8i1tloh3g	avatar_contact_9_20250316_132752.webp	image/webp	{"identified":true,"width":100,"height":100,"analyzed":true}	amazon	17072	8y3v3/H/hm0hZZ0XRuLWpQ==	2025-03-21 08:34:00.911074
266	vcrqbn1oz53pf6ql64ksy2mgn9i3	img_7068-14aa3f56.webp	image/webp	{"identified":true,"width":533,"height":400,"analyzed":true}	amazon	81126	/5HTLYiWPD8aKF8TVWRalQ==	2025-03-28 08:51:37.900732
268	mk9dk0czrvv9fp6tckujslydz1yn	img_7070-9e01c70b.webp	image/webp	{"identified":true,"width":533,"height":400,"analyzed":true}	amazon	62586	lAh2sHnLzvXjiFmbxhM/GQ==	2025-03-28 08:51:38.752403
269	czztpz4bwtxt33dkzp3i8janp7z8	img_7068-14aa3f56.webp	image/webp	{"identified":true,"width":1067,"height":800,"analyzed":true}	amazon	283718	ELFmVvyyT1RCWTf0P78jOQ==	2025-03-28 08:51:41.308396
271	kkk1ba8oeizlh33nvy662i7s7unt	img_7070-9e01c70b.webp	image/webp	{"identified":true,"width":1067,"height":800,"analyzed":true}	amazon	213560	nI/8ruoiQyPEHujz5lGfvw==	2025-03-28 08:51:45.909652
277	af0bom2iv94jbyjorgwtjq7dwn52	img_7070-a9fcfbdd.webp	image/webp	{"identified":true,"width":533,"height":400,"analyzed":true}	amazon	62586	lAh2sHnLzvXjiFmbxhM/GQ==	2025-03-28 08:55:06.415542
121	20250212131219_IMG_0133.jpeg	20250212131219_IMG_0133.jpeg	image/jpeg	{"identified":true,"width":4284,"height":5712,"analyzed":true}	amazon	3756974	oEBm7tvdYZP8dpfc/aV4/A==	2025-02-12 13:12:19.044339
122	20250212131219_IMG_0135.jpeg	20250212131219_IMG_0135.jpeg	image/jpeg	{"identified":true,"width":4284,"height":5712,"analyzed":true}	amazon	3827647	LQueoP3AtkhvO6nP7tbx+A==	2025-02-12 13:12:19.731597
123	20250212131220_IMG_0134.jpeg	20250212131220_IMG_0134.jpeg	image/jpeg	{"identified":true,"width":4284,"height":5712,"analyzed":true}	amazon	3725514	hD4gVtwKEzGl40vH9laaOw==	2025-02-12 13:12:20.238069
124	20250212131220_IMG_0136.jpeg	20250212131220_IMG_0136.jpeg	image/jpeg	{"identified":true,"width":5712,"height":4284,"analyzed":true}	amazon	4419943	gwV1UUeelx944njyDVz+pA==	2025-02-12 13:12:20.711957
218	d6zielpi3n4c9aoa3undmej022f8	20250212131220_IMG_0134.webp	image/webp	{"identified":true,"width":100,"height":100,"analyzed":true}	amazon	14318	a9N3V3lLcqKccIwWTO6Arg==	2025-03-16 14:29:16.067198
221	fcvs8ht7sj3v3roymxdty69k0yle	avatar_contact_4_20250316_131921.webp	image/webp	{"identified":true,"width":100,"height":100,"analyzed":true}	amazon	29658	RtZAxbpv2eBAWsw7Af+rsQ==	2025-03-16 14:29:16.679392
242	idw92aia96gwnxsdtq3gaxwaodws	20250212131221_IMG_0132.webp	image/webp	{"identified":true,"width":533,"height":400,"analyzed":true}	amazon	57416	HamV2C5C217VEgBOU7CfVQ==	2025-03-20 17:08:58.863581
125	20250212131221_IMG_0132.jpeg	20250212131221_IMG_0132.jpeg	image/jpeg	{"identified":true,"width":5712,"height":4284,"analyzed":true}	amazon	4795076	rKYNSqyoaOLnIsrHH1LeXA==	2025-02-12 13:12:21.241597
187	te35mrxkh4qn0am43bea2xvybqlf	20241128131709_IMG_1747.webp	image/webp	{"identified":true,"width":300,"height":400,"analyzed":true}	amazon	39582	lr3K/GgoaN/8adn8NZ/TEA==	2025-03-02 09:56:20.690248
188	xoxa1qnu6aavd6fehodl11yr1a48	20250228172248_IMG_0050.webp	image/webp	{"identified":true,"width":300,"height":400,"analyzed":true}	amazon	33686	kUlL+az2n6HCrsh9GPVJtQ==	2025-03-02 09:56:21.326033
207	Me9AoptkX4WNY1GksfG7HYAj	avatar_contact_2_20250316_131819.webp	image/webp	{"identified":true,"width":1200,"height":800,"analyzed":true}	amazon	83976	wl43SGFxx2Bt0zHeNvwvaA==	2025-03-16 13:18:20.484756
253	fwqv63hq46k1itz88dh1otdbpa53	img_0195-56d0a79f.webp	image/webp	{"identified":true,"width":533,"height":400,"analyzed":true}	amazon	64164	apuwRugeqBHLMnJ2+O2tDA==	2025-03-21 08:31:12.63909
254	fi8a1f149h2q3t34xjtlficlrtxn	img_0195-56d0a79f.webp	image/webp	{"identified":true,"width":1067,"height":800,"analyzed":true}	amazon	175094	BshkpgJNiz5x8E6LOIHljQ==	2025-03-21 08:31:23.820598
272	b5391gge60760d1j846gs96ngpw2	img_7068-c27cbe23.jpeg	image/jpeg	{"identified":true,"width":4032,"height":3024,"analyzed":true}	amazon	3746311	/AQF2MVprsD8+J9DYI6FQQ==	2025-03-28 08:54:57.664235
273	xuh1b4cn28ww7zh0csdsum0lzc6w	img_7069-3ac9ae04.jpeg	image/jpeg	{"identified":true,"width":5712,"height":4284,"analyzed":true}	amazon	5603086	ohrjp/wIW+t/sTbibFktJw==	2025-03-28 08:54:58.12043
274	sxx4qzu3kmne4zcfpwimgfk8oifk	img_7070-a9fcfbdd.jpeg	image/jpeg	{"identified":true,"width":5712,"height":4284,"analyzed":true}	amazon	6254620	a05qpFrJW7hDkl0YCf06gA==	2025-03-28 08:54:58.333099
275	2oqfg40swl3c31jgr0tlrmme9nn7	img_7068-c27cbe23.webp	image/webp	{"identified":true,"width":533,"height":400,"analyzed":true}	amazon	81126	/5HTLYiWPD8aKF8TVWRalQ==	2025-03-28 08:55:04.979601
276	k4jemkp260ujaike6g32nuukxp04	img_7069-3ac9ae04.webp	image/webp	{"identified":true,"width":533,"height":400,"analyzed":true}	amazon	62876	2j+2tmXUUtvD9p0VxMwz8g==	2025-03-28 08:55:06.079231
278	9N7XZE4CKdL4yVYjAj99zSBJ	avatar_contact_12_20250328_090004.webp	image/webp	{"identified":true,"width":1200,"height":900,"analyzed":true}	amazon	127342	GvCOZZw69hanZsUVsLvqew==	2025-03-28 09:00:04.781373
196	9kzmw1flj1ghtrj8bfdalcg9oebe	20241202193540_IMG_1756.webp	image/webp	{"identified":true,"width":150,"height":200,"analyzed":true}	amazon	20010	mB0Z4rod7lnD3ER0aJ/B9w==	2025-03-02 09:56:54.598435
208	1xuWgkGzZMhmG9iFWjSUYs2x	avatar_contact_4_20250316_131921.webp	image/webp	{"identified":true,"width":1200,"height":795,"analyzed":true}	amazon	114284	s+MPP+TUnddloRerHox9Xg==	2025-03-16 13:19:22.24106
226	9l20utgq30wpttn0b5nv6fz1mmjw	20241202193540_IMG_1756.webp	image/webp	{"identified":true,"width":100,"height":100,"analyzed":true}	amazon	14510	X+UEA521KRka8vhqkDb01A==	2025-03-16 14:29:21.125496
209	h5iJwzQJj1aRfHmPRYjGPrFm	avatar_contact_7_20250316_132054.webp	image/webp	{"identified":true,"width":900,"height":1200,"analyzed":true}	amazon	112412	vJv1CV6rOIGCcc4lkYr1GA==	2025-03-16 13:20:54.605422
228	acwc7dy4jxtfehjucyfo7r0nqy9n	20241128121619_IMG_1754.webp	image/webp	{"identified":true,"width":100,"height":100,"analyzed":true}	amazon	15036	8ZjoSX1saI5fAYVD/h4Bnw==	2025-03-16 14:29:21.423096
232	mbu6ywr3b653u7hjrx91wthumfdt	20241128131708_IMG_1748.webp	image/webp	{"identified":true,"width":100,"height":100,"analyzed":true}	amazon	15846	etrq7A8Fge0pl2JV5sPh+A==	2025-03-16 14:29:22.682565
233	4xh862ixozsgdyrp6nxsw4usybfb	20241128131709_IMG_1747.webp	image/webp	{"identified":true,"width":100,"height":100,"analyzed":true}	amazon	15184	D+Cl2pLeYEuhznSqU21yaA==	2025-03-16 14:29:22.912492
243	QwWupN3HiPVUvQsbmCsmHSxP	avatar_contact_1_20250320_172210.webp	image/webp	{"identified":true,"width":1200,"height":900,"analyzed":true}	amazon	188994	0/Vx3dskhqqlZjEeJvKwAA==	2025-03-20 17:22:11.260772
244	semk1bhrcir0m0pqysjufr6l9ilt	img_6960-8516f7df.jpeg	image/jpeg	{"identified":true,"width":5712,"height":4284,"analyzed":true}	amazon	4593009	HK+CiPA8sQHluYjbU6V4vQ==	2025-03-20 17:26:57.253142
245	dbygvr2onsfm6p1g2ik4inxnck1x	img_6961-7aca3e8b.jpeg	image/jpeg	{"identified":true,"width":3088,"height":2316,"analyzed":true}	amazon	1273973	q/yz9uyL43f8E4RVDfSVAA==	2025-03-20 17:26:57.686384
247	ibyawpudm1uyr7srmr84i51obaqs	img_6960-8516f7df.webp	image/webp	{"identified":true,"width":533,"height":400,"analyzed":true}	amazon	71228	G46bmRKzG6aC6uckUtFICA==	2025-03-20 17:27:05.147518
255	ot5wtz0c8jkijkfm8ggy2r9hz53w	avatar_contact_8_20250316_132642.webp	image/webp	{"identified":true,"width":100,"height":100,"analyzed":true}	amazon	35464	DUXI6Hzv5nuJbpoNfPuVqw==	2025-03-21 08:34:00.748767
257	bwr68htydvmhzrd2w4uzjbkix2o1	img_0195-56d0a79f.webp	image/webp	{"identified":true,"width":100,"height":100,"analyzed":true}	amazon	15976	HB11lTzpp2JcJu8oQ2OM+g==	2025-03-21 08:34:02.101269
279	fjjuz6d20ocjpp3lhy0jdzqya1dx	20241217223533_IMG_0033.webp	image/webp	{"identified":true,"width":600,"height":800,"analyzed":true}	amazon	96706	uJP4l9qDYXgEUw8QQdyA0A==	2025-03-29 13:23:11.839252
280	hxbuewdqeqkv5rcu0yjvzuxk630x	20241217223533_IMG_0032.webp	image/webp	{"identified":true,"width":1067,"height":800,"analyzed":true}	amazon	121814	FfcNE6WFxLFc6ZkxjvqRrg==	2025-03-29 13:23:16.169549
197	qoetz6y69ir2w02g4a70xsqjfvyq	20241217223533_IMG_0032.webp	image/webp	{"identified":true,"width":267,"height":200,"analyzed":true}	amazon	25218	8hUVFdz3EuSOk/JGC314tg==	2025-03-03 13:10:37.860633
198	bxdqq58or5cgns835on93uan9uoo	20241217223533_IMG_0032.webp	image/webp	{"identified":true,"width":533,"height":400,"analyzed":true}	amazon	50944	SerI/2XWKQBtXGBuULimdQ==	2025-03-03 13:10:39.044166
202	810oryyw3ws6sssl4r4n2964qtfi	20241217223532_IMG_0034.webp	image/webp	{"identified":true,"width":300,"height":400,"analyzed":true}	amazon	36840	3MZDzBD+9mE7gqC69ZhQeA==	2025-03-03 13:10:44.482498
227	ns33hbrci0oyggmi4773abonhu6k	20241128131707_IMG_1749.webp	image/webp	{"identified":true,"width":100,"height":100,"analyzed":true}	amazon	15670	/Oo3Ot6qvQN0HiXzKLgG6g==	2025-03-16 14:29:21.229128
246	5f7kpb2rm40de0cbxg5h6t4h9sr4	img_6961-7aca3e8b.webp	image/webp	{"identified":true,"width":533,"height":400,"analyzed":true}	amazon	41088	/wI+0zURvYtq9C5ajjdJQA==	2025-03-20 17:27:03.725499
258	2wvan7fk4cljrzmvwskrmd2r4rqa	avatar_contact_1_20250320_172210.webp	image/webp	{"identified":true,"width":100,"height":100,"analyzed":true}	amazon	17456	Sf0FIm0sWe+0HtpGau/qXw==	2025-03-24 10:23:04.535514
261	mtw2oar66srfqtbjkh425dwam021	img_6960-8516f7df.webp	image/webp	{"identified":true,"width":100,"height":100,"analyzed":true}	amazon	20282	HfvLZJTUbgMotOA/TAAisw==	2025-03-24 10:23:05.68971
281	4x6g27v4epfknxo5termbrmo12kt	20241217223532_IMG_0034.webp	image/webp	{"identified":true,"width":600,"height":800,"analyzed":true}	amazon	69576	8I2DPWaD6wuwRauRsyyDjw==	2025-03-29 13:23:17.68287
179	20250228172247_IMG_0050.jpeg	20250228172248_IMG_0050.jpeg	image/jpeg	{"identified":true}	amazon	3710915	HvpqOKbSk5QwF29jumwPSQ==	2025-02-28 17:22:47.954314
\.


--
-- Data for Name: active_storage_variant_records; Type: TABLE DATA; Schema: public; Owner: bentobook
--

COPY public.active_storage_variant_records (id, blob_id, variation_digest) FROM stdin;
145	14	6/MbmLdOctrj7ukuFyVm7nWShm4=
146	26	Aj8k7tw4bj6/BVcuW04LwWQw44I=
147	27	Aj8k7tw4bj6/BVcuW04LwWQw44I=
148	27	30N5XM9+qxU7UAfMoNNTdC3JJAc=
149	28	30N5XM9+qxU7UAfMoNNTdC3JJAc=
150	28	Aj8k7tw4bj6/BVcuW04LwWQw44I=
151	179	Aj8k7tw4bj6/BVcuW04LwWQw44I=
152	26	30N5XM9+qxU7UAfMoNNTdC3JJAc=
154	179	SGzpP2wrKk8t+LlCq+KDhzFv/kU=
155	54	Aj8k7tw4bj6/BVcuW04LwWQw44I=
156	54	30N5XM9+qxU7UAfMoNNTdC3JJAc=
157	48	30N5XM9+qxU7UAfMoNNTdC3JJAc=
158	51	Aj8k7tw4bj6/BVcuW04LwWQw44I=
159	48	Aj8k7tw4bj6/BVcuW04LwWQw44I=
160	51	30N5XM9+qxU7UAfMoNNTdC3JJAc=
161	62	30N5XM9+qxU7UAfMoNNTdC3JJAc=
162	62	Aj8k7tw4bj6/BVcuW04LwWQw44I=
163	61	30N5XM9+qxU7UAfMoNNTdC3JJAc=
164	61	Aj8k7tw4bj6/BVcuW04LwWQw44I=
165	60	30N5XM9+qxU7UAfMoNNTdC3JJAc=
166	60	Aj8k7tw4bj6/BVcuW04LwWQw44I=
167	51	SGzpP2wrKk8t+LlCq+KDhzFv/kU=
168	54	SGzpP2wrKk8t+LlCq+KDhzFv/kU=
169	48	SGzpP2wrKk8t+LlCq+KDhzFv/kU=
170	207	y2R4o1TissKFDPYXyAfRvrkSxR8=
171	121	+SqsjdoWXMbkMuy1I1yKQPQgaS0=
172	211	y2R4o1TissKFDPYXyAfRvrkSxR8=
173	122	+SqsjdoWXMbkMuy1I1yKQPQgaS0=
174	123	+SqsjdoWXMbkMuy1I1yKQPQgaS0=
175	124	+SqsjdoWXMbkMuy1I1yKQPQgaS0=
176	61	+SqsjdoWXMbkMuy1I1yKQPQgaS0=
177	208	y2R4o1TissKFDPYXyAfRvrkSxR8=
178	209	y2R4o1TissKFDPYXyAfRvrkSxR8=
179	62	+SqsjdoWXMbkMuy1I1yKQPQgaS0=
180	60	+SqsjdoWXMbkMuy1I1yKQPQgaS0=
181	54	+SqsjdoWXMbkMuy1I1yKQPQgaS0=
182	51	+SqsjdoWXMbkMuy1I1yKQPQgaS0=
183	26	+SqsjdoWXMbkMuy1I1yKQPQgaS0=
184	14	+SqsjdoWXMbkMuy1I1yKQPQgaS0=
185	48	+SqsjdoWXMbkMuy1I1yKQPQgaS0=
186	15	+SqsjdoWXMbkMuy1I1yKQPQgaS0=
187	16	+SqsjdoWXMbkMuy1I1yKQPQgaS0=
188	27	+SqsjdoWXMbkMuy1I1yKQPQgaS0=
189	28	+SqsjdoWXMbkMuy1I1yKQPQgaS0=
190	206	Aj8k7tw4bj6/BVcuW04LwWQw44I=
191	235	Aj8k7tw4bj6/BVcuW04LwWQw44I=
192	235	SGzpP2wrKk8t+LlCq+KDhzFv/kU=
193	124	Aj8k7tw4bj6/BVcuW04LwWQw44I=
194	123	Aj8k7tw4bj6/BVcuW04LwWQw44I=
195	121	Aj8k7tw4bj6/BVcuW04LwWQw44I=
196	122	Aj8k7tw4bj6/BVcuW04LwWQw44I=
197	125	Aj8k7tw4bj6/BVcuW04LwWQw44I=
198	245	Aj8k7tw4bj6/BVcuW04LwWQw44I=
199	244	Aj8k7tw4bj6/BVcuW04LwWQw44I=
200	235	+SqsjdoWXMbkMuy1I1yKQPQgaS0=
201	121	SGzpP2wrKk8t+LlCq+KDhzFv/kU=
202	26	SGzpP2wrKk8t+LlCq+KDhzFv/kU=
203	252	Aj8k7tw4bj6/BVcuW04LwWQw44I=
204	252	SGzpP2wrKk8t+LlCq+KDhzFv/kU=
205	212	y2R4o1TissKFDPYXyAfRvrkSxR8=
206	213	y2R4o1TissKFDPYXyAfRvrkSxR8=
207	252	+SqsjdoWXMbkMuy1I1yKQPQgaS0=
208	243	y2R4o1TissKFDPYXyAfRvrkSxR8=
209	248	y2R4o1TissKFDPYXyAfRvrkSxR8=
210	245	+SqsjdoWXMbkMuy1I1yKQPQgaS0=
211	244	+SqsjdoWXMbkMuy1I1yKQPQgaS0=
212	244	SGzpP2wrKk8t+LlCq+KDhzFv/kU=
213	265	Aj8k7tw4bj6/BVcuW04LwWQw44I=
214	264	Aj8k7tw4bj6/BVcuW04LwWQw44I=
215	263	Aj8k7tw4bj6/BVcuW04LwWQw44I=
216	265	SGzpP2wrKk8t+LlCq+KDhzFv/kU=
217	264	SGzpP2wrKk8t+LlCq+KDhzFv/kU=
218	263	SGzpP2wrKk8t+LlCq+KDhzFv/kU=
219	272	Aj8k7tw4bj6/BVcuW04LwWQw44I=
220	273	Aj8k7tw4bj6/BVcuW04LwWQw44I=
221	274	Aj8k7tw4bj6/BVcuW04LwWQw44I=
222	61	SGzpP2wrKk8t+LlCq+KDhzFv/kU=
223	62	SGzpP2wrKk8t+LlCq+KDhzFv/kU=
224	60	SGzpP2wrKk8t+LlCq+KDhzFv/kU=
\.


--
-- Data for Name: ar_internal_metadata; Type: TABLE DATA; Schema: public; Owner: bentobook
--

COPY public.ar_internal_metadata (key, value, created_at, updated_at) FROM stdin;
environment	production	2024-11-05 15:16:07.46186	2024-11-05 15:16:07.461871
schema_sha1	8ba27ce096f99ef6e16a9e10a841da3eef6c7045	2024-11-05 15:16:07.485294	2024-11-05 15:16:07.4853
\.


--
-- Data for Name: contacts; Type: TABLE DATA; Schema: public; Owner: bentobook
--

COPY public.contacts (id, name, email, city, country, phone, notes, user_id, created_at, updated_at) FROM stdin;
5	Markus	info@bentobook.com	Paris	France		My bestest friend and the dude who programmed this app.	95	2025-02-10 17:51:54.544148	2025-02-10 17:51:56.133007
6	Esther		Boston	USA			95	2025-02-10 18:01:32.530437	2025-02-10 18:01:33.361696
2	Maryse	esyram.kcnarf@gmail.com	Paris	France			3	2024-11-16 22:08:03.106973	2025-03-16 13:18:21.135864
4	Freddy	zoposso.d@gmail.com		France			3	2024-12-02 15:57:56.156787	2025-03-16 13:19:22.882034
7	Evan		Coburg	Germany			3	2025-02-12 11:37:54.467066	2025-03-16 13:20:55.175598
3	Kent						3	2024-12-02 15:54:09.164148	2025-03-16 13:23:41.889674
8	Quentin		Paris	France			3	2025-03-16 13:26:42.782514	2025-03-16 13:26:43.958348
9	Isabelle Magnon						3	2025-03-16 13:27:52.070086	2025-03-16 13:27:53.135441
10	Patricia C						3	2025-03-16 13:31:02.663832	2025-03-16 13:31:02.663832
1	marc	marc.haussmann@gmail.com	Paris	France	0631643724		12	2024-11-16 21:46:00.710628	2025-03-20 17:22:12.473491
11	Quentin						12	2025-03-20 17:28:23.192975	2025-03-20 17:28:24.243228
12	Isabelle 						12	2025-03-28 09:00:04.307941	2025-03-28 09:00:05.468965
\.


--
-- Data for Name: cuisine_types; Type: TABLE DATA; Schema: public; Owner: bentobook
--

COPY public.cuisine_types (id, name, created_at, updated_at) FROM stdin;
1	african	2024-11-05 18:14:35.998455	2024-11-05 18:14:35.998455
2	american	2024-11-05 18:14:36.029012	2024-11-05 18:14:36.029012
3	asian	2024-11-05 18:14:36.069884	2024-11-05 18:14:36.069884
4	asian_fusion	2024-11-05 18:14:36.100033	2024-11-05 18:14:36.100033
5	bakery	2024-11-05 18:14:36.121478	2024-11-05 18:14:36.121478
6	bar	2024-11-05 18:14:36.14369	2024-11-05 18:14:36.14369
7	bbq	2024-11-05 18:14:36.158602	2024-11-05 18:14:36.158602
8	brazilian	2024-11-05 18:14:36.177359	2024-11-05 18:14:36.177359
9	british	2024-11-05 18:14:36.188565	2024-11-05 18:14:36.188565
10	brunch	2024-11-05 18:14:36.20817	2024-11-05 18:14:36.20817
11	burger	2024-11-05 18:14:36.229513	2024-11-05 18:14:36.229513
12	cafe	2024-11-05 18:14:36.235572	2024-11-05 18:14:36.235572
13	caribbean	2024-11-05 18:14:36.23972	2024-11-05 18:14:36.23972
14	chinese	2024-11-05 18:14:36.243592	2024-11-05 18:14:36.243592
15	dim_sum	2024-11-05 18:14:36.283051	2024-11-05 18:14:36.283051
16	ethiopian	2024-11-05 18:14:36.318332	2024-11-05 18:14:36.318332
17	french	2024-11-05 18:14:36.321626	2024-11-05 18:14:36.321626
18	fusion	2024-11-05 18:14:36.325534	2024-11-05 18:14:36.325534
19	german	2024-11-05 18:14:36.32984	2024-11-05 18:14:36.32984
20	greek	2024-11-05 18:14:36.332719	2024-11-05 18:14:36.332719
21	indian	2024-11-05 18:14:36.336017	2024-11-05 18:14:36.336017
22	italian	2024-11-05 18:14:36.338715	2024-11-05 18:14:36.338715
23	japanese	2024-11-05 18:14:36.341196	2024-11-05 18:14:36.341196
24	korean	2024-11-05 18:14:36.344269	2024-11-05 18:14:36.344269
25	mediterranean	2024-11-05 18:14:36.347132	2024-11-05 18:14:36.347132
26	mexican	2024-11-05 18:14:36.350031	2024-11-05 18:14:36.350031
27	middle_eastern	2024-11-05 18:14:36.351989	2024-11-05 18:14:36.351989
28	moroccan	2024-11-05 18:14:36.35447	2024-11-05 18:14:36.35447
29	noodles	2024-11-05 18:14:36.359794	2024-11-05 18:14:36.359794
30	other	2024-11-05 18:14:36.426118	2024-11-05 18:14:36.426118
31	peruvian	2024-11-05 18:14:36.452027	2024-11-05 18:14:36.452027
32	portuguese	2024-11-05 18:14:36.45626	2024-11-05 18:14:36.45626
33	pub	2024-11-05 18:14:36.460711	2024-11-05 18:14:36.460711
34	ramen	2024-11-05 18:14:36.465074	2024-11-05 18:14:36.465074
35	seafood	2024-11-05 18:14:36.470118	2024-11-05 18:14:36.470118
36	spanish	2024-11-05 18:14:36.476256	2024-11-05 18:14:36.476256
37	steakhouse	2024-11-05 18:14:36.480216	2024-11-05 18:14:36.480216
38	taiwanese	2024-11-05 18:14:36.48369	2024-11-05 18:14:36.48369
39	thai	2024-11-05 18:14:36.487343	2024-11-05 18:14:36.487343
40	turkish	2024-11-05 18:14:36.490338	2024-11-05 18:14:36.490338
41	vegan	2024-11-05 18:14:36.493248	2024-11-05 18:14:36.493248
42	vegetarian	2024-11-05 18:14:36.495998	2024-11-05 18:14:36.495998
43	vietnamese	2024-11-05 18:14:36.498271	2024-11-05 18:14:36.498271
\.


--
-- Data for Name: google_restaurants; Type: TABLE DATA; Schema: public; Owner: bentobook
--

COPY public.google_restaurants (id, name, google_place_id, address, latitude, longitude, street, street_number, postal_code, city, state, country, phone_number, url, business_status, google_rating, google_ratings_total, price_level, opening_hours, google_updated_at, created_at, updated_at, location) FROM stdin;
3	La Grange de Belle Eglise	ChIJ2cWW7G9a5kcROuMrfQPdhPs	28 Bd de Belle Église, 60540 Belle-Église, France	49.19213040	2.21445170	Boulevard de Belle Église	28	60540	Belle-Église	Hauts-de-France	France	03 44 08 49 00	http://www.lagrangedebelleeglise.fr/	OPERATIONAL	4.7	436	4	"{\\"periods\\":[{\\"close\\":{\\"day\\":2,\\"time\\":\\"2100\\",\\"hours\\":21,\\"minutes\\":0},\\"open\\":{\\"day\\":2,\\"time\\":\\"1930\\",\\"hours\\":19,\\"minutes\\":30}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"1300\\",\\"hours\\":13,\\"minutes\\":0},\\"open\\":{\\"day\\":3,\\"time\\":\\"1130\\",\\"hours\\":11,\\"minutes\\":30}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"2100\\",\\"hours\\":21,\\"minutes\\":0},\\"open\\":{\\"day\\":3,\\"time\\":\\"1930\\",\\"hours\\":19,\\"minutes\\":30}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"1300\\",\\"hours\\":13,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"1130\\",\\"hours\\":11,\\"minutes\\":30}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"2100\\",\\"hours\\":21,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"1930\\",\\"hours\\":19,\\"minutes\\":30}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"1300\\",\\"hours\\":13,\\"minutes\\":0},\\"open\\":{\\"day\\":5,\\"time\\":\\"1130\\",\\"hours\\":11,\\"minutes\\":30}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"2100\\",\\"hours\\":21,\\"minutes\\":0},\\"open\\":{\\"day\\":5,\\"time\\":\\"1930\\",\\"hours\\":19,\\"minutes\\":30}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"1300\\",\\"hours\\":13,\\"minutes\\":0},\\"open\\":{\\"day\\":6,\\"time\\":\\"1130\\",\\"hours\\":11,\\"minutes\\":30}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"2100\\",\\"hours\\":21,\\"minutes\\":0},\\"open\\":{\\"day\\":6,\\"time\\":\\"1930\\",\\"hours\\":19,\\"minutes\\":30}}],\\"weekday_text\\":[\\"lundi: Fermé\\",\\"mardi: 19:30 – 21:00\\",\\"mercredi: 11:30 – 13:00, 19:30 – 21:00\\",\\"jeudi: 11:30 – 13:00, 19:30 – 21:00\\",\\"vendredi: 11:30 – 13:00, 19:30 – 21:00\\",\\"samedi: 11:30 – 13:00, 19:30 – 21:00\\",\\"dimanche: Fermé\\"]}"	2024-11-22 16:33:07.803	2024-11-22 16:34:04.785291	2024-11-22 16:34:04.785291	0101000020E6100000A592F07332B70140A1489CBA97984840
4	MOSUGO PARIS 2 PAR MORY SACKO	ChIJrxPxRQBv5kcRn6KeprVs0L4	35 Rue des Jeuneurs, 75002 Paris, France	48.86958150	2.34379200	Rue des Jeuneurs	35	75002	Paris	Île-de-France	France	09 88 56 77 48	https://mosugo.com/	OPERATIONAL	4.6	63	\N	"{\\"periods\\":[{\\"close\\":{\\"day\\":1,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":1,\\"time\\":\\"1130\\",\\"hours\\":11,\\"minutes\\":30}},{\\"close\\":{\\"day\\":1,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":1,\\"time\\":\\"1830\\",\\"hours\\":18,\\"minutes\\":30}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":2,\\"time\\":\\"1130\\",\\"hours\\":11,\\"minutes\\":30}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":2,\\"time\\":\\"1830\\",\\"hours\\":18,\\"minutes\\":30}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":3,\\"time\\":\\"1130\\",\\"hours\\":11,\\"minutes\\":30}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"2230\\",\\"hours\\":22,\\"minutes\\":30},\\"open\\":{\\"day\\":3,\\"time\\":\\"1830\\",\\"hours\\":18,\\"minutes\\":30}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":4,\\"time\\":\\"1130\\",\\"hours\\":11,\\"minutes\\":30}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"1830\\",\\"hours\\":18,\\"minutes\\":30}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":5,\\"time\\":\\"1130\\",\\"hours\\":11,\\"minutes\\":30}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":5,\\"time\\":\\"1830\\",\\"hours\\":18,\\"minutes\\":30}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"1500\\",\\"hours\\":15,\\"minutes\\":0},\\"open\\":{\\"day\\":6,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":6,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}}],\\"weekday_text\\":[\\"lundi: 11:30 – 14:30, 18:30 – 22:00\\",\\"mardi: 11:30 – 14:30, 18:30 – 22:00\\",\\"mercredi: 11:30 – 14:30, 18:30 – 22:30\\",\\"jeudi: 11:30 – 14:30, 18:30 – 22:00\\",\\"vendredi: 11:30 – 14:30, 18:30 – 22:00\\",\\"samedi: 12:00 – 15:00, 19:00 – 23:00\\",\\"dimanche: Fermé\\"]}"	2024-11-22 16:35:15.287	2024-11-22 16:36:37.713519	2024-11-22 16:36:37.713519	0101000020E6100000EF02250516C0024073DA53724E6F4840
5	7oumani chez Issam	ChIJSyn5gdBt5kcRL36O9CgGp34	65 Av. Edouard Vaillant, 93500 Pantin, France	48.90146720	2.39389750	Avenue Edouard Vaillant	65	93500	Pantin	Île-de-France	France	06 62 82 09 41	https://www.facebook.com/7oumaniissam	OPERATIONAL	4.5	149	1	"{\\"periods\\":[{\\"close\\":{\\"day\\":0,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":0,\\"time\\":\\"1000\\",\\"hours\\":10,\\"minutes\\":0}},{\\"close\\":{\\"day\\":1,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":1,\\"time\\":\\"1000\\",\\"hours\\":10,\\"minutes\\":0}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":2,\\"time\\":\\"1000\\",\\"hours\\":10,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":3,\\"time\\":\\"1000\\",\\"hours\\":10,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"1000\\",\\"hours\\":10,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":5,\\"time\\":\\"1000\\",\\"hours\\":10,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":6,\\"time\\":\\"1000\\",\\"hours\\":10,\\"minutes\\":0}}],\\"weekday_text\\":[\\"lundi: 10:00 – 23:00\\",\\"mardi: 10:00 – 23:00\\",\\"mercredi: 10:00 – 23:00\\",\\"jeudi: 10:00 – 23:00\\",\\"vendredi: 10:00 – 23:00\\",\\"samedi: 10:00 – 23:00\\",\\"dimanche: 10:00 – 23:00\\"]}"	2024-11-22 16:46:42.585	2024-11-22 16:49:41.462021	2024-11-22 16:49:41.462021	0101000020E61000002DCF83BBB32603405635F74663734840
25	Les petites dalles	ChIJrVcnvnBx5kcR5L4B3ziT7hE	357 Rue Lecourbe, 75015 Paris, France	48.83626280	2.28244620	Rue Lecourbe	357	75015	Paris	Île-de-France	France	09 87 77 77 19	http://lespetitesdalles.fr/	OPERATIONAL	4.8	702	2	"{\\"periods\\":[{\\"close\\":{\\"day\\":0,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":0,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":0,\\"time\\":\\"2100\\",\\"hours\\":21,\\"minutes\\":0},\\"open\\":{\\"day\\":0,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"1400\\",\\"hours\\":14,\\"minutes\\":0},\\"open\\":{\\"day\\":2,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":2,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"1400\\",\\"hours\\":14,\\"minutes\\":0},\\"open\\":{\\"day\\":3,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":3,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"1400\\",\\"hours\\":14,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"1400\\",\\"hours\\":14,\\"minutes\\":0},\\"open\\":{\\"day\\":5,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"2230\\",\\"hours\\":22,\\"minutes\\":30},\\"open\\":{\\"day\\":5,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":6,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"2230\\",\\"hours\\":22,\\"minutes\\":30},\\"open\\":{\\"day\\":6,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}}],\\"weekday_text\\":[\\"lundi: Fermé\\",\\"mardi: 12:00 – 14:00, 19:00 – 22:00\\",\\"mercredi: 12:00 – 14:00, 19:00 – 22:00\\",\\"jeudi: 12:00 – 14:00, 19:00 – 22:00\\",\\"vendredi: 12:00 – 14:00, 19:00 – 22:30\\",\\"samedi: 12:00 – 14:30, 19:00 – 22:30\\",\\"dimanche: 12:00 – 14:30, 19:00 – 21:00\\"]}"	2025-01-19 10:31:31.026	2025-01-19 10:33:24.756582	2025-01-19 10:33:24.756582	0101000020E61000002A093F2773420240426ED0A80A6B4840
2	Le Bouillon du Coq	ChIJY7SUOdZv5kcRPVDKh7EP-uA	37 Bd Jean Jaurès, 93400 Saint-Ouen-sur-Seine, France	48.91280240	2.33528200	Boulevard Jean Jaurès	37	93400	Saint-Ouen-sur-Seine	Île-de-France	France	01 86 53 46 56	https://lebouillonducoq.com/	OPERATIONAL	3.9	676	\N	"{\\"periods\\":[{\\"close\\":{\\"day\\":0,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":0,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":1,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":1,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":2,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":3,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":5,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":6,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}}],\\"weekday_text\\":[\\"Monday: 12:00 – 11:00 pm\\",\\"Tuesday: 12:00 – 11:00 pm\\",\\"Wednesday: 12:00 – 11:00 pm\\",\\"Thursday: 12:00 – 11:00 pm\\",\\"Friday: 12:00 – 11:00 pm\\",\\"Saturday: 12:00 – 11:00 pm\\",\\"Sunday: 12:00 – 11:00 pm\\"]}"	2025-02-12 11:37:07.549	2024-11-22 16:28:52.23438	2025-02-12 11:37:19.588019	0101000020E6100000F17F4754A8AE0240EBDA83B5D6744840
83	Eats Thyme	ChIJm28ylHBv5kcRPXdmMOyZEOs	44 Rue Coquillière, 75001 Paris, France	48.86468010	2.34078450	Rue Coquillière	44	75001	Paris	Île-de-France	France	01 42 33 21 15	https://eatsthyme.com/	OPERATIONAL	4.3	702	\N	\N	2025-04-27 16:31:00.179509	2025-04-27 16:31:00.186582	2025-04-27 16:31:00.186582	0101000020E6100000A4DE5339EDB90240428067D6AD6E4840
84	GHIDO RAMEN	ChIJEXjIjpRv5kcRrjppeD4_wFk	77 Rue du Faubourg Saint-Martin, 75010 Paris, France	48.87247050	2.35742180	Rue du Faubourg Saint-Martin	77	75010	Paris	Île-de-France	France	\N	https://www.instagram.com/ghidoramenparis/	OPERATIONAL	4.7	250	\N	\N	2025-04-27 16:36:09.914583	2025-04-27 16:36:09.916809	2025-04-27 16:36:09.916809	0101000020E61000000605EFF5FFDB0240C51C041DAD6F4840
85	La Popotière	ChIJ9erV9Ydt5kcR3Ihu92Jt5z4	58 Rue de la Réunion, 75020 Paris, France	48.85521090	2.40159600	Rue de la Réunion	58	75020	Paris	Île-de-France	France	01 43 67 51 15	https://lapopotiere.fr/fr	OPERATIONAL	4.8	149	\N	\N	2025-04-27 16:45:16.451476	2025-04-27 16:45:16.456236	2025-04-27 16:45:16.456236	0101000020E6100000A5A2B1F6773603406457FF8C776D4840
86	Kuna Masala	ChIJj8ku5yJv5kcRgqkRVyYHjZE	89 Rue du Rocher, 75008 Paris, France	48.88058730	2.31714160	Rue du Rocher	89	75008	Paris	Île-de-France	France	\N	https://kuna-family.com/	OPERATIONAL	4.7	62	\N	\N	2025-04-27 16:47:31.539563	2025-04-27 16:47:31.54204	2025-04-27 16:47:31.54204	0101000020E6100000E19B018981890240F062AB15B7704840
6	L'Avanos	ChIJibV3n8lz5kcR9HKspvLkqHs	19 Promenée Marat, 94200 Ivry-sur-Seine, France	48.81112070	2.38456420	Promenée Marat	19	94200	Ivry-sur-Seine	Île-de-France	France	09 83 54 75 92	https://lavanos-restaurant-ivry-sur-seine.eatbu.com/	OPERATIONAL	4.7	231	1	"{\\"periods\\":[{\\"close\\":{\\"day\\":1,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":1,\\"time\\":\\"1130\\",\\"hours\\":11,\\"minutes\\":30}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":2,\\"time\\":\\"1130\\",\\"hours\\":11,\\"minutes\\":30}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":3,\\"time\\":\\"1130\\",\\"hours\\":11,\\"minutes\\":30}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"1130\\",\\"hours\\":11,\\"minutes\\":30}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":5,\\"time\\":\\"1130\\",\\"hours\\":11,\\"minutes\\":30}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":6,\\"time\\":\\"1130\\",\\"hours\\":11,\\"minutes\\":30}}],\\"weekday_text\\":[\\"lundi: 11:30 – 22:00\\",\\"mardi: 11:30 – 22:00\\",\\"mercredi: 11:30 – 22:00\\",\\"jeudi: 11:30 – 22:00\\",\\"vendredi: 11:30 – 22:00\\",\\"samedi: 11:30 – 22:00\\",\\"dimanche: Fermé\\"]}"	2024-11-22 16:50:42.468	2024-11-22 16:51:49.920472	2024-11-22 16:51:49.920472	0101000020E610000000B3316596130340E7CD97CDD2674840
8	Au Petit Bar	ChIJhWdZEi5u5kcR1qejOKLpihM	7 Rue du Mont Thabor, 75001 Paris, France	48.86540690	2.32907840	Rue du Mont Thabor	7	75001	Paris	Île-de-France	France	01 42 60 62 09		OPERATIONAL	4.7	277	1	"{\\"periods\\":[{\\"close\\":{\\"day\\":1,\\"time\\":\\"2130\\",\\"hours\\":21,\\"minutes\\":30},\\"open\\":{\\"day\\":1,\\"time\\":\\"0700\\",\\"hours\\":7,\\"minutes\\":0}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"2130\\",\\"hours\\":21,\\"minutes\\":30},\\"open\\":{\\"day\\":2,\\"time\\":\\"0700\\",\\"hours\\":7,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"2130\\",\\"hours\\":21,\\"minutes\\":30},\\"open\\":{\\"day\\":3,\\"time\\":\\"0700\\",\\"hours\\":7,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"2130\\",\\"hours\\":21,\\"minutes\\":30},\\"open\\":{\\"day\\":4,\\"time\\":\\"0700\\",\\"hours\\":7,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"2130\\",\\"hours\\":21,\\"minutes\\":30},\\"open\\":{\\"day\\":5,\\"time\\":\\"0700\\",\\"hours\\":7,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"2130\\",\\"hours\\":21,\\"minutes\\":30},\\"open\\":{\\"day\\":6,\\"time\\":\\"0700\\",\\"hours\\":7,\\"minutes\\":0}}],\\"weekday_text\\":[\\"lundi: 07:00 – 21:30\\",\\"mardi: 07:00 – 21:30\\",\\"mercredi: 07:00 – 21:30\\",\\"jeudi: 07:00 – 21:30\\",\\"vendredi: 07:00 – 21:30\\",\\"samedi: 07:00 – 21:30\\",\\"dimanche: Fermé\\"]}"	2024-11-22 16:56:12.037	2024-11-22 16:57:34.54953	2024-11-22 16:57:34.54953	0101000020E6100000608F2EDBF3A10240CB9D3EA7C56E4840
9	Fleur D'Orient	ChIJuZPXxhRs5kcRfxHBeBjB-yo	96 Rue Charles Tillon, 93300 Aubervilliers, France	48.91923010	2.39384540	Rue Charles Tillon	96	93300	Aubervilliers	Île-de-France	France			OPERATIONAL	4.5	40	\N	"{\\"periods\\":[{\\"close\\":{\\"day\\":1,\\"time\\":\\"0000\\",\\"hours\\":0,\\"minutes\\":0},\\"open\\":{\\"day\\":0,\\"time\\":\\"0900\\",\\"hours\\":9,\\"minutes\\":0}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"0000\\",\\"hours\\":0,\\"minutes\\":0},\\"open\\":{\\"day\\":1,\\"time\\":\\"0900\\",\\"hours\\":9,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"0000\\",\\"hours\\":0,\\"minutes\\":0},\\"open\\":{\\"day\\":2,\\"time\\":\\"0900\\",\\"hours\\":9,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"0000\\",\\"hours\\":0,\\"minutes\\":0},\\"open\\":{\\"day\\":3,\\"time\\":\\"0900\\",\\"hours\\":9,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"0000\\",\\"hours\\":0,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"0900\\",\\"hours\\":9,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"0000\\",\\"hours\\":0,\\"minutes\\":0},\\"open\\":{\\"day\\":5,\\"time\\":\\"0900\\",\\"hours\\":9,\\"minutes\\":0}},{\\"close\\":{\\"day\\":0,\\"time\\":\\"0000\\",\\"hours\\":0,\\"minutes\\":0},\\"open\\":{\\"day\\":6,\\"time\\":\\"0900\\",\\"hours\\":9,\\"minutes\\":0}}],\\"weekday_text\\":[\\"lundi: 09:00 – 00:00\\",\\"mardi: 09:00 – 00:00\\",\\"mercredi: 09:00 – 00:00\\",\\"jeudi: 09:00 – 00:00\\",\\"vendredi: 09:00 – 00:00\\",\\"samedi: 09:00 – 00:00\\",\\"dimanche: 09:00 – 00:00\\"]}"	2024-11-22 16:59:41.243	2024-11-22 17:01:19.166543	2024-11-22 17:01:19.166543	0101000020E6100000B870C56A98260340D97FF854A9754840
10	Restaurant Sidi Bou	ChIJCd4u5Dds5kcRajlZvkUbG9M	69 Av. Jean Jaurès, 93300 Aubervilliers, France	48.90477760	2.39297310	Avenue Jean Jaurès	69	93300	Aubervilliers	Île-de-France	France	01 48 34 62 41	http://www.sidibouaubervilliers.fr/	OPERATIONAL	4	1089	1	"{\\"periods\\":[{\\"close\\":{\\"day\\":0,\\"time\\":\\"2330\\",\\"hours\\":23,\\"minutes\\":30},\\"open\\":{\\"day\\":0,\\"time\\":\\"1100\\",\\"hours\\":11,\\"minutes\\":0}},{\\"close\\":{\\"day\\":1,\\"time\\":\\"2330\\",\\"hours\\":23,\\"minutes\\":30},\\"open\\":{\\"day\\":1,\\"time\\":\\"1100\\",\\"hours\\":11,\\"minutes\\":0}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"2330\\",\\"hours\\":23,\\"minutes\\":30},\\"open\\":{\\"day\\":2,\\"time\\":\\"1100\\",\\"hours\\":11,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"2330\\",\\"hours\\":23,\\"minutes\\":30},\\"open\\":{\\"day\\":3,\\"time\\":\\"1100\\",\\"hours\\":11,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"2330\\",\\"hours\\":23,\\"minutes\\":30},\\"open\\":{\\"day\\":4,\\"time\\":\\"1100\\",\\"hours\\":11,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"2330\\",\\"hours\\":23,\\"minutes\\":30},\\"open\\":{\\"day\\":5,\\"time\\":\\"1100\\",\\"hours\\":11,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"2330\\",\\"hours\\":23,\\"minutes\\":30},\\"open\\":{\\"day\\":6,\\"time\\":\\"1100\\",\\"hours\\":11,\\"minutes\\":0}}],\\"weekday_text\\":[\\"lundi: 11:00 – 23:30\\",\\"mardi: 11:00 – 23:30\\",\\"mercredi: 11:00 – 23:30\\",\\"jeudi: 11:00 – 23:30\\",\\"vendredi: 11:00 – 23:30\\",\\"samedi: 11:00 – 23:30\\",\\"dimanche: 11:00 – 23:30\\"]}"	2024-11-22 17:03:08.372	2024-11-22 17:06:14.251623	2024-11-22 17:06:14.251623	0101000020E610000072A9A514CF240340A2139DC0CF734840
11	Chawachine	ChIJzcxG70ls5kcRnRi_d0qB7nA	63 Av. Edouard Vaillant, 93500 Pantin, France	48.90134650	2.39401940	Avenue Edouard Vaillant	63	93500	Pantin	Île-de-France	France	06 62 82 09 41		OPERATIONAL	4.5	180	\N	"{\\"periods\\":[{\\"close\\":{\\"day\\":1,\\"time\\":\\"0000\\",\\"hours\\":0,\\"minutes\\":0},\\"open\\":{\\"day\\":0,\\"time\\":\\"1130\\",\\"hours\\":11,\\"minutes\\":30}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"0000\\",\\"hours\\":0,\\"minutes\\":0},\\"open\\":{\\"day\\":1,\\"time\\":\\"1130\\",\\"hours\\":11,\\"minutes\\":30}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"0000\\",\\"hours\\":0,\\"minutes\\":0},\\"open\\":{\\"day\\":2,\\"time\\":\\"1130\\",\\"hours\\":11,\\"minutes\\":30}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"0000\\",\\"hours\\":0,\\"minutes\\":0},\\"open\\":{\\"day\\":3,\\"time\\":\\"1130\\",\\"hours\\":11,\\"minutes\\":30}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"0000\\",\\"hours\\":0,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"1130\\",\\"hours\\":11,\\"minutes\\":30}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"0000\\",\\"hours\\":0,\\"minutes\\":0},\\"open\\":{\\"day\\":5,\\"time\\":\\"1130\\",\\"hours\\":11,\\"minutes\\":30}},{\\"close\\":{\\"day\\":0,\\"time\\":\\"0000\\",\\"hours\\":0,\\"minutes\\":0},\\"open\\":{\\"day\\":6,\\"time\\":\\"1130\\",\\"hours\\":11,\\"minutes\\":30}}],\\"weekday_text\\":[\\"lundi: 11:30 – 00:00\\",\\"mardi: 11:30 – 00:00\\",\\"mercredi: 11:30 – 00:00\\",\\"jeudi: 11:30 – 00:00\\",\\"vendredi: 11:30 – 00:00\\",\\"samedi: 11:30 – 00:00\\",\\"dimanche: 11:30 – 00:00\\"]}"	2024-11-22 17:06:46.644	2024-11-22 17:08:23.008001	2024-11-22 17:08:23.008001	0101000020E610000095EAA7A4F32603409AEE75525F734840
26	l'Olivier du Kef	ChIJb2xHFBhz5kcR1gaCnAxz344	73 Rue de Strasbourg, 94300 Vincennes, France	48.85279930	2.43866850	Rue de Strasbourg	73	94300	Vincennes	Île-de-France	France	09 54 65 18 60		OPERATIONAL	4.9	222	\N	"{\\"periods\\":[{\\"close\\":{\\"day\\":0,\\"time\\":\\"1530\\",\\"hours\\":15,\\"minutes\\":30},\\"open\\":{\\"day\\":0,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"1500\\",\\"hours\\":15,\\"minutes\\":0},\\"open\\":{\\"day\\":2,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":2,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"1500\\",\\"hours\\":15,\\"minutes\\":0},\\"open\\":{\\"day\\":3,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":3,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"1500\\",\\"hours\\":15,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"1500\\",\\"hours\\":15,\\"minutes\\":0},\\"open\\":{\\"day\\":5,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":5,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"1500\\",\\"hours\\":15,\\"minutes\\":0},\\"open\\":{\\"day\\":6,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":6,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}}],\\"weekday_text\\":[\\"lundi: Fermé\\",\\"mardi: 12:00 – 15:00, 19:00 – 23:00\\",\\"mercredi: 12:00 – 15:00, 19:00 – 23:00\\",\\"jeudi: 12:00 – 15:00, 19:00 – 23:00\\",\\"vendredi: 12:00 – 15:00, 19:00 – 23:00\\",\\"samedi: 12:00 – 15:00, 19:00 – 23:00\\",\\"dimanche: 12:00 – 15:30\\"]}"	2025-01-19 10:34:15.402	2025-01-19 10:36:29.32972	2025-01-19 10:36:29.32972	0101000020E610000073486AA1648203409EC60787286D4840
7	La Marmite d’Afrique, restaurant social et solidaire	ChIJeUE7njFs5kcRlXaPF__zBz4	116 Rue de Crimée, 75019 Paris, France	48.88528000	2.38330530	Rue de Crimée	116	75019	Paris	Île-de-France	France	09 81 44 33 70	https://lamarmitedafrique.org/	OPERATIONAL	4.4	175	\N	"{\\"periods\\":[{\\"close\\":{\\"day\\":1,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0},\\"open\\":{\\"day\\":1,\\"time\\":\\"1130\\",\\"hours\\":11,\\"minutes\\":30}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0},\\"open\\":{\\"day\\":2,\\"time\\":\\"1130\\",\\"hours\\":11,\\"minutes\\":30}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0},\\"open\\":{\\"day\\":3,\\"time\\":\\"1130\\",\\"hours\\":11,\\"minutes\\":30}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"1130\\",\\"hours\\":11,\\"minutes\\":30}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0},\\"open\\":{\\"day\\":5,\\"time\\":\\"1130\\",\\"hours\\":11,\\"minutes\\":30}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"1800\\",\\"hours\\":18,\\"minutes\\":0},\\"open\\":{\\"day\\":6,\\"time\\":\\"1130\\",\\"hours\\":11,\\"minutes\\":30}}],\\"weekday_text\\":[\\"lundi: 11:30 – 19:00\\",\\"mardi: 11:30 – 19:00\\",\\"mercredi: 11:30 – 19:00\\",\\"jeudi: 11:30 – 19:00\\",\\"vendredi: 11:30 – 19:00\\",\\"samedi: 11:30 – 18:00\\",\\"dimanche: Fermé\\"]}"	2024-11-22 16:53:31.639	2024-11-22 16:54:45.707082	2024-11-22 16:54:45.707082	0101000020E610000058117F5E02110340C5E6E3DA50714840
12	Ngoc Xuyen Saigon	ChIJA0_NBodx5kcROe2nE0DePAw	4 Rue Caillaux, 75013 Paris, France	48.82292030	2.36173490	Rue Caillaux	4	75013	Paris	Île-de-France	France	01 44 24 14 31	http://ngocxuyensaigon.net/	OPERATIONAL	4.5	931	1	"{\\"periods\\":[{\\"close\\":{\\"day\\":0,\\"time\\":\\"1700\\",\\"hours\\":17,\\"minutes\\":0},\\"open\\":{\\"day\\":0,\\"time\\":\\"0930\\",\\"hours\\":9,\\"minutes\\":30}},{\\"close\\":{\\"day\\":1,\\"time\\":\\"1700\\",\\"hours\\":17,\\"minutes\\":0},\\"open\\":{\\"day\\":1,\\"time\\":\\"0930\\",\\"hours\\":9,\\"minutes\\":30}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"1700\\",\\"hours\\":17,\\"minutes\\":0},\\"open\\":{\\"day\\":2,\\"time\\":\\"0930\\",\\"hours\\":9,\\"minutes\\":30}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"1700\\",\\"hours\\":17,\\"minutes\\":0},\\"open\\":{\\"day\\":3,\\"time\\":\\"0930\\",\\"hours\\":9,\\"minutes\\":30}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"1700\\",\\"hours\\":17,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"0930\\",\\"hours\\":9,\\"minutes\\":30}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"1700\\",\\"hours\\":17,\\"minutes\\":0},\\"open\\":{\\"day\\":5,\\"time\\":\\"0930\\",\\"hours\\":9,\\"minutes\\":30}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"1700\\",\\"hours\\":17,\\"minutes\\":0},\\"open\\":{\\"day\\":6,\\"time\\":\\"0930\\",\\"hours\\":9,\\"minutes\\":30}}],\\"weekday_text\\":[\\"lundi: 09:30 – 17:00\\",\\"mardi: 09:30 – 17:00\\",\\"mercredi: 09:30 – 17:00\\",\\"jeudi: 09:30 – 17:00\\",\\"vendredi: 09:30 – 17:00\\",\\"samedi: 09:30 – 17:00\\",\\"dimanche: 09:30 – 17:00\\"]}"	2024-11-22 17:09:37.555	2024-11-22 17:11:19.73563	2024-11-22 17:11:19.73563	0101000020E61000001C936A44D5E4024075DBCF7355694840
13	Dong Tam	ChIJCZ4O-4Zx5kcRiPGMKKlOIcw	12bis Rue Caillaux, 75013 Paris, France	48.82263940	2.36082440	Rue Caillaux	12bis	75013	Paris	Île-de-France	France	09 56 16 83 10		OPERATIONAL	4.6	608	1	"{\\"periods\\":[{\\"close\\":{\\"day\\":0,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":0,\\"time\\":\\"1100\\",\\"hours\\":11,\\"minutes\\":0}},{\\"close\\":{\\"day\\":1,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":1,\\"time\\":\\"1100\\",\\"hours\\":11,\\"minutes\\":0}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":2,\\"time\\":\\"1100\\",\\"hours\\":11,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":3,\\"time\\":\\"1100\\",\\"hours\\":11,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"1100\\",\\"hours\\":11,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":5,\\"time\\":\\"1100\\",\\"hours\\":11,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":6,\\"time\\":\\"1100\\",\\"hours\\":11,\\"minutes\\":0}}],\\"weekday_text\\":[\\"lundi: 11:00 – 23:00\\",\\"mardi: 11:00 – 23:00\\",\\"mercredi: 11:00 – 23:00\\",\\"jeudi: 11:00 – 23:00\\",\\"vendredi: 11:00 – 23:00\\",\\"samedi: 11:00 – 23:00\\",\\"dimanche: 11:00 – 23:00\\"]}"	2024-11-22 17:12:16.599	2024-11-22 17:13:27.03907	2024-11-22 17:13:27.03907	0101000020E610000063CA2CE7F7E2024056B3733F4C694840
14	Pho Co	ChIJMawsuYBx5kcRmWJpCSq4Si8	142 Bd Masséna, 75013 Paris, France	48.81974530	2.36245280	Boulevard Masséna	142	75013	Paris	Île-de-France	France	09 73 88 02 38		OPERATIONAL	4.3	509	2	"{\\"periods\\":[{\\"close\\":{\\"day\\":0,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0},\\"open\\":{\\"day\\":0,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":1,\\"time\\":\\"1500\\",\\"hours\\":15,\\"minutes\\":0},\\"open\\":{\\"day\\":1,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":1,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":1,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"1500\\",\\"hours\\":15,\\"minutes\\":0},\\"open\\":{\\"day\\":2,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":2,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"1500\\",\\"hours\\":15,\\"minutes\\":0},\\"open\\":{\\"day\\":3,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":3,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"1500\\",\\"hours\\":15,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"1500\\",\\"hours\\":15,\\"minutes\\":0},\\"open\\":{\\"day\\":5,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":5,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"1500\\",\\"hours\\":15,\\"minutes\\":0},\\"open\\":{\\"day\\":6,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":6,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}}],\\"weekday_text\\":[\\"lundi: 12:00 – 15:00, 19:00 – 22:00\\",\\"mardi: 12:00 – 15:00, 19:00 – 22:00\\",\\"mercredi: 12:00 – 15:00, 19:00 – 22:00\\",\\"jeudi: 12:00 – 15:00, 19:00 – 22:00\\",\\"vendredi: 12:00 – 15:00, 19:00 – 22:00\\",\\"samedi: 12:00 – 15:00, 19:00 – 22:00\\",\\"dimanche: 12:00 – 19:00\\"]}"	2024-11-22 17:14:09.649	2024-11-22 17:15:31.436741	2024-11-22 17:15:31.436741	0101000020E6100000C0BF52A74DE602405D46FB69ED684840
15	Impérial Choisy 美丽都	ChIJH7bObodx5kcRZvKndkGRXQo	32 Av. de Choisy, 75013 Paris, France	48.82222220	2.36333330	Avenue de Choisy	32	75013	Paris	Île-de-France	France	01 45 86 42 40	http://www.imperialchoisy.fr/menu	OPERATIONAL	3.9	2437	2	"{\\"periods\\":[{\\"close\\":{\\"day\\":0,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":0,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":1,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":1,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":2,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":3,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":5,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":6,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}}],\\"weekday_text\\":[\\"lundi: 12:00 – 23:00\\",\\"mardi: 12:00 – 23:00\\",\\"mercredi: 12:00 – 23:00\\",\\"jeudi: 12:00 – 23:00\\",\\"vendredi: 12:00 – 23:00\\",\\"samedi: 12:00 – 23:00\\",\\"dimanche: 12:00 – 23:00\\"]}"	2024-11-22 17:16:10.864	2024-11-22 17:17:11.846916	2024-11-22 17:17:11.846916	0101000020E6100000CE61084A1BE80240C885B9933E694840
16	Chinatown Olympiades	ChIJ37_JSShy5kcRMQtDD_WUSWw	44 Av. d'Ivry, 75013 Paris, France	48.82352540	2.36570490	Avenue d'Ivry	44	75013	Paris	Île-de-France	France	01 45 84 72 21	https://www.chinatownolympiades.com/	OPERATIONAL	4	627	2	"{\\"periods\\":[{\\"close\\":{\\"day\\":0,\\"time\\":\\"1500\\",\\"hours\\":15,\\"minutes\\":0},\\"open\\":{\\"day\\":0,\\"time\\":\\"1130\\",\\"hours\\":11,\\"minutes\\":30}},{\\"close\\":{\\"day\\":0,\\"time\\":\\"2315\\",\\"hours\\":23,\\"minutes\\":15},\\"open\\":{\\"day\\":0,\\"time\\":\\"1830\\",\\"hours\\":18,\\"minutes\\":30}},{\\"close\\":{\\"day\\":1,\\"time\\":\\"1445\\",\\"hours\\":14,\\"minutes\\":45},\\"open\\":{\\"day\\":1,\\"time\\":\\"1145\\",\\"hours\\":11,\\"minutes\\":45}},{\\"close\\":{\\"day\\":1,\\"time\\":\\"2315\\",\\"hours\\":23,\\"minutes\\":15},\\"open\\":{\\"day\\":1,\\"time\\":\\"1830\\",\\"hours\\":18,\\"minutes\\":30}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"1445\\",\\"hours\\":14,\\"minutes\\":45},\\"open\\":{\\"day\\":2,\\"time\\":\\"1145\\",\\"hours\\":11,\\"minutes\\":45}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"2315\\",\\"hours\\":23,\\"minutes\\":15},\\"open\\":{\\"day\\":2,\\"time\\":\\"1830\\",\\"hours\\":18,\\"minutes\\":30}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"1445\\",\\"hours\\":14,\\"minutes\\":45},\\"open\\":{\\"day\\":3,\\"time\\":\\"1145\\",\\"hours\\":11,\\"minutes\\":45}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"2315\\",\\"hours\\":23,\\"minutes\\":15},\\"open\\":{\\"day\\":3,\\"time\\":\\"1830\\",\\"hours\\":18,\\"minutes\\":30}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"1445\\",\\"hours\\":14,\\"minutes\\":45},\\"open\\":{\\"day\\":4,\\"time\\":\\"1145\\",\\"hours\\":11,\\"minutes\\":45}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"2315\\",\\"hours\\":23,\\"minutes\\":15},\\"open\\":{\\"day\\":4,\\"time\\":\\"1830\\",\\"hours\\":18,\\"minutes\\":30}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"1445\\",\\"hours\\":14,\\"minutes\\":45},\\"open\\":{\\"day\\":5,\\"time\\":\\"1145\\",\\"hours\\":11,\\"minutes\\":45}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"2315\\",\\"hours\\":23,\\"minutes\\":15},\\"open\\":{\\"day\\":5,\\"time\\":\\"1830\\",\\"hours\\":18,\\"minutes\\":30}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"1445\\",\\"hours\\":14,\\"minutes\\":45},\\"open\\":{\\"day\\":6,\\"time\\":\\"1145\\",\\"hours\\":11,\\"minutes\\":45}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"2315\\",\\"hours\\":23,\\"minutes\\":15},\\"open\\":{\\"day\\":6,\\"time\\":\\"1830\\",\\"hours\\":18,\\"minutes\\":30}}],\\"weekday_text\\":[\\"lundi: 11:45 – 14:45, 18:30 – 23:15\\",\\"mardi: 11:45 – 14:45, 18:30 – 23:15\\",\\"mercredi: 11:45 – 14:45, 18:30 – 23:15\\",\\"jeudi: 11:45 – 14:45, 18:30 – 23:15\\",\\"vendredi: 11:45 – 14:45, 18:30 – 23:15\\",\\"samedi: 11:45 – 14:45, 18:30 – 23:15\\",\\"dimanche: 11:30 – 15:00, 18:30 – 23:15\\"]}"	2024-11-22 17:18:00.983	2024-11-22 17:20:06.500647	2024-11-22 17:20:06.500647	0101000020E610000046E5CBB0F6EC02407136C24769694840
17	Khai Tri	ChIJU7RkxYdx5kcR-_WRy0vNacs	93 Av. d'Ivry, 75013 Paris, France	48.82494500	2.36218900	Avenue d'Ivry	93	75013	Paris	Île-de-France	France	01 45 82 95 81	http://banhmikhaitri.netlify.app/	OPERATIONAL	4.6	557	1	"{\\"periods\\":[{\\"close\\":{\\"day\\":0,\\"time\\":\\"1600\\",\\"hours\\":16,\\"minutes\\":0},\\"open\\":{\\"day\\":0,\\"time\\":\\"1000\\",\\"hours\\":10,\\"minutes\\":0}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"1600\\",\\"hours\\":16,\\"minutes\\":0},\\"open\\":{\\"day\\":2,\\"time\\":\\"1000\\",\\"hours\\":10,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"1600\\",\\"hours\\":16,\\"minutes\\":0},\\"open\\":{\\"day\\":3,\\"time\\":\\"1000\\",\\"hours\\":10,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"1600\\",\\"hours\\":16,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"1000\\",\\"hours\\":10,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"1600\\",\\"hours\\":16,\\"minutes\\":0},\\"open\\":{\\"day\\":5,\\"time\\":\\"1000\\",\\"hours\\":10,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"1600\\",\\"hours\\":16,\\"minutes\\":0},\\"open\\":{\\"day\\":6,\\"time\\":\\"1000\\",\\"hours\\":10,\\"minutes\\":0}}],\\"weekday_text\\":[\\"lundi: Fermé\\",\\"mardi: 10:00 – 16:00\\",\\"mercredi: 10:00 – 16:00\\",\\"jeudi: 10:00 – 16:00\\",\\"vendredi: 10:00 – 16:00\\",\\"samedi: 10:00 – 16:00\\",\\"dimanche: 10:00 – 16:00\\"]}"	2024-11-22 17:20:14.549	2024-11-22 17:21:42.466113	2024-11-22 17:21:42.466113	0101000020E61000007EC4AF58C3E50240D6FF39CC97694840
34	Faubourg Daimant	ChIJfXpjH8pv5kcRCD0PIxrn3yY	20 Rue du Faubourg Poissonnière, 75010 Paris, France	48.87233220	2.34802560	Rue du Faubourg Poissonnière	20	75010	Paris	Île-de-France	France	07 88 09 73 48	https://www.daimant.co/faubourg-daimant.html	OPERATIONAL	4.6	2230	\N	"{\\"periods\\":[{\\"close\\":{\\"day\\":0,\\"time\\":\\"1500\\",\\"hours\\":15,\\"minutes\\":0},\\"open\\":{\\"day\\":0,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":0,\\"time\\":\\"2230\\",\\"hours\\":22,\\"minutes\\":30},\\"open\\":{\\"day\\":0,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":1,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":1,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":1,\\"time\\":\\"2230\\",\\"hours\\":22,\\"minutes\\":30},\\"open\\":{\\"day\\":1,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":2,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"2230\\",\\"hours\\":22,\\"minutes\\":30},\\"open\\":{\\"day\\":2,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":3,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"2230\\",\\"hours\\":22,\\"minutes\\":30},\\"open\\":{\\"day\\":3,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":4,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"2230\\",\\"hours\\":22,\\"minutes\\":30},\\"open\\":{\\"day\\":4,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":5,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"2230\\",\\"hours\\":22,\\"minutes\\":30},\\"open\\":{\\"day\\":5,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"1500\\",\\"hours\\":15,\\"minutes\\":0},\\"open\\":{\\"day\\":6,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"2230\\",\\"hours\\":22,\\"minutes\\":30},\\"open\\":{\\"day\\":6,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}}],\\"weekday_text\\":[\\"lundi: 12:00 – 14:30, 19:00 – 22:30\\",\\"mardi: 12:00 – 14:30, 19:00 – 22:30\\",\\"mercredi: 12:00 – 14:30, 19:00 – 22:30\\",\\"jeudi: 12:00 – 14:30, 19:00 – 22:30\\",\\"vendredi: 12:00 – 14:30, 19:00 – 22:30\\",\\"samedi: 12:00 – 15:00, 19:00 – 22:30\\",\\"dimanche: 12:00 – 15:00, 19:00 – 22:30\\"]}"	2025-01-19 11:05:40.334	2025-01-19 11:06:25.571135	2025-01-19 11:06:25.571135	0101000020E6100000C15D51A5C1C80240B61FDF94A86F4840
18	Le Bastringue	ChIJ34Lr49Bt5kcRC4KK7QvBZ5A	67 Quai de la Seine, 75019 Paris, France	48.88798500	2.37697360	Quai de la Seine	67	75019	Paris	Île-de-France	France	01 42 09 89 27		OPERATIONAL	4.4	1900	2	"{\\"periods\\":[{\\"close\\":{\\"day\\":1,\\"time\\":\\"0200\\",\\"hours\\":2,\\"minutes\\":0},\\"open\\":{\\"day\\":0,\\"time\\":\\"0900\\",\\"hours\\":9,\\"minutes\\":0}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"0200\\",\\"hours\\":2,\\"minutes\\":0},\\"open\\":{\\"day\\":1,\\"time\\":\\"0800\\",\\"hours\\":8,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"0200\\",\\"hours\\":2,\\"minutes\\":0},\\"open\\":{\\"day\\":2,\\"time\\":\\"0800\\",\\"hours\\":8,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"0200\\",\\"hours\\":2,\\"minutes\\":0},\\"open\\":{\\"day\\":3,\\"time\\":\\"0800\\",\\"hours\\":8,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"0200\\",\\"hours\\":2,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"0800\\",\\"hours\\":8,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"0200\\",\\"hours\\":2,\\"minutes\\":0},\\"open\\":{\\"day\\":5,\\"time\\":\\"0800\\",\\"hours\\":8,\\"minutes\\":0}},{\\"close\\":{\\"day\\":0,\\"time\\":\\"0200\\",\\"hours\\":2,\\"minutes\\":0},\\"open\\":{\\"day\\":6,\\"time\\":\\"0900\\",\\"hours\\":9,\\"minutes\\":0}}],\\"weekday_text\\":[\\"lundi: 08:00 – 02:00\\",\\"mardi: 08:00 – 02:00\\",\\"mercredi: 08:00 – 02:00\\",\\"jeudi: 08:00 – 02:00\\",\\"vendredi: 08:00 – 02:00\\",\\"samedi: 09:00 – 02:00\\",\\"dimanche: 09:00 – 02:00\\"]}"	2024-11-28 12:13:18.905	2024-11-28 12:13:36.558384	2024-11-28 12:13:36.558384	0101000020E6100000A1A41BBC0A040340562B137EA9714840
19	Chez Magda	ChIJM2edftht5kcR6qPUVbIqrrM	5 Av. Jean Jaurès, 75019 Paris, France	48.88335530	2.37143770	Avenue Jean Jaurès	5	75019	Paris	Île-de-France	France	07 51 20 90 64	https://www.chez-magda.com/	OPERATIONAL	4.5	683	2	"{\\"periods\\":[{\\"close\\":{\\"day\\":0,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":0,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":2,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":3,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":5,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":6,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}}],\\"weekday_text\\":[\\"Monday: Closed\\",\\"Tuesday: 12:00 – 11:00 PM\\",\\"Wednesday: 12:00 – 11:00 PM\\",\\"Thursday: 12:00 – 11:00 PM\\",\\"Friday: 12:00 – 11:00 PM\\",\\"Saturday: 12:00 – 11:00 PM\\",\\"Sunday: 12:00 – 11:00 PM\\"]}"	2024-11-28 13:10:40.996	2024-11-28 13:11:03.593158	2024-11-28 13:11:03.593158	0101000020E6100000FD023054B4F80240C71F56C911714840
21	Chez les Garçons	ChIJLQVBbffq9EcR36EN0D6MVB0	5 Rue Cuvier, 69006 Lyon, France	45.76662710	4.84210500	Rue Cuvier	5	69006	Lyon	Auvergne-Rhône-Alpes	France	04 78 24 51 07		OPERATIONAL	4.6	259	2	"{\\"periods\\":[{\\"close\\":{\\"day\\":0,\\"time\\":\\"2130\\",\\"hours\\":21,\\"minutes\\":30},\\"open\\":{\\"day\\":0,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":1,\\"time\\":\\"2130\\",\\"hours\\":21,\\"minutes\\":30},\\"open\\":{\\"day\\":1,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"2130\\",\\"hours\\":21,\\"minutes\\":30},\\"open\\":{\\"day\\":2,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"2130\\",\\"hours\\":21,\\"minutes\\":30},\\"open\\":{\\"day\\":3,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"2130\\",\\"hours\\":21,\\"minutes\\":30},\\"open\\":{\\"day\\":4,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":5,\\"time\\":\\"0715\\",\\"hours\\":7,\\"minutes\\":15}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"2130\\",\\"hours\\":21,\\"minutes\\":30},\\"open\\":{\\"day\\":6,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}}],\\"weekday_text\\":[\\"lundi: 12:00 – 21:30\\",\\"mardi: 12:00 – 21:30\\",\\"mercredi: 19:00 – 21:30\\",\\"jeudi: 19:00 – 21:30\\",\\"vendredi: 07:15 – 14:30\\",\\"samedi: 19:00 – 21:30\\",\\"dimanche: 19:00 – 21:30\\"]}"	2024-12-02 18:11:44.837	2024-12-02 18:11:56.736289	2024-12-02 18:11:56.736289	0101000020E61000003C31EBC5505E1340195D39D620E24640
22	龙抄手总店 Ravioli du Sichuan	ChIJSSxdJWVv5kcR0e8jp4RbxJE	50 Rue de Provence, 75009 Paris, France	48.87433440	2.33505380	Rue de Provence	50	75009	Paris	Île-de-France	France	01 40 35 75 06		OPERATIONAL	4.5	436	\N	"{\\"periods\\":[{\\"close\\":{\\"day\\":1,\\"time\\":\\"2100\\",\\"hours\\":21,\\"minutes\\":0},\\"open\\":{\\"day\\":1,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"2100\\",\\"hours\\":21,\\"minutes\\":0},\\"open\\":{\\"day\\":2,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"2100\\",\\"hours\\":21,\\"minutes\\":0},\\"open\\":{\\"day\\":3,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"2100\\",\\"hours\\":21,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"2100\\",\\"hours\\":21,\\"minutes\\":0},\\"open\\":{\\"day\\":5,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"2100\\",\\"hours\\":21,\\"minutes\\":0},\\"open\\":{\\"day\\":6,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}}],\\"weekday_text\\":[\\"lundi: 12:00 – 21:00\\",\\"mardi: 12:00 – 21:00\\",\\"mercredi: 12:00 – 21:00\\",\\"jeudi: 12:00 – 21:00\\",\\"vendredi: 12:00 – 21:00\\",\\"samedi: 12:00 – 21:00\\",\\"dimanche: Fermé\\"]}"	2024-12-16 11:42:42.248	2024-12-16 11:42:52.175768	2024-12-16 11:42:52.175768	0101000020E61000004634CBAF30AE024047E28A30EA6F4840
23	KUTI - Montreuil	ChIJQwoZg2xt5kcRjBsBgHiJWxI	3 Rue Victor Hugo, 93100 Montreuil, France	48.85932490	2.43941060	Rue Victor Hugo	3	93100	Montreuil	Île-de-France	France		http://www.kutigroup.com/	OPERATIONAL	4.7	811	\N	""	2025-01-19 10:28:24.784	2025-01-19 10:29:44.423404	2025-01-19 10:29:44.423404	0101000020E61000003B2064B4E9830340B911BB5BFE6D4840
24	KUTI - Petites Ecuries	ChIJmSoRet5v5kcRonDvbYDlA1U	6 R. des Petites Écuries, 75010 Paris, France	48.87308750	2.35387100	Rue des Petites Écuries	6	75010	Paris	Île-de-France	France	01 86 22 29 09	https://www.instagram.com/kutifood	OPERATIONAL	4.7	377	\N	"{\\"periods\\":[{\\"close\\":{\\"day\\":0,\\"time\\":\\"1600\\",\\"hours\\":16,\\"minutes\\":0},\\"open\\":{\\"day\\":0,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":0,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":0,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":1,\\"time\\":\\"1500\\",\\"hours\\":15,\\"minutes\\":0},\\"open\\":{\\"day\\":1,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":1,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":1,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"1500\\",\\"hours\\":15,\\"minutes\\":0},\\"open\\":{\\"day\\":2,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":2,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"1500\\",\\"hours\\":15,\\"minutes\\":0},\\"open\\":{\\"day\\":3,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":3,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"1500\\",\\"hours\\":15,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"1500\\",\\"hours\\":15,\\"minutes\\":0},\\"open\\":{\\"day\\":5,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":5,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"1600\\",\\"hours\\":16,\\"minutes\\":0},\\"open\\":{\\"day\\":6,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":6,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}}],\\"weekday_text\\":[\\"lundi: 12:00 – 15:00, 19:00 – 23:00\\",\\"mardi: 12:00 – 15:00, 19:00 – 23:00\\",\\"mercredi: 12:00 – 15:00, 19:00 – 23:00\\",\\"jeudi: 12:00 – 15:00, 19:00 – 23:00\\",\\"vendredi: 12:00 – 15:00, 19:00 – 23:00\\",\\"samedi: 12:00 – 16:00, 19:00 – 23:00\\",\\"dimanche: 12:00 – 16:00, 19:00 – 23:00\\"]}"	2025-01-19 10:30:32.578	2025-01-19 10:30:52.887166	2025-01-19 10:30:52.887166	0101000020E6100000C405A051BAD40240F085C954C16F4840
74	Menkicchi Ramen	ChIJq99pfklv5kcRm0NDwGCXyjo	41 Rue Sainte-Anne, 75001 Paris, France	48.86652130	2.33556400	Rue Sainte-Anne	41	75001	Paris	Île-de-France	France	01 42 21 11 68	https://kintarogroup.com/menkicchi/	OPERATIONAL	4.4	1367	2	\N	2025-04-27 09:54:28.565182	2025-04-27 09:54:28.569438	2025-04-27 09:54:28.569438	0101000020E610000035B8AD2D3CAF0240CA64822BEA6E4840
75	Mắm From Hanoï	ChIJfecnzi9v5kcRGrNiqAWlNNQ	39 Rue de Cléry, 75002 Paris, France	48.86867610	2.34836490	Rue de Cléry	39	75002	Paris	Île-de-France	France	01 42 33 12 31	https://mamfromhanoi.com/	OPERATIONAL	4.8	908	\N	\N	2025-04-27 09:57:08.414588	2025-04-27 09:57:08.419768	2025-04-27 09:57:08.419768	0101000020E61000003098648973C902408E2848C7306F4840
87	Kitchen Izakaya	ChIJ3R3099Bv5kcRLL5vrd630s8	32 Rue Tiquetonne, 75002 Paris, France	48.86481090	2.34804560	Rue Tiquetonne	32	75002	Paris	Île-de-France	France	09 70 66 18 57	https://www.kitchen-izakaya.com/	OPERATIONAL	4.7	157	\N	\N	2025-04-27 16:50:30.73347	2025-04-27 16:50:30.74417	2025-04-27 16:50:30.74417	0101000020E61000003222AC21CCC80240B75CA21FB26E4840
27	La Café de l'ici	ChIJE6OP3GVu5kcR15DTLU6exL0	19 Rue Léon, 75018 Paris, France	48.88781390	2.35336940	Rue Léon	19	75018	Paris	Île-de-France	France			OPERATIONAL	4.5	133	1	"{\\"periods\\":[{\\"close\\":{\\"day\\":0,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0},\\"open\\":{\\"day\\":0,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0},\\"open\\":{\\"day\\":2,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0},\\"open\\":{\\"day\\":3,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0},\\"open\\":{\\"day\\":5,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0},\\"open\\":{\\"day\\":6,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}}],\\"weekday_text\\":[\\"lundi: Fermé\\",\\"mardi: 12:00 – 19:00\\",\\"mercredi: 12:00 – 19:00\\",\\"jeudi: 12:00 – 19:00\\",\\"vendredi: 12:00 – 19:00\\",\\"samedi: 12:00 – 19:00\\",\\"dimanche: 12:00 – 19:00\\"]}"	2025-01-19 10:39:49.175	2025-01-19 10:40:16.469626	2025-01-19 10:40:16.469626	0101000020E6100000D4410356B3D3024094B7C8E2A3714840
28	Matka	ChIJLceVAbRv5kcRs2VY6jRA8w4	78 R. Quincampoix, 75003 Paris, France	48.86217290	2.35116880	Rue Quincampoix	78	75003	Paris	Île-de-France	France	01 44 93 58 14	https://www.matkarestaurant.fr/	OPERATIONAL	4.6	148	\N	"{\\"periods\\":[{\\"close\\":{\\"day\\":0,\\"time\\":\\"1400\\",\\"hours\\":14,\\"minutes\\":0},\\"open\\":{\\"day\\":0,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":0,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":0,\\"time\\":\\"1930\\",\\"hours\\":19,\\"minutes\\":30}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"1400\\",\\"hours\\":14,\\"minutes\\":0},\\"open\\":{\\"day\\":3,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":3,\\"time\\":\\"1930\\",\\"hours\\":19,\\"minutes\\":30}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"1400\\",\\"hours\\":14,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"1930\\",\\"hours\\":19,\\"minutes\\":30}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"1400\\",\\"hours\\":14,\\"minutes\\":0},\\"open\\":{\\"day\\":5,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":5,\\"time\\":\\"1930\\",\\"hours\\":19,\\"minutes\\":30}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"1400\\",\\"hours\\":14,\\"minutes\\":0},\\"open\\":{\\"day\\":6,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":6,\\"time\\":\\"1930\\",\\"hours\\":19,\\"minutes\\":30}}],\\"weekday_text\\":[\\"lundi: Fermé\\",\\"mardi: Fermé\\",\\"mercredi: 12:00 – 14:00, 19:30 – 22:00\\",\\"jeudi: 12:00 – 14:00, 19:30 – 22:00\\",\\"vendredi: 12:00 – 14:00, 19:30 – 22:00\\",\\"samedi: 12:00 – 14:00, 19:30 – 22:00\\",\\"dimanche: 12:00 – 14:00, 19:30 – 22:00\\"]}"	2025-01-19 10:43:25.033	2025-01-19 10:43:43.120608	2025-01-19 10:43:43.120608	0101000020E610000028017B9631CF0240AD7F7CAE5B6E4840
29	La Cantine Pas Si Loin - Artagon	ChIJ6-nu-n1t5kcRzFwWowMkiM8	Artagon Pantin, 34 Rue Cartier Bresson Bâtiment gauche, 93500 Pantin, France	48.90269550	2.39659430	Rue Cartier Bresson	34	93500	Pantin	Île-de-France	France	06 21 30 25 51	https://linktr.ee/passiloin	OPERATIONAL	4.9	43	\N	"{\\"periods\\":[{\\"close\\":{\\"day\\":2,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":2,\\"time\\":\\"1100\\",\\"hours\\":11,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":3,\\"time\\":\\"1100\\",\\"hours\\":11,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"1100\\",\\"hours\\":11,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":5,\\"time\\":\\"1100\\",\\"hours\\":11,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"1800\\",\\"hours\\":18,\\"minutes\\":0},\\"open\\":{\\"day\\":6,\\"time\\":\\"1100\\",\\"hours\\":11,\\"minutes\\":0}}],\\"weekday_text\\":[\\"lundi: Fermé\\",\\"mardi: 11:00 – 23:00\\",\\"mercredi: 11:00 – 23:00\\",\\"jeudi: 11:00 – 23:00\\",\\"vendredi: 11:00 – 23:00\\",\\"samedi: 11:00 – 18:00\\",\\"dimanche: Fermé\\"]}"	2025-01-19 10:46:23.757	2025-01-19 10:47:37.880601	2025-01-19 10:47:37.880601	0101000020E6100000773DE2A1392C0340895FB1868B734840
30	POUSH	ChIJ9a9R841t5kcRbS8qd_nwkjo	153 Av. Jean Jaurès, 93300 Aubervilliers, France	48.90909240	2.39764560	Avenue Jean Jaurès	153	93300	Aubervilliers	Île-de-France	France	01 88 50 19 59	https://poush.fr/	OPERATIONAL	4.5	91	\N	""	2025-01-19 10:48:59.353	2025-01-19 10:52:15.367982	2025-01-19 10:52:15.367982	0101000020E6100000B72FFBD0602E03406585C7235D744840
31	Chôô Chaï	ChIJSb2pZwBt5kcRDgCyOfNZFz0	185 Av. Jean Jaurès, 93300 Aubervilliers, France	48.91118530	2.39982320	Avenue Jean Jaurès	185	93300	Aubervilliers	Île-de-France	France	07 78 15 72 05	https://sites.google.com/view/choo-chai/accueil/faq	OPERATIONAL	4.9	33	\N	"{\\"periods\\":[{\\"close\\":{\\"day\\":1,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":1,\\"time\\":\\"1130\\",\\"hours\\":11,\\"minutes\\":30}},{\\"close\\":{\\"day\\":1,\\"time\\":\\"2330\\",\\"hours\\":23,\\"minutes\\":30},\\"open\\":{\\"day\\":1,\\"time\\":\\"1830\\",\\"hours\\":18,\\"minutes\\":30}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":2,\\"time\\":\\"1130\\",\\"hours\\":11,\\"minutes\\":30}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"2330\\",\\"hours\\":23,\\"minutes\\":30},\\"open\\":{\\"day\\":2,\\"time\\":\\"1830\\",\\"hours\\":18,\\"minutes\\":30}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":3,\\"time\\":\\"1130\\",\\"hours\\":11,\\"minutes\\":30}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"2330\\",\\"hours\\":23,\\"minutes\\":30},\\"open\\":{\\"day\\":3,\\"time\\":\\"1830\\",\\"hours\\":18,\\"minutes\\":30}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":4,\\"time\\":\\"1130\\",\\"hours\\":11,\\"minutes\\":30}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"0200\\",\\"hours\\":2,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"1830\\",\\"hours\\":18,\\"minutes\\":30}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":5,\\"time\\":\\"1130\\",\\"hours\\":11,\\"minutes\\":30}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"0200\\",\\"hours\\":2,\\"minutes\\":0},\\"open\\":{\\"day\\":5,\\"time\\":\\"1830\\",\\"hours\\":18,\\"minutes\\":30}},{\\"close\\":{\\"day\\":0,\\"time\\":\\"0200\\",\\"hours\\":2,\\"minutes\\":0},\\"open\\":{\\"day\\":6,\\"time\\":\\"1830\\",\\"hours\\":18,\\"minutes\\":30}}],\\"weekday_text\\":[\\"lundi: 11:30 – 14:30, 18:30 – 23:30\\",\\"mardi: 11:30 – 14:30, 18:30 – 23:30\\",\\"mercredi: 11:30 – 14:30, 18:30 – 23:30\\",\\"jeudi: 11:30 – 14:30, 18:30 – 02:00\\",\\"vendredi: 11:30 – 14:30, 18:30 – 02:00\\",\\"samedi: 18:30 – 02:00\\",\\"dimanche: Fermé\\"]}"	2025-01-19 10:53:03.863	2025-01-19 10:54:08.183316	2025-01-19 10:54:08.183316	0101000020E6100000E0748181D6320340480C4CB8A1744840
32	L'inattendu Villecresnes Emilien Rouable	ChIJdXIUN90L5kcRBsDpA9R1nxk	36 Rue du Général Leclerc, 94440 Villecresnes, France	48.72544640	2.53470320	Rue du Général Leclerc	36	94440	Villecresnes	Île-de-France	France	01 75 36 61 52	https://www.restaurantlinattendu.com/?utm_source=gmb	OPERATIONAL	4.9	568	\N	"{\\"periods\\":[{\\"close\\":{\\"day\\":1,\\"time\\":\\"1400\\",\\"hours\\":14,\\"minutes\\":0},\\"open\\":{\\"day\\":1,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"1400\\",\\"hours\\":14,\\"minutes\\":0},\\"open\\":{\\"day\\":2,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"1400\\",\\"hours\\":14,\\"minutes\\":0},\\"open\\":{\\"day\\":3,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"2130\\",\\"hours\\":21,\\"minutes\\":30},\\"open\\":{\\"day\\":3,\\"time\\":\\"1930\\",\\"hours\\":19,\\"minutes\\":30}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"1400\\",\\"hours\\":14,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"2130\\",\\"hours\\":21,\\"minutes\\":30},\\"open\\":{\\"day\\":4,\\"time\\":\\"1930\\",\\"hours\\":19,\\"minutes\\":30}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"1400\\",\\"hours\\":14,\\"minutes\\":0},\\"open\\":{\\"day\\":5,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"2130\\",\\"hours\\":21,\\"minutes\\":30},\\"open\\":{\\"day\\":5,\\"time\\":\\"1930\\",\\"hours\\":19,\\"minutes\\":30}}],\\"weekday_text\\":[\\"lundi: 12:00 – 14:00\\",\\"mardi: 12:00 – 14:00\\",\\"mercredi: 12:00 – 14:00, 19:30 – 21:30\\",\\"jeudi: 12:00 – 14:00, 19:30 – 21:30\\",\\"vendredi: 12:00 – 14:00, 19:30 – 21:30\\",\\"samedi: Fermé\\",\\"dimanche: Fermé\\"]}"	2025-01-19 10:55:29.731	2025-01-19 10:57:58.242584	2025-01-19 10:57:58.242584	0101000020E61000004A88A878124704401F80796DDB5C4840
76	Le Blainville - bistro paris 2	ChIJvVXZoXVv5kcRANOk97UA374	183 Rue St Denis, 75002 Paris, France	48.86578490	2.35054580	Rue Saint Denis	183	75002	Paris	Île-de-France	France	01 71 60 87 84	\N	OPERATIONAL	4.4	236	\N	\N	2025-04-27 10:00:27.060398	2025-04-27 10:00:27.06448	2025-04-27 10:00:27.06448	0101000020E61000005200D6F4EACD0240716F230AD26E4840
95	Mindelo	ChIJ8Xdd_Rhx5kcRtNzGXe1Y9NY	92 Rue Broca, 75013 Paris, France	48.83579500	2.34647880	Rue Broca	92	75013	Paris	Île-de-France	France	01 83 81 95 85	\N	OPERATIONAL	4.7	70	\N	\N	2025-04-27 17:30:29.335549	2025-04-27 17:30:29.341363	2025-04-27 17:30:29.341363	0101000020E6100000000F56AD96C5024085949F54FB6A4840
33	Restaurant Omar Dhiab	ChIJR7fpoO5v5kcRlFje00R0PpI	23 Rue Hérold, 75001 Paris, France	48.86517950	2.34187710	Rue Hérold	23	75001	Paris	Île-de-France	France	01 42 33 52 47	https://omardhiab.com/	OPERATIONAL	4.9	944	\N	"{\\"periods\\":[{\\"close\\":{\\"day\\":1,\\"time\\":\\"1330\\",\\"hours\\":13,\\"minutes\\":30},\\"open\\":{\\"day\\":1,\\"time\\":\\"1230\\",\\"hours\\":12,\\"minutes\\":30}},{\\"close\\":{\\"day\\":1,\\"time\\":\\"2100\\",\\"hours\\":21,\\"minutes\\":0},\\"open\\":{\\"day\\":1,\\"time\\":\\"1930\\",\\"hours\\":19,\\"minutes\\":30}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"1330\\",\\"hours\\":13,\\"minutes\\":30},\\"open\\":{\\"day\\":2,\\"time\\":\\"1230\\",\\"hours\\":12,\\"minutes\\":30}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"2100\\",\\"hours\\":21,\\"minutes\\":0},\\"open\\":{\\"day\\":2,\\"time\\":\\"1930\\",\\"hours\\":19,\\"minutes\\":30}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"1330\\",\\"hours\\":13,\\"minutes\\":30},\\"open\\":{\\"day\\":3,\\"time\\":\\"1230\\",\\"hours\\":12,\\"minutes\\":30}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"2100\\",\\"hours\\":21,\\"minutes\\":0},\\"open\\":{\\"day\\":3,\\"time\\":\\"1930\\",\\"hours\\":19,\\"minutes\\":30}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"1330\\",\\"hours\\":13,\\"minutes\\":30},\\"open\\":{\\"day\\":4,\\"time\\":\\"1230\\",\\"hours\\":12,\\"minutes\\":30}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"2100\\",\\"hours\\":21,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"1930\\",\\"hours\\":19,\\"minutes\\":30}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"1330\\",\\"hours\\":13,\\"minutes\\":30},\\"open\\":{\\"day\\":5,\\"time\\":\\"1230\\",\\"hours\\":12,\\"minutes\\":30}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"2100\\",\\"hours\\":21,\\"minutes\\":0},\\"open\\":{\\"day\\":5,\\"time\\":\\"1930\\",\\"hours\\":19,\\"minutes\\":30}}],\\"weekday_text\\":[\\"lundi: 12:30 – 13:30, 19:30 – 21:00\\",\\"mardi: 12:30 – 13:30, 19:30 – 21:00\\",\\"mercredi: 12:30 – 13:30, 19:30 – 21:00\\",\\"jeudi: 12:30 – 13:30, 19:30 – 21:00\\",\\"vendredi: 12:30 – 13:30, 19:30 – 21:00\\",\\"samedi: Fermé\\",\\"dimanche: Fermé\\"]}"	2025-01-19 10:59:27.892	2025-01-19 11:00:59.613209	2025-01-19 11:00:59.613209	0101000020E6100000B5029E0F2ABC0240B7D5AC33BE6E4840
35	Chez lili apsara	ChIJm96XGV5t5kcRxw9Fe0HX738	12 Bd Chanzy, 93100 Montreuil, France	48.85859700	2.43523810	Boulevard Chanzy	12	93100	Montreuil	Île-de-France	France			OPERATIONAL	4.6	49	\N	"{\\"periods\\":[{\\"close\\":{\\"day\\":3,\\"time\\":\\"1500\\",\\"hours\\":15,\\"minutes\\":0},\\"open\\":{\\"day\\":3,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"1500\\",\\"hours\\":15,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"1500\\",\\"hours\\":15,\\"minutes\\":0},\\"open\\":{\\"day\\":5,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"1600\\",\\"hours\\":16,\\"minutes\\":0},\\"open\\":{\\"day\\":6,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}}],\\"weekday_text\\":[\\"lundi: Fermé\\",\\"mardi: Fermé\\",\\"mercredi: 12:00 – 15:00\\",\\"jeudi: 12:00 – 15:00\\",\\"vendredi: 12:00 – 15:00\\",\\"samedi: 12:00 – 16:00\\",\\"dimanche: Fermé\\"]}"	2025-01-19 11:08:09.382	2025-01-19 11:09:17.760577	2025-01-19 11:09:17.760577	0101000020E610000011C9EB1C5E7B0340CCB8A981E66D4840
36	Mây Bay - Restaurant vietnamien vegan végétarien	ChIJI4tHr7xz5kcR4DOVb1kw8PU	33 Rue des Laitières, 94300 Vincennes, France	48.84742340	2.42286760	Rue des Laitières	33	94300	Vincennes	Île-de-France	France	01 43 28 86 91	https://maybayrestaurant.com/	OPERATIONAL	4.8	1476	2	"{\\"periods\\":[{\\"close\\":{\\"day\\":0,\\"time\\":\\"1500\\",\\"hours\\":15,\\"minutes\\":0},\\"open\\":{\\"day\\":0,\\"time\\":\\"1130\\",\\"hours\\":11,\\"minutes\\":30}},{\\"close\\":{\\"day\\":1,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":1,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":1,\\"time\\":\\"2130\\",\\"hours\\":21,\\"minutes\\":30},\\"open\\":{\\"day\\":1,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":2,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"2130\\",\\"hours\\":21,\\"minutes\\":30},\\"open\\":{\\"day\\":2,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":3,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"2130\\",\\"hours\\":21,\\"minutes\\":30},\\"open\\":{\\"day\\":3,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":4,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"2130\\",\\"hours\\":21,\\"minutes\\":30},\\"open\\":{\\"day\\":4,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":5,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"2130\\",\\"hours\\":21,\\"minutes\\":30},\\"open\\":{\\"day\\":5,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":6,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"2130\\",\\"hours\\":21,\\"minutes\\":30},\\"open\\":{\\"day\\":6,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}}],\\"weekday_text\\":[\\"lundi: 12:00 – 14:30, 19:00 – 21:30\\",\\"mardi: 12:00 – 14:30, 19:00 – 21:30\\",\\"mercredi: 12:00 – 14:30, 19:00 – 21:30\\",\\"jeudi: 12:00 – 14:30, 19:00 – 21:30\\",\\"vendredi: 12:00 – 14:30, 19:00 – 21:30\\",\\"samedi: 12:00 – 14:30, 19:00 – 21:30\\",\\"dimanche: 11:30 – 15:00\\"]}"	2025-01-19 11:12:37.929	2025-01-19 11:14:28.441017	2025-01-19 11:14:28.441017	0101000020E6100000D84D846808620340BC6EB65E786C4840
37	LA COLLECTIVE PARISIENNE	ChIJnzrxOihx5kcRgov8kYVzQ14	70 Rue François Miron, 75004 Paris, France	48.85536800	2.35868030	Rue François Miron	70	75004	Paris	Île-de-France	France		https://www.facebook.com/lacollectiveparisienne	OPERATIONAL	4.9	67	\N	"{\\"periods\\":[{\\"close\\":{\\"day\\":1,\\"time\\":\\"1700\\",\\"hours\\":17,\\"minutes\\":0},\\"open\\":{\\"day\\":1,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"1700\\",\\"hours\\":17,\\"minutes\\":0},\\"open\\":{\\"day\\":2,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"1700\\",\\"hours\\":17,\\"minutes\\":0},\\"open\\":{\\"day\\":3,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"1700\\",\\"hours\\":17,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"1700\\",\\"hours\\":17,\\"minutes\\":0},\\"open\\":{\\"day\\":5,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"1700\\",\\"hours\\":17,\\"minutes\\":0},\\"open\\":{\\"day\\":6,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}}],\\"weekday_text\\":[\\"lundi: 12:00 – 17:00\\",\\"mardi: 12:00 – 17:00\\",\\"mercredi: 12:00 – 17:00\\",\\"jeudi: 12:00 – 17:00\\",\\"vendredi: 12:00 – 17:00\\",\\"samedi: 12:00 – 17:00\\",\\"dimanche: Fermé\\"]}"	2025-01-19 11:15:18.682	2025-01-19 11:17:43.727309	2025-01-19 11:17:43.727309	0101000020E610000079C1F1C693DE0240C005D9B27C6D4840
38	Le Pouilly-Reuilly	ChIJ60JOUKVt5kcRdz8ahbdFJ3s	68 Rue André Joineau, 93310 Le Pré-Saint-Gervais, France	48.88467430	2.40360860	Rue André Joineau	68	93310	Le Pré-Saint-Gervais	Île-de-France	France	09 88 07 65 99		OPERATIONAL	4.2	230	3	"{\\"periods\\":[{\\"close\\":{\\"day\\":1,\\"time\\":\\"1500\\",\\"hours\\":15,\\"minutes\\":0},\\"open\\":{\\"day\\":1,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":1,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":1,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"1500\\",\\"hours\\":15,\\"minutes\\":0},\\"open\\":{\\"day\\":2,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":2,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"1500\\",\\"hours\\":15,\\"minutes\\":0},\\"open\\":{\\"day\\":3,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":3,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"1500\\",\\"hours\\":15,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"1500\\",\\"hours\\":15,\\"minutes\\":0},\\"open\\":{\\"day\\":5,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":5,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"1500\\",\\"hours\\":15,\\"minutes\\":0},\\"open\\":{\\"day\\":6,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":6,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}}],\\"weekday_text\\":[\\"lundi: 12:00 – 15:00, 19:00 – 23:00\\",\\"mardi: 12:00 – 15:00, 19:00 – 23:00\\",\\"mercredi: 12:00 – 15:00, 19:00 – 23:00\\",\\"jeudi: 12:00 – 15:00, 19:00 – 23:00\\",\\"vendredi: 12:00 – 15:00, 19:00 – 23:00\\",\\"samedi: 12:00 – 15:00, 19:00 – 23:00\\",\\"dimanche: Fermé\\"]}"	2025-01-19 11:18:09.687	2025-01-19 11:19:56.522826	2025-01-19 11:19:56.522826	0101000020E610000024134B25973A03404C0EE9013D714840
39	La Blague café associatif	ChIJw4nz9lNt5kcRf4gHEHnaxtY	126 Rue Danielle-Casanova, 93300 Aubervilliers, France	48.91544790	2.39934550	Rue Danielle-Casanova	126	93300	Aubervilliers	Île-de-France	France	01 79 64 37 34	http://cafelablague.fr/	OPERATIONAL	4.9	34	\N	"{\\"periods\\":[{\\"close\\":{\\"day\\":2,\\"time\\":\\"1800\\",\\"hours\\":18,\\"minutes\\":0},\\"open\\":{\\"day\\":2,\\"time\\":\\"1100\\",\\"hours\\":11,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"1800\\",\\"hours\\":18,\\"minutes\\":0},\\"open\\":{\\"day\\":3,\\"time\\":\\"1100\\",\\"hours\\":11,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"1800\\",\\"hours\\":18,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"0900\\",\\"hours\\":9,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"2100\\",\\"hours\\":21,\\"minutes\\":0},\\"open\\":{\\"day\\":5,\\"time\\":\\"1100\\",\\"hours\\":11,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"1130\\",\\"hours\\":11,\\"minutes\\":30},\\"open\\":{\\"day\\":6,\\"time\\":\\"0900\\",\\"hours\\":9,\\"minutes\\":0}}],\\"weekday_text\\":[\\"lundi: Fermé\\",\\"mardi: 11:00 – 18:00\\",\\"mercredi: 11:00 – 18:00\\",\\"jeudi: 09:00 – 18:00\\",\\"vendredi: 11:00 – 21:00\\",\\"samedi: 09:00 – 11:30\\",\\"dimanche: Fermé\\"]}"	2025-01-19 11:21:30.121	2025-01-19 11:23:01.759694	2025-01-19 11:23:01.759694	0101000020E61000002A70B20DDC3103408FD893652D754840
77	Série Limithée	ChIJNW6NlQhy5kcRD6ktL-pk_aA	24 Rue Trousseau, 75011 Paris, France	48.85177440	2.37895890	Rue Trousseau	24	75011	Paris	Île-de-France	France	01 48 06 27 97	https://www.serielimithee.com/	OPERATIONAL	4.6	77	\N	\N	2025-04-27 10:02:54.351207	2025-04-27 10:02:54.354189	2025-04-27 10:02:54.354189	0101000020E61000009F39909A1B080340F6C88BF1066D4840
88	Public House Paris	ChIJpZfi4plv5kcRyh_s6_A8QeQ	21 Rue Daunou, 75002 Paris, France	48.86992670	2.33026200	Rue Daunou	21	75002	Paris	Île-de-France	France	01 77 37 87 93	https://www.publichouseparis.fr/	OPERATIONAL	4.5	2218	2	\N	2025-04-27 16:55:15.417324	2025-04-27 16:55:15.424521	2025-04-27 16:55:15.424521	0101000020E610000075E4486760A40240673513C2596F4840
92	Namak - Restaurant Perse	ChIJTwF3j0Rv5kcRBitqIAqFIp4	18 Rue Saint-Lazare, 75009 Paris, France	48.87687860	2.33767650	Rue Saint-Lazare	18	75009	Paris	Île-de-France	France	09 73 36 32 71	https://bookings.zenchef.com/results?rid=365444&pid=1001	OPERATIONAL	4.8	881	\N	\N	2025-04-27 17:22:46.406401	2025-04-27 17:22:46.41309	2025-04-27 17:22:46.41309	0101000020E61000009F05A1BC8FB30240F8C7D68E3D704840
1	La Guincheuse	ChIJ3cnKNXZu5kcR2P70T35BDwY	266 Rue du Faubourg Saint-Martin, 75010 Paris, France	48.88320810	2.36796490	Rue du Faubourg Saint-Martin	266	75010	Paris	Île-de-France	France	01 42 09 41 53	https://www.instagram.com/laguincheuse/	OPERATIONAL	4.5	426	2	"{\\"periods\\":[{\\"close\\":{\\"day\\":2,\\"time\\":\\"0200\\",\\"hours\\":2,\\"minutes\\":0},\\"open\\":{\\"day\\":1,\\"time\\":\\"1100\\",\\"hours\\":11,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"0200\\",\\"hours\\":2,\\"minutes\\":0},\\"open\\":{\\"day\\":2,\\"time\\":\\"1100\\",\\"hours\\":11,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"0200\\",\\"hours\\":2,\\"minutes\\":0},\\"open\\":{\\"day\\":3,\\"time\\":\\"1100\\",\\"hours\\":11,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"0200\\",\\"hours\\":2,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"1100\\",\\"hours\\":11,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"0200\\",\\"hours\\":2,\\"minutes\\":0},\\"open\\":{\\"day\\":5,\\"time\\":\\"1100\\",\\"hours\\":11,\\"minutes\\":0}},{\\"close\\":{\\"day\\":0,\\"time\\":\\"0200\\",\\"hours\\":2,\\"minutes\\":0},\\"open\\":{\\"day\\":6,\\"time\\":\\"1800\\",\\"hours\\":18,\\"minutes\\":0}}],\\"weekday_text\\":[\\"Monday: 11:00 AM – 2:00 AM\\",\\"Tuesday: 11:00 AM – 2:00 AM\\",\\"Wednesday: 11:00 AM – 2:00 AM\\",\\"Thursday: 11:00 AM – 2:00 AM\\",\\"Friday: 11:00 AM – 2:00 AM\\",\\"Saturday: 6:00 PM – 2:00 AM\\",\\"Sunday: Closed\\"]}"	2025-02-10 17:47:23.105	2024-11-16 22:10:07.889083	2025-02-10 17:47:43.964086	0101000020E6100000779BDC9497F10240F98788F60C714840
20	Le Baron Rouge	ChIJNTd-9QVy5kcRSktNBvRTsao	1 Rue Théophile Roussel, 75012 Paris, France	48.84944610	2.37735880	Rue Théophile Roussel	1	75012	Paris	Île-de-France	France	01 43 43 14 32	http://lebaronrouge.net/	OPERATIONAL	4.7	1364	1	"{\\"periods\\":[{\\"close\\":{\\"day\\":0,\\"time\\":\\"1600\\",\\"hours\\":16,\\"minutes\\":0},\\"open\\":{\\"day\\":0,\\"time\\":\\"1000\\",\\"hours\\":10,\\"minutes\\":0}},{\\"close\\":{\\"day\\":1,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":1,\\"time\\":\\"1700\\",\\"hours\\":17,\\"minutes\\":0}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"1400\\",\\"hours\\":14,\\"minutes\\":0},\\"open\\":{\\"day\\":2,\\"time\\":\\"1000\\",\\"hours\\":10,\\"minutes\\":0}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":2,\\"time\\":\\"1700\\",\\"hours\\":17,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"1400\\",\\"hours\\":14,\\"minutes\\":0},\\"open\\":{\\"day\\":3,\\"time\\":\\"1000\\",\\"hours\\":10,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":3,\\"time\\":\\"1700\\",\\"hours\\":17,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"1400\\",\\"hours\\":14,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"1000\\",\\"hours\\":10,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"1700\\",\\"hours\\":17,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"1400\\",\\"hours\\":14,\\"minutes\\":0},\\"open\\":{\\"day\\":5,\\"time\\":\\"1000\\",\\"hours\\":10,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"2130\\",\\"hours\\":21,\\"minutes\\":30},\\"open\\":{\\"day\\":5,\\"time\\":\\"1700\\",\\"hours\\":17,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"1500\\",\\"hours\\":15,\\"minutes\\":0},\\"open\\":{\\"day\\":6,\\"time\\":\\"1000\\",\\"hours\\":10,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"2130\\",\\"hours\\":21,\\"minutes\\":30},\\"open\\":{\\"day\\":6,\\"time\\":\\"1700\\",\\"hours\\":17,\\"minutes\\":0}}],\\"weekday_text\\":[\\"Monday: 5:00 – 10:00 PM\\",\\"Tuesday: 10:00 AM – 2:00 PM, 5:00 – 10:00 PM\\",\\"Wednesday: 10:00 AM – 2:00 PM, 5:00 – 10:00 PM\\",\\"Thursday: 10:00 AM – 2:00 PM, 5:00 – 10:00 PM\\",\\"Friday: 10:00 AM – 2:00 PM, 5:00 – 9:30 PM\\",\\"Saturday: 10:00 AM – 3:00 PM, 5:00 – 9:30 PM\\",\\"Sunday: 10:00 AM – 4:00 PM\\"]}"	2025-02-10 17:47:56.654	2024-12-02 15:51:33.209449	2025-02-10 17:48:22.120548	0101000020E6100000C9DCC6B0D40403407D9B59A6BA6C4840
40	Magazzino52	ChIJ7RadcWFtiEcRiCVMIQFmXPs	Via Giovanni Giolitti, 52/A, 10123 Torino TO, Italy	45.06310120	7.69289130	Via Giovanni Giolitti	52/A	10123	Torino	Piemonte	Italy	011 427 1938	http://www.magazzino52.it/	OPERATIONAL	4.6	383	3	"{\\"periods\\":[{\\"close\\":{\\"day\\":1,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":1,\\"time\\":\\"1230\\",\\"hours\\":12,\\"minutes\\":30}},{\\"close\\":{\\"day\\":1,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":1,\\"time\\":\\"1930\\",\\"hours\\":19,\\"minutes\\":30}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":2,\\"time\\":\\"1230\\",\\"hours\\":12,\\"minutes\\":30}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":2,\\"time\\":\\"1930\\",\\"hours\\":19,\\"minutes\\":30}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":3,\\"time\\":\\"1230\\",\\"hours\\":12,\\"minutes\\":30}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":3,\\"time\\":\\"1930\\",\\"hours\\":19,\\"minutes\\":30}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":4,\\"time\\":\\"1230\\",\\"hours\\":12,\\"minutes\\":30}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"1930\\",\\"hours\\":19,\\"minutes\\":30}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":5,\\"time\\":\\"1230\\",\\"hours\\":12,\\"minutes\\":30}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":5,\\"time\\":\\"1930\\",\\"hours\\":19,\\"minutes\\":30}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"2300\\",\\"hours\\":23,\\"minutes\\":0},\\"open\\":{\\"day\\":6,\\"time\\":\\"1930\\",\\"hours\\":19,\\"minutes\\":30}}],\\"weekday_text\\":[\\"Monday: 12:30 – 2:30 PM, 7:30 – 11:00 PM\\",\\"Tuesday: 12:30 – 2:30 PM, 7:30 – 11:00 PM\\",\\"Wednesday: 12:30 – 2:30 PM, 7:30 – 11:00 PM\\",\\"Thursday: 12:30 – 2:30 PM, 7:30 – 11:00 PM\\",\\"Friday: 12:30 – 2:30 PM, 7:30 – 11:00 PM\\",\\"Saturday: 7:30 – 11:00 PM\\",\\"Sunday: Closed\\"]}"	2025-02-10 17:48:36.167	2025-02-10 17:49:00.081806	2025-02-10 17:49:00.081806	0101000020E610000051BB044C85C51E404F2B3BB313884640
41	The Fat Duck	ChIJ9847-dN8dkgRTNy_Eh1e5RE	High St, Bray, Maidenhead SL6 2AQ, UK	51.50791400	-0.70174800	High Street		SL6 2AQ	Bray	England	United Kingdom	01628 580333	http://www.thefatduck.co.uk/	OPERATIONAL	4.7	1322	4	"{\\"periods\\":[{\\"close\\":{\\"day\\":0,\\"time\\":\\"1315\\",\\"hours\\":13,\\"minutes\\":15},\\"open\\":{\\"day\\":0,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":0,\\"time\\":\\"2015\\",\\"hours\\":20,\\"minutes\\":15},\\"open\\":{\\"day\\":0,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"1315\\",\\"hours\\":13,\\"minutes\\":15},\\"open\\":{\\"day\\":2,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"2015\\",\\"hours\\":20,\\"minutes\\":15},\\"open\\":{\\"day\\":2,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"1315\\",\\"hours\\":13,\\"minutes\\":15},\\"open\\":{\\"day\\":3,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"2015\\",\\"hours\\":20,\\"minutes\\":15},\\"open\\":{\\"day\\":3,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"1315\\",\\"hours\\":13,\\"minutes\\":15},\\"open\\":{\\"day\\":4,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"2015\\",\\"hours\\":20,\\"minutes\\":15},\\"open\\":{\\"day\\":4,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"1315\\",\\"hours\\":13,\\"minutes\\":15},\\"open\\":{\\"day\\":5,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"2015\\",\\"hours\\":20,\\"minutes\\":15},\\"open\\":{\\"day\\":5,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"1315\\",\\"hours\\":13,\\"minutes\\":15},\\"open\\":{\\"day\\":6,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"2015\\",\\"hours\\":20,\\"minutes\\":15},\\"open\\":{\\"day\\":6,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}}],\\"weekday_text\\":[\\"Monday: Closed\\",\\"Tuesday: 12:00 – 1:15 PM, 7:00 – 8:15 PM\\",\\"Wednesday: 12:00 – 1:15 PM, 7:00 – 8:15 PM\\",\\"Thursday: 12:00 – 1:15 PM, 7:00 – 8:15 PM\\",\\"Friday: 12:00 – 1:15 PM, 7:00 – 8:15 PM\\",\\"Saturday: 12:00 – 1:15 PM, 7:00 – 8:15 PM\\",\\"Sunday: 12:00 – 1:15 PM, 7:00 – 8:15 PM\\"]}"	2025-02-10 18:02:27.238	2025-02-10 18:02:50.466029	2025-02-10 18:02:50.466029	0101000020E6100000AE11C138B874E6BF1C97715303C14940
78	Nakatsu	ChIJW8bKgPJv5kcRV7X9qGsXCWo	25 Rue Ramey, 75018 Paris, France	48.88845270	2.34672680	Rue Ramey	25	75018	Paris	Île-de-France	France	01 42 58 11 89	https://nakatsu.fr/	OPERATIONAL	4.7	353	\N	\N	2025-04-27 10:15:36.551341	2025-04-27 10:15:36.563466	2025-04-27 10:15:36.563466	0101000020E6100000822C55B318C602407E456DD1B8714840
89	Argile restaurant	ChIJI1msWs1v5kcRGGgBz0v1GAU	4 Rue de Milan, 75009 Paris, France	48.87900460	2.32906370	Rue de Milan	4	75009	Paris	Île-de-France	France	06 46 63 57 50	https://www.instagram.com/argile_restaurant/?hl=fr	OPERATIONAL	4.8	41	\N	\N	2025-04-27 17:01:53.602871	2025-04-27 17:01:53.605716	2025-04-27 17:01:53.605716	0101000020E6100000F2672E26ECA102404C04053983704840
93	De l'Amitié Café	ChIJP754vndy5kcRxcroqionqvc	22 Rue des Vignoles, 75020 Paris, France	48.85351980	2.39896270	Rue des Vignoles	22	75020	Paris	Île-de-France	France	06 65 52 80 78	\N	OPERATIONAL	5	11	\N	\N	2025-04-27 17:25:31.225068	2025-04-27 17:25:31.228292	2025-04-27 17:25:31.228292	0101000020E61000004397265B1331034086BE0523406D4840
94	Kaun Neak Sre	ChIJK-LBrX1u5kcRjSLKwWf5CFk	10 Rue Boucry, 75018 Paris, France	48.89391900	2.36225090	Rue Boucry	10	75018	Paris	Île-de-France	France	01 40 36 97 32	https://kaunneaksre.eatbu.com/?lang=fr	OPERATIONAL	4.4	142	1	\N	2025-04-27 17:28:19.682071	2025-04-27 17:28:19.688972	2025-04-27 17:28:19.688972	0101000020E61000009192C3CCE3E50240F22213F06B724840
42	Restaurant Aux Perchés	ChIJz432B3hx5kcRp9BF9kr3jZs	25 Rue Servandoni, 75006 Paris, France	48.84930580	2.33487750	Rue Servandoni	25	75006	Paris	Île-de-France	France	06 74 35 01 90	https://www.auxperches.com/	OPERATIONAL	4.8	341	\N	"{\\"periods\\":[{\\"close\\":{\\"day\\":2,\\"time\\":\\"1400\\",\\"hours\\":14,\\"minutes\\":0},\\"open\\":{\\"day\\":2,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"2230\\",\\"hours\\":22,\\"minutes\\":30},\\"open\\":{\\"day\\":2,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"1400\\",\\"hours\\":14,\\"minutes\\":0},\\"open\\":{\\"day\\":3,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"2230\\",\\"hours\\":22,\\"minutes\\":30},\\"open\\":{\\"day\\":3,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"1400\\",\\"hours\\":14,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"2230\\",\\"hours\\":22,\\"minutes\\":30},\\"open\\":{\\"day\\":4,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"1400\\",\\"hours\\":14,\\"minutes\\":0},\\"open\\":{\\"day\\":5,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"2230\\",\\"hours\\":22,\\"minutes\\":30},\\"open\\":{\\"day\\":5,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"1400\\",\\"hours\\":14,\\"minutes\\":0},\\"open\\":{\\"day\\":6,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"2230\\",\\"hours\\":22,\\"minutes\\":30},\\"open\\":{\\"day\\":6,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}}],\\"weekday_text\\":[\\"lundi: Fermé\\",\\"mardi: 12:00 – 14:00, 19:00 – 22:30\\",\\"mercredi: 12:00 – 14:00, 19:00 – 22:30\\",\\"jeudi: 12:00 – 14:00, 19:00 – 22:30\\",\\"vendredi: 12:00 – 14:00, 19:00 – 22:30\\",\\"samedi: 12:00 – 14:00, 19:00 – 22:30\\",\\"dimanche: Fermé\\"]}"	2025-02-21 17:44:21.817	2025-02-21 17:45:20.466719	2025-02-21 17:45:20.466719	0101000020E610000076543541D4AD0240CDA66D0DB66C4840
43	Moderno	ChIJ1QLz4odt5kcR77F-5ZAcFtA	12 Rue Vitruve, 75020 Paris, France	48.85649900	2.40228010	Rue Vitruve	12	75020	Paris	Île-de-France	France	09 56 27 11 84	https://moderno-xx.com/	OPERATIONAL	4.9	42	\N	"{\\"periods\\":[{\\"close\\":{\\"day\\":1,\\"time\\":\\"0100\\",\\"hours\\":1,\\"minutes\\":0},\\"open\\":{\\"day\\":0,\\"time\\":\\"1100\\",\\"hours\\":11,\\"minutes\\":0}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"0100\\",\\"hours\\":1,\\"minutes\\":0},\\"open\\":{\\"day\\":1,\\"time\\":\\"1100\\",\\"hours\\":11,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"0100\\",\\"hours\\":1,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"1100\\",\\"hours\\":11,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"0100\\",\\"hours\\":1,\\"minutes\\":0},\\"open\\":{\\"day\\":5,\\"time\\":\\"1100\\",\\"hours\\":11,\\"minutes\\":0}},{\\"close\\":{\\"day\\":0,\\"time\\":\\"0100\\",\\"hours\\":1,\\"minutes\\":0},\\"open\\":{\\"day\\":6,\\"time\\":\\"1100\\",\\"hours\\":11,\\"minutes\\":0}}],\\"weekday_text\\":[\\"lundi: 11:00 – 01:00\\",\\"mardi: Fermé\\",\\"mercredi: Fermé\\",\\"jeudi: 11:00 – 01:00\\",\\"vendredi: 11:00 – 01:00\\",\\"samedi: 11:00 – 01:00\\",\\"dimanche: 11:00 – 01:00\\"]}"	2025-02-21 17:50:49.462	2025-02-21 17:51:21.110368	2025-02-21 17:51:21.110368	0101000020E610000023A70AA1DE37034042075DC2A16D4840
44	Leven	ChIJO6vg8H5v5kcR3aErJ4y7V-o	110 Rue Montmartre, 75002 Paris, France	48.86759820	2.34406460	Rue Montmartre	110	75002	Paris	Île-de-France	France	01 53 40 84 97	https://linktr.ee/levenfoodeli	OPERATIONAL	4.9	209	\N	"{\\"periods\\":[{\\"close\\":{\\"day\\":0,\\"time\\":\\"1530\\",\\"hours\\":15,\\"minutes\\":30},\\"open\\":{\\"day\\":0,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":1,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":1,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":2,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":2,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":3,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":3,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":4,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"2230\\",\\"hours\\":22,\\"minutes\\":30},\\"open\\":{\\"day\\":4,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":5,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"2230\\",\\"hours\\":22,\\"minutes\\":30},\\"open\\":{\\"day\\":5,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"1530\\",\\"hours\\":15,\\"minutes\\":30},\\"open\\":{\\"day\\":6,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"2230\\",\\"hours\\":22,\\"minutes\\":30},\\"open\\":{\\"day\\":6,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}}],\\"weekday_text\\":[\\"lundi: 12:00 – 14:30\\",\\"mardi: 12:00 – 14:30, 19:00 – 22:00\\",\\"mercredi: 12:00 – 14:30, 19:00 – 22:00\\",\\"jeudi: 12:00 – 14:30, 19:00 – 22:30\\",\\"vendredi: 12:00 – 14:30, 19:00 – 22:30\\",\\"samedi: 12:00 – 15:30, 19:00 – 22:30\\",\\"dimanche: 12:00 – 15:30\\"]}"	2025-02-21 17:54:11.28	2025-02-21 17:56:24.354564	2025-02-21 17:56:24.354564	0101000020E6100000C9B0E5F0A4C00240C48833750D6F4840
45	Menkicchi Ramen	ChIJ86ZRJvNv5kcREWEN6AAQna8	1 Rue de la Grange Batelière, 75009 Paris, France	48.87292600	2.34274660	Rue de la Grange Batelière	1	75009	Paris	Île-de-France	France	01 47 70 41 65	https://kintarogroup.com/menkicchi/	OPERATIONAL	4.6	394	2	"{\\"periods\\":[{\\"close\\":{\\"day\\":0,\\"time\\":\\"1530\\",\\"hours\\":15,\\"minutes\\":30},\\"open\\":{\\"day\\":0,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":0,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":0,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":1,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":1,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":1,\\"time\\":\\"2230\\",\\"hours\\":22,\\"minutes\\":30},\\"open\\":{\\"day\\":1,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":2,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"2230\\",\\"hours\\":22,\\"minutes\\":30},\\"open\\":{\\"day\\":2,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":3,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"2230\\",\\"hours\\":22,\\"minutes\\":30},\\"open\\":{\\"day\\":3,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":4,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"2230\\",\\"hours\\":22,\\"minutes\\":30},\\"open\\":{\\"day\\":4,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":5,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"2230\\",\\"hours\\":22,\\"minutes\\":30},\\"open\\":{\\"day\\":5,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"1530\\",\\"hours\\":15,\\"minutes\\":30},\\"open\\":{\\"day\\":6,\\"time\\":\\"1130\\",\\"hours\\":11,\\"minutes\\":30}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"2230\\",\\"hours\\":22,\\"minutes\\":30},\\"open\\":{\\"day\\":6,\\"time\\":\\"1830\\",\\"hours\\":18,\\"minutes\\":30}}],\\"weekday_text\\":[\\"lundi: 12:00 – 14:30, 19:00 – 22:30\\",\\"mardi: 12:00 – 14:30, 19:00 – 22:30\\",\\"mercredi: 12:00 – 14:30, 19:00 – 22:30\\",\\"jeudi: 12:00 – 14:30, 19:00 – 22:30\\",\\"vendredi: 12:00 – 14:30, 19:00 – 22:30\\",\\"samedi: 11:30 – 15:30, 18:30 – 22:30\\",\\"dimanche: 12:00 – 15:30, 19:00 – 22:00\\"]}"	2025-02-21 18:03:53.748	2025-02-21 18:04:45.063939	2025-02-21 18:04:45.063939	0101000020E61000008485EEEDF1BD0240FFE9060ABC6F4840
46	Lacigne	ChIJTx-97HJt5kcRkJVKq9y9ykg	124 Ave Parmentier, 75011 Paris, France	48.86796490	2.37280930	Avenue Parmentier	124	75011	Paris	Île-de-France	France		https://www.instagram.com/lacigne.par%20lacigne.reserve@gmail.com	OPERATIONAL	4.9	158	\N	"{\\"periods\\":[{\\"close\\":{\\"day\\":4,\\"time\\":\\"1500\\",\\"hours\\":15,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}}],\\"weekday_text\\":[\\"lundi: Fermé\\",\\"mardi: Fermé\\",\\"mercredi: Fermé\\",\\"jeudi: 12:00 – 15:00, 19:00 – 22:00\\",\\"vendredi: Fermé\\",\\"samedi: Fermé\\",\\"dimanche: Fermé\\"]}"	2025-02-21 18:10:09.654	2025-02-21 18:11:28.361141	2025-02-21 18:11:28.361141	0101000020E61000004028397183FB0240B7C94D79196F4840
47	Mokochaya	ChIJOy8SPQBz5kcRoCzhaXhUrWI	11 Rue Saint-Bernard, 75011 Paris, France	48.85132340	2.38152480	Rue Saint-Bernard	11	75011	Paris	Île-de-France	France			OPERATIONAL	4.9	22	\N	"{\\"periods\\":[{\\"close\\":{\\"day\\":2,\\"time\\":\\"1800\\",\\"hours\\":18,\\"minutes\\":0},\\"open\\":{\\"day\\":2,\\"time\\":\\"0830\\",\\"hours\\":8,\\"minutes\\":30}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"1800\\",\\"hours\\":18,\\"minutes\\":0},\\"open\\":{\\"day\\":3,\\"time\\":\\"0830\\",\\"hours\\":8,\\"minutes\\":30}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"1800\\",\\"hours\\":18,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"0830\\",\\"hours\\":8,\\"minutes\\":30}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"1800\\",\\"hours\\":18,\\"minutes\\":0},\\"open\\":{\\"day\\":5,\\"time\\":\\"0830\\",\\"hours\\":8,\\"minutes\\":30}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"1530\\",\\"hours\\":15,\\"minutes\\":30},\\"open\\":{\\"day\\":6,\\"time\\":\\"1100\\",\\"hours\\":11,\\"minutes\\":0}}],\\"weekday_text\\":[\\"lundi: Fermé\\",\\"mardi: 08:30 – 18:00\\",\\"mercredi: 08:30 – 18:00\\",\\"jeudi: 08:30 – 18:00\\",\\"vendredi: 08:30 – 18:00\\",\\"samedi: 11:00 – 15:30\\",\\"dimanche: Fermé\\"]}"	2025-02-21 18:18:41.526	2025-02-21 18:20:53.56047	2025-02-21 18:20:53.56047	0101000020E61000004EE7D4DF5C0D0340E6A8482AF86C4840
48	Georgette	ChIJ031VMtBx5kcR2DFk8Xpa2xs	44 Rue d'Assas, 75006 Paris, France	48.84717320	2.32991680	Rue d'Assas	44	75006	Paris	Île-de-France	France	01 45 44 44 44	http://www.restaurant-georgette.fr/	OPERATIONAL	4.7	1916	2	"{\\"periods\\":[{\\"close\\":{\\"day\\":0,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":0,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":0,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":0,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":1,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":1,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":1,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":1,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":2,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":2,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":3,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":3,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":4,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":5,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":5,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":6,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":6,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}}],\\"weekday_text\\":[\\"lundi: 12:00 – 14:30, 19:00 – 22:00\\",\\"mardi: 12:00 – 14:30, 19:00 – 22:00\\",\\"mercredi: 12:00 – 14:30, 19:00 – 22:00\\",\\"jeudi: 12:00 – 14:30, 19:00 – 22:00\\",\\"vendredi: 12:00 – 14:30, 19:00 – 22:00\\",\\"samedi: 12:00 – 14:30, 19:00 – 22:00\\",\\"dimanche: 12:00 – 14:30, 19:00 – 22:00\\"]}"	2025-02-21 18:21:43.458	2025-02-21 18:23:10.178771	2025-02-21 18:23:10.178771	0101000020E61000003135536BABA302401A06E22B706C4840
79	TRÂM 130	ChIJIyCodwBt5kcRb1tE1izyXos	130 Rue Saint-Maur, 75011 Paris, France	48.86802020	2.37541870	Rue Saint-Maur	130	75011	Paris	Île-de-France	France	\N	http://instagram.com/tramtramtramtramtram	OPERATIONAL	4.8	249	\N	\N	2025-04-27 16:20:11.878208	2025-04-27 16:20:11.884473	2025-04-27 16:20:11.884473	0101000020E61000006674F684DB00034039A231491B6F4840
80	Céline Lecoeur Pâtisserie	ChIJAYVk4o5v5kcR3Cj5faQovsM	5 Rue de Calais, 75009 Paris, France	48.88219940	2.33138400	Rue de Calais	5	75009	Paris	Île-de-France	France	01 40 34 40 69	https://www.instagram.com/celinelecoeur.patisserie/	OPERATIONAL	5	86	\N	\N	2025-04-27 16:23:21.757484	2025-04-27 16:23:21.762513	2025-04-27 16:23:21.762513	0101000020E6100000605793A7ACA6024081C6F1E8EB704840
49	Au Trou Gascon	ChIJ9bTpXGly5kcR8tpIMWDJXXM	40 Rue Taine, 75012 Paris, France	48.83911950	2.39428450	Rue Taine	40	75012	Paris	Île-de-France	France	01 88 61 56 31	https://autrougasconparis.fr/	OPERATIONAL	4.4	344	3	"{\\"periods\\":[{\\"close\\":{\\"day\\":2,\\"time\\":\\"1400\\",\\"hours\\":14,\\"minutes\\":0},\\"open\\":{\\"day\\":2,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"2230\\",\\"hours\\":22,\\"minutes\\":30},\\"open\\":{\\"day\\":2,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"1400\\",\\"hours\\":14,\\"minutes\\":0},\\"open\\":{\\"day\\":3,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"2230\\",\\"hours\\":22,\\"minutes\\":30},\\"open\\":{\\"day\\":3,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"1400\\",\\"hours\\":14,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"2230\\",\\"hours\\":22,\\"minutes\\":30},\\"open\\":{\\"day\\":4,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"1400\\",\\"hours\\":14,\\"minutes\\":0},\\"open\\":{\\"day\\":5,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"2230\\",\\"hours\\":22,\\"minutes\\":30},\\"open\\":{\\"day\\":5,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"1400\\",\\"hours\\":14,\\"minutes\\":0},\\"open\\":{\\"day\\":6,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"2230\\",\\"hours\\":22,\\"minutes\\":30},\\"open\\":{\\"day\\":6,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}}],\\"weekday_text\\":[\\"lundi: Fermé\\",\\"mardi: 12:00 – 14:00, 19:00 – 22:30\\",\\"mercredi: 12:00 – 14:00, 19:00 – 22:30\\",\\"jeudi: 12:00 – 14:00, 19:00 – 22:30\\",\\"vendredi: 12:00 – 14:00, 19:00 – 22:30\\",\\"samedi: 12:00 – 14:00, 19:00 – 22:30\\",\\"dimanche: Fermé\\"]}"	2025-02-21 18:24:26.786	2025-02-21 18:26:54.580611	2025-02-21 18:26:54.580611	0101000020E6100000C58EC6A17E270340CBF78C44686B4840
50	DUPIN & Chef Fernando De Tomaso	ChIJbVnmudNx5kcR1IA4uTrdgM4	11 Rue Dupin, 75006 Paris, France	48.84978110	2.32546040	Rue Dupin	11	75006	Paris	Île-de-France	France	01 42 22 64 56	https://restaurant-dupin.fr/	OPERATIONAL	4.5	634	2	"{\\"periods\\":[{\\"close\\":{\\"day\\":2,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":2,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":2,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":3,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":3,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":4,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":5,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":5,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":6,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":6,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}}],\\"weekday_text\\":[\\"lundi: Fermé\\",\\"mardi: 12:00 – 14:30, 19:00 – 22:00\\",\\"mercredi: 12:00 – 14:30, 19:00 – 22:00\\",\\"jeudi: 12:00 – 14:30, 19:00 – 22:00\\",\\"vendredi: 12:00 – 14:30, 19:00 – 22:00\\",\\"samedi: 12:00 – 14:30, 19:00 – 22:00\\",\\"dimanche: Fermé\\"]}"	2025-02-21 18:28:16.424	2025-02-21 18:29:07.932578	2025-02-21 18:29:07.932578	0101000020E6100000062571FB8A9A024024A188A0C56C4840
51	Foodi Jia-Ba-Buay	ChIJ4-g2CBdu5kcRzxXr5lJ9Bwg	2 Rue du Nil, 75002 Paris, France	48.86793510	2.34827790	Rue du Nil	2	75002	Paris	Île-de-France	France	01 45 08 48 28	http://www.foodi-jia-ba-buay.fr/	OPERATIONAL	4.7	463	2	"{\\"periods\\":[{\\"close\\":{\\"day\\":1,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":1,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":1,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":1,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":2,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":2,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":3,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":3,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":4,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":5,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":5,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"1500\\",\\"hours\\":15,\\"minutes\\":0},\\"open\\":{\\"day\\":6,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":6,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}}],\\"weekday_text\\":[\\"lundi: 12:00 – 14:30, 19:00 – 22:00\\",\\"mardi: 12:00 – 14:30, 19:00 – 22:00\\",\\"mercredi: 12:00 – 14:30, 19:00 – 22:00\\",\\"jeudi: 12:00 – 14:30, 19:00 – 22:00\\",\\"vendredi: 12:00 – 14:30, 19:00 – 22:00\\",\\"samedi: 12:00 – 15:00, 19:00 – 22:00\\",\\"dimanche: Fermé\\"]}"	2025-02-21 18:30:26.141	2025-02-21 18:30:44.070716	2025-02-21 18:30:44.070716	0101000020E6100000415B73EC45C9024076C6527F186F4840
52	Chez Camille	ChIJlZO8I0Vu5kcR2iMIgT06Q18	8 Rue Ravignan, 75018 Paris, France	48.88552630	2.33802150	Rue Ravignan	8	75018	Paris	Île-de-France	France	01 42 57 75 62	http://www.facebook.com/Chez-Camille-112695022123953/	OPERATIONAL	4.6	490	2	"{\\"periods\\":[{\\"close\\":{\\"day\\":1,\\"time\\":\\"0000\\",\\"hours\\":0,\\"minutes\\":0},\\"open\\":{\\"day\\":0,\\"time\\":\\"1800\\",\\"hours\\":18,\\"minutes\\":0}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"0130\\",\\"hours\\":1,\\"minutes\\":30},\\"open\\":{\\"day\\":1,\\"time\\":\\"1800\\",\\"hours\\":18,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"0130\\",\\"hours\\":1,\\"minutes\\":30},\\"open\\":{\\"day\\":2,\\"time\\":\\"1800\\",\\"hours\\":18,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"0130\\",\\"hours\\":1,\\"minutes\\":30},\\"open\\":{\\"day\\":3,\\"time\\":\\"1800\\",\\"hours\\":18,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"0130\\",\\"hours\\":1,\\"minutes\\":30},\\"open\\":{\\"day\\":4,\\"time\\":\\"1800\\",\\"hours\\":18,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"0130\\",\\"hours\\":1,\\"minutes\\":30},\\"open\\":{\\"day\\":5,\\"time\\":\\"1800\\",\\"hours\\":18,\\"minutes\\":0}},{\\"close\\":{\\"day\\":0,\\"time\\":\\"0130\\",\\"hours\\":1,\\"minutes\\":30},\\"open\\":{\\"day\\":6,\\"time\\":\\"1800\\",\\"hours\\":18,\\"minutes\\":0}}],\\"weekday_text\\":[\\"lundi: 18:00 – 01:30\\",\\"mardi: 18:00 – 01:30\\",\\"mercredi: 18:00 – 01:30\\",\\"jeudi: 18:00 – 01:30\\",\\"vendredi: 18:00 – 01:30\\",\\"samedi: 18:00 – 01:30\\",\\"dimanche: 18:00 – 00:00\\"]}"	2025-02-21 18:34:45.651	2025-02-21 18:35:40.121983	2025-02-21 18:35:40.121983	0101000020E610000048C2BE9D44B40240BB1F01ED58714840
53	Clos d’Astorg	ChIJM9liEmZv5kcRmfpjGj7ETCQ	22 Rue d'Astorg, 75008 Paris, France	48.87374500	2.31967110	Rue d'Astorg	22	75008	Paris	Île-de-France	France	01 55 06 18 16	https://bookings.zenchef.com/results?rid=367742&pid=1001	OPERATIONAL	4.7	145	\N	"{\\"periods\\":[{\\"close\\":{\\"day\\":1,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":1,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":1,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":1,\\"time\\":\\"1930\\",\\"hours\\":19,\\"minutes\\":30}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":2,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":2,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":2,\\"time\\":\\"1930\\",\\"hours\\":19,\\"minutes\\":30}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":3,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":3,\\"time\\":\\"1930\\",\\"hours\\":19,\\"minutes\\":30}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":4,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"1930\\",\\"hours\\":19,\\"minutes\\":30}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"1430\\",\\"hours\\":14,\\"minutes\\":30},\\"open\\":{\\"day\\":5,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":5,\\"time\\":\\"1930\\",\\"hours\\":19,\\"minutes\\":30}}],\\"weekday_text\\":[\\"lundi: 12:00 – 14:30, 19:30 – 22:00\\",\\"mardi: 12:00 – 14:30, 19:30 – 22:00\\",\\"mercredi: 12:00 – 14:30, 19:30 – 22:00\\",\\"jeudi: 12:00 – 14:30, 19:30 – 22:00\\",\\"vendredi: 12:00 – 14:30, 19:30 – 22:00\\",\\"samedi: Fermé\\",\\"dimanche: Fermé\\"]}"	2025-02-21 18:37:36.268	2025-02-21 18:39:24.380523	2025-02-21 18:39:24.380523	0101000020E61000008ECFBFB8AF8E024092054CE0D66F4840
82	La Source	ChIJsZb3aQBt5kcRymW8GBEFtO8	15 Rue du Surmelin, 75020 Paris, France	48.86815270	2.40321170	Rue du Surmelin	15	75020	Paris	Île-de-France	France	01 42 54 05 95	\N	OPERATIONAL	4.7	83	2	\N	2025-04-27 16:28:48.624971	2025-04-27 16:28:48.630739	2025-04-27 16:28:48.630739	0101000020E6100000A0EA460EC73903409137AFA01F6F4840
90	Aldehyde	ChIJuZn5THBx5kcRIN1OExKjBoU	5 Rue du Pont Louis-Philippe, 75004 Paris, France	48.85494920	2.35538470	Rue du Pont Louis-Philippe	5	75004	Paris	Île-de-France	France	09 73 89 43 24	https://aldehyde.paris/	OPERATIONAL	4.9	84	\N	\N	2025-04-27 17:11:34.343675	2025-04-27 17:11:34.349067	2025-04-27 17:11:34.349067	0101000020E61000007CFDFFEED3D70240E5DEB2F96E6D4840
91	OTÉ	ChIJWV6Gw3Ft5kcRqqwJ3Hy6DmY	46 Rue Jean-Pierre Timbaud, 75011 Paris, France	48.86634180	2.37246420	Rue Jean-Pierre Timbaud	46	75011	Paris	Île-de-France	France	\N	https://www.ote-restaurant.com/	OPERATIONAL	4.8	556	\N	\N	2025-04-27 17:14:41.218269	2025-04-27 17:14:41.221107	2025-04-27 17:14:41.221107	0101000020E61000004972AF82CEFA02403214C149E46E4840
54	Kolam Paris	ChIJVVKIrk9v5kcRDPWO9-gW6I0	27 Rue de Lancry, 75010 Paris, France	48.87033490	2.36098820	Rue de Lancry	27	75010	Paris	Île-de-France	France	07 45 02 19 06	https://linktr.ee/kolamparis	OPERATIONAL	4.9	250	\N	"{\\"periods\\":[{\\"close\\":{\\"day\\":2,\\"time\\":\\"1500\\",\\"hours\\":15,\\"minutes\\":0},\\"open\\":{\\"day\\":2,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":3,\\"time\\":\\"1500\\",\\"hours\\":15,\\"minutes\\":0},\\"open\\":{\\"day\\":3,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"1500\\",\\"hours\\":15,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":4,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":4,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"1500\\",\\"hours\\":15,\\"minutes\\":0},\\"open\\":{\\"day\\":5,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":5,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":5,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"1600\\",\\"hours\\":16,\\"minutes\\":0},\\"open\\":{\\"day\\":6,\\"time\\":\\"1200\\",\\"hours\\":12,\\"minutes\\":0}},{\\"close\\":{\\"day\\":6,\\"time\\":\\"2200\\",\\"hours\\":22,\\"minutes\\":0},\\"open\\":{\\"day\\":6,\\"time\\":\\"1900\\",\\"hours\\":19,\\"minutes\\":0}}],\\"weekday_text\\":[\\"lundi: Fermé\\",\\"mardi: 12:00 – 15:00\\",\\"mercredi: 12:00 – 15:00\\",\\"jeudi: 12:00 – 15:00, 19:00 – 22:00\\",\\"vendredi: 12:00 – 15:00, 19:00 – 22:00\\",\\"samedi: 12:00 – 16:00, 19:00 – 22:00\\",\\"dimanche: Fermé\\"]}"	2025-02-21 18:39:45.167	2025-02-21 18:40:59.214244	2025-02-21 18:40:59.214244	0101000020E61000006DEF09C84DE30240A2084E22676F4840
55	La Scene Theleme	ChIJ9UsVoexv5kcRLc96FFjvii4	18 Rue Troyon	48.87628740	2.29524000	Rue Troyon	18	75017	Paris	Île-de-France	France	\N	\N	\N	4.6	568	\N	\N	2025-03-01 17:08:31	2025-03-01 17:08:39.044347	2025-03-01 17:08:39.044347	0101000020E6100000B1C403CAA65C0240CD727E2F2A704840
56	Dishny	ChIJGceGuHFu5kcRq2ji3K9q7xA	25 Rue Cail	48.88275610	2.35926660	Rue Cail	25	75010	Paris	Île-de-France	France	\N	\N	\N	4.3	1440	\N	\N	2025-03-01 17:08:54	2025-03-01 17:08:56.765884	2025-03-01 17:08:56.765884	0101000020E6100000655CCC2AC7DF024019ECE126FE704840
57	Maison Lucas Carton	ChIJrf6XLDNu5kcRgypP8GERVqw	9 Place de la Madeleine	48.86968120	2.32312710	Place de la Madeleine	9	75008	Paris	Île-de-France	France	\N	\N	\N	4.6	791	\N	\N	2025-03-01 17:09:19	2025-03-01 17:09:22.140029	2025-03-01 17:09:22.140029	0101000020E61000004E9C37A9C395024018F9ABB6516F4840
58	Le Royal China	ChIJr4Ca5xpu5kcRGDeael8KZ9o	85 Rue Beaubourg, 75003 Paris, France	48.86407630	2.35489180	Rue Beaubourg	85	75003	Paris	Île-de-France	France	09 54 54 69 99	https://neoresto.shop/royalchina/	OPERATIONAL	4.1	1399	2	\N	2025-03-16 13:31:17.246065	2025-03-16 13:31:17.287086	2025-03-16 13:31:17.287086	0101000020E6100000D6F21483D1D60240D5DF5C0D9A6E4840
59	Brasserie Dubillot	ChIJBy2KU1Fv5kcRPeBADiR3WzM	222 Rue St Denis, 75002 Paris, France	48.86807910	2.35198530	Rue Saint Denis	222	75002	Paris	Île-de-France	France	01 88 61 51 24	https://nouvellegardegroupe.com/	OPERATIONAL	4.6	7044	2	\N	2025-03-20 17:23:15.504238	2025-03-20 17:23:15.532275	2025-03-20 17:23:15.532275	0101000020E6100000CA6141ABDDD00240AA6B48371D6F4840
60	La Terrasse du Châtel	ChIJk_pK6Kcx70cRlxcslLjmyAo	8 Pl. du Châtel, 77160 Provins, France	48.56261360	3.28820200	Place du Châtel	8	77160	Provins	Île-de-France	France	01 64 00 01 16	https://laterrasseduchatel.eatbu.com/	OPERATIONAL	4.2	662	2	\N	2025-03-27 09:28:10.42317	2025-03-27 09:28:10.45073	2025-03-27 09:28:10.45073	0101000020E61000006422A5D93C4E0A407524F2B803484840
61	Le Bistrot Aux Vieux Remparts	ChIJ9Q_-XgMx70cRldhbJYFKW4w	3 Rue Couverte, 77160 Provins, France	48.56254420	3.28723070	Rue Couverte	3	77160	Provins	Île-de-France	France	01 64 08 97 00	https://www.auxvieuxremparts.com/fr/restaurant/bistrot-des-remparts.html	OPERATIONAL	4.4	88	\N	\N	2025-03-28 08:47:31.506061	2025-03-28 08:47:31.513984	2025-03-28 08:47:31.513984	0101000020E6100000EB41F79B3F4C0A40F9C6C67201484840
62	LE SINGE A PARIS	ChIJM8hTswVy5kcRFy8_zyVcF9A	40 Rue Traversière, 75012 Paris, France	48.84896100	2.37466650	Rue Traversière	40	75012	Paris	Île-de-France	France	07 49 03 84 38	https://www.instagram.com/lesingeaparis/	OPERATIONAL	4.6	545	2	\N	2025-03-31 22:07:24.930402	2025-03-31 22:07:24.944327	2025-03-31 22:07:24.944327	0101000020E61000001841632651FF02402C4A09C1AA6C4840
63	Panorama	ChIJk5cmlK1t5kcRewANbZbBMb8	153 Rue Saint-Maur, 75011 Paris, France	48.86828550	2.37480290	Rue Saint-Maur	153	75011	Paris	Île-de-France	France	01 40 31 66 24	https://www.panoramaparis.fr/	OPERATIONAL	4.8	371	\N	\N	2025-04-27 09:13:35.562996	2025-04-27 09:13:35.581651	2025-04-27 09:13:35.581651	0101000020E61000005391AFA998FF0240A60BB1FA236F4840
64	L'Atelier Dürüm	ChIJBxeQyA5v5kcRQAoFVkGsZVU	41 Rue de Clignancourt, 75018 Paris, France	48.88633300	2.34743810	Rue de Clignancourt	41	75018	Paris	Île-de-France	France	06 13 74 43 91	https://latelierdurum.fr/	OPERATIONAL	4.6	2349	\N	\N	2025-04-27 09:16:52.51736	2025-04-27 09:16:52.521986	2025-04-27 09:16:52.521986	0101000020E6100000351367A08DC70240CB2E185C73714840
65	La Voie Lactée	ChIJPQBOGfpx5kcR4ZFRiZ_dxnE	34 Rue du Cardinal Lemoine, 75005 Paris, France	48.84733140	2.35235270	Rue du Cardinal Lemoine	34	75005	Paris	Île-de-France	France	01 46 34 02 35	https://alavoielactee.fr/	OPERATIONAL	4.5	625	1	\N	2025-04-27 09:19:55.693113	2025-04-27 09:19:55.704599	2025-04-27 09:19:55.704599	0101000020E61000002642D94A9ED10240DCEFF55A756C4840
66	Sapinho	ChIJQRcT4e9v5kcRn_pQudqxqC4	85 Rue Lamarck, 75018 Paris, France	48.89018660	2.33564950	Rue Lamarck	85	75018	Paris	Île-de-France	France	01 83 96 26 73	https://www.sapinho.fr/	OPERATIONAL	4.6	289	\N	\N	2025-04-27 09:22:43.116043	2025-04-27 09:22:43.120085	2025-04-27 09:22:43.120085	0101000020E61000009B594B0169AF0240312B6FA2F1714840
67	Kiku	ChIJOwe6Ivpv5kcRq--tIf7Qnrk	16 Rue de Montyon, 75009 Paris, France	48.87322140	2.34382610	Rue de Montyon	16	75009	Paris	Île-de-France	France	09 56 12 74 52	https://kiku-paris.com/	OPERATIONAL	5	54	\N	\N	2025-04-27 09:26:23.262538	2025-04-27 09:26:23.266481	2025-04-27 09:26:23.266481	0101000020E6100000FD16F8E527C002406B9505B8C56F4840
68	C’est Chouette 枭居	ChIJ6T0enphv5kcROMtWMBnx-JQ	22 Rue des Bourdonnais, 75001 Paris, France	48.85927920	2.34456270	Rue des Bourdonnais	22	75001	Paris	Île-de-France	France	01 89 33 41 64	https://www.cestchouette-paris.com/	OPERATIONAL	4.6	284	\N	\N	2025-04-27 09:30:57.476718	2025-04-27 09:30:57.479994	2025-04-27 09:30:57.479994	0101000020E6100000265FBF16AAC1024008115FDCFC6D4840
69	Elsass	ChIJXwO32AVt5kcRXrI_5bT5HaU	153 Ave Parmentier, 75010 Paris, France	48.87143350	2.36971790	Avenue Parmentier	153	75010	Paris	Île-de-France	France	09 55 66 77 68	https://elsass.restaurant/	OPERATIONAL	4.8	160	\N	\N	2025-04-27 09:34:51.334355	2025-04-27 09:34:51.341377	2025-04-27 09:34:51.341377	0101000020E610000065F789A82EF50240C59107228B6F4840
70	GATEAUX DE MOCHI	ChIJhxELWWlz5kcRWyS9whA0pCo	78 Bd Diderot, 75012 Paris, France	48.84665590	2.38259590	Boulevard Diderot	78	75012	Paris	Île-de-France	France	01 45 70 58 67	https://www.gateaux-de-mochi.com/	OPERATIONAL	4.9	253	\N	\N	2025-04-27 09:38:49.32045	2025-04-27 09:38:49.325435	2025-04-27 09:38:49.325435	0101000020E610000064AB70708E0F034094BB74385F6C4840
71	ajar	ChIJfdLEp4Bt5kcRLJtKUxlnXHU	34 Rue Sainte-Marthe, 75010 Paris, France	48.87429970	2.37270220	Rue Sainte-Marthe	34	75010	Paris	Île-de-France	France	01 42 06 05 03	https://www.instagram.com/ajarparis/	OPERATIONAL	4.8	79	\N	\N	2025-04-27 09:43:56.059182	2025-04-27 09:43:56.066151	2025-04-27 09:43:56.066151	0101000020E6100000922D814A4BFB02408933750DE96F4840
72	Kiyo Aji	ChIJa1CkuDJv5kcRAu81KEoez6U	15 Rue Caulaincourt, 75018 Paris, France	48.88724900	2.33294440	Rue Caulaincourt	15	75018	Paris	Île-de-France	France	09 70 95 98 32	https://www.instagram.com/kiyoajiparis?igsh=MWJzNzAzNTZkcHQwNw==	OPERATIONAL	4.9	301	\N	\N	2025-04-27 09:47:25.371295	2025-04-27 09:47:25.37618	2025-04-27 09:47:25.37618	0101000020E61000003B17EBC0DEA9024050340F6091714840
73	Restaurant TÊT	ChIJmzf7HSVv5kcRQm9fjbuImo4	10 Bd du Temple, 75011 Paris, France	48.86411970	2.36642840	Boulevard du Temple	10	75011	Paris	Île-de-France	France	01 73 75 02 70	https://www.restaurant-tet.com/	OPERATIONAL	4.8	338	\N	\N	2025-04-27 09:50:26.002998	2025-04-27 09:50:26.01032	2025-04-27 09:50:26.01032	0101000020E6100000D89A520372EE024028AA6D799B6E4840
81	L'Attirail	ChIJ6xI0NwVu5kcRMRSFYKsG6zE	9 Rue au Maire, 75003 Paris, France	48.86444610	2.35692680	Rue au Maire	9	75003	Paris	Île-de-France	France	01 42 72 44 42	\N	OPERATIONAL	4.2	987	1	\N	2025-04-27 16:26:20.299428	2025-04-27 16:26:20.304714	2025-04-27 16:26:20.304714	0101000020E610000008872870FCDA0240CF53782BA66E4840
96	Casimir	ChIJUzKfemxu5kcRQaC-jYQBcLk	6 Rue de Belzunce, 75010 Paris, France	48.87936450	2.35253640	Rue de Belzunce	6	75010	Paris	Île-de-France	France	01 48 78 28 80	https://www.casimir.paris/	OPERATIONAL	4.2	1752	2	\N	2025-04-27 17:33:08.718751	2025-04-27 17:33:08.722933	2025-04-27 17:33:08.722933	0101000020E61000005432A59AFED10240B76114048F704840
97	ROUND Egg Buns PARIS 10	ChIJ9zg_z-Vv5kcRCQkM44RGtgY	25 Rue Louis Blanc, 75010 Paris, France	48.88018630	2.36666790	Rue Louis Blanc	25	75010	Paris	Île-de-France	France	07 49 33 00 58	https://www.roundeggbuns.com/	OPERATIONAL	4.8	271	\N	\N	2025-04-27 17:36:55.252733	2025-04-27 17:36:55.257175	2025-04-27 17:36:55.257175	0101000020E6100000A9F17794EFEE02409171D6F1A9704840
98	Adami	ChIJ4_FJ0q1v5kcRO3RTnL4cxp8	19bis Rue Pierre Fontaine, 75009 Paris, France	48.88160850	2.33394480	Rue Pierre Fontaine	19bis	75009	Paris	Île-de-France	France	07 60 87 02 64	https://adamiparis.com/	OPERATIONAL	4.4	300	\N	\N	2025-04-27 17:39:34.420391	2025-04-27 17:39:34.424269	2025-04-27 17:39:34.424269	0101000020E6100000A55A5540EBAB024014B01D8CD8704840
99	Altro Frenchie	ChIJvWmj4TZv5kcRjWXoyQlKnUw	9 Rue du Nil, 75002 Paris, France	48.86766380	2.34775640	Rue du Nil	9	75002	Paris	Île-de-France	France	01 42 21 96 92	http://www.altro-frenchie.com/	OPERATIONAL	4.4	168	\N	\N	2025-04-27 17:42:18.671627	2025-04-27 17:42:18.67416	2025-04-27 17:42:18.67416	0101000020E61000002DCCE78134C8024028767E9B0F6F4840
100	Blanca Restaurant	ChIJN4EGozVz5kcRcL9OSHhiPWE	34 Rue Keller, 75011 Paris, France	48.85529430	2.37563190	Rue Keller	34	75011	Paris	Île-de-France	France	09 52 09 16 78	https://www.restaurantblanca.fr/	OPERATIONAL	4.9	350	\N	\N	2025-04-27 17:44:10.263109	2025-04-27 17:44:10.266483	2025-04-27 17:44:10.266483	0101000020E6100000BCAC2E4C4B010340447A9B487A6D4840
101	Broken Biscuits	ChIJ0W4nGQBv5kcRn1xGgp_6Sh8	18 Rue du Faubourg Poissonnière, 75010 Paris, France	48.87210340	2.34802420	Rue du Faubourg Poissonnière	18	75010	Paris	Île-de-France	France	\N	\N	OPERATIONAL	4.9	65	\N	\N	2025-04-27 17:47:31.754532	2025-04-27 17:47:31.759761	2025-04-27 17:47:31.759761	0101000020E610000085BB69E9C0C802407EDD8E15A16F4840
102	Le Village	ChIJ72W0bOZx5kcR5lDy3duVFSY	56 Rue de la Montagne Ste Geneviève, 75005 Paris, France	48.84731480	2.34823110	Rue de la Montagne Sainte Geneviève	56	75005	Paris	Île-de-France	France	09 51 56 86 98	https://www.facebook.com/levillage	OPERATIONAL	3.9	463	2	\N	2025-04-27 17:50:52.517757	2025-04-27 17:50:52.520977	2025-04-27 17:50:52.520977	0101000020E6100000D1990F632DC9024059B5B5CF746C4840
103	Calice	ChIJO10I8fNx5kcR7yeytWDHa_o	5 Rue de Bazeilles, 75005 Paris, France	48.83909550	2.35047210	Rue de Bazeilles	5	75005	Paris	Île-de-France	France	09 81 11 72 78	http://www.calicerestaurant.fr/	OPERATIONAL	4.7	189	\N	\N	2025-04-27 17:52:27.541108	2025-04-27 17:52:27.546066	2025-04-27 17:52:27.546066	0101000020E61000009648FD50C4CD0240425C397B676B4840
104	ANNA	ChIJIzW1q9pv5kcRLpgJEhD97Pk	13 Rue du Vertbois, 75003 Paris, France	48.86685630	2.35843480	Rue du Vertbois	13	75003	Paris	Île-de-France	France	09 73 88 96 06	https://www.annabaravin.fr/	OPERATIONAL	4.6	189	\N	\N	2025-04-27 17:54:41.820713	2025-04-27 17:54:41.823028	2025-04-27 17:54:41.823028	0101000020E610000085FC7D1013DE0240716AB125F56E4840
105	BOBBY	ChIJs1Cy4cRv5kcRCbGxR9U7tx0	29 Rue Lambert, 75018 Paris, France	48.88914660	2.34479930	Rue Lambert	29	75018	Paris	Île-de-France	France	01 80 50 61 18	https://lebobby.com/	OPERATIONAL	4.8	1541	2	\N	2025-04-27 18:00:40.469745	2025-04-27 18:00:40.474566	2025-04-27 18:00:40.474566	0101000020E61000003478A92226C20240BF2C488ECF714840
106	Petit Bruit	ChIJK1ULuIVt5kcRYMqI4qKKmmI	51 Av. Gambetta, 75020 Paris, France	48.86467310	2.39408560	Avenue Gambetta	51	75020	Paris	Île-de-France	France	09 74 73 53 24	https://www.privateaser.com/lieu/48169-petit-bruit	CLOSED_TEMPORARILY	4.9	202	\N	\N	2025-04-27 18:27:39.313548	2025-04-27 18:27:39.320709	2025-04-27 18:27:39.320709	0101000020E6100000A798DE59162703408F1DAF9BAD6E4840
107	Le Normandie	ChIJgRlRvmdu5kcRp6kgLi4QMCU	13 Rue Custine, 75018 Paris, France	48.88780330	2.34859450	Rue Custine	13	75018	Paris	Île-de-France	France	09 73 88 06 00	http://www.lenormandieparis.com/	OPERATIONAL	4.9	233	\N	\N	2025-04-28 09:03:14.00835	2025-04-28 09:03:14.014514	2025-04-28 09:03:14.014514	0101000020E61000001686C8E9EBC90240F463DD89A3714840
108	naam	ChIJTbbT_fdt5kcRqRMbXqc3tIA	73 Rue de Belleville, 75019 Paris, France	48.87360210	2.38340700	Rue de Belleville	73	75019	Paris	Île-de-France	France	06 62 37 04 31	https://www.naam.love/	OPERATIONAL	4.9	133	\N	\N	2025-04-28 09:15:43.369681	2025-04-28 09:15:43.37457	2025-04-28 09:15:43.37457	0101000020E6100000B47570B037110340C49B9031D26F4840
109	La Bagarre	ChIJr6ATbsBt5kcRthft9lhhinM	4 Rue de l'Orillon, 75011 Paris, France	48.86951840	2.37429150	Rue de l'Orillon	4	75011	Paris	Île-de-France	France	01 48 05 28 53	\N	OPERATIONAL	4.7	213	\N	\N	2025-04-28 09:23:51.202254	2025-04-28 09:23:51.207142	2025-04-28 09:23:51.207142	0101000020E6100000C45DBD8A8CFE024097A201614C6F4840
110	Ayahuma Restaurant	ChIJM9-35zlt5kcRllSr_L4eSKg	74 Rue Léon Frot, 75011 Paris, France	48.85725280	2.38514620	Rue Léon Frot	74	75011	Paris	Île-de-France	France	09 73 26 23 28	http://www.ayahuma.fr/	OPERATIONAL	4.9	426	\N	\N	2025-04-28 09:28:20.620816	2025-04-28 09:28:20.623871	2025-04-28 09:28:20.623871	0101000020E6100000ED6DE987C7140340C433B275BA6D4840
111	Ryô	ChIJM0QUsTpu5kcRwE2UjGgyDZg	7 Rue des Moulins, 75001 Paris, France	48.86695750	2.33501360	Rue des Moulins	7	75001	Paris	Île-de-France	France	01 40 20 91 86	http://ryoparis.wordpress.com/	CLOSED_TEMPORARILY	4.5	509	3	\N	2025-04-28 09:31:38.004491	2025-04-28 09:31:38.007187	2025-04-28 09:31:38.007187	0101000020E6100000C8B83D9C1BAE0240CEC29E76F86E4840
112	L’Art du Quotidien	ChIJE8RKd6hv5kcRM2iPDmDtbCM	98 R. de Lévis, 75017 Paris, France	48.88513490	2.31103820	Rue de Lévis	98	75017	Paris	Île-de-France	France	09 88 48 00 08	http://art-du-quotidien.fr/	OPERATIONAL	4.8	209	\N	\N	2025-04-28 09:35:02.787977	2025-04-28 09:35:02.793544	2025-04-28 09:35:02.793544	0101000020E610000023748698017D02402C06B4194C714840
113	Qasti Green	ChIJRWGMl-5v5kcRknpRdwtBoXo	41 Rue des Jeuneurs, 75002 Paris, France	48.86977760	2.34332870	Rue des Jeuneurs	41	75002	Paris	Île-de-France	France	01 53 40 86 82	https://www.qasti.fr/	OPERATIONAL	4.4	858	\N	\N	2025-04-28 09:37:03.878335	2025-04-28 09:37:03.881429	2025-04-28 09:37:03.881429	0101000020E6100000BE39121E23BF02408D6555DF546F4840
114	L'Etoile Berbère	ChIJCS4FGAVu5kcRL7xM7jfNxrg	16 Rue des Vertus, 75003 Paris, France	48.86428780	2.35793530	Rue des Vertus	16	75003	Paris	Île-de-France	France	01 42 72 29 09	https://www.letoileberbere.fr/	OPERATIONAL	4.8	391	\N	\N	2025-04-28 09:41:28.655046	2025-04-28 09:41:28.659158	2025-04-28 09:41:28.659158	0101000020E6100000EDABBC2E0DDD024078AA8DFBA06E4840
115	La Fille du Boucher	ChIJS35iDb5v5kcRkV1tztoitDc	20 Rue Cardinet, 75017 Paris, France	48.88166310	2.30277930	Rue Cardinet	20	75017	Paris	Île-de-France	France	01 42 67 14 19	http://www.lafilleduboucher.fr/	OPERATIONAL	4.4	467	2	\N	2025-04-28 09:44:38.333202	2025-04-28 09:44:38.338251	2025-04-28 09:44:38.338251	0101000020E6100000063FBB8D176C0240844B2256DA704840
116	Restaurant L'Oasis	ChIJV-UqEvxu5kcRsy-urVc_uaI	124 Av. Gabriel Péri, 93400 Saint-Ouen-sur-Seine, France	48.90278390	2.33055120	Avenue Gabriel Péri	124	93400	Saint-Ouen-sur-Seine	Île-de-France	France	01 40 11 47 23	http://loasis-st-ouen.eatbu.com/	OPERATIONAL	4.4	577	2	\N	2025-04-28 09:47:12.244281	2025-04-28 09:47:12.249704	2025-04-28 09:47:12.249704	0101000020E61000007B3A0D07F8A402407CED3E6C8E734840
117	Unplug - Cocktails & Tapas	ChIJUwJ8XkFv5kcRdZcCr0FyegE	57 Rue d'Anjou, 75008 Paris, France	48.87361940	2.32240780	Rue d'Anjou	57	75008	Paris	Île-de-France	France	\N	http://unplugbar.com/	OPERATIONAL	4.8	695	\N	\N	2025-04-28 09:49:13.158063	2025-04-28 09:49:13.160553	2025-04-28 09:49:13.160553	0101000020E61000006FCD678A4A9402405913B0C2D26F4840
118	Kissproof Belleville	ChIJdVGh_r1t5kcRyu3UvmcAvGo	50 Rue de Belleville, 75020 Paris, France	48.87307290	2.38147360	Rue de Belleville	50	75020	Paris	Île-de-France	France	\N	http://wisorshospitalitygroup.com/	OPERATIONAL	4.8	150	\N	\N	2025-04-28 09:52:06.472574	2025-04-28 09:52:06.477149	2025-04-28 09:52:06.477149	0101000020E6100000914CE207420D03400E4350DAC06F4840
119	Crêperie Little Breizh	ChIJUfHvL9lx5kcRWMzvn3cJrRk	11 Rue Grégoire de Tours, 75006 Paris, France	48.85321540	2.33794790	Rue Grégoire de Tours	11	75006	Paris	Île-de-France	France	01 43 54 60 74	https://www.facebook.com/LittleBreizhCreperie	OPERATIONAL	4.7	1266	1	\N	2025-04-28 09:56:42.480989	2025-04-28 09:56:42.487569	2025-04-28 09:56:42.487569	0101000020E6100000D90352071EB40240C7B88729366D4840
120	Hélia	ChIJO4fOwQpv5kcR_HvA4XsirDg	16 Rue du Colisée, 75008 Paris, France	48.87072480	2.30855680	Rue du Colisée	16	75008	Paris	Île-de-France	France	01 42 89 98 33	http://www.restauranthelia.fr/	OPERATIONAL	4.7	2446	2	\N	2025-04-28 10:00:01.116594	2025-04-28 10:00:01.120952	2025-04-28 10:00:01.120952	0101000020E6100000D4AAA7A0EC77024077E805E9736F4840
121	Maslow Temple	ChIJXZUAEw5v5kcRZxYemK1zagk	32 Rue de Picardie, 75003 Paris, France	48.86435930	2.36360940	Rue de Picardie	32	75003	Paris	Île-de-France	France	\N	https://maslow-restaurants.com/	OPERATIONAL	5	183	\N	\N	2025-04-28 12:38:38.975037	2025-04-28 12:38:38.980735	2025-04-28 12:38:38.980735	0101000020E61000003D258C0BACE8024029BF5653A36E4840
122	BISTROT MEE	ChIJHXZBfCVu5kcRJ9vT1b9opEc	5 Rue d'Argenteuil, 75001 Paris, France	48.86452470	2.33388760	Rue d'Argenteuil	5	75001	Paris	Île-de-France	France	01 42 86 11 85	\N	OPERATIONAL	4.3	1303	2	\N	2025-04-28 12:47:20.97976	2025-04-28 12:47:20.983584	2025-04-28 12:47:20.983584	0101000020E6100000C7511443CDAB0240C78AD0BEA86E4840
123	Ebis	ChIJpR9Nxy9u5kcRFQZ__EepSeo	19 Rue Saint-Roch, 75001 Paris, France	48.86539250	2.33218640	Rue Saint-Roch	19	75001	Paris	Île-de-France	France	01 42 61 05 90	https://ebisparis.com/	OPERATIONAL	4.6	689	2	\N	2025-04-28 12:49:43.295671	2025-04-28 12:49:43.301091	2025-04-28 12:49:43.301091	0101000020E61000006568E15751A8024012DA722EC56E4840
124	L'Officine du Louvre	ChIJ4akYtyVu5kcRrlOtZYi2V_I	Hôtel du Louvre, 1 Pl. André Malraux, 75001 Paris, France	48.86300000	2.33572500	Place André Malraux	1	75001	Paris	Île-de-France	France	01 44 58 37 89	https://www.hyattrestaurants.com/en/paris/bar/officine-du-louvre	OPERATIONAL	4.4	334	\N	\N	2025-04-28 12:53:20.24616	2025-04-28 12:53:20.250933	2025-04-28 12:53:20.250933	0101000020E6100000C898BB9690AF02405839B4C8766E4840
125	Little Yak	ChIJuTeZ_Btu5kcRCSLZSSuhqjc	61 R. Quincampoix, 75004 Paris, France	48.86170810	2.35068940	Rue Quincampoix	61	75004	Paris	Île-de-France	France	01 88 48 09 70	\N	OPERATIONAL	4.7	678	\N	\N	2025-04-28 12:55:24.309	2025-04-28 12:55:24.312312	2025-04-28 12:55:24.312312	0101000020E61000004F6E803E36CE0240621976734C6E4840
126	ACCENTS table bourse	ChIJCfSJczxu5kcR5iWOIrx0RLg	24 Rue Feydeau, 75002 Paris, France	48.86996370	2.34034720	Rue Feydeau	24	75002	Paris	Île-de-France	France	01 40 39 92 88	https://accents-restaurant.com/	OPERATIONAL	4.7	1007	3	\N	2025-04-28 12:57:32.112619	2025-04-28 12:57:32.116221	2025-04-28 12:57:32.116221	0101000020E61000000848EAF307B90240841A74F85A6F4840
127	Alla Mano	ChIJX8gYY2xv5kcRNx6HNnEEnE0	112 Rue Montmartre, 75002 Paris, France	48.86765930	2.34399910	Rue Montmartre	112	75002	Paris	Île-de-France	France	06 18 73 45 47	https://alla-mano-paris.fr/fr	OPERATIONAL	4.7	544	\N	\N	2025-04-28 13:00:02.480416	2025-04-28 13:00:02.484654	2025-04-28 13:00:02.484654	0101000020E6100000D5D3A29982C00240FEC8BE750F6F4840
128	Café Compagnon	ChIJm7G6N6xv5kcRLDH2ttwrhRs	22-26 Rue Léopold Bellan, 75002 Paris, France	48.86664630	2.34565360	Rue Léopold Bellan	22-26	75002	Paris	Île-de-France	France	09 77 09 62 24	http://www.cafecompagnon.com/	OPERATIONAL	4.3	503	\N	\N	2025-04-28 13:02:29.200707	2025-04-28 13:02:29.209324	2025-04-28 13:02:29.209324	0101000020E610000013F5DD08E6C3024086D91544EE6E4840
129	Jòia par Hélène Darroze	ChIJPf2x-Ehv5kcRCwfXoR7Zu3o	39 Rue des Jeuneurs, 75002 Paris, France	48.86974790	2.34345320	Rue des Jeuneurs	39	75002	Paris	Île-de-France	France	01 40 20 06 06	https://www.joiahelenedarroze.com/	OPERATIONAL	3.8	1435	\N	\N	2025-04-28 13:05:39.192972	2025-04-28 13:05:39.196613	2025-04-28 13:05:39.196613	0101000020E610000002A72D6464BF0240E12131E6536F4840
130	Oranta	ChIJl9tXOTFv5kcR_7jhxolghLc	1 Rue de Marivaux, 75002 Paris, France	48.87053150	2.33722430	Rue de Marivaux	1	75002	Paris	Île-de-France	France	01 89 32 35 79	http://www.oranta.fr/	OPERATIONAL	4.9	478	\N	\N	2025-04-28 13:09:02.139162	2025-04-28 13:09:02.145727	2025-04-28 13:09:02.145727	0101000020E6100000FA545FA7A2B20240A45181936D6F4840
131	Ryukishin Eiffel	ChIJRRsdqCtv5kcRL8cYv5wqIag	20 Rue de l'Exposition, 75007 Paris, France	48.85747060	2.30294010	Rue de l'Exposition	20	75007	Paris	Île-de-France	France	01 45 51 90 81	\N	OPERATIONAL	4.8	345	\N	\N	2025-04-28 13:12:03.497606	2025-04-28 13:12:03.503277	2025-04-28 13:12:03.503277	0101000020E6100000FE2CF1DB6B6C02400824BC98C16D4840
132	Sequoia Rooftop Bar	ChIJrSefgy9v5kcRN119_27kEJU	27-29 Bd des Capucines, 75002 Paris, France	48.87017240	2.33049640	Boulevard des Capucines	27-29	75002	Paris	Île-de-France	France	01 80 40 76 20	https://sequoiabar.com/	OPERATIONAL	4.2	286	\N	\N	2025-04-28 13:16:26.912536	2025-04-28 13:16:26.917505	2025-04-28 13:16:26.917505	0101000020E6100000DD90EB4BDBA40240E0F027CF616F4840
133	Waalo	ChIJKxx0D0Rv5kcRhhWG0cu4OaI	9 Rue d'Alexandrie, 75002 Paris, France	48.86796570	2.35064860	Rue d'Alexandrie	9	75002	Paris	Île-de-France	France	06 18 05 68 03	https://instagram.com/harouna_so_?r=nametag	CLOSED_TEMPORARILY	4.8	25	\N	\N	2025-04-28 13:18:42.266032	2025-04-28 13:18:42.269018	2025-04-28 13:18:42.269018	0101000020E6100000011B6BDA20CE02405EC60380196F4840
134	Zakuro	ChIJ5wEXqixv5kcRu5pTwcYI7OU	4 Rue de Port-Mahon, 75002 Paris, France	48.86921490	2.33419850	Rue de Port-Mahon	4	75002	Paris	Île-de-France	France	09 81 13 27 72	http://www.zakuro.fr/	OPERATIONAL	4.8	594	\N	\N	2025-04-28 13:20:27.283313	2025-04-28 13:20:27.287508	2025-04-28 13:20:27.287508	0101000020E610000061FA5E4370AC02401459106F426F4840
135	Glou	ChIJeVTu_ANu5kcRp68n0Y8kVKU	101 Rue Vieille du Temple, 75003 Paris, France	48.86039650	2.36143590	Rue Vieille du Temple	101	75003	Paris	Île-de-France	France	01 42 74 44 32	http://www.glou-resto.com/	OPERATIONAL	4.4	1646	2	\N	2025-04-28 13:22:02.318086	2025-04-28 13:22:02.320427	2025-04-28 13:22:02.320427	0101000020E610000078CD508138E40240E38BF678216E4840
136	Bistrot Instinct	ChIJzX94Mqpv5kcR789tzbYvWzc	19 Rue de Picardie, 75003 Paris, France	48.86371920	2.36258890	Rue de Picardie	19	75003	Paris	Île-de-France	France	01 42 78 93 06	http://instinct-paris.com/	OPERATIONAL	4.9	1050	\N	\N	2025-04-28 13:23:05.287868	2025-04-28 13:23:05.291086	2025-04-28 13:23:05.291086	0101000020E610000013245B0295E60240B176CA598E6E4840
137	Grande Brasserie	ChIJ-2gmGJxz5kcR4TeT2GHQ59Y	6 Rue de la Bastille, 75004 Paris, France	48.85376870	2.36799020	Rue de la Bastille	6	75004	Paris	Île-de-France	France	09 75 80 99 72	http://www.grandebrasserie.fr/	OPERATIONAL	4.4	864	\N	\N	2025-04-28 13:27:55.614747	2025-04-28 13:27:55.618879	2025-04-28 13:27:55.618879	0101000020E6100000EDFC91D8A4F102409A6CF24A486D4840
138	Kébi	ChIJE7nhDSNx5kcRlYevwaFBFDI	3 Rue de Turenne, 75004 Paris, France	48.85503920	2.36313440	Rue de Turenne	3	75004	Paris	Île-de-France	France	06 50 45 20 41	\N	OPERATIONAL	4.9	343	\N	\N	2025-04-28 13:29:19.560733	2025-04-28 13:29:19.566038	2025-04-28 13:29:19.566038	0101000020E6100000B06B2002B3E702402566ACEC716D4840
139	Casa Di Peppe	ChIJPa30YOlx5kcRAbCDqOE8840	222 Rue Saint-Jacques, 75005 Paris, France	48.84478850	2.34210940	Rue Saint-Jacques	222	75005	Paris	Île-de-France	France	01 43 54 78 68	https://www.casadipeppe.fr/	OPERATIONAL	4.6	5673	2	\N	2025-04-28 13:30:37.895845	2025-04-28 13:30:37.89863	2025-04-28 13:30:37.89863	0101000020E6100000C43B65DAA3BC0240B9C49107226C4840
140	Han Lim	ChIJOZDUzuhx5kcRuNzYGo3qqRY	6 Rue Blainville, 75005 Paris, France	48.84456490	2.34862290	Rue Blainville	6	75005	Paris	Île-de-France	France	01 43 54 62 74	https://hanlim.fr/	OPERATIONAL	4.4	390	2	\N	2025-04-28 13:32:32.712849	2025-04-28 13:32:32.715593	2025-04-28 13:32:32.715593	0101000020E6100000EB1791CDFAC90240BD6CE0B31A6C4840
141	Karavaki au Jardin de Luxembourg	ChIJeZiJQKlx5kcRgCSRe8BtvbY	7 Rue Gay-Lussac, 75005 Paris, France	48.84647120	2.34115680	Rue Gay-Lussac	7	75005	Paris	Île-de-France	France	09 53 38 88 70	\N	OPERATIONAL	4.8	384	\N	\N	2025-04-28 13:34:53.126694	2025-04-28 13:34:53.129545	2025-04-28 13:34:53.129545	0101000020E6100000CF76966AB0BA0240C180142B596C4840
142	La Taverne des Korrigans	ChIJM87qnuVx5kcRC15_Upn9Va0	42 Rue du Cardinal Lemoine, 75005 Paris, France	48.84691590	2.35179010	Rue du Cardinal Lemoine	42	75005	Paris	Île-de-France	France	01 43 26 96 59	\N	OPERATIONAL	4.6	363	1	\N	2025-04-28 13:36:03.514873	2025-04-28 13:36:03.51974	2025-04-28 13:36:03.51974	0101000020E6100000DB73F45377D00240307B7EBD676C4840
143	Café le Reflet	ChIJX6pqmN1x5kcRZKezkJ_byXk	6 Rue Champollion, 75005 Paris, France	48.84972800	2.34279100	Rue Champollion	6	75005	Paris	Île-de-France	France	09 52 10 97 27	\N	OPERATIONAL	4.5	334	1	\N	2025-04-28 13:38:06.744585	2025-04-28 13:38:06.748851	2025-04-28 13:38:06.748851	0101000020E6100000B4E7323509BE02406C3F19E3C36C4840
144	OTTO by Eric Trochon	ChIJx6VuJ2dx5kcRpX-dsyUlkL0	5 Rue Mouffetard, 75005 Paris, France	48.84484890	2.34936750	Rue Mouffetard	5	75005	Paris	Île-de-France	France	\N	https://www.instagram.com/ottomouffetard	OPERATIONAL	4.7	457	\N	\N	2025-04-28 13:39:38.774168	2025-04-28 13:39:38.778708	2025-04-28 13:39:38.778708	0101000020E61000004148163081CB0240E2C73D02246C4840
\.


--
-- Data for Name: images; Type: TABLE DATA; Schema: public; Owner: bentobook
--

COPY public.images (id, imageable_type, imageable_id, is_cover, title, description, created_at, updated_at) FROM stdin;
28	Visit	12	\N	\N	\N	2025-03-21 08:30:29.513845	2025-03-21 08:30:30.401243
1	Visit	1	\N	\N	\N	2024-11-28 12:16:19.537243	2024-11-28 12:16:21.680296
2	Visit	1	\N	\N	\N	2024-11-28 12:16:20.452736	2024-11-28 12:16:21.758196
3	Visit	1	\N	\N	\N	2024-11-28 12:16:20.929382	2024-11-28 12:16:22.202593
4	Visit	2	\N	\N	\N	2024-11-28 13:17:07.870345	2024-11-28 13:17:09.508097
5	Visit	2	\N	\N	\N	2024-11-28 13:17:08.99245	2024-11-28 13:17:09.858319
6	Visit	2	\N	\N	\N	2024-11-28 13:17:09.527143	2024-11-28 13:17:10.353198
7	Visit	3	\N	\N	\N	2024-12-02 18:03:46.670869	2024-12-02 18:03:48.119839
8	Visit	3	\N	\N	\N	2024-12-02 19:35:40.489492	2024-12-02 19:35:42.149751
9	Visit	3	\N	\N	\N	2024-12-02 21:20:57.514282	2024-12-02 21:20:58.914597
31	Restaurant	69	\N	\N	\N	2025-03-28 08:51:29.849513	2025-03-28 08:51:31.607762
29	Restaurant	69	\N	\N	\N	2025-03-28 08:51:29.157223	2025-03-28 08:51:31.626875
30	Restaurant	69	\N	\N	\N	2025-03-28 08:51:29.530255	2025-03-28 08:51:31.690275
10	Visit	5	\N	\N	\N	2024-12-17 22:35:32.017029	2024-12-17 22:35:34.283948
11	Visit	5	\N	\N	\N	2024-12-17 22:35:33.032087	2024-12-17 22:35:34.499365
12	Visit	5	\N	\N	\N	2024-12-17 22:35:33.475126	2024-12-17 22:35:34.548466
13	Visit	6	\N	\N	\N	2025-02-10 18:04:16.977187	2025-02-10 18:04:18.301577
14	Visit	6	\N	\N	\N	2025-02-10 18:04:17.781863	2025-02-10 18:04:19.301015
15	Visit	7	\N	\N	\N	2025-02-10 18:06:03.148731	2025-02-10 18:06:04.023232
16	Visit	8	\N	\N	\N	2025-02-10 18:07:46.934686	2025-02-10 18:07:47.900982
17	Visit	8	\N	\N	\N	2025-02-10 18:07:47.46724	2025-02-10 18:07:48.46619
32	Visit	16	\N	\N	\N	2025-03-28 08:54:57.656602	2025-03-28 08:54:58.523338
18	Visit	9	\N	\N	\N	2025-02-12 13:12:19.033059	2025-02-12 13:12:20.365763
33	Visit	16	\N	\N	\N	2025-03-28 08:54:58.117432	2025-03-28 08:54:58.810471
19	Visit	9	\N	\N	\N	2025-02-12 13:12:19.728976	2025-02-12 13:12:20.693443
34	Visit	16	\N	\N	\N	2025-03-28 08:54:58.329287	2025-03-28 08:54:59.01836
20	Visit	9	\N	\N	\N	2025-02-12 13:12:20.235617	2025-02-12 13:12:21.006403
21	Visit	9	\N	\N	\N	2025-02-12 13:12:20.709138	2025-02-12 13:12:21.673616
22	Visit	9	\N	\N	\N	2025-02-12 13:12:21.23733	2025-02-12 13:12:22.570996
24	Restaurant	20	\N	\N	\N	2025-02-28 17:22:48.535687	2025-03-02 08:41:38.401469
25	Visit	10	\N	\N	\N	2025-03-19 15:37:42.139967	2025-03-19 15:37:43.917802
26	Visit	11	\N	\N	\N	2025-03-20 17:26:57.209169	2025-03-20 17:26:58.130936
27	Visit	11	\N	\N	\N	2025-03-20 17:26:57.681234	2025-03-20 17:26:58.184362
\.


--
-- Data for Name: list_restaurants; Type: TABLE DATA; Schema: public; Owner: bentobook
--

COPY public.list_restaurants (id, list_id, restaurant_id, "position", created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: lists; Type: TABLE DATA; Schema: public; Owner: bentobook
--

COPY public.lists (id, name, description, owner_type, owner_id, visibility, premium, "position", created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: memberships; Type: TABLE DATA; Schema: public; Owner: bentobook
--

COPY public.memberships (id, user_id, organization_id, role, created_at, updated_at) FROM stdin;
1	3	3	\N	2025-04-03 13:44:17.251308	2025-04-03 13:44:17.251308
2	4	4	\N	2025-04-03 13:44:17.284419	2025-04-03 13:44:17.284419
3	5	5	\N	2025-04-03 13:44:17.321592	2025-04-03 13:44:17.321592
4	6	6	\N	2025-04-03 13:44:17.335362	2025-04-03 13:44:17.335362
5	7	7	\N	2025-04-03 13:44:17.347375	2025-04-03 13:44:17.347375
6	8	8	\N	2025-04-03 13:44:17.3557	2025-04-03 13:44:17.3557
7	9	9	\N	2025-04-03 13:44:17.381941	2025-04-03 13:44:17.381941
8	10	10	\N	2025-04-03 13:44:17.396422	2025-04-03 13:44:17.396422
9	11	11	\N	2025-04-03 13:44:17.447567	2025-04-03 13:44:17.447567
10	12	12	\N	2025-04-03 13:44:17.479053	2025-04-03 13:44:17.479053
11	13	13	\N	2025-04-03 13:44:17.505737	2025-04-03 13:44:17.505737
12	14	14	\N	2025-04-03 13:44:17.513812	2025-04-03 13:44:17.513812
13	15	15	\N	2025-04-03 13:44:17.522973	2025-04-03 13:44:17.522973
14	16	16	\N	2025-04-03 13:44:17.541969	2025-04-03 13:44:17.541969
15	17	17	\N	2025-04-03 13:44:17.557994	2025-04-03 13:44:17.557994
16	18	18	\N	2025-04-03 13:44:17.587241	2025-04-03 13:44:17.587241
17	19	19	\N	2025-04-03 13:44:17.598222	2025-04-03 13:44:17.598222
18	20	20	\N	2025-04-03 13:44:17.608341	2025-04-03 13:44:17.608341
19	21	21	\N	2025-04-03 13:44:17.618202	2025-04-03 13:44:17.618202
20	22	22	\N	2025-04-03 13:44:17.630306	2025-04-03 13:44:17.630306
21	23	23	\N	2025-04-03 13:44:17.644883	2025-04-03 13:44:17.644883
22	24	24	\N	2025-04-03 13:44:17.65688	2025-04-03 13:44:17.65688
23	25	25	\N	2025-04-03 13:44:17.669963	2025-04-03 13:44:17.669963
24	26	26	\N	2025-04-03 13:44:17.698147	2025-04-03 13:44:17.698147
25	27	27	\N	2025-04-03 13:44:17.709971	2025-04-03 13:44:17.709971
26	28	28	\N	2025-04-03 13:44:17.729971	2025-04-03 13:44:17.729971
27	29	29	\N	2025-04-03 13:44:17.742335	2025-04-03 13:44:17.742335
28	30	30	\N	2025-04-03 13:44:17.751302	2025-04-03 13:44:17.751302
29	31	31	\N	2025-04-03 13:44:17.766336	2025-04-03 13:44:17.766336
30	32	32	\N	2025-04-03 13:44:17.782379	2025-04-03 13:44:17.782379
31	33	33	\N	2025-04-03 13:44:17.816601	2025-04-03 13:44:17.816601
32	34	34	\N	2025-04-03 13:44:17.824045	2025-04-03 13:44:17.824045
33	35	35	\N	2025-04-03 13:44:17.830207	2025-04-03 13:44:17.830207
34	36	36	\N	2025-04-03 13:44:17.838719	2025-04-03 13:44:17.838719
35	37	37	\N	2025-04-03 13:44:17.853162	2025-04-03 13:44:17.853162
36	38	38	\N	2025-04-03 13:44:17.860767	2025-04-03 13:44:17.860767
37	39	39	\N	2025-04-03 13:44:17.869033	2025-04-03 13:44:17.869033
38	40	40	\N	2025-04-03 13:44:17.879239	2025-04-03 13:44:17.879239
39	41	41	\N	2025-04-03 13:44:17.892717	2025-04-03 13:44:17.892717
40	42	42	\N	2025-04-03 13:44:17.907204	2025-04-03 13:44:17.907204
41	43	43	\N	2025-04-03 13:44:17.917214	2025-04-03 13:44:17.917214
42	44	44	\N	2025-04-03 13:44:17.928423	2025-04-03 13:44:17.928423
43	45	45	\N	2025-04-03 13:44:17.938306	2025-04-03 13:44:17.938306
44	46	46	\N	2025-04-03 13:44:17.947643	2025-04-03 13:44:17.947643
45	47	47	\N	2025-04-03 13:44:17.956573	2025-04-03 13:44:17.956573
46	48	48	\N	2025-04-03 13:44:17.968325	2025-04-03 13:44:17.968325
47	49	49	\N	2025-04-03 13:44:17.979097	2025-04-03 13:44:17.979097
48	50	50	\N	2025-04-03 13:44:17.991789	2025-04-03 13:44:17.991789
49	51	51	\N	2025-04-03 13:44:18.001017	2025-04-03 13:44:18.001017
50	52	52	\N	2025-04-03 13:44:18.008977	2025-04-03 13:44:18.008977
51	53	53	\N	2025-04-03 13:44:18.024036	2025-04-03 13:44:18.024036
52	54	54	\N	2025-04-03 13:44:18.039617	2025-04-03 13:44:18.039617
53	55	55	\N	2025-04-03 13:44:18.05502	2025-04-03 13:44:18.05502
54	56	56	\N	2025-04-03 13:44:18.076311	2025-04-03 13:44:18.076311
55	57	57	\N	2025-04-03 13:44:18.100506	2025-04-03 13:44:18.100506
56	58	58	\N	2025-04-03 13:44:18.13007	2025-04-03 13:44:18.13007
57	59	59	\N	2025-04-03 13:44:18.146157	2025-04-03 13:44:18.146157
58	60	60	\N	2025-04-03 13:44:18.15955	2025-04-03 13:44:18.15955
59	61	61	\N	2025-04-03 13:44:18.172567	2025-04-03 13:44:18.172567
60	62	62	\N	2025-04-03 13:44:18.219841	2025-04-03 13:44:18.219841
61	63	63	\N	2025-04-03 13:44:18.269647	2025-04-03 13:44:18.269647
62	64	64	\N	2025-04-03 13:44:18.277637	2025-04-03 13:44:18.277637
63	65	65	\N	2025-04-03 13:44:18.287321	2025-04-03 13:44:18.287321
64	66	66	\N	2025-04-03 13:44:18.297641	2025-04-03 13:44:18.297641
65	67	67	\N	2025-04-03 13:44:18.307805	2025-04-03 13:44:18.307805
66	68	68	\N	2025-04-03 13:44:18.318843	2025-04-03 13:44:18.318843
67	69	69	\N	2025-04-03 13:44:18.32811	2025-04-03 13:44:18.32811
68	70	70	\N	2025-04-03 13:44:18.336223	2025-04-03 13:44:18.336223
69	71	71	\N	2025-04-03 13:44:18.362253	2025-04-03 13:44:18.362253
70	72	72	\N	2025-04-03 13:44:18.369202	2025-04-03 13:44:18.369202
71	73	73	\N	2025-04-03 13:44:18.375541	2025-04-03 13:44:18.375541
72	74	74	\N	2025-04-03 13:44:18.382682	2025-04-03 13:44:18.382682
73	75	75	\N	2025-04-03 13:44:18.392056	2025-04-03 13:44:18.392056
74	76	76	\N	2025-04-03 13:44:18.399046	2025-04-03 13:44:18.399046
75	77	77	\N	2025-04-03 13:44:18.407859	2025-04-03 13:44:18.407859
76	78	78	\N	2025-04-03 13:44:18.415967	2025-04-03 13:44:18.415967
77	79	79	\N	2025-04-03 13:44:18.427106	2025-04-03 13:44:18.427106
78	80	80	\N	2025-04-03 13:44:18.433991	2025-04-03 13:44:18.433991
79	81	81	\N	2025-04-03 13:44:18.442689	2025-04-03 13:44:18.442689
80	82	82	\N	2025-04-03 13:44:18.450211	2025-04-03 13:44:18.450211
81	83	83	\N	2025-04-03 13:44:18.457111	2025-04-03 13:44:18.457111
82	84	84	\N	2025-04-03 13:44:18.4649	2025-04-03 13:44:18.4649
83	85	85	\N	2025-04-03 13:44:18.47115	2025-04-03 13:44:18.47115
84	86	86	\N	2025-04-03 13:44:18.479962	2025-04-03 13:44:18.479962
85	87	87	\N	2025-04-03 13:44:18.489247	2025-04-03 13:44:18.489247
86	88	88	\N	2025-04-03 13:44:18.49877	2025-04-03 13:44:18.49877
87	89	89	\N	2025-04-03 13:44:18.507926	2025-04-03 13:44:18.507926
88	90	90	\N	2025-04-03 13:44:18.514674	2025-04-03 13:44:18.514674
89	91	91	\N	2025-04-03 13:44:18.524424	2025-04-03 13:44:18.524424
90	92	92	\N	2025-04-03 13:44:18.530733	2025-04-03 13:44:18.530733
91	93	93	\N	2025-04-03 13:44:18.535938	2025-04-03 13:44:18.535938
92	94	94	\N	2025-04-03 13:44:18.540751	2025-04-03 13:44:18.540751
93	95	95	\N	2025-04-03 13:44:18.547198	2025-04-03 13:44:18.547198
94	96	96	\N	2025-04-03 13:44:18.552652	2025-04-03 13:44:18.552652
95	97	97	\N	2025-04-03 13:44:18.558859	2025-04-03 13:44:18.558859
96	98	98	\N	2025-04-03 13:44:18.567689	2025-04-03 13:44:18.567689
97	99	99	\N	2025-04-03 13:44:18.575521	2025-04-03 13:44:18.575521
98	100	100	\N	2025-04-03 13:44:18.582432	2025-04-03 13:44:18.582432
99	101	101	\N	2025-04-03 13:44:18.591773	2025-04-03 13:44:18.591773
100	102	102	\N	2025-04-03 13:44:18.601181	2025-04-03 13:44:18.601181
101	103	103	\N	2025-04-03 13:44:18.607848	2025-04-03 13:44:18.607848
102	104	104	\N	2025-04-03 13:44:18.615235	2025-04-03 13:44:18.615235
103	105	105	\N	2025-04-03 13:44:18.621025	2025-04-03 13:44:18.621025
104	106	106	\N	2025-04-03 13:44:18.627203	2025-04-03 13:44:18.627203
105	107	107	\N	2025-04-03 13:44:18.633063	2025-04-03 13:44:18.633063
106	108	108	\N	2025-04-03 13:44:18.640757	2025-04-03 13:44:18.640757
107	109	109	\N	2025-04-03 13:44:18.65038	2025-04-03 13:44:18.65038
108	110	110	\N	2025-04-03 13:44:18.6596	2025-04-03 13:44:18.6596
109	111	111	\N	2025-04-03 13:44:18.669263	2025-04-03 13:44:18.669263
110	112	112	\N	2025-04-03 13:44:18.67759	2025-04-03 13:44:18.67759
111	113	113	\N	2025-04-03 13:44:18.686365	2025-04-03 13:44:18.686365
112	114	114	\N	2025-04-03 13:44:18.696899	2025-04-03 13:44:18.696899
113	115	115	\N	2025-04-03 13:44:18.705242	2025-04-03 13:44:18.705242
114	116	116	\N	2025-04-03 13:44:18.715207	2025-04-03 13:44:18.715207
115	117	117	\N	2025-04-03 13:44:18.725823	2025-04-03 13:44:18.725823
116	118	118	\N	2025-04-03 13:44:18.736572	2025-04-03 13:44:18.736572
117	119	119	\N	2025-04-03 13:44:18.751132	2025-04-03 13:44:18.751132
118	120	120	\N	2025-04-03 13:44:18.76146	2025-04-03 13:44:18.76146
119	121	121	\N	2025-04-03 13:44:18.770007	2025-04-03 13:44:18.770007
120	122	122	\N	2025-04-03 13:44:18.791437	2025-04-03 13:44:18.791437
121	123	123	\N	2025-04-03 13:44:18.798825	2025-04-03 13:44:18.798825
122	124	124	\N	2025-04-03 13:44:18.807211	2025-04-03 13:44:18.807211
123	125	125	\N	2025-04-03 13:44:18.81437	2025-04-03 13:44:18.81437
124	126	126	\N	2025-04-03 13:44:18.823228	2025-04-03 13:44:18.823228
125	127	127	\N	2025-04-03 13:44:18.834191	2025-04-03 13:44:18.834191
126	128	128	\N	2025-04-03 13:44:18.846544	2025-04-03 13:44:18.846544
127	129	129	\N	2025-04-03 13:44:18.856222	2025-04-03 13:44:18.856222
128	130	130	\N	2025-04-03 13:44:18.864831	2025-04-03 13:44:18.864831
129	131	131	\N	2025-04-03 13:44:18.872265	2025-04-03 13:44:18.872265
130	132	132	\N	2025-04-03 13:44:18.879521	2025-04-03 13:44:18.879521
131	133	133	\N	2025-04-03 13:44:18.887534	2025-04-03 13:44:18.887534
132	134	134	\N	2025-04-03 13:44:18.896696	2025-04-03 13:44:18.896696
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: bentobook
--

COPY public.organizations (id, created_at, updated_at) FROM stdin;
3	2025-04-03 13:44:17.181654	2025-04-03 13:44:17.181654
4	2025-04-03 13:44:17.265606	2025-04-03 13:44:17.265606
5	2025-04-03 13:44:17.292415	2025-04-03 13:44:17.292415
6	2025-04-03 13:44:17.32747	2025-04-03 13:44:17.32747
7	2025-04-03 13:44:17.338508	2025-04-03 13:44:17.338508
8	2025-04-03 13:44:17.350618	2025-04-03 13:44:17.350618
9	2025-04-03 13:44:17.371609	2025-04-03 13:44:17.371609
10	2025-04-03 13:44:17.385493	2025-04-03 13:44:17.385493
11	2025-04-03 13:44:17.419035	2025-04-03 13:44:17.419035
12	2025-04-03 13:44:17.452683	2025-04-03 13:44:17.452683
13	2025-04-03 13:44:17.490279	2025-04-03 13:44:17.490279
14	2025-04-03 13:44:17.508691	2025-04-03 13:44:17.508691
15	2025-04-03 13:44:17.516703	2025-04-03 13:44:17.516703
16	2025-04-03 13:44:17.529616	2025-04-03 13:44:17.529616
17	2025-04-03 13:44:17.548018	2025-04-03 13:44:17.548018
18	2025-04-03 13:44:17.576056	2025-04-03 13:44:17.576056
19	2025-04-03 13:44:17.590091	2025-04-03 13:44:17.590091
20	2025-04-03 13:44:17.601232	2025-04-03 13:44:17.601232
21	2025-04-03 13:44:17.611521	2025-04-03 13:44:17.611521
22	2025-04-03 13:44:17.621266	2025-04-03 13:44:17.621266
23	2025-04-03 13:44:17.634243	2025-04-03 13:44:17.634243
24	2025-04-03 13:44:17.64829	2025-04-03 13:44:17.64829
25	2025-04-03 13:44:17.661464	2025-04-03 13:44:17.661464
26	2025-04-03 13:44:17.673861	2025-04-03 13:44:17.673861
27	2025-04-03 13:44:17.701695	2025-04-03 13:44:17.701695
28	2025-04-03 13:44:17.712859	2025-04-03 13:44:17.712859
29	2025-04-03 13:44:17.733473	2025-04-03 13:44:17.733473
30	2025-04-03 13:44:17.745683	2025-04-03 13:44:17.745683
31	2025-04-03 13:44:17.755153	2025-04-03 13:44:17.755153
32	2025-04-03 13:44:17.77064	2025-04-03 13:44:17.77064
33	2025-04-03 13:44:17.804926	2025-04-03 13:44:17.804926
34	2025-04-03 13:44:17.819774	2025-04-03 13:44:17.819774
35	2025-04-03 13:44:17.826503	2025-04-03 13:44:17.826503
36	2025-04-03 13:44:17.83274	2025-04-03 13:44:17.83274
37	2025-04-03 13:44:17.844206	2025-04-03 13:44:17.844206
38	2025-04-03 13:44:17.856423	2025-04-03 13:44:17.856423
39	2025-04-03 13:44:17.863738	2025-04-03 13:44:17.863738
40	2025-04-03 13:44:17.872166	2025-04-03 13:44:17.872166
41	2025-04-03 13:44:17.882741	2025-04-03 13:44:17.882741
42	2025-04-03 13:44:17.896697	2025-04-03 13:44:17.896697
43	2025-04-03 13:44:17.911053	2025-04-03 13:44:17.911053
44	2025-04-03 13:44:17.920309	2025-04-03 13:44:17.920309
45	2025-04-03 13:44:17.932394	2025-04-03 13:44:17.932394
46	2025-04-03 13:44:17.941068	2025-04-03 13:44:17.941068
47	2025-04-03 13:44:17.950666	2025-04-03 13:44:17.950666
48	2025-04-03 13:44:17.959631	2025-04-03 13:44:17.959631
49	2025-04-03 13:44:17.971577	2025-04-03 13:44:17.971577
50	2025-04-03 13:44:17.982306	2025-04-03 13:44:17.982306
51	2025-04-03 13:44:17.995587	2025-04-03 13:44:17.995587
52	2025-04-03 13:44:18.003643	2025-04-03 13:44:18.003643
53	2025-04-03 13:44:18.01215	2025-04-03 13:44:18.01215
54	2025-04-03 13:44:18.0282	2025-04-03 13:44:18.0282
55	2025-04-03 13:44:18.042994	2025-04-03 13:44:18.042994
56	2025-04-03 13:44:18.060722	2025-04-03 13:44:18.060722
57	2025-04-03 13:44:18.079898	2025-04-03 13:44:18.079898
58	2025-04-03 13:44:18.103479	2025-04-03 13:44:18.103479
59	2025-04-03 13:44:18.13336	2025-04-03 13:44:18.13336
60	2025-04-03 13:44:18.149668	2025-04-03 13:44:18.149668
61	2025-04-03 13:44:18.164099	2025-04-03 13:44:18.164099
62	2025-04-03 13:44:18.176779	2025-04-03 13:44:18.176779
63	2025-04-03 13:44:18.259603	2025-04-03 13:44:18.259603
64	2025-04-03 13:44:18.272804	2025-04-03 13:44:18.272804
65	2025-04-03 13:44:18.280542	2025-04-03 13:44:18.280542
66	2025-04-03 13:44:18.29171	2025-04-03 13:44:18.29171
67	2025-04-03 13:44:18.300819	2025-04-03 13:44:18.300819
68	2025-04-03 13:44:18.31177	2025-04-03 13:44:18.31177
69	2025-04-03 13:44:18.321962	2025-04-03 13:44:18.321962
70	2025-04-03 13:44:18.331639	2025-04-03 13:44:18.331639
71	2025-04-03 13:44:18.338309	2025-04-03 13:44:18.338309
72	2025-04-03 13:44:18.365056	2025-04-03 13:44:18.365056
73	2025-04-03 13:44:18.371483	2025-04-03 13:44:18.371483
74	2025-04-03 13:44:18.378092	2025-04-03 13:44:18.378092
75	2025-04-03 13:44:18.388155	2025-04-03 13:44:18.388155
76	2025-04-03 13:44:18.39428	2025-04-03 13:44:18.39428
77	2025-04-03 13:44:18.401791	2025-04-03 13:44:18.401791
78	2025-04-03 13:44:18.410815	2025-04-03 13:44:18.410815
79	2025-04-03 13:44:18.422746	2025-04-03 13:44:18.422746
80	2025-04-03 13:44:18.429414	2025-04-03 13:44:18.429414
81	2025-04-03 13:44:18.437017	2025-04-03 13:44:18.437017
82	2025-04-03 13:44:18.445029	2025-04-03 13:44:18.445029
83	2025-04-03 13:44:18.45273	2025-04-03 13:44:18.45273
84	2025-04-03 13:44:18.460135	2025-04-03 13:44:18.460135
85	2025-04-03 13:44:18.467229	2025-04-03 13:44:18.467229
86	2025-04-03 13:44:18.474766	2025-04-03 13:44:18.474766
87	2025-04-03 13:44:18.482595	2025-04-03 13:44:18.482595
88	2025-04-03 13:44:18.492661	2025-04-03 13:44:18.492661
89	2025-04-03 13:44:18.50209	2025-04-03 13:44:18.50209
90	2025-04-03 13:44:18.510309	2025-04-03 13:44:18.510309
91	2025-04-03 13:44:18.519805	2025-04-03 13:44:18.519805
92	2025-04-03 13:44:18.526643	2025-04-03 13:44:18.526643
93	2025-04-03 13:44:18.532597	2025-04-03 13:44:18.532597
94	2025-04-03 13:44:18.537755	2025-04-03 13:44:18.537755
95	2025-04-03 13:44:18.543341	2025-04-03 13:44:18.543341
96	2025-04-03 13:44:18.549033	2025-04-03 13:44:18.549033
97	2025-04-03 13:44:18.554715	2025-04-03 13:44:18.554715
98	2025-04-03 13:44:18.56176	2025-04-03 13:44:18.56176
99	2025-04-03 13:44:18.570617	2025-04-03 13:44:18.570617
100	2025-04-03 13:44:18.578096	2025-04-03 13:44:18.578096
101	2025-04-03 13:44:18.585797	2025-04-03 13:44:18.585797
102	2025-04-03 13:44:18.594828	2025-04-03 13:44:18.594828
103	2025-04-03 13:44:18.603333	2025-04-03 13:44:18.603333
104	2025-04-03 13:44:18.611191	2025-04-03 13:44:18.611191
105	2025-04-03 13:44:18.617323	2025-04-03 13:44:18.617323
106	2025-04-03 13:44:18.623438	2025-04-03 13:44:18.623438
107	2025-04-03 13:44:18.629433	2025-04-03 13:44:18.629433
108	2025-04-03 13:44:18.63566	2025-04-03 13:44:18.63566
109	2025-04-03 13:44:18.644092	2025-04-03 13:44:18.644092
110	2025-04-03 13:44:18.653388	2025-04-03 13:44:18.653388
111	2025-04-03 13:44:18.663477	2025-04-03 13:44:18.663477
112	2025-04-03 13:44:18.672126	2025-04-03 13:44:18.672126
113	2025-04-03 13:44:18.680627	2025-04-03 13:44:18.680627
114	2025-04-03 13:44:18.68963	2025-04-03 13:44:18.68963
115	2025-04-03 13:44:18.699875	2025-04-03 13:44:18.699875
116	2025-04-03 13:44:18.708799	2025-04-03 13:44:18.708799
117	2025-04-03 13:44:18.719233	2025-04-03 13:44:18.719233
118	2025-04-03 13:44:18.73004	2025-04-03 13:44:18.73004
119	2025-04-03 13:44:18.743102	2025-04-03 13:44:18.743102
120	2025-04-03 13:44:18.754804	2025-04-03 13:44:18.754804
121	2025-04-03 13:44:18.764622	2025-04-03 13:44:18.764622
122	2025-04-03 13:44:18.778263	2025-04-03 13:44:18.778263
123	2025-04-03 13:44:18.794706	2025-04-03 13:44:18.794706
124	2025-04-03 13:44:18.803261	2025-04-03 13:44:18.803261
125	2025-04-03 13:44:18.809509	2025-04-03 13:44:18.809509
126	2025-04-03 13:44:18.817564	2025-04-03 13:44:18.817564
127	2025-04-03 13:44:18.826985	2025-04-03 13:44:18.826985
128	2025-04-03 13:44:18.837697	2025-04-03 13:44:18.837697
129	2025-04-03 13:44:18.850417	2025-04-03 13:44:18.850417
130	2025-04-03 13:44:18.859464	2025-04-03 13:44:18.859464
131	2025-04-03 13:44:18.86768	2025-04-03 13:44:18.86768
132	2025-04-03 13:44:18.874798	2025-04-03 13:44:18.874798
133	2025-04-03 13:44:18.882023	2025-04-03 13:44:18.882023
134	2025-04-03 13:44:18.891367	2025-04-03 13:44:18.891367
\.


--
-- Data for Name: pg_search_documents; Type: TABLE DATA; Schema: public; Owner: bentobook
--

COPY public.pg_search_documents (id, content, searchable_type, searchable_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: profiles; Type: TABLE DATA; Schema: public; Owner: bentobook
--

COPY public.profiles (id, user_id, username, first_name, last_name, about, created_at, updated_at, preferred_language, preferred_theme) FROM stdin;
84	84	\N	\N	\N	\N	2025-01-31 01:28:55.03046	2025-01-31 01:28:55.03046	en	light
62	62	\N	\N	\N	\N	2025-01-03 23:51:26.008723	2025-01-03 23:51:26.008723	en	light
4	4	\N	\N	\N	\N	2024-11-08 16:27:30.53405	2024-11-08 16:27:30.53405	en	light
5	5	\N	\N	\N	\N	2024-11-09 12:36:34.641531	2024-11-09 12:36:34.641531	en	light
6	6	\N	\N	\N	\N	2024-11-10 06:04:11.67664	2024-11-10 06:04:11.67664	en	light
63	63	\N	\N	\N	\N	2025-01-04 22:53:22.419922	2025-01-04 22:53:22.419922	en	light
64	64	\N	\N	\N	\N	2025-01-05 12:15:56.740595	2025-01-05 12:15:56.740595	en	light
65	65	\N	\N	\N	\N	2025-01-06 02:42:43.187868	2025-01-06 02:42:43.187868	en	light
7	7	\N	\N	\N	\N	2024-11-11 18:42:19.311211	2024-11-11 18:42:19.311211	en	light
8	8	\N	\N	\N	\N	2024-11-12 06:05:10.633973	2024-11-12 06:05:10.633973	en	light
9	9	\N	\N	\N	\N	2024-11-12 13:00:24.468402	2024-11-12 13:00:24.468402	en	light
10	10	\N	\N	\N	\N	2024-11-14 09:29:07.153975	2024-11-14 09:29:07.153975	en	light
11	11	\N	\N	\N	\N	2024-11-15 06:00:59.985558	2024-11-15 06:00:59.985558	en	light
66	66	\N	\N	\N	\N	2025-01-07 07:08:32.832063	2025-01-07 07:08:32.832063	en	light
67	67	\N	\N	\N	\N	2025-01-08 07:47:31.796296	2025-01-08 07:47:31.796296	en	light
85	85	\N	\N	\N	\N	2025-02-01 07:02:59.308607	2025-02-01 07:02:59.308607	en	light
86	86	\N	\N	\N	\N	2025-02-01 21:05:43.056516	2025-02-01 21:05:43.056516	en	light
13	13	\N	\N	\N	\N	2024-11-17 03:08:37.332042	2024-11-17 03:08:37.332042	en	light
14	14	\N	\N	\N	\N	2024-11-18 07:17:51.578607	2024-11-18 07:17:51.578607	en	light
15	15	\N	\N	\N	\N	2024-11-20 21:07:33.543308	2024-11-20 21:07:33.543308	en	light
16	16	\N	\N	\N	\N	2024-11-23 15:48:29.236486	2024-11-23 15:48:29.236486	en	light
17	17	\N	\N	\N	\N	2024-11-25 09:12:41.712265	2024-11-25 09:12:41.712265	en	light
18	18	\N	\N	\N	\N	2024-11-25 10:22:39.702691	2024-11-25 10:22:39.702691	en	light
19	19	\N	\N	\N	\N	2024-11-26 08:31:02.202326	2024-11-26 08:31:02.202326	en	light
20	20	\N	\N	\N	\N	2024-11-27 06:53:35.88451	2024-11-27 06:53:35.88451	en	light
21	21	\N	\N	\N	\N	2024-11-28 05:27:30.976696	2024-11-28 05:27:30.976696	en	light
22	22	\N	\N	\N	\N	2024-11-29 02:08:49.960422	2024-11-29 02:08:49.960422	en	light
23	23	\N	\N	\N	\N	2024-11-29 21:18:45.941486	2024-11-29 21:18:45.941486	en	light
24	24	\N	\N	\N	\N	2024-12-01 09:48:09.52792	2024-12-01 09:48:09.52792	en	light
25	25	\N	\N	\N	\N	2024-12-02 03:06:15.06477	2024-12-02 03:06:15.06477	en	light
68	68	\N	\N	\N	\N	2025-01-10 10:33:53.558865	2025-01-10 10:33:53.558865	en	light
69	69	\N	\N	\N	\N	2025-01-11 08:41:13.697533	2025-01-11 08:41:13.697533	en	light
70	70	\N	\N	\N	\N	2025-01-11 09:53:13.814722	2025-01-11 09:53:13.814722	en	light
71	71	\N	\N	\N	\N	2025-01-12 08:30:44.016006	2025-01-12 08:30:44.016006	en	light
72	72	\N	\N	\N	\N	2025-01-13 12:18:07.551534	2025-01-13 12:18:07.551534	en	light
26	26	\N	\N	\N	\N	2024-12-02 20:35:26.207779	2024-12-02 20:35:26.207779	en	light
73	73	\N	\N	\N	\N	2025-01-15 04:44:20.277165	2025-01-15 04:44:20.277165	en	light
74	74	\N	\N	\N	\N	2025-01-16 12:57:39.561155	2025-01-16 12:57:39.561155	en	light
87	87	\N	\N	\N	\N	2025-02-03 03:06:05.847702	2025-02-03 03:06:05.847702	en	light
81	81	\N	\N	\N	\N	2025-01-27 02:51:25.136561	2025-01-27 02:51:25.136561	en	light
80	80	\N	\N	\N	\N	2025-01-24 08:23:21.857526	2025-01-24 08:23:21.857526	en	light
82	82	\N	\N	\N	\N	2025-01-28 23:09:39.333068	2025-01-28 23:09:39.333068	en	light
27	27	\N	\N	\N	\N	2024-12-03 14:05:26.587391	2024-12-03 14:05:26.587391	en	light
28	28	\N	\N	\N	\N	2024-12-04 06:58:35.133541	2024-12-04 06:58:35.133541	en	light
29	29	\N	\N	\N	\N	2024-12-05 00:08:51.628468	2024-12-05 00:08:51.628468	en	light
30	30	\N	\N	\N	\N	2024-12-05 19:02:47.574973	2024-12-05 19:02:47.574973	en	light
31	31	\N	\N	\N	\N	2024-12-06 13:56:27.523562	2024-12-06 13:56:27.523562	en	light
32	32	\N	\N	\N	\N	2024-12-07 09:10:27.829569	2024-12-07 09:10:27.829569	en	light
33	33	\N	\N	\N	\N	2024-12-08 02:56:34.967945	2024-12-08 02:56:34.967945	en	light
34	34	\N	\N	\N	\N	2024-12-08 20:00:03.41418	2024-12-08 20:00:03.41418	en	light
35	35	\N	\N	\N	\N	2024-12-09 20:38:06.961322	2024-12-09 20:38:06.961322	en	light
36	36	\N	\N	\N	\N	2024-12-10 19:39:26.27676	2024-12-10 19:39:26.27676	en	light
37	37	\N	\N	\N	\N	2024-12-12 00:43:52.563399	2024-12-12 00:43:52.563399	en	light
38	38	\N	\N	\N	\N	2024-12-13 03:37:37.866364	2024-12-13 03:37:37.866364	en	light
39	39	\N	\N	\N	\N	2024-12-14 04:22:46.991176	2024-12-14 04:22:46.991176	en	light
40	40	\N	\N	\N	\N	2024-12-15 00:30:26.851736	2024-12-15 00:30:26.851736	en	light
41	41	\N	\N	\N	\N	2024-12-15 12:33:47.929066	2024-12-15 12:33:47.929066	en	light
42	42	\N	\N	\N	\N	2024-12-15 22:04:42.660571	2024-12-15 22:04:42.660571	en	light
43	43	\N	\N	\N	\N	2024-12-17 00:47:28.790958	2024-12-17 00:47:28.790958	en	light
44	44	\N	\N	\N	\N	2024-12-18 06:15:23.692735	2024-12-18 06:15:23.692735	en	light
45	45	\N	\N	\N	\N	2024-12-19 06:51:31.968366	2024-12-19 06:51:31.968366	en	light
46	46	\N	\N	\N	\N	2024-12-20 06:57:43.489645	2024-12-20 06:57:43.489645	en	light
47	47	\N	\N	\N	\N	2024-12-20 10:47:52.788481	2024-12-20 10:47:52.788481	en	light
48	48	\N	\N	\N	\N	2024-12-21 04:39:31.664672	2024-12-21 04:39:31.664672	en	light
49	49	\N	\N	\N	\N	2024-12-21 23:59:53.610305	2024-12-21 23:59:53.610305	en	light
50	50	\N	\N	\N	\N	2024-12-22 18:10:56.135129	2024-12-22 18:10:56.135129	en	light
51	51	\N	\N	\N	\N	2024-12-24 15:58:45.653882	2024-12-24 15:58:45.653882	en	light
52	52	\N	\N	\N	\N	2024-12-25 12:14:05.168533	2024-12-25 12:14:05.168533	en	light
53	53	\N	\N	\N	\N	2024-12-26 07:49:23.307476	2024-12-26 07:49:23.307476	en	light
54	54	\N	\N	\N	\N	2024-12-27 08:10:25.777306	2024-12-27 08:10:25.777306	en	light
55	55	\N	\N	\N	\N	2024-12-28 06:45:48.374114	2024-12-28 06:45:48.374114	en	light
56	56	\N	\N	\N	\N	2024-12-30 02:12:39.918006	2024-12-30 02:12:39.918006	en	light
57	57	\N	\N	\N	\N	2024-12-30 16:02:45.374129	2024-12-30 16:02:45.374129	en	light
58	58	\N	\N	\N	\N	2024-12-31 00:09:34.720076	2024-12-31 00:09:34.720076	en	light
59	59	\N	\N	\N	\N	2024-12-31 18:15:19.720657	2024-12-31 18:15:19.720657	en	light
60	60	\N	\N	\N	\N	2025-01-01 10:54:04.193468	2025-01-01 10:54:04.193468	en	light
61	61	\N	\N	\N	\N	2025-01-02 04:22:49.265603	2025-01-02 04:22:49.265603	en	light
75	75	\N	\N	\N	\N	2025-01-17 23:48:25.186196	2025-01-17 23:48:25.186196	en	light
76	76	\N	\N	\N	\N	2025-01-17 23:48:56.770496	2025-01-17 23:48:56.770496	en	light
88	88	\N	\N	\N	\N	2025-02-04 04:35:23.903486	2025-02-04 04:35:23.903486	en	light
77	77	\N	\N	\N	\N	2025-01-18 21:46:13.167219	2025-01-18 21:46:13.167219	en	light
78	78	\N	\N	\N	\N	2025-01-19 17:59:58.972412	2025-01-19 17:59:58.972412	en	light
83	83	\N	\N	\N	\N	2025-01-29 09:55:31.000405	2025-01-29 09:55:31.000405	en	light
79	79	\N	\N	\N	\N	2025-01-20 14:16:04.843751	2025-01-20 14:16:04.843751	en	light
89	89	\N	\N	\N	\N	2025-02-05 05:38:49.035561	2025-02-05 05:38:49.035561	en	light
96	96	\N	\N	\N	\N	2025-02-14 07:17:24.796244	2025-02-14 07:17:24.796244	en	light
90	90	\N	\N	\N	\N	2025-02-06 05:02:51.051365	2025-02-06 05:02:51.051365	en	light
91	91	\N	\N	\N	\N	2025-02-06 18:56:58.414733	2025-02-06 18:56:58.414733	en	light
92	92	\N	\N	\N	\N	2025-02-07 04:08:45.510878	2025-02-07 04:08:45.510878	en	light
93	93	\N	\N	\N	\N	2025-02-08 16:35:47.903021	2025-02-08 16:35:47.903021	en	light
94	94	\N	\N	\N	\N	2025-02-10 06:43:34.162498	2025-02-10 06:43:34.162498	en	light
95	95	\N	\N	\N	\N	2025-02-10 17:43:53.20388	2025-02-10 17:43:53.20388	en	light
3	3	mrks	Marc			2024-11-05 15:38:34.680296	2025-03-31 22:11:01.886757	fr	dark
97	97	\N	\N	\N	\N	2025-02-15 02:38:52.676794	2025-02-15 02:38:52.676794	en	light
98	98	\N	\N	\N	\N	2025-02-15 19:25:43.907875	2025-02-15 19:25:43.907875	en	light
99	99	\N	\N	\N	\N	2025-02-17 03:40:38.416715	2025-02-17 03:40:38.416715	en	light
100	100	\N	\N	\N	\N	2025-02-18 06:20:57.408164	2025-02-18 06:20:57.408164	en	light
101	101	\N	\N	\N	\N	2025-02-19 14:08:44.891169	2025-02-19 14:08:44.891169	en	light
102	102	\N	\N	\N	\N	2025-02-20 14:07:37.086274	2025-02-20 14:07:37.086274	en	light
177	177	\N	\N	\N	\N	2025-05-14 07:43:25.030131	2025-05-14 07:43:25.030131	en	light
103	103	\N	\N	\N	\N	2025-02-22 18:57:28.111217	2025-02-22 18:57:28.111217	en	light
104	104	\N	\N	\N	\N	2025-02-23 08:08:22.717019	2025-02-23 08:08:22.717019	en	light
105	105	\N	\N	\N	\N	2025-02-24 04:06:44.820011	2025-02-24 04:06:44.820011	en	light
106	106	\N	\N	\N	\N	2025-02-25 03:52:10.308698	2025-02-25 03:52:10.308698	en	light
107	107	\N	\N	\N	\N	2025-02-26 05:04:39.392051	2025-02-26 05:04:39.392051	en	light
108	108	\N	\N	\N	\N	2025-02-27 02:22:55.954565	2025-02-27 02:22:55.954565	en	light
109	109	\N	\N	\N	\N	2025-02-28 04:19:29.848463	2025-02-28 04:19:29.848463	en	light
110	110	\N	\N	\N	\N	2025-02-28 21:47:35.016328	2025-02-28 21:47:35.016328	en	light
111	111	\N	\N	\N	\N	2025-03-01 12:04:30.224341	2025-03-01 12:04:30.224341	en	light
178	178	\N	\N	\N	\N	2025-05-15 11:43:10.428956	2025-05-15 11:43:10.428956	en	light
179	179	\N	\N	\N	\N	2025-05-15 15:25:24.459589	2025-05-15 15:25:24.459589	en	light
180	180	\N	\N	\N	\N	2025-05-15 19:20:23.784212	2025-05-15 19:20:23.784212	en	light
181	181	\N	\N	\N	\N	2025-05-16 01:32:26.939115	2025-05-16 01:32:26.939115	en	light
182	182	\N	\N	\N	\N	2025-05-16 04:44:53.425686	2025-05-16 04:44:53.425686	en	light
12	12	MaryseF	Maryse	Franck		2024-11-16 19:11:20.781328	2025-03-01 17:54:33.764102	fr	light
112	112	\N	\N	\N	\N	2025-03-02 06:40:41.726024	2025-03-02 06:40:41.726024	en	light
113	113	\N	\N	\N	\N	2025-03-04 01:29:58.238921	2025-03-04 01:29:58.238921	en	light
114	114	\N	\N	\N	\N	2025-03-05 00:21:41.24696	2025-03-05 00:21:41.24696	en	light
115	115	\N	\N	\N	\N	2025-03-05 23:45:46.297504	2025-03-05 23:45:46.297504	en	light
116	116	\N	\N	\N	\N	2025-03-08 06:19:51.746516	2025-03-08 06:19:51.746516	en	light
117	117	\N	\N	\N	\N	2025-03-09 03:26:32.112315	2025-03-09 03:26:32.112315	en	light
118	118	\N	\N	\N	\N	2025-03-12 06:55:46.672168	2025-03-12 06:55:46.672168	en	light
119	119	\N	\N	\N	\N	2025-03-13 18:44:13.593623	2025-03-13 18:44:13.593623	en	light
120	120	\N	\N	\N	\N	2025-03-14 17:21:24.686298	2025-03-14 17:21:24.686298	en	light
121	121	\N	\N	\N	\N	2025-03-15 12:13:15.041232	2025-03-15 12:13:15.041232	en	light
122	122	\N	\N	\N	\N	2025-03-16 07:41:31.981879	2025-03-16 07:41:31.981879	en	light
123	123	\N	\N	\N	\N	2025-03-17 03:23:25.490272	2025-03-17 03:23:25.490272	en	light
124	124	\N	\N	\N	\N	2025-03-18 06:01:43.528674	2025-03-18 06:01:43.528674	en	light
125	125	\N	\N	\N	\N	2025-03-19 11:03:49.722017	2025-03-19 11:03:49.722017	en	light
126	126	\N	\N	\N	\N	2025-03-20 14:45:17.860795	2025-03-20 14:45:17.860795	en	light
127	127	\N	\N	\N	\N	2025-03-21 03:46:26.515137	2025-03-21 03:46:26.515137	en	light
128	128	\N	\N	\N	\N	2025-03-23 02:22:13.022028	2025-03-23 02:22:13.022028	en	light
129	129	\N	\N	\N	\N	2025-03-23 17:49:09.771783	2025-03-23 17:49:09.771783	en	light
130	130	\N	\N	\N	\N	2025-03-24 10:37:55.19754	2025-03-24 10:37:55.19754	en	light
131	131	\N	\N	\N	\N	2025-03-28 12:30:20.939455	2025-03-28 12:30:20.939455	en	light
132	132	\N	\N	\N	\N	2025-03-30 01:53:43.450713	2025-03-30 01:53:43.450713	en	light
133	133	\N	\N	\N	\N	2025-04-01 05:49:47.075042	2025-04-01 05:49:47.075042	en	light
134	134	\N	\N	\N	\N	2025-04-03 08:21:24.112604	2025-04-03 08:21:24.112604	en	light
135	135	\N	\N	\N	\N	2025-04-03 19:32:20.619783	2025-04-03 19:32:20.619783	en	light
136	136	\N	\N	\N	\N	2025-04-04 06:58:10.292771	2025-04-04 06:58:10.292771	en	light
137	137	\N	\N	\N	\N	2025-04-05 12:35:26.457065	2025-04-05 12:35:26.457065	en	light
138	138	\N	\N	\N	\N	2025-04-05 16:10:08.948335	2025-04-05 16:10:08.948335	en	light
139	139	\N	\N	\N	\N	2025-04-06 04:04:12.770974	2025-04-06 04:04:12.770974	en	light
140	140	\N	\N	\N	\N	2025-04-06 11:25:24.133348	2025-04-06 11:25:24.133348	en	light
141	141	\N	\N	\N	\N	2025-04-07 01:48:44.811186	2025-04-07 01:48:44.811186	en	light
142	142	\N	\N	\N	\N	2025-04-08 04:00:11.780008	2025-04-08 04:00:11.780008	en	light
143	143	\N	\N	\N	\N	2025-04-09 22:01:52.657262	2025-04-09 22:01:52.657262	en	light
144	144	\N	\N	\N	\N	2025-04-10 07:52:16.986222	2025-04-10 07:52:16.986222	en	light
145	145	\N	\N	\N	\N	2025-04-11 15:35:12.31066	2025-04-11 15:35:12.31066	en	light
146	146	\N	\N	\N	\N	2025-04-11 16:43:53.57841	2025-04-11 16:43:53.57841	en	light
147	147	\N	\N	\N	\N	2025-04-13 00:13:39.552318	2025-04-13 00:13:39.552318	en	light
148	148	\N	\N	\N	\N	2025-04-13 03:43:40.331811	2025-04-13 03:43:40.331811	en	light
149	149	\N	\N	\N	\N	2025-04-13 03:49:37.094084	2025-04-13 03:49:37.094084	en	light
150	150	\N	\N	\N	\N	2025-04-15 12:05:43.935777	2025-04-15 12:05:43.935777	en	light
151	151	\N	\N	\N	\N	2025-04-17 05:03:48.123173	2025-04-17 05:03:48.123173	en	light
152	152	\N	\N	\N	\N	2025-04-18 14:54:17.287178	2025-04-18 14:54:17.287178	en	light
153	153	\N	\N	\N	\N	2025-04-18 18:54:29.817459	2025-04-18 18:54:29.817459	en	light
154	154	\N	\N	\N	\N	2025-04-19 00:50:52.066686	2025-04-19 00:50:52.066686	en	light
155	155	\N	\N	\N	\N	2025-04-19 17:52:21.070307	2025-04-19 17:52:21.070307	en	light
156	156	\N	\N	\N	\N	2025-04-20 04:23:26.350378	2025-04-20 04:23:26.350378	en	light
157	157	\N	\N	\N	\N	2025-04-20 05:30:22.282822	2025-04-20 05:30:22.282822	en	light
158	158	\N	\N	\N	\N	2025-04-20 11:26:36.815302	2025-04-20 11:26:36.815302	en	light
159	159	\N	\N	\N	\N	2025-04-20 20:21:31.010225	2025-04-20 20:21:31.010225	en	light
160	160	\N	\N	\N	\N	2025-04-25 12:55:41.086001	2025-04-25 12:55:41.086001	en	light
161	161	\N	\N	\N	\N	2025-04-25 23:19:46.893883	2025-04-25 23:19:46.893883	en	light
162	162	\N	\N	\N	\N	2025-04-26 13:41:52.138506	2025-04-26 13:41:52.138506	en	light
163	163	\N	\N	\N	\N	2025-04-27 12:49:08.071555	2025-04-27 12:49:08.071555	en	light
164	164	\N	\N	\N	\N	2025-04-28 10:52:43.988705	2025-04-28 10:52:43.988705	en	light
165	165	\N	\N	\N	\N	2025-04-30 19:24:24.146864	2025-04-30 19:24:24.146864	en	light
166	166	\N	\N	\N	\N	2025-05-01 11:18:00.812802	2025-05-01 11:18:00.812802	en	light
167	167	\N	\N	\N	\N	2025-05-04 00:36:20.872308	2025-05-04 00:36:20.872308	en	light
168	168	\N	\N	\N	\N	2025-05-06 00:34:58.54812	2025-05-06 00:34:58.54812	en	light
169	169	\N	\N	\N	\N	2025-05-07 03:58:19.476818	2025-05-07 03:58:19.476818	en	light
170	170	\N	\N	\N	\N	2025-05-07 05:41:56.415675	2025-05-07 05:41:56.415675	en	light
171	171	\N	\N	\N	\N	2025-05-07 07:35:44.964076	2025-05-07 07:35:44.964076	en	light
172	172	\N	\N	\N	\N	2025-05-08 12:54:16.525687	2025-05-08 12:54:16.525687	en	light
173	173	\N	\N	\N	\N	2025-05-09 06:24:27.625043	2025-05-09 06:24:27.625043	en	light
174	174	\N	\N	\N	\N	2025-05-09 09:55:13.006503	2025-05-09 09:55:13.006503	en	light
175	175	\N	\N	\N	\N	2025-05-11 16:51:20.816502	2025-05-11 16:51:20.816502	en	light
176	176	\N	\N	\N	\N	2025-05-14 03:36:34.805753	2025-05-14 03:36:34.805753	en	light
183	183	\N	\N	\N	\N	2025-05-17 03:35:45.144875	2025-05-17 03:35:45.144875	en	light
184	184	\N	\N	\N	\N	2025-05-17 06:41:46.926292	2025-05-17 06:41:46.926292	en	light
185	185	\N	\N	\N	\N	2025-05-17 08:26:36.655799	2025-05-17 08:26:36.655799	en	light
186	186	\N	\N	\N	\N	2025-05-18 21:47:56.200052	2025-05-18 21:47:56.200052	en	light
187	187	\N	\N	\N	\N	2025-05-19 02:44:00.865493	2025-05-19 02:44:00.865493	en	light
188	188	\N	\N	\N	\N	2025-05-19 16:14:11.763014	2025-05-19 16:14:11.763014	en	light
189	189	\N	\N	\N	\N	2025-05-20 01:43:59.087178	2025-05-20 01:43:59.087178	en	light
190	190	\N	\N	\N	\N	2025-05-20 06:37:05.46867	2025-05-20 06:37:05.46867	en	light
191	191	\N	\N	\N	\N	2025-05-20 10:43:19.331556	2025-05-20 10:43:19.331556	en	light
192	192	\N	\N	\N	\N	2025-05-20 10:58:20.546895	2025-05-20 10:58:20.546895	en	light
193	193	\N	\N	\N	\N	2025-05-20 13:46:39.747298	2025-05-20 13:46:39.747298	en	light
194	194	\N	\N	\N	\N	2025-05-22 07:58:43.289781	2025-05-22 07:58:43.289781	en	light
195	195	\N	\N	\N	\N	2025-05-22 10:41:07.244352	2025-05-22 10:41:07.244352	en	light
196	196	\N	\N	\N	\N	2025-05-23 23:05:43.723025	2025-05-23 23:05:43.723025	en	light
197	197	\N	\N	\N	\N	2025-05-24 03:53:13.046287	2025-05-24 03:53:13.046287	en	light
198	198	\N	\N	\N	\N	2025-05-25 03:19:23.640149	2025-05-25 03:19:23.640149	en	light
199	199	\N	\N	\N	\N	2025-05-25 04:10:52.077013	2025-05-25 04:10:52.077013	en	light
200	200	\N	\N	\N	\N	2025-05-25 12:06:50.996694	2025-05-25 12:06:50.996694	en	light
201	201	\N	\N	\N	\N	2025-05-26 04:00:19.64274	2025-05-26 04:00:19.64274	en	light
202	202	\N	\N	\N	\N	2025-05-26 22:13:24.884231	2025-05-26 22:13:24.884231	en	light
203	203	\N	\N	\N	\N	2025-05-28 03:30:00.850813	2025-05-28 03:30:00.850813	en	light
204	204	\N	\N	\N	\N	2025-05-28 10:16:38.602574	2025-05-28 10:16:38.602574	en	light
205	205	\N	\N	\N	\N	2025-05-28 18:54:13.940134	2025-05-28 18:54:13.940134	en	light
206	206	\N	\N	\N	\N	2025-05-28 18:57:47.185543	2025-05-28 18:57:47.185543	en	light
207	207	\N	\N	\N	\N	2025-05-29 09:49:17.214742	2025-05-29 09:49:17.214742	en	light
208	208	\N	\N	\N	\N	2025-05-30 04:58:14.302844	2025-05-30 04:58:14.302844	en	light
209	209	\N	\N	\N	\N	2025-05-30 05:35:49.071313	2025-05-30 05:35:49.071313	en	light
210	210	\N	\N	\N	\N	2025-05-31 07:29:35.391662	2025-05-31 07:29:35.391662	en	light
211	211	\N	\N	\N	\N	2025-05-31 09:04:40.461645	2025-05-31 09:04:40.461645	en	light
212	212	\N	\N	\N	\N	2025-05-31 15:25:59.448536	2025-05-31 15:25:59.448536	en	light
213	213	\N	\N	\N	\N	2025-05-31 15:29:34.881689	2025-05-31 15:29:34.881689	en	light
214	214	\N	\N	\N	\N	2025-05-31 23:50:01.553724	2025-05-31 23:50:01.553724	en	light
215	215	\N	\N	\N	\N	2025-06-01 06:03:48.08759	2025-06-01 06:03:48.08759	en	light
216	216	\N	\N	\N	\N	2025-06-02 23:28:46.781561	2025-06-02 23:28:46.781561	en	light
217	217	\N	\N	\N	\N	2025-06-03 14:21:37.701518	2025-06-03 14:21:37.701518	en	light
218	218	\N	\N	\N	\N	2025-06-04 02:34:32.722334	2025-06-04 02:34:32.722334	en	light
219	219	\N	\N	\N	\N	2025-06-04 05:30:27.693997	2025-06-04 05:30:27.693997	en	light
220	220	\N	\N	\N	\N	2025-06-04 12:09:21.070495	2025-06-04 12:09:21.070495	en	light
221	221	\N	\N	\N	\N	2025-06-05 10:08:31.921538	2025-06-05 10:08:31.921538	en	light
222	222	\N	\N	\N	\N	2025-06-06 02:55:29.634005	2025-06-06 02:55:29.634005	en	light
223	223	\N	\N	\N	\N	2025-06-06 11:25:13.311288	2025-06-06 11:25:13.311288	en	light
224	224	\N	\N	\N	\N	2025-06-06 19:29:22.452625	2025-06-06 19:29:22.452625	en	light
225	225	\N	\N	\N	\N	2025-06-07 00:39:36.284979	2025-06-07 00:39:36.284979	en	light
226	226	\N	\N	\N	\N	2025-06-07 02:41:25.18405	2025-06-07 02:41:25.18405	en	light
227	227	\N	\N	\N	\N	2025-06-07 04:13:19.373236	2025-06-07 04:13:19.373236	en	light
228	228	\N	\N	\N	\N	2025-06-07 07:31:26.30148	2025-06-07 07:31:26.30148	en	light
229	229	\N	\N	\N	\N	2025-06-07 07:36:00.571212	2025-06-07 07:36:00.571212	en	light
230	230	\N	\N	\N	\N	2025-06-07 08:01:31.839482	2025-06-07 08:01:31.839482	en	light
231	231	\N	\N	\N	\N	2025-06-08 14:40:49.320411	2025-06-08 14:40:49.320411	en	light
232	232	\N	\N	\N	\N	2025-06-08 18:59:58.400987	2025-06-08 18:59:58.400987	en	light
233	233	\N	\N	\N	\N	2025-06-09 01:27:09.609653	2025-06-09 01:27:09.609653	en	light
234	234	\N	\N	\N	\N	2025-06-09 12:16:48.392277	2025-06-09 12:16:48.392277	en	light
235	235	\N	\N	\N	\N	2025-06-12 10:33:43.69331	2025-06-12 10:33:43.69331	en	light
236	236	\N	\N	\N	\N	2025-06-12 17:30:21.069649	2025-06-12 17:30:21.069649	en	light
237	237	\N	\N	\N	\N	2025-06-12 22:45:20.818427	2025-06-12 22:45:20.818427	en	light
238	238	\N	\N	\N	\N	2025-06-13 13:56:55.666918	2025-06-13 13:56:55.666918	en	light
239	239	\N	\N	\N	\N	2025-06-13 22:59:54.3115	2025-06-13 22:59:54.3115	en	light
240	240	\N	\N	\N	\N	2025-06-14 02:11:21.537195	2025-06-14 02:11:21.537195	en	light
241	241	\N	\N	\N	\N	2025-06-14 07:23:59.291289	2025-06-14 07:23:59.291289	en	light
242	242	\N	\N	\N	\N	2025-06-14 12:25:47.933803	2025-06-14 12:25:47.933803	en	light
243	243	\N	\N	\N	\N	2025-06-16 13:54:30.99118	2025-06-16 13:54:30.99118	en	light
244	244	\N	\N	\N	\N	2025-06-17 06:53:03.049956	2025-06-17 06:53:03.049956	en	light
245	245	\N	\N	\N	\N	2025-06-17 08:11:01.241804	2025-06-17 08:11:01.241804	en	light
246	246	\N	\N	\N	\N	2025-06-17 12:45:14.164628	2025-06-17 12:45:14.164628	en	light
247	247	\N	\N	\N	\N	2025-06-17 14:23:10.135482	2025-06-17 14:23:10.135482	en	light
248	248	\N	\N	\N	\N	2025-06-18 01:02:37.105448	2025-06-18 01:02:37.105448	en	light
249	249	\N	\N	\N	\N	2025-06-18 19:39:29.142519	2025-06-18 19:39:29.142519	en	light
250	250	\N	\N	\N	\N	2025-06-19 05:14:03.095885	2025-06-19 05:14:03.095885	en	light
251	251	\N	\N	\N	\N	2025-06-19 09:39:16.163235	2025-06-19 09:39:16.163235	en	light
\.


--
-- Data for Name: restaurant_copies; Type: TABLE DATA; Schema: public; Owner: bentobook
--

COPY public.restaurant_copies (id, user_id, restaurant_id, copied_restaurant_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: restaurants; Type: TABLE DATA; Schema: public; Owner: bentobook
--

COPY public.restaurants (id, name, address, latitude, longitude, notes, user_id, google_restaurant_id, cuisine_type_id, street, street_number, postal_code, city, state, country, phone_number, url, business_status, rating, price_level, opening_hours, favorite, created_at, updated_at, original_restaurant_id) FROM stdin;
1	La Guincheuse	266 Rue du Faubourg Saint-Martin, 75010 Paris, France	\N	\N		3	1	17	Rue du Faubourg Saint-Martin	266	75010	Paris	Île-de-France	France	01 42 09 41 53	https://www.instagram.com/laguincheuse/	OPERATIONAL	\N	2	\N	f	2024-11-16 22:10:07.900272	2024-11-16 22:10:07.900272	\N
2	Le Bouillon du Coq	37 Bd Jean Jaurès, 93400 Saint-Ouen-sur-Seine, France	\N	\N	Thierry Marx\r\nDe fait, le céleri rémoulade s’affiche à 3,10 €, la saucisse au couteau/purée est proposée à 12,60 € et le chou chantilly reste sous la barre des 3 €. Une belle démonstration de marxisme culinaire.\r\nOuvert tous les jours de midi à 23 h. Pas de réservation. Accès : métro Mairie de Saint-Ouen (lignes 13 et 14)	12	2	17	Boulevard Jean Jaurès	37	93400	Saint-Ouen-sur-Seine	Île-de-France	France	01 86 53 46 56	https://lebouillonducoq.com/	OPERATIONAL	\N	2	\N	f	2024-11-22 16:28:52.242677	2024-11-22 16:31:40.631725	\N
3	La Grange de Belle Eglise	28 Bd de Belle Église, 60540 Belle-Église, France	\N	\N	La Grange de Belle-Église, 28, boulevard René-Aimé Lagabrielle, Belle-Église (60). Ouvert du mercredi au samedi de 11 h 30 à 13 h et de 19 h 30 à 20 h 30, le mardi de 19 h 30 à 20 h 30. Fermé les dimanches et lundis. Menu du marché à 33 € proposé le midi du mardi au vendredi. Accès : gare de Bornel Belle-Église (TER)	12	3	17	Boulevard de Belle Église	28	60540	Belle-Église	Hauts-de-France	France	03 44 08 49 00	http://www.lagrangedebelleeglise.fr/	OPERATIONAL	\N	2	\N	f	2024-11-22 16:34:04.809999	2024-11-22 16:34:04.809999	\N
84	Série Limithée	\N	\N	\N	3T plats russes lu-ve 10-15h30\nplat 13,9€ formule 20,90\nrésa	12	77	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	1	\N	f	2025-04-27 10:02:56.728562	2025-04-27 10:04:46.765339	\N
4	MOSUGO PARIS 2 PAR MORY SACKO	35 Rue des Jeuneurs, 75002 Paris, France	\N	\N	Sur place, on se régale de poulet frit et de gaufres, à marier avec des frites de patate douce sauce cajun ou une sucrine grillée pour ceux qui veulent faire croire qu’ils ne sont pas venus là (que) pour faire du (bon) gras.\r\nMosugo, 35, rue des Jeûneurs, Paris (2e). Ouvert du lundi au vendredi de 11 h 30 à 14 h 30 et de 18 h 30 à 22 h, le samedi de 11 h 30 à 15 h 30 et de 18 h 30 à 22 h 30. Accès : métro Bourse (ligne 3) ou Grands Boulevards (lignes 8 et 9). Infos et réservations (uniquement le soir) sur mosugo.com	12	4	30	Rue des Jeuneurs	35	75002	Paris	Île-de-France	France	09 88 56 77 48	https://mosugo.com/	OPERATIONAL	\N	2	\N	f	2024-11-22 16:36:37.719768	2024-11-22 16:43:07.03046	\N
5	7oumani chez Issam	65 Av. Edouard Vaillant, 93500 Pantin, France	\N	\N	le lablabi, un des plats phares de la cuisine tunisienne composé de pois chiches, d’un bouillon fin aromatisé à l’ail et au cumin, généralement servi sur des morceaux de pain rassis. On nous met au travail : on va couper en petits morceaux une demi-baguette dans une assiette creuse avant de redonner l’assiette au chef. Quelques minutes plus tard, on la récupère pleine, avec un œuf mollet sur le dessus. Nous sommes invités à bien mélanger le tout. Le pain se gorge du bouillon créant une pâte veloutée divinement parfumée. C’est surprenant, mais follement réconfortant. Le keftaji – légumes frits (poivrons, courgettes et tomates) mélangés avec des œufs – servi avec une assiette de frites maison, en format chips, est tout aussi réussi. Les portions sont extrêmement généreuses, laissant peu d’opportunités à une brick de prendre sa place, mais elle est tout aussi recommandable, bien croustillante et très bien garnie. Tous les plats sont aussi proposés en format sandwich.\r\nOuvert tous les jours de 10 h à 23 h. Accès : métro Aubervilliers–Pantin–Quatre Chemins (ligne 7)	12	5	25	Avenue Edouard Vaillant	65	93500	Pantin	Île-de-France	France	06 62 82 09 41	https://www.facebook.com/7oumaniissam	OPERATIONAL	\N	1	\N	f	2024-11-22 16:49:41.493796	2024-11-22 16:49:41.493796	\N
6	L'Avanos	19 Promenée Marat, 94200 Ivry-sur-Seine, France	\N	\N	un döner, le plus célèbre des sandwichs turcs que vous pourrez aussi déguster à l’assiette. Tout est artisanal, du pain à la broche. Le thé est offert.\r\nOuvert tous les jours sauf le dimanche de 10 h 30 à 23 h.\r\nM° Mairie d'Ivry	12	6	40	Promenée Marat	19	94200	Ivry-sur-Seine	Île-de-France	France	09 83 54 75 92	https://lavanos-restaurant-ivry-sur-seine.eatbu.com/	OPERATIONAL	\N	1	\N	f	2024-11-22 16:51:49.929644	2024-11-22 16:52:26.215496	\N
7	La Marmite d’Afrique, restaurant social et solidaire	116 Rue de Crimée, 75019 Paris, France	\N	\N	Ouvert du lundi au samedi de 11 h 30 à 19 h. Accès : métro Laumière ou Ourcq\r\nLa grande salle s’apparente à une cantine et l’on va d’ailleurs se servir comme dans un self. Mafé, tieb, yassa, saga saga : vous êtes assurément au bon endroit pour suivre un cours de rattrapage des spécialités d’Afrique de l’Ouest. Généreux, sans fioritures, savoureux, cuisiné chaque matin sur place avec des produits frais… Certainement l’un des meilleurs rapports qualité/prix de la capitale !	12	7	1	Rue de Crimée	116	75019	Paris	Île-de-France	France	09 81 44 33 70	https://lamarmitedafrique.org/	OPERATIONAL	\N	1	\N	f	2024-11-22 16:54:45.710946	2024-11-22 16:54:45.710946	\N
9	Fleur D'Orient	96 Rue Charles Tillon, 93300 Aubervilliers, France	\N	\N	une planque street food de 8 m2\r\n\r\nMurs bleu Matisse, empilage de conserves de harissa, guirlandes de piments séchés… « Pittoresque », comme dirait le magazine Elle. À côté des traditionnels fricassés et autres chabatti, Salem et sa petite équipe réalisent à toute heure des sandwiches kefteji bien maous à tarifs imbattables. Moyennant un billet de cinq, on vous garni une demi-baguette avec du thon émietté, deux œufs au plat mitonnés minute, frites maison, oignons rouges et concombre crus, cornichons croquants, olives noires et vertes, pickles de carotte (maison)… Le tout dopé à la harissa (maison itou) et au piment vert et rouge, gentillesse du staff en prime. Pas de table à l’intérieur, mais deux mange-debout dehors. L’occasion sinon de découvrir en mangeant et en marchant le quartier du Montfort fait de petits pavillons avec jardin, héritage ouvrier du XIXe siècle.\r\nOuvert tous les jours de 10 h à minuit. Kefteji : 5 €. Chabatti : 4,50 €. Fricassé : 2,50 €. Smoothies de fruits frais : 3,50 €. Sodas : 1 €. Accès : métro Fort d’Aubervilliers (ligne 7) / gare de La Courneuve-Aubervilliers (RER B)	12	9	25	Rue Charles Tillon	96	93300	Aubervilliers	Île-de-France	France			OPERATIONAL	\N	1	\N	f	2024-11-22 17:01:19.17009	2024-11-22 17:01:19.17009	\N
91	GHIDO RAMEN	\N	\N	\N	3T me-di\nramen 15-17	12	84	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0	\N	f	2025-04-27 16:36:11.788684	2025-04-27 16:38:29.299445	\N
92	Chez Magda	\N	\N	\N	3T géorgien ma-di 12-23h\ncarte 20-35€	12	19	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	2	\N	f	2025-04-27 16:41:13.716515	2025-04-27 16:42:30.611123	\N
93	La Popotière	\N	\N	\N	3T Auvergnat\nje-lu\ndéj 21€	12	85	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	1	\N	f	2025-04-27 16:45:18.142653	2025-04-27 16:47:16.740333	\N
94	Kuna Masala	\N	\N	\N	3T indien lu-di	12	86	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	1	\N	f	2025-04-27 16:47:33.625686	2025-04-27 16:48:35.246781	\N
96	Public House Paris	\N	\N	\N	3T cocktails ma-sa 19-02h	12	88	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	2	\N	f	2025-04-27 16:55:20.84404	2025-04-27 17:01:30.679775	\N
103	Mindelo	\N	\N	\N	3T portugais cap vert lu-sa déj 17€	12	95	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	1	\N	f	2025-04-27 17:30:31.26161	2025-04-27 17:31:31.830086	\N
104	Casimir	\N	\N	\N	3T tlj menu déj 24€	12	96	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	2	\N	f	2025-04-27 17:33:11.909724	2025-04-27 17:36:38.979053	\N
105	ROUND Egg Buns PARIS 10	\N	\N	\N	3T midi moins cher lu-di menu 13,50 - 16,50	12	97	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	1	\N	f	2025-04-27 17:36:57.537356	2025-04-27 17:38:11.332256	\N
10	Restaurant Sidi Bou	69 Av. Jean Jaurès, 93300 Aubervilliers, France	\N	\N	Ouvert tous les jours de 11 h à 23 h 30. Couscous daurade : 12 €. Couscous au mérou : 13 €. Couscous au poulpe : 14 €. Spaghettis aux fruits de mer : 14 €. Daurade entière, sardines, thon ou espadon grillés : 12 à 13 €. Souris d’agneau Galla : 15 €. Accès : métro Aubervilliers-Pantin-Quatre Chemins (ligne 7). \r\nle couscous de la mer ! Au mérou, à la daurade ou même au poulpe\r\nsouris d’agneau dite « à la gargoulette » : cuite au four dans une golla, une sorte de cruche en terre cuite, façon tagine, et servie avec des pommes de terre	12	10	25	Avenue Jean Jaurès	69	93300	Aubervilliers	Île-de-France	France	01 48 34 62 41	http://www.sidibouaubervilliers.fr/	OPERATIONAL	\N	1	\N	f	2024-11-22 17:06:14.255993	2024-11-22 17:06:14.255993	\N
11	Chawachine	63 Av. Edouard Vaillant, 93500 Pantin, France	\N	\N	Le chabatti : le casse-croûte tounsi par excellence ! Aucun rapport avec le chapati indien. C’est un petit pain rond et plat fourré de tout un tas de bonnes choses : omelette, thon émietté, pommes de terre, harissa, huile d’olive, oignons, persil émincé, fromage… De quoi caler les plus grosses faims. Et Chawachine en est le temple ! Depuis 2015, cette échoppe aux murs constellés de billets porte-bonheur et d’anciennes photographies de Tunis ne désemplit pas. Issam Khouaja, le sympathique taulier, y est pour beaucoup. L’autre grande spécialité du cru : le jwajem. Une sorte de smoothie calorifère (mais trop bon) qui ferait s’étouffer une blogueuse mode : fruits frais mixés (trois sortes, à choisir), customisés à l’envi de noisettes, noix, miel, pâte de datte ou dragées de toutes les couleurs. Attention, ni chaises ni tables dans la cahute. Seulement deux mange-debout à l’extérieur. Conseil d’ami : prenez à emporter et filez vous asseoir sur un banc au square Lapérouse voisin !\r\nOuvert tous les jours de 11 h 30 à 1 h. Chabatti et jus de fruits : 5 €. Accès : métro Aubervilliers-Pantin-Quatre Chemins (ligne 7) / gare de Pantin (RER E)	12	11	25	Avenue Edouard Vaillant	63	93500	Pantin	Île-de-France	France	06 62 82 09 41		OPERATIONAL	\N	1	\N	f	2024-11-22 17:08:23.015456	2024-11-22 17:08:23.015456	\N
13	Dong Tam	12bis Rue Caillaux, 75013 Paris, France	\N	\N	Dans le sud du pays, là où le Mékong s’éclate en neuf grandes rivières, le poisson est roi, et on le mange entre autres caramélisé dans un plat nommé cá kho tộ. Il arrive crépitant dans sa marmite en terre cuite avec ses petits légumes et herbes aromatiques. On peut terminer le voyage avec un cà phê, ici évidemment à la vietnamienne, sucré au lait concentré.\r\nOuvert tous les jours de 11 h à 15 h 30 et de 18 h à 22 h 30. Plats autour de 11 €. Accès : métro Porte de Choisy (ligne 7) / tramway T3a arrêt Porte de Choisy	12	13	43	Rue Caillaux	12bis	75013	Paris	Île-de-France	France	09 56 16 83 10		OPERATIONAL	\N	1	\N	f	2024-11-22 17:13:27.064867	2024-11-22 17:13:27.064867	\N
14	Pho Co	142 Bd Masséna, 75013 Paris, France	\N	\N	La spécialité de la capitale du Vietnam, un plat garni de vermicelles de riz, de fines tranches de porc grillé et de boulettes de porc, de salade, d’herbes fraîches à tremper dans de la sauce nuoc-mâm. Omniprésent à Hanoï, il se fait rare dans l’Hexagone mais vous pourrez en manger chez Pho Co, une jolie cantine à la devanture peu engageante sur le bruyant boulevard Masséna.\r\nOuvert tous les jours de 12 h à 15 h et du mercredi au samedi de 19 h à 22 h. a. Bun cha : 12,50 €. Accès : métro Porte de Choisy (ligne 7) / tramway T3a arrêt Porte de Choisy	12	14	43	Boulevard Masséna	142	75013	Paris	Île-de-France	France	09 73 88 02 38		OPERATIONAL	\N	1	\N	f	2024-11-22 17:15:31.441825	2024-11-22 17:15:31.441825	\N
15	Impérial Choisy 美丽都	32 Av. de Choisy, 75013 Paris, France	\N	\N	Ils sont nombreux, les canards laqués, dans les vitrines de l’avenue de Choisy ! Mais où s’attabler pour déguster ce plat mythique ? Choisissez l’Imperial Choisy, une véritable rôtisserie. En préambule, goûtez la salade de méduse puis craquez pour le canard laqué aux cinq parfums. Délicatement mariné et frit, il est parfait, à la fois croustillant et fondant sous la dent. Ambiance cantine, service plus rapide qu’aimable, mais sans conteste la rôtisserie où s’attabler dans le quartier chinois.\r\n\r\nInfos pratiques : Imperial Choisy, 32, avenue de Choisy, Paris (13ᵉ). Ouvert tous les jours de 12 h à 23 h. Canard laqué : 11,50 €. Accès : métro Porte de Choisy (ligne 7) / tramway T3a arrêt Porte de Choisy	12	15	14	Avenue de Choisy	32	75013	Paris	Île-de-France	France	01 45 86 42 40	http://www.imperialchoisy.fr/menu	OPERATIONAL	\N	2	\N	f	2024-11-22 17:17:11.849894	2024-11-22 17:17:11.849894	\N
16	Chinatown Olympiades	44 Av. d'Ivry, 75013 Paris, France	\N	\N	optez pour une conviviale et revigorante fondue chinoise. Comme Tricotin, Chinatown Olympiades est une adresse fétiche de la communauté chinoise. Les familles s’y retrouvent autour de grandes tables rondes avant un karaoké enflammé. Tous les soirs, dès 21 h, la lumière se tamise pour laisser place aux boules à facettes et aux guirlandes lumineuses. N’oubliez pas les paroles, c’est karaoké, et il se dit que Chinatown Olympiades accueille la crème de la crème des chanteurs.\r\nOuvert tous les jours de 11 h 45 à 14 h 45 et de 18 h 30 à 23 h 15. Accès : métro Porte d’Ivry (ligne 7), métro Olympiades (ligne 14) / tramway T3a arrêt Porte d’Ivry.	12	16	14	Avenue d'Ivry	44	75013	Paris	Île-de-France	France	01 45 84 72 21	https://www.chinatownolympiades.com/	OPERATIONAL	\N	1	\N	f	2024-11-22 17:20:06.503759	2024-11-22 17:20:06.503759	\N
17	Khai Tri	93 Av. d'Ivry, 75013 Paris, France	\N	\N	Khai Tri, c’est des banh mi et des livres vietnamiens. Une petite échoppe où l’on débite le célèbre sandwich vietnamien que l’on retrouve à tous les coins de rues, de Hanoï à Hô Chi Minh-Ville. Une demi-baguette crousti-moelleuse tartinée de pâté de porc, de la viande goûteuse encore tiède, quelques lamelles de concombre et de carottes râpées légèrement vinaigrées, de la coriandre fraîche, quelques gouttes de la mythique sauce Maggi et un peu de mayonnaise.\r\nOuvert du mardi au dimanche de 10 h à 16 h. Sandwich spécial Bánh mì đặc biệt (poulet + pâté de porc + viande de porc) : 4,10 €. Accès : métro Tolbiac (ligne 7) ou Olympiades (ligne 14)	12	17	43	Avenue d'Ivry	93	75013	Paris	Île-de-France	France	01 45 82 95 81	http://banhmikhaitri.netlify.app/	OPERATIONAL	\N	1	\N	f	2024-11-22 17:21:42.46774	2024-11-22 17:21:42.46774	\N
40	La Blague café associatif	126 Rue Danielle-Casanova, 93300 Aubervilliers, France	\N	\N	ma-ve midi 15€\r\nFort d'Aubervilliers	12	39	30	Rue Danielle-Casanova	126	93300	Aubervilliers	Île-de-France	France	01 79 64 37 34	http://cafelablague.fr/	OPERATIONAL	\N	1	\N	f	2025-01-19 11:23:01.794422	2025-01-19 11:23:13.50993	\N
44	La Guincheuse	266 Rue du Faubourg Saint-Martin, 75010 Paris, France	\N	\N		95	1	17	Rue du Faubourg Saint-Martin	266	75010	Paris	Île-de-France	France	01 42 09 41 53	https://www.instagram.com/laguincheuse/	OPERATIONAL	\N	2	\N	f	2025-02-10 17:47:43.981307	2025-02-10 17:47:43.981307	\N
95	Kitchen Izakaya	\N	\N	\N	3T lu-sa Japonais \nmidi 19-30	12	87	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0	\N	f	2025-04-27 16:50:33.196078	2025-04-27 16:51:19.912039	\N
106	Adami	\N	\N	\N	3T MA_SA\nASSIETTE 4-10 carte 35-40	12	98	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	2	\N	f	2025-04-27 17:39:37.47788	2025-04-27 17:40:56.782141	\N
146	Kébi	\N	\N	\N	2T je-lu 25€	12	138	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	1	\N	f	2025-04-28 13:29:21.733187	2025-04-28 13:29:58.919794	\N
85	Nakatsu	\N	\N	\N	3T japonais ma-di\ndéj 16€	12	78	23	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	1	\N	f	2025-04-27 10:15:38.666377	2025-04-28 10:03:04.293503	\N
12	Ngoc Xuyen Saigon	4 Rue Caillaux, 75013 Paris, France	\N	\N	pho. Devanture rose flashy, cuisine ouverte à l’entrée regorgeant de grosses marmites fumantes, tables collées serrées garnies d’une collection de sauces et de piments. Ici, pas de carte à rallonge, semainier de soupes affiché au mur et le bun bo Huê servi tous les jours. Toujours une très bonne pioche. Le gros bol arrive débordant : goûteux bouillon de bœuf agrémenté de nouilles de riz, de tranches de bœuf saignantes, de boulettes d’abats de bœuf et de soja, basilic thaï et de citron vert. \r\ntous les jours de 9 h à 17 h sauf le dimanche. Soupe phở : 13,50 €. Accès : métro Porte de Choisy (ligne 7) / tramway T3a arrêt Porte de Choisy	12	12	43	Rue Caillaux	4	75013	Paris	Île-de-France	France	01 44 24 14 31	http://ngocxuyensaigon.net/	OPERATIONAL	\N	1	\N	f	2024-11-22 17:11:19.738477	2024-11-22 17:32:24.41531	\N
86	TRÂM 130	\N	\N	\N	3T lu-ve soir	12	79	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	2	\N	f	2025-04-27 16:20:14.575041	2025-04-27 16:21:38.087673	\N
32	Chôô Chaï	185 Av. Jean Jaurès, 93300 Aubervilliers, France	\N	\N	Aubervilliers-Pantin-4 Chemins	12	31	39	Avenue Jean Jaurès	185	93300	Aubervilliers	Île-de-France	France	07 78 15 72 05	https://sites.google.com/view/choo-chai/accueil/faq	OPERATIONAL	\N	1	\N	f	2025-01-19 10:54:08.218382	2025-01-19 10:54:08.218382	\N
18	Le Bastringue	67 Quai de la Seine, 75019 Paris, France	\N	\N	Pas mal, pas cher, mais très bruyant.	3	18	17	Quai de la Seine	67	75019	Paris	Île-de-France	France	01 42 09 89 27		OPERATIONAL	2	2	\N	f	2024-11-28 12:13:36.57898	2024-11-28 15:58:33.14682	\N
20	Le Baron Rouge	1 Rue Théophile Roussel, 75012 Paris, France	\N	\N		3	20	6	Rue Théophile Roussel	1	75012	Paris	Île-de-France	France	01 43 43 14 32	http://lebaronrouge.net/	OPERATIONAL	4	2	\N	f	2024-12-02 15:51:33.2385	2024-12-02 15:51:33.2385	\N
22	La Grange de Belle Eglise	28 Bd de Belle Église, 60540 Belle-Église, France	\N	\N	Menu de midi 33€. 40 min du gare du nord...	3	3	30	Boulevard de Belle Église	28	60540	Belle-Église	Hauts-de-France	France	03 44 08 49 00	http://www.lagrangedebelleeglise.fr/	OPERATIONAL	\N	4	\N	f	2024-12-12 15:41:01.299811	2024-12-12 15:41:01.299811	\N
23	龙抄手总店 Ravioli du Sichuan	50 Rue de Provence, 75009 Paris, France	\N	\N		3	22	14	Rue de Provence	50	75009	Paris	Île-de-France	France	01 40 35 75 06		OPERATIONAL	\N	\N	\N	f	2024-12-16 11:42:52.187871	2024-12-16 11:42:52.187871	\N
24	KUTI - Montreuil	3 Rue Victor Hugo, 93100 Montreuil, France	\N	\N		12	23	1	Rue Victor Hugo	3	93100	Montreuil	Île-de-France	France		http://www.kutigroup.com/	OPERATIONAL	\N	\N	\N	f	2025-01-19 10:29:44.465447	2025-01-19 10:29:44.465447	\N
25	KUTI - Petites Ecuries	6 R. des Petites Écuries, 75010 Paris, France	\N	\N		12	24	1	Rue des Petites Écuries	6	75010	Paris	Île-de-France	France	01 86 22 29 09	https://www.instagram.com/kutifood	OPERATIONAL	\N	\N	\N	f	2025-01-19 10:30:52.893416	2025-01-19 10:30:52.893416	\N
26	Les petites dalles	357 Rue Lecourbe, 75015 Paris, France	\N	\N	menu du midi 17€\r\nmétro Balard	12	25	30	Rue Lecourbe	357	75015	Paris	Île-de-France	France	09 87 77 77 19	http://lespetitesdalles.fr/	OPERATIONAL	\N	1	\N	f	2025-01-19 10:33:24.759789	2025-01-19 10:33:24.759789	\N
87	Céline Lecoeur Pâtisserie	\N	\N	\N	3T pâtisserie ma-sa 10h30-18h30\ndéj 11-13€	12	80	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	1	\N	f	2025-04-27 16:23:23.688373	2025-04-27 16:24:41.973236	\N
27	l'Olivier du Kef	73 Rue de Strasbourg, 94300 Vincennes, France	\N	\N	Couscous à partir de 18€\r\nCroix de Chavaux ou gare de Vincennes	12	26	1	Rue de Strasbourg	73	94300	Vincennes	Île-de-France	France	09 54 65 18 60		OPERATIONAL	\N	1	\N	f	2025-01-19 10:36:29.36208	2025-01-19 10:38:17.918639	\N
97	Argile restaurant	\N	\N	\N	4T lu-je ve midi et soir, ma et je midi\ndéj 26€	12	89	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	2	\N	f	2025-04-27 17:01:55.522641	2025-04-27 17:05:01.091682	\N
107	Altro Frenchie	\N	\N	\N	3T ma-sa italien déj 27-34	12	99	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	2	\N	f	2025-04-27 17:42:20.71653	2025-04-27 17:43:10.151044	\N
28	La Café de l'ici	19 Rue Léon, 75018 Paris, France	\N	\N	Menu midi 10€\r\nBarbès\r\nts jrs 9-18h sf lundi	12	27	1	Rue Léon	19	75018	Paris	Île-de-France	France			OPERATIONAL	\N	1	\N	f	2025-01-19 10:40:16.472184	2025-01-19 10:42:49.185139	\N
29	Matka	78 R. Quincampoix, 75003 Paris, France	\N	\N	mercredi-dimanche \r\nmidi menu 24-29€\r\nRambuteau	12	28	30	Rue Quincampoix	78	75003	Paris	Île-de-France	France	01 44 93 58 14	https://www.matkarestaurant.fr/	OPERATIONAL	\N	2	\N	f	2025-01-19 10:43:43.122759	2025-01-19 10:45:44.286615	\N
30	La Cantine Pas Si Loin - Artagon	Artagon Pantin, 34 Rue Cartier Bresson Bâtiment gauche, 93500 Pantin, France	\N	\N	Prix libre\r\nsimple et bon\r\ndans un ancien collège	12	29	30	Rue Cartier Bresson	34	93500	Pantin	Île-de-France	France	06 21 30 25 51	https://linktr.ee/passiloin	OPERATIONAL	\N	1	\N	f	2025-01-19 10:47:37.886673	2025-01-19 10:47:37.886673	\N
31	POUSH	153 Av. Jean Jaurès, 93300 Aubervilliers, France	\N	\N	Poull, Cantine de Poush\r\nma-sa 10-22 Aubervilliers-Pantin 4 Chemins\r\n	12	30	30	Avenue Jean Jaurès	153	93300	Aubervilliers	Île-de-France	France	01 88 50 19 59	https://poush.fr/	OPERATIONAL	\N	1	\N	f	2025-01-19 10:52:15.377151	2025-01-19 10:52:15.377151	\N
33	L'inattendu Villecresnes Emilien Rouable	36 Rue du Général Leclerc, 94440 Villecresnes, France	\N	\N	menu 4 temps 49€\r\ngare Boissy St Léger puis bus 21 arrêt Foreau	12	32	17	Rue du Général Leclerc	36	94440	Villecresnes	Île-de-France	France	01 75 36 61 52	https://www.restaurantlinattendu.com/?utm_source=gmb	OPERATIONAL	\N	3	\N	f	2025-01-19 10:57:58.273714	2025-01-19 10:57:58.273714	\N
34	Restaurant Omar Dhiab	23 Rue Hérold, 75001 Paris, France	\N	\N	menu déjeuner 58€	12	33	30	Rue Hérold	23	75001	Paris	Île-de-France	France	01 42 33 52 47	https://omardhiab.com/	OPERATIONAL	\N	3	\N	f	2025-01-19 11:00:59.616818	2025-01-19 11:00:59.616818	\N
35	Faubourg Daimant	20 Rue du Faubourg Poissonnière, 75010 Paris, France	\N	\N	végétal festif	12	34	30	Rue du Faubourg Poissonnière	20	75010	Paris	Île-de-France	France	07 88 09 73 48	https://www.daimant.co/faubourg-daimant.html	OPERATIONAL	\N	\N	\N	f	2025-01-19 11:06:25.574161	2025-01-19 11:06:25.574161	\N
36	Chez lili apsara	12 Bd Chanzy, 93100 Montreuil, France	\N	\N	centre commercial Croix de Chavaux	12	35	3	Boulevard Chanzy	12	93100	Montreuil	Île-de-France	France			OPERATIONAL	\N	1	\N	f	2025-01-19 11:09:17.76539	2025-01-19 11:10:00.747601	\N
37	Mây Bay - Restaurant vietnamien vegan végétarien	33 Rue des Laitières, 94300 Vincennes, France	\N	\N	menu 22,50\r\npho 15,90	12	36	3	Rue des Laitières	33	94300	Vincennes	Île-de-France	France	01 43 28 86 91	https://maybayrestaurant.com/	OPERATIONAL	\N	1	\N	f	2025-01-19 11:14:28.444002	2025-01-19 11:14:28.444002	\N
38	LA COLLECTIVE PARISIENNE	70 Rue François Miron, 75004 Paris, France	\N	\N	lu-sa 12-17h\r\nmenu 10€\r\nmétro St-Paul	12	37	30	Rue François Miron	70	75004	Paris	Île-de-France	France		https://www.facebook.com/lacollectiveparisienne	OPERATIONAL	\N	1	\N	f	2025-01-19 11:17:43.73027	2025-01-19 11:17:43.73027	\N
39	Le Pouilly-Reuilly	68 Rue André Joineau, 93310 Le Pré-Saint-Gervais, France	\N	\N	midi 18-25€\r\nmétro Hoche	12	38	17	Rue André Joineau	68	93310	Le Pré-Saint-Gervais	Île-de-France	France	09 88 07 65 99		OPERATIONAL	\N	1	\N	f	2025-01-19 11:19:56.527051	2025-01-19 11:20:36.242766	\N
21	Chez les Garçons	5 Rue Cuvier, 69006 Lyon, France	\N	\N	Recommendé par Kent et Freddy...	3	21	17	Rue Cuvier	5	69006	Lyon	Auvergne-Rhône-Alpes	France	04 78 24 51 07		OPERATIONAL	2	2	\N	f	2024-12-02 18:11:56.763797	2025-03-20 17:09:33.204571	\N
45	Le Baron Rouge	1 Rue Théophile Roussel, 75012 Paris, France	\N	\N	Best wine bar in Paris.	95	20	6	Rue Théophile Roussel	1	75012	Paris	Île-de-France	France	01 43 43 14 32	http://lebaronrouge.net/	OPERATIONAL	\N	1	\N	f	2025-02-10 17:48:22.123234	2025-02-10 17:48:22.123234	\N
46	Magazzino52	Via Giovanni Giolitti, 52/A, 10123 Torino TO, Italy	\N	\N	omg so good	95	40	22	Via Giovanni Giolitti	52/A	10123	Torino	Piemonte	Italy	011 427 1938	http://www.magazzino52.it/	OPERATIONAL	\N	3	\N	f	2025-02-10 17:49:00.087586	2025-02-10 17:49:00.087586	\N
47	The Fat Duck	High St, Bray, Maidenhead SL6 2AQ, UK	\N	\N	one day...	95	41	17	High Street		SL6 2AQ	Bray	England	United Kingdom	01628 580333	http://www.thefatduck.co.uk/	OPERATIONAL	\N	4	\N	f	2025-02-10 18:02:50.497969	2025-02-10 18:02:50.497969	\N
48	Le Bouillon du Coq	37 Bd Jean Jaurès, 93400 Saint-Ouen-sur-Seine, France	\N	\N		3	2	17	Boulevard Jean Jaurès	37	93400	Saint-Ouen-sur-Seine	Île-de-France	France	01 86 53 46 56	https://lebouillonducoq.com/	OPERATIONAL	\N	\N	\N	f	2025-02-12 11:37:19.591794	2025-02-12 11:37:19.591794	\N
88	L'Attirail	\N	\N	\N	\N	12	81	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	1	\N	f	2025-04-27 16:26:22.916563	2025-04-27 16:26:37.963648	\N
99	OTÉ	\N	\N	\N	3T Réunionnais ma-sa déj 17 soir 35	12	91	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	1	\N	f	2025-04-27 17:14:43.21297	2025-04-27 17:16:11.025553	\N
89	La Source	\N	\N	\N	3T	12	82	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	1	\N	f	2025-04-27 16:28:51.144312	2025-04-27 16:29:19.567618	\N
50	Moderno	12 Rue Vitruve, 75020 Paris, France	\N	\N	déj 19-23€\r\n3T\r\n	12	43	22	Rue Vitruve	12	75020	Paris	Île-de-France	France	09 56 27 11 84	https://moderno-xx.com/	OPERATIONAL	\N	2	\N	f	2025-02-21 17:51:21.11646	2025-02-21 17:52:53.751778	\N
51	Leven	110 Rue Montmartre, 75002 Paris, France	\N	\N	déj 16,50€ (à emporter seulement)	12	44	25	Rue Montmartre	110	75002	Paris	Île-de-France	France	01 53 40 84 97	https://linktr.ee/levenfoodeli	OPERATIONAL	\N	1	\N	f	2025-02-21 17:56:24.359218	2025-02-21 17:56:24.359218	\N
52	Menkicchi Ramen	1 Rue de la Grange Batelière, 75009 Paris, France	\N	\N	ramen 14-16€	12	45	23	Rue de la Grange Batelière	1	75009	Paris	Île-de-France	France	01 47 70 41 65	https://kintarogroup.com/menkicchi/	OPERATIONAL	\N	1	\N	f	2025-02-21 18:04:45.068446	2025-02-21 18:04:45.068446	\N
53	Lacigne	124 Ave Parmentier, 75011 Paris, France	\N	\N	déj 20-22€ dîner 45\r\n	12	46	23	Avenue Parmentier	124	75011	Paris	Île-de-France	France		https://www.instagram.com/lacigne.par%20lacigne.reserve@gmail.com	OPERATIONAL	\N	2	\N	f	2025-02-21 18:11:28.363596	2025-02-21 18:11:28.363596	\N
54	Mokochaya	11 Rue Saint-Bernard, 75011 Paris, France	\N	\N	bento 14€\r\nmidi moins cher\r\n3T	12	47	23	Rue Saint-Bernard	11	75011	Paris	Île-de-France	France			OPERATIONAL	\N	1	\N	f	2025-02-21 18:20:53.591028	2025-02-21 18:20:53.591028	\N
55	Georgette	44 Rue d'Assas, 75006 Paris, France	\N	\N	déj 25€ en semaine\r\ntjrs\r\n3T\r\n	12	48	30	Rue d'Assas	44	75006	Paris	Île-de-France	France	01 45 44 44 44	http://www.restaurant-georgette.fr/	OPERATIONAL	\N	2	\N	f	2025-02-21 18:23:10.182293	2025-02-21 18:23:10.182293	\N
56	Au Trou Gascon	40 Rue Taine, 75012 Paris, France	\N	\N	déj 25-29€	12	49	17	Rue Taine	40	75012	Paris	Île-de-France	France	01 88 61 56 31	https://autrougasconparis.fr/	OPERATIONAL	\N	2	\N	f	2025-02-21 18:26:54.58599	2025-02-21 18:26:54.58599	\N
57	DUPIN & Chef Fernando De Tomaso	11 Rue Dupin, 75006 Paris, France	\N	\N	déj 27,5€\r\n3T	12	50	30	Rue Dupin	11	75006	Paris	Île-de-France	France	01 42 22 64 56	https://restaurant-dupin.fr/	OPERATIONAL	\N	2	\N	f	2025-02-21 18:29:07.937228	2025-02-21 18:29:07.937228	\N
59	Chez Camille	8 Rue Ravignan, 75018 Paris, France	\N	\N	Bar historique butte Montmartre\r\n3T	12	52	6	Rue Ravignan	8	75018	Paris	Île-de-France	France	01 42 57 75 62	http://www.facebook.com/Chez-Camille-112695022123953/	OPERATIONAL	\N	1	\N	f	2025-02-21 18:35:40.15888	2025-02-21 18:35:40.15888	\N
60	Clos d’Astorg	22 Rue d'Astorg, 75008 Paris, France	\N	\N	menu entrée plat 25€\r\n3T	12	53	30	Rue d'Astorg	22	75008	Paris	Île-de-France	France	01 55 06 18 16	https://bookings.zenchef.com/results?rid=367742&pid=1001	OPERATIONAL	\N	2	\N	f	2025-02-21 18:39:24.384923	2025-02-21 18:39:24.384923	\N
49	Restaurant Aux Perchés	25 Rue Servandoni, 75006 Paris, France	\N	\N		12	42	17	Rue Servandoni	25	75006	Paris	Île-de-France	France	06 74 35 01 90	https://www.auxperches.com/	OPERATIONAL	1	2	\N	f	2025-02-21 17:45:20.510505	2025-02-26 13:54:01.78781	\N
108	Blanca Restaurant	\N	\N	\N	3T basco-argentin\nlu-sa déj 17,50€	12	100	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	2	\N	f	2025-04-27 17:44:13.030157	2025-04-27 17:45:16.099076	\N
58	Foodi Jia-Ba-Buay	2 Rue du Nil, 75002 Paris, France	\N	\N	déj 21-24€\r\nbento 17\r\nbrunch samedi 24\r\n3T	12	51	30	Rue du Nil	2	75002	Paris	Île-de-France	France	01 45 08 48 28	http://www.foodi-jia-ba-buay.fr/	OPERATIONAL	3	2	\N	f	2025-02-21 18:30:44.07482	2025-02-28 23:56:53.305349	\N
62	La Scene Theleme	\N	\N	\N		3	55	30	Rue Troyon	18	75017	Paris	Île-de-France	France	\N	\N	\N	5	4	\N	f	2025-03-01 17:08:39.063309	2025-03-01 17:08:39.063309	\N
63	Dishny	\N	\N	\N		3	56	30	Rue Cail	25	75010	Paris	Île-de-France	France	\N	\N	\N	4	2	\N	f	2025-03-01 17:08:56.772986	2025-03-01 17:08:56.772986	\N
64	Maison Lucas Carton	\N	\N	\N		3	57	30	Place de la Madeleine	9	75008	Paris	Île-de-France	France	\N	\N	\N	5	4	\N	f	2025-03-01 17:09:22.142663	2025-03-01 17:09:22.142663	\N
61	Kolam Paris	27 Rue de Lancry, 75010 Paris, France	\N	\N	3T\r\nsri-lankais\r\n5 places au comptoir ou à emporter	12	54	21	Rue de Lancry	27	75010	Paris	Île-de-France	France	07 45 02 19 06	https://linktr.ee/kolamparis	OPERATIONAL	3	1	\N	f	2025-02-21 18:40:59.217855	2025-03-02 11:51:52.038216	\N
19	Chez Magda	5 Av. Jean Jaurès, 75019 Paris, France	\N	\N	Georgien	3	19	30	Avenue Jean Jaurès	5	75019	Paris	Île-de-France	France	07 51 20 90 64	https://www.chez-magda.com/	OPERATIONAL	4	2	\N	f	2024-11-28 13:11:03.626671	2025-03-03 23:10:45.275206	\N
98	Aldehyde	\N	\N	\N	4T ma-sa\ndéj 35-45\nsoir 95-120	12	90	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	3	\N	f	2025-04-27 17:11:37.184505	2025-04-27 17:13:15.250518	\N
110	Calice	\N	\N	\N	3T franco-japonais ma-di\ndéj 28-34 assiette 12-19€	12	103	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	2	\N	f	2025-04-27 17:52:29.398453	2025-04-27 17:53:30.165749	\N
111	ANNA	\N	\N	\N	3T italien déj 10-24	12	104	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	2	\N	f	2025-04-27 17:54:43.67955	2025-04-27 17:55:20.555948	\N
117	Ayahuma Restaurant	\N	\N	\N	3T Equateur lu-sa déj 17-20€	12	110	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	2	\N	f	2025-04-28 09:28:22.177725	2025-04-28 09:29:53.440443	\N
66	Brasserie Dubillot	\N	\N	\N	\N	12	59	17	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	2	\N	f	2025-03-20 17:23:18.506133	2025-03-20 17:24:14.165162	\N
113	Petit Bruit	\N	\N	\N	3T ma-sa	12	106	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	1	\N	f	2025-04-27 18:27:41.468845	2025-04-27 18:28:24.580576	\N
65	Le Royal China	\N	\N	\N		3	58	14	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	2	\N	f	2025-03-16 13:31:19.243011	2025-03-16 14:18:22.574874	\N
115	naam	\N	\N	\N	3T ma-ve déj 18-22€	12	108	39	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	2	\N	f	2025-04-28 09:15:47.411993	2025-04-28 09:17:16.158376	\N
118	Ryô	\N	\N	\N	3T ma-sa  déj 28-34	12	111	23	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	3	\N	f	2025-04-28 09:31:40.389473	2025-04-28 09:32:50.829422	\N
119	L’Art du Quotidien	\N	\N	\N	3T ma-sa déj 21-25	12	112	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	2	\N	f	2025-04-28 09:35:04.469191	2025-04-28 09:36:05.099355	\N
120	Qasti Green	\N	\N	\N	3T libanais lu-di déj 20€ soir et brunch 38€	12	113	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	2	\N	f	2025-04-28 09:37:06.086774	2025-04-28 09:38:22.930786	\N
121	L'Etoile Berbère	\N	\N	\N	3T lu-sa couscous légumes 14€\nrésa	12	114	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	1	\N	f	2025-04-28 09:41:31.28824	2025-04-28 09:43:30.898821	\N
73	La Voie Lactée	\N	\N	\N	3T buffet d'entrées et plat du jour 16€\nlu-sa	12	65	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0	\N	f	2025-04-27 09:19:58.881539	2025-04-27 09:21:09.785469	\N
8	Au Petit Bar	7 Rue du Mont Thabor, 75001 Paris, France	\N	\N	un bistro figé dans le temps. Rideau en dentelle blanche, éphéméride sur la porte, distributeur de cacahuètes sur le comptoir en formica à côté du téléphone à cadran, journaux La Lozère nouvelle et L’Équipe en libre-service sur la banquette, et de vieilles carafes Ricard sur les tables. La porte du fond de la salle est ouverte sur la cuisine et les vieilles marmites, celles dans lesquelles on fait certainement le meilleur petit salé aux lentilles du jour, comme tous les lundis. Ici, le semainier rythme invariablement la semaine depuis presque 60 ans. Mardi, rôti de veau ; mercredi, rosbif et frites maison ; jeudi, saucisse d’Auvergne et purée maison ; vendredi, gigot d’agneau et haricots coco. Hubert et Michel, tablier bleu, chemise blanche et serviette rouge sur l’épaule, servent avec entrain les habitués qui jouent du coude au comptoir. Hubert et Michel sont frères et ils ont un peu grandi ici, dans ce petit bar que leurs parents ont ouvert en 1966. Les plats, à l’évidence servis dans de vieilles assiettes dépareillées, ont la saveur des plats ménagers et familiaux. Un bistrot qui raconte Paris comme aucun autre.\r\nOuvert de 7 h à 21 h 30 tous les jours sauf le dimanche. Accès : métro Tuileries (ligne 1) ou Concorde (lignes 1, 8 et 12)	12	8	17	Rue du Mont Thabor	7	75001	Paris	Île-de-France	France	01 42 60 62 09		OPERATIONAL	\N	1	\N	f	2024-11-22 16:57:34.558343	2025-03-20 17:22:41.697991	\N
83	Le Blainville - bistro paris 2	\N	\N	\N	3T tlj	12	76	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	2	\N	f	2025-04-27 10:00:29.267437	2025-04-27 10:02:28.325984	\N
114	Le Normandie	\N	\N	\N	4T lu-sa déj 17-20	12	107	30	Rue Custine	13	75018	Paris	Île-de-France	France	09 73 88 06 00	http://www.lenormandieparis.com/	\N	0	2	\N	f	2025-04-28 09:03:16.651331	2025-04-28 09:05:36.022814	\N
68	La Terrasse du Châtel	\N	\N	\N	\N	3	60	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	2	\N	f	2025-03-27 09:28:13.75753	2025-03-27 09:28:26.550748	\N
75	Kiku	\N	\N	\N	3T Japonais lu soir et ma-sa\ndéj 14-24€ soir 30€	12	67	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0	\N	f	2025-04-27 09:26:25.059241	2025-04-27 09:27:48.891138	\N
69	Le Bistrot Aux Vieux Remparts	\N	\N	\N	\N	12	61	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	2	\N	f	2025-03-28 08:47:35.504403	2025-03-28 08:48:09.651105	\N
67	Brasserie Dubillot	\N	\N	\N	Sympa	3	59	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	2	\N	f	2025-03-21 08:28:31.976111	2025-03-31 22:04:16.503359	\N
90	Eats Thyme	\N	\N	\N	3T lu-di\ndéj 19-21€	12	83	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	2	\N	f	2025-04-27 16:31:03.043301	2025-04-27 16:32:17.859243	\N
76	C’est Chouette 枭居	\N	\N	\N	3T chinois  ma-sa\ndi 12-15\nmenu 14,50	12	68	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	1	\N	f	2025-04-27 09:30:59.765718	2025-04-27 09:32:27.331104	\N
70	LE SINGE A PARIS	\N	\N	\N	Recommendation kent	3	62	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	3	\N	f	2025-03-31 22:07:30.158294	2025-03-31 22:07:50.577643	\N
71	Panorama	\N	\N	\N	3T déj 18-21 ma soir - me-sa déj et soir	12	63	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0	\N	f	2025-04-27 09:13:39.418401	2025-04-27 09:15:58.595182	\N
100	Namak - Restaurant Perse	\N	\N	\N	3T iranien ma-sa déj 11,5-20€	12	92	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	1	\N	f	2025-04-27 17:22:48.315464	2025-04-27 17:24:04.499972	\N
72	L'Atelier Dürüm	\N	\N	\N	3T midi moins cher ma-di	12	64	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0	\N	f	2025-04-27 09:16:54.755506	2025-04-27 09:18:07.054326	\N
116	La Bagarre	\N	\N	\N	3T ma-ve dej 14-20€	12	109	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	1	\N	f	2025-04-28 09:23:53.725408	2025-04-28 09:25:41.97548	\N
77	Elsass	\N	\N	\N	3T alsacien\ndéj 27-32€	12	69	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	2	\N	f	2025-04-27 09:34:53.77903	2025-04-27 09:38:25.964008	\N
101	De l'Amitié Café	\N	\N	\N	3T lu-sa 16-02h	12	93	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	1	\N	f	2025-04-27 17:25:33.041725	2025-04-27 17:26:25.203225	\N
78	GATEAUX DE MOCHI	\N	\N	\N	3T à emporter	12	70	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0	\N	f	2025-04-27 09:38:51.585073	2025-04-27 09:43:38.283493	\N
79	ajar	\N	\N	\N	3T me-di\ndéj 25€	12	71	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	2	\N	f	2025-04-27 09:43:58.707885	2025-04-27 09:47:02.553025	\N
102	Kaun Neak Sre	\N	\N	\N	2T cambodgien lu-di\nmenu 11,50-13,90	12	94	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	1	\N	f	2025-04-27 17:28:21.591718	2025-04-27 17:29:40.558979	\N
80	Kiyo Aji	\N	\N	\N	4T japonais\nma-di soir menus 75-110€	12	72	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	3	\N	f	2025-04-27 09:47:27.47056	2025-04-27 09:48:39.823807	\N
122	La Fille du Boucher	\N	\N	\N	3T juif tunisien lu-di sf samedi couscous 15-20€	12	115	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	2	\N	f	2025-04-28 09:44:40.946812	2025-04-28 09:45:48.671621	\N
109	Broken Biscuits	\N	\N	\N	3T midi moins cher pain et sandwichs\nlu-sa\ndéj 9,6-15,5€	12	101	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	1	\N	f	2025-04-27 17:47:33.628688	2025-04-27 17:49:01.437518	\N
81	Restaurant TÊT	\N	\N	\N	3T  tlj 12-14h30 18h30-22h30\nplat 15€	12	73	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	2	\N	f	2025-04-27 09:50:28.376995	2025-04-27 09:52:18.921863	\N
112	BOBBY	\N	\N	\N	3T pizza lu-sa	12	105	22	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	2	\N	f	2025-04-27 18:00:43.122897	2025-04-27 18:01:32.209744	\N
82	Mắm From Hanoï	\N	\N	\N	3T lu-sa plat 17€	12	75	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	2	\N	f	2025-04-27 09:57:10.303983	2025-04-27 09:58:14.512609	\N
126	Crêperie Little Breizh	\N	\N	\N	3T crêperie ma-sa déj 13,9-16,9\ncomplète 9,9€	12	119	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	1	\N	f	2025-04-28 09:56:44.350802	2025-04-28 09:57:47.180135	\N
123	Restaurant L'Oasis	\N	\N	\N	3T couscous marocain tlj sf lu \n16-28€	12	116	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	2	\N	f	2025-04-28 09:47:14.164025	2025-04-28 09:48:01.629109	\N
129	BISTROT MEE	\N	\N	\N	3T 17€ midi	12	122	24	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	1	\N	f	2025-04-28 12:47:24.403352	2025-04-28 12:48:45.059335	\N
124	Unplug - Cocktails & Tapas	\N	\N	\N	3T bar  lu-sa sf ve 18h-minuit\ncocktails 15€	12	117	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	2	\N	f	2025-04-28 09:49:15.356726	2025-04-28 09:50:20.45973	\N
127	Hélia	\N	\N	\N	3T libanais\nlu-sa midi 16€ sf sa messe pour 2 20€	12	120	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	2	\N	f	2025-04-28 10:00:02.646742	2025-04-28 10:01:19.15532	\N
125	Kissproof Belleville	\N	\N	\N	4T bar à cocktails ma-sa  soir 13€	12	118	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	1	\N	f	2025-04-28 09:52:08.429232	2025-04-28 09:52:57.112745	\N
128	Maslow Temple	\N	\N	\N	\N	12	121	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	2	\N	f	2025-04-28 12:38:42.213098	2025-04-28 12:40:00.660324	\N
74	Sapinho	\N	\N	\N	3T Portugais\nma-sa résa	12	66	32	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0	\N	f	2025-04-27 09:22:45.704412	2025-04-28 12:40:59.603509	\N
130	Ebis	\N	\N	\N	\N	12	123	23	Rue Saint-Roch	19	75001	Paris	Île-de-France	France	01 42 61 05 90	https://ebisparis.com/	\N	0	2	\N	f	2025-04-28 12:49:46.015028	2025-04-28 12:51:30.823286	\N
131	L'Officine du Louvre	\N	\N	\N	3T cocktail 14-16€	12	124	6	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0	\N	f	2025-04-28 12:53:22.474377	2025-04-28 12:54:40.07475	\N
132	Little Yak	\N	\N	\N	3T tibétain 15€ sf mardi	12	125	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0	\N	f	2025-04-28 12:55:26.173281	2025-04-28 12:56:33.199363	\N
133	ACCENTS table bourse	\N	\N	\N	3T gastronomique 4 temps 52€	12	126	23	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	3	\N	f	2025-04-28 12:57:35.200267	2025-04-28 12:59:10.215883	\N
134	Alla Mano	\N	\N	\N	2T Street food	12	127	22	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	1	\N	f	2025-04-28 13:00:04.817063	2025-04-28 13:01:21.672663	\N
135	Café Compagnon	\N	\N	\N	3T 40€	12	128	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	2	\N	f	2025-04-28 13:02:31.806984	2025-04-28 13:03:30.264228	\N
136	Jòia par Hélène Darroze	\N	\N	\N	3T 24-29€	12	129	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	3	\N	f	2025-04-28 13:06:48.86598	2025-04-28 13:07:52.954826	\N
137	Oranta	\N	\N	\N	3T ukrainien 15€ midi	12	130	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	1	\N	f	2025-04-28 13:09:04.496314	2025-04-28 13:09:38.419132	\N
138	Ryukishin Eiffel	\N	\N	\N	\N	12	131	23	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	2	\N	f	2025-04-28 13:12:05.766461	2025-04-28 13:12:18.723873	\N
139	Sequoia Rooftop Bar	\N	\N	\N	4T bar à cocktails vin 11-14€	12	132	6	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	3	\N	f	2025-04-28 13:16:29.00262	2025-04-28 13:17:51.385937	\N
142	Glou	\N	\N	\N	3T 20€ déj	12	135	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	2	\N	f	2025-04-28 13:22:04.463726	2025-04-28 13:22:26.679043	\N
143	Bistrot Instinct	\N	\N	\N	2T 25€ midi	12	136	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	2	\N	f	2025-04-28 13:23:07.78299	2025-04-28 13:23:53.07686	\N
144	Le Royal China	\N	\N	\N	3T 20€	12	58	14	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	1	\N	f	2025-04-28 13:24:35.844207	2025-04-28 13:25:21.176421	\N
147	Casa Di Peppe	\N	\N	\N	3T pizzas terrasse	12	139	22	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	2	\N	f	2025-04-28 13:30:39.77847	2025-04-28 13:31:26.055052	\N
149	Karavaki au Jardin de Luxembourg	\N	\N	\N	3T traiteur grec	12	141	20	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	1	\N	f	2025-04-28 13:34:56.581552	2025-04-28 13:35:46.347446	\N
150	La Taverne des Korrigans	\N	\N	\N	3T brasserie	12	142	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	2	\N	f	2025-04-28 13:36:05.636721	2025-04-28 13:37:25.80461	\N
151	Café le Reflet	\N	\N	\N	3T bar	12	143	6	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	1	\N	f	2025-04-28 13:38:10.409183	2025-04-28 13:38:53.635554	\N
141	Zakuro	\N	\N	\N	3T avec Christine et Pierre 13-18 midi	12	134	23	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	2	\N	f	2025-04-28 13:20:29.547877	2025-05-13 13:00:15.564146	\N
140	Waalo	\N	\N	\N	3T 15-19€	12	133	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	2	\N	f	2025-04-28 13:18:48.275841	2025-04-28 13:19:36.906836	\N
145	Grande Brasserie	\N	\N	\N	2T déj 24€	12	137	30	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	2	\N	f	2025-04-28 13:27:58.341833	2025-04-28 13:28:51.031571	\N
148	Han Lim	\N	\N	\N	3T 15€ cantine coréenne	12	140	24	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	1	\N	f	2025-04-28 13:32:34.668201	2025-04-28 13:33:48.046649	\N
152	OTTO by Eric Trochon	\N	\N	\N	3T 19-24€	12	144	23	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	2	\N	f	2025-04-28 13:39:40.971651	2025-04-28 13:40:31.104433	\N
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: bentobook
--

COPY public.schema_migrations (version) FROM stdin;
20241005155941
20241005155817
20241005155763
20241005155762
20241005155761
20241005155760
20241005155759
20241005155758
20241005155757
20241005154422
20241005154410
20241005154400
20241005154343
20241005154223
20241005153816
20241005153558
20241005153514
20241005153458
20241005153435
20241005151426
20241103172330
20241105103121
20241111083840
20241114110224
20241120092858
20241120092910
20241121201805
20241122082306
20241129140719
20250319140828
\.


--
-- Data for Name: shares; Type: TABLE DATA; Schema: public; Owner: bentobook
--

COPY public.shares (id, creator_id, recipient_id, shareable_type, shareable_id, permission, status, created_at, updated_at, reshareable) FROM stdin;
\.


--
-- Data for Name: spatial_ref_sys; Type: TABLE DATA; Schema: public; Owner: bentobook
--

COPY public.spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text) FROM stdin;
\.


--
-- Data for Name: taggings; Type: TABLE DATA; Schema: public; Owner: bentobook
--

COPY public.taggings (id, tag_id, taggable_type, taggable_id, tagger_type, tagger_id, context, created_at, tenant) FROM stdin;
1	1	Restaurant	1	\N	\N	tags	2024-11-16 22:10:07.983586	\N
2	2	Restaurant	2	\N	\N	tags	2024-11-22 16:28:52.296015	\N
3	2	Restaurant	3	\N	\N	tags	2024-11-22 16:34:04.839638	\N
4	2	Restaurant	4	\N	\N	tags	2024-11-22 16:36:37.737641	\N
5	3	Restaurant	4	\N	\N	tags	2024-11-22 16:42:29.116716	\N
6	4	Restaurant	5	\N	\N	tags	2024-11-22 16:49:41.532105	\N
7	4	Restaurant	10	\N	\N	tags	2024-11-22 17:06:14.290668	\N
8	4	Restaurant	11	\N	\N	tags	2024-11-22 17:08:23.029274	\N
9	5	Restaurant	20	\N	\N	tags	2024-12-02 15:51:33.278425	\N
10	6	Restaurant	22	\N	\N	tags	2024-12-12 15:41:01.399702	\N
11	4	Restaurant	27	\N	\N	tags	2025-01-19 10:38:17.942473	\N
12	7	Restaurant	28	\N	\N	tags	2025-01-19 10:42:49.217631	\N
13	8	Restaurant	29	\N	\N	tags	2025-01-19 10:45:44.3045	\N
14	2	Restaurant	33	\N	\N	tags	2025-01-19 10:57:58.295295	\N
15	2	Restaurant	34	\N	\N	tags	2025-01-19 11:00:59.631793	\N
16	9	Restaurant	36	\N	\N	tags	2025-01-19 11:09:17.786539	\N
17	10	Restaurant	37	\N	\N	tags	2025-01-19 11:14:28.465524	\N
18	11	Restaurant	39	\N	\N	tags	2025-01-19 11:20:36.262114	\N
19	12	Restaurant	44	\N	\N	tags	2025-02-10 17:47:44.04657	\N
20	5	Restaurant	45	\N	\N	tags	2025-02-10 17:48:22.130559	\N
21	13	Restaurant	46	\N	\N	tags	2025-02-10 17:49:00.100889	\N
22	5	Restaurant	46	\N	\N	tags	2025-02-10 17:49:00.109134	\N
23	7	Restaurant	72	\N	\N	tags	2025-04-27 09:18:04.483033	\N
24	7	Restaurant	73	\N	\N	tags	2025-04-27 09:21:08.125147	\N
25	10	Restaurant	81	\N	\N	tags	2025-04-27 09:50:53.699248	\N
26	10	Restaurant	82	\N	\N	tags	2025-04-27 09:57:40.363059	\N
27	11	Restaurant	83	\N	\N	tags	2025-04-27 10:00:53.941287	\N
28	10	Restaurant	86	\N	\N	tags	2025-04-27 16:20:53.737259	\N
29	11	Restaurant	88	\N	\N	tags	2025-04-27 16:26:37.972892	\N
30	11	Restaurant	89	\N	\N	tags	2025-04-27 16:29:05.544231	\N
31	7	Restaurant	91	\N	\N	tags	2025-04-27 16:36:32.517403	\N
32	11	Restaurant	96	\N	\N	tags	2025-04-27 16:55:44.705672	\N
33	4	Restaurant	98	\N	\N	tags	2025-04-27 17:12:22.932256	\N
34	11	Restaurant	101	\N	\N	tags	2025-04-27 17:25:44.712975	\N
35	11	Restaurant	113	\N	\N	tags	2025-04-27 18:27:57.888387	\N
36	11	Restaurant	114	\N	\N	tags	2025-04-28 09:05:12.150693	\N
37	11	Restaurant	116	\N	\N	tags	2025-04-28 09:24:18.355278	\N
38	11	Restaurant	117	\N	\N	tags	2025-04-28 09:29:12.171784	\N
39	2	Restaurant	133	\N	\N	tags	2025-04-28 12:59:02.696661	\N
40	2	Restaurant	136	\N	\N	tags	2025-04-28 13:07:25.995808	\N
41	11	Restaurant	143	\N	\N	tags	2025-04-28 13:23:23.897439	\N
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: bentobook
--

COPY public.tags (id, name, created_at, updated_at, taggings_count) FROM stdin;
1	wtg	2024-11-16 22:10:07.93633	2024-11-16 22:10:07.93633	1
3	cajun	2024-11-22 16:42:29.100975	2024-11-22 16:42:29.100975	1
6	⭐️	2024-12-12 15:41:01.357576	2024-12-12 15:41:01.357576	1
8	Polonais	2025-01-19 10:45:44.29288	2025-01-19 10:45:44.29288	1
9	Cambodgien	2025-01-19 11:09:17.776165	2025-01-19 11:09:17.776165	1
12	first	2025-02-10 17:47:44.010215	2025-02-10 17:47:44.010215	1
13	piemont	2025-02-10 17:49:00.093368	2025-02-10 17:49:00.093368	1
5	wine	2024-12-02 15:51:33.259757	2024-12-02 15:51:33.259757	3
10	Vietnamien	2025-01-19 11:14:28.455643	2025-01-19 11:14:28.455643	4
7	Oriental	2025-01-19 10:42:49.199269	2025-01-19 10:42:49.199269	4
4	tunisien	2024-11-22 16:49:41.508792	2024-11-22 16:49:41.508792	5
2	gastronomique	2024-11-22 16:28:52.271385	2024-11-22 16:28:52.271385	7
11	Bistrot	2025-01-19 11:20:36.249202	2025-01-19 11:20:36.249202	11
\.


--
-- Data for Name: user_sessions; Type: TABLE DATA; Schema: public; Owner: bentobook
--

COPY public.user_sessions (id, user_id, jti, client_name, last_used_at, ip_address, user_agent, active, created_at, updated_at, device_type, os_name, os_version, browser_name, browser_version, last_ip_address, location_country, suspicious) FROM stdin;
1	3	61da7069-829c-428f-a1b4-0299755c3dd3	Dart/3.6 (dart:io)	2025-01-03 20:17:34.902323	172.71.123.40	Dart/3.6 (dart:io)	f	2025-01-03 20:16:57.755608	2025-01-03 20:17:34.959167	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
13	3	3d0abb6d-07d8-4cb3-bda1-8991ba6b91fd	PostmanRuntime/7.43.0	2025-01-22 17:34:40.643802	172.71.126.202	PostmanRuntime/7.43.0	t	2025-01-22 17:11:00.758362	2025-01-22 17:34:40.644861	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
12	3	bf09fbaa-2332-4f66-a340-8958dd004fb3	bentobook/1 CFNetwork/1568.300.101 Darwin/24.2.0	2025-01-23 10:57:50.879287	172.69.222.214	bentobook/1 CFNetwork/1568.300.101 Darwin/24.2.0	t	2025-01-22 16:56:29.818027	2025-01-23 10:57:50.883658	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
2	3	bf4c7ca3-a599-4668-bc8a-a50221c2dc8d	Dart/3.6 (dart:io)	2025-01-03 20:20:37.791295	172.71.123.160	Dart/3.6 (dart:io)	f	2025-01-03 20:17:59.155135	2025-01-03 20:20:37.808648	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
3	3	4cf0a6aa-1ed2-4023-bb97-81de33ef1810	Dart/3.6 (dart:io)	2025-01-03 20:20:59.833318	172.71.134.208	Dart/3.6 (dart:io)	t	2025-01-03 20:20:59.83802	2025-01-03 20:20:59.83802	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
14	3	abd3895f-10c0-41c9-9d74-19deed81d34a	bentobook/1 CFNetwork/1568.300.101 Darwin/24.2.0	2025-01-23 11:14:37.867202	172.71.123.161	bentobook/1 CFNetwork/1568.300.101 Darwin/24.2.0	t	2025-01-23 11:14:37.876713	2025-01-23 11:14:37.876713	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
15	3	d14ab8a8-d8ed-454d-8329-306aa7e124c4	bentobook/1 CFNetwork/1568.300.101 Darwin/24.2.0	2025-01-23 11:15:13.593469	172.71.134.59	bentobook/1 CFNetwork/1568.300.101 Darwin/24.2.0	t	2025-01-23 11:15:13.597636	2025-01-23 11:15:13.597636	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
16	3	0abd47b1-d9f9-4b1f-9d6e-6675d78fce28	bentobook/1 CFNetwork/1568.300.101 Darwin/24.2.0	2025-01-23 11:16:04.843366	172.71.123.155	bentobook/1 CFNetwork/1568.300.101 Darwin/24.2.0	t	2025-01-23 11:16:04.845926	2025-01-23 11:16:04.845926	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
17	3	91b860db-03da-4048-9878-71e4e47df3e1	bentobook/1 CFNetwork/1568.300.101 Darwin/24.2.0	2025-01-23 11:16:34.975093	172.69.223.59	bentobook/1 CFNetwork/1568.300.101 Darwin/24.2.0	t	2025-01-23 11:16:34.986049	2025-01-23 11:16:34.986049	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
18	3	ba319e78-4e38-4a9f-b559-8ba4ce7e2aa2	bentobook/1 CFNetwork/1568.300.101 Darwin/24.2.0	2025-01-23 12:10:51.942803	172.71.130.19	bentobook/1 CFNetwork/1568.300.101 Darwin/24.2.0	t	2025-01-23 12:10:51.947428	2025-01-23 12:10:51.947428	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
4	3	4a912694-5c63-4d87-aad2-c1da907d800d	Dart/3.6 (dart:io)	2025-01-03 20:35:42.848744	172.71.126.76	Dart/3.6 (dart:io)	t	2025-01-03 20:34:54.627329	2025-01-03 20:35:42.851607	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
19	3	db6766ab-d296-4276-993d-20cccdf2d3f6	bentobook/1 CFNetwork/1568.300.101 Darwin/24.2.0	2025-01-23 12:16:21.665017	172.71.123.156	bentobook/1 CFNetwork/1568.300.101 Darwin/24.2.0	t	2025-01-23 12:16:21.667961	2025-01-23 12:16:21.667961	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
20	3	f7e7335d-c4ee-4820-8bae-55306ce6eaad	bentobook/1 CFNetwork/1568.300.101 Darwin/24.2.0	2025-01-23 12:23:21.491325	172.71.123.152	bentobook/1 CFNetwork/1568.300.101 Darwin/24.2.0	t	2025-01-23 12:23:21.495542	2025-01-23 12:23:21.495542	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
5	3	4c25fcf9-6439-4d51-b655-09204e61bb7c	Dart/3.6 (dart:io)	2025-01-08 16:47:12.264055	172.71.134.59	Dart/3.6 (dart:io)	t	2025-01-08 16:46:51.585447	2025-01-08 16:47:12.266229	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
6	3	dc1676ea-ec05-4425-8cf7-1a351f8a1d1f	Dart/3.6 (dart:io)	2025-01-08 19:50:01.092491	172.71.123.181	Dart/3.6 (dart:io)	t	2025-01-08 19:50:01.102057	2025-01-08 19:50:01.102057	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
22	3	b6cb1441-6f76-4467-baad-a1db92352a00	bentobook/2 CFNetwork/1568.300.101 Darwin/24.2.0	2025-01-23 19:33:06.047282	172.71.122.74	bentobook/2 CFNetwork/1568.300.101 Darwin/24.2.0	t	2025-01-23 13:09:08.958642	2025-01-23 19:33:06.049304	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
7	3	183a681b-0e64-4e8e-9d1b-1319eba65a87	Dart/3.6 (dart:io)	2025-01-16 16:55:04.664504	141.101.68.109	Dart/3.6 (dart:io)	f	2025-01-16 16:54:56.966596	2025-01-16 16:55:04.674687	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
24	3	901a35ff-84ec-4a8f-860f-cda2143afb1c	bentobook/1 CFNetwork/1568.300.101 Darwin/24.2.0	2025-01-23 23:28:47.18313	172.71.134.47	bentobook/1 CFNetwork/1568.300.101 Darwin/24.2.0	t	2025-01-23 17:34:19.384313	2025-01-23 23:28:47.190332	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
28	3	f9a69596-45a6-499b-a841-ba9231b4d061	bentobook/4 CFNetwork/1568.300.101 Darwin/24.2.0	2025-01-26 17:46:58.934473	172.71.126.161	bentobook/4 CFNetwork/1568.300.101 Darwin/24.2.0	t	2025-01-25 19:34:53.101518	2025-01-26 17:46:58.937209	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
9	3	eb84354d-0a17-4432-b714-ae208a2a1ab3	Dart/3.6 (dart:io)	2025-01-16 17:05:03.93606	172.71.130.133	Dart/3.6 (dart:io)	t	2025-01-16 17:05:03.822391	2025-01-16 17:05:03.937335	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
25	3	3f8ea58f-608f-439e-a4e2-d11233e36c52	bentobook/1 CFNetwork/1568.300.101 Darwin/24.2.0	2025-01-25 10:08:19.910497	141.101.97.104	bentobook/1 CFNetwork/1568.300.101 Darwin/24.2.0	t	2025-01-24 10:44:25.222558	2025-01-25 10:08:19.911654	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
30	3	1ce4c210-b1d7-49b3-9902-0e13ad77c2b5	bentobook/1 CFNetwork/1568.300.101 Darwin/24.2.0	2025-01-27 11:01:04.717672	172.71.123.149	bentobook/1 CFNetwork/1568.300.101 Darwin/24.2.0	t	2025-01-26 16:45:20.725662	2025-01-27 11:01:04.721633	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
29	3	5079dfdb-5753-442d-b73e-58ec38586ff2	bentobook/1 CFNetwork/1568.300.101 Darwin/24.2.0	2025-01-27 14:48:58.818879	141.101.68.93	bentobook/1 CFNetwork/1568.300.101 Darwin/24.2.0	t	2025-01-26 16:39:06.984324	2025-01-27 14:48:58.820994	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
8	3	da7dc0bf-2317-4621-8703-db171de318d2	Dart/3.6 (dart:io)	2025-01-16 21:12:38.1981	172.69.223.59	Dart/3.6 (dart:io)	t	2025-01-16 17:04:10.836942	2025-01-16 21:12:38.199764	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
26	3	fb861dcd-b934-4291-a4ce-ef17aa06679d	bentobook/3 CFNetwork/1568.300.101 Darwin/24.2.0	2025-01-24 17:43:55.597053	172.71.123.162	bentobook/3 CFNetwork/1568.300.101 Darwin/24.2.0	t	2025-01-24 17:43:24.257702	2025-01-24 17:43:55.60023	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
10	3	e5cd7852-2940-4a7f-982c-b000d0fc620b	Dart/3.6 (dart:io)	2025-01-18 20:53:13.73489	141.101.97.98	Dart/3.6 (dart:io)	t	2025-01-18 20:53:13.478795	2025-01-18 20:53:13.737496	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
11	3	16b5ded3-bb68-4eba-8bdd-15fb0111b3f0	bentobook/1 CFNetwork/1568.300.101 Darwin/24.2.0	2025-01-19 14:55:05.261212	172.71.126.76	bentobook/1 CFNetwork/1568.300.101 Darwin/24.2.0	t	2025-01-19 14:55:05.269044	2025-01-19 14:55:05.269044	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
27	3	9cdbde57-e88c-4501-af66-bf730e540df3	bentobook/1 CFNetwork/1568.300.101 Darwin/24.2.0	2025-01-25 19:12:20.696882	141.101.96.37	bentobook/1 CFNetwork/1568.300.101 Darwin/24.2.0	t	2025-01-25 10:45:49.184889	2025-01-25 19:12:20.700668	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
21	3	b41c13f6-c7ec-49bc-aba1-18843b38cc91	bentobook/1 CFNetwork/1568.300.101 Darwin/24.2.0	2025-01-23 17:10:41.40476	172.71.123.83	bentobook/1 CFNetwork/1568.300.101 Darwin/24.2.0	t	2025-01-23 12:31:55.739819	2025-01-23 17:10:41.406641	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
23	3	61c73dda-1cc5-4792-bfdd-3a08620a6463	PostmanRuntime/7.43.0	2025-01-23 17:25:38.143747	172.71.123.151	PostmanRuntime/7.43.0	t	2025-01-23 15:15:30.756772	2025-01-23 17:25:38.145509	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
35	3	eff0cffc-29b8-4716-9a54-e5bb34bb6a86	bentobook/5 CFNetwork/1568.300.101 Darwin/24.2.0	2025-02-02 08:14:40.901607	141.101.96.60	bentobook/5 CFNetwork/1568.300.101 Darwin/24.2.0	t	2025-02-02 08:14:37.798104	2025-02-02 08:14:40.907716	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
55	12	9fb6ebbc-766d-4e4b-832d-2a7c44cd0dcc	bentobook/5 CFNetwork/3826.400.120 Darwin/24.3.0	2025-03-24 10:23:12.531352	172.69.223.60	bentobook/5 CFNetwork/3826.400.120 Darwin/24.3.0	t	2025-03-24 10:22:58.574272	2025-03-24 10:23:12.536166	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
40	12	156622bd-1310-4d2d-b9a9-4c1ba0517040	bentobook/5 CFNetwork/1568.300.101 Darwin/24.2.0	2025-02-11 19:23:52.897158	172.71.123.151	bentobook/5 CFNetwork/1568.300.101 Darwin/24.2.0	t	2025-02-11 19:21:09.0466	2025-02-11 19:23:52.898843	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
38	3	e3f911d3-503c-41dd-afdb-3c9ec2c4b38d	bentobook/5 CFNetwork/3826.400.120 Darwin/24.3.0	2025-02-12 12:17:05.369409	172.71.126.70	bentobook/5 CFNetwork/3826.400.120 Darwin/24.3.0	t	2025-02-11 13:05:43.591814	2025-02-12 12:17:05.371145	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
36	3	5eb9a414-bad0-42b8-9b3e-a85b6be83c2e	bentobook/5 CFNetwork/1568.300.101 Darwin/24.2.0	2025-02-05 20:33:43.55626	172.71.131.4	bentobook/5 CFNetwork/1568.300.101 Darwin/24.2.0	t	2025-02-05 20:32:04.230021	2025-02-05 20:33:43.557458	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
43	12	f53f3368-089d-4adb-8c67-2447eb30c571	bentobook/5 CFNetwork/1568.300.101 Darwin/24.2.0	2025-02-17 07:57:46.409956	172.71.131.162	bentobook/5 CFNetwork/1568.300.101 Darwin/24.2.0	t	2025-02-17 07:48:53.082294	2025-02-17 07:57:46.413985	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
31	3	95608208-3584-4625-a393-20a7d2b0a796	bentobook/4 CFNetwork/1568.300.101 Darwin/24.2.0	2025-01-27 18:05:31.659025	172.71.131.159	bentobook/4 CFNetwork/1568.300.101 Darwin/24.2.0	t	2025-01-27 18:00:54.756111	2025-01-27 18:05:31.660688	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
44	3	3da90376-389d-4241-8455-7d7c32a33d6d	bentobook/6 CFNetwork/3826.400.120 Darwin/24.3.0	2025-02-18 14:49:29.365178	141.101.96.37	bentobook/6 CFNetwork/3826.400.120 Darwin/24.3.0	t	2025-02-18 09:17:38.547249	2025-02-18 14:49:29.372322	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
41	3	7f2fab0e-eea0-4c3f-afac-7cdb0761196c	bentobook/5 CFNetwork/3826.400.120 Darwin/24.3.0	2025-02-12 13:33:24.5938	172.71.127.127	bentobook/5 CFNetwork/3826.400.120 Darwin/24.3.0	t	2025-02-12 13:13:06.895438	2025-02-12 13:33:24.595528	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
56	3	818f424b-d134-4427-946c-519e0ce0f764	bentobook/6 CFNetwork/3826.400.120 Darwin/24.3.0	2025-03-28 09:26:13.397535	172.68.151.167	bentobook/6 CFNetwork/3826.400.120 Darwin/24.3.0	t	2025-03-28 09:05:14.293807	2025-03-28 09:26:13.400617	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
45	3	087ff8ed-6e1a-42d2-9858-5fb0a277a090	bentobook/6 CFNetwork/3826.400.120 Darwin/24.3.0	2025-02-19 11:51:46.001257	141.101.69.34	bentobook/6 CFNetwork/3826.400.120 Darwin/24.3.0	t	2025-02-19 11:51:40.578319	2025-02-19 11:51:46.009544	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
37	95	cdc72c4e-de64-46e8-a23e-27b4ed191f3b	bentobook/5 CFNetwork/3826.400.120 Darwin/24.3.0	2025-02-11 13:05:21.267279	172.71.118.213	bentobook/5 CFNetwork/3826.400.120 Darwin/24.3.0	t	2025-02-10 18:10:55.258282	2025-02-11 13:05:21.270866	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
32	3	0f8d52ad-cef0-48fa-b1df-31a5599ed848	bentobook/5 CFNetwork/1568.300.101 Darwin/24.2.0	2025-01-29 09:52:15.08053	172.71.134.220	bentobook/5 CFNetwork/1568.300.101 Darwin/24.2.0	t	2025-01-28 22:37:59.265603	2025-01-29 09:52:15.082044	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
57	3	27296e1c-83b9-4c56-b2a9-5e5aeb4bbefb	bentobook/6 CFNetwork/3826.400.120 Darwin/24.3.0	2025-03-31 22:11:01.87734	172.71.232.53	bentobook/6 CFNetwork/3826.400.120 Darwin/24.3.0	t	2025-03-31 22:09:59.430201	2025-03-31 22:11:01.87885	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
46	3	1ccefa02-3d45-47dd-bab0-0d8cf80f5399	bentobook/6 CFNetwork/3826.400.120 Darwin/24.3.0	2025-02-21 09:21:46.520396	172.69.223.154	bentobook/6 CFNetwork/3826.400.120 Darwin/24.3.0	t	2025-02-20 18:09:44.685511	2025-02-21 09:21:46.526699	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
33	3	4786aec7-a811-4a65-9070-4f3152c52506	bentobook/1 CFNetwork/1568.300.101 Darwin/24.2.0	2025-01-30 18:37:33.776159	172.71.126.70	bentobook/1 CFNetwork/1568.300.101 Darwin/24.2.0	t	2025-01-30 18:16:07.686144	2025-01-30 18:37:33.77761	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
34	3	0e53b631-b44a-4322-8583-7bffddc75092	bentobook/5 CFNetwork/1568.300.101 Darwin/24.2.0	2025-01-30 22:28:40.245502	172.71.126.160	bentobook/5 CFNetwork/1568.300.101 Darwin/24.2.0	t	2025-01-30 22:28:27.71975	2025-01-30 22:28:40.246888	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
52	3	d78f43ea-9e0e-41fa-ab4d-f56771b138f0	bentobook/6 CFNetwork/3826.400.120 Darwin/24.3.0	2025-03-16 21:55:41.408543	141.101.96.38	bentobook/6 CFNetwork/3826.400.120 Darwin/24.3.0	t	2025-03-16 14:29:02.955137	2025-03-16 21:55:41.415216	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
47	12	7a4f5431-4189-4fc8-9b7a-51a3136e9147	bentobook/5 CFNetwork/1568.300.101 Darwin/24.2.0	2025-02-21 15:54:47.196041	141.101.68.92	bentobook/5 CFNetwork/1568.300.101 Darwin/24.2.0	t	2025-02-21 15:48:54.97918	2025-02-21 15:54:47.206367	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
39	95	4cc9b21f-7a29-41d6-aa43-53841b8b9c17	bentobook/5 CFNetwork/3826.400.120 Darwin/24.3.0	2025-02-11 17:46:01.767536	172.71.155.62	bentobook/5 CFNetwork/3826.400.120 Darwin/24.3.0	t	2025-02-11 17:45:57.764638	2025-02-11 17:46:01.768991	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
48	3	491bd1ae-c8cf-4e1f-8433-2f76b3273d40	bentobook/6 CFNetwork/3826.400.120 Darwin/24.3.0	2025-02-22 11:53:21.776077	172.69.222.74	bentobook/6 CFNetwork/3826.400.120 Darwin/24.3.0	t	2025-02-22 11:53:20.331581	2025-02-22 11:53:21.79188	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
49	3	f8aaaa99-faba-42ec-a5f9-817e180bd376	bentobook/6 CFNetwork/3826.400.120 Darwin/24.3.0	2025-02-25 13:27:23.255244	172.71.131.4	bentobook/6 CFNetwork/3826.400.120 Darwin/24.3.0	t	2025-02-24 19:32:45.265339	2025-02-25 13:27:23.257993	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
50	12	58986207-d0c7-4f3b-9978-1763f486fe1a	bentobook/5 CFNetwork/1568.300.101 Darwin/24.2.0	2025-02-26 13:50:13.738745	172.69.222.220	bentobook/5 CFNetwork/1568.300.101 Darwin/24.2.0	t	2025-02-26 13:50:13.752662	2025-02-26 13:50:13.752662	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
42	3	7d1d4298-cba4-4c38-96c2-b99fce15edd2	bentobook/6 CFNetwork/3826.400.120 Darwin/24.3.0	2025-02-14 07:39:49.313798	172.71.130.232	bentobook/6 CFNetwork/3826.400.120 Darwin/24.3.0	t	2025-02-13 17:37:48.344858	2025-02-14 07:39:49.315165	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
53	3	6578c3b9-2d99-43e6-80fa-6d772ec3598f	bentobook/6 CFNetwork/3826.400.120 Darwin/24.3.0	2025-03-21 08:34:06.496177	172.71.122.63	bentobook/6 CFNetwork/3826.400.120 Darwin/24.3.0	t	2025-03-20 17:54:03.176149	2025-03-21 08:34:06.498411	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
51	3	2e4e4239-9690-4420-8e07-a5cae61dee78	bentobook/6 CFNetwork/3826.400.120 Darwin/24.3.0	2025-03-04 18:21:06.091529	172.71.123.154	bentobook/6 CFNetwork/3826.400.120 Darwin/24.3.0	t	2025-03-04 18:20:44.41084	2025-03-04 18:21:06.094843	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
54	3	5726d8cc-90e9-4bcf-8e13-e154481e5895	bentobook/6 CFNetwork/3826.400.120 Darwin/24.3.0	2025-03-22 23:10:05.420993	141.101.97.105	bentobook/6 CFNetwork/3826.400.120 Darwin/24.3.0	t	2025-03-22 23:09:49.403215	2025-03-22 23:10:05.422488	desktop	Unknown	0	Unknown Browser	0	\N	\N	f
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: bentobook
--

COPY public.users (id, email, encrypted_password, reset_password_token, reset_password_sent_at, remember_created_at, sign_in_count, current_sign_in_at, last_sign_in_at, current_sign_in_ip, last_sign_in_ip, confirmation_token, confirmed_at, confirmation_sent_at, unconfirmed_email, failed_attempts, unlock_token, locked_at, created_at, updated_at) FROM stdin;
22	maddipaimcek@yahoo.com	$2a$12$3pgCHdT61hbC94BxHKDLNepV/igfkoL6bp0tEV2Z7zadq6aooF4x6	\N	\N	\N	0	\N	\N	\N	\N	MPRVUgoMDosHj6Ny1TKA	\N	2024-11-29 02:08:49.948429	\N	0	\N	\N	2024-11-29 02:08:49.948063	2024-11-29 02:08:49.948063
23	peronelandrews1984@gmail.com	$2a$12$iCs7FjUduufzxfhxzEaNKObbKqbJnNwpsXycbEsjVTN176rO8Bls6	\N	\N	\N	0	\N	\N	\N	\N	iyhnBV2yVyjana7qGQks	\N	2024-11-29 21:18:45.935577	\N	0	\N	\N	2024-11-29 21:18:45.935425	2024-11-29 21:18:45.935425
4	farleiex45@gmail.com	$2a$12$A.sLFh/QMObCj0osV0CP4e62mvI2k45vmzJijk6KZzmCuAE31NT06	\N	\N	\N	0	\N	\N	\N	\N	hxigYMjA_GQ7RuvZQSn3	\N	2024-11-08 16:27:30.499813	\N	0	\N	\N	2024-11-08 16:27:30.499298	2024-11-08 16:27:30.499298
6	liuigmvrotpguge@yahoo.com	$2a$12$iRGEt4ORkQPOEfiTDogFHOvW/RUS2bG0LYBsce6EDJZnJBM79ft1a	\N	\N	\N	0	\N	\N	\N	\N	JANjm53uDyZfuBK96yZP	\N	2024-11-10 06:04:11.664374	\N	0	\N	\N	2024-11-10 06:04:11.664161	2024-11-10 06:04:11.664161
30	kbotrvgtwgajtncpu@yahoo.com	$2a$12$KA07sHsvF5CdItM97RwV6.eZEoq6TUUG0bYco2d/zwKhz98xbXAAq	\N	\N	\N	0	\N	\N	\N	\N	py9a3ifxaeLnyxEQ5p8w	\N	2024-12-05 19:02:47.567027	\N	0	\N	\N	2024-12-05 19:02:47.566784	2024-12-05 19:02:47.566784
5	stormmb1984@gmail.com	$2a$12$70Tjf96ysAbQtp7QEXUcS..2M.CFWXKlf/1OjTt.0HjGfOhw3uMsW	0a173cc022b55410a98fed04a1c9b0883777e6e7899d92c79b5b9d9b5973a687	2024-11-11 00:08:00.856472	\N	0	\N	\N	\N	\N	yAQTaD3PGZyYJdabKgAe	\N	2024-11-09 12:36:34.614042	\N	1	\N	\N	2024-11-09 12:36:34.613753	2024-11-11 00:08:00.857065
7	i4ia9huysaanhxk@yahoo.com	$2a$12$YuE0dQRT/bGxIiMLdfLVGuN2DkwexO2Gu8BPskcwaPP0igHZLa5Vq	\N	\N	\N	0	\N	\N	\N	\N	EWkZ159r9-t9tmxp6sBs	\N	2024-11-11 18:42:19.274801	\N	0	\N	\N	2024-11-11 18:42:19.274206	2024-11-11 18:42:19.274206
8	zsseiizjisuj@dont-reply.me	$2a$12$TmYE5vkD8nnn6w4XFsM5a.pSaN7XDGZHCJgz7qUapJAQB8IERAtFK	\N	\N	\N	0	\N	\N	\N	\N	KK_epBT9AQiKvPPP2h12	\N	2024-11-12 06:05:10.625735	\N	0	\N	\N	2024-11-12 06:05:10.625543	2024-11-12 06:05:10.625543
9	mylavacardenasuv181@gmail.com	$2a$12$w4iPjSB0bIk.xM.vSnvgTuieHiazlnWqLyqD0ZyrGXHjDOKZDOvh2	\N	\N	\N	0	\N	\N	\N	\N	HXBMba22jhySdZAksAny	\N	2024-11-12 13:00:24.442155	\N	0	\N	\N	2024-11-12 13:00:24.441614	2024-11-12 13:00:24.441614
10	vsybcvurcnmkg@yahoo.com	$2a$12$EXR92ABn5fMGgpCf.uE.6OVYhl4hPUHnyiuT5IK8lFiCen6CejOn2	\N	\N	\N	0	\N	\N	\N	\N	62bL4f_wfYzdXLAwmTvQ	\N	2024-11-14 09:29:07.145227	\N	0	\N	\N	2024-11-14 09:29:07.145049	2024-11-14 09:29:07.145049
11	kellhumphreyd3557@gmail.com	$2a$12$S5DumdP/X7zCBS6O6p9oSeyT7XYbAgkrIp6L36wpq2WnX2lMVPWTO	\N	\N	\N	0	\N	\N	\N	\N	rt24LuZf45V8PfHsM-Qp	\N	2024-11-15 06:00:59.973238	\N	0	\N	\N	2024-11-15 06:00:59.97301	2024-11-15 06:00:59.97301
31	kaspirekkmlet@yahoo.com	$2a$12$Dn6YTrIN9ToMm.Gjmx3Hd.6rIMIBTcvxFKhqIeY/ys3E85h073ls6	\N	\N	\N	0	\N	\N	\N	\N	vsJdhmap5cqTFv8CVuUn	\N	2024-12-06 13:56:27.516557	\N	0	\N	\N	2024-12-06 13:56:27.516388	2024-12-06 13:56:27.516388
13	adneidunn@gmail.com	$2a$12$H36M6D4CPM1NwGWf7g6abeuXjBPdqeVkWGpt91tTNAwGc/Gb6yinm	\N	\N	\N	0	\N	\N	\N	\N	z-yBiFbmV4XVQ2LNsHNX	\N	2024-11-17 03:08:37.321893	\N	0	\N	\N	2024-11-17 03:08:37.321647	2024-11-17 03:08:37.321647
14	nuegwcpngsg6myxx@yahoo.com	$2a$12$cLLLE8JAiMuroellGHrUpuZKtxY6I/LNPsuS19zs323kCrgWuHECK	\N	\N	\N	0	\N	\N	\N	\N	cYTwEjUnUABfirXtjpYQ	\N	2024-11-18 07:17:51.501203	\N	0	\N	\N	2024-11-18 07:17:51.500445	2024-11-18 07:17:51.500445
15	zambarakjien@yahoo.com	$2a$12$o7uK3f0Z51eUNsaZbdatIu9FtdJbZsSmVhtfjwSA7DbIEdxIpdapG	\N	\N	\N	0	\N	\N	\N	\N	PhQ-nnNV-xDD85U6qo-s	\N	2024-11-20 21:07:33.459057	\N	0	\N	\N	2024-11-20 21:07:33.45821	2024-11-20 21:07:33.45821
16	murrelliory@yahoo.com	$2a$12$z2UjP5y4Lp.VfNxctwLWxeNqpa5TOFu.LkbockqZkCgzIAP4RrILe	\N	\N	\N	0	\N	\N	\N	\N	uDcni1_zH9rtNFsVC-F_	\N	2024-11-23 15:48:29.222163	\N	0	\N	\N	2024-11-23 15:48:29.221815	2024-11-23 15:48:29.221815
17	steelegeib1985@gmail.com	$2a$12$elB/gwajEH4n4D514X4nAuyGKL2XvwEMzk9.VX/LrwH7fB9wEMiem	\N	\N	\N	0	\N	\N	\N	\N	WJacWbQz32FNWsMRNsvD	\N	2024-11-25 09:12:41.700981	\N	0	\N	\N	2024-11-25 09:12:41.700845	2024-11-25 09:12:41.700845
18	eeislsiremuj@dont-reply.me	$2a$12$VkZh/xvjVsTD5By1q1Sv/ukU7fu19wTX0XA6ZBQ2Cxnhl/14rO11q	\N	\N	\N	0	\N	\N	\N	\N	JY7Ciav3VrKpySEN-S43	\N	2024-11-25 10:22:39.688969	\N	0	\N	\N	2024-11-25 10:22:39.688475	2024-11-25 10:22:39.688475
19	grovermathews854@gmail.com	$2a$12$i0sHFFrzBwa3JGzPNdzuvuQwBIvM9aSKR8Z5atosUiErJby3FPsq.	\N	\N	\N	0	\N	\N	\N	\N	r48RpAyyTrbB3u93q-jb	\N	2024-11-26 08:31:02.197211	\N	0	\N	\N	2024-11-26 08:31:02.197093	2024-11-26 08:31:02.197093
20	ruizedrianvz@gmail.com	$2a$12$XaHssp942Z7z7vYE5tIF/erGmQK7vVIl9nxVXN0/LVdge/T5jC3.W	\N	\N	\N	0	\N	\N	\N	\N	XdhiZUxs67JmPp5sZHzC	\N	2024-11-27 06:53:35.871981	\N	0	\N	\N	2024-11-27 06:53:35.871724	2024-11-27 06:53:35.871724
21	gvelazquezzk8127@gmail.com	$2a$12$RRjCwobFUqNCjTfkZ2r8DOfAQNoC6KB.z0PCo.GEzOccI39OqVJ6q	\N	\N	\N	0	\N	\N	\N	\N	H9Ux-G1iVV62nFsLzfNM	\N	2024-11-28 05:27:30.969543	\N	0	\N	\N	2024-11-28 05:27:30.969434	2024-11-28 05:27:30.969434
24	kipkesg@yahoo.com	$2a$12$bZUGSiyjIYgtjuTZAs3VOezKJqwceCUFH1YyBXsttTTPJGA9ggnXq	\N	\N	\N	0	\N	\N	\N	\N	WZW7h-PGx9uzfc7LFCh5	\N	2024-12-01 09:48:09.521369	\N	0	\N	\N	2024-12-01 09:48:09.521206	2024-12-01 09:48:09.521206
25	dyjdb48fgfacrsq@yahoo.com	$2a$12$tPoaLYvz2Etd8oEDmW8gneIifTNKSVIocIkaiKlqUfyXrZr6yZ/UC	\N	\N	\N	0	\N	\N	\N	\N	RyEC2hYwHXh7_tx9AD13	\N	2024-12-02 03:06:15.052471	\N	0	\N	\N	2024-12-02 03:06:15.05236	2024-12-02 03:06:15.05236
76	aygossameriu28vergeae@gmail.com	$2a$12$svsx9Iew1/a.ndZAJFV1tOrZC3gERmsoiwF.TYqW.Q2R4WurVbdcO	\N	\N	\N	0	\N	\N	\N	\N	5WMDXwreGyUhVQuBMCnG	\N	2025-01-17 23:48:56.76678	\N	0	\N	\N	2025-01-17 23:48:56.766713	2025-01-17 23:48:56.766713
27	mymngbiyuarikvu@yahoo.com	$2a$12$SEvVmCzjOTxNvNzPU4SweOoYTxps1GBiOPDo9lDdeWZbGGg2l/rv6	\N	\N	\N	0	\N	\N	\N	\N	vpCkQJeAy3xjHy7zysJR	\N	2024-12-03 14:05:26.572901	\N	0	\N	\N	2024-12-03 14:05:26.572458	2024-12-03 14:05:26.572458
28	graneroeagr@yahoo.com	$2a$12$mHa2ioWgqX.9nRxY3UYW0.QeWyEbK9LjtUJyNSSDcYAXiFSW5adF.	\N	\N	\N	0	\N	\N	\N	\N	pP9fgSj-HF4ng8sUbRhv	\N	2024-12-04 06:58:35.126342	\N	0	\N	\N	2024-12-04 06:58:35.126169	2024-12-04 06:58:35.126169
29	hkenrikk@gmail.com	$2a$12$JVJtgh.mVB.GMsN/vF/60uVJ9T4xVGO7./Re56/DBvQHSOvV45xlK	\N	\N	\N	0	\N	\N	\N	\N	5L1hwhxsABzMaUWjZPpe	\N	2024-12-05 00:08:51.622725	\N	0	\N	\N	2024-12-05 00:08:51.622619	2024-12-05 00:08:51.622619
26	lkjvqissaxocexof@yahoo.com	$2a$12$xk.C2IRT0.NF9UxiQbzfAuOjwmNT4ZCyZ6WLkD71xPlL4XVopSvWq	\N	\N	\N	0	\N	\N	\N	\N	graMCxsPNTBs9X4SmVAs	\N	2024-12-02 20:35:26.198243	\N	0	\N	\N	2024-12-02 20:35:26.198086	2024-12-02 20:35:26.198086
32	calasreschuk@yahoo.com	$2a$12$jSL6PI99L3ePRjeDsBwc7.3ku9sU13E0sK5HsPyoT7oL71uYx418O	\N	\N	\N	0	\N	\N	\N	\N	nPTEYt9Xyo4xFK-R1AVx	\N	2024-12-07 09:10:27.822141	\N	0	\N	\N	2024-12-07 09:10:27.821881	2024-12-07 09:10:27.821881
33	chlopkpapcu@yahoo.com	$2a$12$XY9YBb7nkibV4DVgKJFOxui0aJaWCmxGlT03eByI.bouoBT0CCcYy	\N	\N	\N	0	\N	\N	\N	\N	qnWfwBtoNzZfu71MFErX	\N	2024-12-08 02:56:34.961557	\N	0	\N	\N	2024-12-08 02:56:34.96106	2024-12-08 02:56:34.96106
34	brandayaalibp27@gmail.com	$2a$12$DF5DLiyJbserfY5jphiZQOpswdIBa/bwn7jcWJxm1.6qGVZE/su7u	\N	\N	\N	0	\N	\N	\N	\N	KwC9ZEMi9CHRdFWcWiKN	\N	2024-12-08 20:00:03.407806	\N	0	\N	\N	2024-12-08 20:00:03.407542	2024-12-08 20:00:03.407542
35	brynsmallv9@gmail.com	$2a$12$aDE1EteALGv5lhq2mf7t.uiFX/qHYtr84iK6UaAQm4AXtt.OifvhG	\N	\N	\N	0	\N	\N	\N	\N	EzuDc4pxaySm--pQQJGP	\N	2024-12-09 20:38:06.955275	\N	0	\N	\N	2024-12-09 20:38:06.955073	2024-12-09 20:38:06.955073
77	glossersoroogh@yahoo.com	$2a$12$QDJcEDsDieo/9ijry0DNI.aCrOKDa/bWtAWMlEUjYojXBXIgijidS	\N	\N	\N	0	\N	\N	\N	\N	Vxy9zxrdRrZ4uUvdU6pY	\N	2025-01-18 21:46:13.16054	\N	0	\N	\N	2025-01-18 21:46:13.160365	2025-01-18 21:46:13.160365
36	singletonkareikt26@gmail.com	$2a$12$x/PlbQ5FOPEuJHGwjiBtz.iAfTua2HzRAO7U./42bUdBbXf8/GXpi	\N	\N	\N	0	\N	\N	\N	\N	DSH1dahxTdbCcvi8x_C8	\N	2024-12-10 19:39:26.271156	\N	0	\N	\N	2024-12-10 19:39:26.271043	2024-12-10 19:39:26.271043
62	qimedixihij052@gmail.com	$2a$12$bJLfcrCOnkXhgGmu1WHepeZlgNBe/iGYZag7dpz4FQI0bpZ6U4AFi	\N	\N	\N	0	\N	\N	\N	\N	SincjNfy3wDxQSh2JZsx	\N	2025-01-03 23:51:25.983167	\N	0	\N	\N	2025-01-03 23:51:25.982849	2025-01-03 23:51:25.982849
37	siedentoppgothal@yahoo.com	$2a$12$HRl6Jh8bCzZUcjQqt3WAjOpAWdKjwpH0JXiVCHiVjUQaD953xZRiq	\N	\N	\N	0	\N	\N	\N	\N	pgrRJDDPMzW7KsJ9kxZA	\N	2024-12-12 00:43:52.55748	\N	0	\N	\N	2024-12-12 00:43:52.556809	2024-12-12 00:43:52.556809
38	lrkaqhephejtsxn@yahoo.com	$2a$12$I4DuNdTG59Z49oVYb.tra.NOrjBRt60pg1Cd9GKDDbw.nt6qyHSVC	\N	\N	\N	0	\N	\N	\N	\N	XUuUdPAPdQzgXVATkVNk	\N	2024-12-13 03:37:37.798178	\N	0	\N	\N	2024-12-13 03:37:37.796124	2024-12-13 03:37:37.796124
63	xahejudi632@gmail.com	$2a$12$jBsRSqK2c1p.QcJxkjAUOOmCrT4SMIx9VTbj3tBI90Wm8o9Q6p00C	\N	\N	\N	0	\N	\N	\N	\N	oC8rM3G8SNwuMLHjQ5qB	\N	2025-01-04 22:53:22.411317	\N	0	\N	\N	2025-01-04 22:53:22.411164	2025-01-04 22:53:22.411164
64	rjbrzjjlmmuj@do-not-respond.me	$2a$12$uPwn/71FYhpI/3FtFOhd9O8voQvNMmESL4EalVK4ZQ51j7.8qoGaq	\N	\N	\N	0	\N	\N	\N	\N	zVTwuZVCPGk94rfuuHnm	\N	2025-01-05 12:15:56.716368	\N	0	\N	\N	2025-01-05 12:15:56.716051	2025-01-05 12:15:56.716051
39	millskiron@gmail.com	$2a$12$SyA7mE2Cl/FyFtg5uHYGCOHF7XGA0vqraWcdAcEZaUYEnOkcLbK9y	\N	\N	\N	0	\N	\N	\N	\N	YtDrzK9yUN4vJFeywCY5	\N	2024-12-14 04:22:46.900827	\N	0	\N	\N	2024-12-14 04:22:46.898761	2024-12-14 04:22:46.898761
65	urokicepob207@gmail.com	$2a$12$7DZSO75paDJ2vitJF1K2uevxGZ0uiwfoq.IF6QgHVhEGnX3sU/xJO	\N	\N	\N	0	\N	\N	\N	\N	sH8GKgqh8B3ousYBXxTX	\N	2025-01-06 02:42:43.173243	\N	0	\N	\N	2025-01-06 02:42:43.172941	2025-01-06 02:42:43.172941
40	filrdelapaz@yahoo.com	$2a$12$QtvLdA0yWy.HS0hSFL4l3eY.TNtsIIwYqJP9w931yw9gsT1Hqp5j2	\N	\N	\N	0	\N	\N	\N	\N	RNP_BxpXr6CKT27ZXefT	\N	2024-12-15 00:30:26.770476	\N	0	\N	\N	2024-12-15 00:30:26.770167	2024-12-15 00:30:26.770167
41	bzejjsrizmuj@dont-reply.me	$2a$12$Th5VWm4tOARGEKFpUsuebeMxuUWLOVx9l7.hePY30w2UNYfnqg5Xa	\N	\N	\N	0	\N	\N	\N	\N	9DQ4UfYMVgyZ9hA9HFu6	\N	2024-12-15 12:33:47.909327	\N	0	\N	\N	2024-12-15 12:33:47.909108	2024-12-15 12:33:47.909108
42	nabsheonarain@yahoo.com	$2a$12$fLuw1HYOyGyEKRgeVyKz6eGRFdfbMuBuXRqnGE7pK8pBGZfkmV9g2	\N	\N	\N	0	\N	\N	\N	\N	nUa-kuQQLRZW_Vsp8Zqs	\N	2024-12-15 22:04:42.649734	\N	0	\N	\N	2024-12-15 22:04:42.649534	2024-12-15 22:04:42.649534
66	ihowogefef205@gmail.com	$2a$12$9SeJWptuzjwI.x1fMt.bluFUuL6Yhcro9xN2NvB7mpKRubinh7.dS	\N	\N	\N	0	\N	\N	\N	\N	TyFRhoXUbTg6bWXEvhMF	\N	2025-01-07 07:08:32.826029	\N	0	\N	\N	2025-01-07 07:08:32.825895	2025-01-07 07:08:32.825895
43	dghujuysbgcd@yahoo.com	$2a$12$YuhP.VSDCNNczF29aRXZE.lfkrBSaMxR5zZl.V3e9GEuraje3yD6u	\N	\N	\N	0	\N	\N	\N	\N	8ghRjEusQd2YWjWoFbQm	\N	2024-12-17 00:47:28.783037	\N	0	\N	\N	2024-12-17 00:47:28.782615	2024-12-17 00:47:28.782615
67	smd9bi3cpefs@yahoo.com	$2a$12$MWb/AFfQHUqiOLFCfao2zuuw7AJ0Y8sZnDxYAORO5ms1YdU7OHuXO	\N	\N	\N	0	\N	\N	\N	\N	Xzm8y2RtHMjx3NzPry8n	\N	2025-01-08 07:47:31.788355	\N	0	\N	\N	2025-01-08 07:47:31.788006	2025-01-08 07:47:31.788006
44	aomwyvteat@yahoo.com	$2a$12$3y9eoPDJ4ZM.0fEycr6kvenTxYSaBZjzvqKHZ2ForHv3Pa6mXg1by	\N	\N	\N	0	\N	\N	\N	\N	3p58btLZE_ionJDJdKHX	\N	2024-12-18 06:15:23.667058	\N	0	\N	\N	2024-12-18 06:15:23.666826	2024-12-18 06:15:23.666826
45	bibhnwoghbaatqw@yahoo.com	$2a$12$VeR/Z8cebvtQz3HVRUk9oOnUr9HCRJs//mymxsx869PolTIQoQm6y	\N	\N	\N	0	\N	\N	\N	\N	5jc8-usCnkxdkdmsd7yw	\N	2024-12-19 06:51:31.952343	\N	0	\N	\N	2024-12-19 06:51:31.952186	2024-12-19 06:51:31.952186
46	n0in0qt9lucmnmo7@yahoo.com	$2a$12$idfyNJEVMcePl4mxzGkL3OAJrxa3bsVhNoRj8R4tyiT5Vs9AghRMS	\N	\N	\N	0	\N	\N	\N	\N	ynNwz6z2LPA2zXKWKKT-	\N	2024-12-20 06:57:43.481042	\N	0	\N	\N	2024-12-20 06:57:43.480028	2024-12-20 06:57:43.480028
47	bbrlalzzlmuj@do-not-respond.me	$2a$12$Q.ISqLcaJ7Dp75X3t4jZhepKoQMFLT7376TYA6MOd98tiBh2bmT.K	\N	\N	\N	0	\N	\N	\N	\N	_Mzj5HBhzcpzHHpn_SKs	\N	2024-12-20 10:47:52.780722	\N	0	\N	\N	2024-12-20 10:47:52.780539	2024-12-20 10:47:52.780539
48	quracebeja85@gmail.com	$2a$12$ztGPJ01PXMGmP844K7Oe/u4wp27zVwJ9.0/1z.kRFf1AVqwM0vtKC	\N	\N	\N	0	\N	\N	\N	\N	znxMosKsVHYx9MYFqV8U	\N	2024-12-21 04:39:31.645184	\N	0	\N	\N	2024-12-21 04:39:31.645061	2024-12-21 04:39:31.645061
68	beskalhagelerer@yahoo.com	$2a$12$YfUyQnFbuytXii0NxDBT2.QFn5/iUuccfndA5K2256Z.W8LvVAZQS	\N	\N	\N	0	\N	\N	\N	\N	kd5bQsa4tsZCRQzCbxE5	\N	2025-01-10 10:33:53.547871	\N	0	\N	\N	2025-01-10 10:33:53.547748	2025-01-10 10:33:53.547748
49	llirdgsorec@yahoo.com	$2a$12$D2mLlhquJ3BuSh0O4EwUoO6kHeWf3pMt4s3ASKdm6L.372RA148j2	\N	\N	\N	0	\N	\N	\N	\N	zv6VDDt_vp_bvhy2d6Ct	\N	2024-12-21 23:59:53.603442	\N	0	\N	\N	2024-12-21 23:59:53.603336	2024-12-21 23:59:53.603336
50	asc9oijacileu@yahoo.com	$2a$12$HgZeIFyRSdQC9YEnwfQ5GOb7TOYTX./Ltr29SWHhndWWntcVLrSy.	\N	\N	\N	0	\N	\N	\N	\N	uZ3aqu_67r94xaNqxScz	\N	2024-12-22 18:10:56.129186	\N	0	\N	\N	2024-12-22 18:10:56.12902	2024-12-22 18:10:56.12902
51	azuwolig212@gmail.com	$2a$12$.Vr.RHOgnK7YYXbrFabZLOVUD1sSyJhP6N/VJZgliIOMLal28lyiC	\N	\N	\N	0	\N	\N	\N	\N	5Q31T882ihqvtTFsvBVu	\N	2024-12-24 15:58:45.621406	\N	0	\N	\N	2024-12-24 15:58:45.621288	2024-12-24 15:58:45.621288
52	crescentoemirage39ua@gmail.com	$2a$12$fXyaki3nycWKP.CUbhaQ4eYpHqVVIVFs3mp/fkGsSOzDo5MBbz5Xm	\N	\N	\N	0	\N	\N	\N	\N	r3b-PPXYzYHFZPrk864s	\N	2024-12-25 12:14:05.163564	\N	0	\N	\N	2024-12-25 12:14:05.163422	2024-12-25 12:14:05.163422
53	clibertisumey@yahoo.com	$2a$12$USSMV8Hu9VJPqocP1QQLZOIMLvnzBgxFuJtzeVdEXZzZt5vq56kRi	\N	\N	\N	0	\N	\N	\N	\N	GyhsVA1GxHHg26JU4Gwf	\N	2024-12-26 07:49:23.292254	\N	0	\N	\N	2024-12-26 07:49:23.291745	2024-12-26 07:49:23.291745
54	orescogistert@yahoo.com	$2a$12$dxcb34LhAQFxQnyuzl7GhOrLCIkfqgEiM/tut4VS2yAWHNhX2We7y	\N	\N	\N	0	\N	\N	\N	\N	moJTqpjNneXYDgf3PnPY	\N	2024-12-27 08:10:25.770069	\N	0	\N	\N	2024-12-27 08:10:25.769885	2024-12-27 08:10:25.769885
55	ledmonteell@yahoo.com	$2a$12$zoDfOGYBd5DSTp6DrN9uDesoUZUr4ZwR1he8D8GdXgx5FWSnvtz8W	\N	\N	\N	0	\N	\N	\N	\N	j15qs1RGCxpo92V4C-Su	\N	2024-12-28 06:45:48.368049	\N	0	\N	\N	2024-12-28 06:45:48.367869	2024-12-28 06:45:48.367869
56	poriviwugok895@gmail.com	$2a$12$z8rm0bpxlpv4kbRxgjITO.WWA4FySNvU70JFtFpJyDj6VpsjRPwHy	\N	\N	\N	0	\N	\N	\N	\N	9DATF_NbR-LPxLwgtaa6	\N	2024-12-30 02:12:39.911783	\N	0	\N	\N	2024-12-30 02:12:39.911659	2024-12-30 02:12:39.911659
57	bljaamrbemuj@dont-reply.me	$2a$12$s.RdFPE9HW6RmxRzbLvypOoFiP2GrY8BkChSWbYdSOTyEBvymB0WG	\N	\N	\N	0	\N	\N	\N	\N	4sT-CyEGgnquQ5KtKxre	\N	2024-12-30 16:02:45.364443	\N	0	\N	\N	2024-12-30 16:02:45.364218	2024-12-30 16:02:45.364218
58	uyaxexejuk17@gmail.com	$2a$12$Y5ZvjymssLsIQ1iWjs1PueCnbzMKy7r.XqyiRfVCpetHALtMOn0Fa	\N	\N	\N	0	\N	\N	\N	\N	16E7nNGNmL4Zyhhmt-rA	\N	2024-12-31 00:09:34.70261	\N	0	\N	\N	2024-12-31 00:09:34.70243	2024-12-31 00:09:34.70243
59	iyuqeyaq10@gmail.com	$2a$12$teBgmcgkMcb8V9mNGXXX9e2M4rh.bd36CLL2pILBPP0SYM7u9SJXC	\N	\N	\N	0	\N	\N	\N	\N	kQn3SMv7zokYNw4vJBgx	\N	2024-12-31 18:15:19.713973	\N	0	\N	\N	2024-12-31 18:15:19.713816	2024-12-31 18:15:19.713816
60	geyutahikaz532@gmail.com	$2a$12$rOYedz8xg3Y9YVX9qRy9IumKgjVexafY2mTH9enbTlUq98zIj3Gl6	\N	\N	\N	0	\N	\N	\N	\N	yX3aYgYbd4sTAaS24SV2	\N	2025-01-01 10:54:04.185776	\N	0	\N	\N	2025-01-01 10:54:04.185621	2025-01-01 10:54:04.185621
61	oyeqedumiy50@gmail.com	$2a$12$xpAt8raMmVep0kE8xQvSDOeCGgjkMDuaJ.idsiON9ChFVvtXb/YJq	\N	\N	\N	0	\N	\N	\N	\N	TD7YSaFPkuCNcaf_sRsv	\N	2025-01-02 04:22:49.255474	\N	0	\N	\N	2025-01-02 04:22:49.255338	2025-01-02 04:22:49.255338
69	inopido998@gmail.com	$2a$12$1Zk7HZ3W0rNcXsiZjtSYnO/o/ENSVvcvAi.sDWzZ9vaeiTBA/0pdy	\N	\N	\N	0	\N	\N	\N	\N	nLiJhF1jexYGZ82JTKqW	\N	2025-01-11 08:41:13.689176	\N	0	\N	\N	2025-01-11 08:41:13.689035	2025-01-11 08:41:13.689035
70	reieijsrimuj@dont-reply.me	$2a$12$Xr7Dx287LhOu4SciEUwUpe0Y4rYgd4q3BmcyTBUCkIfttmIccIrPO	\N	\N	\N	0	\N	\N	\N	\N	DsacyWf-wwAzWBQzMMUK	\N	2025-01-11 09:53:13.802537	\N	0	\N	\N	2025-01-11 09:53:13.802213	2025-01-11 09:53:13.802213
71	maodelicata@yahoo.com	$2a$12$XUp/JxmaH0ARzF9w6Fo1meP7.UOF1BHUsH3p6ju58qn3RqzF7B3De	\N	\N	\N	0	\N	\N	\N	\N	dD4ybsSGZkH3ZUFnya1_	\N	2025-01-12 08:30:44.007131	\N	0	\N	\N	2025-01-12 08:30:44.006974	2025-01-12 08:30:44.006974
72	gwwfoirdvtrwncwv@yahoo.com	$2a$12$5hcsPxju2tpHSTcM7dqXueJW8MhruR2n1jgal7YSAeysMpGF4Pc.u	\N	\N	\N	0	\N	\N	\N	\N	dxD7f84EYyRENxA2VWbX	\N	2025-01-13 12:18:07.537625	\N	0	\N	\N	2025-01-13 12:18:07.537427	2025-01-13 12:18:07.537427
73	fablee23umbra@gmail.com	$2a$12$mMt/um/U2ITg6uRkVhbaguqZ/JvrNY4P.rnSv/NMBELRG4pxrI1.m	\N	\N	\N	0	\N	\N	\N	\N	GZC2sS48f1-p3sFmGQQz	\N	2025-01-15 04:44:20.270101	\N	0	\N	\N	2025-01-15 04:44:20.269947	2025-01-15 04:44:20.269947
74	illuminateoy34kaleidoscopeoy@gmail.com	$2a$12$hhrn5BmqaVPfUKvsn0XhGeiYIbZvoglOG.AfNLjPObEB0s//OaHF6	\N	\N	\N	0	\N	\N	\N	\N	FrHFKhxhn8cyMAmxG1Pz	\N	2025-01-16 12:57:39.549376	\N	0	\N	\N	2025-01-16 12:57:39.549236	2025-01-16 12:57:39.549236
75	pazapz@mailbox.in.ua	$2a$12$cjI2Wf1ywYMC0iKOsRzpOeZCX2z.6wGph79UvLw7v30kAc3wU5PsG	\N	\N	\N	0	\N	\N	\N	\N	mZVCW82fUhTUpXwiyC7_	\N	2025-01-17 23:48:25.167433	\N	12	\N	\N	2025-01-17 23:48:25.167272	2025-01-17 23:48:25.167272
78	yborealoymirage70oui@gmail.com	$2a$12$Hz1ux8SDHJ61K./yHfoFH.DcAb7kKJIoQAD09.bRaUPurEZv6fxAu	\N	\N	\N	0	\N	\N	\N	\N	TP-yYBLHrCbZuqRibmPy	\N	2025-01-19 17:59:58.964959	\N	0	\N	\N	2025-01-19 17:59:58.964661	2025-01-19 17:59:58.964661
79	vpj71xkd6sp0sn@yahoo.com	$2a$12$M/lm7n2E0.6aX4leFe45HuYwSkmi.DzwSSx6QDDUp8dTj0iaIZwNK	\N	\N	\N	0	\N	\N	\N	\N	rAisJVm8Qoad2dKVhe5n	\N	2025-01-20 14:16:04.835598	\N	0	\N	\N	2025-01-20 14:16:04.835459	2025-01-20 14:16:04.835459
80	azsiibbsrmuj@dont-reply.me	$2a$12$RvRqgN0gbAwJ.FCEfnoi8eEZQgTNnOKG4Xoa4.wnDV4HNQfV9jBIu	\N	\N	\N	0	\N	\N	\N	\N	8-5kaLtcPj9K2DwfjckZ	\N	2025-01-24 08:23:21.845288	\N	0	\N	\N	2025-01-24 08:23:21.8441	2025-01-24 08:23:21.8441
81	qgk24fh8rfln8qt@yahoo.com	$2a$12$fj0/yjOFF1s9JSP/wSQboOvXSxRReHRvF6VK2VZhKzMQfsilEdA4m	\N	\N	\N	0	\N	\N	\N	\N	wygQa22g95LVR3M4Qmyy	\N	2025-01-27 02:51:25.105686	\N	0	\N	\N	2025-01-27 02:51:25.103703	2025-01-27 02:51:25.103703
82	aibbirillmuj@dont-reply.me	$2a$12$u0Lo7VvAi9aHmezoQWNU6.kCbzNLzga83hTA57EB/kj1UIz3/DBvG	\N	\N	\N	0	\N	\N	\N	\N	uYACcwpqCR9-VA91ddxx	\N	2025-01-28 23:09:39.320794	\N	0	\N	\N	2025-01-28 23:09:39.320226	2025-01-28 23:09:39.320226
83	bjin8kfh41v@yahoo.com	$2a$12$7voXJS699NAwKNY4NTakbuBX96fJ.vG0W5DpCn7.nxHUUSz2Or6iG	\N	\N	\N	0	\N	\N	\N	\N	t3RYHWE1Jt_gdHgMpBff	\N	2025-01-29 09:55:30.990652	\N	0	\N	\N	2025-01-29 09:55:30.988527	2025-01-29 09:55:30.988527
84	nyikxvhsgfmpff@yahoo.com	$2a$12$W3zP7r1qU/el6BAx1/kpjOOFURM1pwzLAJ8B7toaIY0Gx33lbA57m	\N	\N	\N	0	\N	\N	\N	\N	nW-LoUzGHer4qyDXH9QC	\N	2025-01-31 01:28:55.023664	\N	0	\N	\N	2025-01-31 01:28:55.023504	2025-01-31 01:28:55.023504
85	vortexayoracle@gmail.com	$2a$12$eoExvttYGdi.lhiJtUrNuOlORp2uBNSWeNuyC5p0scuzNcctMoTki	\N	\N	\N	0	\N	\N	\N	\N	spZ7Ws16FCcsrWdXqGf_	\N	2025-02-01 07:02:59.302843	\N	0	\N	\N	2025-02-01 07:02:59.302726	2025-02-01 07:02:59.302726
86	ijmjiijjemuj@dont-reply.me	$2a$12$1HbFjenuGdx8Fqzwmcs2K.URYg1JE/cSAoULMFeoiWok3jsOQt2rS	\N	\N	\N	0	\N	\N	\N	\N	mt-HUw4JZrzpsU4Aqks4	\N	2025-02-01 21:05:43.047697	\N	0	\N	\N	2025-02-01 21:05:43.047522	2025-02-01 21:05:43.047522
87	iunadwkjiwsmap7@yahoo.com	$2a$12$dXJajat1t2L/zkXY0N8S7uYXT3gRZHif7R.HW2x0G/G4LQeY1/Asy	\N	\N	\N	0	\N	\N	\N	\N	_kTCXyZq9599cD71NUA5	\N	2025-02-03 03:06:05.83661	\N	0	\N	\N	2025-02-03 03:06:05.836412	2025-02-03 03:06:05.836412
88	uegossamersylvanoui@gmail.com	$2a$12$bgZUcSyiX.Eelkdn24Yq9.2dRC1Tr8VyoNhvIZvKkQL3sWluyQ75O	\N	\N	\N	0	\N	\N	\N	\N	ie2ETb9VbDULxSbGnHX6	\N	2025-02-04 04:35:23.896421	\N	0	\N	\N	2025-02-04 04:35:23.896298	2025-02-04 04:35:23.896298
89	aiobsidian46rift30@gmail.com	$2a$12$j2Oin.nvtaf6XZ/ACtp2p.lbN7a0EEzZc5.g2PTewEjV//risMkm.	\N	\N	\N	0	\N	\N	\N	\N	JNUJh5zvryqZZAshdusL	\N	2025-02-05 05:38:49.027267	\N	0	\N	\N	2025-02-05 05:38:49.027068	2025-02-05 05:38:49.027068
90	boifo3npuypn@yahoo.com	$2a$12$WfW1JoyVZ2Pbop5BkY3trOld3qgBjgypfxBdi5YrgB2q7UKsRv0/u	\N	\N	\N	0	\N	\N	\N	\N	g7AwDEVTXNcdX2XL8SsU	\N	2025-02-06 05:02:51.041658	\N	0	\N	\N	2025-02-06 05:02:51.041474	2025-02-06 05:02:51.041474
91	sansoneacothley@gmail.com	$2a$12$/KaseLUiYc6IYetvcymkjebYaY790yIY6FDps9yet03ugnRsyd9kK	\N	\N	\N	0	\N	\N	\N	\N	WMMxNyxmKV6HtKzxNYty	\N	2025-02-06 18:56:58.404836	\N	0	\N	\N	2025-02-06 18:56:58.404494	2025-02-06 18:56:58.404494
92	aueclipsexenon28ua@gmail.com	$2a$12$TUulacT52wGuDsv9kOwTA.znGr57eZi4USGH83GzbjxoGElAHQwBK	\N	\N	\N	0	\N	\N	\N	\N	yGyrqPGxEQFv3bswZz_J	\N	2025-02-07 04:08:45.505882	\N	0	\N	\N	2025-02-07 04:08:45.505772	2025-02-07 04:08:45.505772
93	stellar87quartz58@gmail.com	$2a$12$WfD4rBU9s1dtPjob02ATzO9IwM7PubGcqTFkQOyJ479CpS3XAND.q	\N	\N	\N	0	\N	\N	\N	\N	v8kvNkSCMJSrwJyt6dYx	\N	2025-02-08 16:35:47.89012	\N	0	\N	\N	2025-02-08 16:35:47.889998	2025-02-08 16:35:47.889998
94	lunareorift31@gmail.com	$2a$12$l17M8GHgbhOfapmuogtIbuNtYSsRVILNqbSv2bw/XAN7OuHTc7EGW	\N	\N	\N	0	\N	\N	\N	\N	C1mzMYx5LLzJyuoACL7H	\N	2025-02-10 06:43:34.156233	\N	0	\N	\N	2025-02-10 06:43:34.156091	2025-02-10 06:43:34.156091
95	appreview@bentobook.app	$2a$12$ow/.K3y1Nr4N3iLidYbfC.XeijfeOsH9Aviwf3igpVxelkJnkXloC	\N	\N	\N	1	2025-02-10 17:45:20.096344	2025-02-10 17:45:20.096344	172.71.134.217	172.71.134.217	PB1v6tA1LHGNVqmFvpxe	2025-02-10 17:43:53.155363	2025-02-10 17:43:53.15625	\N	0	\N	\N	2025-02-10 17:43:53.156008	2025-02-10 17:45:20.096931
104	graibrock39@gmail.com	$2a$12$0bafWQ7WiWqDSxaBElfq8uKj82iKb.JSfZY.V4/vt0Pk/lAkY8nQm	\N	\N	\N	0	\N	\N	\N	\N	kkYnPfW28hNC7K5-YmE6	\N	2025-02-23 08:08:22.706219	\N	0	\N	\N	2025-02-23 08:08:22.706112	2025-02-23 08:08:22.706112
96	udahexajib97@gmail.com	$2a$12$/rl50hbNTut/3u7nMFFfOu45B9EGjq4xovMs4rW6.VsPKahe8tvAS	\N	\N	\N	0	\N	\N	\N	\N	PC1NJFqXKRLZRa8vsunu	\N	2025-02-14 07:17:24.77668	\N	0	\N	\N	2025-02-14 07:17:24.776255	2025-02-14 07:17:24.776255
105	poulouebaace@yahoo.com	$2a$12$E2s.v2nsUKLr8XyNGJwEhuH41GmcaXIkbMiZdodqmoGda20XtfbNO	\N	\N	\N	0	\N	\N	\N	\N	smywhsqyvZnsLp_Gx6uL	\N	2025-02-24 04:06:44.798866	\N	0	\N	\N	2025-02-24 04:06:44.798678	2025-02-24 04:06:44.798678
97	aunirvanaeaquartzau@gmail.com	$2a$12$3CE8JoReejQam1SxD0wl1egPn/.5l.nxc10KvilWtPGjcn2uDtjjO	\N	\N	\N	0	\N	\N	\N	\N	G2CA1LUkfREj2Bjf78FQ	\N	2025-02-15 02:38:52.664591	\N	0	\N	\N	2025-02-15 02:38:52.664399	2025-02-15 02:38:52.664399
98	akerleim1990@gmail.com	$2a$12$xGKtyDxsu8stMThnekPSjeTOmF4F5140accbfrbaAfAnlIAk5zZoy	\N	\N	\N	0	\N	\N	\N	\N	hyjBE4KiLrtozYhb8q8-	\N	2025-02-15 19:25:43.90115	\N	0	\N	\N	2025-02-15 19:25:43.900995	2025-02-15 19:25:43.900995
99	lennigreene55@gmail.com	$2a$12$Gd4rOcfDZJGoHShKB8VCAO/N3FlUUzyVBl4SUqd8ArAjFKPK8vKi.	\N	\N	\N	0	\N	\N	\N	\N	nikkybzVUy9Ha54JziNv	\N	2025-02-17 03:40:38.389839	\N	0	\N	\N	2025-02-17 03:40:38.389579	2025-02-17 03:40:38.389579
100	adelisiyafigueroao36@gmail.com	$2a$12$T7TyUVtncblftQr42KF7ZOjH8PtsBxu4OrvnPRB42kS04LwV5a5tq	\N	\N	\N	0	\N	\N	\N	\N	ny2VNokssLqxU67Miu4z	\N	2025-02-18 06:20:57.401697	\N	0	\N	\N	2025-02-18 06:20:57.40117	2025-02-18 06:20:57.40117
101	mcintyreedyn17@gmail.com	$2a$12$imS9Vigrm.0Wvk4z7ssowuk6x9NZfDoUrEGmcgK6GXW5G26cOfX6O	\N	\N	\N	0	\N	\N	\N	\N	zmhWrHU47ruN8_xJGf_E	\N	2025-02-19 14:08:44.866761	\N	0	\N	\N	2025-02-19 14:08:44.865564	2025-02-19 14:08:44.865564
102	oybrinj@gmail.com	$2a$12$wUb99PBzXWu.c2mSht9nResONIvz1Wd.3/vcgBhcBgkSGuGR8WWjK	\N	\N	\N	0	\N	\N	\N	\N	NwdcYsBJ8qZaWyeDBnVd	\N	2025-02-20 14:07:37.00762	\N	0	\N	\N	2025-02-20 14:07:37.003498	2025-02-20 14:07:37.003498
110	brinkhan23@gmail.com	$2a$12$pnnttJuqb5n4fRFlonY3WuC.6ulGmf1PheuiP7Hd3iUSQiiKWSw3q	\N	\N	\N	0	\N	\N	\N	\N	BqGb6BmQhs5txDckF21c	\N	2025-02-28 21:47:34.997796	\N	0	\N	\N	2025-02-28 21:47:34.997572	2025-02-28 21:47:34.997572
106	duskoi81iris@gmail.com	$2a$12$rF68gx.gin1YIngTMTpZfexzVbZyaXL.ViYKKceNmRAm/FDvNSyp6	\N	\N	\N	0	\N	\N	\N	\N	RMf9YiWojdPa2NNx99og	\N	2025-02-25 03:52:10.295557	\N	0	\N	\N	2025-02-25 03:52:10.295299	2025-02-25 03:52:10.295299
115	dominmoogu50@gmail.com	$2a$12$4i/LeS/AhndEZ8WcajTp3uz51P5qrxO2bv4VKhxwZ5xB3SYqrqEl6	\N	\N	\N	0	\N	\N	\N	\N	zC9xHzbupuaheY-m-UpY	\N	2025-03-05 23:45:46.287647	\N	0	\N	\N	2025-03-05 23:45:46.287321	2025-03-05 23:45:46.287321
107	nirvana6rift5ia@gmail.com	$2a$12$1NzVfMvzJ/3KNBeDUNkNNunAwA78hJK5GqK4TrNJRaSvqbzkw3Hn6	\N	\N	\N	0	\N	\N	\N	\N	z3U-iqqRiToEjxsgg3e1	\N	2025-02-26 05:04:39.375882	\N	0	\N	\N	2025-02-26 05:04:39.375786	2025-02-26 05:04:39.375786
113	mortgreerb@gmail.com	$2a$12$cXZqOi94PadiSE5fgBq6Z.Q8fAY4.2fgjTJgNehm8UH/9T7BEQYru	\N	\N	\N	0	\N	\N	\N	\N	KWUsj5deeTREbWAwzLZh	\N	2025-03-04 01:29:58.212217	\N	0	\N	\N	2025-03-04 01:29:58.211472	2025-03-04 01:29:58.211472
108	maldonadoaltaird6@gmail.com	$2a$12$2hXL0CVEFH2YNpM.y57t1uhvcwWRPgQbMKpso8/RwlQh58ATrspQK	\N	\N	\N	0	\N	\N	\N	\N	7AdbD3NMKfn9xwBi3Ljh	\N	2025-02-27 02:22:55.94058	\N	0	\N	\N	2025-02-27 02:22:55.940258	2025-02-27 02:22:55.940258
103	megmql25@gmail.com	$2a$12$1cptZp6E8mUgv1mSiMQtCeThhfP9fuPDtbZ6jOTGxMNBWkNXo33LW	\N	\N	\N	0	\N	\N	\N	\N	PhqjzRLxdU9Faaj_kvoB	\N	2025-02-22 18:57:28.049359	\N	0	\N	\N	2025-02-22 18:57:28.049097	2025-02-22 18:57:28.049097
109	vddhlisumdl@yahoo.com	$2a$12$l0nYiJ6L44KN9t3Tc.rFieS7euPEgVvWDFeNu3RbEhmLNMJxJPf1.	\N	\N	\N	0	\N	\N	\N	\N	QGrbEprsxR5rAnZ3tzC_	\N	2025-02-28 04:19:29.83455	\N	0	\N	\N	2025-02-28 04:19:29.834451	2025-02-28 04:19:29.834451
111	teodocarlsaq3@gmail.com	$2a$12$v/SqDB8LbnE03Z071X2YyeM1HscebkP3.G8bivxeN2d28JKRlqnmu	\N	\N	\N	0	\N	\N	\N	\N	UxgdvtuueizbCZ1gzuLN	\N	2025-03-01 12:04:30.19939	\N	0	\N	\N	2025-03-01 12:04:30.198322	2025-03-01 12:04:30.198322
112	ksnowtf34@gmail.com	$2a$12$E5.J/x/a107sw6qT0QryP.PSkzvkgIeTEk05uQD2hwsI8tXKUBKWG	\N	\N	\N	0	\N	\N	\N	\N	4BNAXHT8vUYdScgz8Ybb	\N	2025-03-02 06:40:41.710638	\N	0	\N	\N	2025-03-02 06:40:41.710274	2025-03-02 06:40:41.710274
12	esyram.kcnarf@gmail.com	$2a$12$RKujDXru9SH8C6dFAEI0yujmXSMWm8jFaGP6T8PfzjALCha7t4UTG	\N	\N	2025-03-02 11:50:52.263424	28	2025-06-19 17:19:54.700438	2025-05-13 12:42:44.314604	172.68.151.146	141.101.96.61	_urx9HK9TqrnXxWjNFF3	2024-11-16 21:32:51.725668	2024-11-16 19:11:20.730544	\N	0	\N	\N	2024-11-16 19:11:20.729656	2025-06-19 17:19:54.700938
114	mckeenolanm2006@gmail.com	$2a$12$7d5cmmd4Ff2uJVQ4xsCW.erNE/axrO5iSofD46N0HaaV2RRKp4xA2	\N	\N	\N	0	\N	\N	\N	\N	5doE6cQknm7J4dwffx9k	\N	2025-03-05 00:21:41.235186	\N	0	\N	\N	2025-03-05 00:21:41.235013	2025-03-05 00:21:41.235013
116	schwartzgennaoz5@gmail.com	$2a$12$6hDuNm1.SapbSSDPcy5qb.yDvcCRkAv2lC4esIYvbTfxeZefJta8O	\N	\N	\N	0	\N	\N	\N	\N	EAmdgDCvpwM9AsKjGS22	\N	2025-03-08 06:19:51.737489	\N	0	\N	\N	2025-03-08 06:19:51.737345	2025-03-08 06:19:51.737345
117	djoynic@gmail.com	$2a$12$nUDucb841mBM0z6FaGCLX.4UtoNXipXIyy9yLA2Gya.rXXpPEJ19W	\N	\N	\N	0	\N	\N	\N	\N	mq3cT9XqziyDSzkRSoge	\N	2025-03-09 03:26:32.08377	\N	0	\N	\N	2025-03-09 03:26:32.083668	2025-03-09 03:26:32.083668
118	tranterfk@gmail.com	$2a$12$o0I5HAap6RzRsubNapBeWeLEsFsEm3Mrxwxma5czs8zUj2LK6A84.	\N	\N	\N	0	\N	\N	\N	\N	az9cJ8NfsyrnkJpkgi99	\N	2025-03-12 06:55:46.665871	\N	0	\N	\N	2025-03-12 06:55:46.665693	2025-03-12 06:55:46.665693
119	moonmeibellaini5@gmail.com	$2a$12$581lDMsVUagr0hP0mooMqu.W6FAhUu7Lj.H35bhBSGIymrgAowGNG	\N	\N	\N	0	\N	\N	\N	\N	41pzAVkytPSp_beQS5RL	\N	2025-03-13 18:44:13.579541	\N	0	\N	\N	2025-03-13 18:44:13.579401	2025-03-13 18:44:13.579401
120	brenkorepi42@gmail.com	$2a$12$dRXkgld6D/F5U5uTzhf9A.RjM6LdNc0.KTfjIOHGvfNwVWosg4hwW	\N	\N	\N	0	\N	\N	\N	\N	f8eyrVAdQhzkyTgJjo4K	\N	2025-03-14 17:21:24.670009	\N	0	\N	\N	2025-03-14 17:21:24.669836	2025-03-14 17:21:24.669836
121	djadinalvaradoqh@gmail.com	$2a$12$84gmEOPkGCXakYXx20AC..uJNsK7c4LWgAdPqbl.g3u0VYwT1r3h6	\N	\N	\N	0	\N	\N	\N	\N	8KzxgejFHYCUzRz9zo73	\N	2025-03-15 12:13:15.022708	\N	0	\N	\N	2025-03-15 12:13:15.022414	2025-03-15 12:13:15.022414
122	melissa_broadus1992@yahoo.com	$2a$12$YnRY0K/bya/qnSSgTBuVpOK/UaoJgq6yROoKtPM2rgJCu933ktdU.	\N	\N	\N	0	\N	\N	\N	\N	1-2t-z1nZkz2gZrGPNKs	\N	2025-03-16 07:41:31.976392	\N	0	\N	\N	2025-03-16 07:41:31.976289	2025-03-16 07:41:31.976289
137	milonas_richard136473@yahoo.com	$2a$12$MrVEBsJlsQuPLwnKIekR.Ohe4LLuvOdbEXKLG4PIKL8GL6hyubroa	\N	\N	\N	0	\N	\N	\N	\N	EaQjUgnT16BwuFPcL6MK	\N	2025-04-05 12:35:26.44295	\N	0	\N	\N	2025-04-05 12:35:26.442661	2025-04-05 12:35:26.442661
138	mark_hill597115@yahoo.com	$2a$12$T0DhZA4xnRHEmKN1k3Zl1.cMnbsUooTdBhBLeC5tlgAnb.YVq7quK	\N	\N	\N	0	\N	\N	\N	\N	UEEcpsvdkk1xN6sYYyUw	\N	2025-04-05 16:10:08.938935	\N	0	\N	\N	2025-04-05 16:10:08.936382	2025-04-05 16:10:08.936382
139	thompson.kimberly507864@yahoo.com	$2a$12$W7D/cFoXFd1x.FO.MHMXzuApm78.2HYS.6JtqIOv2qzHElJXUSGri	\N	\N	\N	0	\N	\N	\N	\N	cbW8bC5_rST3ZkFyZJHs	\N	2025-04-06 04:04:12.761847	\N	0	\N	\N	2025-04-06 04:04:12.761668	2025-04-06 04:04:12.761668
140	waltegregoan@gmail.com	$2a$12$MN0ciuaRg4Yiy9/qwxiG.uFVcQmwbtejebgyG82zUUAgJONbThd1a	\N	\N	\N	0	\N	\N	\N	\N	zQYEDfYh58S1EKzwniU7	\N	2025-04-06 11:25:24.127821	\N	0	\N	\N	2025-04-06 11:25:24.127708	2025-04-06 11:25:24.127708
123	svanhildsteeleo@gmail.com	$2a$12$2eGSvzqvkoiAOnCGFalZ5Ox8vs.lMr5XGs5GIZKliURnZAEajD78u	\N	\N	\N	0	\N	\N	\N	\N	sTxnxs2rwxaqBoUNr14s	\N	2025-03-17 03:23:25.477964	\N	0	\N	\N	2025-03-17 03:23:25.4774	2025-03-17 03:23:25.4774
124	soniahogue570475@yahoo.com	$2a$12$hC9Ey73MlMeLiEGQ.8KpIOQ/RvyuEu/dbrLktKB0gfsKZYgHVmu82	\N	\N	\N	0	\N	\N	\N	\N	LRJ_rS9ey4QYpkUs6m5B	\N	2025-03-18 06:01:43.507606	\N	0	\N	\N	2025-03-18 06:01:43.506712	2025-03-18 06:01:43.506712
125	wilkerluks@gmail.com	$2a$12$L2QuMP1VfE9f83g7Hp5zVeV9GsrKUBmXUid9sWO0PECJziFxEzySi	\N	\N	\N	0	\N	\N	\N	\N	AC6Pd5q4nxMg1BxseLWS	\N	2025-03-19 11:03:49.717289	\N	0	\N	\N	2025-03-19 11:03:49.717177	2025-03-19 11:03:49.717177
141	danielle_collins524191@yahoo.com	$2a$12$e7Txh6qDDn2tsMW9Cpe26ucax/rWhD9TdORb7wph./WT5PcxQIA4e	\N	\N	\N	0	\N	\N	\N	\N	CjncUd5iesHrFJ2hmGrd	\N	2025-04-07 01:48:44.793212	\N	0	\N	\N	2025-04-07 01:48:44.793057	2025-04-07 01:48:44.793057
142	dyerkendf48@gmail.com	$2a$12$IhuAvOl.KvZPImY03UAQfey8E2byKEQa/w4mGsrOTqtsSI1jkxRrW	\N	\N	\N	0	\N	\N	\N	\N	EjVpUXFWJXkGjKKTm1iC	\N	2025-04-08 04:00:11.773361	\N	0	\N	\N	2025-04-08 04:00:11.773232	2025-04-08 04:00:11.773232
126	millereldredc1987@gmail.com	$2a$12$zVNySxkYKKKz9CvZ1dHJieIacwdJB6pw1.cuZvqwzCa2T9LsCkzhu	\N	\N	\N	0	\N	\N	\N	\N	6LzURqLJAazxFTzba-5U	\N	2025-03-20 14:45:17.838638	\N	0	\N	\N	2025-03-20 14:45:17.838019	2025-03-20 14:45:17.838019
143	nburnsvi65@gmail.com	$2a$12$2S8vcnY9IF31F4uPsmyvsuiwO9Hb0ywP.E1gQIKi5mNpxO5l8jGVG	\N	\N	\N	0	\N	\N	\N	\N	87yAVuGw2_znzmgbr9Yv	\N	2025-04-09 22:01:52.649221	\N	0	\N	\N	2025-04-09 22:01:52.649081	2025-04-09 22:01:52.649081
144	watersteinziv@gmail.com	$2a$12$fNLb3UCdQDVJALUxGYMRTuQJsRfG2kxunERs9VXU0Yz8KEUb3oiPe	\N	\N	\N	0	\N	\N	\N	\N	sN9vubq_zWSePvvfxJuE	\N	2025-04-10 07:52:16.975011	\N	0	\N	\N	2025-04-10 07:52:16.974818	2025-04-10 07:52:16.974818
145	klerise1985@gmail.com	$2a$12$l2hE/UVcvchjx.2/noke2uF6amtKjNN4xnoW6B40YJTgShCY45SJa	\N	\N	\N	0	\N	\N	\N	\N	vF7J1VqrzBM5r-sCZvpu	\N	2025-04-11 15:35:12.295674	\N	0	\N	\N	2025-04-11 15:35:12.29517	2025-04-11 15:35:12.29517
127	summersdjelissa4@gmail.com	$2a$12$QsnZJPFGV748bfF3hQgPOeZOZ4hkc/CO0l2EqsBmvF5tkR/j/Jt5.	\N	\N	\N	0	\N	\N	\N	\N	xaioQDTWAkMfcrWqWtUD	\N	2025-03-21 03:46:26.502489	\N	0	\N	\N	2025-03-21 03:46:26.501996	2025-03-21 03:46:26.501996
146	basque_josh844191@yahoo.com	$2a$12$xtwcmtWSdDxjyWB4F1CyXeKc8psbrnQfHGIlY2d9MloHYSTTYtlg6	\N	\N	\N	0	\N	\N	\N	\N	Zm2j-yeBFxoY6xj87vSL	\N	2025-04-11 16:43:53.571811	\N	0	\N	\N	2025-04-11 16:43:53.57169	2025-04-11 16:43:53.57169
128	aprilpratt956985@yahoo.com	$2a$12$4Qrim5Y64KZDYGAoYyiEh.l/nYJ2UtEO5UMQ4a36nZNOHRUWCiXie	\N	\N	\N	0	\N	\N	\N	\N	FxNBRMLTm2NXX5pQpJeM	\N	2025-03-23 02:22:12.991857	\N	0	\N	\N	2025-03-23 02:22:12.991117	2025-03-23 02:22:12.991117
129	fbrentonke3@gmail.com	$2a$12$BQpV0HK714q9XCcwGGGnEO3x5MKM/dtE9Q0MbWHj28.a2OR9w7ikK	\N	\N	\N	0	\N	\N	\N	\N	EQxxHB3aRDyx1i26wNuX	\N	2025-03-23 17:49:09.759523	\N	0	\N	\N	2025-03-23 17:49:09.7594	2025-03-23 17:49:09.7594
130	adelislawrencei25@gmail.com	$2a$12$nXNlO99cBH1B3Vrj.TF9LuviHAjeB9mUzP/jayLf0Wmje/YDd97au	\N	\N	\N	0	\N	\N	\N	\N	-sqcZMiETZrZWk7EymyN	\N	2025-03-24 10:37:55.185519	\N	0	\N	\N	2025-03-24 10:37:55.185403	2025-03-24 10:37:55.185403
147	richiehossain1994@yahoo.com	$2a$12$qfDxsZzgm4RbLBFgrQwVuOtnBPQKpBINUVCn1Elnih5ITm0aQbnCW	\N	\N	\N	0	\N	\N	\N	\N	Uf3udGWD6t5HT1-xQUp3	\N	2025-04-13 00:13:39.545485	\N	0	\N	\N	2025-04-13 00:13:39.545341	2025-04-13 00:13:39.545341
148	luis_walsh532316@yahoo.com	$2a$12$G4PKbpvtcIbTFNnLw6B9EuIN/Ouh3vnpbJAj3CUExU0Tl2NtFrwTO	\N	\N	\N	0	\N	\N	\N	\N	nufyYYhNhk-6KdibR3P-	\N	2025-04-13 03:43:40.323804	\N	0	\N	\N	2025-04-13 03:43:40.323684	2025-04-13 03:43:40.323684
131	kelleyfrenkipo31@gmail.com	$2a$12$GSqM5hLT1Pg42Bth0cp8k.VtYdGcYRFgLXYV3grxQtjSRdVLYJaay	\N	\N	\N	0	\N	\N	\N	\N	tBCv7mhw9o75spghUC7f	\N	2025-03-28 12:30:20.921123	\N	0	\N	\N	2025-03-28 12:30:20.920769	2025-03-28 12:30:20.920769
149	bcooperqb37@gmail.com	$2a$12$wpwS3ZTL23sBJv8/OiMwNucTDGL/Ww3BnZsGZ534npcz3GVwMwLe6	\N	\N	\N	0	\N	\N	\N	\N	mhKAavsUR2yFK4xhV5Dx	\N	2025-04-13 03:49:37.086001	\N	0	\N	\N	2025-04-13 03:49:37.085824	2025-04-13 03:49:37.085824
132	matthewjones688914@yahoo.com	$2a$12$3YG8tagxq87S/HLEUxzY.OamqbSaZlTwF9GIQbV7Cqqun74duuKHG	\N	\N	\N	0	\N	\N	\N	\N	MsZBCWqMkPhRkmYEQ4qY	\N	2025-03-30 01:53:43.442529	\N	0	\N	\N	2025-03-30 01:53:43.442361	2025-03-30 01:53:43.442361
133	yorkkonanwi75@gmail.com	$2a$12$CPT7wtBouhhvgD9r1ty9w.Y2ao7sYPUb5yvyHtNrzhAlY2yb/rAMO	\N	\N	\N	0	\N	\N	\N	\N	76JfBQbag8rifi1FUPSs	\N	2025-04-01 05:49:47.057414	\N	0	\N	\N	2025-04-01 05:49:47.056565	2025-04-01 05:49:47.056565
134	langkrispian8@gmail.com	$2a$12$FADdB1OaPjdrrcEkQQZnc.RWNqZko898u6CSJETK4kd0HH4A6VBI2	\N	\N	\N	0	\N	\N	\N	\N	6ExraZ5zvw3WLFxBZsNs	\N	2025-04-03 08:21:24.101918	\N	0	\N	\N	2025-04-03 08:21:24.101677	2025-04-03 08:21:24.101677
135	ethnabernw@gmail.com	$2a$12$Onu0hvNWhCHInKpr3dzvlOvxJFebstUgVtUXFpCddWlK04Ywo.fZG	\N	\N	\N	0	\N	\N	\N	\N	epSzsQXK_Nus3yEz98zX	\N	2025-04-03 19:32:20.597546	\N	0	\N	\N	2025-04-03 19:32:20.597353	2025-04-03 19:32:20.597353
136	gardnerchristine527665@yahoo.com	$2a$12$oSWphiLKh2n6O6a.SnZxeuoWK65KI.wpMlYE01ptLYZ60WJ0hb1o6	\N	\N	\N	0	\N	\N	\N	\N	djrBi_ZAoeQuybEKuEb2	\N	2025-04-04 06:58:10.284662	\N	0	\N	\N	2025-04-04 06:58:10.284487	2025-04-04 06:58:10.284487
150	gardndjoettzn3@gmail.com	$2a$12$skBfvmPJuS.04I1abqVoq.IdibtbR3z1CKKd8Nwp3BIq9YPSyqa2K	\N	\N	\N	0	\N	\N	\N	\N	SGAsBYMzFhTKkYJZbW5G	\N	2025-04-15 12:05:43.929393	\N	0	\N	\N	2025-04-15 12:05:43.929262	2025-04-15 12:05:43.929262
151	korrirodriguezc2005@gmail.com	$2a$12$Em8/JckTDBFht7pE2phfaO9nLE4B1UeG698O0a8aDfPiuiRy/bTEG	\N	\N	\N	0	\N	\N	\N	\N	73-54tqzDaw2x2orGJAG	\N	2025-04-17 05:03:48.107802	\N	0	\N	\N	2025-04-17 05:03:48.107491	2025-04-17 05:03:48.107491
152	verbodepar1973@yahoo.com	$2a$12$QHXkmhzhZlZxZ3JAmI60GO5pcDbxovbsxhz7hyOh3PkZ6sHl/0ZvC	\N	\N	\N	0	\N	\N	\N	\N	XoK1hvHcoYQLUo27_voy	\N	2025-04-18 14:54:17.277114	\N	0	\N	\N	2025-04-18 14:54:17.276938	2025-04-18 14:54:17.276938
153	necomosta1980@yahoo.com	$2a$12$epKAJZ5eJnB.eH8U4cOre.ViP43hIPdHvlw6HezXp3CxF1cb2pHZ.	\N	\N	\N	0	\N	\N	\N	\N	pwEfD6nX6uLG-HRzaeMs	\N	2025-04-18 18:54:29.809286	\N	0	\N	\N	2025-04-18 18:54:29.809158	2025-04-18 18:54:29.809158
154	walshamandal36@gmail.com	$2a$12$l/fsqxyUPNRmlnfZtn4tYO1/C7H59QTHJ2Z.4CreM327UVgZunGGm	\N	\N	\N	0	\N	\N	\N	\N	ymSE-BNdeZ5uWydohzeu	\N	2025-04-19 00:50:52.056691	\N	0	\N	\N	2025-04-19 00:50:52.056522	2025-04-19 00:50:52.056522
155	reubirthdestdi1989@yahoo.com	$2a$12$q.w2SzT.KMlFCg6n8/jCquriBLhAnJ6YMUZctE2UFOZv84CwnvOJm	\N	\N	\N	0	\N	\N	\N	\N	QmWFKCy4472iV9z_V-oe	\N	2025-04-19 17:52:21.06238	\N	0	\N	\N	2025-04-19 17:52:21.062221	2025-04-19 17:52:21.062221
156	grahareddj@gmail.com	$2a$12$0UQ/yxiXD2j4LbMXZI5hlebUoVJzQwtb.QqD/J8fev9BrvnM3KvDu	\N	\N	\N	0	\N	\N	\N	\N	iL6iPTmsF9WprzTiH3xd	\N	2025-04-20 04:23:26.343636	\N	0	\N	\N	2025-04-20 04:23:26.343477	2025-04-20 04:23:26.343477
157	vercucaljazz1970@yahoo.com	$2a$12$IvmQl95adKX7bS8m8PBgDOTnQL7WZozF7xbHHCMkTJAdNBy/i2Iqa	\N	\N	\N	0	\N	\N	\N	\N	YmWAGeTdyZSFw1HS4ZvV	\N	2025-04-20 05:30:22.274803	\N	0	\N	\N	2025-04-20 05:30:22.274629	2025-04-20 05:30:22.274629
158	kleintentm@gmail.com	$2a$12$G9Le.UbYF2xBuXML8oQVU.h4kmguAwHYEPwS3ycV3JNbgtTKdYXcy	\N	\N	\N	0	\N	\N	\N	\N	PTGvEG9bkH2ZbEc8mqNZ	\N	2025-04-20 11:26:36.803373	\N	0	\N	\N	2025-04-20 11:26:36.803163	2025-04-20 11:26:36.803163
159	lingsoblungse1981@yahoo.com	$2a$12$2PxsCGZZabKdTsnGy6xFke6hCerjw5xxZd.7u2ouEOqbkuKp7cfI.	\N	\N	\N	0	\N	\N	\N	\N	mBzvP1ptox8jjm_PxqMR	\N	2025-04-20 20:21:31.000192	\N	0	\N	\N	2025-04-20 20:21:30.999996	2025-04-20 20:21:30.999996
160	doloresconway34@gmail.com	$2a$12$eL.rb03OrmSeTQHnlGTho.o50SYNdXr1UeCNq8pkPCM.7YXkCnuvy	\N	\N	\N	0	\N	\N	\N	\N	zf3BSjtqfcazxx83kDsB	\N	2025-04-25 12:55:41.078341	\N	0	\N	\N	2025-04-25 12:55:41.078181	2025-04-25 12:55:41.078181
161	hesterteri17@gmail.com	$2a$12$vhCy8n4eTjc0Ig.Y8isJ0OQFC2RDyBghMtvl3bKSJbNno7rfsIFB2	\N	\N	\N	0	\N	\N	\N	\N	5c4d1H5QJB7s_Lz47522	\N	2025-04-25 23:19:46.886893	\N	0	\N	\N	2025-04-25 23:19:46.886752	2025-04-25 23:19:46.886752
162	lendonvne4@gmail.com	$2a$12$RO8mGf7b1kORRug4Dbcvlu1Ql1PZmpcD6gym9.3sKE5sK6GZRv1/m	\N	\N	\N	0	\N	\N	\N	\N	saatqezwDmjR4KS__SRc	\N	2025-04-26 13:41:52.125743	\N	0	\N	\N	2025-04-26 13:41:52.125523	2025-04-26 13:41:52.125523
163	rosscaseb@gmail.com	$2a$12$elAIzfI9M01zrc87GkNoQepPa04Toi5jIZQ6SKtDPRFc1PefWPBAy	\N	\N	\N	0	\N	\N	\N	\N	L4u_3yzZPejZguWvfDgn	\N	2025-04-27 12:49:08.054034	\N	0	\N	\N	2025-04-27 12:49:08.0538	2025-04-27 12:49:08.0538
164	henrdolfb41@gmail.com	$2a$12$JlBFAtLqv9xGxPbXAxQL4egiFZ7Qpkvq8PmCIq5KxeCiNllnNye32	\N	\N	\N	0	\N	\N	\N	\N	Q_a71NWJiRJh4A4W6-my	\N	2025-04-28 10:52:43.979349	\N	0	\N	\N	2025-04-28 10:52:43.978851	2025-04-28 10:52:43.978851
165	estradrend2001@gmail.com	$2a$12$nA8/QLrCBXFK616PFRMoe.GutnLSlzn26ypmhrT/.Sdv7ATqLX3G2	\N	\N	\N	0	\N	\N	\N	\N	RRzn3NXCXjrK-Q2x3MnN	\N	2025-04-30 19:24:24.140348	\N	0	\N	\N	2025-04-30 19:24:24.140208	2025-04-30 19:24:24.140208
166	peidwaters1993@gmail.com	$2a$12$w0Tnzgzoq2hwqrQDM9Rum.Lla4aA0F2I3esTxSkEiD2bm6hbb/eyW	\N	\N	\N	0	\N	\N	\N	\N	pZHxn_c2g_8roj2H5RFA	\N	2025-05-01 11:18:00.794686	\N	0	\N	\N	2025-05-01 11:18:00.794199	2025-05-01 11:18:00.794199
167	tiogrowsunrea1985@yahoo.com	$2a$12$qTJOQU4FAe4VzV6YDF0peeEZqkNuUrnOQrgPR7oVcl3rw8hXqs2/2	\N	\N	\N	0	\N	\N	\N	\N	iD9QM35V12CATSEXK2oU	\N	2025-05-04 00:36:20.864337	\N	0	\N	\N	2025-05-04 00:36:20.863644	2025-05-04 00:36:20.863644
168	ketrinc45@gmail.com	$2a$12$pTIA5LVXtl53PjkMubg/Q.TlwuExUqm2US6i4bWJyPjQA.1JJPTga	\N	\N	\N	0	\N	\N	\N	\N	AEzSrsdd7DCyMFYEvGZc	\N	2025-05-06 00:34:58.543355	\N	0	\N	\N	2025-05-06 00:34:58.543233	2025-05-06 00:34:58.543233
169	jeffersonprincessvd42@gmail.com	$2a$12$oDr5BfqHaKsOm/dZP2XK2eLSBNaGwspaO2mmGhBCYgtxEq6FUYw7m	\N	\N	\N	0	\N	\N	\N	\N	Rb2AnLPQdJUpd3tSCuGP	\N	2025-05-07 03:58:19.470534	\N	0	\N	\N	2025-05-07 03:58:19.470405	2025-05-07 03:58:19.470405
170	stephensonlibbeiy@gmail.com	$2a$12$te5xYEqrOYVrMgL0ypkG5uhXYQ/.HxyLybgRekNd66Qv11.mkfpcC	\N	\N	\N	0	\N	\N	\N	\N	_WWH_VMsyefRVq18RcYY	\N	2025-05-07 05:41:56.407792	\N	0	\N	\N	2025-05-07 05:41:56.407661	2025-05-07 05:41:56.407661
171	bkristabellavt2@gmail.com	$2a$12$A2MKXynQv/KVZt4t0GUBU.NR4SnDH5S/kAyYjKZLuDRy/J3Os3GEC	\N	\N	\N	0	\N	\N	\N	\N	3HC1xyzpyAAc2B1pZs6v	\N	2025-05-07 07:35:44.955774	\N	0	\N	\N	2025-05-07 07:35:44.955619	2025-05-07 07:35:44.955619
172	sidjeberhtml16@gmail.com	$2a$12$yJhN3aIyIxUYafE50v6e.eyXwG2MtS6b6p93C4uXvSHSIH0fXdMri	\N	\N	\N	0	\N	\N	\N	\N	KmarzshHxgRxDeAX5344	\N	2025-05-08 12:54:16.516436	\N	0	\N	\N	2025-05-08 12:54:16.516303	2025-05-08 12:54:16.516303
173	rodgerbrendk45@gmail.com	$2a$12$.jfx8OdNiR/a4aZbXSVLZ.g7Ntl/.bSzDzIdrjMNVbaxRakmGcVhu	\N	\N	\N	0	\N	\N	\N	\N	nrdsTV3LWVgRDkZDfS71	\N	2025-05-09 06:24:27.617796	\N	0	\N	\N	2025-05-09 06:24:27.617642	2025-05-09 06:24:27.617642
174	tcameronux23@gmail.com	$2a$12$xHqhcMyBe9F0duEctg88kOEU2JZXqcHEWxiK9Wnps1Tnhiyh46dGa	\N	\N	\N	0	\N	\N	\N	\N	Ga-JPsTnCdzbAeKTmy1x	\N	2025-05-09 09:55:13.000203	\N	0	\N	\N	2025-05-09 09:55:13.000051	2025-05-09 09:55:13.000051
175	obarreraw@gmail.com	$2a$12$xMTPUT5gCs3oEEyPKHNpEuNP2ys8YNpe9aCSslh7QjAovIcOMnrO.	\N	\N	\N	0	\N	\N	\N	\N	piC-zuJmAsRrHm84sRa9	\N	2025-05-11 16:51:20.809285	\N	0	\N	\N	2025-05-11 16:51:20.809154	2025-05-11 16:51:20.809154
176	brytysp5@gmail.com	$2a$12$gb926fXuk1xfroisGcBWXOD3SDKdwEuJoDgTpQA2HKfHhzcFWrpSi	\N	\N	\N	0	\N	\N	\N	\N	x-EMPqf7Ru3nznKrs2gC	\N	2025-05-14 03:36:34.797644	\N	0	\N	\N	2025-05-14 03:36:34.797461	2025-05-14 03:36:34.797461
177	vmosleymh@gmail.com	$2a$12$9ypKqoPsZP4DSjv5tMhDnu2J5o31VupBjlzEFgTT6fg0mXgZdarf2	\N	\N	\N	0	\N	\N	\N	\N	y5Xs79KyD1LQ4z4xyPbq	\N	2025-05-14 07:43:25.020781	\N	0	\N	\N	2025-05-14 07:43:25.020649	2025-05-14 07:43:25.020649
178	castroshemar660306@yahoo.com	$2a$12$e/wFrlnH4NErI71xWf67ZuAUylaXINpw0fu.t2bbHzTwfLe7US50m	\N	\N	\N	0	\N	\N	\N	\N	xQCnT2W1sAxTWLQZErjh	\N	2025-05-15 11:43:10.421436	\N	0	\N	\N	2025-05-15 11:43:10.421315	2025-05-15 11:43:10.421315
179	ariapatri9@gmail.com	$2a$12$XGXXD0SYWOEEFK5DRkd.I.9GVfDxyzxXAsAeBmbTrYBG.TjAahNXm	\N	\N	\N	0	\N	\N	\N	\N	x2EhTVaU3bTLjrtiso9X	\N	2025-05-15 15:25:24.452418	\N	0	\N	\N	2025-05-15 15:25:24.452266	2025-05-15 15:25:24.452266
180	dhaasmh1998@gmail.com	$2a$12$cjWDKATLWtXUTouhKDyzr.XnvsHqVpj1WGKuTT1/9ktk75iQJm1sy	\N	\N	\N	0	\N	\N	\N	\N	iWxNe1EerfAioGMbNepe	\N	2025-05-15 19:20:23.775736	\N	0	\N	\N	2025-05-15 19:20:23.775618	2025-05-15 19:20:23.775618
181	whitedjif32@gmail.com	$2a$12$qzVLJZMkt7t/NbIpU4VRGO8/SbS/ftJ1frMUPxwZKof1iP57enq8a	\N	\N	\N	0	\N	\N	\N	\N	hHNJwvUXfUHGiQ594KtE	\N	2025-05-16 01:32:26.932651	\N	0	\N	\N	2025-05-16 01:32:26.932529	2025-05-16 01:32:26.932529
182	dschaefery@gmail.com	$2a$12$FBnrPPEK.fBqjPuxn8vVuu87.kFX9K6waDuUne5jqHyAX717k.X4m	83517056b2f384f77c9727bd73c0f05955c5436ffe64d12369074b879f82b763	2025-05-16 06:47:26.550821	\N	0	\N	\N	\N	\N	dJoUFX5AREAa1-BV_DUT	\N	2025-05-16 04:44:53.42066	\N	0	\N	\N	2025-05-16 04:44:53.420529	2025-05-16 06:47:26.553854
183	anabkempu@gmail.com	$2a$12$PH9xwqWkIozTAcyOZOsxaefMVCULDFvS76WE1l5Y25yvTQFuKlZda	\N	\N	\N	0	\N	\N	\N	\N	Cx5dyYPkKKoYCd5icrPA	\N	2025-05-17 03:35:45.138301	\N	0	\N	\N	2025-05-17 03:35:45.138152	2025-05-17 03:35:45.138152
184	manningylissese2005@gmail.com	$2a$12$OZ8zw2kwTG5D3S7GpHYLVubtC2vOguL7FYvJQf3qyXPk9N8Q0XPYO	\N	\N	\N	0	\N	\N	\N	\N	xK8Q6MBGRfcP23T3ahZd	\N	2025-05-17 06:41:46.920416	\N	0	\N	\N	2025-05-17 06:41:46.920282	2025-05-17 06:41:46.920282
185	veidgrantl@gmail.com	$2a$12$ut3t7wKxKlLe0/V9d2qEeeCKcUZC0PtsF8L.HMw2piUoRj8oNV3lS	\N	\N	\N	0	\N	\N	\N	\N	of71DEGwoLbWtMNsx-vp	\N	2025-05-17 08:26:36.650576	\N	0	\N	\N	2025-05-17 08:26:36.650434	2025-05-17 08:26:36.650434
186	simmonsamang9@gmail.com	$2a$12$NUr7x4rW3cNdzpfWE0nMS.JUfV7YsQkqMf17qxvFvzOD1djUO/Xb2	\N	\N	\N	0	\N	\N	\N	\N	WsDeZLT2mNAgYpiME4sa	\N	2025-05-18 21:47:56.194726	\N	0	\N	\N	2025-05-18 21:47:56.194595	2025-05-18 21:47:56.194595
187	hannbuchq50@gmail.com	$2a$12$h/wrfc7HfpV0pdr3p1nVsOU2q/GqmYcnBF/Xk1MNNM35DA1LKFF6O	\N	\N	\N	0	\N	\N	\N	\N	ekV5Z1vC1Xh45cq3xR_D	\N	2025-05-19 02:44:00.859596	\N	0	\N	\N	2025-05-19 02:44:00.859461	2025-05-19 02:44:00.859461
188	scostabk@gmail.com	$2a$12$Oxl9Gyd70Adej9FaRwmoKOdAoUqv1qKpcR7pSCyRRoRByZoGG.b0u	\N	\N	\N	0	\N	\N	\N	\N	UXnwbx6N2wu7zVQ9VgaG	\N	2025-05-19 16:14:11.754019	\N	0	\N	\N	2025-05-19 16:14:11.753789	2025-05-19 16:14:11.753789
189	markleyluis898076@yahoo.com	$2a$12$OHTkHcxgg86.r1WaFE1kqurkjZiKaXzIS.uSXc5S/sPlbVPU7/AlG	\N	\N	\N	0	\N	\N	\N	\N	sW_Qi9B6_3YBhrLhrXPy	\N	2025-05-20 01:43:59.074394	\N	0	\N	\N	2025-05-20 01:43:59.074258	2025-05-20 01:43:59.074258
190	sissigardner71@gmail.com	$2a$12$zZR/ASfR.U5STzhJcegyhewnb8JX8YgZcLtMn0xSeRFBCUaRF3Mcm	\N	\N	\N	0	\N	\N	\N	\N	3X5i-cr1tyPN_Lpt6W2s	\N	2025-05-20 06:37:05.45979	\N	0	\N	\N	2025-05-20 06:37:05.459606	2025-05-20 06:37:05.459606
191	russellbeth800396@yahoo.com	$2a$12$ok8LcX0XvAACinyXwImOkuV6oataodBKu.tNfq8ChqHuHalXTOqtu	\N	\N	\N	0	\N	\N	\N	\N	cuLEnx5gJBRsb5YB1GeT	\N	2025-05-20 10:43:19.321919	\N	0	\N	\N	2025-05-20 10:43:19.32176	2025-05-20 10:43:19.32176
192	richmonddjylyan29@gmail.com	$2a$12$9DxTiW/xsgzOOPAuzMV7WOSg90Kf5.l5c/OHCFMfWNBkks5mckKlC	\N	\N	\N	0	\N	\N	\N	\N	ydYJvJxjjEt5pdMeWLDU	\N	2025-05-20 10:58:20.538715	\N	0	\N	\N	2025-05-20 10:58:20.538528	2025-05-20 10:58:20.538528
193	cheresekwia1987@yahoo.com	$2a$12$pv6mV4HeDo0BLxBiLPKWzOd8c9P10HpOWYYIy/x5Xdkj.4ErV9xRq	\N	\N	\N	0	\N	\N	\N	\N	tUQeEkqRayPLBGkZCUmK	\N	2025-05-20 13:46:39.741015	\N	0	\N	\N	2025-05-20 13:46:39.740847	2025-05-20 13:46:39.740847
194	ortegadenisaf27@gmail.com	$2a$12$8FO4HQmSQP0NFIqphhSr.OVztgqSw2Gr8Cx1btEhJg6JEVCCzO1Cy	\N	\N	\N	0	\N	\N	\N	\N	7Xn-Eh_P4SG87bsUAWhL	\N	2025-05-22 07:58:43.282502	\N	0	\N	\N	2025-05-22 07:58:43.282361	2025-05-22 07:58:43.282361
195	sdonovanrj26@gmail.com	$2a$12$5yKXs4dW2iksb8B2j7kziu951r3TZchALUy1wJcuA2bDQL0wnBXL2	\N	\N	\N	0	\N	\N	\N	\N	H_xxNL3jzmBELs3u5zNg	\N	2025-05-22 10:41:07.234269	\N	0	\N	\N	2025-05-22 10:41:07.234111	2025-05-22 10:41:07.234111
196	belmathjs1989@gmail.com	$2a$12$mIzYFsT7QLtm1Sy3wYLI8Of6h2talcuwKkTizLO7lfcvnkLJ5kpxa	\N	\N	\N	0	\N	\N	\N	\N	3XqQni8ETWfaVCY-LPj1	\N	2025-05-23 23:05:43.717247	\N	0	\N	\N	2025-05-23 23:05:43.717118	2025-05-23 23:05:43.717118
197	shepardkendra6@gmail.com	$2a$12$xc2b5R3nGDjRYVi7SDKpKOaWOqFUJbUff9NrbLQslTogeXcoGU.JK	\N	\N	\N	0	\N	\N	\N	\N	Xyeu7-y-Y5UrAnucFzqk	\N	2025-05-24 03:53:13.039058	\N	0	\N	\N	2025-05-24 03:53:13.038935	2025-05-24 03:53:13.038935
198	tirodufql2@gmail.com	$2a$12$3mkhSz9ItrRTObbYeELu3uIxKVp0L3EFfw8ayPwnQ89C4y7f7Agai	\N	\N	\N	0	\N	\N	\N	\N	879x9L6S8mPPzL8uK-7F	\N	2025-05-25 03:19:23.632401	\N	0	\N	\N	2025-05-25 03:19:23.632229	2025-05-25 03:19:23.632229
199	eoforvdeckut1990@gmail.com	$2a$12$1/8wK9B9BwGzFUfolBweJexk0U8z5inGBx.xmjhYTFWPxWOcq5JhC	\N	\N	\N	0	\N	\N	\N	\N	QWTKMasxRC98n-FoAnYB	\N	2025-05-25 04:10:52.069597	\N	0	\N	\N	2025-05-25 04:10:52.069372	2025-05-25 04:10:52.069372
200	brittanymitchell758242@yahoo.com	$2a$12$sK4bhWTJrVZWXyfLqt5ax.c0yhnkpvBFqRVrn0oAYiIdJTEY8hWie	\N	\N	\N	0	\N	\N	\N	\N	YtPRA1ygTzupb4QShwrq	\N	2025-05-25 12:06:50.989391	\N	0	\N	\N	2025-05-25 12:06:50.989235	2025-05-25 12:06:50.989235
201	mahoneyvrene@gmail.com	$2a$12$sZYr2KhZ2pNbcshc1Sv5H.F0euZqz4XfBNlEte88sqlGkODZ3toee	\N	\N	\N	0	\N	\N	\N	\N	u17scpFUNfh3M-wPsAyh	\N	2025-05-26 04:00:19.636443	\N	0	\N	\N	2025-05-26 04:00:19.636285	2025-05-26 04:00:19.636285
202	reibarryvl32@gmail.com	$2a$12$FLQXH9bVf85rSll3ELXgQOlEoqRLFCCMTeE6AEh7HJrJXM7dukX4i	\N	\N	\N	0	\N	\N	\N	\N	Tf2yj2Cto_jDhXooD4ES	\N	2025-05-26 22:13:24.874719	\N	0	\N	\N	2025-05-26 22:13:24.874577	2025-05-26 22:13:24.874577
203	nyorner44@gmail.com	$2a$12$KPshypvzlgxiBy7R7qepR.G7RwXr5HN.Wyvi24JaAUftWD2Eq6S2K	\N	\N	\N	0	\N	\N	\N	\N	fKAgWEAzjEwGvH3zEYak	\N	2025-05-28 03:30:00.840331	\N	0	\N	\N	2025-05-28 03:30:00.840157	2025-05-28 03:30:00.840157
204	elanorb1991@gmail.com	$2a$12$UsexyFxMiB9lVcARxNhgcu/eCwJwwh4rQahCZR8rMNjWu5096lWYK	\N	\N	\N	0	\N	\N	\N	\N	pZ_zix2z4aWzes4qxFXy	\N	2025-05-28 10:16:38.596021	\N	0	\N	\N	2025-05-28 10:16:38.595849	2025-05-28 10:16:38.595849
205	jeremydecoteau1998@yahoo.com	$2a$12$xNpIFtPV2lOX/v.XQkTS/edKsOmfOTpvMZBuP7ghoHOfDFLhPoWa2	\N	\N	\N	0	\N	\N	\N	\N	z3ESVhJpLwUsE2j-_Uod	\N	2025-05-28 18:54:13.927877	\N	0	\N	\N	2025-05-28 18:54:13.927706	2025-05-28 18:54:13.927706
206	korbinb2006@gmail.com	$2a$12$wp4tTpXI1X9KDAwbG6C4mOfeuJYQZu3/9ZJqYtHIy5gas2cx2QWwS	\N	\N	\N	0	\N	\N	\N	\N	qq2kNLwJqmkrtrdUhjV3	\N	2025-05-28 18:57:47.177027	\N	0	\N	\N	2025-05-28 18:57:47.176828	2025-05-28 18:57:47.176828
207	inglecarol349003@yahoo.com	$2a$12$5eGWj6vn7Go..ZRc0HzmleLe27NJcNuhmEF5Kt47z2d1Cg6qZDaWq	\N	\N	\N	0	\N	\N	\N	\N	krk1xt699Qd6Hr4dyMSa	\N	2025-05-29 09:49:17.205478	\N	0	\N	\N	2025-05-29 09:49:17.205303	2025-05-29 09:49:17.205303
208	plaiammx7@gmail.com	$2a$12$RFADa4fd.BZa7vwJ1nyd/.1vB2PN0YTDrhUhxX6CyDr9h.SVA5vuK	\N	\N	\N	0	\N	\N	\N	\N	hC_nasGkb47sL8T9EeTS	\N	2025-05-30 04:58:14.294105	\N	0	\N	\N	2025-05-30 04:58:14.293883	2025-05-30 04:58:14.293883
209	robrobbinsgb1982@gmail.com	$2a$12$/2rmvRuwTUL29Augxry6geM3cfnW0fOrdC0unbuaMvSkx.IsJB//u	\N	\N	\N	0	\N	\N	\N	\N	UPokrTBC6gDUxa4zX19f	\N	2025-05-30 05:35:49.062794	\N	0	\N	\N	2025-05-30 05:35:49.062626	2025-05-30 05:35:49.062626
210	hobbsamiaswp7@gmail.com	$2a$12$5H/aQEKf6455tiNHJf5Maevo8N7Q63SktP2p0WMvkyzPKOgnJBlx6	\N	\N	\N	0	\N	\N	\N	\N	Mzs3zmxEM8_ziDzsRenB	\N	2025-05-31 07:29:35.384259	\N	0	\N	\N	2025-05-31 07:29:35.384114	2025-05-31 07:29:35.384114
211	staffordzedgb@gmail.com	$2a$12$g1l1NHISmR9jSYMeeEvrqOGTYc5uOVoCkJwS/ddnQlOUNXxvtqLhi	\N	\N	\N	0	\N	\N	\N	\N	uhi7LBNUB4zf-XywA1RV	\N	2025-05-31 09:04:40.451994	\N	0	\N	\N	2025-05-31 09:04:40.451794	2025-05-31 09:04:40.451794
212	leofrollinqv5@gmail.com	$2a$12$bIDTA7ZL.JuMqAhp0rqRteVTPWsrLKLUZvslAyizo2G9DdS4mZwMq	\N	\N	\N	0	\N	\N	\N	\N	cBJye_89TuyaSCR8KxN5	\N	2025-05-31 15:25:59.442205	\N	0	\N	\N	2025-05-31 15:25:59.442062	2025-05-31 15:25:59.442062
213	vilbehays6@gmail.com	$2a$12$yxDqcLkLtKGLhfc.SOG4au7fWnn0nBav3G.u.jbdKu99AVHiM6wly	\N	\N	\N	0	\N	\N	\N	\N	3VszHAuAv4bzf6__inkY	\N	2025-05-31 15:29:34.877677	\N	0	\N	\N	2025-05-31 15:29:34.877553	2025-05-31 15:29:34.877553
214	vinnlinf21@gmail.com	$2a$12$P25XXjnY4ULYRug2p0oZoeLPKVLKs1srqx584Zn58zpSPk6bNtEui	\N	\N	\N	0	\N	\N	\N	\N	7uXsKxPucsztUcZyiGXq	\N	2025-05-31 23:50:01.538995	\N	0	\N	\N	2025-05-31 23:50:01.538756	2025-05-31 23:50:01.538756
215	hanirosnn39@gmail.com	$2a$12$H/6W./Z5nZe/1YGXnK8PpO2HKeWlYef.6VYsoYJ0WOPxmtNf1EtwC	\N	\N	\N	0	\N	\N	\N	\N	EY1EHvDxqwPVA6kXecUQ	\N	2025-06-01 06:03:48.081298	\N	0	\N	\N	2025-06-01 06:03:48.081152	2025-06-01 06:03:48.081152
216	ivorihorn@gmail.com	$2a$12$D2FzD0PSJPGj/unS3HftPOGeRp21dlkd1iqcqD8Sepk6HU/7gRtrK	\N	\N	\N	0	\N	\N	\N	\N	K_U-yAA1UBDZ6dDrfgjy	\N	2025-06-02 23:28:46.773558	\N	0	\N	\N	2025-06-02 23:28:46.77338	2025-06-02 23:28:46.77338
217	darianboltonz17@gmail.com	$2a$12$5JyWqwe2UBgvEpLhtdAVM.slFpsDKb.qe0SNnBISZpAcMvojePs.u	\N	\N	\N	0	\N	\N	\N	\N	DErQ1tDJ4AXaYn7uUzRF	\N	2025-06-03 14:21:37.695445	\N	0	\N	\N	2025-06-03 14:21:37.695317	2025-06-03 14:21:37.695317
218	doloreslanetc25@gmail.com	$2a$12$c8BMhYLNGz3kwaIsxCSQiuBJJS036Sp2ptMayVtfqohYyGCUVKYK2	\N	\N	\N	0	\N	\N	\N	\N	6bTCxnccurWxBThPmeHn	\N	2025-06-04 02:34:32.71177	\N	0	\N	\N	2025-06-04 02:34:32.711576	2025-06-04 02:34:32.711576
219	alexanderlisa913106@yahoo.com	$2a$12$Jju5HJsWuy44t5/D2M.m1u/gXUuqe3hE4ALuDDsKg3MfJZdhjJ/U6	\N	\N	\N	0	\N	\N	\N	\N	YxqJ8bNhza9a1BvsKqnX	\N	2025-06-04 05:30:27.686632	\N	0	\N	\N	2025-06-04 05:30:27.686442	2025-06-04 05:30:27.686442
220	pollarddjoism1994@gmail.com	$2a$12$KaAfCE3yX/bniXohds7MaedDh/X08CZFNufz.NwZ2j58QihT3eWLG	\N	\N	\N	0	\N	\N	\N	\N	2CYEHpqPfvmpLujZhXur	\N	2025-06-04 12:09:21.060283	\N	0	\N	\N	2025-06-04 12:09:21.059708	2025-06-04 12:09:21.059708
221	frenkirobbinv8@gmail.com	$2a$12$a3D1mNTdzgTUyON/zN746.opNe.HY8fYtv18aJefG5xMNqoNQnnhS	\N	\N	\N	0	\N	\N	\N	\N	jTnhzPd3Lfq9BjKTiJVz	\N	2025-06-05 10:08:31.906987	\N	0	\N	\N	2025-06-05 10:08:31.906527	2025-06-05 10:08:31.906527
222	kamibx46@gmail.com	$2a$12$TI6rlEG3ndssxVQX50Ikqewzyk0wyL/UctOx5cAazXMI5uH2UV2GK	\N	\N	\N	0	\N	\N	\N	\N	RseyR3ZyKMFPyukjsjA6	\N	2025-06-06 02:55:29.627332	\N	0	\N	\N	2025-06-06 02:55:29.627138	2025-06-06 02:55:29.627138
223	pabloholstead307049@yahoo.com	$2a$12$RdNOYbrQ4Auybuup.QMWF.UcJJnYyo/jGZzow5N9PUeL8achF6sCi	\N	\N	\N	0	\N	\N	\N	\N	ro6SvrG4_Wz2d8MdM8Yd	\N	2025-06-06 11:25:13.304101	\N	0	\N	\N	2025-06-06 11:25:13.303897	2025-06-06 11:25:13.303897
224	hyntleibrockhp1991@gmail.com	$2a$12$xzr.XstNpLZmy0qdLRtU0.E7/2bdwd.WziYyMnbIJiERQMJzvOTcS	\N	\N	\N	0	\N	\N	\N	\N	UXxnGVhtjRzXoyd7JtF-	\N	2025-06-06 19:29:22.443536	\N	0	\N	\N	2025-06-06 19:29:22.443377	2025-06-06 19:29:22.443377
225	eidenlqj1990@gmail.com	$2a$12$o2REi12cSE3xaYiv345o.u8OW03IUtQhkIS8FHt5zsupIpsZ1bf0G	\N	\N	\N	0	\N	\N	\N	\N	C6618WboJwzzw5BCwmpP	\N	2025-06-07 00:39:36.277488	\N	0	\N	\N	2025-06-07 00:39:36.277341	2025-06-07 00:39:36.277341
226	dyanmuell@gmail.com	$2a$12$aH2APocTMDPzrC8NgHJJluVy.8V6aYZaHh6PV2B3d3KPQ4OsXVv6W	\N	\N	\N	0	\N	\N	\N	\N	MVv2uye61nFyXNbzYT3o	\N	2025-06-07 02:41:25.176166	\N	0	\N	\N	2025-06-07 02:41:25.176054	2025-06-07 02:41:25.176054
227	djobd63@gmail.com	$2a$12$FFFRkgL1gFVtOUyMJjCJs.qqLRzOBCPn8jW5TYOjvPLNJjTI8kbUC	\N	\N	\N	0	\N	\N	\N	\N	emHdyc5TzynapCbZBxLU	\N	2025-06-07 04:13:19.365289	\N	0	\N	\N	2025-06-07 04:13:19.365123	2025-06-07 04:13:19.365123
228	nfilippawo@gmail.com	$2a$12$Jotfjhnm269Qh20GyHI2eeJmqi2vn5mCbQHwT551ovpBrCItv.4C.	\N	\N	\N	0	\N	\N	\N	\N	NyoXHhMLq2BJVFDmo4vy	\N	2025-06-07 07:31:26.292692	\N	0	\N	\N	2025-06-07 07:31:26.2925	2025-06-07 07:31:26.2925
229	ashleymelg8@gmail.com	$2a$12$1bLbJiPHnm42xXMm9ZGBY.rILbfnxOqQnZOzZqOHHplRKY8SBShn.	\N	\N	\N	0	\N	\N	\N	\N	pZ2wJtyW4EY-zLa2WXjz	\N	2025-06-07 07:36:00.561149	\N	0	\N	\N	2025-06-07 07:36:00.560951	2025-06-07 07:36:00.560951
230	robinapacel@gmail.com	$2a$12$xdhPXR7TkzXL1MhYRcBqdeHacSdifNi9j2K3KWtinZHxuhkDvmYRa	\N	\N	\N	0	\N	\N	\N	\N	PwydukTiUW_K6MT-RT7j	\N	2025-06-07 08:01:31.833244	\N	0	\N	\N	2025-06-07 08:01:31.833098	2025-06-07 08:01:31.833098
231	shannchonshe@gmail.com	$2a$12$xQ4MUD.AecEENs/FaxT.guxd1qWGfuksggsPolHChqADU5MjRNxR6	\N	\N	\N	0	\N	\N	\N	\N	pP5iRdLPrPAzxDzUxHyo	\N	2025-06-08 14:40:49.309781	\N	0	\N	\N	2025-06-08 14:40:49.309603	2025-06-08 14:40:49.309603
232	johnsoriano1985@yahoo.com	$2a$12$ES2KwRZhlisBllhrtwhkHeCf9cL/Hr4f9FWVQJdE96A6t1G2XJEmm	\N	\N	\N	0	\N	\N	\N	\N	A-eQdVCMgpgbXBt-4MgP	\N	2025-06-08 18:59:58.392721	\N	0	\N	\N	2025-06-08 18:59:58.392542	2025-06-08 18:59:58.392542
233	sallisalaza44@gmail.com	$2a$12$oaXGzBkjOJIWt5.hhAtd4.dsNDcTJGmD8MXVGeAqtvau/S.E2xPxK	\N	\N	\N	0	\N	\N	\N	\N	8mmuo_zzK3ALWXq6XT1m	\N	2025-06-09 01:27:09.602512	\N	0	\N	\N	2025-06-09 01:27:09.602352	2025-06-09 01:27:09.602352
234	rayenacarneyg3@gmail.com	$2a$12$vYtD10ja5HX09bilLLuuneBhg1uVmTpSpPSFX5KI./evGakImhCny	\N	\N	\N	0	\N	\N	\N	\N	ho9CMkdcoLiQzJ33sbL7	\N	2025-06-09 12:16:48.386677	\N	0	\N	\N	2025-06-09 12:16:48.38653	2025-06-09 12:16:48.38653
235	manningevelainel36@gmail.com	$2a$12$OxyrFhjGIgAv5oYMjGvnPeLPI5IJWXUy0Fa1.Y/2/fAQQGbt4wPku	\N	\N	\N	0	\N	\N	\N	\N	smmiMHADssBzMptCdnuR	\N	2025-06-12 10:33:43.685986	\N	0	\N	\N	2025-06-12 10:33:43.685815	2025-06-12 10:33:43.685815
236	bailibhm@gmail.com	$2a$12$ZHCd3zKbw2tsiQ2LCn88t.kgBZil4za.toh98IkxOEp057IbIykUO	\N	\N	\N	0	\N	\N	\N	\N	wYMNys79xScJsz9zyQrx	\N	2025-06-12 17:30:21.059013	\N	0	\N	\N	2025-06-12 17:30:21.058809	2025-06-12 17:30:21.058809
237	browneiverw8@gmail.com	$2a$12$WGbA0rSlpzpehW0u8xWwlev.InAw632tRDf1eVpnn1egGEAJYYhqC	\N	\N	\N	0	\N	\N	\N	\N	5pAkBf8AtxjvCxYC4Xx2	\N	2025-06-12 22:45:20.809156	\N	0	\N	\N	2025-06-12 22:45:20.808999	2025-06-12 22:45:20.808999
238	elizabethprice530021@yahoo.com	$2a$12$Wr3gNc68VfG8fClxnEM7M.JX/e4U5ovunmOlyUCq61KGVmwK9kz6a	\N	\N	\N	0	\N	\N	\N	\N	d7k71igbKPSZCmE-huzH	\N	2025-06-13 13:56:55.657556	\N	0	\N	\N	2025-06-13 13:56:55.657374	2025-06-13 13:56:55.657374
239	vaughanyankeidd22@gmail.com	$2a$12$OUa6CSoFin87WCiPOrr2SOg7p4MmOjMM8qiWTEEKxZ.V7hCFxQlAO	\N	\N	\N	0	\N	\N	\N	\N	jb5CzU4tzVtR25ApFmsT	\N	2025-06-13 22:59:54.303879	\N	0	\N	\N	2025-06-13 22:59:54.303741	2025-06-13 22:59:54.303741
240	kerrir2002@gmail.com	$2a$12$8RSdKOgvEzt7wqFEFmRf5u8BZWepR.b52SazNF6a9w1Vex4GgXuYS	\N	\N	\N	0	\N	\N	\N	\N	Ma2XXB4sz6kUg44is5U8	\N	2025-06-14 02:11:21.531661	\N	0	\N	\N	2025-06-14 02:11:21.531512	2025-06-14 02:11:21.531512
241	dinacuevasam8@gmail.com	$2a$12$xfigJf5N4/FZUCcCSGDteOiCLqZAIb4Jw4v2QxnkzTej8Dn1BUsCi	\N	\N	\N	0	\N	\N	\N	\N	XV6Cs1yNnzAssUT71g4v	\N	2025-06-14 07:23:59.284461	\N	0	\N	\N	2025-06-14 07:23:59.284284	2025-06-14 07:23:59.284284
242	godfrithahnh8@gmail.com	$2a$12$1MoXozZK2QRZsTUklOExMuBvX6kMwsg1Z9kwiL6WgwWMwCmwVnHJi	\N	\N	\N	0	\N	\N	\N	\N	x8i6PH9QRFvob-dw1Ds1	\N	2025-06-14 12:25:47.926472	\N	0	\N	\N	2025-06-14 12:25:47.926304	2025-06-14 12:25:47.926304
243	adelislove42@gmail.com	$2a$12$.rrZvjid0qM9T1Nbr1FPD.PkBlkiYrP9kWeFKksre4UVHl.gN.Hdy	\N	\N	\N	0	\N	\N	\N	\N	cVis_WuY2xswADvs6fPr	\N	2025-06-16 13:54:30.984624	\N	0	\N	\N	2025-06-16 13:54:30.984477	2025-06-16 13:54:30.984477
244	moirhuertlz45@gmail.com	$2a$12$Mbg0pFWifvY3nuNAGzZqHuDjzYwe1zAu1L1o1P.AjHxxdJBnTBBjm	\N	\N	\N	0	\N	\N	\N	\N	VNHF3GLuz_MAj4Vgyyxn	\N	2025-06-17 06:53:03.044266	\N	0	\N	\N	2025-06-17 06:53:03.044141	2025-06-17 06:53:03.044141
245	pcareypr@gmail.com	$2a$12$RhIZnQOq4ZsTY6/w9FOMQuFlAsw4X9NUQHZJCNtJMxd6FF5RdNAry	\N	\N	\N	0	\N	\N	\N	\N	no8Mvqsd6sqegtNkKMzj	\N	2025-06-17 08:11:01.228046	\N	0	\N	\N	2025-06-17 08:11:01.227698	2025-06-17 08:11:01.227698
246	whitneysmith60458@yahoo.com	$2a$12$45P6k1Mi6d4eYX81EcywlOtBB9q1RTMO3aWYvAUIGbIUMPw9FFMD6	\N	\N	\N	0	\N	\N	\N	\N	BBsf-Vomqxj94zovgxrQ	\N	2025-06-17 12:45:14.158747	\N	0	\N	\N	2025-06-17 12:45:14.158621	2025-06-17 12:45:14.158621
247	mccoyaella@gmail.com	$2a$12$R40hD4EW7eGdlmD9MekaQO.s/f2I8HlGZldfNcVygyjoov2s8OlPm	\N	\N	\N	0	\N	\N	\N	\N	F7-hcYzX8XM2GPmg7-kC	\N	2025-06-17 14:23:10.127795	\N	0	\N	\N	2025-06-17 14:23:10.127657	2025-06-17 14:23:10.127657
248	bschneideran1980@gmail.com	$2a$12$rVZKkyQYG7BunrJPEsnvqOhFKK.mWWXvpCwbXucnNRrEy2lQAiybW	\N	\N	\N	0	\N	\N	\N	\N	x8UPwxYPSU9SBaouARS7	\N	2025-06-18 01:02:37.095059	\N	0	\N	\N	2025-06-18 01:02:37.094672	2025-06-18 01:02:37.094672
249	ellenowatki7@gmail.com	$2a$12$sHvmMNsR6B83xBpGcK/smeHNf4HfPNWCYEGeNPDd3/omnGh74dLLi	\N	\N	\N	0	\N	\N	\N	\N	scPzf1oyY7u_RPDGjVyT	\N	2025-06-18 19:39:29.134072	\N	0	\N	\N	2025-06-18 19:39:29.133929	2025-06-18 19:39:29.133929
250	kfischerew20@gmail.com	$2a$12$DXlBVWpWEBhNvKY6o5aZf.IepCUS3YNQzx6M2MaseDLLConULIphy	\N	\N	\N	0	\N	\N	\N	\N	kQvf9yYs1PzS8XWcYJ5a	\N	2025-06-19 05:14:03.086814	\N	0	\N	\N	2025-06-19 05:14:03.086627	2025-06-19 05:14:03.086627
251	consuelasolis718848@yahoo.com	$2a$12$3cWV8ZYKI1Tly9xXrmTUOu4ocgVqhvaVkfMKhsDYrspJF3aVQjsA2	\N	\N	\N	0	\N	\N	\N	\N	QJfve53aKd_XPpoaVm-8	\N	2025-06-19 09:39:16.156144	\N	0	\N	\N	2025-06-19 09:39:16.156004	2025-06-19 09:39:16.156004
3	mrks.heumann@gmail.com	$2a$12$j661wxxH4mKZDwru8yNWTeYhdfAOII3Wr8pbVvca4iDxbwsmyg6IS	\N	\N	2025-06-19 17:06:20.555525	67	2025-06-19 17:06:20.563672	2025-05-23 19:58:29.19087	172.71.172.206	172.71.126.70	8D_1RBiyGmoczasdtaz9	2024-11-05 15:43:50.263833	2024-11-05 15:38:34.601846	\N	0	\N	\N	2024-11-05 15:38:34.600066	2025-06-19 17:06:20.565133
\.


--
-- Data for Name: visit_contacts; Type: TABLE DATA; Schema: public; Owner: bentobook
--

COPY public.visit_contacts (id, visit_id, contact_id, created_at, updated_at) FROM stdin;
1	1	2	2024-11-28 12:16:19.495245	2024-11-28 12:16:19.495245
2	2	2	2024-11-28 13:16:40.318436	2024-11-28 13:16:40.318436
3	3	2	2024-12-02 15:59:15.65277	2024-12-02 15:59:15.65277
4	3	3	2024-12-02 15:59:15.657212	2024-12-02 15:59:15.657212
5	3	4	2024-12-02 15:59:15.660275	2024-12-02 15:59:15.660275
6	4	2	2024-12-16 12:06:57.251447	2024-12-16 12:06:57.251447
7	5	2	2024-12-17 22:35:07.760329	2024-12-17 22:35:07.760329
8	5	3	2024-12-17 22:35:07.769666	2024-12-17 22:35:07.769666
9	5	4	2024-12-17 22:35:07.771766	2024-12-17 22:35:07.771766
10	6	5	2025-02-10 18:04:16.941938	2025-02-10 18:04:16.941938
11	7	6	2025-02-10 18:06:03.108424	2025-02-10 18:06:03.108424
12	8	5	2025-02-10 18:07:46.91834	2025-02-10 18:07:46.91834
13	8	6	2025-02-10 18:07:46.920759	2025-02-10 18:07:46.920759
14	9	2	2025-02-12 12:16:27.104525	2025-02-12 12:16:27.104525
15	9	7	2025-02-12 12:16:27.108386	2025-02-12 12:16:27.108386
16	10	2	2025-03-16 14:16:19.341808	2025-03-16 14:16:19.341808
18	10	10	2025-03-19 15:37:23.66064	2025-03-19 15:37:23.66064
19	11	1	2025-03-20 17:25:41.761294	2025-03-20 17:25:41.761294
20	11	11	2025-03-20 17:28:38.312774	2025-03-20 17:28:38.312774
21	12	2	2025-03-21 08:30:01.019282	2025-03-21 08:30:01.019282
22	12	8	2025-03-21 08:30:11.736604	2025-03-21 08:30:11.736604
23	12	9	2025-03-21 08:30:13.869434	2025-03-21 08:30:13.869434
24	15	2	2025-03-27 09:29:47.588007	2025-03-27 09:29:47.588007
25	16	1	2025-03-28 08:53:34.060827	2025-03-28 08:53:34.060827
26	11	12	2025-03-28 09:00:51.885393	2025-03-28 09:00:51.885393
\.


--
-- Data for Name: visits; Type: TABLE DATA; Schema: public; Owner: bentobook
--

COPY public.visits (id, date, title, notes, user_id, restaurant_id, rating, price_paid_cents, price_paid_currency, created_at, updated_at, time_of_day) FROM stdin;
2	2024-11-26	Midi	Kinkhali au Bœuf, Pkhali, demi Khachapuri. Pkhali intéressant mais pas forcement à reprendre, Khachapuri une sort de pain gratiné au fromage. Kinkhali top, suffisant pour un repas... pour la prochaine fois. 	3	19	3	\N	EUR	2024-11-28 13:16:40.311226	2024-11-28 13:17:07.838081	12:00:00
1	2024-11-28	Midi après Tai-Chi et marché	16€ entrée / plat. Gésier de canard pour moi et St Jacques sur lit de poireaux pour Maryse, Blanquette de veau pour nous deux. Entrées très bon, la Blanquette copieux mais un peu commun. Même déco sur tout les plats. Trop bruyant pour mon goût... 	3	18	2	3200	EUR	2024-11-28 12:16:19.483931	2024-11-28 15:59:04.031086	12:00:00
3	2024-12-02	La Première	Pas vraiment la première fois... mais la première entrée ici... Éric M nous a rejoint pour un verre, sinon comme d'habitude.	3	20	3	7000	EUR	2024-12-02 15:59:15.641003	2024-12-02 21:31:49.72284	12:00:00
4	2024-12-16	Great	Raviolis porc et ciboulette dans bouillon de pieds de porc pour moi, raviolis poulet + crevettes (qui se sont transformés en raviolis crevettes après la commande : serveur inepte) dans bouillon claire pour Maryse. Beaucoup de monde, on a fait la queue...	3	23	3	3000	EUR	2024-12-16 12:06:57.239846	2024-12-16 13:56:08.719803	12:00:00
5	2024-12-17		Grande Mixte, émiettés de haddock, émiettés de maquereaux, assiette de radis. Bière avant mon arrivé, Papi, Duché d'Uzes. 	3	20	3	9600	EUR	2024-12-17 22:35:07.741358	2024-12-17 22:37:55.169003	12:00:00
6	2025-01-10	First time	it was fine. reasonably hip place in a not so hip neighborhood 	95	44	4	3200	EUR	2025-02-10 18:04:16.932964	2025-02-10 18:04:16.932964	12:00:00
7	2025-01-27		So nice. Real contemporary piemontese food. Great wine cellar also.	95	46	5	9000	EUR	2025-02-10 18:06:03.105876	2025-02-10 18:06:03.105876	12:00:00
8	2025-02-05	Fun evening	Great bar. Closes at 10pm, so you can stay till the end AND go to bet at a reasonable time... perfect.	95	45	\N	5900	EUR	2025-02-10 18:07:46.914303	2025-02-10 18:07:46.914303	12:00:00
9	2025-02-12		Moi Œufs mayonnaise et Bœuf bourguignon, Maryse Crevettes mayonnaise et Poulet frites, Evan onglet de Bœuf et Poire Hélène . Une carafe de Ventoux à boire.	3	48	2	7000	EUR	2025-02-12 12:16:27.096076	2025-02-12 13:34:30.455578	12:00:00
10	2025-03-16		Brioches Shanghaiennes au poulet à la citronnlle, Brioche au porc laqué, Riz gluant rouge au porc (pas mal mais pas reprendre), Brioches Shanghaiennes au porc Tom Yam, Poulet sauté aux champignons noirs, salade de concombre	3	65	3	4800	EUR	2025-03-16 14:16:19.331478	2025-03-20 21:09:17.618464	12:00:00
12	2025-03-16	\N	Escargots en Persillade, finger de tête de veau, poireaux vinaigrette, huîtres, rémoulade morteau pour Quentin et Isabelle, Œuf mayo et tartare de bœuf pour moi, végé du moment (purée du potimarron, chanterelles, shiitake, crumble au comté etc) pour Maryse. 	3	67	3	13750	USD	2025-03-21 08:29:47.772552	2025-03-21 08:30:57.540621	19:00:00
15	2025-03-26		2 bavettes, brioche perdu, carafe de Languedoc Roussillon 	3	68	2	5490	USD	2025-03-27 09:28:58.761035	2025-03-27 09:30:30.80773	20:00:00
16	2025-03-27	Dîner d’anniversaire 52	\N	12	69	4	10000	USD	2025-03-28 08:53:17.047744	2025-03-28 08:56:33.1517	20:00:00
11	2025-03-16	\N	Soirée avec Quentin et Isabelle	12	66	4	\N	\N	2025-03-20 17:25:25.312781	2025-03-28 08:57:23.93271	19:00:00
13	2025-02-13	\N	\N	12	2	4	\N	\N	2025-03-24 10:32:08.272382	2025-03-28 09:01:23.579151	12:30:00
17	2022-07-28	\N	\N	12	138	3	\N	\N	2025-04-28 13:14:06.624265	2025-04-28 13:14:17.569282	19:15:00
\.


--
-- Data for Name: geocode_settings; Type: TABLE DATA; Schema: tiger; Owner: bentobook
--

COPY tiger.geocode_settings (name, setting, unit, category, short_desc) FROM stdin;
\.


--
-- Data for Name: pagc_gaz; Type: TABLE DATA; Schema: tiger; Owner: bentobook
--

COPY tiger.pagc_gaz (id, seq, word, stdword, token, is_custom) FROM stdin;
\.


--
-- Data for Name: pagc_lex; Type: TABLE DATA; Schema: tiger; Owner: bentobook
--

COPY tiger.pagc_lex (id, seq, word, stdword, token, is_custom) FROM stdin;
\.


--
-- Data for Name: pagc_rules; Type: TABLE DATA; Schema: tiger; Owner: bentobook
--

COPY tiger.pagc_rules (id, rule, is_custom) FROM stdin;
\.


--
-- Data for Name: topology; Type: TABLE DATA; Schema: topology; Owner: bentobook
--

COPY topology.topology (id, name, srid, "precision", hasz) FROM stdin;
\.


--
-- Data for Name: layer; Type: TABLE DATA; Schema: topology; Owner: bentobook
--

COPY topology.layer (topology_id, layer_id, schema_name, table_name, feature_column, feature_type, level, child_id) FROM stdin;
\.


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bentobook
--

SELECT pg_catalog.setval('public.active_storage_attachments_id_seq', 276, true);


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bentobook
--

SELECT pg_catalog.setval('public.active_storage_blobs_id_seq', 281, true);


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bentobook
--

SELECT pg_catalog.setval('public.active_storage_variant_records_id_seq', 224, true);


--
-- Name: contacts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bentobook
--

SELECT pg_catalog.setval('public.contacts_id_seq', 12, true);


--
-- Name: cuisine_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bentobook
--

SELECT pg_catalog.setval('public.cuisine_types_id_seq', 43, true);


--
-- Name: google_restaurants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bentobook
--

SELECT pg_catalog.setval('public.google_restaurants_id_seq', 144, true);


--
-- Name: images_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bentobook
--

SELECT pg_catalog.setval('public.images_id_seq', 34, true);


--
-- Name: list_restaurants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bentobook
--

SELECT pg_catalog.setval('public.list_restaurants_id_seq', 1, false);


--
-- Name: lists_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bentobook
--

SELECT pg_catalog.setval('public.lists_id_seq', 1, false);


--
-- Name: memberships_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bentobook
--

SELECT pg_catalog.setval('public.memberships_id_seq', 132, true);


--
-- Name: organizations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bentobook
--

SELECT pg_catalog.setval('public.organizations_id_seq', 135, false);


--
-- Name: pg_search_documents_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bentobook
--

SELECT pg_catalog.setval('public.pg_search_documents_id_seq', 1, false);


--
-- Name: profiles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bentobook
--

SELECT pg_catalog.setval('public.profiles_id_seq', 251, true);


--
-- Name: restaurant_copies_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bentobook
--

SELECT pg_catalog.setval('public.restaurant_copies_id_seq', 1, false);


--
-- Name: restaurants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bentobook
--

SELECT pg_catalog.setval('public.restaurants_id_seq', 152, true);


--
-- Name: shares_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bentobook
--

SELECT pg_catalog.setval('public.shares_id_seq', 1, false);


--
-- Name: taggings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bentobook
--

SELECT pg_catalog.setval('public.taggings_id_seq', 41, true);


--
-- Name: tags_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bentobook
--

SELECT pg_catalog.setval('public.tags_id_seq', 13, true);


--
-- Name: user_sessions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bentobook
--

SELECT pg_catalog.setval('public.user_sessions_id_seq', 57, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bentobook
--

SELECT pg_catalog.setval('public.users_id_seq', 251, true);


--
-- Name: visit_contacts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bentobook
--

SELECT pg_catalog.setval('public.visit_contacts_id_seq', 26, true);


--
-- Name: visits_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bentobook
--

SELECT pg_catalog.setval('public.visits_id_seq', 17, true);


--
-- Name: topology_id_seq; Type: SEQUENCE SET; Schema: topology; Owner: bentobook
--

SELECT pg_catalog.setval('topology.topology_id_seq', 1, false);


--
-- Name: active_storage_attachments active_storage_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT active_storage_attachments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_blobs active_storage_blobs_pkey; Type: CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.active_storage_blobs
    ADD CONSTRAINT active_storage_blobs_pkey PRIMARY KEY (id);


--
-- Name: active_storage_variant_records active_storage_variant_records_pkey; Type: CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT active_storage_variant_records_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: contacts contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_pkey PRIMARY KEY (id);


--
-- Name: cuisine_types cuisine_types_pkey; Type: CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.cuisine_types
    ADD CONSTRAINT cuisine_types_pkey PRIMARY KEY (id);


--
-- Name: google_restaurants google_restaurants_pkey; Type: CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.google_restaurants
    ADD CONSTRAINT google_restaurants_pkey PRIMARY KEY (id);


--
-- Name: images images_pkey; Type: CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.images
    ADD CONSTRAINT images_pkey PRIMARY KEY (id);


--
-- Name: list_restaurants list_restaurants_pkey; Type: CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.list_restaurants
    ADD CONSTRAINT list_restaurants_pkey PRIMARY KEY (id);


--
-- Name: lists lists_pkey; Type: CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.lists
    ADD CONSTRAINT lists_pkey PRIMARY KEY (id);


--
-- Name: memberships memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.memberships
    ADD CONSTRAINT memberships_pkey PRIMARY KEY (id);


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: pg_search_documents pg_search_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.pg_search_documents
    ADD CONSTRAINT pg_search_documents_pkey PRIMARY KEY (id);


--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- Name: restaurant_copies restaurant_copies_pkey; Type: CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.restaurant_copies
    ADD CONSTRAINT restaurant_copies_pkey PRIMARY KEY (id);


--
-- Name: restaurants restaurants_pkey; Type: CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.restaurants
    ADD CONSTRAINT restaurants_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: shares shares_pkey; Type: CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.shares
    ADD CONSTRAINT shares_pkey PRIMARY KEY (id);


--
-- Name: taggings taggings_pkey; Type: CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.taggings
    ADD CONSTRAINT taggings_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: user_sessions user_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.user_sessions
    ADD CONSTRAINT user_sessions_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: visit_contacts visit_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.visit_contacts
    ADD CONSTRAINT visit_contacts_pkey PRIMARY KEY (id);


--
-- Name: visits visits_pkey; Type: CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.visits
    ADD CONSTRAINT visits_pkey PRIMARY KEY (id);


--
-- Name: index_active_storage_attachments_on_blob_id; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_active_storage_attachments_on_blob_id ON public.active_storage_attachments USING btree (blob_id);


--
-- Name: index_active_storage_attachments_uniqueness; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE UNIQUE INDEX index_active_storage_attachments_uniqueness ON public.active_storage_attachments USING btree (record_type, record_id, name, blob_id);


--
-- Name: index_active_storage_blobs_on_key; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE UNIQUE INDEX index_active_storage_blobs_on_key ON public.active_storage_blobs USING btree (key);


--
-- Name: index_active_storage_variant_records_uniqueness; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE UNIQUE INDEX index_active_storage_variant_records_uniqueness ON public.active_storage_variant_records USING btree (blob_id, variation_digest);


--
-- Name: index_contacts_on_user_id; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_contacts_on_user_id ON public.contacts USING btree (user_id);


--
-- Name: index_cuisine_types_on_name; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE UNIQUE INDEX index_cuisine_types_on_name ON public.cuisine_types USING btree (name);


--
-- Name: index_google_restaurants_on_address; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_google_restaurants_on_address ON public.google_restaurants USING btree (address);


--
-- Name: index_google_restaurants_on_city; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_google_restaurants_on_city ON public.google_restaurants USING btree (city);


--
-- Name: index_google_restaurants_on_google_place_id; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE UNIQUE INDEX index_google_restaurants_on_google_place_id ON public.google_restaurants USING btree (google_place_id);


--
-- Name: index_google_restaurants_on_id; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_google_restaurants_on_id ON public.google_restaurants USING btree (id);


--
-- Name: index_google_restaurants_on_location; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_google_restaurants_on_location ON public.google_restaurants USING gist (location);


--
-- Name: index_google_restaurants_on_name; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_google_restaurants_on_name ON public.google_restaurants USING btree (name);


--
-- Name: index_images_on_imageable; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_images_on_imageable ON public.images USING btree (imageable_type, imageable_id);


--
-- Name: index_list_restaurants_on_list_id; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_list_restaurants_on_list_id ON public.list_restaurants USING btree (list_id);


--
-- Name: index_list_restaurants_on_list_id_and_restaurant_id; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE UNIQUE INDEX index_list_restaurants_on_list_id_and_restaurant_id ON public.list_restaurants USING btree (list_id, restaurant_id);


--
-- Name: index_list_restaurants_on_restaurant_id; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_list_restaurants_on_restaurant_id ON public.list_restaurants USING btree (restaurant_id);


--
-- Name: index_lists_on_owner; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_lists_on_owner ON public.lists USING btree (owner_type, owner_id);


--
-- Name: index_lists_on_owner_type_and_owner_id; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_lists_on_owner_type_and_owner_id ON public.lists USING btree (owner_type, owner_id);


--
-- Name: index_memberships_on_organization_id; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_memberships_on_organization_id ON public.memberships USING btree (organization_id);


--
-- Name: index_memberships_on_user_id; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_memberships_on_user_id ON public.memberships USING btree (user_id);


--
-- Name: index_pg_search_documents_on_searchable; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_pg_search_documents_on_searchable ON public.pg_search_documents USING btree (searchable_type, searchable_id);


--
-- Name: index_profiles_on_user_id; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_profiles_on_user_id ON public.profiles USING btree (user_id);


--
-- Name: index_restaurant_copies_on_copied_restaurant_id; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_restaurant_copies_on_copied_restaurant_id ON public.restaurant_copies USING btree (copied_restaurant_id);


--
-- Name: index_restaurant_copies_on_restaurant_id; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_restaurant_copies_on_restaurant_id ON public.restaurant_copies USING btree (restaurant_id);


--
-- Name: index_restaurant_copies_on_user_id; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_restaurant_copies_on_user_id ON public.restaurant_copies USING btree (user_id);


--
-- Name: index_restaurant_copies_on_user_id_and_restaurant_id; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE UNIQUE INDEX index_restaurant_copies_on_user_id_and_restaurant_id ON public.restaurant_copies USING btree (user_id, restaurant_id);


--
-- Name: index_restaurants_on_address; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_restaurants_on_address ON public.restaurants USING btree (address);


--
-- Name: index_restaurants_on_city; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_restaurants_on_city ON public.restaurants USING btree (city);


--
-- Name: index_restaurants_on_cuisine_type_id; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_restaurants_on_cuisine_type_id ON public.restaurants USING btree (cuisine_type_id);


--
-- Name: index_restaurants_on_favorite; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_restaurants_on_favorite ON public.restaurants USING btree (favorite);


--
-- Name: index_restaurants_on_google_restaurant_id; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_restaurants_on_google_restaurant_id ON public.restaurants USING btree (google_restaurant_id);


--
-- Name: index_restaurants_on_name; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_restaurants_on_name ON public.restaurants USING btree (name);


--
-- Name: index_restaurants_on_notes; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_restaurants_on_notes ON public.restaurants USING btree (notes);


--
-- Name: index_restaurants_on_original_restaurant_id; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_restaurants_on_original_restaurant_id ON public.restaurants USING btree (original_restaurant_id);


--
-- Name: index_restaurants_on_user_id; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_restaurants_on_user_id ON public.restaurants USING btree (user_id);


--
-- Name: index_restaurants_on_user_id_and_google_restaurant_id; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE UNIQUE INDEX index_restaurants_on_user_id_and_google_restaurant_id ON public.restaurants USING btree (user_id, google_restaurant_id);


--
-- Name: index_shares_on_creator_id; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_shares_on_creator_id ON public.shares USING btree (creator_id);


--
-- Name: index_shares_on_recipient_id; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_shares_on_recipient_id ON public.shares USING btree (recipient_id);


--
-- Name: index_shares_on_shareable; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_shares_on_shareable ON public.shares USING btree (shareable_type, shareable_id);


--
-- Name: index_shares_uniqueness; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE UNIQUE INDEX index_shares_uniqueness ON public.shares USING btree (creator_id, recipient_id, shareable_type, shareable_id);


--
-- Name: index_taggings_on_context; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_taggings_on_context ON public.taggings USING btree (context);


--
-- Name: index_taggings_on_tag_id; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_taggings_on_tag_id ON public.taggings USING btree (tag_id);


--
-- Name: index_taggings_on_taggable_id; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_taggings_on_taggable_id ON public.taggings USING btree (taggable_id);


--
-- Name: index_taggings_on_taggable_type; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_taggings_on_taggable_type ON public.taggings USING btree (taggable_type);


--
-- Name: index_taggings_on_taggable_type_and_taggable_id; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_taggings_on_taggable_type_and_taggable_id ON public.taggings USING btree (taggable_type, taggable_id);


--
-- Name: index_taggings_on_tagger_id; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_taggings_on_tagger_id ON public.taggings USING btree (tagger_id);


--
-- Name: index_taggings_on_tagger_id_and_tagger_type; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_taggings_on_tagger_id_and_tagger_type ON public.taggings USING btree (tagger_id, tagger_type);


--
-- Name: index_taggings_on_tagger_type_and_tagger_id; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_taggings_on_tagger_type_and_tagger_id ON public.taggings USING btree (tagger_type, tagger_id);


--
-- Name: index_taggings_on_tenant; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_taggings_on_tenant ON public.taggings USING btree (tenant);


--
-- Name: index_tags_on_name; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE UNIQUE INDEX index_tags_on_name ON public.tags USING btree (name);


--
-- Name: index_user_sessions_on_active; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_user_sessions_on_active ON public.user_sessions USING btree (active);


--
-- Name: index_user_sessions_on_device_type; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_user_sessions_on_device_type ON public.user_sessions USING btree (device_type);


--
-- Name: index_user_sessions_on_jti; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE UNIQUE INDEX index_user_sessions_on_jti ON public.user_sessions USING btree (jti);


--
-- Name: index_user_sessions_on_last_used_at; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_user_sessions_on_last_used_at ON public.user_sessions USING btree (last_used_at);


--
-- Name: index_user_sessions_on_suspicious; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_user_sessions_on_suspicious ON public.user_sessions USING btree (suspicious);


--
-- Name: index_user_sessions_on_user_id; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_user_sessions_on_user_id ON public.user_sessions USING btree (user_id);


--
-- Name: index_user_sessions_on_user_id_and_client_name; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_user_sessions_on_user_id_and_client_name ON public.user_sessions USING btree (user_id, client_name);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON public.users USING btree (confirmation_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: index_users_on_unlock_token; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE UNIQUE INDEX index_users_on_unlock_token ON public.users USING btree (unlock_token);


--
-- Name: index_visit_contacts_on_contact_id; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_visit_contacts_on_contact_id ON public.visit_contacts USING btree (contact_id);


--
-- Name: index_visit_contacts_on_visit_id; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_visit_contacts_on_visit_id ON public.visit_contacts USING btree (visit_id);


--
-- Name: index_visits_on_restaurant_id; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_visits_on_restaurant_id ON public.visits USING btree (restaurant_id);


--
-- Name: index_visits_on_user_id; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX index_visits_on_user_id ON public.visits USING btree (user_id);


--
-- Name: taggings_idx; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE UNIQUE INDEX taggings_idx ON public.taggings USING btree (tag_id, taggable_id, taggable_type, context, tagger_id, tagger_type);


--
-- Name: taggings_idy; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX taggings_idy ON public.taggings USING btree (taggable_id, taggable_type, tagger_id, context);


--
-- Name: taggings_taggable_context_idx; Type: INDEX; Schema: public; Owner: bentobook
--

CREATE INDEX taggings_taggable_context_idx ON public.taggings USING btree (taggable_id, taggable_type, context);


--
-- Name: list_restaurants fk_list_restaurants_list; Type: FK CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.list_restaurants
    ADD CONSTRAINT fk_list_restaurants_list FOREIGN KEY (list_id) REFERENCES public.lists(id) ON DELETE CASCADE;


--
-- Name: list_restaurants fk_list_restaurants_restaurant; Type: FK CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.list_restaurants
    ADD CONSTRAINT fk_list_restaurants_restaurant FOREIGN KEY (restaurant_id) REFERENCES public.restaurants(id) ON DELETE CASCADE;


--
-- Name: visits fk_rails_09e5e7c20b; Type: FK CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.visits
    ADD CONSTRAINT fk_rails_09e5e7c20b FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: restaurant_copies fk_rails_0ee957d258; Type: FK CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.restaurant_copies
    ADD CONSTRAINT fk_rails_0ee957d258 FOREIGN KEY (copied_restaurant_id) REFERENCES public.restaurants(id);


--
-- Name: restaurant_copies fk_rails_3ea502fa9a; Type: FK CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.restaurant_copies
    ADD CONSTRAINT fk_rails_3ea502fa9a FOREIGN KEY (restaurant_id) REFERENCES public.restaurants(id);


--
-- Name: shares fk_rails_5d388a8a85; Type: FK CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.shares
    ADD CONSTRAINT fk_rails_5d388a8a85 FOREIGN KEY (creator_id) REFERENCES public.users(id);


--
-- Name: memberships fk_rails_64267aab58; Type: FK CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.memberships
    ADD CONSTRAINT fk_rails_64267aab58 FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: restaurants fk_rails_6459e3b9d7; Type: FK CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.restaurants
    ADD CONSTRAINT fk_rails_6459e3b9d7 FOREIGN KEY (google_restaurant_id) REFERENCES public.google_restaurants(id);


--
-- Name: contacts fk_rails_8d2134e55e; Type: FK CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT fk_rails_8d2134e55e FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: memberships fk_rails_99326fb65d; Type: FK CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.memberships
    ADD CONSTRAINT fk_rails_99326fb65d FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: active_storage_variant_records fk_rails_993965df05; Type: FK CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT fk_rails_993965df05 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: restaurant_copies fk_rails_9d4e535f93; Type: FK CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.restaurant_copies
    ADD CONSTRAINT fk_rails_9d4e535f93 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: user_sessions fk_rails_9fa262d742; Type: FK CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.user_sessions
    ADD CONSTRAINT fk_rails_9fa262d742 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: taggings fk_rails_9fcd2e236b; Type: FK CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.taggings
    ADD CONSTRAINT fk_rails_9fcd2e236b FOREIGN KEY (tag_id) REFERENCES public.tags(id);


--
-- Name: visits fk_rails_9feab3f441; Type: FK CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.visits
    ADD CONSTRAINT fk_rails_9feab3f441 FOREIGN KEY (restaurant_id) REFERENCES public.restaurants(id);


--
-- Name: restaurants fk_rails_aef57e41ec; Type: FK CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.restaurants
    ADD CONSTRAINT fk_rails_aef57e41ec FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: visit_contacts fk_rails_b4070a404c; Type: FK CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.visit_contacts
    ADD CONSTRAINT fk_rails_b4070a404c FOREIGN KEY (contact_id) REFERENCES public.contacts(id);


--
-- Name: restaurants fk_rails_c2e9970bf8; Type: FK CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.restaurants
    ADD CONSTRAINT fk_rails_c2e9970bf8 FOREIGN KEY (cuisine_type_id) REFERENCES public.cuisine_types(id);


--
-- Name: shares fk_rails_c36b56cf51; Type: FK CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.shares
    ADD CONSTRAINT fk_rails_c36b56cf51 FOREIGN KEY (recipient_id) REFERENCES public.users(id);


--
-- Name: active_storage_attachments fk_rails_c3b3935057; Type: FK CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT fk_rails_c3b3935057 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: list_restaurants fk_rails_c63a738d79; Type: FK CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.list_restaurants
    ADD CONSTRAINT fk_rails_c63a738d79 FOREIGN KEY (restaurant_id) REFERENCES public.restaurants(id);


--
-- Name: restaurants fk_rails_cd30f1f5a1; Type: FK CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.restaurants
    ADD CONSTRAINT fk_rails_cd30f1f5a1 FOREIGN KEY (original_restaurant_id) REFERENCES public.restaurants(id);


--
-- Name: profiles fk_rails_e424190865; Type: FK CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT fk_rails_e424190865 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: list_restaurants fk_rails_e68366fbf6; Type: FK CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.list_restaurants
    ADD CONSTRAINT fk_rails_e68366fbf6 FOREIGN KEY (list_id) REFERENCES public.lists(id);


--
-- Name: visit_contacts fk_rails_f5c4153bfb; Type: FK CONSTRAINT; Schema: public; Owner: bentobook
--

ALTER TABLE ONLY public.visit_contacts
    ADD CONSTRAINT fk_rails_f5c4153bfb FOREIGN KEY (visit_id) REFERENCES public.visits(id);


--
-- PostgreSQL database dump complete
--

