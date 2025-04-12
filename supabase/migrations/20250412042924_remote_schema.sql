create sequence "public"."posts_id_seq";

create sequence "public"."questions_id_seq";

create sequence "public"."reactions_id_seq";

create table "public"."posts" (
    "id" integer not null default nextval('posts_id_seq'::regclass),
    "content" text not null,
    "created_at" timestamp with time zone default CURRENT_TIMESTAMP,
    "updated_at" timestamp with time zone default CURRENT_TIMESTAMP,
    "is_deleted" boolean default false,
    "is_hidden" boolean default false,
    "profile_id" uuid not null,
    "question_id" integer not null
);


alter table "public"."posts" enable row level security;

create table "public"."questions" (
    "id" integer not null default nextval('questions_id_seq'::regclass),
    "content" text not null,
    "created_at" timestamp with time zone default CURRENT_TIMESTAMP,
    "updated_at" timestamp with time zone default CURRENT_TIMESTAMP,
    "is_deleted" boolean default false,
    "is_hidden" boolean default false
);


alter table "public"."questions" enable row level security;

create table "public"."reactions" (
    "id" integer not null default nextval('reactions_id_seq'::regclass),
    "type" character varying(30) not null,
    "created_at" timestamp with time zone default CURRENT_TIMESTAMP,
    "profile_id" uuid not null,
    "post_id" integer not null
);


alter table "public"."reactions" enable row level security;

alter sequence "public"."posts_id_seq" owned by "public"."posts"."id";

alter sequence "public"."questions_id_seq" owned by "public"."questions"."id";

alter sequence "public"."reactions_id_seq" owned by "public"."reactions"."id";

CREATE UNIQUE INDEX posts_pkey ON public.posts USING btree (id);

CREATE UNIQUE INDEX questions_pkey ON public.questions USING btree (id);

CREATE UNIQUE INDEX reactions_pkey ON public.reactions USING btree (id);

alter table "public"."posts" add constraint "posts_pkey" PRIMARY KEY using index "posts_pkey";

alter table "public"."questions" add constraint "questions_pkey" PRIMARY KEY using index "questions_pkey";

alter table "public"."reactions" add constraint "reactions_pkey" PRIMARY KEY using index "reactions_pkey";

alter table "public"."posts" add constraint "posts_profile_id_fkey" FOREIGN KEY (profile_id) REFERENCES profiles(id) ON DELETE CASCADE not valid;

alter table "public"."posts" validate constraint "posts_profile_id_fkey";

alter table "public"."posts" add constraint "posts_question_id_fkey" FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE not valid;

alter table "public"."posts" validate constraint "posts_question_id_fkey";

alter table "public"."reactions" add constraint "reactions_post_id_fkey" FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE not valid;

alter table "public"."reactions" validate constraint "reactions_post_id_fkey";

alter table "public"."reactions" add constraint "reactions_profile_id_fkey" FOREIGN KEY (profile_id) REFERENCES profiles(id) ON DELETE CASCADE not valid;

alter table "public"."reactions" validate constraint "reactions_profile_id_fkey";

grant delete on table "public"."posts" to "anon";

grant insert on table "public"."posts" to "anon";

grant references on table "public"."posts" to "anon";

grant select on table "public"."posts" to "anon";

grant trigger on table "public"."posts" to "anon";

grant truncate on table "public"."posts" to "anon";

grant update on table "public"."posts" to "anon";

grant delete on table "public"."posts" to "authenticated";

grant insert on table "public"."posts" to "authenticated";

grant references on table "public"."posts" to "authenticated";

grant select on table "public"."posts" to "authenticated";

grant trigger on table "public"."posts" to "authenticated";

grant truncate on table "public"."posts" to "authenticated";

grant update on table "public"."posts" to "authenticated";

grant delete on table "public"."posts" to "service_role";

grant insert on table "public"."posts" to "service_role";

grant references on table "public"."posts" to "service_role";

grant select on table "public"."posts" to "service_role";

grant trigger on table "public"."posts" to "service_role";

grant truncate on table "public"."posts" to "service_role";

grant update on table "public"."posts" to "service_role";

grant delete on table "public"."questions" to "anon";

grant insert on table "public"."questions" to "anon";

grant references on table "public"."questions" to "anon";

grant select on table "public"."questions" to "anon";

grant trigger on table "public"."questions" to "anon";

grant truncate on table "public"."questions" to "anon";

grant update on table "public"."questions" to "anon";

grant delete on table "public"."questions" to "authenticated";

grant insert on table "public"."questions" to "authenticated";

grant references on table "public"."questions" to "authenticated";

grant select on table "public"."questions" to "authenticated";

grant trigger on table "public"."questions" to "authenticated";

grant truncate on table "public"."questions" to "authenticated";

grant update on table "public"."questions" to "authenticated";

grant delete on table "public"."questions" to "service_role";

grant insert on table "public"."questions" to "service_role";

grant references on table "public"."questions" to "service_role";

grant select on table "public"."questions" to "service_role";

grant trigger on table "public"."questions" to "service_role";

grant truncate on table "public"."questions" to "service_role";

grant update on table "public"."questions" to "service_role";

grant delete on table "public"."reactions" to "anon";

grant insert on table "public"."reactions" to "anon";

grant references on table "public"."reactions" to "anon";

grant select on table "public"."reactions" to "anon";

grant trigger on table "public"."reactions" to "anon";

grant truncate on table "public"."reactions" to "anon";

grant update on table "public"."reactions" to "anon";

grant delete on table "public"."reactions" to "authenticated";

grant insert on table "public"."reactions" to "authenticated";

grant references on table "public"."reactions" to "authenticated";

grant select on table "public"."reactions" to "authenticated";

grant trigger on table "public"."reactions" to "authenticated";

grant truncate on table "public"."reactions" to "authenticated";

grant update on table "public"."reactions" to "authenticated";

grant delete on table "public"."reactions" to "service_role";

grant insert on table "public"."reactions" to "service_role";

grant references on table "public"."reactions" to "service_role";

grant select on table "public"."reactions" to "service_role";

grant trigger on table "public"."reactions" to "service_role";

grant truncate on table "public"."reactions" to "service_role";

grant update on table "public"."reactions" to "service_role";

create policy "Anon can read posts"
on "public"."posts"
as permissive
for select
to anon
using (true);


create policy "User can manage own posts"
on "public"."posts"
as permissive
for all
to authenticated
using ((profile_id = auth.uid()))
with check ((profile_id = auth.uid()));


create policy "Anon can read questions"
on "public"."questions"
as permissive
for select
to anon
using (true);


create policy "Anon can read reactions"
on "public"."reactions"
as permissive
for select
to anon
using (true);


create policy "User can create reactions"
on "public"."reactions"
as permissive
for insert
to authenticated
with check ((profile_id = auth.uid()));


create policy "User can delete own reactions"
on "public"."reactions"
as permissive
for delete
to authenticated
using ((profile_id = auth.uid()));



