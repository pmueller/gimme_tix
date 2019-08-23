# GimmeTix - A simple realtime ticket queue

I wanted to try building a realtime webapp with [Phoenix](https://phoenixframework.org/), so I decided to build a simple system that can be used to queue people who want to buy tickets online for an event.

You can see it running in production here: [https://gimmetix.herokuapp.com](https://gimmetix.herokuapp.com). To see it in action, open the 'buy tickets' page for an event in multiple browser tabs/windows

#### Note: Don't try to use this code for anything real. It has a button that lets people skip in line because there is no time limit on the person at the front of the line, and has at least one possible race condition

### What it does
- When a user clicks the link for an event they are placed into the event's queue
- The user has a position in line, and the first person in line has an offer to buy a ticket
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
