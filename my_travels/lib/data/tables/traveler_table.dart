abstract final class TravelerTable{
    static const String tableName = 'Traveler';
    static const String travelerId = 'travelerId';
    static const String name = 'name';
    static const String age = 'age';
    static const String photoPath = 'photoPath';

    static const String createTable =
        '''
        CREATE TABLE $tableName(
            $travelerId INTEGER PRIMARY KEY AUTOINCREMENT,
            $name TEXT NOT NULL,
            $age INTEGER,
            $photoPath TEXT
        );
        ''';
}