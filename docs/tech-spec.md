# 1. Requirements

1. View all user click stream events
2. View Top web pages viewed by users
3. Daily Active Users
4. Average session length
5. New Users

# 2. Input Schema
This is the schema sent from the clients. 

## 2.1 Event Schema

```
{
    eventId: uuid, // uuid for the event
    event: string, // Name of the event
    deviceId: uuid, // client generated device id.
    userId: uuid, // uuid of the anonymous user. This can be attached to a userProfileId. 
    properties: {, // Used to pass custom properties for an event.
        platform: string // ios, android or web
        os: string // name of the os
        osVersion: string // version of the os
        browser: string // browser Name
        browserVersion: string // browser version
        deviceType: string // type of device
        pathName: string // derived from the url
        },
    customProperties: json, // add all custom properties in this json.
    timestamp: time, // time when the event was produced. microsecond precision.
}
```

Note - Amplitude and posthog captures more information like screen width, viewport etc. We are limiting
to basic properties for this exercise.

## 2.2 User profile Schema
User profile can be set using `user_profile` events. This is the schema set from the client or from the admin portal.

Schema
```
{   
    profileId: uuid // uuid of the profile
    name: string // name of the user
    email: string // email of the user
    phone: string // phone of the user
    firstSeen: time // timestamp at millisecond precisoin
}
```

Note - Amplitude and posthog captures more information like initial url, referer etc. We are limiting
to basic properties for this exercise.

# 3. Features
## 3.1 Mapping Anonymous users to user profiles
### Problem statement:
1. When a user lands on the website, the identify is now known until he/she log in. We need a way to associate the events
with a known user.
2. We would like to track the user's actions across devices since the behaviour could be different. Ex - shopping experience
on amazon's mobile app is much different from the web app. 

### Solution
1. Create a device id on the client. 
   1. Mobile apps could give consistent device id while 
   2. Device id for web apps vary from browser to browser. Device id is the same in new tabs / incognito if the cache is persisted. Cache delete issues a new device id.
2. For every device id, create an analytics id or map to existing internal user id called analyticsUserId. Each analyticsUserId has multiple mappings with multiple device ids.
3. When a user lands on a new browser, he/she will be anonymous. These events are not updated as soon as the users are logged in.
4. For queries like unique users, we will have to treat multiple analyticsUserId as one unit. This is more expensive query
  but will be required in calculating unique DAU, MAU etc.

## 3.2 Web analytics
### Problem statement
1. Ability to group events by properties. Ex - Group events by Page title to calculate frequently viewed pages.
2. Define various measurements like
   1. Unique - Unique users who triggered these events
   2. Event Totals - Total count of events
   3. Active % (out of scope) - Breaks down event as percentage triggers by each active user
   4. Average - Number of events by active users.
   5. Frequency (out of scope) - 
3. Segment users (out of scope for this project)

This data can be viewed by
1. Realtime
2. Hourly - data retention for 7 previous days
3. Daily - Data rention for 90 previous days
4. Weekly - Data rention for 54 previous weeks
5. Monthly - Data rention for 24 previous months
6. Quarterly - Data rention for 8 previous quarters


# [4. DB Schema](../docker/clickhouse/migrations.sql)