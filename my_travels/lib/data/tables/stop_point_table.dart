const stopPointTableName = 'StopPoint';
const stopPointTableId = 'id';
const stopPointTableTravelId = 'travel_id';
const stopPointTableStopOrder = 'stop_order';
const stopPointTableLocationName = 'location_name';
const stopPointTableLatitude = 'latitude';
const stopPointTableLongitude = 'longitude';
const stopPointTableDescription = 'description';
const stopPointTableArrivalDate = 'arrival_date';
const stopPointTableDepartureDate = 'departure_date';

const createStopPointTable =
    '''
  CREATE TABLE $stopPointTableName(
    $stopPointTableId INTEGER PRIMARY KEY AUTOINCREMENT,
    $stopPointTableTravelId INTEGER NOT NULL,
    $stopPointTableStopOrder INTEGER,
    $stopPointTableLocationName TEXT NOT NULL,
    $stopPointTableLatitude REAL,
    $stopPointTableLongitude REAL,
    $stopPointTableDescription TEXT,
    $stopPointTableArrivalDate DATETIME,
    $stopPointTableDepartureDate DATETIME,
    FOREIGN KEY ($stopPointTableTravelId) REFERENCES Travel(id)
  );
''';
