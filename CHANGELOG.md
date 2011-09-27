# CHANGELOG

# 0.2.3 (Sep 27 2011)

* Bugfix: The changelog file was missing the current release, it needs to include the tag that has not been added yet. The heroku_release:log was correct though. I considered removing the CHANGELOG file altogether to simplify things but I'm keeping it around since I like it (unfortunately the code is getting smelly now - refactoring needed).

# 0.2.2 (Sep 27 2011)

* Bugfix: the optional writing of the version file and updating of the changelog now happens before the tag is created. This makes sense of course since when you check out the tag you expect the changelog and version files to reflect the tag. Also, before this change, the release commit would commit the list you get when you do heroku_release:pending.

# 0.2.0 (Sep 23 2011)

* When doing a release, now instead of polluting the git log with two commits (for changelog and version file) we now do a single commit. We also make sure that commit has an informative comment containing the tag comment.
