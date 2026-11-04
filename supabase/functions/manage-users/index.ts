import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
const cors = { "Access-Control-Allow-Origin": "*", "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type", "Access-Control-Allow-Methods": "POST, OPTIONS" };
const reply = (data: unknown, status = 200) => new Response(JSON.stringify(data), { status, headers: { ...cors, "Content-Type": "application/json" } });

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return reply({ error: "Method not allowed" }, 405);
  const auth = req.headers.get("Authorization") ?? "";
  if (!auth.startsWith("Bearer ")) return reply({ error: "Authentication required" }, 401);
  const url = Deno.env.get("SUPABASE_URL"), anon = Deno.env.get("SUPABASE_ANON_KEY"), service = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!url || !anon || !service) return reply({ error: "Server function is not configured" }, 500);
  const token = auth.slice(7);
  const caller = createClient(url, anon, { global: { headers: { Authorization: "Bearer " + token } }, auth: { persistSession: false, autoRefreshToken: false } });
  const { data: authData, error: authError } = await caller.auth.getUser(token);
  if (authError || !authData.user) return reply({ error: "Invalid session" }, 401);
  if (authData.user.app_metadata?.role !== "super_admin") return reply({ error: "Super Admin permission required" }, 403);
  const admin = createClient(url, service, { auth: { persistSession: false, autoRefreshToken: false } });
  try {
    const body = await req.json(), action = body?.action;
    if (action === "list") {
      const { data, error } = await admin.auth.admin.listUsers({ page: 1, perPage: 500 });
      if (error) return reply({ error: error.message }, 400);
      return reply({ users: data.users.map((u) => ({ id: u.id, email: u.email ?? null, app_metadata: { role: u.app_metadata?.role ?? "devotee" }, user_metadata: { full_name: u.user_metadata?.full_name ?? null, phone: u.user_metadata?.phone ?? null }, created_at: u.created_at, banned_until: u.banned_until ?? null })) });
    }
    const id = typeof body?.user_id === "string" ? body.user_id : "";
    if (!id) return reply({ error: "Valid user_id required" }, 400);
    if (id === authData.user.id) return reply({ error: "You cannot modify your own account" }, 400);
    const { data: targetData, error: targetError } = await admin.auth.admin.getUserById(id);
    if (targetError || !targetData.user) return reply({ error: "User not found" }, 404);
    const target = targetData.user;
    if (target.app_metadata?.role === "super_admin") return reply({ error: "Super Admin accounts are protected" }, 403);
    if (action === "set_role") {
      const role = body?.role;
      if (role !== "admin" && role !== "devotee") return reply({ error: "Role must be admin or devotee" }, 400);
      const { error } = await admin.auth.admin.updateUserById(id, { app_metadata: { ...target.app_metadata, role } });
      if (error) return reply({ error: error.message }, 400);
      return reply({ success: true, role });
    }
    if (action === "ban" || action === "unban") {
      const { error } = await admin.auth.admin.updateUserById(id, { ban_duration: action === "ban" ? "876000h" : "none" });
      if (error) return reply({ error: error.message }, 400);
      return reply({ success: true, banned: action === "ban" });
    }
    return reply({ error: "Unsupported action" }, 400);
  } catch (e) { return reply({ error: e instanceof Error ? e.message : "Unexpected server error" }, 500); }
});
