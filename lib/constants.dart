class AppConstants {
  static const appName = 'ScoutX';
  static const tagline = 'Find your next player. Get scouted.';

  static const roles = ['player', 'coach', 'viewer'];

  static const sportList = [
    'Football',
    'Basketball',
    'Cricket',
    'Volleyball',
    'Tennis',
    'Badminton',
    'Other',
  ];

  static const positionsBySport = {
    'Football': ['Goalkeeper', 'Defender', 'Midfielder', 'Winger', 'Striker'],
    'Basketball': [
      'Point Guard',
      'Shooting Guard',
      'Small Forward',
      'Power Forward',
      'Center',
    ],
    'Cricket': ['Batsman', 'Bowler', 'All-Rounder', 'Wicketkeeper'],
    'Volleyball': [
      'Setter',
      'Libero',
      'Outside Hitter',
      'Opposite Hitter',
      'Middle Blocker',
    ],
    'Tennis': ['Singles', 'Doubles'],
    'Badminton': ['Singles', 'Doubles', 'Mixed Doubles'],
    'Other': ['Any'],
  };

  static const skillLevels = ['Beginner', 'Intermediate', 'Advanced', 'Elite'];

  static const highlightTypes = [
    'Training',
    'Match',
    'Trial',
    'Competition',
    'Skills',
    'Goals',
    'Assists',
    'Defending',
    'Dribbling',
    'Fitness',
    'Practice',
    'Other',
  ];

  static const highlightTypesBySport = {
    'Football': [
      'Training',
      'Match',
      'Trial',
      'Competition',
      'Goals',
      'Assists',
      'Defending',
      'Dribbling',
      'Skills',
      'Fitness',
      'Practice',
      'Other',
    ],
    'Basketball': [
      'Training',
      'Match',
      'Trial',
      'Competition',
      'Dunk',
      'Three-Pointer',
      'Steal',
      'Block',
      'Assist',
      'Rebound',
      'Skills',
      'Fitness',
      'Practice',
      'Other',
    ],
    'Cricket': [
      'Training',
      'Match',
      'Trial',
      'Competition',
      'Batting',
      'Bowling',
      'Fielding',
      'Catching',
      'Wicketkeeping',
      'Sixes',
      'Fours',
      'Wickets',
      'Skills',
      'Fitness',
      'Practice',
      'Other',
    ],
    'Volleyball': [
      'Training',
      'Match',
      'Trial',
      'Competition',
      'Spike',
      'Block',
      'Serve',
      'Dig',
      'Set',
      'Skills',
      'Fitness',
      'Practice',
      'Other',
    ],
    'Tennis': [
      'Training',
      'Match',
      'Trial',
      'Competition',
      'Serve',
      'Forehand',
      'Backhand',
      'Volley',
      'Rally',
      'Skills',
      'Fitness',
      'Practice',
      'Other',
    ],
    'Badminton': [
      'Training',
      'Match',
      'Trial',
      'Competition',
      'Smash',
      'Drop Shot',
      'Clear',
      'Net Shot',
      'Rally',
      'Skills',
      'Fitness',
      'Practice',
      'Other',
    ],
    'Other': [
      'Training',
      'Match',
      'Trial',
      'Competition',
      'Skills',
      'Fitness',
      'Practice',
      'Other',
    ],
  };

  static const ageGroups = [
    'U13',
    'U15',
    'U17',
    'U18',
    'U21',
    'Senior',
    'Masters',
  ];

  static const skillLibrary = <String, List<String>>{
    'Football': [
      'Dribbling', 'Passing', 'Shooting', 'Finishing', 'Crossing',
      'Tackling', 'Interception', 'Ball Control', 'Speed', 'Agility',
      'Heading', 'Free Kick', 'Penalty', '1v1', 'Pressing',
      'Positioning', 'Vision', 'Through Ball', 'Long Ball', 'Defending',
      'Set Pieces', 'Aerial Duels',
    ],
    'Cricket': [
      'Batting', 'Bowling', 'Pace', 'Spin', 'Swing',
      'Yorker', 'Bouncer', 'Fielding', 'Catching', 'Throwing',
      'Cover Drive', 'Pull Shot', 'Cut Shot', 'Sweep', 'Reverse Sweep',
      'Off Spin', 'Leg Spin', 'Googly', 'Doosra', 'Slower Ball',
    ],
    'Basketball': [
      'Dribbling', 'Passing', 'Shooting', 'Three Point', 'Layup',
      'Dunk', 'Rebound', 'Steal', 'Block', 'Cross-over',
      'Fadeaway', 'Pick and Roll', 'Post Move', 'Free Throw', 'Alley Oop',
    ],
    'Volleyball': [
      'Serving', 'Spiking', 'Blocking', 'Setting', 'Diving',
      'Receiving', 'Libero Play', 'Quick Attack', 'Back Row Attack',
    ],
    'Tennis': [
      'Forehand', 'Backhand', 'Serve', 'Volley', 'Drop Shot',
      'Lob', 'Cross-court', 'Down the Line', 'Slice', 'Topspin',
    ],
    'Badminton': [
      'Smash', 'Drop Shot', 'Clear', 'Net Play', 'Drive',
      'Backhand', 'Footwork', 'Deception', 'Cross-court', 'Toss',
    ],
    'Other': [],
  };

  static const positionAliases = <String, String>{
    'gk': 'Goalkeeper',
    'def': 'Defender',
    'mid': 'Midfielder',
    'fwd': 'Striker',
    'st': 'Striker',
    'cb': 'Defender',
    'lb': 'Defender',
    'rb': 'Defender',
    'cm': 'Midfielder',
    'cam': 'Midfielder',
    'cdm': 'Midfielder',
    'lw': 'Winger',
    'rw': 'Winger',
  };

  static const locationAliases = <String, String>{
    'bengaluru': 'bangalore',
    'bombay': 'mumbai',
    'calcutta': 'kolkata',
    'madras': 'chennai',
  };

  static const popularCities = [
    'Bangalore',
    'Mumbai',
    'Delhi',
    'Chennai',
    'Kolkata',
    'Hyderabad',
    'Pune',
    'Ahmedabad',
    'Jaipur',
    'Lucknow',
    'Bengaluru',
    'Kochi',
    'Chandigarh',
    'Bhopal',
    'Indore',
    'Nagpur',
    'Surat',
    'Visakhapatnam',
    'Coimbatore',
    'Thiruvananthapuram',
  ];
}

class AppPaths {
  static const clips = 'clips';
  static const users = 'users';
  static const likes = 'likes';
  static const trials = 'trials';
  static const trialApplications = 'trial_applications';
  static const openings = 'openings';
  static const conversations = 'conversations';
  static const messages = 'messages';
  static const clipComments = 'clip_comments';
  static const savedClips = 'saved_clips';
  static const follows = 'follows';
  static const reports = 'reports';
}
