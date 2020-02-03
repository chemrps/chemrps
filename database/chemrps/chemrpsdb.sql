--
-- PostgreSQL database dump
--

-- Dumped from database version 11.5
-- Dumped by pg_dump version 11.5

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
-- Name: aux_services; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA aux_services;


ALTER SCHEMA aux_services OWNER TO postgres;

--
-- Name: SCHEMA aux_services; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA aux_services IS 'Interfaces to auxillary services, e.g. web services.';


--
-- Name: bcf_auth; Type: SCHEMA; Schema: -; Owner: bcf_auth
--

CREATE SCHEMA bcf_auth;


ALTER SCHEMA bcf_auth OWNER TO bcf_auth;

--
-- Name: SCHEMA bcf_auth; Type: COMMENT; Schema: -; Owner: bcf_auth
--

COMMENT ON SCHEMA bcf_auth IS 'External user => database user authentication and mapping schema.';


--
-- Name: bcf_reg; Type: SCHEMA; Schema: -; Owner: bcf_reg
--

CREATE SCHEMA bcf_reg;


ALTER SCHEMA bcf_reg OWNER TO bcf_reg;

--
-- Name: SCHEMA bcf_reg; Type: COMMENT; Schema: -; Owner: bcf_reg
--

COMMENT ON SCHEMA bcf_reg IS 'Biochemfusion registration system - data tables.';


--
-- Name: bcf_reg_config; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA bcf_reg_config;


ALTER SCHEMA bcf_reg_config OWNER TO postgres;

--
-- Name: SCHEMA bcf_reg_config; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA bcf_reg_config IS 'Biochemfusion registration system - configuration and company-specific rules.';


--
-- Name: bcf_reg_facade; Type: SCHEMA; Schema: -; Owner: bcf_reg_facade
--

CREATE SCHEMA bcf_reg_facade;


ALTER SCHEMA bcf_reg_facade OWNER TO bcf_reg_facade;

--
-- Name: SCHEMA bcf_reg_facade; Type: COMMENT; Schema: -; Owner: bcf_reg_facade
--

COMMENT ON SCHEMA bcf_reg_facade IS 'Biochemfusion registration system - client facade.';


--
-- Name: bcf_reg_web_facade; Type: SCHEMA; Schema: -; Owner: bcf_reg_facade
--

CREATE SCHEMA bcf_reg_web_facade;


ALTER SCHEMA bcf_reg_web_facade OWNER TO bcf_reg_facade;

--
-- Name: SCHEMA bcf_reg_web_facade; Type: COMMENT; Schema: -; Owner: bcf_reg_facade
--

COMMENT ON SCHEMA bcf_reg_web_facade IS 'Biochemfusion registration system - Web UI facade.';


--
-- Name: bcf_utils; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA bcf_utils;


ALTER SCHEMA bcf_utils OWNER TO postgres;

--
-- Name: SCHEMA bcf_utils; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA bcf_utils IS 'Biochemfusion utilities.';


--
-- Name: hstore; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA hstore;


ALTER SCHEMA hstore OWNER TO postgres;

--
-- Name: SCHEMA hstore; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA hstore IS 'Postgres hstore extension schema.';


--
-- Name: proteax; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA proteax;


ALTER SCHEMA proteax OWNER TO postgres;

--
-- Name: SCHEMA proteax; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA proteax IS 'Proteax extension schema.';


--
-- Name: rdkit; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA rdkit;


ALTER SCHEMA rdkit OWNER TO postgres;

--
-- Name: SCHEMA rdkit; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA rdkit IS 'RDKit extension schema.';


--
-- Name: plpythonu; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: postgres
--

CREATE OR REPLACE PROCEDURAL LANGUAGE plpythonu;


ALTER PROCEDURAL LANGUAGE plpythonu OWNER TO postgres;

--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA hstore;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


--
-- Name: proteax; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS proteax WITH SCHEMA proteax;


--
-- Name: EXTENSION proteax; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION proteax IS 'The Proteax PostgreSQL extension provides biochemistry functions for peptides and proteins.';


--
-- Name: rdkit; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS rdkit WITH SCHEMA rdkit;


--
-- Name: EXTENSION rdkit; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION rdkit IS 'Cheminformatics functionality for PostgreSQL.';


--
-- Name: molfile_fragment_count(text); Type: FUNCTION; Schema: aux_services; Owner: system_admin
--

CREATE FUNCTION aux_services.molfile_fragment_count(a_molfile text) RETURNS integer
    LANGUAGE plpythonu
    AS $$
import urllib, json

qrystr = urllib.urlencode({'molfile': a_molfile})
req = urllib.urlopen("http://localhost:8080/run/fragment_count", qrystr)
if req.getcode() != 200:
  err_msg = req.read()
  raise Exception, err_msg
else:
  json_text = req.read()
  json_result = json.loads(json_text)
  return json_result['fragment_count']

$$;


ALTER FUNCTION aux_services.molfile_fragment_count(a_molfile text) OWNER TO system_admin;

--
-- Name: molfile_to_svg(text, integer, integer); Type: FUNCTION; Schema: aux_services; Owner: system_admin
--

CREATE FUNCTION aux_services.molfile_to_svg(a_molfile text, a_width integer, a_height integer) RETURNS text
    LANGUAGE plpythonu
    AS $$
import urllib, json

qrystr = urllib.urlencode({'molfile': a_molfile, 'width': a_width, 'height': a_height})
req = urllib.urlopen("http://localhost:8080/run/render", qrystr)
if req.getcode() != 200:
  err_msg = req.read()
  raise Exception, err_msg
else:
  json_text = req.read()
  json_result = json.loads(json_text)
  return json_result['svg']

$$;


ALTER FUNCTION aux_services.molfile_to_svg(a_molfile text, a_width integer, a_height integer) OWNER TO system_admin;

--
-- Name: assign_privs(text, integer, integer, integer); Type: FUNCTION; Schema: bcf_auth; Owner: bcf_auth
--

CREATE FUNCTION bcf_auth.assign_privs(a_user_initials text, reg_privs integer, stock_privs integer, patent_privs integer) RETURNS void
    LANGUAGE plpgsql
    SET search_path TO 'bcf_auth', 'pg_temp'
    AS $_$
declare
  db_username text;
  rec record;
  new_reg_role text;
  new_stock_role text;
  new_patent_role text;
begin
  if not upper(a_user_initials) ~ '^[A-Z_]+$' then
    raise exception 'Invalid initials "%": Must be all alphabetical characters A..Z or underscores.', a_user_initials;
  end if;

  db_username := bcf_reg_config.initials_to_account_name(a_user_initials);
  raise notice 'Assign/reset BCFReg privileges for %.', db_username;

  if reg_privs < 0 or reg_privs > 4 then
    raise exception 'BCFReg privileges out of range - must be 0..4.';
  end if;
  if stock_privs < 0 or stock_privs > 2 then
    raise exception 'BCFReg stock privileges out of range - must be 0..2.';
  end if;
  if patent_privs <> 0 and patent_privs <> 3 then
    raise exception 'BCFReg patent privileges out of range - must be 0 or 3.';
  end if;

  case reg_privs
    when 0 then new_reg_role := '';
    when 1 then new_reg_role := 'bcf_reg_viewer';
    when 2 then new_reg_role := 'bcf_reg_editor';
    when 3 then new_reg_role := 'bcf_reg_admin';
    when 4 then new_reg_role := 'bcf_reg_dba';
  else
    raise exception 'Internal bug: BCFReg privilege level out of range.';
  end case;

  case stock_privs
    when 0 then new_stock_role := '';
    when 1 then new_stock_role := 'bcf_reg_stock_requester';
    when 2 then new_stock_role := 'bcf_reg_stock_admin';
  else
    raise exception 'Internal bug: BCFReg stock privilege level out of range.';
  end case;

  case patent_privs
    when 0 then new_patent_role := '';
    when 3 then new_patent_role := 'bcf_reg_patent_admin';
  else
    raise exception 'Internal bug: BCFReg patent privilege level out of range.';
  end case;

  -- Revoke already granted roles.
  for rec in (
    SELECT grp.groname as granted_role
      FROM pg_user usr
      JOIN pg_group grp ON usr.usesysid = ANY (grp.grolist)
     WHERE usr.usename = db_username AND grp.groname like 'bcf_reg_%'
  )
  loop
    execute 'revoke ' || quote_ident(rec.granted_role) || ' from ' || quote_ident(db_username) || ';';
    raise notice '  Revoked % from %.', rec.granted_role, db_username;
  end loop;

  if new_reg_role <> '' then
    execute 'grant ' || new_reg_role || ' to ' || quote_ident(db_username) || ';';
    raise notice '  Granted % to %.', new_reg_role, db_username;
  end if;

  if new_stock_role <> '' then
    execute 'grant ' || new_stock_role || ' to ' || quote_ident(db_username) || ';';
    raise notice '  Granted % to %.', new_stock_role, db_username;
  end if;

  if new_patent_role <> '' then
    execute 'grant ' || new_patent_role || ' to ' || quote_ident(db_username) || ';';
    raise notice '  Granted % to %.', new_patent_role, db_username;
  end if;
end;
$_$;


ALTER FUNCTION bcf_auth.assign_privs(a_user_initials text, reg_privs integer, stock_privs integer, patent_privs integer) OWNER TO bcf_auth;

--
-- Name: const_priv_level_admin(); Type: FUNCTION; Schema: bcf_auth; Owner: bcf_auth
--

CREATE FUNCTION bcf_auth.const_priv_level_admin() RETURNS integer
    LANGUAGE sql IMMUTABLE
    AS $$ select 3::integer $$;


ALTER FUNCTION bcf_auth.const_priv_level_admin() OWNER TO bcf_auth;

--
-- Name: FUNCTION const_priv_level_admin(); Type: COMMENT; Schema: bcf_auth; Owner: bcf_auth
--

COMMENT ON FUNCTION bcf_auth.const_priv_level_admin() IS 'CONST: "Admin"/bcf_reg_admin role code returned by get_priv_level().';


--
-- Name: const_priv_level_dba(); Type: FUNCTION; Schema: bcf_auth; Owner: bcf_auth
--

CREATE FUNCTION bcf_auth.const_priv_level_dba() RETURNS integer
    LANGUAGE sql IMMUTABLE
    AS $$ select 4::integer $$;


ALTER FUNCTION bcf_auth.const_priv_level_dba() OWNER TO bcf_auth;

--
-- Name: FUNCTION const_priv_level_dba(); Type: COMMENT; Schema: bcf_auth; Owner: bcf_auth
--

COMMENT ON FUNCTION bcf_auth.const_priv_level_dba() IS 'CONST: "DBA"/bcf_reg_dba role code returned by get_priv_level().';


--
-- Name: const_priv_level_editor(); Type: FUNCTION; Schema: bcf_auth; Owner: bcf_auth
--

CREATE FUNCTION bcf_auth.const_priv_level_editor() RETURNS integer
    LANGUAGE sql IMMUTABLE
    AS $$ select 2::integer $$;


ALTER FUNCTION bcf_auth.const_priv_level_editor() OWNER TO bcf_auth;

--
-- Name: FUNCTION const_priv_level_editor(); Type: COMMENT; Schema: bcf_auth; Owner: bcf_auth
--

COMMENT ON FUNCTION bcf_auth.const_priv_level_editor() IS 'CONST: "Editor"/bcf_reg_editor role code returned by get_priv_level().';


--
-- Name: const_priv_level_viewer(); Type: FUNCTION; Schema: bcf_auth; Owner: bcf_auth
--

CREATE FUNCTION bcf_auth.const_priv_level_viewer() RETURNS integer
    LANGUAGE sql IMMUTABLE
    AS $$ select 1::integer $$;


ALTER FUNCTION bcf_auth.const_priv_level_viewer() OWNER TO bcf_auth;

--
-- Name: FUNCTION const_priv_level_viewer(); Type: COMMENT; Schema: bcf_auth; Owner: bcf_auth
--

COMMENT ON FUNCTION bcf_auth.const_priv_level_viewer() IS 'CONST: "Viewer"/bcf_reg_viewer role code returned by get_priv_level().';


--
-- Name: create_user(text); Type: FUNCTION; Schema: bcf_auth; Owner: bcf_auth
--

CREATE FUNCTION bcf_auth.create_user(a_user_initials text) RETURNS void
    LANGUAGE plpgsql
    SET search_path TO 'bcf_auth, pg_temp'
    AS $_$

declare
  new_password text;
  new_username text;
  ext_username text;
  new_emailadr text;
begin
  if not upper(a_user_initials) ~ '^[A-Z_]+$' then
    raise exception 'Invalid initials "%": Must be all alphabetical characters A..Z or underscores.', a_user_initials;
  end if;

  new_password := md5(random()::text);
  new_username := bcf_reg_config.initials_to_account_name(a_user_initials);
  ext_username := 'example\' || lower(a_user_initials); -- //(**!! COMPANY-SPECIFIC RULE.
  new_emailadr := lower(a_user_initials) || '@example.com'; -- //(**!! COMPANY-SPECIFIC RULE.

  execute 'create user ' || quote_ident(new_username) || ' with encrypted password ' || quote_literal(new_password) || ';';

  insert into bcf_auth.user_mappings
    (external_user_name, db_user_name, db_password,  email_address)
  values
    (ext_username,       new_username, new_password, new_emailadr);
end;

$_$;


ALTER FUNCTION bcf_auth.create_user(a_user_initials text) OWNER TO bcf_auth;

--
-- Name: FUNCTION create_user(a_user_initials text); Type: COMMENT; Schema: bcf_auth; Owner: bcf_auth
--

COMMENT ON FUNCTION bcf_auth.create_user(a_user_initials text) IS 'Creates a new user with the specified initials, maps the new user to an external user name, and assigns BCFReg viewer privileges to the new user.';


--
-- Name: delete_user(text); Type: FUNCTION; Schema: bcf_auth; Owner: bcf_auth
--

CREATE FUNCTION bcf_auth.delete_user(a_user_initials text) RETURNS void
    LANGUAGE plpgsql
    SET search_path TO 'bcf_auth, pg_temp'
    AS $_$

declare
  db_username text;
  deleted_count integer;
begin
  if not upper(a_user_initials) ~ '^[A-Z_]+$' then
    raise exception 'Invalid initials "%": Must be all alphabetical characters A..Z or underscores.', a_user_initials;
  end if;

  db_username := bcf_reg_config.initials_to_account_name(a_user_initials);

  delete from bcf_auth.user_mappings
   where db_user_name = db_username;

  get diagnostics deleted_count = row_count;
  if deleted_count <> 1 then
    raise exception 'There is no mapping of "%" to an external user. This procedure will not attempt to delete such a user.', a_user_initials;
  end if;

  execute 'drop user ' || quote_ident(db_username) || ';';
end;

$_$;


ALTER FUNCTION bcf_auth.delete_user(a_user_initials text) OWNER TO bcf_auth;

--
-- Name: FUNCTION delete_user(a_user_initials text); Type: COMMENT; Schema: bcf_auth; Owner: bcf_auth
--

COMMENT ON FUNCTION bcf_auth.delete_user(a_user_initials text) IS 'Deletes the user with the specified initials, but only if such a user has been mapped to an external user.';


--
-- Name: get_kvp_value(text, text); Type: FUNCTION; Schema: bcf_auth; Owner: postgres
--

CREATE FUNCTION bcf_auth.get_kvp_value(a_kvp_text text, a_key text) RETURNS text
    LANGUAGE plpgsql
    AS $$
declare
  key_pos integer;
  result text;
  space_pos integer;
begin
  key_pos := position(' ' || a_key || '=' in a_kvp_text);
  if key_pos > 0 then
    result := substr(a_kvp_text, key_pos + length(a_key) + 2);
    space_pos := position(' ' in result);
    if space_pos > 0 then
      result := substr(result, 1, space_pos - 1);
    end if;
  else
    result := '';
  end if;

  return result;
end
$$;


ALTER FUNCTION bcf_auth.get_kvp_value(a_kvp_text text, a_key text) OWNER TO postgres;

--
-- Name: FUNCTION get_kvp_value(a_kvp_text text, a_key text); Type: COMMENT; Schema: bcf_auth; Owner: postgres
--

COMMENT ON FUNCTION bcf_auth.get_kvp_value(a_kvp_text text, a_key text) IS 'Extracts value by key from key-value-pair text. NOTE: Expects at least one space before all keys in text (assumes key value pairs are trailing data in log message). Also assumes that values do not contain spaces.';


--
-- Name: get_priv_levels_for_user(text); Type: FUNCTION; Schema: bcf_auth; Owner: bcf_auth
--

CREATE FUNCTION bcf_auth.get_priv_levels_for_user(a_user_name text) RETURNS TABLE(reg_priv_level integer, stock_priv_level integer, patent_priv_level integer, chemstore_priv_level integer)
    LANGUAGE plpgsql
    AS $$

begin
  return query
  select
      coalesce(max(
        case
          when g.groname = 'bcf_reg_viewer' then bcf_auth.CONST_PRIV_LEVEL_VIEWER()
          when g.groname = 'bcf_reg_editor' then bcf_auth.CONST_PRIV_LEVEL_EDITOR()
          when g.groname = 'bcf_reg_admin' then bcf_auth.CONST_PRIV_LEVEL_ADMIN()
          when g.groname = 'bcf_reg_dba' then bcf_auth.CONST_PRIV_LEVEL_DBA()
        else
          0
        end
      ), 0) as reg_priv_level,
      0 as stock_priv_level
    , 0 as patent_priv_level
    , 0 as chemstore_priv_level
    from pg_catalog.pg_user u
         join pg_catalog.pg_group g on u.usesysid = any(g.grolist)
   where u.usename = a_user_name;
end;

$$;


ALTER FUNCTION bcf_auth.get_priv_levels_for_user(a_user_name text) OWNER TO bcf_auth;

--
-- Name: FUNCTION get_priv_levels_for_user(a_user_name text); Type: COMMENT; Schema: bcf_auth; Owner: bcf_auth
--

COMMENT ON FUNCTION bcf_auth.get_priv_levels_for_user(a_user_name text) IS 'Internal function for retrieving max. BCFReg, Stock, Patent, and ZPChemStore privileges for a given user. Should be exposed to external interfaces through a "security definer" function.';


--
-- Name: job$refresh_user_passwords(); Type: FUNCTION; Schema: bcf_auth; Owner: bcf_auth
--

CREATE FUNCTION bcf_auth."job$refresh_user_passwords"() RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'bcf_auth', 'pg_temp'
    AS $$
declare
  u record;
  new_password text;
begin
  for u in (
    select * from bcf_auth.user_mappings
     where is_enabled = 'Y'
  )
  loop
    -- md5() returns a 32-char hex string. This is equivalent to 128 bits.
    -- random()::text returns a 14-digit decimal number equivalent to ~45 bits.
    -- So chaining 3 x random()::text provides at least 128 bits of input to md5().
    new_password := 
      md5(random()::text || random()::text || random()::text) ||
      md5(random()::text || random()::text || random()::text);

    begin
      execute 'alter user ' || quote_ident(u.db_user_name) || ' with encrypted password ' || quote_literal(new_password) || ';';

      update bcf_auth.user_mappings
         set db_password = new_password, status = 'VALID'
       where id = u.id;
    exception
      when others then
        update bcf_auth.user_mappings
           set db_password = '::ERROR::SEE_STATUS_COLUMN', status = 'ERROR: ' || SQLERRM
         where id = u.id;
    end;
  end loop;
end;
$$;


ALTER FUNCTION bcf_auth."job$refresh_user_passwords"() OWNER TO bcf_auth;

--
-- Name: set_password(text, text); Type: FUNCTION; Schema: bcf_auth; Owner: bcf_auth
--

CREATE FUNCTION bcf_auth.set_password(a_user_initials text, a_new_password text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'bcf_auth, pg_temp'
    AS $$
declare
  update_count integer;
begin
  update bcf_auth.user_mappings
     set db_password = a_new_password
   where db_user_name = bcf_reg_config.initials_to_account_name(a_user_initials);

  get diagnostics update_count = row_count;
  if update_count <> 1 then
    raise exception 'There is no registered account for the initials "%".', a_user_initials;
  end if;
  
  execute 'alter user '
    || quote_ident(bcf_reg_config.initials_to_account_name(a_user_initials))
    || ' with encrypted password ' || quote_literal(a_new_password);
end;
$$;


ALTER FUNCTION bcf_auth.set_password(a_user_initials text, a_new_password text) OWNER TO bcf_auth;

--
-- Name: sync_users(); Type: FUNCTION; Schema: bcf_auth; Owner: bcf_auth
--

CREATE FUNCTION bcf_auth.sync_users() RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'bcf_auth', 'pg_temp'
    AS $$
declare
  rec record;
  user_updated boolean;
begin
  for rec in (
    with all_ext_users as (
      select
          lower(trim(initials)) as user_initials
        , max(reg_priv_level) as reg_priv_level
        from (
          select initials, bcf_auth.const_priv_level_viewer() as reg_priv_level from bcf_auth.users_viewer
          union
          select initials, bcf_auth.const_priv_level_editor() from bcf_auth.users_editor
          union
          select initials, bcf_auth.const_priv_level_admin() from bcf_auth.users_admin
        ) all_user_tables
       group by lower(trim(initials))
    ),
    all_db_users as (
      select
          lower(bcf_reg_config.display_user_name(umap.db_user_name)) as db_user_initials,
          coalesce(umap.email_address, '') as db_email_address,
          privs.reg_priv_level as db_reg_priv_level,
          umap.is_enabled,
          umap.id
        from bcf_auth.user_mappings umap
        join bcf_auth.get_priv_levels_for_user(umap.db_user_name) privs on 1 = 1
    )
    select *
      from all_ext_users extusr
      full outer join all_db_users dbusr on dbusr.db_user_initials = extusr.user_initials
  )
  loop
    user_updated := false;

    -- DB user account removed from User Tables.
    if rec.user_initials is null then
      perform bcf_auth.delete_user(rec.db_user_initials);
      raise notice 'Dropped DB account "%".', rec.db_user_initials;
    -- New account in User Tables.
    elsif rec.db_user_initials is null then
      perform bcf_auth.create_user(rec.user_initials);
      raise notice 'Create DB account for "%".', rec.user_initials;

      perform bcf_auth.assign_privs(rec.user_initials, rec.reg_priv_level, 0, 0);
      raise notice '  Assign BCFReg privileges (reg) (%) to user "%".', rec.reg_priv_level, rec.user_initials;
    else
      -- Account assigned new BCFReg privileges in User Tables.
      if rec.reg_priv_level <> rec.db_reg_priv_level then
        perform bcf_auth.assign_privs(rec.db_user_initials, rec.reg_priv_level, 0, 0);
        raise notice '  Updated BCFReg privileges for DB account % to %.', rec.db_user_initials, rec.reg_priv_level;

        user_updated := true;
      end if;
    end if;

    -- If account has been changed in User Tables but it is disabled in DB: Emit warning.
    if user_updated and coalesce(rec.is_enabled, '') = 'N' then
      raise notice 'WARNING: User "%" has a disabled account.', rec.db_user_initials;
    end if;

  end loop;
end;
$$;


ALTER FUNCTION bcf_auth.sync_users() OWNER TO bcf_auth;

--
-- Name: FUNCTION sync_users(); Type: COMMENT; Schema: bcf_auth; Owner: bcf_auth
--

COMMENT ON FUNCTION bcf_auth.sync_users() IS 'Update DB accounts based on BCF_AUTH.USERS_* tables.';


--
-- Name: user_credentials(text); Type: FUNCTION; Schema: bcf_auth; Owner: bcf_auth
--

CREATE FUNCTION bcf_auth.user_credentials(an_external_user_name text) RETURNS TABLE(a_db_user_name text, a_db_password text, a_db_type text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'bcf_auth', 'pg_temp'
    AS $$
begin
  return query
    select db_user_name, db_password, bcf_reg_config.read_property('db_config', 'db_type', '<Unconfigured>', false)
      from bcf_auth.user_mappings
     where upper(external_user_name) = upper(an_external_user_name)
       and is_enabled = 'Y';
end;
$$;


ALTER FUNCTION bcf_auth.user_credentials(an_external_user_name text) OWNER TO bcf_auth;

--
-- Name: FUNCTION user_credentials(an_external_user_name text); Type: COMMENT; Schema: bcf_auth; Owner: bcf_auth
--

COMMENT ON FUNCTION bcf_auth.user_credentials(an_external_user_name text) IS 'Returns login credentials for a given external user name. Only used by BCF_AUTHENTICATOR user.';


--
-- Name: trg$assign_compound_name(); Type: FUNCTION; Schema: bcf_reg; Owner: bcf_reg
--

CREATE FUNCTION bcf_reg."trg$assign_compound_name"() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'bcf_reg', 'pg_temp'
    AS $$
begin
  if (coalesce(NEW.name, '') = '') then
    NEW.name := bcf_reg_config.create_compound_name(
      (select par.no from bcf_reg.parents par where par.id = NEW.parent_id),
      ''
    );
  end if;
  
  return NEW;
end;
$$;


ALTER FUNCTION bcf_reg."trg$assign_compound_name"() OWNER TO bcf_reg;

--
-- Name: trg$assign_parent_no_and_name(); Type: FUNCTION; Schema: bcf_reg; Owner: bcf_reg
--

CREATE FUNCTION bcf_reg."trg$assign_parent_no_and_name"() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'bcf_reg', 'pg_temp'
    AS $$
begin
  if NEW.no is null then
    NEW.no := nextval('bcf_reg.parent_no_sequence');
  end if;

  if coalesce(NEW.name, '') = '' then
    NEW.name := bcf_reg_config.create_parent_name(NEW.no);
  end if;
  
  return NEW;
end;
$$;


ALTER FUNCTION bcf_reg."trg$assign_parent_no_and_name"() OWNER TO bcf_reg;

--
-- Name: trg$biur_salts(); Type: FUNCTION; Schema: bcf_reg; Owner: bcf_reg
--

CREATE FUNCTION bcf_reg."trg$biur_salts"() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'bcf_reg', 'pg_temp'
    AS $$
begin
  if NEW.molfile is not null then
    --                                                        +- 'true' = retain 2D depiction.
    NEW.molecule = rdkit.mol_from_ctab(NEW.molfile::cstring, true);
  end if;

  if NEW.auto_calc_properties = 'Y' then
    if NEW.molfile is not null then
      --                                                 +- 'true' = separate isotopes.
      NEW.sum_formula := rdkit.mol_formula(NEW.molecule, true)::text;
    end if;

    -- Pretty-print formula.
    NEW.sum_formula = proteax.formula_add(NEW.sum_formula, '');

    NEW.mw_avg      = proteax.formula_mass_avg(NEW.sum_formula);
    NEW.mw_mono     = proteax.formula_mass_mono(NEW.sum_formula);
  end if;

  return NEW;
end;
$$;


ALTER FUNCTION bcf_reg."trg$biur_salts"() OWNER TO bcf_reg;

--
-- Name: trg$calc_compound_props(); Type: FUNCTION; Schema: bcf_reg; Owner: bcf_reg
--

CREATE FUNCTION bcf_reg."trg$calc_compound_props"() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'bcf_reg, pg_temp'
    AS $_$

declare
  salt_mw_avg double precision;
  salt_mw_mono double precision;
  salt_sum_formula text;
  --
  parent_mw_avg double precision;
  parent_mw_mono double precision;
  parent_sum_formula text;
  --
  new_mw_avg double precision;
  new_mw_mono double precision;
  new_sum_formula text;
  new_theor_struct_fraction double precision;
  --
  update_count integer;
begin
  select
      slt.mw_avg, slt.mw_mono, slt.sum_formula
    into strict
      salt_mw_avg, salt_mw_mono, salt_sum_formula
    from bcf_reg.salts slt
   where id = NEW.salt_id;

  select
      par_prop.mw_avg, par_prop.mw_mono, par_prop.sum_formula
    into strict
      parent_mw_avg, parent_mw_mono, parent_sum_formula
    from bcf_reg.parents par
    join bcf_reg.parents$calc_props par_prop on par_prop.parent_id = par.id
   where par.id = NEW.parent_id;

  new_mw_avg  := (parent_mw_avg  * NEW.structure_ratio + salt_mw_avg  * NEW.salt_ratio) / NEW.structure_ratio;
  new_mw_mono := (parent_mw_mono * NEW.structure_ratio + salt_mw_mono * NEW.salt_ratio) / NEW.structure_ratio;

  /* We do not attempt to reduce structure ratios >1 to see if we can make
     a sum formula that represents a single parent molecule only.
     A 2:3 ratio would be reducible to a per-structure sum formula if salt
     formula element counts were all divisible by 3. However, that is rather
     complicated to implement so we won''t bother. */
  if NEW.structure_ratio = 1 and NEW.salt_ratio = 1 then
    new_sum_formula := proteax.formula_add(parent_sum_formula, salt_sum_formula);
  elsif NEW.structure_ratio = 1 and NEW.salt_ratio > 1 then
    new_sum_formula := proteax.formula_add(parent_sum_formula, proteax.formula_mult(salt_sum_formula, NEW.salt_ratio));
  else
    new_sum_formula := ((((((NEW.structure_ratio || 'x('::text) || parent_sum_formula) || ') + '::text) || NEW.salt_ratio) || 'x('::text) || salt_sum_formula) || ')'::text;
  end if;

  if new_mw_avg > 0.0 then
    new_theor_struct_fraction := parent_mw_avg / new_mw_avg;
  else
    new_theor_struct_fraction := 0;
  end if;

  if TG_OP = 'INSERT' then
    insert into bcf_reg.compounds$calc_props
      (compound_id, mw_avg,     mw_mono,     sum_formula,    theoretical_structure_fraction)
    values
      (NEW.id,      new_mw_avg, new_mw_mono, new_sum_formula, new_theor_struct_fraction);

  elsif TG_OP = 'UPDATE' then
    update bcf_reg.compounds$calc_props
       set mw_avg = new_mw_avg, mw_mono = new_mw_mono, sum_formula = new_sum_formula,
           theoretical_structure_fraction = new_theor_struct_fraction
     where compound_id = NEW.id;

    get diagnostics update_count = row_count;
    -- If update fails, something is wrong.
    if update_count = 0 then
      raise exception 'BCF_REG BUG: Compound calculated properties: Missing CALC_PROPS row for ID %.', NEW.id;
    end if;
  else
    raise exception 'Internal bug: Insert/Update trigger called on % operation.', TG_OP;
  end if;
  
  return NEW;
end;

$_$;


ALTER FUNCTION bcf_reg."trg$calc_compound_props"() OWNER TO bcf_reg;

--
-- Name: trg$calc_parent_props_and_check_dupreason(); Type: FUNCTION; Schema: bcf_reg; Owner: bcf_reg
--

CREATE FUNCTION bcf_reg."trg$calc_parent_props_and_check_dupreason"() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'bcf_reg, pg_temp'
    AS $_$
declare
  the_molecule rdkit.mol;
  --
  the_avg_mw double precision;
  the_mono_mw double precision;
  the_sum_formula text;
  the_inchi_key text;
  the_svg_rendering text;
  --
  new_structure_key text;
  new_duplicate_reason text;
  old_structure_key text;
  old_duplicate_reason text;
  --
  dup_count integer;
  structure_changed boolean;
begin
  -- Read molecule and calculate structure key.
  if NEW.primary_type <> 'M' then
    raise exception 'This database only supports registrations in molfile format.';
  end if;
  
  the_molecule := rdkit.mol_from_ctab(NEW.original_registration::cstring, true);
  if the_molecule is null then
    raise exception 'The structure molfile could not be read.';
  end if;

  the_inchi_key := rdkit.mol_inchikey(the_molecule)::text;
  new_structure_key := the_inchi_key;
  if coalesce(new_structure_key, '') = '' then
    raise exception 'The structure could not have an InChI key generated.';
  end if;


  /**
    Set a parent structure key and check that DUPLICATE_REASON is set to a valid value.
  **/
  new_duplicate_reason := coalesce(NEW.duplicate_reason, '');

  -- No-Structure-s have the below InChI key. Treat each No-Structure as a
  -- unique structure.
  if new_structure_key = 'MOSFIJXAXDLOML-UHFFFAOYSA-N' then
    new_duplicate_reason := 'No-Structure ID ' || NEW.id;
    dup_count := 1;
  else
    select count(*) into dup_count
      from bcf_reg.parents
     where structure_key = new_structure_key
       and id <> NEW.id;
  end if;

  NEW.structure_key    := new_structure_key;
  NEW.duplicate_reason := new_duplicate_reason;

  if TG_OP = 'INSERT' then
    if dup_count = 0 then
      if new_duplicate_reason <> '' then
        raise exception 'This parent structure is unique - DUPLICATE_REASON must be blank.';
      end if;
    else
      if new_duplicate_reason = '' then
        raise exception 'This parent structure has % duplicates - DUPLICATE_REASON must be non-blank.', dup_count;
      end if;
    end if;

  elsif TG_OP = 'UPDATE' then
    -- Structure is unique.
    if dup_count = 0 then
      if new_duplicate_reason <> '' then
        raise exception 'This parent structure is unique - DUPLICATE_REASON must be blank.';
      end if;
    -- Structure has duplicates.
    else
      old_structure_key    := coalesce(OLD.structure_key, '');
      old_duplicate_reason := coalesce(OLD.duplicate_reason, '');

      if new_structure_key <> old_structure_key then
        -- Structure changed, and it is now a duplicate of another: DUPLICATE_REASON must be non-blank.
        if new_duplicate_reason = '' then
          raise exception 'After changing the structure, this parent structure now has % duplicates - DUPLICATE_REASON must be non-blank.', dup_count;
        end if;
      else
        -- Structure not changed. Certain changes in DUPLICATE_REASON are allowed.
        if new_duplicate_reason = old_duplicate_reason then
          null; -- NEW = OLD: OK.
        elsif new_duplicate_reason <> '' then
          null; -- From blank or non-blank => non-blank (that is different from OLD): OK.
        elsif new_duplicate_reason = '' then
          -- Going from non-blank to blank is only allowed if none of the sibling duplicates have a blank DUPLICATE_REASON.
          -- Let's just disallow it for now.
          -- This check is arguably redundant since we have a unique constraint enforced on (STRUCTURE_KEY, DUPLICATE_REASON).
          -- But there is no harm done in providing a nice readable error message instead of a compressed constraint name.
          raise exception 'This parent structure has % duplicates - DUPLICATE_REASON must be non-blank.', dup_count;
        end if;
      end if;
    end if;
  else
    raise exception 'Invalid trigger operation % for trg$calc_parent_props_and_check_dupreason().', TG_OP;
  end if;

  /**
    Everything looks good. Calculate additional properties and save them.
  **/
  --                                                 +- 'true' = separate isotopes.
  the_sum_formula := rdkit.mol_formula(the_molecule, true)::text;
  -- Use proteax.formula_add() to pretty-print formula (with spaces).
  the_sum_formula := proteax.formula_add('aux:' || the_sum_formula, '');

  the_avg_mw      := proteax.formula_mass_avg(the_sum_formula);
  the_mono_mw     := proteax.formula_mass_mono(the_sum_formula);

  the_svg_rendering := aux_services.molfile_to_svg(NEW.original_registration, 250, 200);
  -- Fix-up namespaces so the SVG can be embedded straight into web pages.
  the_svg_rendering := replace(replace(the_svg_rendering, 'svg:', ''), 'xmlns:svg', 'xmlns');

  if TG_OP = 'INSERT' then
    insert into bcf_reg.parents$calc_props
      (parent_id, molecule,
       sum_formula, mw_avg, mw_mono,
       inchi_key, svg_rendering)
    values
      (NEW.id, the_molecule,
       the_sum_formula, the_avg_mw, the_mono_mw,
       the_inchi_key, the_svg_rendering);

  elsif TG_OP = 'UPDATE' then
    update bcf_reg.parents$calc_props
       set molecule = the_molecule,
           sum_formula = the_sum_formula,
           mw_avg = the_avg_mw,
           mw_mono = the_mono_mw,
           inchi_key = the_inchi_key,
           svg_rendering = the_svg_rendering
     where parent_id = OLD.id;
  end if;

  return NEW;
end;
$_$;


ALTER FUNCTION bcf_reg."trg$calc_parent_props_and_check_dupreason"() OWNER TO bcf_reg;

--
-- Name: trg$check_has_delete_reason(); Type: FUNCTION; Schema: bcf_reg; Owner: bcf_reg
--

CREATE FUNCTION bcf_reg."trg$check_has_delete_reason"() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'bcf_reg', 'pg_temp'
    AS $$
declare
  dummy_id integer;
begin
  select id into dummy_id
    from bcf_reg.delete_reasons
   where id = OLD.id;
  if not found then
    raise exception 'You must register a non-blank reason in the DELETE_REASONS table before you are allowed to delete this record from the "%" table.', TG_TABLE_NAME;
  end if;

  return OLD;
end;
$$;


ALTER FUNCTION bcf_reg."trg$check_has_delete_reason"() OWNER TO bcf_reg;

--
-- Name: trg$check_non_blank_update_reason(); Type: FUNCTION; Schema: bcf_reg; Owner: bcf_reg
--

CREATE FUNCTION bcf_reg."trg$check_non_blank_update_reason"() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'bcf_reg', 'pg_temp'
    AS $$
begin
  if coalesce(NEW.update_reason, '') = '' then
    raise exception 'You must provide a non-blank reason for updating a record in the "%" table.', TG_TABLE_NAME;
  end if;
  if coalesce(NEW.update_reason, '') = coalesce(OLD.update_reason, '') then
    raise exception 'The reason for updating a record in the "%" table may not be identical to the previous reason given.', TG_TABLE_NAME;
  end if;

  return NEW;
end;
$$;


ALTER FUNCTION bcf_reg."trg$check_non_blank_update_reason"() OWNER TO bcf_reg;

--
-- Name: trg$jn$compounds(); Type: FUNCTION; Schema: bcf_reg; Owner: bcf_reg
--

CREATE FUNCTION bcf_reg."trg$jn$compounds"() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'bcf_reg', 'pg_temp'
    AS $_$ begin
  if TG_OP = 'INSERT' then 
    insert into bcf_reg.jn$compounds select current_timestamp, 'INS', session_user, NEW.*; 
  elsif TG_OP = 'UPDATE' then 
    insert into bcf_reg.jn$compounds select current_timestamp, 'UPD', session_user, NEW.*; 
  elsif TG_OP = 'DELETE' then 
    insert into bcf_reg.jn$compounds select current_timestamp, 'DEL', session_user, OLD.*; 
  end if;
  return NULL;
end $_$;


ALTER FUNCTION bcf_reg."trg$jn$compounds"() OWNER TO bcf_reg;

--
-- Name: trg$jn$parents(); Type: FUNCTION; Schema: bcf_reg; Owner: bcf_reg
--

CREATE FUNCTION bcf_reg."trg$jn$parents"() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'bcf_reg', 'pg_temp'
    AS $_$ begin
  if TG_OP = 'INSERT' then 
    insert into bcf_reg.jn$parents select current_timestamp, 'INS', session_user, NEW.*; 
  elsif TG_OP = 'UPDATE' then 
    insert into bcf_reg.jn$parents select current_timestamp, 'UPD', session_user, NEW.*; 
  elsif TG_OP = 'DELETE' then 
    insert into bcf_reg.jn$parents select current_timestamp, 'DEL', session_user, OLD.*; 
  end if;
  return NULL;
end $_$;


ALTER FUNCTION bcf_reg."trg$jn$parents"() OWNER TO bcf_reg;

--
-- Name: trg$jn$salts(); Type: FUNCTION; Schema: bcf_reg; Owner: bcf_reg
--

CREATE FUNCTION bcf_reg."trg$jn$salts"() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'bcf_reg', 'pg_temp'
    AS $_$ begin
  if TG_OP = 'INSERT' then 
    insert into bcf_reg.jn$salts select current_timestamp, 'INS', session_user, NEW.*; 
  elsif TG_OP = 'UPDATE' then 
    insert into bcf_reg.jn$salts select current_timestamp, 'UPD', session_user, NEW.*; 
  elsif TG_OP = 'DELETE' then 
    insert into bcf_reg.jn$salts select current_timestamp, 'DEL', session_user, OLD.*; 
  end if;
  return NULL;
end $_$;


ALTER FUNCTION bcf_reg."trg$jn$salts"() OWNER TO bcf_reg;

--
-- Name: trg$set_updated_fields(); Type: FUNCTION; Schema: bcf_reg; Owner: bcf_reg
--

CREATE FUNCTION bcf_reg."trg$set_updated_fields"() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'bcf_reg', 'pg_temp'
    AS $$
begin
  NEW.updated_by = session_user;
  NEW.updated_on = current_timestamp;

  return NEW;
end;
$$;


ALTER FUNCTION bcf_reg."trg$set_updated_fields"() OWNER TO bcf_reg;

--
-- Name: trg$update_unique_names(); Type: FUNCTION; Schema: bcf_reg; Owner: bcf_reg
--

CREATE FUNCTION bcf_reg."trg$update_unique_names"() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'bcf_reg', 'pg_temp'
    AS $_$
begin
  if TG_OP = 'INSERT' then
    insert into bcf_reg."unique$names"
      (id, source_table, name)
    values
      (NEW.id, TG_TABLE_NAME, NEW.name);

  elsif TG_OP = 'UPDATE' then
    delete from bcf_reg."unique$names"
     where source_table = TG_TABLE_NAME
       and trim(upper(name)) = trim(upper(OLD.name));

    insert into bcf_reg."unique$names"
      (id, source_table, name)
    values
      (NEW.id, TG_TABLE_NAME, NEW.name);

  else
    delete from bcf_reg."unique$names"
     where source_table = TG_TABLE_NAME
       and trim(upper(name)) = trim(upper(OLD.name));
  end if;

  return NEW;
end;
$_$;


ALTER FUNCTION bcf_reg."trg$update_unique_names"() OWNER TO bcf_reg;

--
-- Name: create_compound_name(integer, text); Type: FUNCTION; Schema: bcf_reg_config; Owner: bcf_reg
--

CREATE FUNCTION bcf_reg_config.create_compound_name(a_parent_no integer, a_salt_code text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$
  select 'CMP' || trim(to_char(a_parent_no, '000000')) || '_' || a_salt_code;  -- <== Company-specific rule.
$$;


ALTER FUNCTION bcf_reg_config.create_compound_name(a_parent_no integer, a_salt_code text) OWNER TO bcf_reg;

--
-- Name: create_parent_name(integer); Type: FUNCTION; Schema: bcf_reg_config; Owner: bcf_reg
--

CREATE FUNCTION bcf_reg_config.create_parent_name(a_parent_no integer) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$
  select 'PAR' || trim(to_char(a_parent_no, '000000'));  -- <== Company-specific rule.
$$;


ALTER FUNCTION bcf_reg_config.create_parent_name(a_parent_no integer) OWNER TO bcf_reg;

--
-- Name: display_user_name(text); Type: FUNCTION; Schema: bcf_reg_config; Owner: bcf_reg_facade
--

CREATE FUNCTION bcf_reg_config.display_user_name(a_user_name text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$
 select upper(replace(a_user_name, 'example$', ''))  -- <== Company-specific rule.
$_$;


ALTER FUNCTION bcf_reg_config.display_user_name(a_user_name text) OWNER TO bcf_reg_facade;

--
-- Name: FUNCTION display_user_name(a_user_name text); Type: COMMENT; Schema: bcf_reg_config; Owner: bcf_reg_facade
--

COMMENT ON FUNCTION bcf_reg_config.display_user_name(a_user_name text) IS 'Translate a DB user account name into display-friendly initials.';


--
-- Name: initials_to_account_name(text); Type: FUNCTION; Schema: bcf_reg_config; Owner: bcf_reg_facade
--

CREATE FUNCTION bcf_reg_config.initials_to_account_name(an_initials text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$
 select lower('example$' || trim(an_initials))  -- <== Company-specific rule.
$_$;


ALTER FUNCTION bcf_reg_config.initials_to_account_name(an_initials text) OWNER TO bcf_reg_facade;

--
-- Name: FUNCTION initials_to_account_name(an_initials text); Type: COMMENT; Schema: bcf_reg_config; Owner: bcf_reg_facade
--

COMMENT ON FUNCTION bcf_reg_config.initials_to_account_name(an_initials text) IS 'Translate initials into a DB user account name.';


--
-- Name: read_property(text, text, text, boolean); Type: FUNCTION; Schema: bcf_reg_config; Owner: postgres
--

CREATE FUNCTION bcf_reg_config.read_property(a_table_name text, a_property_name text, default_value text DEFAULT NULL::text, raise_error_on_notexist boolean DEFAULT true) RETURNS text
    LANGUAGE plpgsql
    AS $_$
declare
  result text;
  found_count integer;
begin
  execute 
    ' select value '
  ||'   from bcf_reg_config.' || quote_ident(a_table_name)
  ||'  where property = $1; '
  using a_property_name into result;

  get diagnostics found_count = row_count; 

  if found_count > 1 then
    raise exception 'Multiple definitions of property "%" in config table "%".', a_property_name, a_table_name;
  end if;
  if found_count = 0 then
    if raise_error_on_notexist then
      raise exception 'No property named "%" in config table "%".', a_property_name, a_table_name;
    else
      result := default_value;
    end if;
  end if;

  return result;
end;
$_$;


ALTER FUNCTION bcf_reg_config.read_property(a_table_name text, a_property_name text, default_value text, raise_error_on_notexist boolean) OWNER TO postgres;

--
-- Name: FUNCTION read_property(a_table_name text, a_property_name text, default_value text, raise_error_on_notexist boolean); Type: COMMENT; Schema: bcf_reg_config; Owner: postgres
--

COMMENT ON FUNCTION bcf_reg_config.read_property(a_table_name text, a_property_name text, default_value text, raise_error_on_notexist boolean) IS 'Read a property from a (property, value) table in bcf_reg_config. Per default the property must exist or an error will be raised. If you allow non-existing properties, the default value will be returned when the property does not exist.';


--
-- Name: trg$jn$db_config(); Type: FUNCTION; Schema: bcf_reg_config; Owner: postgres
--

CREATE FUNCTION bcf_reg_config."trg$jn$db_config"() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'bcf_reg_config', 'pg_temp'
    AS $_$ begin
  if TG_OP = 'INSERT' then 
    insert into bcf_reg_config.jn$db_config select current_timestamp, 'INS', session_user, NEW.*; 
  elsif TG_OP = 'UPDATE' then 
    insert into bcf_reg_config.jn$db_config select current_timestamp, 'UPD', session_user, NEW.*; 
  elsif TG_OP = 'DELETE' then 
    insert into bcf_reg_config.jn$db_config select current_timestamp, 'DEL', session_user, OLD.*; 
  end if;
  return NULL;
end $_$;


ALTER FUNCTION bcf_reg_config."trg$jn$db_config"() OWNER TO postgres;

--
-- Name: active_sessions(); Type: FUNCTION; Schema: bcf_reg_facade; Owner: postgres
--

CREATE FUNCTION bcf_reg_facade.active_sessions() RETURNS TABLE(user_name name, application_name text, client_address inet, logged_on timestamp with time zone, state text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'bcf_reg_facade', 'pg_catalog'
    AS $$
begin
  return query
    select
      act.usename as user_name,
      act.application_name,
      act.client_addr as client_address,
      act.backend_start as logged_on,
      act.state
    from pg_stat_activity act;
end
$$;


ALTER FUNCTION bcf_reg_facade.active_sessions() OWNER TO postgres;

--
-- Name: append_count_line(text, integer, integer, text, text, text); Type: FUNCTION; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE FUNCTION bcf_reg_facade.append_count_line(prev_lines text, a_level integer, a_count integer, an_item_name text, an_item_plural_suffix text, an_item_list text) RETURNS text
    LANGUAGE plpgsql
    AS $$
declare
  result text;
begin
  if a_count <= 0 then
    return prev_lines;
  end if;

  result := coalesce(prev_lines, '');
  if result <> '' then
    result := result || Chr(10);
  end if;

  result := result || repeat(' ', a_level * 2) || a_count || ' ' || bcf_reg_facade.pluralized(a_count, an_item_name, an_item_plural_suffix);

  if an_item_list <> '' then
    if length(an_item_list) > 60 then
      result := result || ' (' || substring(an_item_list, 1, 60) || '...)';
    else
      result := result || ' (' || an_item_list || ')';
    end if;
  end if;

  return result;
end
$$;


ALTER FUNCTION bcf_reg_facade.append_count_line(prev_lines text, a_level integer, a_count integer, an_item_name text, an_item_plural_suffix text, an_item_list text) OWNER TO bcf_reg_facade;

--
-- Name: FUNCTION append_count_line(prev_lines text, a_level integer, a_count integer, an_item_name text, an_item_plural_suffix text, an_item_list text); Type: COMMENT; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

COMMENT ON FUNCTION bcf_reg_facade.append_count_line(prev_lines text, a_level integer, a_count integer, an_item_name text, an_item_plural_suffix text, an_item_list text) IS 'Internal: Append an item count line to an existing message and returns the result, adjusting for plural form of item name as necessary. Requires that "a_count" > 0, otherwise the result is equal to the original message.';


--
-- Name: coltype_to_fieldtype(text, text, text); Type: FUNCTION; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE FUNCTION bcf_reg_facade.coltype_to_fieldtype(col_data_type text, col_udt_name text, unknown_prefix text DEFAULT ''::text) RETURNS text
    LANGUAGE plpgsql
    AS $$
begin
  if col_data_type = 'USER-DEFINED' then
    if col_udt_name = 'mol' then
      return 'molecule';
    else
      return unknown_prefix || col_udt_name;
    end if;
  elsif col_data_type = 'text' then
    return 'string';
  elsif col_data_type = 'character' then
    return 'string';
  elsif col_data_type = 'boolean' then
    return 'boolean';
  elsif col_data_type = 'integer' then
    return 'number';
  elsif col_data_type = 'double precision' or col_data_type = 'numeric' then
    return 'number';
  elsif col_data_type = 'timestamp with time zone' then
    return 'datetime';
  else
    return unknown_prefix || col_data_type::text;
  end if;
end
$$;


ALTER FUNCTION bcf_reg_facade.coltype_to_fieldtype(col_data_type text, col_udt_name text, unknown_prefix text) OWNER TO bcf_reg_facade;

--
-- Name: FUNCTION coltype_to_fieldtype(col_data_type text, col_udt_name text, unknown_prefix text); Type: COMMENT; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

COMMENT ON FUNCTION bcf_reg_facade.coltype_to_fieldtype(col_data_type text, col_udt_name text, unknown_prefix text) IS 'Internal, search: Maps Postgres column types to query builder field types.';


--
-- Name: create_search_query(text); Type: FUNCTION; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE FUNCTION bcf_reg_facade.create_search_query(a_root_name text) RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'bcf_reg_facade', 'pg_catalog'
    AS $_$
declare
  THIS_SCHEMA constant text := 'bcf_reg_facade';
  root_view_name text;
  root_key_field_name text;
  qry text := '';
  from_clause text;
  where_clause text := '';
  r record;
  criteria text;
  criteria_prefix text;
begin
  select
      quote_ident(qt.query_view), quote_ident(qtr.key_field)
    into root_view_name, root_key_field_name
    from bcf_reg_facade.query_tree_roots qtr
         inner join bcf_reg_facade.query_trees qt on qt.query_tree_root_id = qtr.id
   where qt.parent_item_id is null
     and qtr.display_name = a_root_name;

  if not found then
    raise exception '"%" is not a recognized query root name.', a_root_name;
  end if;

  qry := 'select distinct ' || root_key_field_name;

  for r in (
    select
        qtr.display_name as root_name,
        qfu.item_no,
        qt.id as item_id,
        qt.parent_item_id,
        qt.parent_link,
        qt.query_view,
        qt.display_name as item_display_name,
        -- 'query_field_name' is only used for reporting an invalid field name (one that
        -- doesn't map to a view or table field name according to information_schema.
        qfu.field_name as query_field_name,
        cols.column_name::text as field_name,
        coltype_to_fieldtype(cols.data_type, cols.udt_name, '?unknown?') as field_type,
        fieldtype_to_criteriafield(coltype_to_fieldtype(cols.data_type, cols.udt_name, '?unknown?')) as criteria_field,
        trim(lower(qfu.operator)) as operator,
        qfu.options
      from pg_temp.tmp$query_fields_uploaded qfu
           join bcf_reg_facade.query_trees qt on qt.id = qfu.query_item_id
           join bcf_reg_facade.query_tree_roots qtr on qtr.id = qt.query_tree_root_id
           left outer join information_schema.columns cols on cols.table_name = qt.query_view and cols.column_name = qfu.field_name and cols.table_schema = THIS_SCHEMA
     order by qfu.item_no
  )
  loop
    if r.root_name <> a_root_name then
      raise exception 'The "%" field is from the query root "%". It cannot be used in a "%"-rooted query.', r.item_display_name || '.' || r.field_name, r.root_name, a_root_name;
    end if;
    if r.field_name is null then
      raise exception 'Invalid field name "%".', r.query_field_name;
    end if;

    criteria := create_sql_filter_for_field(r.query_view, r.field_name, r.field_type, r.operator, r.criteria_field, r.item_no);

    if where_clause = '' then
      where_clause := criteria;
    else
      where_clause := where_clause || Chr(10) || '   and ' || criteria;
    end if;
  end loop;

  -- Generate list of tables required to execute the query.
  with recursive join_levels (parent_item_id, id, level_no, display_name, query_view, parent_link) as (
    select parent_item_id, id, level_no, display_name, query_view, parent_link
      from bcf_reg_facade.query_trees root_node
        -- Start from the query views the user has chosen fields from.
     where id in (select query_item_id from pg_temp.tmp$query_fields_uploaded)

    -- Not "union all"; we want distinct values. The "union" also guards against
    -- circular view linking, so we won't end up with a session that hangs in an
    -- infinite loop in case of circular query view configurations.
    union

    -- Traverse parent views until root view reached.
    select par.parent_item_id, par.id, par.level_no, par.display_name, par.query_view, par.parent_link
      from bcf_reg_facade.query_trees par
      join join_levels chld on chld.parent_item_id = par.id
  )
  select string_agg(from_stmt, Chr(10) order by level_no)
    into from_clause
    from (
      select
          level_no,
          case
            when coalesce(trim(parent_link), '') = '' then '  from ' || THIS_SCHEMA || '.' || quote_ident(query_view)
            else '  ' || parent_link
          end as from_stmt
        from join_levels j
    ) from_statements;

  -- "from_clause" may be NULL if no criteria entered, meaning "Retrieve all".
  if from_clause is null then
    qry := qry || Chr(10) || '  from ' || THIS_SCHEMA || '.' || root_view_name;
  else
    qry := qry || Chr(10) || from_clause;
  end if;

  if where_clause <> '' then
    qry := qry || Chr(10) || ' where ' || trim(where_clause);
  end if;

  return qry;
end
$_$;


ALTER FUNCTION bcf_reg_facade.create_search_query(a_root_name text) OWNER TO bcf_reg_facade;

--
-- Name: FUNCTION create_search_query(a_root_name text); Type: COMMENT; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

COMMENT ON FUNCTION bcf_reg_facade.create_search_query(a_root_name text) IS 'Creates a SQL query from the query fields uploaded to temporary table "tmp$query_fields_uploaded".';


--
-- Name: create_sql_filter_for_field(text, text, text, text, text, integer); Type: FUNCTION; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE FUNCTION bcf_reg_facade.create_sql_filter_for_field(view_name text, field_name text, field_type text, _operator text, criteria_fieldname text, item_no integer) RETURNS text
    LANGUAGE plpgsql
    AS $_$
declare
  the_operator text;
  date_adjust text;
  sql_filter text;
begin
  -- ** Molecule **
  if field_type = 'molecule' then
    if not _operator = any(array ['sss', 'exact match', 'similarity']) then
      raise exception 'Invalid molecule search operator "%".', _operator;
    end if;

    the_operator := '*invalid*';
    if _operator = 'sss' then
      the_operator := 'operator(rdkit.@>)';
    elsif _operator = 'exact match' then
      the_operator := 'operator(rdkit.=)';
    elsif _operator = 'similarity' then
      the_operator := 'operator(rdkit.%)';
    end if;
    
    if _operator = 'similarity' then
      sql_filter := 
        'rdkit.morganbv_fp(' || quote_ident(view_name) || '.' || quote_ident(field_name) || ') ' || the_operator || ' '
        || '(select rdkit.morganbv_fp(rdkit.mol_from_ctab(' || criteria_fieldname || '::cstring)) from pg_temp.tmp$query_fields_uploaded'
        || '  where item_no = ' || item_no || ')';
    else
      sql_filter := 
        quote_ident(view_name) || '.' || quote_ident(field_name) || ' ' || the_operator || ' '
        || '(select rdkit.mol_from_ctab(' || criteria_fieldname || '::cstring) from pg_temp.tmp$query_fields_uploaded'
        || '  where item_no = ' || item_no || ')';
    end if;

  -- ** Date **
  elsif field_type = 'datetime' then
    if not _operator = any(array ['>=', '<=', 'between', '=', '<>']) then
      raise exception 'Invalid date search operator "%".', _operator;
    end if;

    date_adjust := '';
    if _operator = 'between' or _operator = '<=' or _operator = '=' or _operator = '<>' then
      date_adjust := '+ ''1 day''::interval';
    end if;

    if _operator = 'between' then
      sql_filter := 
        quote_ident(view_name) || '.' || quote_ident(field_name) || ' ' || _operator || ' '
        || '(select date_trunc(''day'', least(' || criteria_fieldname || '1, ' || criteria_fieldname || '2)) from pg_temp.tmp$query_fields_uploaded'
        || '  where item_no = ' || item_no || ') and '
        || '(select date_trunc(''day'', greatest(' || criteria_fieldname || '1, ' || criteria_fieldname || '2)) ' || date_adjust || ' from pg_temp.tmp$query_fields_uploaded'
        || '  where item_no = ' || item_no || ')';
    elsif _operator = '=' then
      sql_filter := 
        quote_ident(view_name) || '.' || quote_ident(field_name) || ' between '
        || '(select date_trunc(''day'', ' || criteria_fieldname || '1) from pg_temp.tmp$query_fields_uploaded'
        || '  where item_no = ' || item_no || ') and '
        || '(select date_trunc(''day'', ' || criteria_fieldname || '1) ' || date_adjust || ' from pg_temp.tmp$query_fields_uploaded'
        || '  where item_no = ' || item_no || ')';
    elsif _operator = '<>' then
      sql_filter := 
        '(' || quote_ident(view_name) || '.' || quote_ident(field_name) || ' < '
        || '(select date_trunc(''day'', ' || criteria_fieldname || '1) from pg_temp.tmp$query_fields_uploaded'
        || '  where item_no = ' || item_no || ') or '
        || quote_ident(view_name) || '.' || quote_ident(field_name) || ' >= '
        || '(select date_trunc(''day'', ' || criteria_fieldname || '1) ' || date_adjust || ' from pg_temp.tmp$query_fields_uploaded'
        || '  where item_no = ' || item_no || ') )';
    else
      sql_filter := 
        quote_ident(view_name) || '.' || quote_ident(field_name) || ' ' || _operator || ' '
        || '(select date_trunc(''day'', ' || criteria_fieldname || '1) ' || date_adjust || ' from pg_temp.tmp$query_fields_uploaded'
        || '  where item_no = ' || item_no || ')';
    end if;

  -- ** Text **
  elsif field_type = 'string' then
    if not _operator = any(array ['contains', 'contains not', 'like', 'not like', '=', '>=', '<=', '<>', 'in list']) then
      raise exception 'Invalid text search operator "%".', _operator;
    end if;

    if _operator = 'in list' then
      sql_filter := 'upper(' || quote_ident(view_name) || '.' || quote_ident(field_name) || ') = ANY ('
        || 'string_to_array(upper(replace('
        || '  (select ' || criteria_fieldname || ' from pg_temp.tmp$query_fields_uploaded'
        || '    where item_no = ' || item_no || ') '
        || ', Chr(13), '''')), Chr(10))'
        || ')';
    else
      sql_filter := 'upper(' || quote_ident(view_name) || '.' || quote_ident(field_name) || ') ';

      if _operator = 'contains' then
        sql_filter := sql_filter || 'like ''%'' || ';
      elsif _operator = 'contains not' then
        sql_filter := sql_filter || 'not like ''%'' || ';
      else
        sql_filter := sql_filter || _operator || ' ';
      end if;
      if _operator = 'contains' or _operator = 'contains not' then
        sql_filter := sql_filter || 'replace(replace(replace(';
      end if;
      sql_filter := sql_filter
        || '(select upper(' || criteria_fieldname || ') from pg_temp.tmp$query_fields_uploaded'
        || '  where item_no = ' || item_no || ') ';
      if _operator = 'contains' or _operator = 'contains not' then
        sql_filter := sql_filter || ', ''\'', ''\\''), ''_'', ''\_''), ''%'', ''\%'') || ''%'' escape ''\'' ';
      end if;
    end if;

  -- ** Number **
  elsif field_type = 'number' then
    if not _operator = any(array ['=', '>=', '<=', '<>']) then
      raise exception 'Invalid number search operator "%".', _operator;
    end if;

    sql_filter := 
      quote_ident(view_name) || '.' || quote_ident(field_name) || ' ' || _operator || ' '
      || '(select ' || criteria_fieldname || ' from pg_temp.tmp$query_fields_uploaded'
      || '  where item_no = ' || item_no || ')';

  -- ** Boolean **
  elsif field_type = 'boolean' then
    if not _operator = '=' then
      raise exception 'Invalid boolean search operator "%".', _operator;
    end if;

    sql_filter := 
      quote_ident(view_name) || '.' || quote_ident(field_name) || ' ' || _operator || ' '
      || '(select (' || criteria_fieldname || ' = ''Y'') from pg_temp.tmp$query_fields_uploaded'
      || '  where item_no = ' || item_no || ')';

  -- ** Unsupported **
  else
    raise exception 'Unsupported field type "%".', field_type;
  end if;

  return sql_filter;
end
$_$;


ALTER FUNCTION bcf_reg_facade.create_sql_filter_for_field(view_name text, field_name text, field_type text, _operator text, criteria_fieldname text, item_no integer) OWNER TO bcf_reg_facade;

--
-- Name: criteria_to_string(text, text, text, text, double precision, timestamp with time zone, timestamp with time zone); Type: FUNCTION; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE FUNCTION bcf_reg_facade.criteria_to_string(a_field_type text, an_operator text, an_options text, a_text text, a_number double precision, a_date1 timestamp with time zone, a_date2 timestamp with time zone) RETURNS text
    LANGUAGE plpgsql
    AS $$
declare
  result text;
begin
  if a_field_type = 'string' then
    if an_operator = 'in list' then
      if length(a_text) > 200 then
        result := an_operator || ' "' || substr(replace(replace(a_text, Chr(13), ''), Chr(10), '; '), 1, 197) || '..."';
      else
        result := replace(replace(a_text, Chr(13), ''), Chr(10), '; ');
        -- Remove trailing delimiter if present.
        if substr(result, length(result) - 1, 2) = '; ' then
          result := substr(result, 1, length(result) - 2);
        end if;
        result := an_operator || ' "' || result || '"';
      end if;
    else
      result := an_operator || ' "' || replace(a_text, '"', '""') || '"';
    end if;

  elsif a_field_type = 'number' then
    result := an_operator || ' ' || a_number;

  elsif a_field_type = 'boolean' then
    if a_text = 'Y' then
      --        Checkmark.
      result := U&'\2713' || ' (Yes)';
    else
      --        Ballot mark (x).
      result := U&'\2717' || ' (No)';
    end if;

  elsif a_field_type = 'datetime' then
    result := an_operator || ' ' || substr(date_trunc('day', least(a_date1, a_date2))::text, 1, 10);
    if an_operator = 'between' then
      result := result  || ' and ' || substr(date_trunc('day', greatest(a_date1, a_date2))::text, 1, 10);
    end if;

  elsif a_field_type = 'molecule' then
    if an_operator = 'similarity' then
      result := an_operator || ' (' || an_options || '%) [smiles:' || rdkit.mol_from_ctab(a_text::cstring)::text || ']';
    else
      result := an_operator || ' [smiles:' || rdkit.mol_from_ctab(a_text::cstring)::text || ']';
    end if;

  else
    raise exception 'Cannot create human-readable query field configuration: Unsupported field type "%".', a_field_type;
  end if;

  return result;
end
$$;


ALTER FUNCTION bcf_reg_facade.criteria_to_string(a_field_type text, an_operator text, an_options text, a_text text, a_number double precision, a_date1 timestamp with time zone, a_date2 timestamp with time zone) OWNER TO bcf_reg_facade;

--
-- Name: FUNCTION criteria_to_string(a_field_type text, an_operator text, an_options text, a_text text, a_number double precision, a_date1 timestamp with time zone, a_date2 timestamp with time zone); Type: COMMENT; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

COMMENT ON FUNCTION bcf_reg_facade.criteria_to_string(a_field_type text, an_operator text, an_options text, a_text text, a_number double precision, a_date1 timestamp with time zone, a_date2 timestamp with time zone) IS 'Search: Create a human-readable string representation of a query field''s configuration.';


--
-- Name: default_query_fields(); Type: FUNCTION; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE FUNCTION bcf_reg_facade.default_query_fields() RETURNS TABLE(field_id integer, field_name text, field_type text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'bcf_reg_facade', 'pg_catalog'
    AS $$
begin
  return query
  select id as field_id, 'compound_no'::text as field_name, 'string'::text as field_type
    from bcf_reg_facade.query_trees
   where display_name = 'compounds'
     and query_tree_root_id = (select id from bcf_reg_facade.query_tree_roots where display_name = 'compounds')
  /**
    Can return multiple default fields by adding them like this:

  union all
  select id as field_id, 'structure_ratio' as field_name, 'number' as field_type
    from bcf_reg_facade.query_trees
   where display_name = 'compounds'
  **/
  ;
end;
$$;


ALTER FUNCTION bcf_reg_facade.default_query_fields() OWNER TO bcf_reg_facade;

--
-- Name: FUNCTION default_query_fields(); Type: COMMENT; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

COMMENT ON FUNCTION bcf_reg_facade.default_query_fields() IS 'Returns default query fields to setup when no previous searches have been run by end user.';


--
-- Name: display_user_name(text); Type: FUNCTION; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE FUNCTION bcf_reg_facade.display_user_name(a_user_name text) RETURNS text
    LANGUAGE sql IMMUTABLE SECURITY DEFINER
    SET search_path TO 'bcf_reg_facade', 'pg_catalog'
    AS $$ select bcf_reg_config.display_user_name(a_user_name) $$;


ALTER FUNCTION bcf_reg_facade.display_user_name(a_user_name text) OWNER TO bcf_reg_facade;

--
-- Name: FUNCTION display_user_name(a_user_name text); Type: COMMENT; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

COMMENT ON FUNCTION bcf_reg_facade.display_user_name(a_user_name text) IS 'Translate a DB user account name into display-friendly initials.';


--
-- Name: execute_search(text, boolean); Type: FUNCTION; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE FUNCTION bcf_reg_facade.execute_search(a_root_name text, within_current_list boolean) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'bcf_reg_facade', 'pg_temp'
    AS $_$
declare
  THIS_SCHEMA constant text := 'bcf_reg_facade';
  qry text;
  simil_percent text;
  simil_count integer;
  similarity_threshold double precision;
  qry_start_time timestamp with time zone;
  qry_done_time timestamp with time zone;
begin
  if within_current_list then
    -- Save current list into CURRENT_LIST1.
    delete from pg_temp.tmp$current_list1;
    insert into pg_temp.tmp$current_list1
    select * from pg_temp.tmp$current_list;
  end if;

  delete from pg_temp.tmp$current_list;

  qry := create_search_query(a_root_name);

  select string_agg(distinct qfu.options, '; ' order by qfu.options), count(distinct options)
    into simil_percent, simil_count
    from pg_temp.tmp$query_fields_uploaded qfu
    join bcf_reg_facade.query_trees qt on qt.id = qfu.query_item_id
    join bcf_reg_facade.query_tree_roots qtr on qtr.id = qt.query_tree_root_id
    left outer join information_schema.columns cols on cols.table_name = qt.query_view and cols.column_name = qfu.field_name and cols.table_schema = THIS_SCHEMA
   where coltype_to_fieldtype(cols.data_type, cols.udt_name, '?unknown?') = 'molecule'
     and qfu.operator = 'similarity';

  if simil_count > 1 then
    raise exception 'All structure similarity criteria must agree on using the same similarity threshold. You have specified % different thresholds ("%").', simil_count, simil_percent;
  end if;
  
  if simil_count = 1 then
    similarity_threshold := simil_percent::double precision;
    if similarity_threshold > 100.0 or similarity_threshold < 0.0 then
      raise exception 'Similarity threshold out of range: Must be 0..100 percent.';
    end if;
    execute 'set rdkit.tanimoto_threshold=' || (similarity_threshold / 100.0)::text;
  end if;

  -- Ensure that SSS queries are matched chirally by RDKit.
  execute 'set rdkit.do_chiral_sss=true; ';

  qry_start_time := clock_timestamp();
  execute 'insert into pg_temp.tmp$current_list (id) ' || qry;
  if within_current_list then
    -- Constrain result to the previous current list.
    delete from pg_temp.tmp$current_list2;
    insert into pg_temp.tmp$current_list2
    select * from pg_temp.tmp$current_list;

    delete from pg_temp.tmp$current_list;
    insert into pg_temp.tmp$current_list
    select * from pg_temp.tmp$current_list1
    intersect
    select * from pg_temp.tmp$current_list2;
  end if;
  qry_done_time := clock_timestamp();

  perform save_search(qry, qry_start_time, qry_done_time, within_current_list);
end
$_$;


ALTER FUNCTION bcf_reg_facade.execute_search(a_root_name text, within_current_list boolean) OWNER TO bcf_reg_facade;

--
-- Name: fieldtype_to_criteriafield(text); Type: FUNCTION; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE FUNCTION bcf_reg_facade.fieldtype_to_criteriafield(field_type text) RETURNS text
    LANGUAGE plpgsql
    AS $$
begin
  if field_type = 'molecule' or field_type = 'string' or field_type = 'boolean' then
    return 'criteria_text';
  elsif field_type = 'number' then
    return 'criteria_number';
  elsif field_type = 'datetime' then
    return 'criteria_date';
  else
    return field_type;
  end if;
end
$$;


ALTER FUNCTION bcf_reg_facade.fieldtype_to_criteriafield(field_type text) OWNER TO bcf_reg_facade;

--
-- Name: full_fieldname_path(text, integer); Type: FUNCTION; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE FUNCTION bcf_reg_facade.full_fieldname_path(a_fieldname text, a_parent_id integer) RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'bcf_reg_facade', 'pg_catalog'
    AS $$
declare
  full_path text;
  level_count integer := 0;
  the_parent_name text;
begin
  full_path := a_fieldname;
  loop
    -- Non-STRICT select into => a_parent_id will be set to NULL if no rows found.
    select parent_item_id, display_name into a_parent_id, the_parent_name
      from bcf_reg_facade.query_trees
     where id = a_parent_id;
    exit when a_parent_id is null;

    full_path := the_parent_name || '\' || full_path;

    level_count := level_count + 1;
    if level_count > 100 then
      raise exception 'Recursive loop detected in query tree definition (field name %) - or the tree is more than 100 levels deep (?!).', a_fieldname;
    end if;
  end loop;

  return full_path;
end
$$;


ALTER FUNCTION bcf_reg_facade.full_fieldname_path(a_fieldname text, a_parent_id integer) OWNER TO bcf_reg_facade;

--
-- Name: FUNCTION full_fieldname_path(a_fieldname text, a_parent_id integer); Type: COMMENT; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

COMMENT ON FUNCTION bcf_reg_facade.full_fieldname_path(a_fieldname text, a_parent_id integer) IS 'Search: Get field name, including its full path, of a query run field item.';


--
-- Name: get_compound_duplicates(text, integer, text, integer, integer); Type: FUNCTION; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE FUNCTION bcf_reg_facade.get_compound_duplicates(a_structure_key text, a_row_no integer, a_salt_name text, a_salt_ratio integer, a_structure_ratio integer) RETURNS TABLE(provenance text, duplicate_name text, are_ratios_equal boolean)
    LANGUAGE plpgsql
    AS $_$
begin
  return query
    select
        'DB', cmp.name,
        case
          when cmp.salt_ratio = a_salt_ratio and cmp.structure_ratio = a_structure_ratio then true
          else false
        end
      from bcf_reg.parents par
           join bcf_reg.compounds cmp on cmp.parent_id = par.id
           join bcf_reg.salts slt on slt.id = cmp.salt_id
     where par.structure_key = a_structure_key
       and trim(upper(slt.short_name)) = trim(upper(a_salt_name))
    union
    select
        'UPLOAD', 'Row[' || row_no::text || ']',
        case
          when salt_ratio = a_salt_ratio and structure_ratio = a_structure_ratio then true
          else false
        end
      from pg_temp.tmp$compound_upload
     where internal__structure_key = a_structure_key
       and trim(upper(salt_name)) = trim(upper(a_salt_name))
       and row_no < a_row_no;
end
$_$;


ALTER FUNCTION bcf_reg_facade.get_compound_duplicates(a_structure_key text, a_row_no integer, a_salt_name text, a_salt_ratio integer, a_structure_ratio integer) OWNER TO bcf_reg_facade;

--
-- Name: get_parent_duplicates(text, integer); Type: FUNCTION; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE FUNCTION bcf_reg_facade.get_parent_duplicates(a_structure_key text, a_row_no integer) RETURNS TABLE(provenance text, duplicate_name text)
    LANGUAGE plpgsql
    AS $_$
begin
  return query
    select 'DB', par.name
      from bcf_reg.parents par
     where par.structure_key = a_structure_key
    union
    select 'UPLOAD', 'Row[' || row_no::text || ']'
      from pg_temp.tmp$compound_upload
     where internal__structure_key = a_structure_key
       and row_no < a_row_no;
end
$_$;


ALTER FUNCTION bcf_reg_facade.get_parent_duplicates(a_structure_key text, a_row_no integer) OWNER TO bcf_reg_facade;

--
-- Name: get_priv_level(); Type: FUNCTION; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE FUNCTION bcf_reg_facade.get_priv_level() RETURNS TABLE(reg_priv_level integer, stock_priv_level integer)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'bcf_reg_facade', 'pg_catalog'
    AS $$
begin
  return query
  select privs.reg_priv_level, privs.stock_priv_level
    from bcf_auth.get_priv_levels_for_user(session_user) privs;
end;
$$;


ALTER FUNCTION bcf_reg_facade.get_priv_level() OWNER TO bcf_reg_facade;

--
-- Name: FUNCTION get_priv_level(); Type: COMMENT; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

COMMENT ON FUNCTION bcf_reg_facade.get_priv_level() IS 'Returns max. BCFReg and Stock privilege level for the currently logged in user.';


--
-- Name: get_query_fields(text); Type: FUNCTION; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE FUNCTION bcf_reg_facade.get_query_fields(a_root_name text) RETURNS TABLE(item_id integer, parent_item_id integer, item_display_name text, field_name text, field_type text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'bcf_reg_facade', 'pg_temp'
    AS $$
declare
  a_root_id integer;
begin
  select id into a_root_id
    from bcf_reg_facade.query_tree_roots
   where display_name = a_root_name;
  if not found then
    raise exception 'The "%" query root does not exist.', a_root_name;
  end if;

  return query
    select
        qt.id as item_id,
        qt.parent_item_id,
        qt.display_name as item_display_name,
        cols.column_name::text as field_name,
        coltype_to_fieldtype(cols.data_type::text, cols.udt_name::text) as field_type
      from bcf_reg_facade.query_trees qt
           join information_schema.columns cols on cols.table_name = qt.query_view and cols.table_schema = 'bcf_reg_facade'
     where qt.query_tree_root_id = a_root_id
           -- Suppress hidden fields.
       and not exists (
             select 1 from regexp_split_to_table(qt.hidden_fields, ';') as hidden_field
              where hidden_field = cols.column_name
           )
     order by qt.item_no, cols.ordinal_position;
end
$$;


ALTER FUNCTION bcf_reg_facade.get_query_fields(a_root_name text) OWNER TO bcf_reg_facade;

--
-- Name: get_query_roots(); Type: FUNCTION; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE FUNCTION bcf_reg_facade.get_query_roots() RETURNS TABLE(id integer, display_name text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'bcf_reg_facade', 'pg_temp'
    AS $$
begin
  return query
    select
        qtr.id,
        qtr.display_name
      from bcf_reg_facade.query_tree_roots qtr
     order by qtr.id;
end
$$;


ALTER FUNCTION bcf_reg_facade.get_query_roots() OWNER TO bcf_reg_facade;

--
-- Name: guess_query_root(text); Type: FUNCTION; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE FUNCTION bcf_reg_facade.guess_query_root(a_key_value text) RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'bcf_reg_facade', 'pg_temp'
    AS $_$
declare
  result text;
  v record;
  roots_row_count integer;
begin
  result := '';
  for v in (
    select
        qtr.display_name, qt.query_view, qtr.key_field 
      from bcf_reg_facade.query_tree_roots qtr
           inner join bcf_reg_facade.query_trees qt on qt.query_tree_root_id = qtr.id
     where qt.parent_item_id is null
  )
  loop
    execute
      'select 1 from bcf_reg_facade.' || quote_ident(v.query_view) 
      || ' where ' || quote_ident(v.key_field) || ' = $1;'
    using a_key_value;
	-- FOUND cannot be used since EXECUTE does not set it.
    get diagnostics roots_row_count = row_count;
    if roots_row_count > 0 then
      result := v.display_name;
      exit;
    end if;
  end loop;

  return result;
end;
$_$;


ALTER FUNCTION bcf_reg_facade.guess_query_root(a_key_value text) OWNER TO bcf_reg_facade;

--
-- Name: FUNCTION guess_query_root(a_key_value text); Type: COMMENT; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

COMMENT ON FUNCTION bcf_reg_facade.guess_query_root(a_key_value text) IS 'Guess the display name of the root that ''a_key_value'' belongs to.';


--
-- Name: init_current_list(); Type: FUNCTION; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE FUNCTION bcf_reg_facade.init_current_list() RETURNS void
    LANGUAGE plpgsql
    AS $_$
begin
  create temporary table if not exists tmp$current_list (id text);
  grant select, insert, delete on pg_temp.tmp$current_list to bcf_reg_facade;
  delete from pg_temp.tmp$current_list;  

  -- CURRENT_LIST1 and CURRENT_LIST2 used by search engine for list logic if
  -- end user wants to search within the domain of the existing current list.
  create temporary table if not exists tmp$current_list1 (id text);
  grant select, insert, delete on pg_temp.tmp$current_list1 to bcf_reg_facade;
  delete from pg_temp.tmp$current_list1;  

  create temporary table if not exists tmp$current_list2 (id text);
  grant select, insert, delete on pg_temp.tmp$current_list2 to bcf_reg_facade;
  delete from pg_temp.tmp$current_list2;  
end;
$_$;


ALTER FUNCTION bcf_reg_facade.init_current_list() OWNER TO bcf_reg_facade;

--
-- Name: init_currentlist_and_exec_search(text); Type: FUNCTION; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE FUNCTION bcf_reg_facade.init_currentlist_and_exec_search(a_root_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
  perform bcf_reg_facade.init_current_list();
  -- We have just initialized (reset) the current list so we can't search within it.
  --                                                   !
  perform bcf_reg_facade.execute_search(a_root_name, false);
end
$$;


ALTER FUNCTION bcf_reg_facade.init_currentlist_and_exec_search(a_root_name text) OWNER TO bcf_reg_facade;

--
-- Name: init_query_fields_upload(); Type: FUNCTION; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE FUNCTION bcf_reg_facade.init_query_fields_upload() RETURNS void
    LANGUAGE plpgsql
    AS $_$
begin
  create temporary table if not exists tmp$query_fields_uploaded (
    item_no integer,
    query_item_id integer,
    field_name text,
    operator text,
    options text,
    criteria_text text,
    criteria_number double precision,
    criteria_date1 timestamp with time zone,
    criteria_date2 timestamp with time zone
  );
  grant select on pg_temp.tmp$query_fields_uploaded to bcf_reg_facade;
  delete from pg_temp.tmp$query_fields_uploaded;
end;
$_$;


ALTER FUNCTION bcf_reg_facade.init_query_fields_upload() OWNER TO bcf_reg_facade;

--
-- Name: journal_compound_diff(text); Type: FUNCTION; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE FUNCTION bcf_reg_facade.journal_compound_diff(a_compound_name text) RETURNS TABLE(change_date timestamp with time zone, username text, reason text, field text, old_value text, new_value text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'bcf_reg_facade', 'pg_catalog'
    AS $_$
begin
  return query
    select * from (
      select jtd.change_date, jtd.username, jtd.reason, 'Parent.' || jtd.field as field, jtd.old_value, jtd.new_value
        from bcf_reg_facade.journal_table_diff('bcf_reg', 'jn$parents', 
               (select name from bcf_reg.parents where id = (select parent_id from bcf_reg.compounds where name = a_compound_name))
             ) jtd
      union
      select jtd.change_date, jtd.username, jtd.reason, 'Compound.' || jtd.field as field, jtd.old_value, jtd.new_value
        from bcf_reg_facade.journal_table_diff('bcf_reg', 'jn$compounds', a_compound_name) jtd
    ) all_diff
    order by change_date;
end
$_$;


ALTER FUNCTION bcf_reg_facade.journal_compound_diff(a_compound_name text) OWNER TO bcf_reg_facade;

--
-- Name: FUNCTION journal_compound_diff(a_compound_name text); Type: COMMENT; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

COMMENT ON FUNCTION bcf_reg_facade.journal_compound_diff(a_compound_name text) IS 'Returns audit trail for a given compound. The compound audit trail is interleaved with the parent structure audit trail.';


--
-- Name: journal_table_diff(text, text, text); Type: FUNCTION; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE FUNCTION bcf_reg_facade.journal_table_diff(schema_name text, table_name text, key_field_value text) RETURNS TABLE(change_date timestamp with time zone, username text, reason text, field text, old_value text, new_value text)
    LANGUAGE plpgsql
    SET search_path TO 'hstore', 'bcf_reg_facade', 'pg_catalog'
    AS $_$
declare
  journal_data refcursor;
  rec record;
  rec2 record;
  colname text;
begin
  open journal_data for execute
    'select * from ' || quote_ident(schema_name) || '.' || quote_ident(table_name) 
    || ' where name = $1 order by jn$timestamp;'
    using key_field_value;
  loop
    fetch journal_data into rec;
    fetch journal_data into rec2;

    -- Check if inserted.
    if rec.jn$operation = 'INS' then
      change_date := rec.jn$timestamp;
      username    := display_user_name(rec.jn$user);
      reason      := 'Record created.';
      field       := '';
      old_value   := '';
      new_value   := '';
      return next;
    end if;
    -- Exit if rec2 is empty => only insert has occurred.
    if not found then
      exit;
    end if;

    -- Move back one record, important, must be after check for found.
    move prior from journal_data;

    -- Loop over fields to find changes, skipping the journal- and latest-change- specific fields.
    for colname in (
      select a.attname
        from pg_catalog.pg_attribute a
       where a.attrelid = (schema_name || '.' || table_name)::regclass
         and a.attnum > 0
         and a.attisdropped = false
         and a.attname not in ('jn$user', 'jn$timestamp', 'jn$operation', 'update_reason', 'updated_by', 'updated_on')
    )
    loop
      -- Compare the content of columns, if not the same add to table. If one but not other is null, also add.
      -- hstore(rec) -> 'text' fetches the content of column 'text'.
      if (hstore(rec) -> colname) <> (hstore(rec2) -> colname) or (((hstore(rec) -> colname) is null) != ((hstore(rec2) -> colname) is null)) then
        change_date := rec2.jn$timestamp;
        username    := display_user_name(rec2.jn$user);
        reason      := rec2.update_reason;
        field       := colname;
        old_value   := hstore(rec) -> colname;
        new_value   := hstore(rec2) -> colname;
        return next;
      end if;
    end loop;

  end loop;

  close journal_data;
end;
$_$;


ALTER FUNCTION bcf_reg_facade.journal_table_diff(schema_name text, table_name text, key_field_value text) OWNER TO bcf_reg_facade;

--
-- Name: FUNCTION journal_table_diff(schema_name text, table_name text, key_field_value text); Type: COMMENT; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

COMMENT ON FUNCTION bcf_reg_facade.journal_table_diff(schema_name text, table_name text, key_field_value text) IS 'Internal function that parses data from a journalling table or view and returns a table containing fields that have been changed, when, by whom and the reason why.';


--
-- Name: pluralized(integer, text, text); Type: FUNCTION; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE FUNCTION bcf_reg_facade.pluralized(a_count integer, an_item_name text, an_item_plural_suffix text) RETURNS text
    LANGUAGE plpgsql
    AS $$
begin
  if a_count <> 1 then
    return an_item_name || an_item_plural_suffix;
  else
    return an_item_name;
  end if;
end
$$;


ALTER FUNCTION bcf_reg_facade.pluralized(a_count integer, an_item_name text, an_item_plural_suffix text) OWNER TO bcf_reg_facade;

--
-- Name: FUNCTION pluralized(a_count integer, an_item_name text, an_item_plural_suffix text); Type: COMMENT; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

COMMENT ON FUNCTION bcf_reg_facade.pluralized(a_count integer, an_item_name text, an_item_plural_suffix text) IS 'Internal: Returns pluralized form of "an_item_name" if "a_count" <> 1.';


--
-- Name: register_delete_reason(integer, text); Type: FUNCTION; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE FUNCTION bcf_reg_facade.register_delete_reason(an_id integer, a_reason text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'bcf_reg_facade', 'pg_temp'
    AS $$
begin
  insert into bcf_reg.delete_reasons (id, delete_reason)
  values (an_id, a_reason);
end;
$$;


ALTER FUNCTION bcf_reg_facade.register_delete_reason(an_id integer, a_reason text) OWNER TO bcf_reg_facade;

--
-- Name: FUNCTION register_delete_reason(an_id integer, a_reason text); Type: COMMENT; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

COMMENT ON FUNCTION bcf_reg_facade.register_delete_reason(an_id integer, a_reason text) IS 'Register a delete reason for any type of record.';


--
-- Name: save_search(text, timestamp with time zone, timestamp with time zone, boolean); Type: FUNCTION; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE FUNCTION bcf_reg_facade.save_search(qry text, qry_start_time timestamp with time zone, qry_done_time timestamp with time zone, within_current_list boolean) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'bcf_reg_facade', 'pg_temp'
    AS $_$
declare
  new_query_run_id integer;
begin
  -- Log the query, its results, and its setup.
  insert into bcf_reg_facade.query_runs
    (result, result_count, sql_text, run_by, run_on, run_time)
  select
      string_agg(id, ';' order by id), count(*), qry, session_user, qry_start_time, qry_done_time - qry_start_time
    from pg_temp.tmp$current_list
  returning id into new_query_run_id;
  
  if within_current_list then
    update bcf_reg_facade.query_runs
       set within_list = (select string_agg(id, ';' order by id) from pg_temp.tmp$current_list1)
         , within_list_count = (select count(*) from pg_temp.tmp$current_list1)
     where id = new_query_run_id;
  end if;

  insert into bcf_reg_facade.query_run_fields
    (query_run_id, item_no, query_item_id, field_name, operator, options, criteria_text, criteria_number, criteria_date1, criteria_date2)
  select
      new_query_run_id, qfu.*
    from pg_temp.tmp$query_fields_uploaded qfu;
end
$_$;


ALTER FUNCTION bcf_reg_facade.save_search(qry text, qry_start_time timestamp with time zone, qry_done_time timestamp with time zone, within_current_list boolean) OWNER TO bcf_reg_facade;

--
-- Name: trg$delete_query_runs(); Type: FUNCTION; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE FUNCTION bcf_reg_facade."trg$delete_query_runs"() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'bcf_reg_facade', 'pg_temp'
    AS $$
begin
  delete from bcf_reg_facade.query_run_fields
   where query_run_id = OLD.id;

  delete from bcf_reg_facade.query_runs
   where id = OLD.id;

  return OLD;
end;
$$;


ALTER FUNCTION bcf_reg_facade."trg$delete_query_runs"() OWNER TO bcf_reg_facade;

--
-- Name: trg$update_query_runs(); Type: FUNCTION; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE FUNCTION bcf_reg_facade."trg$update_query_runs"() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'bcf_reg_facade', 'pg_temp'
    AS $$
begin
  update bcf_reg_facade.query_runs
     set name = NEW."Name"
   where id = NEW.id;

  return NEW;
end;
$$;


ALTER FUNCTION bcf_reg_facade."trg$update_query_runs"() OWNER TO bcf_reg_facade;

--
-- Name: create_delete_reason(); Type: FUNCTION; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

CREATE FUNCTION bcf_reg_web_facade.create_delete_reason() RETURNS text
    LANGUAGE sql
    AS $$
select 'System-generated delete reason ; ' || clock_timestamp() || '.';
$$;


ALTER FUNCTION bcf_reg_web_facade.create_delete_reason() OWNER TO bcf_reg_facade;

--
-- Name: create_update_reason(); Type: FUNCTION; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

CREATE FUNCTION bcf_reg_web_facade.create_update_reason() RETURNS text
    LANGUAGE sql
    AS $$
select 'System-generated update reason ; ' || clock_timestamp() || '.';
$$;


ALTER FUNCTION bcf_reg_web_facade.create_update_reason() OWNER TO bcf_reg_facade;

--
-- Name: delete_compound(text); Type: FUNCTION; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

CREATE FUNCTION bcf_reg_web_facade.delete_compound(a_compound_name text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'bcf_reg_facade', 'pg_temp'
    AS $$
declare
  the_parent_id integer;
  deleted_count integer;
begin
  /**
    NOTE: This function must be kept in sync with delete_compound_impact() so
          the listed impact accurately reflects what will be deleted here.
  **/
  select id into the_parent_id
    from bcf_reg.parents
   where name = a_compound_name;

  if not found then
    raise exception 'Invalid compound name "%".', a_compound_name;
  end if;

  -- Compounds.
  insert into bcf_reg.delete_reasons (id, delete_reason)
  select cmp.id, bcf_reg_web_facade.create_delete_reason()
    from bcf_reg.compounds cmp
   where cmp.parent_id = the_parent_id;

  delete from bcf_reg.compounds
   where parent_id = the_parent_id;

  -- Parent.  
  insert into bcf_reg.delete_reasons (id, delete_reason)
  values (the_parent_id, bcf_reg_web_facade.create_delete_reason());

  delete from bcf_reg.parents
   where id = the_parent_id;

  get diagnostics deleted_count = row_count;
  if deleted_count <> 1 then
    raise exception 'Internal bug: Trying to delete the parent of compound "%" deleted % records - expected exactly one record to be deleted.', a_compound_name, deleted_count;
  end if;
end
$$;


ALTER FUNCTION bcf_reg_web_facade.delete_compound(a_compound_name text) OWNER TO bcf_reg_facade;

--
-- Name: delete_compound_impact(text); Type: FUNCTION; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

CREATE FUNCTION bcf_reg_web_facade.delete_compound_impact(a_compound_name text) RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'bcf_reg_facade', 'pg_catalog'
    AS $$
declare
  the_parent_id integer;
  salts_count integer;
  child_count integer;
  impact text;
begin
  /**
    NOTE: This function must be kept in sync with delete_compound() so
          the listed impact accurately reflects what will be deleted
          by delete_compound().
  **/
  impact := '';

  select id into the_parent_id
    from bcf_reg.parents
   where name = a_compound_name;

  if not found then
    raise exception 'Invalid compound name "%".', a_compound_name;
  end if;

  return impact;
end
$$;


ALTER FUNCTION bcf_reg_web_facade.delete_compound_impact(a_compound_name text) OWNER TO bcf_reg_facade;

--
-- Name: describe_table(text); Type: FUNCTION; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

CREATE FUNCTION bcf_reg_web_facade.describe_table(a_table_name text) RETURNS TABLE(name text, type text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'bcf_reg_web_facade', 'pg_catalog'
    AS $$
declare
  dot_pos integer;
  the_schema_name text;
  the_table_name text;
begin
  dot_pos := position('.' in a_table_name);
  if dot_pos = 0 then
    the_schema_name := current_schema();
    the_table_name  := a_table_name;
  else
    the_schema_name := substring(a_table_name, 1, dot_pos - 1);
    the_table_name  := substring(a_table_name, dot_pos + 1);
  end if;

  if the_schema_name = 'pg_temp' then
    -- Temporary schema appears as 'pg_temp_<integer>' in INFORMATION_SCHEMA.
    the_schema_name := 'pg_temp_%';
  end if;

  return query
    select
        column_name::text
      , case
          when data_type = 'integer' then 'int'
          when data_type = 'numeric' or data_type = 'double precision' then 'number'
          when data_type = 'boolean' then 'bool'
          when data_type = 'timestamp with time zone' then 'date'
          when data_type = 'text' then 'string'
        else
          '<Unsupported column type>'
        end as data_type_translated
      from information_schema.columns
     where table_schema like the_schema_name
       and table_name = the_table_name
     order by ordinal_position;
end;
$$;


ALTER FUNCTION bcf_reg_web_facade.describe_table(a_table_name text) OWNER TO bcf_reg_facade;

--
-- Name: find_or_create_compound_salt(integer, text, integer, integer); Type: FUNCTION; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

CREATE FUNCTION bcf_reg_web_facade.find_or_create_compound_salt(a_parent_id integer, a_short_salt_name text, a_structure_ratio integer, a_salt_ratio integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare
  the_parent_name text;
  the_salt_id integer;
  the_structure_ratio integer;
  the_salt_ratio integer;
  --
  the_compound_salt_id integer;
begin
  select name into the_parent_name
    from bcf_reg.parents
   where id = a_parent_id;
  if not found then
    raise exception 'Invalid parent ID (%).', a_parent_id;
  end if;

  the_salt_id := lookup_salt(coalesce(a_short_salt_name, 'None'));
  the_structure_ratio := coalesce(a_structure_ratio, 1);
  the_salt_ratio := coalesce(a_salt_ratio, 1);

  select id into the_compound_salt_id
    from bcf_reg.compounds
   where parent_id = a_parent_id
     and salt_id = the_salt_id
     and structure_ratio = the_structure_ratio 
     and salt_ratio = the_salt_ratio; 

  if not found then     
    insert into bcf_reg.compounds
      (parent_id,
       name,
       salt_id, structure_ratio, salt_ratio, comments)
    values
      (a_parent_id,
       the_parent_name || '_' || coalesce(a_short_salt_name, 'None') || '_' || the_structure_ratio || ':' || the_salt_ratio,
       the_salt_id, the_structure_ratio, the_salt_ratio, '')
    returning id into the_compound_salt_id;
  end if;
  
  return the_compound_salt_id;
end
$$;


ALTER FUNCTION bcf_reg_web_facade.find_or_create_compound_salt(a_parent_id integer, a_short_salt_name text, a_structure_ratio integer, a_salt_ratio integer) OWNER TO bcf_reg_facade;

--
-- Name: FUNCTION find_or_create_compound_salt(a_parent_id integer, a_short_salt_name text, a_structure_ratio integer, a_salt_ratio integer); Type: COMMENT; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

COMMENT ON FUNCTION bcf_reg_web_facade.find_or_create_compound_salt(a_parent_id integer, a_short_salt_name text, a_structure_ratio integer, a_salt_ratio integer) IS 'Internal function used by instead-of triggers on the v$bathes_edit view.';


--
-- Name: get_structure_duplicates(text, integer); Type: FUNCTION; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

CREATE FUNCTION bcf_reg_web_facade.get_structure_duplicates(a_molfile text, a_compound_id_to_exclude integer) RETURNS TABLE(compound_name text, duplicate_reason text)
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
declare
  the_structure_key text;
begin
  the_structure_key := rdkit.mol_inchikey(rdkit.mol_from_ctab(a_molfile::cstring, true))::text;

  -- Ensure that No-Structure-s do not have duplicates.
  if the_structure_key = 'MOSFIJXAXDLOML-UHFFFAOYSA-N' then
    the_structure_key := 'No-Structure';
  end if;

  return query
    select
        par.name,
        par.duplicate_reason
      from bcf_reg.parents par
     where par.structure_key = the_structure_key
        -- The 'a_compound_id_to_exclude' passed in from the UI is really a
        -- parent ID.
       and par.id <> coalesce(a_compound_id_to_exclude, -1) 
     order by par.name;
end
$$;


ALTER FUNCTION bcf_reg_web_facade.get_structure_duplicates(a_molfile text, a_compound_id_to_exclude integer) OWNER TO bcf_reg_facade;

--
-- Name: lookup_salt(text); Type: FUNCTION; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

CREATE FUNCTION bcf_reg_web_facade.lookup_salt(a_short_salt_name text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare
  the_result integer;
begin
  select id into the_result
    from bcf_reg.salts
   where short_name = a_short_salt_name;

  if not found then
    raise exception 'There is no salt with a short name of "%".', a_short_salt_name;
  end if;
  
  return the_result;
end
$$;


ALTER FUNCTION bcf_reg_web_facade.lookup_salt(a_short_salt_name text) OWNER TO bcf_reg_facade;

--
-- Name: molfile_fragment_count(text); Type: FUNCTION; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

CREATE FUNCTION bcf_reg_web_facade.molfile_fragment_count(a_molfile text) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
begin
  return aux_services.molfile_fragment_count(a_molfile);
end
$$;


ALTER FUNCTION bcf_reg_web_facade.molfile_fragment_count(a_molfile text) OWNER TO bcf_reg_facade;

--
-- Name: molfile_to_svg(text, integer, integer); Type: FUNCTION; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

CREATE FUNCTION bcf_reg_web_facade.molfile_to_svg(a_molfile text, a_width integer, a_height integer) RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
begin
  return aux_services.molfile_to_svg(a_molfile, a_width, a_height);
end
$$;


ALTER FUNCTION bcf_reg_web_facade.molfile_to_svg(a_molfile text, a_width integer, a_height integer) OWNER TO bcf_reg_facade;

--
-- Name: refresh_user_name_cache(); Type: FUNCTION; Schema: bcf_reg_web_facade; Owner: system_admin
--

CREATE FUNCTION bcf_reg_web_facade.refresh_user_name_cache() RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'bcf_reg_facade, pg_temp'
    AS $_$
declare
  cols record;
  stmt text;
begin
  delete from bcf_reg_web_facade.cached_user_names;

  for cols in (
    select table_schema, table_name, column_name 
      from information_schema.columns
     where table_schema in ('bcf_reg', 'bcf_reg_inv', 'bcf_reg_assay_data')
       and table_name not like 'jn$%'
       and column_name in ('created_by', 'updated_by')
  )
  loop
    stmt := 'insert into bcf_reg_web_facade.cached_user_names ' || Chr(10)
    || 'select distinct ' || quote_literal(cols.table_name) || ', ' || quote_literal(cols.column_name) || ', bcf_reg_facade.display_user_name(' || cols.column_name || ') ' || Chr(10)
    || '  from ' || cols.table_schema || '.' || cols.table_name || Chr(10)
    || ' where ' || cols.column_name || ' is not null and ' || cols.column_name || ' not in (''bcf_reg'', ''bcf_reg_facade'')' || Chr(10);

    execute stmt;
  end loop;

  insert into bcf_reg_web_facade.cached_user_names
  select '_all_logins', 'user_name', bcf_reg_facade.display_user_name(user_name) from (
    select initials as user_name from bcf_auth.users_viewer
    union
    select initials as user_name from bcf_auth.users_editor
    union
    select initials as user_name from bcf_auth.users_admin
  ) logins
  ;
  
end
$_$;


ALTER FUNCTION bcf_reg_web_facade.refresh_user_name_cache() OWNER TO system_admin;

--
-- Name: trg$delete_v$salts_edit(); Type: FUNCTION; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

CREATE FUNCTION bcf_reg_web_facade."trg$delete_v$salts_edit"() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'bcf_reg_web_facade', 'pg_temp'
    AS $$
begin
  insert into bcf_reg.delete_reasons
  select OLD.id, bcf_reg_web_facade.create_delete_reason();

  delete from bcf_reg.salts
   where id = OLD.id;

  return OLD;
end;
$$;


ALTER FUNCTION bcf_reg_web_facade."trg$delete_v$salts_edit"() OWNER TO bcf_reg_facade;

--
-- Name: trg$insert_v$compounds_edit(); Type: FUNCTION; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

CREATE FUNCTION bcf_reg_web_facade."trg$insert_v$compounds_edit"() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'bcf_reg_web_facade', 'pg_temp'
    AS $$
begin
  insert into bcf_reg.parents
    (name, primary_type, original_registration, duplicate_reason,
     comments)
  values
    (trim(upper(NEW.name)), 'M', NEW.molfile, NEW.duplicate_reason,
     coalesce(NEW.comments, ''))
  returning id into NEW.id;

  return NEW;
end;
$$;


ALTER FUNCTION bcf_reg_web_facade."trg$insert_v$compounds_edit"() OWNER TO bcf_reg_facade;

--
-- Name: trg$update_v$compounds_edit(); Type: FUNCTION; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

CREATE FUNCTION bcf_reg_web_facade."trg$update_v$compounds_edit"() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'bcf_reg_web_facade', 'pg_temp'
    AS $$
begin
  update bcf_reg.parents
     set original_registration = NEW.molfile
       , comments = coalesce(NEW.comments, '')
       , duplicate_reason = NEW.duplicate_reason
       , update_reason = bcf_reg_web_facade.create_update_reason()
   where id = OLD.id; 

  return NEW;
end;
$$;


ALTER FUNCTION bcf_reg_web_facade."trg$update_v$compounds_edit"() OWNER TO bcf_reg_facade;

--
-- Name: trg$update_v$salts_edit(); Type: FUNCTION; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

CREATE FUNCTION bcf_reg_web_facade."trg$update_v$salts_edit"() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'bcf_reg_web_facade', 'pg_temp'
    AS $$
declare
  use_count integer;
begin
  select count(*) into use_count
    from bcf_reg.compounds
   where salt_id = NEW.id;

  if use_count > 0 then
    if proteax.formula_add(coalesce(NEW.sum_formula, ''), '') <> proteax.formula_add(coalesce(OLD.sum_formula, ''), '') then
      raise exception 'You cannot change the sum formula of this salt. It is the basis for the molweight of % compounds. Please refer to a database administrator if you really need to change this value.', use_count;
    end if;
  end if;

  update bcf_reg.salts
     set name = NEW.name
       , short_name = NEW.short_name
       , sum_formula = NEW.sum_formula
       , update_reason = bcf_reg_web_facade.create_update_reason()
   where id = NEW.id;

  return NEW;
end;
$$;


ALTER FUNCTION bcf_reg_web_facade."trg$update_v$salts_edit"() OWNER TO bcf_reg_facade;

--
-- Name: create_journal_table(text); Type: FUNCTION; Schema: bcf_utils; Owner: postgres
--

CREATE FUNCTION bcf_utils.create_journal_table(a_table_name text) RETURNS void
    LANGUAGE plpgsql
    AS $_$
declare
  the_table_schema text;
  the_table_type text;
  --
  create_table_statement text;
  create_trigger_handler_statement text;
  LF text := Chr(10);
begin
  -- This version doesn't yet support creating a journal table for a table
  -- in a schema other than current_schema().
  the_table_schema := current_schema();
  select table_type into the_table_type
    from information_schema.tables
   where table_schema = the_table_schema
     and table_name = a_table_name;
  if not found then
    raise exception 'The "%" table does not exist.', a_table_name;
  end if;
  if the_table_type <> 'BASE TABLE' then
    raise exception 'The "%" table is a "%" - only base tables can be journalled.', a_table_name, the_table_type;
  end if;

  select
    -- Journal table.
    'create table ' || the_table_schema || '.jn$' || a_table_name || '('
    || 'jn$timestamp timestamp with time zone, '
    || 'jn$operation character(3), jn$user text, '
    || string_agg(column_name || ' ' || data_type, ', ')
    || ');',
    -- Journal trigger handler.
    'create function ' || the_table_schema || '.trg$jn$' || a_table_name || '() '
    || 'returns trigger as $trigger_handler_code$ begin' || LF 
    || '  if TG_OP = ''INSERT'' then ' || LF
    || '    insert into ' || the_table_schema || '.jn$' || a_table_name || ' select current_timestamp, ''INS'', session_user, NEW.*; ' || LF
    || '  elsif TG_OP = ''UPDATE'' then ' || LF
    || '    insert into ' || the_table_schema || '.jn$' || a_table_name || ' select current_timestamp, ''UPD'', session_user, NEW.*; ' || LF
    || '  elsif TG_OP = ''DELETE'' then ' || LF
    || '    insert into ' || the_table_schema || '.jn$' || a_table_name || ' select current_timestamp, ''DEL'', session_user, OLD.*; ' || LF
    || '  end if;' || LF
    || '  return NULL;' || LF
    || 'end $trigger_handler_code$ language plpgsql security definer set search_path = ' || the_table_schema || ',pg_temp;'
    into create_table_statement, create_trigger_handler_statement
    from (
      select
        column_name,
        case
          when data_type = 'USER-DEFINED' then udt_schema || '.' || udt_name
          when data_type = 'character' then data_type || '(' || character_maximum_length || ')'
          else data_type
        end as data_type
        from information_schema.columns
       where table_schema = current_schema()
         and table_name = a_table_name
       order by ordinal_position
    ) table_columns;

  execute create_table_statement;
  execute create_trigger_handler_statement;
  execute 'create trigger jn$ins_upd_del after insert or update or delete '
    || 'on ' || the_table_schema || '.' || a_table_name || ' '
    || 'for each row execute procedure ' || the_table_schema || '.trg$jn$' || a_table_name || '();';
end
$_$;


ALTER FUNCTION bcf_utils.create_journal_table(a_table_name text) OWNER TO postgres;

--
-- Name: id_sequence; Type: SEQUENCE; Schema: bcf_auth; Owner: bcf_auth
--

CREATE SEQUENCE bcf_auth.id_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bcf_auth.id_sequence OWNER TO bcf_auth;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: user_mappings; Type: TABLE; Schema: bcf_auth; Owner: bcf_auth
--

CREATE TABLE bcf_auth.user_mappings (
    id integer DEFAULT nextval('bcf_auth.id_sequence'::regclass) NOT NULL,
    external_user_name text NOT NULL,
    db_user_name text NOT NULL,
    db_password text NOT NULL,
    email_address text DEFAULT 'unknown'::text NOT NULL,
    status text,
    is_enabled character(1) DEFAULT 'Y'::bpchar NOT NULL,
    CONSTRAINT usermappings_isenabled_yn CHECK ((is_enabled = ANY (ARRAY['Y'::bpchar, 'N'::bpchar])))
);


ALTER TABLE bcf_auth.user_mappings OWNER TO bcf_auth;

--
-- Name: users_admin; Type: TABLE; Schema: bcf_auth; Owner: bcf_auth
--

CREATE TABLE bcf_auth.users_admin (
    initials text
);


ALTER TABLE bcf_auth.users_admin OWNER TO bcf_auth;

--
-- Name: users_editor; Type: TABLE; Schema: bcf_auth; Owner: bcf_auth
--

CREATE TABLE bcf_auth.users_editor (
    initials text
);


ALTER TABLE bcf_auth.users_editor OWNER TO bcf_auth;

--
-- Name: users_viewer; Type: TABLE; Schema: bcf_auth; Owner: bcf_auth
--

CREATE TABLE bcf_auth.users_viewer (
    initials text
);


ALTER TABLE bcf_auth.users_viewer OWNER TO bcf_auth;

--
-- Name: v$email_addresses; Type: VIEW; Schema: bcf_auth; Owner: bcf_auth
--

CREATE VIEW bcf_auth."v$email_addresses" AS
 SELECT user_mappings.db_user_name,
    user_mappings.email_address
   FROM bcf_auth.user_mappings
  WHERE (user_mappings.is_enabled = 'Y'::bpchar);


ALTER TABLE bcf_auth."v$email_addresses" OWNER TO bcf_auth;

--
-- Name: VIEW "v$email_addresses"; Type: COMMENT; Schema: bcf_auth; Owner: bcf_auth
--

COMMENT ON VIEW bcf_auth."v$email_addresses" IS 'Mapping of user names to e-mail addresses. Used by "bcf_reg_stock_facade" for sending delivery notes.';


--
-- Name: id_sequence; Type: SEQUENCE; Schema: bcf_reg; Owner: bcf_reg
--

CREATE SEQUENCE bcf_reg.id_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bcf_reg.id_sequence OWNER TO bcf_reg;

--
-- Name: compounds; Type: TABLE; Schema: bcf_reg; Owner: bcf_reg
--

CREATE TABLE bcf_reg.compounds (
    id integer DEFAULT nextval('bcf_reg.id_sequence'::regclass) NOT NULL,
    name text NOT NULL,
    parent_id integer NOT NULL,
    salt_id integer NOT NULL,
    structure_ratio integer NOT NULL,
    salt_ratio integer NOT NULL,
    comments text,
    created_by text DEFAULT "session_user"() NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL,
    updated_by text,
    update_reason text,
    updated_on timestamp with time zone,
    CONSTRAINT compound_name_not_blank CHECK ((btrim(name) <> ''::text)),
    CONSTRAINT compound_saltratio_must_be_positive CHECK ((salt_ratio > 0)),
    CONSTRAINT compound_structureratio_must_be_positive CHECK ((structure_ratio > 0))
);


ALTER TABLE bcf_reg.compounds OWNER TO bcf_reg;

--
-- Name: compounds$calc_props; Type: TABLE; Schema: bcf_reg; Owner: bcf_reg
--

CREATE TABLE bcf_reg."compounds$calc_props" (
    compound_id integer NOT NULL,
    mw_avg double precision,
    mw_mono double precision,
    sum_formula text,
    theoretical_structure_fraction double precision,
    clogp double precision,
    logp double precision,
    logd double precision
);


ALTER TABLE bcf_reg."compounds$calc_props" OWNER TO bcf_reg;

--
-- Name: db_revision; Type: TABLE; Schema: bcf_reg; Owner: bcf_reg
--

CREATE TABLE bcf_reg.db_revision (
    revision text
);


ALTER TABLE bcf_reg.db_revision OWNER TO bcf_reg;

--
-- Name: delete_reasons; Type: TABLE; Schema: bcf_reg; Owner: bcf_reg
--

CREATE TABLE bcf_reg.delete_reasons (
    id integer NOT NULL,
    delete_reason text NOT NULL,
    CONSTRAINT non_blank_delete_reason CHECK ((btrim(delete_reason) <> ''::text))
);


ALTER TABLE bcf_reg.delete_reasons OWNER TO bcf_reg;

--
-- Name: TABLE delete_reasons; Type: COMMENT; Schema: bcf_reg; Owner: bcf_reg
--

COMMENT ON TABLE bcf_reg.delete_reasons IS 'Table of non-blank reasons for deleting records from controlled tables.';


--
-- Name: jn$compounds; Type: TABLE; Schema: bcf_reg; Owner: bcf_reg
--

CREATE TABLE bcf_reg."jn$compounds" (
    "jn$timestamp" timestamp with time zone,
    "jn$operation" character(3),
    "jn$user" text,
    id integer,
    name text,
    parent_id integer,
    salt_id integer,
    structure_ratio integer,
    salt_ratio integer,
    comments text,
    created_by text,
    created_on timestamp with time zone,
    updated_by text,
    update_reason text,
    updated_on timestamp with time zone
);


ALTER TABLE bcf_reg."jn$compounds" OWNER TO bcf_reg;

--
-- Name: jn$parents; Type: TABLE; Schema: bcf_reg; Owner: bcf_reg
--

CREATE TABLE bcf_reg."jn$parents" (
    "jn$timestamp" timestamp with time zone,
    "jn$operation" character(3),
    "jn$user" text,
    id integer,
    no integer,
    name text,
    comments text,
    original_registration text,
    primary_type character(1),
    structure_key text,
    duplicate_reason text,
    created_by text,
    created_on timestamp with time zone,
    updated_by text,
    update_reason text,
    updated_on timestamp with time zone
);


ALTER TABLE bcf_reg."jn$parents" OWNER TO bcf_reg;

--
-- Name: jn$salts; Type: TABLE; Schema: bcf_reg; Owner: bcf_reg
--

CREATE TABLE bcf_reg."jn$salts" (
    "jn$timestamp" timestamp with time zone,
    "jn$operation" character(3),
    "jn$user" text,
    id integer,
    name text,
    short_name text,
    molfile text,
    molecule rdkit.mol,
    auto_calc_properties character(1),
    sum_formula text,
    mw_avg double precision,
    mw_mono double precision,
    created_by text,
    created_on timestamp with time zone,
    updated_by text,
    update_reason text,
    updated_on timestamp with time zone
);


ALTER TABLE bcf_reg."jn$salts" OWNER TO bcf_reg;

--
-- Name: parent_no_sequence; Type: SEQUENCE; Schema: bcf_reg; Owner: bcf_reg
--

CREATE SEQUENCE bcf_reg.parent_no_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bcf_reg.parent_no_sequence OWNER TO bcf_reg;

--
-- Name: parents; Type: TABLE; Schema: bcf_reg; Owner: bcf_reg
--

CREATE TABLE bcf_reg.parents (
    id integer DEFAULT nextval('bcf_reg.id_sequence'::regclass) NOT NULL,
    no integer NOT NULL,
    name text NOT NULL,
    comments text,
    original_registration text NOT NULL,
    primary_type character(1) DEFAULT 'P'::bpchar NOT NULL,
    structure_key text NOT NULL,
    duplicate_reason text DEFAULT ''::text NOT NULL,
    created_by text DEFAULT "session_user"() NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL,
    updated_by text,
    update_reason text,
    updated_on timestamp with time zone,
    CONSTRAINT parent_name_not_blank CHECK ((btrim(name) <> ''::text)),
    CONSTRAINT parent_primarytype_valid CHECK ((primary_type = ANY (ARRAY['M'::bpchar, 'P'::bpchar])))
);


ALTER TABLE bcf_reg.parents OWNER TO bcf_reg;

--
-- Name: parents$calc_props; Type: TABLE; Schema: bcf_reg; Owner: bcf_reg
--

CREATE TABLE bcf_reg."parents$calc_props" (
    id integer DEFAULT nextval('bcf_reg.id_sequence'::regclass) NOT NULL,
    molecule rdkit.mol,
    pln text,
    conversion_errors text,
    sum_formula text,
    mw_avg double precision,
    mw_mono double precision,
    norm_seq_chksum text,
    norm_prot_chksum text,
    protein_key_chksum text,
    inchi_key text,
    predicted_pi double precision,
    predicted_anion_count integer,
    predicted_cation_count integer,
    svg_rendering text,
    parent_id integer NOT NULL
);


ALTER TABLE bcf_reg."parents$calc_props" OWNER TO bcf_reg;

--
-- Name: parents$calc_queue; Type: TABLE; Schema: bcf_reg; Owner: bcf_reg
--

CREATE TABLE bcf_reg."parents$calc_queue" (
    id integer NOT NULL,
    parent_id integer NOT NULL
);


ALTER TABLE bcf_reg."parents$calc_queue" OWNER TO bcf_reg;

--
-- Name: parents$calc_queue_id_seq; Type: SEQUENCE; Schema: bcf_reg; Owner: bcf_reg
--

CREATE SEQUENCE bcf_reg."parents$calc_queue_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bcf_reg."parents$calc_queue_id_seq" OWNER TO bcf_reg;

--
-- Name: parents$calc_queue_id_seq; Type: SEQUENCE OWNED BY; Schema: bcf_reg; Owner: bcf_reg
--

ALTER SEQUENCE bcf_reg."parents$calc_queue_id_seq" OWNED BY bcf_reg."parents$calc_queue".id;


--
-- Name: salts; Type: TABLE; Schema: bcf_reg; Owner: bcf_reg
--

CREATE TABLE bcf_reg.salts (
    id integer DEFAULT nextval('bcf_reg.id_sequence'::regclass) NOT NULL,
    name text NOT NULL,
    short_name text NOT NULL,
    molfile text,
    molecule rdkit.mol,
    auto_calc_properties character(1) DEFAULT 'Y'::bpchar NOT NULL,
    sum_formula text NOT NULL,
    mw_avg double precision NOT NULL,
    mw_mono double precision NOT NULL,
    created_by text DEFAULT "session_user"() NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL,
    updated_by text,
    update_reason text,
    updated_on timestamp with time zone,
    CONSTRAINT salt_autocalcprops_is_yn CHECK ((auto_calc_properties = ANY (ARRAY['Y'::bpchar, 'N'::bpchar]))),
    CONSTRAINT salt_name_not_blank CHECK ((btrim(name) <> ''::text)),
    CONSTRAINT salt_short_name_not_blank CHECK ((btrim(short_name) <> ''::text))
);


ALTER TABLE bcf_reg.salts OWNER TO bcf_reg;

--
-- Name: unique$names; Type: TABLE; Schema: bcf_reg; Owner: bcf_reg
--

CREATE TABLE bcf_reg."unique$names" (
    id integer NOT NULL,
    source_table text NOT NULL,
    name text NOT NULL,
    CONSTRAINT non_blank_source_table CHECK ((btrim(source_table) <> ''::text)),
    CONSTRAINT non_blank_unique_name CHECK ((btrim(name) <> ''::text))
);


ALTER TABLE bcf_reg."unique$names" OWNER TO bcf_reg;

--
-- Name: TABLE "unique$names"; Type: COMMENT; Schema: bcf_reg; Owner: bcf_reg
--

COMMENT ON TABLE bcf_reg."unique$names" IS 'Helper table that provides a cross-table unique name index.';


--
-- Name: db_config; Type: TABLE; Schema: bcf_reg_config; Owner: bcf_auth
--

CREATE TABLE bcf_reg_config.db_config (
    property text,
    value text
);


ALTER TABLE bcf_reg_config.db_config OWNER TO bcf_auth;

--
-- Name: jn$db_config; Type: TABLE; Schema: bcf_reg_config; Owner: postgres
--

CREATE TABLE bcf_reg_config."jn$db_config" (
    "jn$timestamp" timestamp with time zone,
    "jn$operation" character(3),
    "jn$user" text,
    property text,
    value text
);


ALTER TABLE bcf_reg_config."jn$db_config" OWNER TO postgres;

--
-- Name: id_sequence; Type: SEQUENCE; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE SEQUENCE bcf_reg_facade.id_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bcf_reg_facade.id_sequence OWNER TO bcf_reg_facade;

--
-- Name: export_views; Type: TABLE; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE TABLE bcf_reg_facade.export_views (
    id integer DEFAULT nextval('bcf_reg_facade.id_sequence'::regclass) NOT NULL,
    query_tree_root_id integer NOT NULL,
    display_order integer NOT NULL,
    requires_admin boolean DEFAULT false NOT NULL,
    display_name text NOT NULL,
    export_type text DEFAULT 'Excel'::text NOT NULL,
    export_view text NOT NULL,
    export_view_key_field text NOT NULL,
    CONSTRAINT display_name_not_blank CHECK ((btrim(display_name) <> ''::text)),
    CONSTRAINT valid_export_type CHECK ((export_type = ANY (ARRAY['Excel'::text, 'SDfile'::text])))
);


ALTER TABLE bcf_reg_facade.export_views OWNER TO bcf_reg_facade;

--
-- Name: query_no_sequence; Type: SEQUENCE; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE SEQUENCE bcf_reg_facade.query_no_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bcf_reg_facade.query_no_sequence OWNER TO bcf_reg_facade;

--
-- Name: query_run_fields; Type: TABLE; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE TABLE bcf_reg_facade.query_run_fields (
    id integer DEFAULT nextval('bcf_reg_facade.id_sequence'::regclass) NOT NULL,
    query_run_id integer NOT NULL,
    item_no integer,
    query_item_id integer,
    field_name text,
    operator text,
    options text,
    criteria_text text,
    criteria_number double precision,
    criteria_date1 timestamp with time zone,
    criteria_date2 timestamp with time zone
);


ALTER TABLE bcf_reg_facade.query_run_fields OWNER TO bcf_reg_facade;

--
-- Name: TABLE query_run_fields; Type: COMMENT; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

COMMENT ON TABLE bcf_reg_facade.query_run_fields IS 'Fields used to run a logged query.';


--
-- Name: query_runs; Type: TABLE; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE TABLE bcf_reg_facade.query_runs (
    id integer DEFAULT nextval('bcf_reg_facade.id_sequence'::regclass) NOT NULL,
    no integer DEFAULT nextval('bcf_reg_facade.query_no_sequence'::regclass) NOT NULL,
    name text DEFAULT ''::text,
    result text,
    result_count integer NOT NULL,
    sql_text text,
    run_by text,
    run_on timestamp with time zone,
    run_time interval,
    within_list text DEFAULT ''::text NOT NULL,
    within_list_count integer
);


ALTER TABLE bcf_reg_facade.query_runs OWNER TO bcf_reg_facade;

--
-- Name: TABLE query_runs; Type: COMMENT; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

COMMENT ON TABLE bcf_reg_facade.query_runs IS 'Log of all queries run.';


--
-- Name: query_tree_roots; Type: TABLE; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE TABLE bcf_reg_facade.query_tree_roots (
    id integer DEFAULT nextval('bcf_reg_facade.id_sequence'::regclass) NOT NULL,
    display_name text NOT NULL,
    key_field text NOT NULL
);


ALTER TABLE bcf_reg_facade.query_tree_roots OWNER TO bcf_reg_facade;

--
-- Name: query_trees; Type: TABLE; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE TABLE bcf_reg_facade.query_trees (
    id integer DEFAULT nextval('bcf_reg_facade.id_sequence'::regclass) NOT NULL,
    query_tree_root_id integer NOT NULL,
    parent_item_id integer,
    item_no integer NOT NULL,
    level_no integer NOT NULL,
    display_name text NOT NULL,
    query_view text NOT NULL,
    hidden_fields text DEFAULT ''::text NOT NULL,
    parent_link text DEFAULT ''::text NOT NULL
);


ALTER TABLE bcf_reg_facade.query_trees OWNER TO bcf_reg_facade;

--
-- Name: report_no_sequence; Type: SEQUENCE; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE SEQUENCE bcf_reg_facade.report_no_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bcf_reg_facade.report_no_sequence OWNER TO bcf_reg_facade;

--
-- Name: v$db_revision; Type: VIEW; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE VIEW bcf_reg_facade."v$db_revision" AS
 SELECT db_revision.revision
   FROM bcf_reg.db_revision
  ORDER BY db_revision.revision;


ALTER TABLE bcf_reg_facade."v$db_revision" OWNER TO bcf_reg_facade;

--
-- Name: v$export_views; Type: VIEW; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE VIEW bcf_reg_facade."v$export_views" AS
 SELECT ev.id,
    ev.display_order,
    qtr.id AS query_root_id,
    qtr.display_name AS query_root_name,
    ev.display_name,
    ev.requires_admin,
    ev.export_type,
    ev.export_view,
    ev.export_view_key_field
   FROM (bcf_reg_facade.export_views ev
     JOIN bcf_reg_facade.query_tree_roots qtr ON ((qtr.id = ev.query_tree_root_id)))
  ORDER BY qtr.display_name, ev.display_order;


ALTER TABLE bcf_reg_facade."v$export_views" OWNER TO bcf_reg_facade;

--
-- Name: v$latest_query_run; Type: VIEW; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE VIEW bcf_reg_facade."v$latest_query_run" AS
 SELECT max(qr.no) AS latest_query_no
   FROM bcf_reg_facade.query_runs qr
  WHERE (qr.run_by = ("session_user"())::text);


ALTER TABLE bcf_reg_facade."v$latest_query_run" OWNER TO bcf_reg_facade;

--
-- Name: VIEW "v$latest_query_run"; Type: COMMENT; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

COMMENT ON VIEW bcf_reg_facade."v$latest_query_run" IS 'Returns number of latest executed search for the current user.';


--
-- Name: v$qry$cmp_compounds; Type: VIEW; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE VIEW bcf_reg_facade."v$qry$cmp_compounds" AS
 SELECT par.id,
    par.name AS compound_no,
    par_prop.molecule,
    par_prop.pln AS pln_sequence,
    par.primary_type AS structure_primary_type,
    par_prop.sum_formula AS parent_sum_formula,
    par_prop.mw_avg AS parent_mw_avg,
    par_prop.mw_mono AS parent_mw_mono,
    par.comments,
    bcf_reg_facade.display_user_name(par.created_by) AS created_by,
    par.created_on,
    bcf_reg_facade.display_user_name(par.updated_by) AS updated_by,
    par.updated_on
   FROM (bcf_reg.parents par
     JOIN bcf_reg."parents$calc_props" par_prop ON ((par_prop.parent_id = par.id)));


ALTER TABLE bcf_reg_facade."v$qry$cmp_compounds" OWNER TO bcf_reg_facade;

--
-- Name: v$query_run_details; Type: VIEW; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE VIEW bcf_reg_facade."v$query_run_details" AS
 SELECT qrf.query_run_id,
    qrf.item_no AS "No",
    bcf_reg_facade.full_fieldname_path(qrf.field_name, qt.id) AS "Field name",
    bcf_reg_facade.criteria_to_string(bcf_reg_facade.coltype_to_fieldtype((cols.data_type)::text, (cols.udt_name)::text), qrf.operator, qrf.options, qrf.criteria_text, qrf.criteria_number, qrf.criteria_date1, qrf.criteria_date2) AS "Criteria"
   FROM (((bcf_reg_facade.query_run_fields qrf
     JOIN bcf_reg_facade.query_trees qt ON ((qt.id = qrf.query_item_id)))
     JOIN bcf_reg_facade.query_tree_roots qtr ON ((qtr.id = qt.query_tree_root_id)))
     JOIN information_schema.columns cols ON ((((cols.table_name)::text = qt.query_view) AND ((cols.column_name)::text = qrf.field_name) AND ((cols.table_schema)::text = 'bcf_reg_facade'::text))))
  WHERE (EXISTS ( SELECT query_runs.id
           FROM bcf_reg_facade.query_runs
          WHERE ((query_runs.id = qrf.query_run_id) AND (query_runs.run_by = ("session_user"())::text))))
  ORDER BY qrf.item_no;


ALTER TABLE bcf_reg_facade."v$query_run_details" OWNER TO bcf_reg_facade;

--
-- Name: v$query_run_fields; Type: VIEW; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE VIEW bcf_reg_facade."v$query_run_fields" AS
 SELECT qtr.display_name AS query_root_name,
    qrf.id,
    qrf.query_run_id,
    qrf.item_no,
    qrf.query_item_id,
    bcf_reg_facade.full_fieldname_path(qrf.field_name, qt.id) AS full_path_field_name,
    bcf_reg_facade.coltype_to_fieldtype((cols.data_type)::text, (cols.udt_name)::text) AS field_type,
    qrf.operator,
    qrf.options,
    qrf.criteria_text,
    qrf.criteria_number,
    qrf.criteria_date1,
    qrf.criteria_date2
   FROM (((bcf_reg_facade.query_run_fields qrf
     JOIN bcf_reg_facade.query_trees qt ON ((qt.id = qrf.query_item_id)))
     JOIN bcf_reg_facade.query_tree_roots qtr ON ((qtr.id = qt.query_tree_root_id)))
     JOIN information_schema.columns cols ON ((((cols.table_name)::text = qt.query_view) AND ((cols.column_name)::text = qrf.field_name) AND ((cols.table_schema)::text = 'bcf_reg_facade'::text))))
  WHERE (EXISTS ( SELECT query_runs.id
           FROM bcf_reg_facade.query_runs
          WHERE ((query_runs.id = qrf.query_run_id) AND (query_runs.run_by = ("session_user"())::text))));


ALTER TABLE bcf_reg_facade."v$query_run_fields" OWNER TO bcf_reg_facade;

--
-- Name: v$query_runs; Type: VIEW; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE VIEW bcf_reg_facade."v$query_runs" AS
 SELECT qr.id,
    qr.run_on,
    qr.within_list,
    qr.within_list_count,
    qr.result AS search_results,
    qr.no AS "No",
    qr.name AS "Name",
    qr.result_count AS "Hit count",
    COALESCE(( SELECT qtr.display_name
           FROM ((bcf_reg_facade.query_run_fields qrf
             JOIN bcf_reg_facade.query_trees qt ON ((qrf.query_item_id = qt.id)))
             JOIN bcf_reg_facade.query_tree_roots qtr ON ((qtr.id = qt.query_tree_root_id)))
          WHERE (qrf.query_run_id = qr.id)
         LIMIT 1),
        CASE
            WHEN ("position"(qr.result, ';'::text) = 0) THEN ''::text
            ELSE bcf_reg_facade.guess_query_root(substr(qr.result, 1, ("position"(qr.result, ';'::text) - 1)))
        END) AS "Query root",
    qr.run_on AS "Run on",
        CASE
            WHEN (qr.run_time >= '01:00:00'::interval) THEN to_char(qr.run_time, 'DD "days" HH24 "hrs" MI "mins"'::text)
            WHEN (qr.run_time >= '00:01:00'::interval) THEN to_char(qr.run_time, 'MI "min" SS "s"'::text)
            ELSE to_char(qr.run_time, 'SS.MS "s"'::text)
        END AS "Run time"
   FROM bcf_reg_facade.query_runs qr
  WHERE (qr.run_by = ("session_user"())::text);


ALTER TABLE bcf_reg_facade."v$query_runs" OWNER TO bcf_reg_facade;

--
-- Name: v$users_and_priv_levels; Type: VIEW; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE VIEW bcf_reg_facade."v$users_and_priv_levels" AS
 SELECT bcf_reg_facade.display_user_name(usrs.db_user_name) AS "Display user name",
    usrs.db_user_name AS "Database user",
    usrs.email_address AS "Recorded e-mail address",
    ( SELECT string_agg(initcap(replace((grp.groname)::text, 'bcf_reg_'::text, ''::text)), '; '::text ORDER BY grp.groname) AS string_agg
           FROM (pg_user usr
             JOIN pg_group grp ON ((usr.usesysid = ANY (grp.grolist))))
          WHERE (((usr.usename)::text = usrs.db_user_name) AND (grp.groname ~~ 'bcf_reg_%'::text) AND (grp.groname !~~ 'bcf_reg_stock_%'::text))) AS "Reg. privileges",
    ( SELECT string_agg(initcap(replace((grp.groname)::text, 'bcf_reg_'::text, ''::text)), '; '::text ORDER BY grp.groname) AS string_agg
           FROM (pg_user usr
             JOIN pg_group grp ON ((usr.usesysid = ANY (grp.grolist))))
          WHERE (((usr.usename)::text = usrs.db_user_name) AND (grp.groname ~~ 'bcf_reg_stock_%'::text))) AS "Stock privileges"
   FROM bcf_auth."v$email_addresses" usrs;


ALTER TABLE bcf_reg_facade."v$users_and_priv_levels" OWNER TO bcf_reg_facade;

--
-- Name: VIEW "v$users_and_priv_levels"; Type: COMMENT; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

COMMENT ON VIEW bcf_reg_facade."v$users_and_priv_levels" IS 'View listing all database users, their registered e-mails, and their assigned privilege levels.';


--
-- Name: cached_user_names; Type: TABLE; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

CREATE TABLE bcf_reg_web_facade.cached_user_names (
    source_table text,
    source_column text,
    user_name text
);


ALTER TABLE bcf_reg_web_facade.cached_user_names OWNER TO bcf_reg_facade;

--
-- Name: v$cmp_compounds; Type: VIEW; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

CREATE VIEW bcf_reg_web_facade."v$cmp_compounds" AS
 SELECT par.id,
    par.name,
    par.comments,
    parprop.svg_rendering,
    parprop.sum_formula,
    (round((parprop.mw_avg)::numeric, 4))::double precision AS mw_avg,
    (round((parprop.mw_mono)::numeric, 4))::double precision AS mw_mono,
    ( SELECT prop.clogp
           FROM ((bcf_reg.compounds cmp
             JOIN bcf_reg.salts slt ON ((slt.id = cmp.salt_id)))
             JOIN bcf_reg."compounds$calc_props" prop ON ((prop.compound_id = cmp.id)))
          WHERE ((cmp.parent_id = par.id) AND (slt.name = 'None'::text))) AS clogp,
    ( SELECT prop.logp
           FROM ((bcf_reg.compounds cmp
             JOIN bcf_reg.salts slt ON ((slt.id = cmp.salt_id)))
             JOIN bcf_reg."compounds$calc_props" prop ON ((prop.compound_id = cmp.id)))
          WHERE ((cmp.parent_id = par.id) AND (slt.name = 'None'::text))) AS logp,
    ( SELECT prop.logd
           FROM ((bcf_reg.compounds cmp
             JOIN bcf_reg.salts slt ON ((slt.id = cmp.salt_id)))
             JOIN bcf_reg."compounds$calc_props" prop ON ((prop.compound_id = cmp.id)))
          WHERE ((cmp.parent_id = par.id) AND (slt.name = 'None'::text))) AS logd,
    bcf_reg_facade.display_user_name(par.created_by) AS created_by,
    par.created_on
   FROM (bcf_reg.parents par
     JOIN bcf_reg."parents$calc_props" parprop ON ((parprop.parent_id = par.id)));


ALTER TABLE bcf_reg_web_facade."v$cmp_compounds" OWNER TO bcf_reg_facade;

--
-- Name: v$cmp_overview; Type: VIEW; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

CREATE VIEW bcf_reg_web_facade."v$cmp_overview" AS
 SELECT par.id,
    par.name,
    par_props.svg_rendering,
    (round((par_props.mw_avg)::numeric, 4))::double precision AS mw_avg,
    (round((par_props.mw_mono)::numeric, 4))::double precision AS mw_mono,
    par_props.sum_formula,
    ( SELECT prop.clogp
           FROM ((bcf_reg.compounds cmp
             JOIN bcf_reg.salts slt ON ((slt.id = cmp.salt_id)))
             JOIN bcf_reg."compounds$calc_props" prop ON ((prop.compound_id = cmp.id)))
          WHERE ((cmp.parent_id = par.id) AND (slt.name = 'None'::text))) AS clogp,
    ( SELECT prop.logp
           FROM ((bcf_reg.compounds cmp
             JOIN bcf_reg.salts slt ON ((slt.id = cmp.salt_id)))
             JOIN bcf_reg."compounds$calc_props" prop ON ((prop.compound_id = cmp.id)))
          WHERE ((cmp.parent_id = par.id) AND (slt.name = 'None'::text))) AS logp,
    ( SELECT prop.logd
           FROM ((bcf_reg.compounds cmp
             JOIN bcf_reg.salts slt ON ((slt.id = cmp.salt_id)))
             JOIN bcf_reg."compounds$calc_props" prop ON ((prop.compound_id = cmp.id)))
          WHERE ((cmp.parent_id = par.id) AND (slt.name = 'None'::text))) AS logd
   FROM (bcf_reg.parents par
     JOIN bcf_reg."parents$calc_props" par_props ON ((par_props.parent_id = par.id)));


ALTER TABLE bcf_reg_web_facade."v$cmp_overview" OWNER TO bcf_reg_facade;

--
-- Name: v$compounds_edit; Type: VIEW; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

CREATE VIEW bcf_reg_web_facade."v$compounds_edit" AS
 SELECT par.id,
    par.name,
    par.original_registration AS molfile,
    par.comments,
    par.duplicate_reason,
    bcf_reg_facade.display_user_name(par.created_by) AS created_by,
    par.created_on,
    bcf_reg_facade.display_user_name(par.updated_by) AS updated_by,
    par.updated_on
   FROM bcf_reg.parents par;


ALTER TABLE bcf_reg_web_facade."v$compounds_edit" OWNER TO bcf_reg_facade;

--
-- Name: v$lookup_salts; Type: VIEW; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

CREATE VIEW bcf_reg_web_facade."v$lookup_salts" AS
 SELECT slt.id,
    slt.name,
    slt.short_name,
    slt.sum_formula,
    slt.mw_avg
   FROM bcf_reg.salts slt
  ORDER BY slt.name;


ALTER TABLE bcf_reg_web_facade."v$lookup_salts" OWNER TO bcf_reg_facade;

--
-- Name: v$salts_edit; Type: VIEW; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

CREATE VIEW bcf_reg_web_facade."v$salts_edit" AS
 SELECT slt.id,
    slt.name,
    slt.short_name,
    slt.sum_formula,
    slt.mw_avg,
    slt.mw_mono,
    bcf_reg_facade.display_user_name(slt.created_by) AS created_by,
    slt.created_on,
    bcf_reg_facade.display_user_name(slt.updated_by) AS updated_by,
    slt.updated_on
   FROM bcf_reg.salts slt;


ALTER TABLE bcf_reg_web_facade."v$salts_edit" OWNER TO bcf_reg_facade;

--
-- Name: VIEW "v$salts_edit"; Type: COMMENT; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

COMMENT ON VIEW bcf_reg_web_facade."v$salts_edit" IS 'View for managing salts. Admins only.';


--
-- Name: parents$calc_queue id; Type: DEFAULT; Schema: bcf_reg; Owner: bcf_reg
--

ALTER TABLE ONLY bcf_reg."parents$calc_queue" ALTER COLUMN id SET DEFAULT nextval('bcf_reg."parents$calc_queue_id_seq"'::regclass);


--
-- Data for Name: user_mappings; Type: TABLE DATA; Schema: bcf_auth; Owner: bcf_auth
--

COPY bcf_auth.user_mappings (id, external_user_name, db_user_name, db_password, email_address, status, is_enabled) FROM stdin;
\.


--
-- Data for Name: users_admin; Type: TABLE DATA; Schema: bcf_auth; Owner: bcf_auth
--

COPY bcf_auth.users_admin (initials) FROM stdin;
\.


--
-- Data for Name: users_editor; Type: TABLE DATA; Schema: bcf_auth; Owner: bcf_auth
--

COPY bcf_auth.users_editor (initials) FROM stdin;
\.


--
-- Data for Name: users_viewer; Type: TABLE DATA; Schema: bcf_auth; Owner: bcf_auth
--

COPY bcf_auth.users_viewer (initials) FROM stdin;
\.


--
-- Data for Name: compounds; Type: TABLE DATA; Schema: bcf_reg; Owner: bcf_reg
--

COPY bcf_reg.compounds (id, name, parent_id, salt_id, structure_ratio, salt_ratio, comments, created_by, created_on, updated_by, update_reason, updated_on) FROM stdin;
\.


--
-- Data for Name: compounds$calc_props; Type: TABLE DATA; Schema: bcf_reg; Owner: bcf_reg
--

COPY bcf_reg."compounds$calc_props" (compound_id, mw_avg, mw_mono, sum_formula, theoretical_structure_fraction, clogp, logp, logd) FROM stdin;
\.


--
-- Data for Name: db_revision; Type: TABLE DATA; Schema: bcf_reg; Owner: bcf_reg
--

COPY bcf_reg.db_revision (revision) FROM stdin;
\.


--
-- Data for Name: delete_reasons; Type: TABLE DATA; Schema: bcf_reg; Owner: bcf_reg
--

COPY bcf_reg.delete_reasons (id, delete_reason) FROM stdin;
\.


--
-- Data for Name: jn$compounds; Type: TABLE DATA; Schema: bcf_reg; Owner: bcf_reg
--

COPY bcf_reg."jn$compounds" ("jn$timestamp", "jn$operation", "jn$user", id, name, parent_id, salt_id, structure_ratio, salt_ratio, comments, created_by, created_on, updated_by, update_reason, updated_on) FROM stdin;
\.


--
-- Data for Name: jn$parents; Type: TABLE DATA; Schema: bcf_reg; Owner: bcf_reg
--

COPY bcf_reg."jn$parents" ("jn$timestamp", "jn$operation", "jn$user", id, no, name, comments, original_registration, primary_type, structure_key, duplicate_reason, created_by, created_on, updated_by, update_reason, updated_on) FROM stdin;
\.


--
-- Data for Name: jn$salts; Type: TABLE DATA; Schema: bcf_reg; Owner: bcf_reg
--

COPY bcf_reg."jn$salts" ("jn$timestamp", "jn$operation", "jn$user", id, name, short_name, molfile, molecule, auto_calc_properties, sum_formula, mw_avg, mw_mono, created_by, created_on, updated_by, update_reason, updated_on) FROM stdin;
2019-11-15 20:28:28.964053+01	INS	postgres	1	None	None	\N	\N	N		0	0	postgres	2019-11-15 20:28:28.964053+01	\N	\N	\N
\.


--
-- Data for Name: parents; Type: TABLE DATA; Schema: bcf_reg; Owner: bcf_reg
--

COPY bcf_reg.parents (id, no, name, comments, original_registration, primary_type, structure_key, duplicate_reason, created_by, created_on, updated_by, update_reason, updated_on) FROM stdin;
\.


--
-- Data for Name: parents$calc_props; Type: TABLE DATA; Schema: bcf_reg; Owner: bcf_reg
--

COPY bcf_reg."parents$calc_props" (id, molecule, pln, conversion_errors, sum_formula, mw_avg, mw_mono, norm_seq_chksum, norm_prot_chksum, protein_key_chksum, inchi_key, predicted_pi, predicted_anion_count, predicted_cation_count, svg_rendering, parent_id) FROM stdin;
\.


--
-- Data for Name: parents$calc_queue; Type: TABLE DATA; Schema: bcf_reg; Owner: bcf_reg
--

COPY bcf_reg."parents$calc_queue" (id, parent_id) FROM stdin;
\.


--
-- Data for Name: salts; Type: TABLE DATA; Schema: bcf_reg; Owner: bcf_reg
--

COPY bcf_reg.salts (id, name, short_name, molfile, molecule, auto_calc_properties, sum_formula, mw_avg, mw_mono, created_by, created_on, updated_by, update_reason, updated_on) FROM stdin;
1	None	None	\N	\N	N		0	0	postgres	2019-11-15 20:28:28.964053+01	\N	\N	\N
\.


--
-- Data for Name: unique$names; Type: TABLE DATA; Schema: bcf_reg; Owner: bcf_reg
--

COPY bcf_reg."unique$names" (id, source_table, name) FROM stdin;
\.


--
-- Data for Name: db_config; Type: TABLE DATA; Schema: bcf_reg_config; Owner: bcf_auth
--

COPY bcf_reg_config.db_config (property, value) FROM stdin;
\.


--
-- Data for Name: jn$db_config; Type: TABLE DATA; Schema: bcf_reg_config; Owner: postgres
--

COPY bcf_reg_config."jn$db_config" ("jn$timestamp", "jn$operation", "jn$user", property, value) FROM stdin;
\.


--
-- Data for Name: export_views; Type: TABLE DATA; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

COPY bcf_reg_facade.export_views (id, query_tree_root_id, display_order, requires_admin, display_name, export_type, export_view, export_view_key_field) FROM stdin;
\.


--
-- Data for Name: query_run_fields; Type: TABLE DATA; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

COPY bcf_reg_facade.query_run_fields (id, query_run_id, item_no, query_item_id, field_name, operator, options, criteria_text, criteria_number, criteria_date1, criteria_date2) FROM stdin;
\.


--
-- Data for Name: query_runs; Type: TABLE DATA; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

COPY bcf_reg_facade.query_runs (id, no, name, result, result_count, sql_text, run_by, run_on, run_time, within_list, within_list_count) FROM stdin;
\.


--
-- Data for Name: query_tree_roots; Type: TABLE DATA; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

COPY bcf_reg_facade.query_tree_roots (id, display_name, key_field) FROM stdin;
1	compounds	compound_no
\.


--
-- Data for Name: query_trees; Type: TABLE DATA; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

COPY bcf_reg_facade.query_trees (id, query_tree_root_id, parent_item_id, item_no, level_no, display_name, query_view, hidden_fields, parent_link) FROM stdin;
2	1	\N	0	0	compounds	v$qry$cmp_compounds	id	
\.


--
-- Data for Name: cached_user_names; Type: TABLE DATA; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

COPY bcf_reg_web_facade.cached_user_names (source_table, source_column, user_name) FROM stdin;
\.


--
-- Name: id_sequence; Type: SEQUENCE SET; Schema: bcf_auth; Owner: bcf_auth
--

SELECT pg_catalog.setval('bcf_auth.id_sequence', 1, false);


--
-- Name: id_sequence; Type: SEQUENCE SET; Schema: bcf_reg; Owner: bcf_reg
--

SELECT pg_catalog.setval('bcf_reg.id_sequence', 1, true);


--
-- Name: parent_no_sequence; Type: SEQUENCE SET; Schema: bcf_reg; Owner: bcf_reg
--

SELECT pg_catalog.setval('bcf_reg.parent_no_sequence', 1, false);


--
-- Name: parents$calc_queue_id_seq; Type: SEQUENCE SET; Schema: bcf_reg; Owner: bcf_reg
--

SELECT pg_catalog.setval('bcf_reg."parents$calc_queue_id_seq"', 1, false);


--
-- Name: id_sequence; Type: SEQUENCE SET; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

SELECT pg_catalog.setval('bcf_reg_facade.id_sequence', 2, true);


--
-- Name: query_no_sequence; Type: SEQUENCE SET; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

SELECT pg_catalog.setval('bcf_reg_facade.query_no_sequence', 1, false);


--
-- Name: report_no_sequence; Type: SEQUENCE SET; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

SELECT pg_catalog.setval('bcf_reg_facade.report_no_sequence', 1, false);


--
-- Name: user_mappings user_mappings_db_user_name_key; Type: CONSTRAINT; Schema: bcf_auth; Owner: bcf_auth
--

ALTER TABLE ONLY bcf_auth.user_mappings
    ADD CONSTRAINT user_mappings_db_user_name_key UNIQUE (db_user_name);


--
-- Name: user_mappings user_mappings_external_user_name_key; Type: CONSTRAINT; Schema: bcf_auth; Owner: bcf_auth
--

ALTER TABLE ONLY bcf_auth.user_mappings
    ADD CONSTRAINT user_mappings_external_user_name_key UNIQUE (external_user_name);


--
-- Name: user_mappings user_mappings_pkey; Type: CONSTRAINT; Schema: bcf_auth; Owner: bcf_auth
--

ALTER TABLE ONLY bcf_auth.user_mappings
    ADD CONSTRAINT user_mappings_pkey PRIMARY KEY (id);


--
-- Name: compounds$calc_props compounds$calc_props_compound_id_key; Type: CONSTRAINT; Schema: bcf_reg; Owner: bcf_reg
--

ALTER TABLE ONLY bcf_reg."compounds$calc_props"
    ADD CONSTRAINT "compounds$calc_props_compound_id_key" UNIQUE (compound_id);


--
-- Name: compounds compounds_name_key; Type: CONSTRAINT; Schema: bcf_reg; Owner: bcf_reg
--

ALTER TABLE ONLY bcf_reg.compounds
    ADD CONSTRAINT compounds_name_key UNIQUE (name);


--
-- Name: compounds compounds_pkey; Type: CONSTRAINT; Schema: bcf_reg; Owner: bcf_reg
--

ALTER TABLE ONLY bcf_reg.compounds
    ADD CONSTRAINT compounds_pkey PRIMARY KEY (id);


--
-- Name: delete_reasons delete_reasons_pkey; Type: CONSTRAINT; Schema: bcf_reg; Owner: bcf_reg
--

ALTER TABLE ONLY bcf_reg.delete_reasons
    ADD CONSTRAINT delete_reasons_pkey PRIMARY KEY (id);


--
-- Name: parents$calc_props parents$calc_props_pkey; Type: CONSTRAINT; Schema: bcf_reg; Owner: bcf_reg
--

ALTER TABLE ONLY bcf_reg."parents$calc_props"
    ADD CONSTRAINT "parents$calc_props_pkey" PRIMARY KEY (id);


--
-- Name: parents parents_name_key; Type: CONSTRAINT; Schema: bcf_reg; Owner: bcf_reg
--

ALTER TABLE ONLY bcf_reg.parents
    ADD CONSTRAINT parents_name_key UNIQUE (name);


--
-- Name: parents parents_no_key; Type: CONSTRAINT; Schema: bcf_reg; Owner: bcf_reg
--

ALTER TABLE ONLY bcf_reg.parents
    ADD CONSTRAINT parents_no_key UNIQUE (no);


--
-- Name: parents parents_pkey; Type: CONSTRAINT; Schema: bcf_reg; Owner: bcf_reg
--

ALTER TABLE ONLY bcf_reg.parents
    ADD CONSTRAINT parents_pkey PRIMARY KEY (id);


--
-- Name: salts salts_pkey; Type: CONSTRAINT; Schema: bcf_reg; Owner: bcf_reg
--

ALTER TABLE ONLY bcf_reg.salts
    ADD CONSTRAINT salts_pkey PRIMARY KEY (id);


--
-- Name: unique$names unique$names_pkey; Type: CONSTRAINT; Schema: bcf_reg; Owner: bcf_reg
--

ALTER TABLE ONLY bcf_reg."unique$names"
    ADD CONSTRAINT "unique$names_pkey" PRIMARY KEY (id);


--
-- Name: compounds unique_compound_salt; Type: CONSTRAINT; Schema: bcf_reg; Owner: bcf_reg
--

ALTER TABLE ONLY bcf_reg.compounds
    ADD CONSTRAINT unique_compound_salt UNIQUE (parent_id, salt_id);


--
-- Name: export_views export_views_pkey; Type: CONSTRAINT; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

ALTER TABLE ONLY bcf_reg_facade.export_views
    ADD CONSTRAINT export_views_pkey PRIMARY KEY (id);


--
-- Name: query_run_fields query_run_fields_pkey; Type: CONSTRAINT; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

ALTER TABLE ONLY bcf_reg_facade.query_run_fields
    ADD CONSTRAINT query_run_fields_pkey PRIMARY KEY (id);


--
-- Name: query_runs query_runs_pkey; Type: CONSTRAINT; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

ALTER TABLE ONLY bcf_reg_facade.query_runs
    ADD CONSTRAINT query_runs_pkey PRIMARY KEY (id);


--
-- Name: query_tree_roots query_tree_roots_pkey; Type: CONSTRAINT; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

ALTER TABLE ONLY bcf_reg_facade.query_tree_roots
    ADD CONSTRAINT query_tree_roots_pkey PRIMARY KEY (id);


--
-- Name: query_trees query_trees_pkey; Type: CONSTRAINT; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

ALTER TABLE ONLY bcf_reg_facade.query_trees
    ADD CONSTRAINT query_trees_pkey PRIMARY KEY (id);


--
-- Name: usermap_unique_dbusername_idx; Type: INDEX; Schema: bcf_auth; Owner: bcf_auth
--

CREATE INDEX usermap_unique_dbusername_idx ON bcf_auth.user_mappings USING btree (upper(db_user_name));


--
-- Name: usermap_unique_extusername_idx; Type: INDEX; Schema: bcf_auth; Owner: bcf_auth
--

CREATE INDEX usermap_unique_extusername_idx ON bcf_auth.user_mappings USING btree (upper(external_user_name));


--
-- Name: compound_parentfk_idx; Type: INDEX; Schema: bcf_reg; Owner: bcf_reg
--

CREATE INDEX compound_parentfk_idx ON bcf_reg.compounds USING btree (parent_id);


--
-- Name: compound_saltfk_idx; Type: INDEX; Schema: bcf_reg; Owner: bcf_reg
--

CREATE INDEX compound_saltfk_idx ON bcf_reg.compounds USING btree (salt_id);


--
-- Name: parent_molecule_fp_idx; Type: INDEX; Schema: bcf_reg; Owner: bcf_reg
--

CREATE INDEX parent_molecule_fp_idx ON bcf_reg."parents$calc_props" USING gist (rdkit.morganbv_fp(molecule));


--
-- Name: parent_molecule_idx; Type: INDEX; Schema: bcf_reg; Owner: bcf_reg
--

CREATE INDEX parent_molecule_idx ON bcf_reg."parents$calc_props" USING gist (molecule);


--
-- Name: parentcalcprops_parentid_idx; Type: INDEX; Schema: bcf_reg; Owner: bcf_reg
--

CREATE UNIQUE INDEX parentcalcprops_parentid_idx ON bcf_reg."parents$calc_props" USING btree (parent_id);


--
-- Name: unique_names_idx; Type: INDEX; Schema: bcf_reg; Owner: bcf_reg
--

CREATE UNIQUE INDEX unique_names_idx ON bcf_reg."unique$names" USING btree (btrim(upper(name)));


--
-- Name: unique_parent_structure_idx; Type: INDEX; Schema: bcf_reg; Owner: bcf_reg
--

CREATE UNIQUE INDEX unique_parent_structure_idx ON bcf_reg.parents USING btree (structure_key, btrim(upper(duplicate_reason)));


--
-- Name: unique_salts_name_idx; Type: INDEX; Schema: bcf_reg; Owner: bcf_reg
--

CREATE UNIQUE INDEX unique_salts_name_idx ON bcf_reg.salts USING btree (btrim(upper(name)));


--
-- Name: unique_salts_short_name_idx; Type: INDEX; Schema: bcf_reg; Owner: bcf_reg
--

CREATE UNIQUE INDEX unique_salts_short_name_idx ON bcf_reg.salts USING btree (btrim(upper(short_name)));


--
-- Name: dbconfig_property_idx; Type: INDEX; Schema: bcf_reg_config; Owner: bcf_auth
--

CREATE UNIQUE INDEX dbconfig_property_idx ON bcf_reg_config.db_config USING btree (property);


--
-- Name: query_runs__user_no_idx; Type: INDEX; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE INDEX query_runs__user_no_idx ON bcf_reg_facade.query_runs USING btree (run_by, no);


--
-- Name: queryrunfields_queryrun_fk_idx; Type: INDEX; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE INDEX queryrunfields_queryrun_fk_idx ON bcf_reg_facade.query_run_fields USING btree (query_run_id);


--
-- Name: unique_export_view_name; Type: INDEX; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE UNIQUE INDEX unique_export_view_name ON bcf_reg_facade.export_views USING btree (query_tree_root_id, btrim(upper(display_name)));


--
-- Name: unique_querytree_itemnumbers; Type: INDEX; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE UNIQUE INDEX unique_querytree_itemnumbers ON bcf_reg_facade.query_trees USING btree (query_tree_root_id, item_no);


--
-- Name: unique_querytreeroot_displayname; Type: INDEX; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE UNIQUE INDEX unique_querytreeroot_displayname ON bcf_reg_facade.query_tree_roots USING btree (lower(display_name));


--
-- Name: source_username_idx; Type: INDEX; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

CREATE INDEX source_username_idx ON bcf_reg_web_facade.cached_user_names USING btree (source_table, source_column, user_name);


--
-- Name: compounds aiudr_compounds_sync_unique_names; Type: TRIGGER; Schema: bcf_reg; Owner: bcf_reg
--

CREATE TRIGGER aiudr_compounds_sync_unique_names AFTER INSERT OR DELETE OR UPDATE ON bcf_reg.compounds FOR EACH ROW EXECUTE PROCEDURE bcf_reg."trg$update_unique_names"();


--
-- Name: parents aiudr_parents_sync_unique_names; Type: TRIGGER; Schema: bcf_reg; Owner: bcf_reg
--

CREATE TRIGGER aiudr_parents_sync_unique_names AFTER INSERT OR DELETE OR UPDATE ON bcf_reg.parents FOR EACH ROW EXECUTE PROCEDURE bcf_reg."trg$update_unique_names"();


--
-- Name: compounds aiur_compounds_calc_props; Type: TRIGGER; Schema: bcf_reg; Owner: bcf_reg
--

CREATE TRIGGER aiur_compounds_calc_props AFTER INSERT OR UPDATE ON bcf_reg.compounds FOR EACH ROW EXECUTE PROCEDURE bcf_reg."trg$calc_compound_props"();


--
-- Name: compounds bdr_compounds_check_delete_reason; Type: TRIGGER; Schema: bcf_reg; Owner: bcf_reg
--

CREATE TRIGGER bdr_compounds_check_delete_reason BEFORE DELETE ON bcf_reg.compounds FOR EACH ROW EXECUTE PROCEDURE bcf_reg."trg$check_has_delete_reason"();


--
-- Name: parents bdr_parents_check_delete_reason; Type: TRIGGER; Schema: bcf_reg; Owner: bcf_reg
--

CREATE TRIGGER bdr_parents_check_delete_reason BEFORE DELETE ON bcf_reg.parents FOR EACH ROW EXECUTE PROCEDURE bcf_reg."trg$check_has_delete_reason"();


--
-- Name: salts bdr_salts_check_delete_reason; Type: TRIGGER; Schema: bcf_reg; Owner: bcf_reg
--

CREATE TRIGGER bdr_salts_check_delete_reason BEFORE DELETE ON bcf_reg.salts FOR EACH ROW EXECUTE PROCEDURE bcf_reg."trg$check_has_delete_reason"();


--
-- Name: compounds bir_compounds_assign_name; Type: TRIGGER; Schema: bcf_reg; Owner: bcf_reg
--

CREATE TRIGGER bir_compounds_assign_name BEFORE INSERT ON bcf_reg.compounds FOR EACH ROW EXECUTE PROCEDURE bcf_reg."trg$assign_compound_name"();


--
-- Name: parents biur_parents_calcprops_check_dupreason; Type: TRIGGER; Schema: bcf_reg; Owner: bcf_reg
--

CREATE TRIGGER biur_parents_calcprops_check_dupreason BEFORE INSERT OR UPDATE ON bcf_reg.parents FOR EACH ROW EXECUTE PROCEDURE bcf_reg."trg$calc_parent_props_and_check_dupreason"();


--
-- Name: salts biur_salts; Type: TRIGGER; Schema: bcf_reg; Owner: bcf_reg
--

CREATE TRIGGER biur_salts BEFORE INSERT OR UPDATE ON bcf_reg.salts FOR EACH ROW EXECUTE PROCEDURE bcf_reg."trg$biur_salts"();


--
-- Name: compounds bur_compounds_check_update_reason; Type: TRIGGER; Schema: bcf_reg; Owner: bcf_reg
--

CREATE TRIGGER bur_compounds_check_update_reason BEFORE UPDATE ON bcf_reg.compounds FOR EACH ROW EXECUTE PROCEDURE bcf_reg."trg$check_non_blank_update_reason"();


--
-- Name: compounds bur_compounds_set_updated_fields; Type: TRIGGER; Schema: bcf_reg; Owner: bcf_reg
--

CREATE TRIGGER bur_compounds_set_updated_fields BEFORE UPDATE ON bcf_reg.compounds FOR EACH ROW EXECUTE PROCEDURE bcf_reg."trg$set_updated_fields"();


--
-- Name: compounds bur_compounds_update_name; Type: TRIGGER; Schema: bcf_reg; Owner: bcf_reg
--

CREATE TRIGGER bur_compounds_update_name BEFORE UPDATE ON bcf_reg.compounds FOR EACH ROW EXECUTE PROCEDURE bcf_reg."trg$assign_compound_name"();


--
-- Name: parents bur_parents_check_update_reason; Type: TRIGGER; Schema: bcf_reg; Owner: bcf_reg
--

CREATE TRIGGER bur_parents_check_update_reason BEFORE UPDATE ON bcf_reg.parents FOR EACH ROW EXECUTE PROCEDURE bcf_reg."trg$check_non_blank_update_reason"();


--
-- Name: parents bur_parents_set_updated_fields; Type: TRIGGER; Schema: bcf_reg; Owner: bcf_reg
--

CREATE TRIGGER bur_parents_set_updated_fields BEFORE UPDATE ON bcf_reg.parents FOR EACH ROW EXECUTE PROCEDURE bcf_reg."trg$set_updated_fields"();


--
-- Name: salts bur_salts; Type: TRIGGER; Schema: bcf_reg; Owner: bcf_reg
--

CREATE TRIGGER bur_salts BEFORE UPDATE ON bcf_reg.salts FOR EACH ROW EXECUTE PROCEDURE bcf_reg."trg$set_updated_fields"();


--
-- Name: salts bur_salts_check_update_reason; Type: TRIGGER; Schema: bcf_reg; Owner: bcf_reg
--

CREATE TRIGGER bur_salts_check_update_reason BEFORE UPDATE ON bcf_reg.salts FOR EACH ROW EXECUTE PROCEDURE bcf_reg."trg$check_non_blank_update_reason"();


--
-- Name: salts jn$ins_upd_del; Type: TRIGGER; Schema: bcf_reg; Owner: bcf_reg
--

CREATE TRIGGER "jn$ins_upd_del" AFTER INSERT OR DELETE OR UPDATE ON bcf_reg.salts FOR EACH ROW EXECUTE PROCEDURE bcf_reg."trg$jn$salts"();


--
-- Name: parents jn$ins_upd_del; Type: TRIGGER; Schema: bcf_reg; Owner: bcf_reg
--

CREATE TRIGGER "jn$ins_upd_del" AFTER INSERT OR DELETE OR UPDATE ON bcf_reg.parents FOR EACH ROW EXECUTE PROCEDURE bcf_reg."trg$jn$parents"();


--
-- Name: compounds jn$ins_upd_del; Type: TRIGGER; Schema: bcf_reg; Owner: bcf_reg
--

CREATE TRIGGER "jn$ins_upd_del" AFTER INSERT OR DELETE OR UPDATE ON bcf_reg.compounds FOR EACH ROW EXECUTE PROCEDURE bcf_reg."trg$jn$compounds"();


--
-- Name: parents z99_bir_parents_assign_no_and_name; Type: TRIGGER; Schema: bcf_reg; Owner: bcf_reg
--

CREATE TRIGGER z99_bir_parents_assign_no_and_name BEFORE INSERT ON bcf_reg.parents FOR EACH ROW EXECUTE PROCEDURE bcf_reg."trg$assign_parent_no_and_name"();


--
-- Name: TRIGGER z99_bir_parents_assign_no_and_name ON parents; Type: COMMENT; Schema: bcf_reg; Owner: bcf_reg
--

COMMENT ON TRIGGER z99_bir_parents_assign_no_and_name ON bcf_reg.parents IS 'Named like it is to ensure that it executes last.';


--
-- Name: db_config jn$ins_upd_del; Type: TRIGGER; Schema: bcf_reg_config; Owner: bcf_auth
--

CREATE TRIGGER "jn$ins_upd_del" AFTER INSERT OR DELETE OR UPDATE ON bcf_reg_config.db_config FOR EACH ROW EXECUTE PROCEDURE bcf_reg_config."trg$jn$db_config"();


--
-- Name: v$query_runs instead_of_delete; Type: TRIGGER; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE TRIGGER instead_of_delete INSTEAD OF DELETE ON bcf_reg_facade."v$query_runs" FOR EACH ROW EXECUTE PROCEDURE bcf_reg_facade."trg$delete_query_runs"();


--
-- Name: v$query_runs instead_of_update; Type: TRIGGER; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

CREATE TRIGGER instead_of_update INSTEAD OF UPDATE ON bcf_reg_facade."v$query_runs" FOR EACH ROW EXECUTE PROCEDURE bcf_reg_facade."trg$update_query_runs"();


--
-- Name: v$salts_edit instead_of_delete; Type: TRIGGER; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

CREATE TRIGGER instead_of_delete INSTEAD OF DELETE ON bcf_reg_web_facade."v$salts_edit" FOR EACH ROW EXECUTE PROCEDURE bcf_reg_web_facade."trg$delete_v$salts_edit"();


--
-- Name: v$compounds_edit instead_of_insert; Type: TRIGGER; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

CREATE TRIGGER instead_of_insert INSTEAD OF INSERT ON bcf_reg_web_facade."v$compounds_edit" FOR EACH ROW EXECUTE PROCEDURE bcf_reg_web_facade."trg$insert_v$compounds_edit"();


--
-- Name: v$salts_edit instead_of_update; Type: TRIGGER; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

CREATE TRIGGER instead_of_update INSTEAD OF UPDATE ON bcf_reg_web_facade."v$salts_edit" FOR EACH ROW EXECUTE PROCEDURE bcf_reg_web_facade."trg$update_v$salts_edit"();


--
-- Name: v$compounds_edit instead_of_update; Type: TRIGGER; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

CREATE TRIGGER instead_of_update INSTEAD OF UPDATE ON bcf_reg_web_facade."v$compounds_edit" FOR EACH ROW EXECUTE PROCEDURE bcf_reg_web_facade."trg$update_v$compounds_edit"();


--
-- Name: compounds$calc_props compcalcprop_comp_fk; Type: FK CONSTRAINT; Schema: bcf_reg; Owner: bcf_reg
--

ALTER TABLE ONLY bcf_reg."compounds$calc_props"
    ADD CONSTRAINT compcalcprop_comp_fk FOREIGN KEY (compound_id) REFERENCES bcf_reg.compounds(id) ON DELETE CASCADE;


--
-- Name: compounds compound_parent_fk; Type: FK CONSTRAINT; Schema: bcf_reg; Owner: bcf_reg
--

ALTER TABLE ONLY bcf_reg.compounds
    ADD CONSTRAINT compound_parent_fk FOREIGN KEY (parent_id) REFERENCES bcf_reg.parents(id);


--
-- Name: compounds compound_salt_fk; Type: FK CONSTRAINT; Schema: bcf_reg; Owner: bcf_reg
--

ALTER TABLE ONLY bcf_reg.compounds
    ADD CONSTRAINT compound_salt_fk FOREIGN KEY (salt_id) REFERENCES bcf_reg.salts(id);


--
-- Name: parents$calc_props parent$calcprop_parent_fk; Type: FK CONSTRAINT; Schema: bcf_reg; Owner: bcf_reg
--

ALTER TABLE ONLY bcf_reg."parents$calc_props"
    ADD CONSTRAINT "parent$calcprop_parent_fk" FOREIGN KEY (parent_id) REFERENCES bcf_reg.parents(id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: export_views exportview_querytree_fk; Type: FK CONSTRAINT; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

ALTER TABLE ONLY bcf_reg_facade.export_views
    ADD CONSTRAINT exportview_querytree_fk FOREIGN KEY (query_tree_root_id) REFERENCES bcf_reg_facade.query_tree_roots(id);


--
-- Name: query_run_fields qryrunfld_qryrun_fk; Type: FK CONSTRAINT; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

ALTER TABLE ONLY bcf_reg_facade.query_run_fields
    ADD CONSTRAINT qryrunfld_qryrun_fk FOREIGN KEY (query_run_id) REFERENCES bcf_reg_facade.query_runs(id);


--
-- Name: query_run_fields qryrunfld_qrytreeitem_fk; Type: FK CONSTRAINT; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

ALTER TABLE ONLY bcf_reg_facade.query_run_fields
    ADD CONSTRAINT qryrunfld_qrytreeitem_fk FOREIGN KEY (query_item_id) REFERENCES bcf_reg_facade.query_trees(id);


--
-- Name: query_trees querytree_parentitem_fk; Type: FK CONSTRAINT; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

ALTER TABLE ONLY bcf_reg_facade.query_trees
    ADD CONSTRAINT querytree_parentitem_fk FOREIGN KEY (parent_item_id) REFERENCES bcf_reg_facade.query_trees(id);


--
-- Name: query_trees querytree_root_fk; Type: FK CONSTRAINT; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

ALTER TABLE ONLY bcf_reg_facade.query_trees
    ADD CONSTRAINT querytree_root_fk FOREIGN KEY (query_tree_root_id) REFERENCES bcf_reg_facade.query_tree_roots(id);


--
-- Name: SCHEMA aux_services; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA aux_services TO bcf_reg WITH GRANT OPTION;
GRANT USAGE ON SCHEMA aux_services TO bcf_reg_facade WITH GRANT OPTION;


--
-- Name: SCHEMA bcf_auth; Type: ACL; Schema: -; Owner: bcf_auth
--

GRANT USAGE ON SCHEMA bcf_auth TO bcf_authenticator;
GRANT USAGE ON SCHEMA bcf_auth TO bcf_reg_facade;


--
-- Name: SCHEMA bcf_reg; Type: ACL; Schema: -; Owner: bcf_reg
--

GRANT USAGE ON SCHEMA bcf_reg TO bcf_reg_facade;
GRANT ALL ON SCHEMA bcf_reg TO bcf_reg_dba;


--
-- Name: SCHEMA bcf_reg_config; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA bcf_reg_config TO bcf_auth;
GRANT USAGE ON SCHEMA bcf_reg_config TO bcf_reg;
GRANT USAGE ON SCHEMA bcf_reg_config TO bcf_reg_facade;


--
-- Name: SCHEMA bcf_reg_facade; Type: ACL; Schema: -; Owner: bcf_reg_facade
--

GRANT USAGE ON SCHEMA bcf_reg_facade TO bcf_reg_viewer;
GRANT ALL ON SCHEMA bcf_reg_facade TO bcf_reg_dba;


--
-- Name: SCHEMA bcf_reg_web_facade; Type: ACL; Schema: -; Owner: bcf_reg_facade
--

GRANT USAGE ON SCHEMA bcf_reg_web_facade TO bcf_reg_viewer;


--
-- Name: SCHEMA bcf_utils; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA bcf_utils TO PUBLIC;


--
-- Name: SCHEMA hstore; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA hstore TO bcf_reg_facade;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA public TO proteax_user;


--
-- Name: SCHEMA rdkit; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA rdkit TO PUBLIC;


--
-- Name: FUNCTION assign_privs(a_user_initials text, reg_privs integer, stock_privs integer, patent_privs integer); Type: ACL; Schema: bcf_auth; Owner: bcf_auth
--

REVOKE ALL ON FUNCTION bcf_auth.assign_privs(a_user_initials text, reg_privs integer, stock_privs integer, patent_privs integer) FROM PUBLIC;


--
-- Name: FUNCTION const_priv_level_admin(); Type: ACL; Schema: bcf_auth; Owner: bcf_auth
--

REVOKE ALL ON FUNCTION bcf_auth.const_priv_level_admin() FROM PUBLIC;
GRANT ALL ON FUNCTION bcf_auth.const_priv_level_admin() TO bcf_reg_facade;


--
-- Name: FUNCTION const_priv_level_dba(); Type: ACL; Schema: bcf_auth; Owner: bcf_auth
--

REVOKE ALL ON FUNCTION bcf_auth.const_priv_level_dba() FROM PUBLIC;
GRANT ALL ON FUNCTION bcf_auth.const_priv_level_dba() TO bcf_reg_facade;


--
-- Name: FUNCTION const_priv_level_editor(); Type: ACL; Schema: bcf_auth; Owner: bcf_auth
--

REVOKE ALL ON FUNCTION bcf_auth.const_priv_level_editor() FROM PUBLIC;
GRANT ALL ON FUNCTION bcf_auth.const_priv_level_editor() TO bcf_reg_facade;


--
-- Name: FUNCTION const_priv_level_viewer(); Type: ACL; Schema: bcf_auth; Owner: bcf_auth
--

REVOKE ALL ON FUNCTION bcf_auth.const_priv_level_viewer() FROM PUBLIC;
GRANT ALL ON FUNCTION bcf_auth.const_priv_level_viewer() TO bcf_reg_facade;


--
-- Name: FUNCTION create_user(a_user_initials text); Type: ACL; Schema: bcf_auth; Owner: bcf_auth
--

REVOKE ALL ON FUNCTION bcf_auth.create_user(a_user_initials text) FROM PUBLIC;


--
-- Name: FUNCTION delete_user(a_user_initials text); Type: ACL; Schema: bcf_auth; Owner: bcf_auth
--

REVOKE ALL ON FUNCTION bcf_auth.delete_user(a_user_initials text) FROM PUBLIC;


--
-- Name: FUNCTION get_priv_levels_for_user(a_user_name text); Type: ACL; Schema: bcf_auth; Owner: bcf_auth
--

REVOKE ALL ON FUNCTION bcf_auth.get_priv_levels_for_user(a_user_name text) FROM PUBLIC;
GRANT ALL ON FUNCTION bcf_auth.get_priv_levels_for_user(a_user_name text) TO bcf_reg_facade;


--
-- Name: FUNCTION "job$refresh_user_passwords"(); Type: ACL; Schema: bcf_auth; Owner: bcf_auth
--

REVOKE ALL ON FUNCTION bcf_auth."job$refresh_user_passwords"() FROM PUBLIC;


--
-- Name: FUNCTION set_password(a_user_initials text, a_new_password text); Type: ACL; Schema: bcf_auth; Owner: bcf_auth
--

REVOKE ALL ON FUNCTION bcf_auth.set_password(a_user_initials text, a_new_password text) FROM PUBLIC;
GRANT ALL ON FUNCTION bcf_auth.set_password(a_user_initials text, a_new_password text) TO bcf_authenticator;


--
-- Name: FUNCTION sync_users(); Type: ACL; Schema: bcf_auth; Owner: bcf_auth
--

REVOKE ALL ON FUNCTION bcf_auth.sync_users() FROM PUBLIC;
GRANT ALL ON FUNCTION bcf_auth.sync_users() TO bcf_reg_facade;
GRANT ALL ON FUNCTION bcf_auth.sync_users() TO bcf_authenticator;


--
-- Name: FUNCTION user_credentials(an_external_user_name text); Type: ACL; Schema: bcf_auth; Owner: bcf_auth
--

REVOKE ALL ON FUNCTION bcf_auth.user_credentials(an_external_user_name text) FROM PUBLIC;
GRANT ALL ON FUNCTION bcf_auth.user_credentials(an_external_user_name text) TO bcf_authenticator;


--
-- Name: FUNCTION "trg$assign_compound_name"(); Type: ACL; Schema: bcf_reg; Owner: bcf_reg
--

REVOKE ALL ON FUNCTION bcf_reg."trg$assign_compound_name"() FROM PUBLIC;


--
-- Name: FUNCTION "trg$assign_parent_no_and_name"(); Type: ACL; Schema: bcf_reg; Owner: bcf_reg
--

REVOKE ALL ON FUNCTION bcf_reg."trg$assign_parent_no_and_name"() FROM PUBLIC;


--
-- Name: FUNCTION "trg$biur_salts"(); Type: ACL; Schema: bcf_reg; Owner: bcf_reg
--

REVOKE ALL ON FUNCTION bcf_reg."trg$biur_salts"() FROM PUBLIC;


--
-- Name: FUNCTION "trg$calc_compound_props"(); Type: ACL; Schema: bcf_reg; Owner: bcf_reg
--

REVOKE ALL ON FUNCTION bcf_reg."trg$calc_compound_props"() FROM PUBLIC;


--
-- Name: FUNCTION "trg$calc_parent_props_and_check_dupreason"(); Type: ACL; Schema: bcf_reg; Owner: bcf_reg
--

REVOKE ALL ON FUNCTION bcf_reg."trg$calc_parent_props_and_check_dupreason"() FROM PUBLIC;


--
-- Name: FUNCTION "trg$check_has_delete_reason"(); Type: ACL; Schema: bcf_reg; Owner: bcf_reg
--

REVOKE ALL ON FUNCTION bcf_reg."trg$check_has_delete_reason"() FROM PUBLIC;


--
-- Name: FUNCTION "trg$check_non_blank_update_reason"(); Type: ACL; Schema: bcf_reg; Owner: bcf_reg
--

REVOKE ALL ON FUNCTION bcf_reg."trg$check_non_blank_update_reason"() FROM PUBLIC;


--
-- Name: FUNCTION "trg$jn$compounds"(); Type: ACL; Schema: bcf_reg; Owner: bcf_reg
--

REVOKE ALL ON FUNCTION bcf_reg."trg$jn$compounds"() FROM PUBLIC;


--
-- Name: FUNCTION "trg$jn$parents"(); Type: ACL; Schema: bcf_reg; Owner: bcf_reg
--

REVOKE ALL ON FUNCTION bcf_reg."trg$jn$parents"() FROM PUBLIC;


--
-- Name: FUNCTION "trg$jn$salts"(); Type: ACL; Schema: bcf_reg; Owner: bcf_reg
--

REVOKE ALL ON FUNCTION bcf_reg."trg$jn$salts"() FROM PUBLIC;


--
-- Name: FUNCTION "trg$set_updated_fields"(); Type: ACL; Schema: bcf_reg; Owner: bcf_reg
--

REVOKE ALL ON FUNCTION bcf_reg."trg$set_updated_fields"() FROM PUBLIC;
GRANT ALL ON FUNCTION bcf_reg."trg$set_updated_fields"() TO bcf_reg_facade;


--
-- Name: FUNCTION "trg$update_unique_names"(); Type: ACL; Schema: bcf_reg; Owner: bcf_reg
--

REVOKE ALL ON FUNCTION bcf_reg."trg$update_unique_names"() FROM PUBLIC;
GRANT ALL ON FUNCTION bcf_reg."trg$update_unique_names"() TO bcf_reg_facade;


--
-- Name: FUNCTION create_compound_name(a_parent_no integer, a_salt_code text); Type: ACL; Schema: bcf_reg_config; Owner: bcf_reg
--

REVOKE ALL ON FUNCTION bcf_reg_config.create_compound_name(a_parent_no integer, a_salt_code text) FROM PUBLIC;


--
-- Name: FUNCTION create_parent_name(a_parent_no integer); Type: ACL; Schema: bcf_reg_config; Owner: bcf_reg
--

REVOKE ALL ON FUNCTION bcf_reg_config.create_parent_name(a_parent_no integer) FROM PUBLIC;


--
-- Name: FUNCTION display_user_name(a_user_name text); Type: ACL; Schema: bcf_reg_config; Owner: bcf_reg_facade
--

REVOKE ALL ON FUNCTION bcf_reg_config.display_user_name(a_user_name text) FROM PUBLIC;
GRANT ALL ON FUNCTION bcf_reg_config.display_user_name(a_user_name text) TO bcf_auth;


--
-- Name: FUNCTION initials_to_account_name(an_initials text); Type: ACL; Schema: bcf_reg_config; Owner: bcf_reg_facade
--

REVOKE ALL ON FUNCTION bcf_reg_config.initials_to_account_name(an_initials text) FROM PUBLIC;
GRANT ALL ON FUNCTION bcf_reg_config.initials_to_account_name(an_initials text) TO bcf_auth;


--
-- Name: FUNCTION read_property(a_table_name text, a_property_name text, default_value text, raise_error_on_notexist boolean); Type: ACL; Schema: bcf_reg_config; Owner: postgres
--

REVOKE ALL ON FUNCTION bcf_reg_config.read_property(a_table_name text, a_property_name text, default_value text, raise_error_on_notexist boolean) FROM PUBLIC;
GRANT ALL ON FUNCTION bcf_reg_config.read_property(a_table_name text, a_property_name text, default_value text, raise_error_on_notexist boolean) TO bcf_auth;
GRANT ALL ON FUNCTION bcf_reg_config.read_property(a_table_name text, a_property_name text, default_value text, raise_error_on_notexist boolean) TO bcf_reg;
GRANT ALL ON FUNCTION bcf_reg_config.read_property(a_table_name text, a_property_name text, default_value text, raise_error_on_notexist boolean) TO bcf_reg_facade;


--
-- Name: FUNCTION active_sessions(); Type: ACL; Schema: bcf_reg_facade; Owner: postgres
--

REVOKE ALL ON FUNCTION bcf_reg_facade.active_sessions() FROM PUBLIC;
GRANT ALL ON FUNCTION bcf_reg_facade.active_sessions() TO bcf_reg_admin;
GRANT ALL ON FUNCTION bcf_reg_facade.active_sessions() TO bcf_reg_facade;


--
-- Name: FUNCTION append_count_line(prev_lines text, a_level integer, a_count integer, an_item_name text, an_item_plural_suffix text, an_item_list text); Type: ACL; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

REVOKE ALL ON FUNCTION bcf_reg_facade.append_count_line(prev_lines text, a_level integer, a_count integer, an_item_name text, an_item_plural_suffix text, an_item_list text) FROM PUBLIC;


--
-- Name: FUNCTION coltype_to_fieldtype(col_data_type text, col_udt_name text, unknown_prefix text); Type: ACL; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

REVOKE ALL ON FUNCTION bcf_reg_facade.coltype_to_fieldtype(col_data_type text, col_udt_name text, unknown_prefix text) FROM PUBLIC;
GRANT ALL ON FUNCTION bcf_reg_facade.coltype_to_fieldtype(col_data_type text, col_udt_name text, unknown_prefix text) TO bcf_reg_viewer;


--
-- Name: FUNCTION create_search_query(a_root_name text); Type: ACL; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

REVOKE ALL ON FUNCTION bcf_reg_facade.create_search_query(a_root_name text) FROM PUBLIC;


--
-- Name: FUNCTION create_sql_filter_for_field(view_name text, field_name text, field_type text, _operator text, criteria_fieldname text, item_no integer); Type: ACL; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

REVOKE ALL ON FUNCTION bcf_reg_facade.create_sql_filter_for_field(view_name text, field_name text, field_type text, _operator text, criteria_fieldname text, item_no integer) FROM PUBLIC;


--
-- Name: FUNCTION criteria_to_string(a_field_type text, an_operator text, an_options text, a_text text, a_number double precision, a_date1 timestamp with time zone, a_date2 timestamp with time zone); Type: ACL; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

REVOKE ALL ON FUNCTION bcf_reg_facade.criteria_to_string(a_field_type text, an_operator text, an_options text, a_text text, a_number double precision, a_date1 timestamp with time zone, a_date2 timestamp with time zone) FROM PUBLIC;
GRANT ALL ON FUNCTION bcf_reg_facade.criteria_to_string(a_field_type text, an_operator text, an_options text, a_text text, a_number double precision, a_date1 timestamp with time zone, a_date2 timestamp with time zone) TO bcf_reg_viewer;


--
-- Name: FUNCTION display_user_name(a_user_name text); Type: ACL; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

REVOKE ALL ON FUNCTION bcf_reg_facade.display_user_name(a_user_name text) FROM PUBLIC;
GRANT ALL ON FUNCTION bcf_reg_facade.display_user_name(a_user_name text) TO bcf_reg_viewer;


--
-- Name: FUNCTION execute_search(a_root_name text, within_current_list boolean); Type: ACL; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

REVOKE ALL ON FUNCTION bcf_reg_facade.execute_search(a_root_name text, within_current_list boolean) FROM PUBLIC;
GRANT ALL ON FUNCTION bcf_reg_facade.execute_search(a_root_name text, within_current_list boolean) TO bcf_reg_viewer;


--
-- Name: FUNCTION fieldtype_to_criteriafield(field_type text); Type: ACL; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

REVOKE ALL ON FUNCTION bcf_reg_facade.fieldtype_to_criteriafield(field_type text) FROM PUBLIC;


--
-- Name: FUNCTION full_fieldname_path(a_fieldname text, a_parent_id integer); Type: ACL; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

REVOKE ALL ON FUNCTION bcf_reg_facade.full_fieldname_path(a_fieldname text, a_parent_id integer) FROM PUBLIC;
GRANT ALL ON FUNCTION bcf_reg_facade.full_fieldname_path(a_fieldname text, a_parent_id integer) TO bcf_reg_viewer;


--
-- Name: FUNCTION get_compound_duplicates(a_structure_key text, a_row_no integer, a_salt_name text, a_salt_ratio integer, a_structure_ratio integer); Type: ACL; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

REVOKE ALL ON FUNCTION bcf_reg_facade.get_compound_duplicates(a_structure_key text, a_row_no integer, a_salt_name text, a_salt_ratio integer, a_structure_ratio integer) FROM PUBLIC;


--
-- Name: FUNCTION get_parent_duplicates(a_structure_key text, a_row_no integer); Type: ACL; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

REVOKE ALL ON FUNCTION bcf_reg_facade.get_parent_duplicates(a_structure_key text, a_row_no integer) FROM PUBLIC;


--
-- Name: FUNCTION get_priv_level(); Type: ACL; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

REVOKE ALL ON FUNCTION bcf_reg_facade.get_priv_level() FROM PUBLIC;
GRANT ALL ON FUNCTION bcf_reg_facade.get_priv_level() TO bcf_reg_viewer;


--
-- Name: FUNCTION get_query_fields(a_root_name text); Type: ACL; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

REVOKE ALL ON FUNCTION bcf_reg_facade.get_query_fields(a_root_name text) FROM PUBLIC;
GRANT ALL ON FUNCTION bcf_reg_facade.get_query_fields(a_root_name text) TO bcf_reg_viewer;


--
-- Name: FUNCTION get_query_roots(); Type: ACL; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

REVOKE ALL ON FUNCTION bcf_reg_facade.get_query_roots() FROM PUBLIC;
GRANT ALL ON FUNCTION bcf_reg_facade.get_query_roots() TO bcf_reg_viewer;


--
-- Name: FUNCTION guess_query_root(a_key_value text); Type: ACL; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

REVOKE ALL ON FUNCTION bcf_reg_facade.guess_query_root(a_key_value text) FROM PUBLIC;
GRANT ALL ON FUNCTION bcf_reg_facade.guess_query_root(a_key_value text) TO bcf_reg_viewer;


--
-- Name: FUNCTION init_current_list(); Type: ACL; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

REVOKE ALL ON FUNCTION bcf_reg_facade.init_current_list() FROM PUBLIC;
GRANT ALL ON FUNCTION bcf_reg_facade.init_current_list() TO bcf_reg_viewer;


--
-- Name: FUNCTION init_currentlist_and_exec_search(a_root_name text); Type: ACL; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

REVOKE ALL ON FUNCTION bcf_reg_facade.init_currentlist_and_exec_search(a_root_name text) FROM PUBLIC;
GRANT ALL ON FUNCTION bcf_reg_facade.init_currentlist_and_exec_search(a_root_name text) TO bcf_reg_viewer;


--
-- Name: FUNCTION init_query_fields_upload(); Type: ACL; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

REVOKE ALL ON FUNCTION bcf_reg_facade.init_query_fields_upload() FROM PUBLIC;
GRANT ALL ON FUNCTION bcf_reg_facade.init_query_fields_upload() TO bcf_reg_viewer;


--
-- Name: FUNCTION journal_compound_diff(a_compound_name text); Type: ACL; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

REVOKE ALL ON FUNCTION bcf_reg_facade.journal_compound_diff(a_compound_name text) FROM PUBLIC;
GRANT ALL ON FUNCTION bcf_reg_facade.journal_compound_diff(a_compound_name text) TO bcf_reg_viewer;


--
-- Name: FUNCTION journal_table_diff(schema_name text, table_name text, key_field_value text); Type: ACL; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

REVOKE ALL ON FUNCTION bcf_reg_facade.journal_table_diff(schema_name text, table_name text, key_field_value text) FROM PUBLIC;


--
-- Name: FUNCTION pluralized(a_count integer, an_item_name text, an_item_plural_suffix text); Type: ACL; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

REVOKE ALL ON FUNCTION bcf_reg_facade.pluralized(a_count integer, an_item_name text, an_item_plural_suffix text) FROM PUBLIC;


--
-- Name: FUNCTION register_delete_reason(an_id integer, a_reason text); Type: ACL; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

REVOKE ALL ON FUNCTION bcf_reg_facade.register_delete_reason(an_id integer, a_reason text) FROM PUBLIC;
GRANT ALL ON FUNCTION bcf_reg_facade.register_delete_reason(an_id integer, a_reason text) TO bcf_reg_editor;


--
-- Name: FUNCTION save_search(qry text, qry_start_time timestamp with time zone, qry_done_time timestamp with time zone, within_current_list boolean); Type: ACL; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

REVOKE ALL ON FUNCTION bcf_reg_facade.save_search(qry text, qry_start_time timestamp with time zone, qry_done_time timestamp with time zone, within_current_list boolean) FROM PUBLIC;


--
-- Name: FUNCTION "trg$delete_query_runs"(); Type: ACL; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

REVOKE ALL ON FUNCTION bcf_reg_facade."trg$delete_query_runs"() FROM PUBLIC;


--
-- Name: FUNCTION "trg$update_query_runs"(); Type: ACL; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

REVOKE ALL ON FUNCTION bcf_reg_facade."trg$update_query_runs"() FROM PUBLIC;


--
-- Name: FUNCTION create_delete_reason(); Type: ACL; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

REVOKE ALL ON FUNCTION bcf_reg_web_facade.create_delete_reason() FROM PUBLIC;


--
-- Name: FUNCTION create_update_reason(); Type: ACL; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

REVOKE ALL ON FUNCTION bcf_reg_web_facade.create_update_reason() FROM PUBLIC;


--
-- Name: FUNCTION delete_compound(a_compound_name text); Type: ACL; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

REVOKE ALL ON FUNCTION bcf_reg_web_facade.delete_compound(a_compound_name text) FROM PUBLIC;
GRANT ALL ON FUNCTION bcf_reg_web_facade.delete_compound(a_compound_name text) TO bcf_reg_admin;


--
-- Name: FUNCTION delete_compound_impact(a_compound_name text); Type: ACL; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

REVOKE ALL ON FUNCTION bcf_reg_web_facade.delete_compound_impact(a_compound_name text) FROM PUBLIC;
GRANT ALL ON FUNCTION bcf_reg_web_facade.delete_compound_impact(a_compound_name text) TO bcf_reg_admin;


--
-- Name: FUNCTION describe_table(a_table_name text); Type: ACL; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

REVOKE ALL ON FUNCTION bcf_reg_web_facade.describe_table(a_table_name text) FROM PUBLIC;
GRANT ALL ON FUNCTION bcf_reg_web_facade.describe_table(a_table_name text) TO bcf_reg_viewer;


--
-- Name: FUNCTION find_or_create_compound_salt(a_parent_id integer, a_short_salt_name text, a_structure_ratio integer, a_salt_ratio integer); Type: ACL; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

REVOKE ALL ON FUNCTION bcf_reg_web_facade.find_or_create_compound_salt(a_parent_id integer, a_short_salt_name text, a_structure_ratio integer, a_salt_ratio integer) FROM PUBLIC;


--
-- Name: FUNCTION get_structure_duplicates(a_molfile text, a_compound_id_to_exclude integer); Type: ACL; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

REVOKE ALL ON FUNCTION bcf_reg_web_facade.get_structure_duplicates(a_molfile text, a_compound_id_to_exclude integer) FROM PUBLIC;
GRANT ALL ON FUNCTION bcf_reg_web_facade.get_structure_duplicates(a_molfile text, a_compound_id_to_exclude integer) TO bcf_reg_editor;


--
-- Name: FUNCTION lookup_salt(a_short_salt_name text); Type: ACL; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

REVOKE ALL ON FUNCTION bcf_reg_web_facade.lookup_salt(a_short_salt_name text) FROM PUBLIC;


--
-- Name: FUNCTION molfile_fragment_count(a_molfile text); Type: ACL; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

REVOKE ALL ON FUNCTION bcf_reg_web_facade.molfile_fragment_count(a_molfile text) FROM PUBLIC;
GRANT ALL ON FUNCTION bcf_reg_web_facade.molfile_fragment_count(a_molfile text) TO bcf_reg_viewer;


--
-- Name: FUNCTION molfile_to_svg(a_molfile text, a_width integer, a_height integer); Type: ACL; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

REVOKE ALL ON FUNCTION bcf_reg_web_facade.molfile_to_svg(a_molfile text, a_width integer, a_height integer) FROM PUBLIC;
GRANT ALL ON FUNCTION bcf_reg_web_facade.molfile_to_svg(a_molfile text, a_width integer, a_height integer) TO bcf_reg_viewer;


--
-- Name: FUNCTION refresh_user_name_cache(); Type: ACL; Schema: bcf_reg_web_facade; Owner: system_admin
--

REVOKE ALL ON FUNCTION bcf_reg_web_facade.refresh_user_name_cache() FROM PUBLIC;
GRANT ALL ON FUNCTION bcf_reg_web_facade.refresh_user_name_cache() TO bcf_reg_admin;


--
-- Name: FUNCTION "trg$delete_v$salts_edit"(); Type: ACL; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

REVOKE ALL ON FUNCTION bcf_reg_web_facade."trg$delete_v$salts_edit"() FROM PUBLIC;


--
-- Name: FUNCTION "trg$insert_v$compounds_edit"(); Type: ACL; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

REVOKE ALL ON FUNCTION bcf_reg_web_facade."trg$insert_v$compounds_edit"() FROM PUBLIC;


--
-- Name: FUNCTION "trg$update_v$compounds_edit"(); Type: ACL; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

REVOKE ALL ON FUNCTION bcf_reg_web_facade."trg$update_v$compounds_edit"() FROM PUBLIC;


--
-- Name: FUNCTION "trg$update_v$salts_edit"(); Type: ACL; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

REVOKE ALL ON FUNCTION bcf_reg_web_facade."trg$update_v$salts_edit"() FROM PUBLIC;


--
-- Name: TABLE user_mappings; Type: ACL; Schema: bcf_auth; Owner: bcf_auth
--

GRANT SELECT ON TABLE bcf_auth.user_mappings TO bcf_authenticator;


--
-- Name: TABLE users_admin; Type: ACL; Schema: bcf_auth; Owner: bcf_auth
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE bcf_auth.users_admin TO bcf_reg_facade;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE bcf_auth.users_admin TO bcf_authenticator;


--
-- Name: TABLE users_editor; Type: ACL; Schema: bcf_auth; Owner: bcf_auth
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE bcf_auth.users_editor TO bcf_reg_facade;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE bcf_auth.users_editor TO bcf_authenticator;


--
-- Name: TABLE users_viewer; Type: ACL; Schema: bcf_auth; Owner: bcf_auth
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE bcf_auth.users_viewer TO bcf_reg_facade;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE bcf_auth.users_viewer TO bcf_authenticator;


--
-- Name: TABLE "v$email_addresses"; Type: ACL; Schema: bcf_auth; Owner: bcf_auth
--

GRANT SELECT ON TABLE bcf_auth."v$email_addresses" TO bcf_reg_facade;


--
-- Name: SEQUENCE id_sequence; Type: ACL; Schema: bcf_reg; Owner: bcf_reg
--

GRANT USAGE ON SEQUENCE bcf_reg.id_sequence TO bcf_reg_facade;
GRANT USAGE ON SEQUENCE bcf_reg.id_sequence TO bcf_reg_editor;


--
-- Name: TABLE compounds; Type: ACL; Schema: bcf_reg; Owner: bcf_reg
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE bcf_reg.compounds TO bcf_reg_facade;


--
-- Name: TABLE "compounds$calc_props"; Type: ACL; Schema: bcf_reg; Owner: bcf_reg
--

GRANT SELECT,UPDATE ON TABLE bcf_reg."compounds$calc_props" TO bcf_reg_facade;


--
-- Name: TABLE db_revision; Type: ACL; Schema: bcf_reg; Owner: bcf_reg
--

GRANT SELECT ON TABLE bcf_reg.db_revision TO bcf_reg_facade;


--
-- Name: TABLE delete_reasons; Type: ACL; Schema: bcf_reg; Owner: bcf_reg
--

GRANT INSERT ON TABLE bcf_reg.delete_reasons TO bcf_reg_facade;


--
-- Name: TABLE "jn$compounds"; Type: ACL; Schema: bcf_reg; Owner: bcf_reg
--

GRANT SELECT ON TABLE bcf_reg."jn$compounds" TO bcf_reg_facade;


--
-- Name: TABLE "jn$parents"; Type: ACL; Schema: bcf_reg; Owner: bcf_reg
--

GRANT SELECT ON TABLE bcf_reg."jn$parents" TO bcf_reg_facade;


--
-- Name: TABLE parents; Type: ACL; Schema: bcf_reg; Owner: bcf_reg
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE bcf_reg.parents TO bcf_reg_facade;


--
-- Name: TABLE "parents$calc_props"; Type: ACL; Schema: bcf_reg; Owner: bcf_reg
--

GRANT SELECT ON TABLE bcf_reg."parents$calc_props" TO bcf_reg_facade;


--
-- Name: TABLE salts; Type: ACL; Schema: bcf_reg; Owner: bcf_reg
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE bcf_reg.salts TO bcf_reg_facade;


--
-- Name: TABLE "unique$names"; Type: ACL; Schema: bcf_reg; Owner: bcf_reg
--

GRANT SELECT ON TABLE bcf_reg."unique$names" TO bcf_reg_facade WITH GRANT OPTION;


--
-- Name: TABLE db_config; Type: ACL; Schema: bcf_reg_config; Owner: bcf_auth
--

GRANT SELECT ON TABLE bcf_reg_config.db_config TO bcf_reg_facade;


--
-- Name: TABLE "v$db_revision"; Type: ACL; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

GRANT SELECT ON TABLE bcf_reg_facade."v$db_revision" TO bcf_reg_viewer;


--
-- Name: TABLE "v$export_views"; Type: ACL; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

GRANT SELECT ON TABLE bcf_reg_facade."v$export_views" TO bcf_reg_viewer;


--
-- Name: TABLE "v$latest_query_run"; Type: ACL; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

GRANT SELECT ON TABLE bcf_reg_facade."v$latest_query_run" TO bcf_reg_viewer;


--
-- Name: TABLE "v$qry$cmp_compounds"; Type: ACL; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

GRANT SELECT ON TABLE bcf_reg_facade."v$qry$cmp_compounds" TO bcf_reg_viewer;


--
-- Name: TABLE "v$query_run_details"; Type: ACL; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

GRANT SELECT ON TABLE bcf_reg_facade."v$query_run_details" TO bcf_reg_viewer;


--
-- Name: TABLE "v$query_run_fields"; Type: ACL; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

GRANT SELECT ON TABLE bcf_reg_facade."v$query_run_fields" TO bcf_reg_viewer;


--
-- Name: TABLE "v$query_runs"; Type: ACL; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

GRANT SELECT,DELETE ON TABLE bcf_reg_facade."v$query_runs" TO bcf_reg_viewer;


--
-- Name: COLUMN "v$query_runs"."Name"; Type: ACL; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

GRANT UPDATE("Name") ON TABLE bcf_reg_facade."v$query_runs" TO bcf_reg_viewer;


--
-- Name: TABLE "v$users_and_priv_levels"; Type: ACL; Schema: bcf_reg_facade; Owner: bcf_reg_facade
--

GRANT SELECT ON TABLE bcf_reg_facade."v$users_and_priv_levels" TO bcf_reg_admin;


--
-- Name: TABLE cached_user_names; Type: ACL; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

GRANT SELECT ON TABLE bcf_reg_web_facade.cached_user_names TO bcf_reg_viewer;


--
-- Name: TABLE "v$cmp_compounds"; Type: ACL; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

GRANT SELECT ON TABLE bcf_reg_web_facade."v$cmp_compounds" TO bcf_reg_viewer;


--
-- Name: TABLE "v$cmp_overview"; Type: ACL; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

GRANT SELECT ON TABLE bcf_reg_web_facade."v$cmp_overview" TO bcf_reg_viewer;


--
-- Name: TABLE "v$compounds_edit"; Type: ACL; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

GRANT SELECT ON TABLE bcf_reg_web_facade."v$compounds_edit" TO bcf_reg_viewer;


--
-- Name: COLUMN "v$compounds_edit".name; Type: ACL; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

GRANT INSERT(name) ON TABLE bcf_reg_web_facade."v$compounds_edit" TO bcf_reg_admin;
GRANT INSERT(name) ON TABLE bcf_reg_web_facade."v$compounds_edit" TO bcf_reg_editor;


--
-- Name: COLUMN "v$compounds_edit".molfile; Type: ACL; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

GRANT INSERT(molfile),UPDATE(molfile) ON TABLE bcf_reg_web_facade."v$compounds_edit" TO bcf_reg_admin;
GRANT INSERT(molfile) ON TABLE bcf_reg_web_facade."v$compounds_edit" TO bcf_reg_editor;


--
-- Name: COLUMN "v$compounds_edit".comments; Type: ACL; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

GRANT INSERT(comments),UPDATE(comments) ON TABLE bcf_reg_web_facade."v$compounds_edit" TO bcf_reg_admin;
GRANT INSERT(comments),UPDATE(comments) ON TABLE bcf_reg_web_facade."v$compounds_edit" TO bcf_reg_editor;


--
-- Name: COLUMN "v$compounds_edit".duplicate_reason; Type: ACL; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

GRANT INSERT(duplicate_reason),UPDATE(duplicate_reason) ON TABLE bcf_reg_web_facade."v$compounds_edit" TO bcf_reg_admin;


--
-- Name: TABLE "v$lookup_salts"; Type: ACL; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

GRANT SELECT ON TABLE bcf_reg_web_facade."v$lookup_salts" TO bcf_reg_viewer;


--
-- Name: TABLE "v$salts_edit"; Type: ACL; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

GRANT SELECT,DELETE ON TABLE bcf_reg_web_facade."v$salts_edit" TO bcf_reg_admin;


--
-- Name: COLUMN "v$salts_edit".name; Type: ACL; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

GRANT INSERT(name),UPDATE(name) ON TABLE bcf_reg_web_facade."v$salts_edit" TO bcf_reg_admin;


--
-- Name: COLUMN "v$salts_edit".short_name; Type: ACL; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

GRANT INSERT(short_name),UPDATE(short_name) ON TABLE bcf_reg_web_facade."v$salts_edit" TO bcf_reg_admin;


--
-- Name: COLUMN "v$salts_edit".sum_formula; Type: ACL; Schema: bcf_reg_web_facade; Owner: bcf_reg_facade
--

GRANT INSERT(sum_formula),UPDATE(sum_formula) ON TABLE bcf_reg_web_facade."v$salts_edit" TO bcf_reg_admin;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: -; Owner: bcf_auth
--

ALTER DEFAULT PRIVILEGES FOR ROLE bcf_auth REVOKE ALL ON FUNCTIONS  FROM PUBLIC;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: -; Owner: bcf_reg
--

ALTER DEFAULT PRIVILEGES FOR ROLE bcf_reg REVOKE ALL ON FUNCTIONS  FROM PUBLIC;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: -; Owner: bcf_reg_facade
--

ALTER DEFAULT PRIVILEGES FOR ROLE bcf_reg_facade REVOKE ALL ON FUNCTIONS  FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

