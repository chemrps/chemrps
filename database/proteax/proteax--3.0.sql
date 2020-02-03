-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION proteax WITH SCHEMA <chosen schema>;" to load this file. \quit

-- Installs the Proteax cartridge in PostgreSQL. Run this script as the 'postgres' superuser.

do
$body$
begin
  if not exists (select * from pg_catalog.pg_roles where rolname = 'proteax_user') then
    -- Roles are not tracked by the extension installer mechanism so the role will not be
    -- dropped automatically along with the extension. Which is a good thing, since you may
    -- have granted the role to other roles and don't want that configuration to be lost if
    -- if you drop the extension and re-create it.
    create role proteax_user;
    -- When running in the context of CREATE EXTENSION all output is apparently suppressed :-/.
    -- Anyway, we have at least tried to tell the end user that a role was implicitly created.
    raise notice 'PROTEAX EXTENSION: Created role "proteax_user"';
  end if;
end
$body$;

grant usage on schema @extschema@ to proteax_user;

create function version() returns text as 'MODULE_PATHNAME', 'version' language C strict;
comment on function @extschema@.version() is 'Get version string of loaded Proteax library. The full version string is a multiple-line text. Main version ID is found in the first line.';
grant execute on function @extschema@.version() to proteax_user;
create function latest_error() returns text as 'MODULE_PATHNAME', 'latest_error' language C strict;
comment on function @extschema@.latest_error() is 'Get latest Proteax error message after a function returns NULL (when you set the optional parameter NOE = true).';
grant execute on function @extschema@.latest_error() to proteax_user;
create function format(text, noe boolean default false) returns text as 'MODULE_PATHNAME' language C strict;
comment on function @extschema@.format(text, boolean) is 'The file format of the supplied protein entry. If the input is not recognized an error is returned.';
grant execute on function @extschema@.format(text, boolean) to proteax_user;
create function id(text, noe boolean default false) returns text as 'MODULE_PATHNAME' language C strict;
comment on function @extschema@.id(text, boolean) is 'The ID, if any defined, of the supplied protein entry.';
grant execute on function @extschema@.id(text, boolean) to proteax_user;
create function name(text, noe boolean default false) returns text as 'MODULE_PATHNAME' language C strict;
comment on function @extschema@.name(text, boolean) is 'The name, if any defined, of the supplied protein entry.';
grant execute on function @extschema@.name(text, boolean) to proteax_user;
create function full_sequence(text, noe boolean default false) returns text as 'MODULE_PATHNAME' language C strict;
comment on function @extschema@.full_sequence(text, boolean) is 'The full plain sequence of the supplied protein entry, including non-expressed sequence parts.';
grant execute on function @extschema@.full_sequence(text, boolean) to proteax_user;
create function modifications(text, noe boolean default false) returns text as 'MODULE_PATHNAME' language C strict;
comment on function @extschema@.modifications(text, boolean) is 'Lists all modifications in supplied protein entry by name and locant.';
grant execute on function @extschema@.modifications(text, boolean) to proteax_user;
create function inline_mods(text, noe boolean default false) returns text as 'MODULE_PATHNAME' language C strict;
comment on function @extschema@.inline_mods(text, boolean) is 'Lists all inline modifications in supplied protein entry.';
grant execute on function @extschema@.inline_mods(text, boolean) to proteax_user;
create function inline_mods(text, text, noe boolean default false) returns text as 'MODULE_PATHNAME', 'inline_mods2' language C strict;
comment on function @extschema@.inline_mods(text, text, boolean) is 'Lists all inline modifications in supplied protein entry.';
grant execute on function @extschema@.inline_mods(text, text, boolean) to proteax_user;
create function sequence(text, noe boolean default false) returns text as 'MODULE_PATHNAME' language C strict;
comment on function @extschema@.sequence(text, boolean) is 'The expressed chains of the supplied protein entry. Chains are separated by periods.';
grant execute on function @extschema@.sequence(text, boolean) to proteax_user;
create function formula(text, noe boolean default false) returns text as 'MODULE_PATHNAME' language C strict;
comment on function @extschema@.formula(text, boolean) is 'The sum formula of the chemical structure represented by the supplied protein entry or molfile.';
grant execute on function @extschema@.formula(text, boolean) to proteax_user;
create function as_pln(text, noe boolean default false) returns text as 'MODULE_PATHNAME' language C strict;
comment on function @extschema@.as_pln(text, boolean) is 'Protein entry converted to PLN (Protein Line Notation) format.';
grant execute on function @extschema@.as_pln(text, boolean) to proteax_user;
create function as_pln(text, text, noe boolean default false) returns text as 'MODULE_PATHNAME', 'as_pln2' language C strict;
comment on function @extschema@.as_pln(text, text, boolean) is 'Protein entry converted to PLN (Protein Line Notation) format.';
grant execute on function @extschema@.as_pln(text, text, boolean) to proteax_user;
create function as_fasta(text, noe boolean default false) returns text as 'MODULE_PATHNAME' language C strict;
comment on function @extschema@.as_fasta(text, boolean) is 'Protein entry converted to FASTA format. Note that this strips all chemical annotations.';
grant execute on function @extschema@.as_fasta(text, boolean) to proteax_user;
create function as_uniprot(text, noe boolean default false) returns text as 'MODULE_PATHNAME' language C strict;
comment on function @extschema@.as_uniprot(text, boolean) is 'Protein entry converted to UniProt format.';
grant execute on function @extschema@.as_uniprot(text, boolean) to proteax_user;
create function as_uniprot(text, text, noe boolean default false) returns text as 'MODULE_PATHNAME', 'as_uniprot2' language C strict;
comment on function @extschema@.as_uniprot(text, text, boolean) is 'Protein entry converted to UniProt format.';
grant execute on function @extschema@.as_uniprot(text, text, boolean) to proteax_user;
create function as_gpmaw(text, noe boolean default false) returns text as 'MODULE_PATHNAME' language C strict;
comment on function @extschema@.as_gpmaw(text, boolean) is 'Protein entry converted to GPMAW format.';
grant execute on function @extschema@.as_gpmaw(text, boolean) to proteax_user;
create function as_gpmaw(text, text, noe boolean default false) returns text as 'MODULE_PATHNAME', 'as_gpmaw2' language C strict;
comment on function @extschema@.as_gpmaw(text, text, boolean) is 'Protein entry converted to GPMAW format.';
grant execute on function @extschema@.as_gpmaw(text, text, boolean) to proteax_user;
create function as_helm(text, noe boolean default false) returns text as 'MODULE_PATHNAME' language C strict;
comment on function @extschema@.as_helm(text, boolean) is 'Protein entry converted to Pfizer HELM notation. EXPERIMENTAL function at present.';
grant execute on function @extschema@.as_helm(text, boolean) to proteax_user;
create function as_molfile(text, noe boolean default false) returns text as 'MODULE_PATHNAME' language C strict;
comment on function @extschema@.as_molfile(text, boolean) is 'The chemical 2D structure that the supplied protein entry represents. The structure is represented in MDL molfile format (V2000 or V3000 depending on molecule size).';
grant execute on function @extschema@.as_molfile(text, boolean) to proteax_user;
create function as_molfile(text, text, noe boolean default false) returns text as 'MODULE_PATHNAME', 'as_molfile2' language C strict;
comment on function @extschema@.as_molfile(text, text, boolean) is 'The chemical 2D structure that the supplied protein entry represents. The structure is represented in MDL molfile format (V2000 or V3000 depending on molecule size).';
grant execute on function @extschema@.as_molfile(text, text, boolean) to proteax_user;
create function seq_render_info(text, noe boolean default false) returns text as 'MODULE_PATHNAME' language C strict;
comment on function @extschema@.seq_render_info(text, boolean) is 'Produces sequence rendering info for the supplied protein entry.';
grant execute on function @extschema@.seq_render_info(text, boolean) to proteax_user;
create function seq_render_info(text, text, noe boolean default false) returns text as 'MODULE_PATHNAME', 'seq_render_info2' language C strict;
comment on function @extschema@.seq_render_info(text, text, boolean) is 'Produces sequence rendering info for the supplied protein entry.';
grant execute on function @extschema@.seq_render_info(text, text, boolean) to proteax_user;
create function mol_render_info(text, noe boolean default false) returns text as 'MODULE_PATHNAME' language C strict;
comment on function @extschema@.mol_render_info(text, boolean) is 'Produces condensed or full-structure molecule rendering info for the supplied protein entry. If the input is an MDL molfile the molecule is rendered directly from the connection table without further conversion.';
grant execute on function @extschema@.mol_render_info(text, boolean) to proteax_user;
create function mol_render_info(text, text, noe boolean default false) returns text as 'MODULE_PATHNAME', 'mol_render_info2' language C strict;
comment on function @extschema@.mol_render_info(text, text, boolean) is 'Produces condensed or full-structure molecule rendering info for the supplied protein entry. If the input is an MDL molfile the molecule is rendered directly from the connection table without further conversion.';
grant execute on function @extschema@.mol_render_info(text, text, boolean) to proteax_user;
create function norm_sequence(text, noe boolean default false) returns text as 'MODULE_PATHNAME' language C strict;
comment on function @extschema@.norm_sequence(text, boolean) is 'The ordered expressed plain-sequence chains of the supplied protein entry. Chains are separated by periods. Cyclic chains are normalized to ensure identical sort order regardless of in-chain rotation.';
grant execute on function @extschema@.norm_sequence(text, boolean) to proteax_user;
create function norm_sequence_chksum(text, noe boolean default false) returns text as 'MODULE_PATHNAME' language C strict;
comment on function @extschema@.norm_sequence_chksum(text, boolean) is 'Runs norm_sequence() and then returns the MD5 checksum of the output from norm_sequence().';
grant execute on function @extschema@.norm_sequence_chksum(text, boolean) to proteax_user;
create function norm_protein(text, noe boolean default false) returns text as 'MODULE_PATHNAME' language C strict;
comment on function @extschema@.norm_protein(text, boolean) is 'The ordered expressed chains of the supplied protein entry. This is similar to norm_sequence(), except that the output is PLN so the full chemistry is preserved. Having the full chemistry annotations present enables structural comparison.';
grant execute on function @extschema@.norm_protein(text, boolean) to proteax_user;
create function norm_protein_chksum(text, noe boolean default false) returns text as 'MODULE_PATHNAME' language C strict;
comment on function @extschema@.norm_protein_chksum(text, boolean) is 'Runs norm_protein() and then returns the MD5 checksum of the output from norm_protein().';
grant execute on function @extschema@.norm_protein_chksum(text, boolean) to proteax_user;
create function protein_key(text, noe boolean default false) returns text as 'MODULE_PATHNAME' language C strict;
comment on function @extschema@.protein_key(text, boolean) is 'The protein key are the ordered expressed chains of the supplied protein entry, with InChI keys used to represent modified residues. This produces a structurally unique key.';
grant execute on function @extschema@.protein_key(text, boolean) to proteax_user;
create function protein_key_chksum(text, noe boolean default false) returns text as 'MODULE_PATHNAME' language C strict;
comment on function @extschema@.protein_key_chksum(text, boolean) is 'Runs protein_key() and then returns the MD5 checksum of the output from protein_key().';
grant execute on function @extschema@.protein_key_chksum(text, boolean) to proteax_user;
create function sequence_fingerprint(text, noe boolean default false) returns text as 'MODULE_PATHNAME' language C strict;
comment on function @extschema@.sequence_fingerprint(text, boolean) is 'Feature bitmap fingerprint of sequence for calculating similarity measures.';
grant execute on function @extschema@.sequence_fingerprint(text, boolean) to proteax_user;
create function inchi_string(text, noe boolean default false) returns text as 'MODULE_PATHNAME' language C strict;
comment on function @extschema@.inchi_string(text, boolean) is 'The InChI string of the supplied protein entry or molecule. If the input is a protein entry, the corresponding full structure will be built and the InChI string calculated for that structure.';
grant execute on function @extschema@.inchi_string(text, boolean) to proteax_user;
create function inchi_key(text, noe boolean default false) returns text as 'MODULE_PATHNAME' language C strict;
comment on function @extschema@.inchi_key(text, boolean) is 'The InChI key of the supplied protein entry or molecule. If the input is a protein entry, the corresponding full structure will be built and the InChI key calculated for that structure.';
grant execute on function @extschema@.inchi_key(text, boolean) to proteax_user;
create function list(text, noe boolean default false) returns text as 'MODULE_PATHNAME' language C strict;
comment on function @extschema@.list(text, boolean) is 'Lists all terminals and residues of the supplied protein entry. Output is a TAB-delimited table.';
grant execute on function @extschema@.list(text, boolean) to proteax_user;
create function full_sequence_mw(text, noe boolean default false) returns double precision as 'MODULE_PATHNAME' language C strict;
comment on function @extschema@.full_sequence_mw(text, boolean) is 'The simple average molecular weight of the protein entry sequence. Calculation follows the algorithm as given at http://www.expasy.ch/tools/pi_tool-doc.html.';
grant execute on function @extschema@.full_sequence_mw(text, boolean) to proteax_user;
create function mw_avg(text, noe boolean default false) returns double precision as 'MODULE_PATHNAME' language C strict;
comment on function @extschema@.mw_avg(text, boolean) is 'Average molecular weight of the chemical structure represented by the supplied protein entry or molfile. Proteax uses the IUPAC 2007 atomic masses at http://www.chem.qmul.ac.uk/iupac/AtWt/index.html.';
grant execute on function @extschema@.mw_avg(text, boolean) to proteax_user;
create function mw_mono(text, noe boolean default false) returns double precision as 'MODULE_PATHNAME' language C strict;
comment on function @extschema@.mw_mono(text, boolean) is 'Mono-isotopic molecular weight of the chemical structure represented by the supplied protein entry or molfile. Proteax uses the UniMod masses found at http://www.unimod.org/masses.html.';
grant execute on function @extschema@.mw_mono(text, boolean) to proteax_user;
create function dernot_diff(text, text, noe boolean default false) returns text as 'MODULE_PATHNAME' language C strict;
comment on function @extschema@.dernot_diff(text, text, boolean) is 'Calculates the DerNot expression that will produce the given protein when applied to the reference protein.';
grant execute on function @extschema@.dernot_diff(text, text, boolean) to proteax_user;
create function dernot_diff(text, text, text, noe boolean default false) returns text as 'MODULE_PATHNAME', 'dernot_diff2' language C strict;
comment on function @extschema@.dernot_diff(text, text, text, boolean) is 'Calculates the DerNot expression that will produce the given protein when applied to the reference protein.';
grant execute on function @extschema@.dernot_diff(text, text, text, boolean) to proteax_user;
create function dernot_applied(text, text, noe boolean default false) returns text as 'MODULE_PATHNAME' language C strict;
comment on function @extschema@.dernot_applied(text, text, boolean) is 'Returns a protein derivative produced by applying the DerNot expression to the reference protein.';
grant execute on function @extschema@.dernot_applied(text, text, boolean) to proteax_user;
create function dernot_distance(text, text, noe boolean default false) returns integer as 'MODULE_PATHNAME' language C strict;
comment on function @extschema@.dernot_distance(text, text, boolean) is 'Calculates the distance between two protein entries, expressed as the number of DerNot edits required to get from the given protein to the reference protein.';
grant execute on function @extschema@.dernot_distance(text, text, boolean) to proteax_user;
create function formula_mass_avg(text, noe boolean default false) returns double precision as 'MODULE_PATHNAME' language C strict;
comment on function @extschema@.formula_mass_avg(text, boolean) is 'Average molecular weight of the supplied sum formula.';
grant execute on function @extschema@.formula_mass_avg(text, boolean) to proteax_user;
create function formula_mass_mono(text, noe boolean default false) returns double precision as 'MODULE_PATHNAME' language C strict;
comment on function @extschema@.formula_mass_mono(text, boolean) is 'Mono-isotopic molecular weight of the supplied sum formula.';
grant execute on function @extschema@.formula_mass_mono(text, boolean) to proteax_user;
create function formula_add(text, text, text default 'N', noe boolean default false) returns text as 'MODULE_PATHNAME' language C strict;
comment on function @extschema@.formula_add(text, text, text, boolean) is 'Adds two sum formulas.';
grant execute on function @extschema@.formula_add(text, text, text, boolean) to proteax_user;
create function formula_sub(text, text, text default 'N', noe boolean default false) returns text as 'MODULE_PATHNAME' language C strict;
comment on function @extschema@.formula_sub(text, text, text, boolean) is 'Subtracts the second sum formula from the first.';
grant execute on function @extschema@.formula_sub(text, text, text, boolean) to proteax_user;
create function formula_mult(text, integer, text default 'N', noe boolean default false) returns text as 'MODULE_PATHNAME' language C strict;
comment on function @extschema@.formula_mult(text, integer, text, boolean) is 'Multiplies a sum formula by an integer number. This means that all element counts will be multiplied by the integer number.';
grant execute on function @extschema@.formula_mult(text, integer, text, boolean) to proteax_user;
create function formula_element_count(text, text, noe boolean default false) returns integer as 'MODULE_PATHNAME' language C strict;
comment on function @extschema@.formula_element_count(text, text, boolean) is 'Extracts the number of atoms of a given element within a sum formula.';
grant execute on function @extschema@.formula_element_count(text, text, boolean) to proteax_user;
create function tanimoto_score(text, text, noe boolean default false) returns double precision as 'MODULE_PATHNAME' language C strict;
comment on function @extschema@.tanimoto_score(text, text, boolean) is 'Calculates the similarity between two feature bitmaps using the tanimoto metric.';
grant execute on function @extschema@.tanimoto_score(text, text, boolean) to proteax_user;
