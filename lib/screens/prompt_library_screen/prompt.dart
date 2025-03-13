class Prompt {
  final String id;
  final String title;
  final String description;
  final List<String> categories;
  final bool isPublic;
  final String content;
  final int usageCount;
  bool isFavorite;

  Prompt({
    required this.id,
    required this.title,
    required this.description,
    required this.categories,
    required this.isPublic,
    required this.content,
    this.usageCount = 0,
    this.isFavorite = false,
  });
}

// Sample data
List<Prompt> samplePrompts = [
  Prompt(
    id: '1',
    title: 'Grammar corrector',
    description: 'Improve your spelling and grammar by correcting errors in your writing.',
    categories: ['Writing', 'Education'],
    isPublic: true,
    content: 'Please review the following text and correct any grammatical or spelling errors while preserving the original meaning: [YOUR TEXT HERE]',
  ),
  Prompt(
    id: '2',
    title: 'Learn Code FAST!',
    description: 'Teach you the code with the most understandable knowledge.',
    categories: ['Coding', 'Education'],
    isPublic: true,
    content: 'Explain the following programming concept in simple terms with examples that a beginner would understand: [CONCEPT]',
  ),
  Prompt(
    id: '3',
    title: 'Story generator',
    description: 'Write your own beautiful story.',
    categories: ['Writing', 'Fun'],
    isPublic: true,
    content: 'Create a short story about [THEME] with the following elements: [ELEMENTS]. The story should be engaging and have a clear beginning, middle, and end.',
  ),
  Prompt(
    id: '4',
    title: 'Essay improver',
    description: 'Improve your content\'s effectiveness with ease.',
    categories: ['Writing', 'Education'],
    isPublic: true,
    content: 'Please review and enhance the following essay to improve its clarity, structure, and persuasiveness while maintaining the original argument: [YOUR ESSAY]',
  ),
  Prompt(
    id: '5',
    title: 'Pro tips generator',
    description: 'Get perfect tips and advice tailored to your field with this prompt!',
    categories: ['Productivity', 'Career'],
    isPublic: true,
    content: 'Provide 5 professional tips for someone working in [FIELD/INDUSTRY] who wants to improve their [SPECIFIC SKILL/AREA].',
  ),
  Prompt(
    id: '6',
    title: 'Resume Editing',
    description: 'Provide suggestions and advice to improve your resume.',
    categories: ['Career', 'Writing'],
    isPublic: true,
    content: 'Review the following resume and provide specific suggestions to improve its impact, highlighting relevant skills and experiences for a [JOB TITLE] position: [RESUME TEXT]',
  ),
  Prompt(
    id: '7',
    title: 'SEO Content Optimizer',
    description: 'Optimize your content for search engines while maintaining readability.',
    categories: ['SEO', 'Marketing', 'Writing'],
    isPublic: true,
    content: 'Optimize the following content for SEO targeting the keyword "[KEYWORD]" while maintaining natural readability and engagement: [CONTENT]',
  ),
  Prompt(
    id: '8',
    title: 'Business Plan Creator',
    description: 'Generate a structured business plan outline for your startup idea.',
    categories: ['Business', 'Productivity'],
    isPublic: true,
    content: 'Create a detailed business plan outline for a [TYPE OF BUSINESS] startup, including sections for executive summary, market analysis, competitive advantage, financial projections, and marketing strategy.',
  ),
  Prompt(
    id: '9',
    title: 'Chatbot Personality',
    description: 'Design a unique personality for your customer service chatbot.',
    categories: ['Chatbot', 'Business'],
    isPublic: false,
    content: 'Design a conversational personality for a customer service chatbot for a [TYPE OF BUSINESS]. Include tone of voice, common phrases, and how it should handle difficult customers.',
  ),
];

// Get all unique categories from the sample prompts
List<String> getAllCategories() {
  Set<String> categories = {};
  for (var prompt in samplePrompts) {
    categories.addAll(prompt.categories);
  }
  return ['All', ...categories.toList()..sort()];
}

