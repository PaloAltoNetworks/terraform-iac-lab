# Contribution Guidelines

## Publish a new release (for maintainers)

This workflow requires node, npm, and semantic-release to be installed locally:

```
$ npm install -g semantic-release@^17.1.1 @semantic-release/git@^9.0.0 @semantic-release/exec@^5.0.0 conventional-changelog-conventionalcommits@^4.4.0
```

### Test the release process

Run `semantic-release` on develop:

```
semantic-release --dry-run --no-ci --branches=develop
```

Verify in the output that the next version is set correctly, and the release notes are generated correctly.

### Merge develop to master and push

```
git checkout master
git merge develop
git push origin master
```

At this point, GitHub Actions builds the final release.

### Merge master to develop and push

Now, sync develop to master to add the new commits made by the release bot.

```
git fetch --all --tags
git pull origin master
git checkout develop
git merge master
git push origin develop
```
