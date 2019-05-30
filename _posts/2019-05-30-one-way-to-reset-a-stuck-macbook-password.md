---
title: "One Way to Reset a Macbook Password"
tags: ['it']
date: 2019-05-30
layout: 'post'
---

Weird problem today: macbook was accepting my password to decrypt disk, but not
accepting it for user account login. This started happening after adding lock
button to my touch bar. I can't see how that's related, but that was the last
thing I did so maybe relevant!? Tried the new button, locked my computer,
couldn't login again.

Things that didn't work:

* Reset password using recovery key. (I think this only resets the disk password?)
* Recovery mode (hold `Command+R` on boot), `resetpassword` in terminal. Weirdly
  this did change the password hint for the account, but the new password was
  still not accepted.
* Reseting PRAM (hold `Command+Option+P+R` on boot).

What did work (thanks to Apple care phone support, very good experience):

1. Boot into recovery mode (hold `Command+R` on boot).
2. Open `Disk Utilities` and mount `Macintosh HD`.
3. Open `Terminal` and `rm /Volumes/Macintosh\ HD/var/db/.AppleSetupDone`.
4. Reboot computer, enter disk password, then go through new computer setup
   again.
5. When prompted, create a new `Temp Admin` user account. You'll end up logged
   in as this new temp admin.
6. Via System Settings, User & Accounts, reset password of your original account.
7. Log out and re-login as your original account (hooray!)
8. Delete the newly created `Temp Admin` account.
