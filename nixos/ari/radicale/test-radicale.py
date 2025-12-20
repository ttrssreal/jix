#!/usr/bin/env python3

#
# Create a calendar, add an event and check the event added correctly.
# Needs CALDAV_USERNAME, CALDAV_URL, CALDAV_PASSWORD
#

import json
from caldav.davclient import get_davclient
from caldav.elements import dav
from random import choice
from string import ascii_lowercase
import argparse
from datetime import datetime

RANDOM_CALENDAR_NAME_LENGTH = 10
TEST_EVENT_SUMMARY = "meow meorw mrow"

def random_calendar_name():
    random_part = "".join(choice(ascii_lowercase) for i in range(RANDOM_CALENDAR_NAME_LENGTH))
    return f"test-{random_part}"

def cleanup(calendar, args):
    if args.cleanup:
        print("Cleaning up calendar")
        calendar.delete()
        print("Cleaning up calendar")

def create_calendar(principal, name):
    return principal.make_calendar(name=name)

def do_tests(calendar, args):
    print("Adding an event")
    event = calendar.save_event(
        dtstart=datetime(2026, 10, 17, 6),
        dtend=datetime(2026, 10, 18, 1),
        summary=TEST_EVENT_SUMMARY,
    )
    print("Added an event")

    events = calendar.events()
    assert len(events) == 1, f"added one event, but calendar has {len(events)}"

    event = events[0]
    summary = event.component.get("summary")
    assert summary == TEST_EVENT_SUMMARY, \
        f"event has summary \"{summary}\" when it should have \"{TEST_EVENT_SUMMARY}\""

def main(client, args):
    print("Connecting to the caldav server")
    principal = client.principal()
    print("Connected")

    name = random_calendar_name()

    print(f"Creating calendar \"{name}\"")
    calendar = create_calendar(principal, name)
    print(f"Created calendar \"{name}\"")

    try:
        do_tests(calendar, args)
    except Exception as e:
        print(f"Error: {e}")
        cleanup(calendar, args)
        return 1

    cleanup(calendar, args)
    return 0

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-n",
        "--no-cleanup",
        action="store_false",
        dest="cleanup",
        help="cleanup test calendar"
    )
    
    args = parser.parse_args()

    with get_davclient() as client:
        ret = main(client, args)

    exit(ret)
