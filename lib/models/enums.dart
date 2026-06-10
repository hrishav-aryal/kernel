// ================================
// ENUMS
// ================================

enum ContentElementType {
  heading, // Headings (h1, h2, h3, etc.)
  text, // Regular text/paragraph
  image, // Images with optional caption
  code, // Code blocks with syntax highlighting
  list, // Bullet/numbered lists
  spacer, // Spacing element
  mcq, // Multiple choice questions
  code_fill, // Code completion with fill-in-the-blanks
}

enum UserSubscriptionType { free, premium }

enum ProgressStatus { notStarted, inProgress, completed }
