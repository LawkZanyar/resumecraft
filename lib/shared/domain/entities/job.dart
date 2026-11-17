import 'map_utils.dart';

/// Where a job listing came from. The UI always shows this label.
enum JobSource {
  sample('Sample'),
  jooble('Jooble');

  const JobSource(this.label);
  final String label;
}

/// `jobs` collection document, or a listing returned by the job proxy.
class Job {
  const Job({
    required this.jobId,
    required this.title,
    required this.company,
    required this.location,
    required this.source,
    this.latitude,
    this.longitude,
    this.locationIsApproximate = false,
    this.description = '',
    this.requirements = const [],
    this.applicationUrl = '',
    this.category = '',
    this.employmentType = '',
    this.salary,
    this.postedAt,
    this.isSample = false,
  });

  final String jobId;
  final String title;
  final String company;
  final String location;
  final double? latitude;
  final double? longitude;

  /// True when the position comes from city geocoding rather than the listing.
  final bool locationIsApproximate;
  final String description;
  final List<String> requirements;
  final String applicationUrl;
  final JobSource source;
  final String category;
  final String employmentType;
  final String? salary;
  final DateTime? postedAt;

  /// Sample records use fictional companies and always show a "Sample" label.
  final bool isSample;

  bool get hasPosition => latitude != null && longitude != null;

  Job copyWith({
    double? latitude,
    double? longitude,
    bool? locationIsApproximate,
  }) =>
      Job(
        jobId: jobId,
        title: title,
        company: company,
        location: location,
        source: source,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        locationIsApproximate: locationIsApproximate ?? this.locationIsApproximate,
        description: description,
        requirements: requirements,
        applicationUrl: applicationUrl,
        category: category,
        employmentType: employmentType,
        salary: salary,
        postedAt: postedAt,
        isSample: isSample,
      );

  Map<String, Object?> toMap() => {
        'jobId': jobId,
        'title': title,
        'company': company,
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
        'locationIsApproximate': locationIsApproximate,
        'description': description,
        'requirements': requirements,
        'applicationUrl': applicationUrl,
        'source': source.name,
        'category': category,
        'employmentType': employmentType,
        'salary': salary,
        'postedAt': dateToStr(postedAt),
        'isSample': isSample,
      };

  factory Job.fromMap(Map<String, Object?> m) => Job(
        jobId: str(m['jobId']),
        title: str(m['title']),
        company: str(m['company']),
        location: str(m['location']),
        latitude: doubleOrNull(m['latitude']),
        longitude: doubleOrNull(m['longitude']),
        locationIsApproximate: boolOf(m['locationIsApproximate']),
        description: str(m['description']),
        requirements: strList(m['requirements']),
        applicationUrl: str(m['applicationUrl']),
        source: enumOf(JobSource.values, m['source'], JobSource.sample),
        category: str(m['category']),
        employmentType: str(m['employmentType']),
        salary: strOrNull(m['salary']),
        postedAt: dateOrNull(m['postedAt']),
        isSample: boolOf(m['isSample']),
      );
}
