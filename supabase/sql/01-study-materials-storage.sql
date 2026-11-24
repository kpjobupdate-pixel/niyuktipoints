-- NiyuktiPoints | Study Materials Storage
-- Run once in Supabase SQL Editor. Safe to rerun.
-- Creates a public-read bucket for study files, with uploads restricted to the configured admin email.
-- Frontend uses bucket: study-materials and a 20 MB client-side file-size cap.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'study-materials',
  'study-materials',
  true,
  20971520,
  array[
    'application/pdf',
    'image/png',
    'image/jpeg',
    'image/webp',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.ms-powerpoint',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation'
  ]
)
on conflict (id) do update
set public = excluded.public,
    file_size_limit = excluded.file_size_limit,
    allowed_mime_types = excluded.allowed_mime_types;

-- Public read access: files published into the study-materials bucket are intended for students.
drop policy if exists "Public can read study materials" on storage.objects;
create policy "Public can read study materials"
on storage.objects for select
using (bucket_id = 'study-materials');

-- Admin-only uploads.
drop policy if exists "Admin can upload study materials" on storage.objects;
create policy "Admin can upload study materials"
on storage.objects for insert
with check (
  bucket_id = 'study-materials'
  and (auth.jwt() ->> 'email') = 'princeji9305@gmail.com'
);

-- Admin-only replacement/metadata update.
drop policy if exists "Admin can update study materials" on storage.objects;
create policy "Admin can update study materials"
on storage.objects for update
using (
  bucket_id = 'study-materials'
  and (auth.jwt() ->> 'email') = 'princeji9305@gmail.com'
)
with check (
  bucket_id = 'study-materials'
  and (auth.jwt() ->> 'email') = 'princeji9305@gmail.com'
);

-- Admin-only deletion.
drop policy if exists "Admin can delete study materials" on storage.objects;
create policy "Admin can delete study materials"
on storage.objects for delete
using (
  bucket_id = 'study-materials'
  and (auth.jwt() ->> 'email') = 'princeji9305@gmail.com'
);
