-- Revert personnel:permissions_on_user from pg

begin;

drop function personnel.permissions_on_user(integer, integer);

commit;
