  - implement coordinate fuzzing

  - read all records at Itinerary instantiation
    - cache (using Marshal)
    - rebuild cache if new/deleted files, or files have changed

  - expand routing
    - multiple routes
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
