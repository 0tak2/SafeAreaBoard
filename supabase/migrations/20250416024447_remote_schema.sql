create table "public"."notifications" (
    "id" uuid not null default gen_random_uuid(),
    "profile_id" uuid,
    "is_for_all" boolean not null default false,
    "notification_type" character varying(128) not null,
    "arguments" jsonb not null default '{}'::jsonb,
    "created_at" timestamp with time zone not null default now(),
    "sent_at" timestamp with time zone
);


alter table "public"."notifications" enable row level security;

alter table "public"."profiles" add column "fcm_token" text;

CREATE UNIQUE INDEX notifications_pkey ON public.notifications USING btree (id);

alter table "public"."notifications" add constraint "notifications_pkey" PRIMARY KEY using index "notifications_pkey";

alter table "public"."notifications" add constraint "notifications_profile_id_fkey" FOREIGN KEY (profile_id) REFERENCES profiles(id) not valid;

alter table "public"."notifications" validate constraint "notifications_profile_id_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.notify_on_new_question()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    INSERT INTO notifications (
        is_for_all,
        notification_type,
        arguments
    ) VALUES (
        TRUE,
        'NEW_QUESTION',
        jsonb_build_object('question_id', NEW.id)
    );

    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.notify_on_new_reaction()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
    target_profile_id UUID;
BEGIN
    SELECT profile_id INTO target_profile_id
    FROM posts
    WHERE id = NEW.post_id;

    IF target_profile_id IS NOT NULL AND target_profile_id <> NEW.profile_id THEN
        INSERT INTO notifications (
            profile_id,
            is_for_all,
            notification_type,
            arguments
        ) VALUES (
            target_profile_id,
            FALSE,
            'NEW_REACTION',
            jsonb_build_object(
                'reaction_id', NEW.id,
                'post_id', NEW.post_id
            )
        );
    END IF;

    RETURN NEW;
END;
$function$
;

grant delete on table "public"."notifications" to "service_role";

grant insert on table "public"."notifications" to "service_role";

grant references on table "public"."notifications" to "service_role";

grant select on table "public"."notifications" to "service_role";

grant trigger on table "public"."notifications" to "service_role";

grant truncate on table "public"."notifications" to "service_role";

grant update on table "public"."notifications" to "service_role";

create policy "Allow service role to DELETE notifications"
on "public"."notifications"
as permissive
for delete
to service_role
using (true);


create policy "Allow service role to INSERT notifications"
on "public"."notifications"
as permissive
for insert
to service_role
with check (true);


create policy "Allow service role to SELECT notifications"
on "public"."notifications"
as permissive
for select
to service_role
using (true);


create policy "Allow service role to UPDATE notifications"
on "public"."notifications"
as permissive
for update
to service_role
using (true)
with check (true);


CREATE TRIGGER "NotificationPush" AFTER INSERT ON public.notifications FOR EACH ROW EXECUTE FUNCTION supabase_functions.http_request('https://yjcigolwgyzyvoezrdsn.supabase.co/functions/v1/push', 'POST', '{"Content-type":"application/json"}', '{}', '1000');

CREATE TRIGGER trg_notify_new_question AFTER INSERT ON public.questions FOR EACH ROW EXECUTE FUNCTION notify_on_new_question();

CREATE TRIGGER trg_notify_new_reaction AFTER INSERT ON public.reactions FOR EACH ROW EXECUTE FUNCTION notify_on_new_reaction();


