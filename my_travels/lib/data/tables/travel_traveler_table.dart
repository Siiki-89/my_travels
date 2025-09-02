const travelTravelerTableName = 'TravelTraveler';
const travelTravelerTableTravelId = 'travel_id';
const travelTravelerTableTravelerId = 'traveler_id';

const createTravelTravelerTable =
    '''
  CREATE TABLE $travelTravelerTableName(
    $travelTravelerTableTravelId INTEGER NOT NULL,
    $travelTravelerTableTravelerId INTEGER NOT NULL,
    PRIMARY KEY ($travelTravelerTableTravelId, $travelTravelerTableTravelerId),
    FOREIGN KEY ($travelTravelerTableTravelId) REFERENCES Travel(id),
    FOREIGN KEY ($travelTravelerTableTravelerId) REFERENCES Traveler(id)
  );
''';
