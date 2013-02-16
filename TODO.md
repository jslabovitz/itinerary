
  - create gem
    - bin
      - main script
      - sub-scripts for tools
    - lib
      - library modules
    - commit to private github repo
    - get oauth token for private repo
        http://stackoverflow.com/questions/13137996/heroku-pull-private-github-repository

  - move cache to ~?

  - move entries, route, etc. to johnlabovitz.com source

  - add contact metadata?
    - date/method/description

  - add status
    - contacted, to-visit, visited

  - write web app
    - in simple Rack module, hosted at johnlabovitz.com (Heroku)
    - sync via normal git update to site
    - able to access via laptop & phone
    - query:
      - by flags
      - by location
      - by name
    - simple link to map
      - resource to generate KML
        - mode
          - public info only
          - all info
        - colorize placemark icons:
          - visited
          - to visit (by flag or date)
          - unvisited
          - cluster by region?
              http://www.google.ca/earth/outreach/tutorials/region.html
              https://developers.google.com/kml/documentation/regions
        - route
      - redirects to use Google Maps with URL to KML (and new UUID to avoid caching)