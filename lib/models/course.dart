class Course {
  final String id;
  final String title;
  final String description;
  final String instructorId;
  final String? instructorName;
  final String? instructorEmail;
  final CourseCategory category;
  final TargetAudience targetAudience;
  final List<String> healthConditions;
  final CourseDifficulty? difficulty;
  final int? duration; // hours
  final List<CourseModule> modules;
  final String? thumbnail;
  final bool isPublished;
  final DateTime? publishedAt;
  final int enrollmentCount;
  final CourseRating rating;
  final DateTime createdAt;
  final DateTime updatedAt;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.instructorId,
    this.instructorName,
    this.instructorEmail,
    required this.category,
    required this.targetAudience,
    this.healthConditions = const [],
    this.difficulty,
    this.duration,
    this.modules = const [],
    this.thumbnail,
    this.isPublished = false,
    this.publishedAt,
    this.enrollmentCount = 0,
    required this.rating,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    // Handle instructor field (can be ObjectId string or populated object)
    String instructorId;
    String? instructorName;
    String? instructorEmail;

    if (json['instructor'] is String) {
      instructorId = json['instructor'];
    } else if (json['instructor'] is Map) {
      final instructor = json['instructor'] as Map<String, dynamic>;
      instructorId = instructor['_id'] ?? instructor['id'] ?? '';
      instructorName = instructor['name'];
      instructorEmail = instructor['email'];
    } else {
      instructorId = '';
    }

    return Course(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      instructorId: instructorId,
      instructorName: instructorName,
      instructorEmail: instructorEmail,
      category: CourseCategoryExtension.fromString(
        json['category'] ?? 'HealthProgram',
      ),
      targetAudience: TargetAudienceExtension.fromString(
        json['targetAudience'] ?? 'Patient',
      ),
      healthConditions:
          (json['healthConditions'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      difficulty: json['difficulty'] != null
          ? CourseDifficultyExtension.fromString(json['difficulty'])
          : null,
      duration: json['duration'],
      modules:
          (json['modules'] as List?)
              ?.map((m) => CourseModule.fromJson(m))
              .toList() ??
          [],
      thumbnail: json['thumbnail'],
      isPublished: json['isPublished'] ?? false,
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'])
          : null,
      enrollmentCount: json['enrollmentCount'] ?? 0,
      rating: CourseRating.fromJson(json['rating'] ?? {}),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category.value,
      'targetAudience': targetAudience.value,
      'healthConditions': healthConditions,
      if (difficulty != null) 'difficulty': difficulty!.value,
      if (duration != null) 'duration': duration,
      'modules': modules.map((m) => m.toJson()).toList(),
      if (thumbnail != null) 'thumbnail': thumbnail,
    };
  }
}

class CourseModule {
  final String? id;
  final String title;
  final String description;
  final int order;
  final List<Lesson> lessons;
  final Quiz? quiz;

  CourseModule({
    this.id,
    required this.title,
    required this.description,
    required this.order,
    this.lessons = const [],
    this.quiz,
  });

  factory CourseModule.fromJson(Map<String, dynamic> json) {
    return CourseModule(
      id: json['_id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      order: json['order'] ?? 0,
      lessons:
          (json['lessons'] as List?)?.map((l) => Lesson.fromJson(l)).toList() ??
          [],
      quiz: json['quiz'] != null ? Quiz.fromJson(json['quiz']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'order': order,
      'lessons': lessons.map((l) => l.toJson()).toList(),
      if (quiz != null) 'quiz': quiz!.toJson(),
    };
  }
}

class Lesson {
  final String? id;
  final String title;
  final String content;
  final String? videoUrl;
  final int? duration; // minutes
  final int order;
  final List<LessonResource> resources;

  Lesson({
    this.id,
    required this.title,
    required this.content,
    this.videoUrl,
    this.duration,
    required this.order,
    this.resources = const [],
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['_id'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      videoUrl: json['videoUrl'],
      duration: json['duration'],
      order: json['order'] ?? 0,
      resources:
          (json['resources'] as List?)
              ?.map((r) => LessonResource.fromJson(r))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      if (videoUrl != null) 'videoUrl': videoUrl,
      if (duration != null) 'duration': duration,
      'order': order,
      'resources': resources.map((r) => r.toJson()).toList(),
    };
  }
}

class LessonResource {
  final String title;
  final String url;
  final String type;

  LessonResource({required this.title, required this.url, required this.type});

  factory LessonResource.fromJson(Map<String, dynamic> json) {
    return LessonResource(
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'url': url, 'type': type};
  }
}

class Quiz {
  final List<QuizQuestion> questions;
  final int passingScore;

  Quiz({required this.questions, required this.passingScore});

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      questions:
          (json['questions'] as List?)
              ?.map((q) => QuizQuestion.fromJson(q))
              .toList() ??
          [],
      passingScore: json['passingScore'] ?? 70,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questions': questions.map((q) => q.toJson()).toList(),
      'passingScore': passingScore,
    };
  }
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String? explanation;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'] ?? '',
      options:
          (json['options'] as List?)?.map((o) => o.toString()).toList() ?? [],
      correctAnswer: json['correctAnswer'] ?? 0,
      explanation: json['explanation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      if (explanation != null) 'explanation': explanation,
    };
  }
}

class CourseRating {
  final double average;
  final int count;

  CourseRating({this.average = 0.0, this.count = 0});

  factory CourseRating.fromJson(Map<String, dynamic> json) {
    return CourseRating(
      average: (json['average'] ?? 0).toDouble(),
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'average': average, 'count': count};
  }
}

enum CourseCategory { healthProgram, professionalCourse }

extension CourseCategoryExtension on CourseCategory {
  String get value {
    switch (this) {
      case CourseCategory.healthProgram:
        return 'HealthProgram';
      case CourseCategory.professionalCourse:
        return 'ProfessionalCourse';
    }
  }

  String get displayName {
    switch (this) {
      case CourseCategory.healthProgram:
        return 'Health Program';
      case CourseCategory.professionalCourse:
        return 'Professional Course';
    }
  }

  static CourseCategory fromString(String value) {
    switch (value) {
      case 'HealthProgram':
        return CourseCategory.healthProgram;
      case 'ProfessionalCourse':
        return CourseCategory.professionalCourse;
      default:
        return CourseCategory.healthProgram;
    }
  }
}

enum TargetAudience {
  patient,
  doctor,
  laboratory,
  pharmacy,
  student,
  instructor,
  both,
  all,
}

extension TargetAudienceExtension on TargetAudience {
  String get value {
    switch (this) {
      case TargetAudience.patient:
        return 'Patient';
      case TargetAudience.doctor:
        return 'Doctor';
      case TargetAudience.laboratory:
        return 'Laboratory';
      case TargetAudience.pharmacy:
        return 'Pharmacy';
      case TargetAudience.student:
        return 'Student';
      case TargetAudience.instructor:
        return 'Instructor';
      case TargetAudience.both:
        return 'Both';
      case TargetAudience.all:
        return 'All';
    }
  }

  String get displayName {
    switch (this) {
      case TargetAudience.patient:
        return 'Patients';
      case TargetAudience.doctor:
        return 'Doctors';
      case TargetAudience.laboratory:
        return 'Laboratories';
      case TargetAudience.pharmacy:
        return 'Pharmacies';
      case TargetAudience.student:
        return 'Students';
      case TargetAudience.instructor:
        return 'Instructors';
      case TargetAudience.both:
        return 'Both';
      case TargetAudience.all:
        return 'All';
    }
  }

  static TargetAudience fromString(String value) {
    switch (value) {
      case 'Patient':
        return TargetAudience.patient;
      case 'Doctor':
        return TargetAudience.doctor;
      case 'Laboratory':
        return TargetAudience.laboratory;
      case 'Pharmacy':
        return TargetAudience.pharmacy;
      case 'Student':
        return TargetAudience.student;
      case 'Instructor':
        return TargetAudience.instructor;
      case 'Both':
        return TargetAudience.both;
      case 'All':
        return TargetAudience.all;
      default:
        return TargetAudience.patient;
    }
  }
}

enum CourseDifficulty { beginner, intermediate, advanced }

extension CourseDifficultyExtension on CourseDifficulty {
  String get value {
    switch (this) {
      case CourseDifficulty.beginner:
        return 'Beginner';
      case CourseDifficulty.intermediate:
        return 'Intermediate';
      case CourseDifficulty.advanced:
        return 'Advanced';
    }
  }

  String get displayName {
    switch (this) {
      case CourseDifficulty.beginner:
        return 'Beginner';
      case CourseDifficulty.intermediate:
        return 'Intermediate';
      case CourseDifficulty.advanced:
        return 'Advanced';
    }
  }

  static CourseDifficulty fromString(String value) {
    switch (value) {
      case 'Beginner':
        return CourseDifficulty.beginner;
      case 'Intermediate':
        return CourseDifficulty.intermediate;
      case 'Advanced':
        return CourseDifficulty.advanced;
      default:
        return CourseDifficulty.beginner;
    }
  }
}
