const commentTableName = 'Comment';
const commentTableId = 'id';
const commentTableStopPointId = 'stop_point_id';
const commentTableTravelerId = 'traveler_id';
const commentTableContent = 'content';

const createCommentTable =
    '''
  CREATE TABLE $commentTableName(
    $commentTableId INTEGER PRIMARY KEY AUTOINCREMENT,
    $commentTableStopPointId INTEGER NOT NULL,
    $commentTableTravelerId INTEGER NOT NULL,
    $commentTableContent TEXT NOT NULL,
    FOREIGN KEY ($commentTableStopPointId) REFERENCES StopPoint(id),
    FOREIGN KEY ($commentTableTravelerId) REFERENCES Traveler(id)
  );
''';
