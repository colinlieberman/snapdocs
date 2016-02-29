Well, this was going to be for unit tests, but the app has almost no logic; there's really nothing to test. URL & RSS parsing, YAML, JSON... it all comes from off-the shelf gems.

I supposed I could write unit tests for the AppDB api, test that reads and writes work as expected, that ids and dates and whatnot are returned as expected, but either the tests would need to talk to the database, or I'd be building mock data in a way that almost certainly would make the tests sylogistic.

