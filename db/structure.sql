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
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: membership_role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.membership_role AS ENUM (
    'guest',
    'viewer',
    'author',
    'editor',
    'admin',
    'owner'
);


--
-- Name: representation_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.representation_status AS ENUM (
    'ready_to_review',
    'approved',
    'not_approved'
);


--
-- Name: resource_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.resource_status AS ENUM (
    'active',
    'archived',
    'deleted',
    'not_found',
    'unexpected_response'
);


--
-- Name: resource_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.resource_type AS ENUM (
    'collection',
    'dataset',
    'event',
    'image',
    'interactive_resource',
    'moving_image',
    'physical_object',
    'service',
    'software',
    'sound',
    'still_image',
    'text'
);


--
-- Name: reset_sequence(text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.reset_sequence(tablename text, columnname text, sequence_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
        DECLARE
        BEGIN
        EXECUTE 'SELECT setval( ''' || sequence_name  || ''', ' || '(SELECT MAX(' || columnname || ') FROM ' || tablename || ')' || '+1)';
        END;

      $$;


SET default_tablespace = '';

--
-- Name: active_storage_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_attachments (
    id bigint NOT NULL,
    name character varying NOT NULL,
    record_type character varying NOT NULL,
    record_id bigint NOT NULL,
    blob_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL
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
    byte_size bigint NOT NULL,
    checksum character varying NOT NULL,
    created_at timestamp without time zone NOT NULL
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
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: assignments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assignments (
    id integer NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    resource_id integer NOT NULL,
    status integer DEFAULT 0 NOT NULL
);


--
-- Name: assignments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.assignments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: assignments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.assignments_id_seq OWNED BY public.assignments.id;


--
-- Name: audits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audits (
    id integer NOT NULL,
    auditable_id integer NOT NULL,
    auditable_type character varying NOT NULL,
    associated_id integer,
    associated_type character varying,
    user_id integer,
    user_type character varying,
    username character varying DEFAULT 'Unknown'::character varying NOT NULL,
    action character varying NOT NULL,
    audited_changes jsonb,
    version integer DEFAULT 0 NOT NULL,
    comment character varying,
    remote_address character varying,
    request_uuid character varying,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: audits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.audits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: audits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.audits_id_seq OWNED BY public.audits.id;


--
-- Name: auth_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auth_tokens (
    id bigint NOT NULL,
    user_id bigint,
    token character varying,
    user_agent character varying,
    expires_at timestamp without time zone NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: auth_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.auth_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: auth_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.auth_tokens_id_seq OWNED BY public.auth_tokens.id;


--
-- Name: imports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.imports (
    id bigint NOT NULL,
    organization_id bigint,
    user_id bigint,
    sheet_mappings json,
    status integer DEFAULT 0 NOT NULL,
    successes integer DEFAULT 0 NOT NULL,
    failures integer DEFAULT 0 NOT NULL,
    new_records integer DEFAULT 0 NOT NULL,
    duplicate_records integer DEFAULT 0 NOT NULL,
    changed_records integer DEFAULT 0 NOT NULL,
    error character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: imports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.imports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: imports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.imports_id_seq OWNED BY public.imports.id;


--
-- Name: invitations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invitations (
    id bigint NOT NULL,
    recipient_email public.citext NOT NULL,
    token public.citext NOT NULL,
    sender_user_id bigint NOT NULL,
    recipient_user_id bigint NOT NULL,
    organization_id bigint NOT NULL,
    redeemed_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    role public.membership_role DEFAULT 'viewer'::public.membership_role NOT NULL
);


--
-- Name: invitations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.invitations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invitations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.invitations_id_seq OWNED BY public.invitations.id;


--
-- Name: licenses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.licenses (
    id bigint NOT NULL,
    name public.citext NOT NULL,
    description character varying NOT NULL,
    url public.citext NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: licenses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.licenses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: licenses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.licenses_id_seq OWNED BY public.licenses.id;


--
-- Name: memberships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.memberships (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    organization_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    role public.membership_role DEFAULT 'guest'::public.membership_role NOT NULL,
    active boolean DEFAULT true
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
-- Name: meta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.meta (
    id integer NOT NULL,
    name public.citext NOT NULL,
    instructions text DEFAULT ''::text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    organization_id bigint NOT NULL,
    is_required boolean DEFAULT false NOT NULL
);


--
-- Name: meta_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.meta_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: meta_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.meta_id_seq OWNED BY public.meta.id;


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organizations (
    id integer NOT NULL,
    name public.citext NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    default_license_id integer NOT NULL,
    is_deleted boolean DEFAULT false,
    footer character varying,
    allow_authors_to_claim_resources boolean DEFAULT false NOT NULL
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
-- Name: password_resets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.password_resets (
    id bigint NOT NULL,
    user_id bigint,
    token character varying NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: password_resets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.password_resets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: password_resets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.password_resets_id_seq OWNED BY public.password_resets.id;


--
-- Name: representation_rejections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.representation_rejections (
    id bigint NOT NULL,
    representation_id bigint,
    user_id bigint,
    reason text NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: representation_rejections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.representation_rejections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: representation_rejections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.representation_rejections_id_seq OWNED BY public.representation_rejections.id;


--
-- Name: representations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.representations (
    id bigint NOT NULL,
    resource_id bigint NOT NULL,
    text text,
    content_uri public.citext,
    status public.representation_status DEFAULT 'ready_to_review'::public.representation_status NOT NULL,
    metum_id bigint NOT NULL,
    author_id bigint NOT NULL,
    content_type character varying DEFAULT 'text/plain'::character varying NOT NULL,
    language public.citext NOT NULL,
    license_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    notes text,
    ordinality integer
);


--
-- Name: representations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.representations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: representations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.representations_id_seq OWNED BY public.representations.id;


--
-- Name: resource_group_resources; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.resource_group_resources (
    id bigint NOT NULL,
    resource_group_id bigint,
    resource_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    is_auto_matched boolean DEFAULT false NOT NULL
);


--
-- Name: resource_group_resources_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.resource_group_resources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: resource_group_resources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.resource_group_resources_id_seq OWNED BY public.resource_group_resources.id;


--
-- Name: resource_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.resource_groups (
    id integer NOT NULL,
    name public.citext NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    organization_id integer NOT NULL,
    "default" boolean DEFAULT false,
    webhook_uri public.citext,
    token character varying,
    auto_match_host_uris character varying[] DEFAULT '{}'::character varying[] NOT NULL
);


--
-- Name: resource_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.resource_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: resource_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.resource_groups_id_seq OWNED BY public.resource_groups.id;


--
-- Name: resource_links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.resource_links (
    id bigint NOT NULL,
    subject_resource_id bigint NOT NULL,
    verb character varying NOT NULL,
    object_resource_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: resource_links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.resource_links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: resource_links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.resource_links_id_seq OWNED BY public.resource_links.id;


--
-- Name: resource_status_checks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.resource_status_checks (
    id bigint NOT NULL,
    resource_id bigint,
    source_uri character varying NOT NULL,
    response integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: resource_status_checks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.resource_status_checks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: resource_status_checks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.resource_status_checks_id_seq OWNED BY public.resource_status_checks.id;


--
-- Name: resource_webhook_calls; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.resource_webhook_calls (
    id bigint NOT NULL,
    resource_id bigint NOT NULL,
    uri public.citext NOT NULL,
    body json,
    response integer,
    error text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    response_body text
);


--
-- Name: resource_webhook_calls_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.resource_webhook_calls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: resource_webhook_calls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.resource_webhook_calls_id_seq OWNED BY public.resource_webhook_calls.id;


--
-- Name: resources; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.resources (
    id bigint NOT NULL,
    name character varying DEFAULT '(no title provided)'::character varying NOT NULL,
    resource_type public.resource_type DEFAULT 'image'::public.resource_type NOT NULL,
    canonical_id public.citext,
    source_uri public.citext NOT NULL,
    organization_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    representations_count integer DEFAULT 0 NOT NULL,
    priority_flag boolean DEFAULT false NOT NULL,
    host_uris character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    status public.resource_status DEFAULT 'active'::public.resource_status NOT NULL,
    source_uri_hash character varying
);


--
-- Name: resources_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.resources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: resources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.resources_id_seq OWNED BY public.resources.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    email public.citext DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying,
    last_sign_in_ip character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    first_name public.citext,
    last_name public.citext,
    authentication_token character varying NOT NULL,
    staff boolean DEFAULT false NOT NULL,
    failed_attempts integer DEFAULT 0 NOT NULL,
    locked_at timestamp without time zone,
    organizations_count integer DEFAULT 0,
    active boolean DEFAULT true,
    password_digest character varying
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
-- Name: active_storage_attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments ALTER COLUMN id SET DEFAULT nextval('public.active_storage_attachments_id_seq'::regclass);


--
-- Name: active_storage_blobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs ALTER COLUMN id SET DEFAULT nextval('public.active_storage_blobs_id_seq'::regclass);


--
-- Name: assignments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assignments ALTER COLUMN id SET DEFAULT nextval('public.assignments_id_seq'::regclass);


--
-- Name: audits id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audits ALTER COLUMN id SET DEFAULT nextval('public.audits_id_seq'::regclass);


--
-- Name: auth_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_tokens ALTER COLUMN id SET DEFAULT nextval('public.auth_tokens_id_seq'::regclass);


--
-- Name: imports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.imports ALTER COLUMN id SET DEFAULT nextval('public.imports_id_seq'::regclass);


--
-- Name: invitations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invitations ALTER COLUMN id SET DEFAULT nextval('public.invitations_id_seq'::regclass);


--
-- Name: licenses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.licenses ALTER COLUMN id SET DEFAULT nextval('public.licenses_id_seq'::regclass);


--
-- Name: memberships id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memberships ALTER COLUMN id SET DEFAULT nextval('public.memberships_id_seq'::regclass);


--
-- Name: meta id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meta ALTER COLUMN id SET DEFAULT nextval('public.meta_id_seq'::regclass);


--
-- Name: organizations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations ALTER COLUMN id SET DEFAULT nextval('public.organizations_id_seq'::regclass);


--
-- Name: password_resets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.password_resets ALTER COLUMN id SET DEFAULT nextval('public.password_resets_id_seq'::regclass);


--
-- Name: representation_rejections id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.representation_rejections ALTER COLUMN id SET DEFAULT nextval('public.representation_rejections_id_seq'::regclass);


--
-- Name: representations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.representations ALTER COLUMN id SET DEFAULT nextval('public.representations_id_seq'::regclass);


--
-- Name: resource_group_resources id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resource_group_resources ALTER COLUMN id SET DEFAULT nextval('public.resource_group_resources_id_seq'::regclass);


--
-- Name: resource_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resource_groups ALTER COLUMN id SET DEFAULT nextval('public.resource_groups_id_seq'::regclass);


--
-- Name: resource_links id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resource_links ALTER COLUMN id SET DEFAULT nextval('public.resource_links_id_seq'::regclass);


--
-- Name: resource_status_checks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resource_status_checks ALTER COLUMN id SET DEFAULT nextval('public.resource_status_checks_id_seq'::regclass);


--
-- Name: resource_webhook_calls id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resource_webhook_calls ALTER COLUMN id SET DEFAULT nextval('public.resource_webhook_calls_id_seq'::regclass);


--
-- Name: resources id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resources ALTER COLUMN id SET DEFAULT nextval('public.resources_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


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
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: assignments assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assignments
    ADD CONSTRAINT assignments_pkey PRIMARY KEY (id);


--
-- Name: audits audits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audits
    ADD CONSTRAINT audits_pkey PRIMARY KEY (id);


--
-- Name: auth_tokens auth_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_tokens
    ADD CONSTRAINT auth_tokens_pkey PRIMARY KEY (id);


--
-- Name: imports imports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.imports
    ADD CONSTRAINT imports_pkey PRIMARY KEY (id);


--
-- Name: invitations invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invitations
    ADD CONSTRAINT invitations_pkey PRIMARY KEY (id);


--
-- Name: licenses licenses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.licenses
    ADD CONSTRAINT licenses_pkey PRIMARY KEY (id);


--
-- Name: memberships memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memberships
    ADD CONSTRAINT memberships_pkey PRIMARY KEY (id);


--
-- Name: meta meta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meta
    ADD CONSTRAINT meta_pkey PRIMARY KEY (id);


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: password_resets password_resets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.password_resets
    ADD CONSTRAINT password_resets_pkey PRIMARY KEY (id);


--
-- Name: representation_rejections representation_rejections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.representation_rejections
    ADD CONSTRAINT representation_rejections_pkey PRIMARY KEY (id);


--
-- Name: representations representations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.representations
    ADD CONSTRAINT representations_pkey PRIMARY KEY (id);


--
-- Name: resource_group_resources resource_group_resources_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resource_group_resources
    ADD CONSTRAINT resource_group_resources_pkey PRIMARY KEY (id);


--
-- Name: resource_groups resource_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resource_groups
    ADD CONSTRAINT resource_groups_pkey PRIMARY KEY (id);


--
-- Name: resource_links resource_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resource_links
    ADD CONSTRAINT resource_links_pkey PRIMARY KEY (id);


--
-- Name: resource_status_checks resource_status_checks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resource_status_checks
    ADD CONSTRAINT resource_status_checks_pkey PRIMARY KEY (id);


--
-- Name: resource_webhook_calls resource_webhook_calls_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resource_webhook_calls
    ADD CONSTRAINT resource_webhook_calls_pkey PRIMARY KEY (id);


--
-- Name: resources resources_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resources
    ADD CONSTRAINT resources_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: associated_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX associated_index ON public.audits USING btree (associated_id, associated_type);


--
-- Name: auditable_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auditable_index ON public.audits USING btree (auditable_id, auditable_type);


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
-- Name: index_assignments_on_resource_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_assignments_on_resource_id_and_user_id ON public.assignments USING btree (resource_id, user_id);


--
-- Name: index_audits_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_audits_on_created_at ON public.audits USING btree (created_at);


--
-- Name: index_audits_on_request_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_audits_on_request_uuid ON public.audits USING btree (request_uuid);


--
-- Name: index_auth_tokens_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_auth_tokens_on_token ON public.auth_tokens USING btree (token);


--
-- Name: index_auth_tokens_on_token_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_auth_tokens_on_token_and_user_id ON public.auth_tokens USING btree (token, user_id);


--
-- Name: index_auth_tokens_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_auth_tokens_on_user_id ON public.auth_tokens USING btree (user_id);


--
-- Name: index_imports_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_imports_on_organization_id ON public.imports USING btree (organization_id);


--
-- Name: index_imports_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_imports_on_user_id ON public.imports USING btree (user_id);


--
-- Name: index_invitations_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_invitations_on_organization_id ON public.invitations USING btree (organization_id);


--
-- Name: index_invitations_on_recipient_email_and_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_invitations_on_recipient_email_and_token ON public.invitations USING btree (recipient_email, token);


--
-- Name: index_invitations_on_recipient_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_invitations_on_recipient_user_id ON public.invitations USING btree (recipient_user_id);


--
-- Name: index_invitations_on_sender_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_invitations_on_sender_user_id ON public.invitations USING btree (sender_user_id);


--
-- Name: index_memberships_on_user_id_and_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_memberships_on_user_id_and_organization_id ON public.memberships USING btree (user_id, organization_id);


--
-- Name: index_meta_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_meta_on_organization_id ON public.meta USING btree (organization_id);


--
-- Name: index_meta_on_organization_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_meta_on_organization_id_and_name ON public.meta USING btree (organization_id, name);


--
-- Name: index_organizations_on_is_deleted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organizations_on_is_deleted ON public.organizations USING btree (is_deleted);


--
-- Name: index_organizations_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_organizations_on_name ON public.organizations USING btree (name);


--
-- Name: index_password_resets_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_password_resets_on_user_id ON public.password_resets USING btree (user_id);


--
-- Name: index_representation_rejections_on_representation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_representation_rejections_on_representation_id ON public.representation_rejections USING btree (representation_id);


--
-- Name: index_representation_rejections_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_representation_rejections_on_user_id ON public.representation_rejections USING btree (user_id);


--
-- Name: index_representations_on_author_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_representations_on_author_id ON public.representations USING btree (author_id);


--
-- Name: index_representations_on_license_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_representations_on_license_id ON public.representations USING btree (license_id);


--
-- Name: index_representations_on_metum_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_representations_on_metum_id ON public.representations USING btree (metum_id);


--
-- Name: index_representations_on_resource_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_representations_on_resource_id ON public.representations USING btree (resource_id);


--
-- Name: index_representations_on_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_representations_on_status ON public.representations USING btree (status);


--
-- Name: index_resource_group_resources_on_resource_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_resource_group_resources_on_resource_group_id ON public.resource_group_resources USING btree (resource_group_id);


--
-- Name: index_resource_group_resources_on_resource_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_resource_group_resources_on_resource_id ON public.resource_group_resources USING btree (resource_id);


--
-- Name: index_resource_groups_on_organization_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_resource_groups_on_organization_id_and_name ON public.resource_groups USING btree (organization_id, name);


--
-- Name: index_resource_groups_on_webhook_uri; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_resource_groups_on_webhook_uri ON public.resource_groups USING btree (webhook_uri);


--
-- Name: index_resource_links; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_resource_links ON public.resource_links USING btree (subject_resource_id, verb, object_resource_id);


--
-- Name: index_resource_links_on_object_resource_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_resource_links_on_object_resource_id ON public.resource_links USING btree (object_resource_id);


--
-- Name: index_resource_links_on_subject_resource_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_resource_links_on_subject_resource_id ON public.resource_links USING btree (subject_resource_id);


--
-- Name: index_resource_status_checks_on_resource_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_resource_status_checks_on_resource_id ON public.resource_status_checks USING btree (resource_id);


--
-- Name: index_resource_webhook_calls_on_resource_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_resource_webhook_calls_on_resource_id ON public.resource_webhook_calls USING btree (resource_id);


--
-- Name: index_resources_on_canonical_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_resources_on_canonical_id ON public.resources USING btree (canonical_id);


--
-- Name: index_resources_on_is_deleted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_resources_on_is_deleted ON public.resources USING btree (is_deleted);


--
-- Name: index_resources_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_resources_on_organization_id ON public.resources USING btree (organization_id);


--
-- Name: index_resources_on_organization_id_and_canonical_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_resources_on_organization_id_and_canonical_id ON public.resources USING btree (organization_id, canonical_id);


--
-- Name: index_resources_on_priority_flag; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_resources_on_priority_flag ON public.resources USING btree (priority_flag DESC);


--
-- Name: index_resources_on_representations_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_resources_on_representations_count ON public.resources USING btree (representations_count);


--
-- Name: index_resources_on_schemaless_source_uri; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_resources_on_schemaless_source_uri ON public.resources USING gin (source_uri public.gin_trgm_ops);


--
-- Name: index_resources_on_source_uri; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_resources_on_source_uri ON public.resources USING btree (source_uri);


--
-- Name: index_resources_on_source_uri_and_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_resources_on_source_uri_and_organization_id ON public.resources USING btree (source_uri, organization_id) WHERE ((source_uri IS NOT NULL) AND (source_uri OPERATOR(public.<>) ''::public.citext));


--
-- Name: index_resources_resource_group_join; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_resources_resource_group_join ON public.resource_group_resources USING btree (resource_id, resource_group_id);


--
-- Name: index_users_on_authentication_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_authentication_token ON public.users USING btree (authentication_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON public.schema_migrations USING btree (version);


--
-- Name: user_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_index ON public.audits USING btree (user_id, user_type);


--
-- Name: auth_tokens fk_rails_0d66c22f4c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_tokens
    ADD CONSTRAINT fk_rails_0d66c22f4c FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: invitations fk_rails_0fe4c14f0e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invitations
    ADD CONSTRAINT fk_rails_0fe4c14f0e FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: representations fk_rails_15f6769de2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.representations
    ADD CONSTRAINT fk_rails_15f6769de2 FOREIGN KEY (author_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: resource_webhook_calls fk_rails_16dfa60230; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resource_webhook_calls
    ADD CONSTRAINT fk_rails_16dfa60230 FOREIGN KEY (resource_id) REFERENCES public.resources(id);


--
-- Name: assignments fk_rails_24272542fc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assignments
    ADD CONSTRAINT fk_rails_24272542fc FOREIGN KEY (resource_id) REFERENCES public.resources(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: resource_links fk_rails_34c53ccf50; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resource_links
    ADD CONSTRAINT fk_rails_34c53ccf50 FOREIGN KEY (subject_resource_id) REFERENCES public.resources(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: password_resets fk_rails_526379cd99; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.password_resets
    ADD CONSTRAINT fk_rails_526379cd99 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: representations fk_rails_5dbc0cf401; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.representations
    ADD CONSTRAINT fk_rails_5dbc0cf401 FOREIGN KEY (metum_id) REFERENCES public.meta(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: memberships fk_rails_64267aab58; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memberships
    ADD CONSTRAINT fk_rails_64267aab58 FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: resource_group_resources fk_rails_66b6e5785c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resource_group_resources
    ADD CONSTRAINT fk_rails_66b6e5785c FOREIGN KEY (resource_id) REFERENCES public.resources(id);


--
-- Name: invitations fk_rails_7c153aa738; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invitations
    ADD CONSTRAINT fk_rails_7c153aa738 FOREIGN KEY (sender_user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: resource_group_resources fk_rails_88737f8f93; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resource_group_resources
    ADD CONSTRAINT fk_rails_88737f8f93 FOREIGN KEY (resource_group_id) REFERENCES public.resource_groups(id);


--
-- Name: organizations fk_rails_8a4b69ce6a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT fk_rails_8a4b69ce6a FOREIGN KEY (default_license_id) REFERENCES public.licenses(id);


--
-- Name: resource_groups fk_rails_8e9711c31f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resource_groups
    ADD CONSTRAINT fk_rails_8e9711c31f FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: memberships fk_rails_99326fb65d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memberships
    ADD CONSTRAINT fk_rails_99326fb65d FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: assignments fk_rails_aa6b76dac2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assignments
    ADD CONSTRAINT fk_rails_aa6b76dac2 FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: invitations fk_rails_ad7a61abab; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invitations
    ADD CONSTRAINT fk_rails_ad7a61abab FOREIGN KEY (recipient_user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: imports fk_rails_b1e2154c26; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.imports
    ADD CONSTRAINT fk_rails_b1e2154c26 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: resources fk_rails_b7c74d1aaf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resources
    ADD CONSTRAINT fk_rails_b7c74d1aaf FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: representation_rejections fk_rails_b9bd075422; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.representation_rejections
    ADD CONSTRAINT fk_rails_b9bd075422 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: representations fk_rails_bdad6334d2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.representations
    ADD CONSTRAINT fk_rails_bdad6334d2 FOREIGN KEY (resource_id) REFERENCES public.resources(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: active_storage_attachments fk_rails_c3b3935057; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT fk_rails_c3b3935057 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: meta fk_rails_cb7ee3d880; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meta
    ADD CONSTRAINT fk_rails_cb7ee3d880 FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: representations fk_rails_d040284b2b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.representations
    ADD CONSTRAINT fk_rails_d040284b2b FOREIGN KEY (license_id) REFERENCES public.licenses(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: imports fk_rails_d57890ddd8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.imports
    ADD CONSTRAINT fk_rails_d57890ddd8 FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: resource_links fk_rails_e34756464a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resource_links
    ADD CONSTRAINT fk_rails_e34756464a FOREIGN KEY (object_resource_id) REFERENCES public.resources(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: representation_rejections fk_rails_f68380ebbc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.representation_rejections
    ADD CONSTRAINT fk_rails_f68380ebbc FOREIGN KEY (representation_id) REFERENCES public.representations(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20150625124853'),
('20150625125138'),
('20150625125139'),
('20150625125140'),
('20150625125141'),
('20150625125142'),
('20150625134302'),
('20150625142217'),
('20150625155015'),
('20150625155025'),
('20150625155026'),
('20150625155032'),
('20150701220841'),
('20150702152708'),
('20150708151043'),
('20150708191222'),
('20150724203747'),
('20150724215850'),
('20150724215851'),
('20150831153035'),
('20150903170221'),
('20160426130133'),
('20160525155525'),
('20160620125547'),
('20160621193039'),
('20160621220610'),
('20160727192933'),
('20160811173510'),
('20170320174821'),
('20170724200105'),
('20170724203045'),
('20170727161448'),
('20170727163758'),
('20170727190212'),
('20170727192426'),
('20170728134702'),
('20170731150808'),
('20170731182230'),
('20170804131408'),
('20170807153011'),
('20170808141238'),
('20170808141713'),
('20170829152556'),
('20170829153738'),
('20170829173615'),
('20170829174112'),
('20170901140040'),
('20170901140852'),
('20170901142505'),
('20170901142712'),
('20170901151655'),
('20170905125227'),
('20170905125501'),
('20170905125542'),
('20170907200258'),
('20170911173601'),
('20170918155037'),
('20170919130347'),
('20170919131343'),
('20170919131540'),
('20170919131733'),
('20170919132337'),
('20170919140456'),
('20170919142450'),
('20170921185109'),
('20170922154933'),
('20170922160337'),
('20170922160701'),
('20171003125652'),
('20171003131534'),
('20171003131931'),
('20171006172008'),
('20171011152909'),
('20171013160538'),
('20171016133717'),
('20171017125333'),
('20171017201950'),
('20171017203300'),
('20171106164149'),
('20171117164747'),
('20171120143357'),
('20171120143519'),
('20171120144727'),
('20171121165017'),
('20180327144408'),
('20180614200303'),
('20180710164016'),
('20180825140356'),
('20180825140408'),
('20180825193305'),
('20180829010109'),
('20180830121901'),
('20180904221446'),
('20180912004124'),
('20180928203337'),
('20181003184315'),
('20181003222901'),
('20181005234836'),
('20200402174009'),
('20200423170945'),
('20200428200839'),
('20200429211742'),
('20200429212438'),
('20200429224758'),
('20200501205106'),
('20200514191454'),
('20200519172348'),
('20200519183148'),
('20200519184306'),
('20200520195141'),
('20200520204316'),
('20200522191610'),
('20200527215343'),
('20200527221219'),
('20200527223134'),
('20200527224933'),
('20200603164622'),
('20200615211941'),
('20200618182745'),
('20200618194643'),
('20200619172655'),
('20200619192855'),
('20200622231708'),
('20200622232200'),
('20200731042857'),
('20200814180824'),
('20200824203050'),
('20200825173757'),
('20200827210043'),
('20201110000430'),
('20201113164644'),
('20201203005723'),
('20210224181332'),
('20210303210513'),
('20210304215302'),
('20210312210908'),
('20210317190514'),
('20210325221939'),
('20210325224106'),
('20210405190521'),
('20210417203301'),
('20210421221224');


