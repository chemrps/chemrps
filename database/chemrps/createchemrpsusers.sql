CREATE USER DBSUPER_USER WITH SUPERUSER encrypted password 'SUPERUSERPASSWORD';

	CREATE ROLE proteax_user;

	CREATE USER bcf_auth WITH  CREATEROLE encrypted password 'BCF_AUTH_PASSWORD';

	CREATE USER bcf_authenticator WITH encrypted password 'BCF_AUTHENTICATORPASSWORD';

	CREATE USER bcf_reg WITH encrypted password 'BCF_REGPASSWORD';
	GRANT proteax_user TO bcf_reg;

	CREATE USER bcf_reg_facade WITH encrypted password 'BCF_REG_FACADEPASSWORD';
	GRANT proteax_user TO bcf_reg_facade;

	CREATE ROLE bcf_reg_viewer;

	CREATE ROLE bcf_reg_editor;
	GRANT bcf_reg_viewer TO bcf_reg_editor;

	CREATE ROLE bcf_reg_admin;
	GRANT bcf_reg_editor TO bcf_reg_admin;

	CREATE ROLE bcf_reg_dba;
	GRANT bcf_reg_admin TO bcf_reg_dba;