import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};
const reply = (data: unknown, status = 200) =>
  new Response(JSON.stringify(data), { status, headers: { ...cors, "Content-Type": "application/json" } });

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return reply({ error: "Method not allowed" }, 405);
  const url = Deno.env.get("SUPABASE_URL");
  const anon = Deno.env.get("SUPABASE_ANON_KEY");
  const service = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!url || !anon || !service) return reply({ error: "Authentication service is not configured" }, 500);
  try {
    const body = await req.json();
    const phone = typeof body.phone === "string" ? body.phone.replace(/[^+0-9]/g, "") : "";
    const password = typeof body.password === "string" ? body.password : "";
    if (phone.length < 7 || password.length < 6) return reply({ error: "Invalid phone number or password" }, 400);
    const admin = createClient(url, service, { auth: { persistSession: false, autoRefreshToken: false } });
    let page = 1, email: string | null = null;
    while (page <= 20 && !email) {
      const { data, error } = await admin.auth.admin.listUsers({ page, perPage: 500 });
      if (error) return reply({ error: "Unable to verify login details" }, 500);
      const found = data.users.find((u) => (u.user_metadata?.phone ?? "").toString().replace(/[^+0-9]/g, "") === phone);
      if (found?.email) email = found.email;
      if (data.users.length < 500) break;
      page++;
    }
    if (!email) return reply({ error: "Invalid phone number or password" }, 401);
    const auth = createClient(url, anon, { auth: { persistSession: false, autoRefreshToken: false } });
    const { data, error } = await auth.auth.signInWithPassword({ email, password });
    if (error || !data.session) return reply({ error: "Invalid phone number or password" }, 401);
    return reply({ access_token: data.session.access_token, refresh_token: data.session.refresh_token, token_type: data.session.token_type, expires_in: data.session.expires_in });
  } catch {
    return reply({ error: "Unable to complete phone login" }, 400);
  }
});
