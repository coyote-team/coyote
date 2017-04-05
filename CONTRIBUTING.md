# Contributing

## Setup
Fork, then clone the repo:

```
git clone git@github.com:your-username/coyote.git
```

Push to your fork, refer to our issues, and submit a [pull request](https://github.com/coyote-team/coyote/compare/develop...) to develop when you have changes rebased into a clean set of commits.

## Before you pull

No merge bubbles please. 

```
git pull --rebase
# or default rebase instead of merge
git config branch.autosetuprebase always # Force all new branches to automatically use rebase
git config branch.*branch-name*.rebase true # Force existing branches to use rebase.
```

## Before you push

Clean up your local commits.

```
git pull
git rebase -i
git push
```


## Making changes
The `master` branch is used for our auto-deploy process and should be deploy-ready. Minor changes should target or be made on the `develop` branch. Substantial, feature-related changes should be made on a corresponding feature branch based off of `develop` branch.  Commits should be rebased for conciseness and clarity before pull requests are made and within the `develop` branch and feature branches.

Changes are merged into `master` with a sauash:

```
git merge --squash develop
```
