gpgit
=====

What
----
`gpgit` is a mail filter that encrypts an email with a public key in the user's [GnuPG] keyring.

Why
---
It partially solves the problem that no one wants to use [PGP] encryption. The email is still in the clear while in transit, but it gets encrypted before it touches your mail server's hard drive. That means mail is still vulnerable to network capture (unless [TLS] is used) and to logging on the intermediate [SMTP] servers, but not vulnerable to [authorities randomly seizing your server][Riseup server seizure], [National Security Letters]  [on your email provider][Jacob Appelbaum email seizure], or other crazy stuff like that.

How
---
`gpgit` simply reads an email from stdin, encrypts it with the key given as first argument (unless the email is already encrypted), and writes out the result to stdout. That's almost all there is to it; some other arguments are available. Run `gpgit` without arguments for details.

You need some Perl modules for this to work:

* [MIME:Tools]
* [Mail::GnuPG]

There are multiple ways to use this in your email system:
* With [Exim]: [Automatically Encrypting all Incoming Email with Exim]
* With [Dovecot]: [Encrypt specific incoming emails using Dovecot and Sieve]

encmaildir.sh
-------------
`encmaildir.sh` is a little bonus script to encrypt an existing email directory, taking care of file permissions and ownership and Dovecot indexes and everything.

Only unencrypted emails will be modified. Run `encmaildir.sh` without arguments for usage information.

Who
---
* [Mike Cardwell] for the original script ([`gpgit.pl`][gpgit.pl])
* [PunchiePets on DSLReports] and [Olivier Berger] for the [original version of `encmaildir.sh`][original version of encmaildir.sh]
* [Etienne Perot] for modifications to `encmaildir.sh`

[GnuPG]: http://www.gnupg.org/
[PGP]: https://en.wikipedia.org/wiki/Pretty_Good_Privacy
[TLS]: https://en.wikipedia.org/wiki/Transport_Layer_Security
[SMTP]: https://en.wikipedia.org/wiki/Simple_Mail_Transfer_Protocol
[Riseup server seizure]: https://www.eff.org/deeplinks/2012/04/may-firstriseup-server-seizure-fbi-overreaches-yet-again
[National security letters]: https://en.wikipedia.org/wiki/National_security_letter
[Jacob Appelbaum email seizure]: http://online.wsj.com/article/SB10001424052970203476804576613284007315072.html
[MIME:Tools]: http://search.cpan.org/perldoc?MIME%3A%3ATools
[Mail::GnuPG]: http://search.cpan.org/perldoc?Mail%3A%3AGnuPG
[Exim]: http://www.exim.org/
[Automatically Encrypting all Incoming Email with Exim]: https://grepular.com/Automatically_Encrypting_all_Incoming_Email
[Dovecot]: http://www.dovecot.org/
[Encrypt specific incoming emails using Dovecot and Sieve]: https://perot.me/encrypt-specific-incoming-emails-using-dovecot-and-sieve
[Mike Cardwell]: https://grepular.com/
[gpgit.pl]: https://github.com/mikecardwell/gpgit/blob/master/gpgit.pl
[PunchiePets on DSLReports]: https://secure.dslreports.com/forum/r26276347-
[Olivier Berger]: https://github.com/olberger
[Etienne Perot]: https://perot.me/
[original version of encmaildir.sh]: https://github.com/olberger/gpgit/blob/master/encmaildir.sh