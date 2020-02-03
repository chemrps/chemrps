drop user if exists example$admin;
drop user if exists example$writer;
drop user if exists example$viewer;

truncate table bcf_auth.user_mappings;

truncate table bcf_auth.users_admin;

truncate table bcf_auth.users_editor;

truncate table bcf_auth.users_viewer;

insert into bcf_auth.users_admin values ('admin');


insert into bcf_auth.users_editor values ('writer');



insert into bcf_auth.users_viewer values ('viewer');



do $$
begin
  perform bcf_auth.sync_users();
end;
$$;

do $$
begin
  perform bcf_auth.set_password('admin','demo');
  
end;
$$

