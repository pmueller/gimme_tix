# GimmeTix - A simple realtime ticket queue

I wanted to try building a realtime webapp with [Phoenix](https://phoenixframework.org/), so I decided to build a super MVP version of a system that can be used to queue people who want to buy tickets online for an event.

### What it does
- When a user clicks the link for an event they are placed into the event's queue
- The user has a position in line, and the first person in line has an offer to buy tickets
- When the user decides to buy a ticket or not, the queue advances and everyone else moves a spot forward
- Users can come back to their spot in line with a special URL

### What it uses
The changes happen in realtime using websockets talking to a Phoenix Channel

### Install and Run
```
# dependencies
mix deps

# migrate the db
mix ecto.migrate

# run the server
mix phx.server
```
