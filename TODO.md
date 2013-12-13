  - try Github map rendering
    	https://github.com/blog/1528-there-s-a-map-for-that

  - try Mavericks MapKit
      https://developer.apple.com/library/mac/documentation/MapKit/Reference/MapKit_Framework_Reference/_index.html#//apple_ref/doc/uid/TP40008210

  - implement coordinate fuzzing
    - use new 'Geocoder::Calculations.random_point_near' method

  - read all records at Itinerary instantiation
    - cache (using Marshal)
    - rebuild cache if new/deleted files, or files have changed

  - expand routing
    - travel mode for each leg
    - date for each node

  - move briar cache to ~?

  - add contact metadata?
    - date/method/description

  - add status/flags
    - contacted, to-visit, visited

  - make interactive web app
    - query:
      - by flags
      - by location
      - by name

  - show private view of map/info, in addition to public view

  - colorize placemark icons by status

  - cluster placemarks by region to avoid clutter
      http://www.google.ca/earth/outreach/tutorials/region.html
      https://developers.google.com/kml/documentation/regions
