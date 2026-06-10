-- ================================
-- SUPABASE SQL SCHEMA FOR KERNEL APP
-- Simplified Schema with JSON Storage
-- ================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ================================
-- MAIN TABLES
-- ================================

-- Users table - user profiles and authentication data
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    display_name VARCHAR(255),
    profile_image_url TEXT,
    subscription_type VARCHAR(50) DEFAULT 'free',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    subscription_expires_at TIMESTAMPTZ,
    preferences JSONB DEFAULT '{}',
    
    -- Constraints
    CONSTRAINT users_email_check CHECK (length(email) > 0),
    CONSTRAINT users_subscription_type_check CHECK (subscription_type IN ('free', 'premium'))
);

-- Courses table - main courses
CREATE TABLE courses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    thumbnail_url TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT courses_title_check CHECK (length(title) > 0)
);

-- Units table - course units/modules
CREATE TABLE units (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    unit_order INTEGER NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT units_title_check CHECK (length(title) > 0),
    CONSTRAINT units_order_check CHECK (unit_order >= 0),
    CONSTRAINT units_unique_course_order UNIQUE(course_id, unit_order)
);

-- Course Bytes table - simplified course content
CREATE TABLE course_bytes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    unit_id UUID NOT NULL REFERENCES units(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    content_json_url TEXT NOT NULL,
    total_blocks INTEGER NOT NULL DEFAULT 0,
    byte_order INTEGER NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT course_bytes_title_check CHECK (length(title) > 0),
    CONSTRAINT course_bytes_blocks_check CHECK (total_blocks >= 0),
    CONSTRAINT course_bytes_order_check CHECK (byte_order >= 0),
    CONSTRAINT course_bytes_unique_unit_order UNIQUE(unit_id, byte_order)
);

-- Byte table - weekly bytes only (simplified)
CREATE TABLE byte (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    slug VARCHAR(255) NOT NULL,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    content_json_url TEXT, -- URL to JSON file in Supabase Storage
    is_premium BOOLEAN NOT NULL DEFAULT false,
    tags TEXT[] DEFAULT '{}', -- Array of tags
    published_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    thumbnail_url TEXT, -- URL to thumbnail in Supabase Storage
    reading_time_minutes INTEGER NOT NULL DEFAULT 5,
    total_blocks INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Indexes for performance
    CONSTRAINT bytes_slug_check CHECK (length(slug) > 0),
    CONSTRAINT bytes_title_check CHECK (length(title) > 0),
    CONSTRAINT bytes_reading_time_check CHECK (reading_time_minutes > 0)
);

-- ================================
-- INDEXES FOR PERFORMANCE
-- ================================

-- Users table indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_subscription_type ON users(subscription_type);
CREATE INDEX idx_users_created_at ON users(created_at DESC);

-- Courses table indexes
CREATE INDEX idx_courses_is_active ON courses(is_active);
CREATE INDEX idx_courses_created_at ON courses(created_at DESC);

-- Units table indexes
CREATE INDEX idx_units_course_id ON units(course_id);
CREATE INDEX idx_units_course_order ON units(course_id, unit_order);

-- Course Bytes table indexes
CREATE INDEX idx_course_bytes_unit_id ON course_bytes(unit_id);
CREATE INDEX idx_course_bytes_unit_order ON course_bytes(unit_id, byte_order);

-- Byte table indexes (weekly bytes only)
CREATE INDEX idx_byte_slug ON byte(slug);
CREATE INDEX idx_byte_published_at ON byte(published_at DESC);
CREATE INDEX idx_byte_is_premium ON byte(is_premium);
CREATE INDEX idx_byte_tags ON byte USING GIN(tags);
CREATE INDEX idx_byte_created_at ON byte(created_at DESC);

-- Saved bytes table - tracks user's saved/bookmarked bytes
CREATE TABLE saved_bytes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    byte_id UUID NOT NULL REFERENCES byte(id) ON DELETE CASCADE,
    saved_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Ensure a user can only save a byte once
    CONSTRAINT saved_bytes_unique_user_byte UNIQUE(user_id, byte_id)
);

-- Saved bytes table indexes
CREATE INDEX idx_saved_bytes_user_id ON saved_bytes(user_id);
CREATE INDEX idx_saved_bytes_byte_id ON saved_bytes(byte_id);
CREATE INDEX idx_saved_bytes_saved_at ON saved_bytes(saved_at DESC);

-- Course Byte Progress table - tracks user progress on course bytes
CREATE TABLE course_byte_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    course_byte_id UUID NOT NULL REFERENCES course_bytes(id) ON DELETE CASCADE,
    current_block_index INTEGER NOT NULL DEFAULT 0,
    is_completed BOOLEAN NOT NULL DEFAULT false,
    completed_at TIMESTAMPTZ,
    last_accessed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT course_byte_progress_unique_user_byte UNIQUE(user_id, course_byte_id),
    CONSTRAINT course_byte_progress_block_index_check CHECK (current_block_index >= 0)
);

-- Byte Progress table - tracks user reading progress (weekly bytes only)
CREATE TABLE byte_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    byte_id UUID NOT NULL REFERENCES byte(id) ON DELETE CASCADE,
    current_block_index INTEGER NOT NULL DEFAULT 0,
    is_completed BOOLEAN NOT NULL DEFAULT false,
    completed_at TIMESTAMPTZ,
    last_accessed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT byte_progress_unique_user_byte UNIQUE(user_id, byte_id),
    CONSTRAINT byte_progress_block_index_check CHECK (current_block_index >= 0)
);

-- Course byte progress table indexes
CREATE INDEX idx_course_byte_progress_user_id ON course_byte_progress(user_id);
CREATE INDEX idx_course_byte_progress_byte_id ON course_byte_progress(course_byte_id);
CREATE INDEX idx_course_byte_progress_is_completed ON course_byte_progress(is_completed);
CREATE INDEX idx_course_byte_progress_last_accessed ON course_byte_progress(last_accessed_at DESC);

-- Byte progress table indexes
CREATE INDEX idx_byte_progress_user_id ON byte_progress(user_id);
CREATE INDEX idx_byte_progress_byte_id ON byte_progress(byte_id);
CREATE INDEX idx_byte_progress_is_completed ON byte_progress(is_completed);
CREATE INDEX idx_byte_progress_last_accessed ON byte_progress(last_accessed_at DESC);

-- ================================
-- ROW LEVEL SECURITY (RLS)
-- ================================

-- Enable RLS on users table
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Users can only see and modify their own data
CREATE POLICY "Users can view own profile" ON users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON users
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON users
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Enable RLS on courses table
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;

-- Public read access for active courses
CREATE POLICY "Active courses are viewable by everyone" ON courses
    FOR SELECT USING (is_active = true);

-- Admin/Editor policies for course management
CREATE POLICY "Admins can manage all courses" ON courses
    FOR ALL USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Editors can manage all courses" ON courses
    FOR ALL USING (auth.jwt() ->> 'role' = 'editor');

-- Enable RLS on units table
ALTER TABLE units ENABLE ROW LEVEL SECURITY;

-- Public read access for units of active courses
CREATE POLICY "Units of active courses are viewable by everyone" ON units
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM courses 
            WHERE courses.id = units.course_id 
            AND courses.is_active = true
        )
    );

-- Admin/Editor policies for unit management
CREATE POLICY "Admins can manage all units" ON units
    FOR ALL USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Editors can manage all units" ON units
    FOR ALL USING (auth.jwt() ->> 'role' = 'editor');

-- Enable RLS on course_bytes table
ALTER TABLE course_bytes ENABLE ROW LEVEL SECURITY;

-- Public read access for course bytes
CREATE POLICY "Course bytes are viewable by everyone" ON course_bytes
    FOR SELECT USING (true);

-- Admin/Editor policies for course bytes management
CREATE POLICY "Admins can manage all course bytes" ON course_bytes
    FOR ALL USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Editors can manage all course bytes" ON course_bytes
    FOR ALL USING (auth.jwt() ->> 'role' = 'editor');

-- Enable RLS on byte table
ALTER TABLE byte ENABLE ROW LEVEL SECURITY;

-- Public read access for non-premium content
CREATE POLICY "Public bytes are viewable by everyone" ON byte
    FOR SELECT USING (is_premium = false);

-- Premium content requires authentication
CREATE POLICY "Premium bytes require authentication" ON byte
    FOR SELECT USING (
        is_premium = true AND auth.role() = 'authenticated'
    );

-- Admin/Editor policies for content management (adjust role names as needed)
CREATE POLICY "Admins can manage all bytes" ON byte
    FOR ALL USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Editors can manage all bytes" ON byte
    FOR ALL USING (auth.jwt() ->> 'role' = 'editor');

-- Enable RLS on saved_bytes table
ALTER TABLE saved_bytes ENABLE ROW LEVEL SECURITY;

-- Users can only see and manage their own saved bytes
CREATE POLICY "Users can view own saved bytes" ON saved_bytes
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can save bytes" ON saved_bytes
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can unsave bytes" ON saved_bytes
    FOR DELETE USING (auth.uid() = user_id);

-- Enable RLS on course_byte_progress table
ALTER TABLE course_byte_progress ENABLE ROW LEVEL SECURITY;

-- Users can only see and manage their own course progress
CREATE POLICY "Users can view own course progress" ON course_byte_progress
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own course progress" ON course_byte_progress
    FOR ALL USING (auth.uid() = user_id);

-- Enable RLS on byte_progress table
ALTER TABLE byte_progress ENABLE ROW LEVEL SECURITY;

-- Users can only see and manage their own progress
CREATE POLICY "Users can view own progress" ON byte_progress
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own progress" ON byte_progress
    FOR ALL USING (auth.uid() = user_id);

-- ================================
-- HELPFUL VIEWS
-- ================================

-- View for public API - excludes internal fields
CREATE VIEW public_bytes AS
SELECT 
    id,
    slug,
    title,
    description,
    content_json_url,
    is_premium,
    tags,
    published_at,
    updated_at,
    thumbnail_url,
    reading_time_minutes,
    total_blocks
FROM byte
WHERE (is_premium = false OR auth.role() = 'authenticated');

-- ================================
-- STORAGE BUCKETS SETUP
-- ================================
-- Note: Run these in Supabase Dashboard or via API

-- Create storage buckets for content and images
-- INSERT INTO storage.buckets (id, name, public) VALUES ('byte-content', 'byte-content', true);
-- INSERT INTO storage.buckets (id, name, public) VALUES ('byte-images', 'byte-images', true);

-- Storage policies for byte-content bucket
-- CREATE POLICY "Public can view content" ON storage.objects FOR SELECT USING (bucket_id = 'byte-content');
-- CREATE POLICY "Authenticated can upload content" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'byte-content' AND auth.role() = 'authenticated');

-- Storage policies for byte-images bucket  
-- CREATE POLICY "Public can view images" ON storage.objects FOR SELECT USING (bucket_id = 'byte-images');
-- CREATE POLICY "Authenticated can upload images" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'byte-images' AND auth.role() = 'authenticated');

-- ================================
-- SAMPLE DATA INSERTION
-- ================================

-- Insert sample course
INSERT INTO courses (id, title, description, thumbnail_url, is_active) VALUES
('550e8400-e29b-41d4-a716-446655440000', 'System Design Foundations', 'Learn the core concepts and principles of system design', 'system-design.png', true);

-- Insert sample units for the course
INSERT INTO units (id, course_id, title, unit_order) VALUES
('550e8400-e29b-41d4-a716-446655440100', '550e8400-e29b-41d4-a716-446655440000', 'System Design Basics', 0),
('550e8400-e29b-41d4-a716-446655440101', '550e8400-e29b-41d4-a716-446655440000', 'Databases & Storage', 1),
('550e8400-e29b-41d4-a716-446655440102', '550e8400-e29b-41d4-a716-446655440000', 'Communication Patterns', 2);

-- Insert sample course bytes
INSERT INTO course_bytes (id, unit_id, title, content_json_url, total_blocks, byte_order) VALUES
-- System Design Basics unit
('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440100', 'What is System Design?', 'what_is_system_design.json', 5, 0),
('550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440100', 'Scalability Fundamentals', 'scalability_fundamentals.json', 7, 1),
('550e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440100', 'Load Balancing', 'load_balancing.json', 8, 2),
('550e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440100', 'Caching Strategies', 'caching_strategies.json', 9, 3),

-- Databases & Storage unit
('550e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440101', 'SQL vs NoSQL', 'sql_vs_nosql.json', 10, 0),
('550e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440101', 'Database Sharding', 'database_sharding.json', 12, 1),
('550e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440101', 'ACID Properties', 'acid_properties.json', 8, 2),

-- Communication Patterns unit
('550e8400-e29b-41d4-a716-446655440008', '550e8400-e29b-41d4-a716-446655440102', 'REST vs GraphQL', 'rest_vs_graphql.json', 11, 0),
('550e8400-e29b-41d4-a716-446655440009', '550e8400-e29b-41d4-a716-446655440102', 'Message Queues', 'message_queues.json', 9, 1);

-- Insert sample weekly bytes (existing ones)
INSERT INTO byte (id, slug, title, description, content_json_url, is_premium, tags, published_at, thumbnail_url, reading_time_minutes, total_blocks) VALUES
('550e8400-e29b-41d4-a716-446655440010', 'ai-bias-social-good', 'Understanding the Role of Bias in AI and ML - AI for Social Good', 'Learn about AI bias and its impact on society', 'ai_bias_content.json', false, ARRAY['ai', 'ml', 'ethics', 'beginner'], '2025-01-15T10:00:00Z', 'three.png', 6, 5),
('550e8400-e29b-41d4-a716-446655440011', 'kernel-app-guide', 'How to use the Kernel App to Learn AI', 'Complete guide to using the Kernel app effectively', 'kernel_guide_content.json', true, ARRAY['kernel', 'tutorial', 'beginner'], '2024-01-15T10:00:00Z', 'four.png', 4, 3),
('550e8400-e29b-41d4-a716-446655440012', 'flutter-basics', 'Flutter Basics', 'Learn the fundamentals of Flutter development with hands-on examples', 'flutter_basics_content.json', false, ARRAY['flutter', 'basics', 'beginner'], '2025-08-15T10:00:00Z', 'five.png', 3, 4),
('550e8400-e29b-41d4-a716-446655440013', 'database-real-world', 'Understanding databases and how to use them in real world applications', 'Real-world database usage patterns and best practices', 'database_guide_content.json', false, ARRAY['database', 'sql', 'backend', 'intermediate'], '2025-07-15T10:00:00Z', 'six.png', 8, 7);

-- ================================
-- USEFUL QUERIES FOR TESTING
-- ================================

-- Get all bytes ordered by publication date
-- SELECT * FROM byte ORDER BY published_at DESC;

-- Get all public bytes (via view)
-- SELECT * FROM public_bytes ORDER BY published_at DESC;

-- Get all free bytes
-- SELECT * FROM byte WHERE is_premium = false ORDER BY published_at DESC;

-- Search bytes by tags
-- SELECT * FROM byte WHERE tags && ARRAY['flutter', 'beginner'];

-- Get bytes with specific reading time range
-- SELECT * FROM byte WHERE reading_time_minutes BETWEEN 3 AND 10;

-- Search content summary (if you store searchable metadata)
-- SELECT * FROM byte WHERE content_summary @> '{"element_types": ["code"]}';

-- ================================
-- MIGRATION NOTES
-- ================================

-- 1. Upload your existing JSON content files to 'byte-content' bucket
-- 2. Upload thumbnail images to 'byte-images' bucket  
-- 3. Update the URLs in the sample data above with your actual Supabase URLs
-- 4. Your Dart models can remain mostly unchanged - just update the URLs
