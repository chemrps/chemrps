set role bcf_reg_facade;

CREATE OR REPLACE FUNCTION bcf_reg_facade.create_sql_filter_for_field(view_name text, field_name text, field_type text, _operator text, criteria_fieldname text, item_no integer)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
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
      sql_filter := sql_filter
        || '(select upper(' || criteria_fieldname || ') from pg_temp.tmp$query_fields_uploaded'
        || '  where item_no = ' || item_no || ') ';
      if _operator = 'contains' or _operator = 'contains not' then
        sql_filter := sql_filter || '|| ''%'' ';
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
$function$
;
GRANT EXECUTE ON FUNCTION bcf_reg_facade.create_sql_filter_for_field(view_name text, field_name text, field_type text, _operator text, criteria_fieldname text, item_no integer) TO bcf_reg_facade;

DROP VIEW bcf_reg_facade.v$query_run_details;
DROP FUNCTION bcf_reg_facade.criteria_to_string(a_field_type text, an_operator text, a_text text, a_number double precision, a_date1 timestamp with time zone, a_date2 timestamp with time zone);

CREATE FUNCTION bcf_reg_facade.criteria_to_string(a_field_type text, an_operator text, an_options text, a_text text, a_number double precision, a_date1 timestamp with time zone, a_date2 timestamp with time zone)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
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
$function$
;
GRANT EXECUTE ON FUNCTION bcf_reg_facade.criteria_to_string(a_field_type text, an_operator text, an_options text, a_text text, a_number double precision, a_date1 timestamp with time zone, a_date2 timestamp with time zone) TO bcf_reg_facade;
GRANT EXECUTE ON FUNCTION bcf_reg_facade.criteria_to_string(a_field_type text, an_operator text, an_options text, a_text text, a_number double precision, a_date1 timestamp with time zone, a_date2 timestamp with time zone) TO bcf_reg_viewer;

-- Re-create view dependent on function above.
CREATE VIEW bcf_reg_facade."v$query_run_details" AS 
 SELECT qrf.query_run_id,
    qrf.item_no AS "No",
    bcf_reg_facade.full_fieldname_path(qrf.field_name, qt.id) AS "Field name",
    bcf_reg_facade.criteria_to_string(bcf_reg_facade.coltype_to_fieldtype(cols.data_type::text, cols.udt_name::text), qrf.operator, qrf.options, qrf.criteria_text, qrf.criteria_number, qrf.criteria_date1, qrf.criteria_date2) AS "Criteria"
   FROM bcf_reg_facade.query_run_fields qrf
     JOIN bcf_reg_facade.query_trees qt ON qt.id = qrf.query_item_id
     JOIN bcf_reg_facade.query_tree_roots qtr ON qtr.id = qt.query_tree_root_id
     JOIN information_schema.columns cols ON cols.table_name::text = qt.query_view AND cols.column_name::text = qrf.field_name AND cols.table_schema::text = 'bcf_reg_facade'::text
  WHERE (EXISTS ( SELECT query_runs.id
           FROM bcf_reg_facade.query_runs
          WHERE query_runs.id = qrf.query_run_id AND query_runs.run_by = "session_user"()::text))
  ORDER BY qrf.item_no;

GRANT SELECT ON TABLE bcf_reg_facade."v$query_run_details" TO bcf_reg_viewer;

CREATE OR REPLACE FUNCTION bcf_reg_facade.execute_search(a_root_name text, within_current_list boolean)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'bcf_reg_facade', 'pg_temp'
AS $function$
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
$function$
;
GRANT EXECUTE ON FUNCTION bcf_reg_facade.execute_search(a_root_name text, within_current_list boolean) TO bcf_reg_facade;
GRANT EXECUTE ON FUNCTION bcf_reg_facade.execute_search(a_root_name text, within_current_list boolean) TO bcf_reg_viewer;

-- EOF
