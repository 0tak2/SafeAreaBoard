revoke delete on table "public"."notifications" from "anon";

revoke insert on table "public"."notifications" from "anon";

revoke references on table "public"."notifications" from "anon";

revoke select on table "public"."notifications" from "anon";

revoke trigger on table "public"."notifications" from "anon";

revoke truncate on table "public"."notifications" from "anon";

revoke update on table "public"."notifications" from "anon";

revoke delete on table "public"."notifications" from "authenticated";

revoke insert on table "public"."notifications" from "authenticated";

revoke references on table "public"."notifications" from "authenticated";

revoke select on table "public"."notifications" from "authenticated";

revoke trigger on table "public"."notifications" from "authenticated";

revoke truncate on table "public"."notifications" from "authenticated";

revoke update on table "public"."notifications" from "authenticated";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.notify_on_new_question()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
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
 SECURITY DEFINER
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


