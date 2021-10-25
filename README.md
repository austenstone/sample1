# Sync Multiple Repositories

This is a demonstration on how to synchronize multiple repositories.

See the script [`sync.sh`](https://github.com/astone2014/sample1/blob/main/sync.sh) which synchronizes two repositories [sample1](https://github.com/astone2014/sample1) and [sample2](https://github.com/astone2014/sample2).

## Setup

Clone the primary repo.
```sh
git clone https://github.com/astone2014/sample1.git
```

## Pushing
Now run `git remote set-url --add –push` for each repository you’d like to push to. (`git remote set-url --add --push` overrides the default URL for pushes, so you must run this command twice, as demonstrated).
```sh
git remote set-url --add --push origin git@github.com:astone2014/sample1.git
git remote set-url --add --push origin git@github.com:astone2014/sample2.git
```

Show verbose remote output. 
The output should contain two push urls and one fetch.
```sh
$ git remote -v
origin  https://github.com/astone2014/sample1.git (fetch)
origin  https://github.com/astone2014/sample1.git (push)
origin  https://github.com/astone2014/sample2.git (push)
```

`git push` will now push two remote repositories simultaneously.
You will get 2 outputs, 1 for each repository.
```sh
$ git push origin main
Everything up-to-date
Everything up-to-date
```

You can now push to as many repos as you'd like following this process!

## Pulling
The problem with the solution is not pushing but pulling. You cannot pull from multiple remotes simultaneously. You can however fetch from multiple remotes.

Add each repo you'd like to sync with as a separate remote.
```sh
git remote add sample1 git@github.com:astone2014/sample1.git
git remote add sample2 git@github.com:astone2014/sample2.git
```

Now you can fetch from all remotes with one command.
```sh
git fetch --all
```

Once you've done a fetch you can sync the repositories by merging or rebasing them with your local changes.
```sh
git merge origin/main sample1/main sample2/main
git push origin main
```

## 🚀 GitHub Actions
You can use [github actions](https://docs.github.com/en/actions/quickstart) to automate this process. If this is your first time creating an action I suggest reading [Understanding GitHub Actions](https://docs.github.com/en/actions/learn-github-actions/understanding-github-actions) to learn the basics.


### Setup
Create a [`.github/workflows/blank.yml`](https://github.com/astone2014/sample1/blob/main/.github/workflows/blank.yml) file in your workspace and open it up.

Name your workflow at the top of the file.
```yml
name: Sync Repos
```

### Event
Then set the event that will trigger the workflow. I run the workflow every 10 minutes, on push to main, or on pull request to main. `workflow_dispatch` lets us manually trigger the workflow.
```yml
on:
  schedule:
    - cron:  '*/10 * * * *'
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:
```

### Job
Finally the job is where we run our code. 
* [`runs-on`](https://docs.github.com/en/actions/learn-github-actions/workflow-syntax-for-github-actions#jobsjob_idruns-on) tells us which machine to run on.
* [`uses`](https://docs.github.com/en/actions/learn-github-actions/workflow-syntax-for-github-actions#jobsjob_idstepsuses) selects an action to run as part of the step.
* [`with`](https://docs.github.com/en/actions/learn-github-actions/workflow-syntax-for-github-actions#jobsjob_idstepswith) allows you to map input parameters to actions.
* [`run`](https://docs.github.com/en/actions/learn-github-actions/workflow-syntax-for-github-actions#jobsjob_idstepsrun) actually runs a program on the machines command line.
```yml
jobs:
  sync-repos:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v2
        with:
          fetch-depth: 0
          persist-credentials: false
  
      - uses: webfactory/ssh-agent@v0.5.3
        with:
          ssh-private-key: |
            ${{ secrets.DESTINATION_SSH_PRIVATE_KEY }}
          # ...Add any private keys necessary to access repos.

      - name: Sync Script
        run: ./sync.sh
```
Let me break this job down...
#### Checkout
We use GitHub's checkout action with the [`fetch-depth: 0`](https://github.com/actions/checkout#usage) input to indicate all history for all branches and tags.

#### Repo Access
We use [`webfactory/ssh-agent@v0.5.3`](https://github.com/marketplace/actions/webfactory/ssh-agent) to configure the SSH for access to the other repository. You could use [SSH Keys](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) or [Personal Access Tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) to grant access.

In this example we [generated an SSH key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) and then we [add the SSH key to GitHub](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account). We utalize [GitHub Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets) to safely store our private key. The same process would work for any other git repository that supports SSH Keys.

| :exclamation: Please use [GitHub Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets) to store your SSH key!   |
|-----------------------------------------|

#### The Script
The script itself is exactly the same process described [above](https://github.com/astone2014/sample1#setup)!

## 🔮 Future Improvements
* Make this as a single GitHub action with a simple interface.
* Improve the script to be generic and take input.

## References
[rvl/git-pushing-multiple.rst](https://gist.github.com/rvl/c3f156e117e22a25f242)

[AWS - Push commits to an additional Git repository](https://docs.aws.amazon.com/codecommit/latest/userguide/how-to-mirror-repo-pushes.html)
