/**
  Run this as "system_admin" or another superuser.
**/

set role bcf_reg;

-- Add molecule fingerprint column to calculated properties. I can't convince Postgres to
-- use a functional index for this purpose.
-- drop index parent_molecule_fp_data_idx;

alter table bcf_reg.parents$calc_props add column molecule_fp rdkit.bfp;

update bcf_reg.parents$calc_props
   set molecule_fp = rdkit.morganbv_fp(molecule);


-- Update parent trigger function so the molecule fingerprint is maintained.
CREATE OR REPLACE FUNCTION bcf_reg."trg$calc_parent_props_and_check_dupreason"()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'bcf_reg, pg_temp'
AS $function$
declare
  the_molecule rdkit.mol;
  the_molecule_fp rdkit.bfp;
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
  the_molecule_fp := rdkit.morganbv_fp(the_molecule);

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
      (parent_id, molecule, molecule_fp,
       sum_formula, mw_avg, mw_mono,
       inchi_key, svg_rendering)
    values
      (NEW.id, the_molecule, the_molecule_fp,
       the_sum_formula, the_avg_mw, the_mono_mw,
       the_inchi_key, the_svg_rendering);

  elsif TG_OP = 'UPDATE' then
    update bcf_reg.parents$calc_props
       set molecule = the_molecule,
           molecule_fp = the_molecule_fp,
           sum_formula = the_sum_formula,
           mw_avg = the_avg_mw,
           mw_mono = the_mono_mw,
           inchi_key = the_inchi_key,
           svg_rendering = the_svg_rendering
     where parent_id = OLD.id;
  end if;

  return NEW;
end;
$function$
;

set role bcf_reg_facade;

CREATE FUNCTION bcf_reg_facade.current_list_by_similarity(a_query_molfile text, a_limit_count integer)
 RETURNS TABLE(id text, similarity_score double precision)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'bcf_reg_facade', 'pg_temp'
AS $function$
declare
  the_query_fp rdkit.bfp;
begin
  the_query_fp := rdkit.morganbv_fp(rdkit.mol_from_ctab(a_query_molfile::cstring));

  return query
  select
      curlst.id
    , rdkit.tanimoto_sml( par_props.molecule_fp, the_query_fp ) as similarity_score
    from pg_temp.tmp$current_list curlst
    join bcf_reg.parents par on par.name = curlst.id
    join bcf_reg.parents$calc_props par_props on par_props.parent_id = par.id
   order by 2 desc
   limit a_limit_count
  ;
end
$function$
;
GRANT EXECUTE ON FUNCTION bcf_reg_facade.current_list_by_similarity(text, integer) TO bcf_reg_facade;
GRANT EXECUTE ON FUNCTION bcf_reg_facade.current_list_by_similarity(text, integer) TO bcf_reg_viewer;

COMMENT ON FUNCTION bcf_reg_facade.current_list_by_similarity(text, integer) IS
  'Retrieves the top N compounds from the current list, that are most similar to the input query.';

-- EOF
