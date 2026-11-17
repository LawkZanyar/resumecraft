/// Sample content for AI screens. Shown with a "Sample" label.
library;

/// Made-up spoken description used to demo voice-to-resume.
const sampleTranscript =
    'I worked at a small marketing company for two years and managed their '
    'social media accounts. I also studied business administration at Example '
    'University. I am good at Canva, copywriting and customer service.';

/// Question bank for the interview simulator: type -> templates.
/// `{role}` is replaced with the job title.
const sampleGeneralQuestions = [
  'Tell me about yourself and why you are interested in the {role} role.',
  'What do you know about the kind of work a {role} does day to day?',
  'Where would you like your career to be in three years?',
  'Why should we choose you for this {role} position?',
];

const sampleBehavioralQuestions = [
  'Describe a time you had to meet a tight deadline. What did you do?',
  'Tell me about a disagreement with a teammate and how you handled it.',
  'Give an example of a mistake you made and what you learned from it.',
  'Describe a situation where you had to learn something new quickly.',
];

const sampleTechnicalQuestions = <String, List<String>>{
  'General': [
    'Which tools do you use most in your work, and why?',
    'How do you check the quality of your work before you hand it in?',
  ],
  'Software and IT': [
    'How would you find the cause of a bug that only happens on some phones?',
    'Explain how you would structure a small app so it is easy to test.',
  ],
  'Design': [
    'Walk me through how you would test a new screen design with users.',
    'How do you make sure a design is accessible?',
  ],
  'Marketing and sales': [
    'How would you measure whether a social media campaign worked?',
    'How do you decide which audience to target for a new product?',
  ],
  'Business and admin': [
    'How do you prioritize tasks when several managers need things at once?',
    'Which spreadsheet features do you use to organize data?',
  ],
  'Healthcare': [
    'How do you make sure patient information stays private?',
    'Describe how you would calmly handle an upset patient.',
  ],
};
