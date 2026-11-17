import '../../domain/domain.dart';

/// Made-up resumes for demos and tests. People and companies are fictional,
/// and every record has `isSample: true` so the UI labels it "Sample".
List<Resume> sampleResumes(String userId, DateTime now) => [
      Resume(
        resumeId: 'sample-resume-designer-$userId',
        userId: userId,
        title: 'Product Designer (Sample)',
        isSample: true,
        templateId: 'modern',
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(hours: 2)),
        personalInformation: const PersonalInfo(
          fullName: 'Sara Ahmed',
          jobTitle: 'Product Designer',
          email: 'sara.ahmed@example.com',
          phone: '+964 750 000 0001',
          location: 'Erbil, Iraq',
          website: 'example.com/sara',
          summary: 'Product designer with three years of experience designing '
              'mobile apps for small businesses.',
        ),
        experience: const [
          Experience(
            id: 'exp-1',
            company: 'Northwind Studio',
            role: 'Product Designer',
            location: 'Erbil',
            startDate: 'Mar 2023',
            isCurrent: true,
            description: 'Designed the booking flow for a clinic app.\n'
                'Ran usability tests with customers.',
          ),
          Experience(
            id: 'exp-2',
            company: 'Bluepeak Apps',
            role: 'Junior UI Designer',
            location: 'Sulaymaniyah',
            startDate: 'Jun 2021',
            endDate: 'Feb 2023',
            description: 'made screens for the shop app and fixed design bugs',
          ),
        ],
        education: const [
          Education(
            id: 'edu-1',
            institution: 'Example University of Design',
            degree: 'BSc',
            field: 'Software Engineering',
            startDate: '2017',
            endDate: '2021',
          ),
        ],
        skills: const ['Figma', 'User research', 'Prototyping', 'Design systems'],
        projects: const [
          ResumeProject(
            id: 'proj-1',
            name: 'Clinic booking redesign',
            description: 'Redesigned appointment booking for a fictional clinic.',
          ),
        ],
        languages: const [
          LanguageSkill(id: 'lang-1', name: 'Kurdish', level: 'Native'),
          LanguageSkill(id: 'lang-2', name: 'English', level: 'Fluent'),
        ],
        aiScore: 74,
      ),
      Resume(
        resumeId: 'sample-resume-developer-$userId',
        userId: userId,
        title: 'Flutter Developer (Sample)',
        isSample: true,
        templateId: 'classic',
        createdAt: now.subtract(const Duration(days: 9)),
        updatedAt: now.subtract(const Duration(days: 1)),
        personalInformation: const PersonalInfo(
          fullName: 'Omar Khalid',
          jobTitle: 'Junior Flutter Developer',
          email: 'omar.khalid@example.com',
          location: 'Duhok, Iraq',
        ),
        experience: const [
          Experience(
            id: 'exp-1',
            company: 'Cedar Labs',
            role: 'Mobile Developer Intern',
            startDate: 'Jul 2025',
            endDate: 'Sep 2025',
            description: 'worked on the app and helped the team',
          ),
        ],
        education: const [
          Education(
            id: 'edu-1',
            institution: 'Example Polytechnic',
            degree: 'BSc',
            field: 'Computer Science',
            startDate: '2022',
            endDate: '2026',
          ),
        ],
        skills: const ['Dart', 'Flutter', 'Git'],
        customization: const ResumeCustomization(
          accentColor: 0xFF24B8A0,
          font: ResumeFont.serif,
        ),
      ),
    ];
