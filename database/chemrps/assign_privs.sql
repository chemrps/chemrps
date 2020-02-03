-- FUNCTION: bcf_auth.assign_privs(text, integer, integer, integer)

-- DROP FUNCTION bcf_auth.assign_privs(text, integer, integer, integer);

CREATE OR REPLACE FUNCTION bcf_auth.assign_privs(
	a_user_initials text,
	reg_privs integer,
	stock_privs integer,
	patent_privs integer)
    RETURNS void
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    SET search_path='"bcf_auth, pg_temp"'
AS $BODY$


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


$BODY$;

ALTER FUNCTION bcf_auth.assign_privs(text, integer, integer, integer)
    OWNER TO bcf_auth;

GRANT EXECUTE ON FUNCTION bcf_auth.assign_privs(text, integer, integer, integer) TO bcf_auth;

REVOKE ALL ON FUNCTION bcf_auth.assign_privs(text, integer, integer, integer) FROM PUBLIC;

COMMENT ON FUNCTION bcf_auth.assign_privs(text, integer, integer, integer)
    IS 'Assigns BCFReg privileges to the user with the specified initials. Privileges are passed as integer codes; 0 = no privileges; 1 = lowest privilege; 2 = second-lowest privilege, and so on.';
