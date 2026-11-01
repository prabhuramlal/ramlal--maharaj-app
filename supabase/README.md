# Supabase Super Admin setup

The Flutter app's **Users** tab is shown only when the signed-in account has the
server-managed `app_metadata.role = "super_admin"` claim.

## One-time first Super Admin bootstrap

1. Confirm the exact email address of the trusted account that should become the first Super Admin.
2. In the Supabase project SQL Editor, run the following after replacing the placeholder with that exact email:

```sql
update auth.users
set raw_app_meta_data =
  coalesce(raw_app_meta_data, '{}'::jsonb) || '{"role":"super_admin"}'::jsonb
where lower(email) = lower('REPLACE-WITH-VERIFIED-ACCOUNT-EMAIL');
```

3. Confirm exactly one row was updated. Sign out and sign back in on the app so the refreshed access token contains the new app metadata claim.

Do not put the service-role key in the Flutter app or commit it to this repository.

## Deploy the function

From the repository root, link the intended Supabase project and deploy:

```sh
supabase login
supabase link --project-ref YOUR_PROJECT_REF
supabase functions deploy manage-users
```

The function uses the Supabase-provided `SUPABASE_URL`, `SUPABASE_ANON_KEY`,
and `SUPABASE_SERVICE_ROLE_KEY` environment variables. The service-role key is
used only inside the Edge Function. JWT verification is enabled in
`config.toml`, and the function independently validates the caller's session
and `app_metadata.role` before any administrative operation.

## Available Super Admin actions

- List up to 500 registered Auth users.
- Promote a regular account to `admin`.
- Revoke `admin` access (returns the account to `devotee`).
- Suspend or restore a regular account.

The function prevents self-modification and protects every account already
marked `super_admin`. Keep the number of Super Admin accounts small and grant
the role only through trusted Supabase project administration.

## Important deployment note

This repository change does not deploy the Edge Function or modify live Supabase
Auth users. The Users tab will show a configuration/deployment error until the
function is deployed to the app's actual Supabase project and the first
Super Admin role is bootstrapped.
