const travelTableName = 'Travel';
const travelTableId = 'id';
const travelTableTitle = 'title';
const travelTableStartDate = 'start_date';
const travelTableEndDate = 'end_date';
const travelTableVehicle = 'vehicle';
const travelTableCoverImagePath = 'cover_image_path';

const createTravelTable =
    '''
  CREATE TABLE $travelTableName(
    $travelTableId INTEGER PRIMARY KEY AUTOINCREMENT,
    $travelTableTitle TEXT NOT NULL,
    $travelTableStartDate DATE,
    $travelTableEndDate DATE,
    $travelTableVehicle TEXT,
    $travelTableCoverImagePath TEXT
  );
''';
