-- ================================
-- ROW LEVEL SECURITY (RLS) POLICIES FOR KERNEL MVP
-- Run this file to set up or update RLS policies
-- ================================
--
-- IMPORTANT FOR MVP:
-- - These policies protect your app's API from unauthorized access
-- - Supabase Dashboard operations BYPASS RLS automatically
-- - You can add/edit content manually from Dashboard without any role setup
-- - Admin/Editor policies are for future use (if you build an admin panel)
-- - For MVP, you don't need to set up admin/editor roles
--
-- ================================

-- ================================
-- 1. USERS TABLE
-- ================================
-- Critical: Contains PII (email, display_name, preferences)

-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (for updates)
DROP POLICY IF EXISTS "Users can view own profile" ON users;
DROP POLICY IF EXISTS "Users can update own profile" ON users;
DROP POLICY IF EXISTS "Users can insert own profile" ON users;
DROP POLICY IF EXISTS "Users can delete own profile" ON users;

-- Users can only view their own profile
CREATE POLICY "Users can view own profile" ON users
    FOR SELECT 
    USING (auth.uid() = id);

-- Users can only update their own profile
CREATE POLICY "Users can update own profile" ON users
    FOR UPDATE 
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- Users can only insert their own profile (id must match auth.uid())
CREATE POLICY "Users can insert own profile" ON users
    FOR INSERT 
    WITH CHECK (auth.uid() = id);

-- Users can delete their own profile (for account deletion)
CREATE POLICY "Users can delete own profile" ON users
    FOR DELETE 
    USING (auth.uid() = id);

-- ================================
-- 2. COURSE_BYTE_PROGRESS TABLE
-- ================================
-- Critical: User progress data - must be isolated per user

-- Enable RLS
ALTER TABLE course_byte_progress ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view own course progress" ON course_byte_progress;
DROP POLICY IF EXISTS "Users can insert own course progress" ON course_byte_progress;
DROP POLICY IF EXISTS "Users can update own course progress" ON course_byte_progress;
DROP POLICY IF EXISTS "Users can delete own course progress" ON course_byte_progress;

-- Users can only view their own progress
CREATE POLICY "Users can view own course progress" ON course_byte_progress
    FOR SELECT 
    USING (auth.uid() = user_id);

-- Users can only insert progress for themselves
CREATE POLICY "Users can insert own course progress" ON course_byte_progress
    FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

-- Users can only update their own progress
CREATE POLICY "Users can update own course progress" ON course_byte_progress
    FOR UPDATE 
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Users can delete their own progress
CREATE POLICY "Users can delete own course progress" ON course_byte_progress
    FOR DELETE 
    USING (auth.uid() = user_id);

-- ================================
-- 3. COURSES TABLE
-- ================================
-- Public read for active courses
-- NOTE: Write operations are restricted to prevent app users from modifying content
-- You can still add/edit courses manually from Supabase Dashboard (Dashboard bypasses RLS)

-- Enable RLS
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Active courses are viewable by everyone" ON courses;
DROP POLICY IF EXISTS "Admins can manage all courses" ON courses;
DROP POLICY IF EXISTS "Editors can manage all courses" ON courses;

-- Public read access for active courses (anyone can read via app)
CREATE POLICY "Active courses are viewable by everyone" ON courses
    FOR SELECT 
    USING (is_active = true);

-- IMPORTANT FOR MVP: 
-- The policies below prevent app users from modifying content.
-- You can still add/edit courses from Supabase Dashboard (Dashboard has elevated privileges).
-- These policies are only for future use if you build an admin panel in your app.

-- Admin can manage all courses (for future admin panel - not needed for MVP Dashboard access)
CREATE POLICY "Admins can manage all courses" ON courses
    FOR ALL 
    USING (
        auth.jwt() ->> 'role' = 'admin' 
        OR 
        auth.jwt() ->> 'user_role' = 'admin'
    );

-- Editor can manage all courses (for future admin panel - not needed for MVP Dashboard access)
CREATE POLICY "Editors can manage all courses" ON courses
    FOR ALL 
    USING (
        auth.jwt() ->> 'role' = 'editor' 
        OR 
        auth.jwt() ->> 'user_role' = 'editor'
    );

-- ================================
-- 4. UNITS TABLE
-- ================================
-- Public read for units of active courses
-- NOTE: Write operations are restricted to prevent app users from modifying content
-- You can still add/edit units manually from Supabase Dashboard (Dashboard bypasses RLS)

-- Enable RLS
ALTER TABLE units ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Units of active courses are viewable by everyone" ON units;
DROP POLICY IF EXISTS "Admins can manage all units" ON units;
DROP POLICY IF EXISTS "Editors can manage all units" ON units;

-- Public read access for units of active courses
CREATE POLICY "Units of active courses are viewable by everyone" ON units
    FOR SELECT 
    USING (
        EXISTS (
            SELECT 1 FROM courses 
            WHERE courses.id = units.course_id 
            AND courses.is_active = true
        )
    );

-- Admin can manage all units (for future admin panel - not needed for MVP Dashboard access)
CREATE POLICY "Admins can manage all units" ON units
    FOR ALL 
    USING (
        auth.jwt() ->> 'role' = 'admin' 
        OR 
        auth.jwt() ->> 'user_role' = 'admin'
    );

-- Editor can manage all units (for future admin panel - not needed for MVP Dashboard access)
CREATE POLICY "Editors can manage all units" ON units
    FOR ALL 
    USING (
        auth.jwt() ->> 'role' = 'editor' 
        OR 
        auth.jwt() ->> 'user_role' = 'editor'
    );

-- ================================
-- 5. COURSE_BYTES TABLE
-- ================================
-- Public read for all course bytes
-- NOTE: Write operations are restricted to prevent app users from modifying content
-- You can still add/edit course bytes manually from Supabase Dashboard (Dashboard bypasses RLS)

-- Enable RLS
ALTER TABLE course_bytes ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Course bytes are viewable by everyone" ON course_bytes;
DROP POLICY IF EXISTS "Admins can manage all course bytes" ON course_bytes;
DROP POLICY IF EXISTS "Editors can manage all course bytes" ON course_bytes;

-- Public read access for all course bytes (anyone can read via app)
CREATE POLICY "Course bytes are viewable by everyone" ON course_bytes
    FOR SELECT 
    USING (true);

-- Admin can manage all course bytes (for future admin panel - not needed for MVP Dashboard access)
CREATE POLICY "Admins can manage all course bytes" ON course_bytes
    FOR ALL 
    USING (
        auth.jwt() ->> 'role' = 'admin' 
        OR 
        auth.jwt() ->> 'user_role' = 'admin'
    );

-- Editor can manage all course bytes (for future admin panel - not needed for MVP Dashboard access)
CREATE POLICY "Editors can manage all course bytes" ON course_bytes
    FOR ALL 
    USING (
        auth.jwt() ->> 'role' = 'editor' 
        OR 
        auth.jwt() ->> 'user_role' = 'editor'
    );

-- ================================
-- STORAGE BUCKET POLICIES
-- ================================
-- If you're using Supabase Storage for course content

-- Note: These need to be run in Supabase Dashboard > Storage > Policies
-- Or via the Supabase API

-- For 'kernel_bytes' bucket (public read, authenticated upload)
-- CREATE POLICY "Public can view kernel_bytes content" 
--     ON storage.objects FOR SELECT 
--     USING (bucket_id = 'kernel_bytes');

-- CREATE POLICY "Authenticated can upload kernel_bytes content" 
--     ON storage.objects FOR INSERT 
--     WITH CHECK (
--         bucket_id = 'kernel_bytes' 
--         AND auth.role() = 'authenticated'
--     );

-- CREATE POLICY "Authenticated can update kernel_bytes content" 
--     ON storage.objects FOR UPDATE 
--     USING (
--         bucket_id = 'kernel_bytes' 
--         AND auth.role() = 'authenticated'
--     );

-- CREATE POLICY "Authenticated can delete kernel_bytes content" 
--     ON storage.objects FOR DELETE 
--     USING (
--         bucket_id = 'kernel_bytes' 
--         AND auth.role() = 'authenticated'
--     );

-- ================================
-- VERIFICATION QUERIES
-- ================================
-- Run these to verify RLS is enabled and policies exist

-- Check if RLS is enabled on all tables
-- SELECT tablename, rowsecurity 
-- FROM pg_tables 
-- WHERE schemaname = 'public' 
-- AND tablename IN ('users', 'courses', 'units', 'course_bytes', 'course_byte_progress')
-- ORDER BY tablename;

-- Check all policies
-- SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
-- FROM pg_policies 
-- WHERE schemaname = 'public'
-- ORDER BY tablename, policyname;

