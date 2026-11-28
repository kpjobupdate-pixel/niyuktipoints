-- NiyuktiPoints: read-only Supabase schema/security inventory
-- Run in Supabase SQL Editor and share the single JSON result with the developer.
-- This script does NOT alter data, policies, grants, functions, or schema.

select jsonb_build_object(
  'columns', coalesce((
    select jsonb_agg(jsonb_build_object(
      'table', c.table_name,
      'column', c.column_name,
      'type', c.data_type,
      'udt', c.udt_name,
      'nullable', c.is_nullable,
      'default', c.column_default
    ) order by c.table_name, c.ordinal_position)
    from information_schema.columns c
    where c.table_schema = 'public'
      and c.table_name in (
        'profiles','submissions','doubts','site_settings',
        'mock_tests','reviews','notices','resources','toppers'
      )
  ), '[]'::jsonb),
  'rls', coalesce((
    select jsonb_agg(jsonb_build_object(
      'table', p.tablename,
      'enabled', p.rowsecurity,
      'forced', p.forcerowsecurity
    ) order by p.tablename)
    from pg_tables p
    where p.schemaname = 'public'
      and p.tablename in (
        'profiles','submissions','doubts','site_settings',
        'mock_tests','reviews','notices','resources','toppers'
      )
  ), '[]'::jsonb),
  'policies', coalesce((
    select jsonb_agg(jsonb_build_object(
      'table', p.tablename,
      'name', p.policyname,
      'command', p.cmd,
      'roles', p.roles,
      'using', p.qual,
      'with_check', p.with_check
    ) order by p.tablename, p.policyname)
    from pg_policies p
    where p.schemaname = 'public'
      and p.tablename in (
        'profiles','submissions','doubts','site_settings',
        'mock_tests','reviews','notices','resources','toppers'
      )
  ), '[]'::jsonb),
  'table_grants', coalesce((
    select jsonb_agg(jsonb_build_object(
      'table', g.table_name,
      'grantee', g.grantee,
      'privilege', g.privilege_type
    ) order by g.table_name, g.grantee, g.privilege_type)
    from information_schema.role_table_grants g
    where g.table_schema = 'public'
      and g.table_name in (
        'profiles','submissions','doubts','site_settings',
        'mock_tests','reviews','notices','resources','toppers'
      )
  ), '[]'::jsonb),
  'triggers', coalesce((
    select jsonb_agg(jsonb_build_object(
      'table', t.event_object_table,
      'name', t.trigger_name,
      'event', t.event_manipulation,
      'timing', t.action_timing,
      'definition', t.action_statement
    ) order by t.event_object_table, t.trigger_name)
    from information_schema.triggers t
    where t.event_object_schema = 'public'
      and t.event_object_table in (
        'profiles','submissions','doubts','site_settings'
      )
  ), '[]'::jsonb),
  'security_functions', coalesce((
    select jsonb_agg(jsonb_build_object(
      'name', p.proname,
      'args', pg_get_function_identity_arguments(p.oid),
      'security_definer', p.prosecdef,
      'definition', pg_get_functiondef(p.oid)
    ) order by p.proname)
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and (
        p.proname ilike '%coin%' or
        p.proname ilike '%reward%' or
        p.proname ilike '%study%' or
        p.proname ilike '%profile%' or
        p.proname ilike '%submission%'
      )
  ), '[]'::jsonb)
) as niyuktipoints_security_audit;
