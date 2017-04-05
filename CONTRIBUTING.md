# Contributing

## Setup
Fork, then clone the repo:

```
git clone git@github.com:your-username/coyote.git
```

Push to your fork, refer to our issues, and submit a [pull request](https://github.com/coyote-team/coyote/compare) when you have changes rebased into a clean set of commits.

## Before you pull

No merge bubbles please. 

```
git pull --rebase
# or default your pull to use rebase instead of merge
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
The `master` branch is used for our auto-deploy process and should be deploy-ready. Substantial, feature-related changes should be made on a corresponding feature branch.  Commits should be rebased for conciseness and clarity before pull requests are made.
