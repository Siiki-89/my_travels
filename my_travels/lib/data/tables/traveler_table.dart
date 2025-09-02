const travelerTableName = 'Traveler';
const travelerTableId = 'id';
const travelerTableNameColumn = 'name';
const travelerTableAge = 'age';
const travelerTablePhotoPath = 'photoPath';

const createTravelerTable =
    '''
  CREATE TABLE $travelerTableName(
      $travelerTableId INTEGER PRIMARY KEY AUTOINCREMENT,
      $travelerTableNameColumn TEXT NOT NULL,
      $travelerTableAge INTEGER,
      $travelerTablePhotoPath TEXT
  );
''';
