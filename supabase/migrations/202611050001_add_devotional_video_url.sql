-- Adds an optional uploaded video alongside the existing external/file link and thumbnail.
-- Existing rows remain valid; legacy file_url and thumbnail_url values are preserved.
alter table public.devotional_content
  add column if not exists video_url text;

comment on column public.devotional_content.video_url is
  'Optional public storage URL for an uploaded video attached to a devotional content entry.';
