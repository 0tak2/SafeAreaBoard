alter table "public"."questions" disable row level security;

create policy "Users can read posts"
on "public"."posts"
as permissive
for select
to authenticated
using (true);


create policy "Users can read questions"
on "public"."questions"
as permissive
for select
to authenticated
using (true);


create policy "Users can read reactions"
on "public"."reactions"
as permissive
for select
to authenticated
using (true);



