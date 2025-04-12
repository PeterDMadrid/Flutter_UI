class UserModel {
  final String username;
  final String? profilePictureUrl;
  final int level;
  final bool isRight;
  final Score score;
  final Progress progress;

  UserModel({
    required this.username,
    this.profilePictureUrl,
    required this.level,
    required this.isRight,
    required this.score,
    required this.progress,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle profile picture
    String? pictureUrl;
    if (json['profile_picture'] != null && json['profile_picture'] is Map<String, dynamic>) {
      pictureUrl = json['profile_picture']['image'];
    }

    // Handle progress - check if progress_data exists first, otherwise use defaults
    Progress progressObj;
    if (json['progress_data'] != null && json['progress_data'] is Map<String, dynamic>) {
      progressObj = Progress.fromJson(json['progress_data']);
    } else {
      progressObj = Progress(
        introduction: false,
        twodigit: false,
        mathlesson: false,
      );
    }

    return UserModel(
      username: json['username'] ?? '',
      profilePictureUrl: pictureUrl,
      level: json['level'] ?? 1,
      isRight: json['is_right'] ?? true,
      score: Score.fromJson(json['user_score_profile'] ?? 
          {'recognition': 0, 'signing': 0, 'challenge_scores': []}),
      progress: progressObj,
    );
  }
}

class Score {
  final int recognition;
  final int signing;
  final List<dynamic> challengeScores;

  Score({
    required this.recognition,
    required this.signing,
    required this.challengeScores,
  });

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      recognition: json['recognition'] ?? 0,
      signing: json['signing'] ?? 0,
      challengeScores: json['challenge_scores'] ?? [],
    );
  }
}

class Progress {
  final bool introduction;
  final bool twodigit;
  final bool mathlesson;

  Progress({
    required this.introduction,
    required this.twodigit,
    required this.mathlesson,
  });

  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress(
      introduction: json['introduction'] ?? false,
      twodigit: json['twodigit'] ?? false,
      mathlesson: json['mathlesson'] ?? false,
    );
  }
}