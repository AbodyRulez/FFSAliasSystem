# FFSAliasSystem
Objective:

We've been suffering for a good amount of time with our admin panel and commands like /whowas or /whois, in order to search for certain players by their serial so they could get punished for whatever they've done.
Hopefully, this panel will make our life easier, specially when it comes to certain situations like tracing players' ban reasons by searching for their serial in ban list in order to take the right actions, and so much more!

Features:

Auto player join information capture "works on guests as well, captures serial and all other nicknames"
Auto player change nick capture.
Search for player by serial, nickname, or IP "by clicking on Search or pressing enter button"
Adding a reason to ban/mute is obligatory now.
Offline timed ban is now available.
Controlled grid list rows* explained below
Controlled penalty periods for cleaner database and wiser admin management.
Penalty periods:
Months: 12 - 6 - 3 - 1
Days: 15 - 7 - 3 - 1
Hours: 12 - 6 - 3 - 1
Minutes: 30 - 15 - 10 - 5


Changelog: 8/29/2015
Database changed from SQLite to MySQL "Allows communicating with the database from forums in the future 'thanks to Bauss'"
Added warns system
Warns system automatically punishes players after a certain amount of warns:
- 3 days ban for 3rd warn
- 5 days ban for 4th warn
- 7 days ban for 5th warn
- 30 days ban for 10th warn
Added warn / unwarn buttons.
Registered players are logged in Database with their forums user id "Connected element with forum account"
Fixed low resolution not showing permanent tab bug.
Fixed minor bugs.


Changelog: 8/30/2015
Added Unban tab to log players' unban date and the nickname of the responsible admin, as requested.
Fixed a major bug.


Changelog: 3/19/2016
It's been a long time since the last changelog, here are the final touches update.
Added the /alias command admin only restriction to toggle the panel's visibility.
Fixed FFS player join capture.
Fixed minor bugs.
