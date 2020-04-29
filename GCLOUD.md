# Deployment to Google Cloud

We deploy this project to Google Cloud. It follows these steps:

1. Pushing to a branch runs CI. If CI passes and the branch is up-to-date with master, you're able to merge your PR.
2. Merging with, or pushing to, master creates a job in Google Cloud Build. This follows the steps in `cloudbuild.yaml`, namely:
  1. Fetch secrets from the Google Cloud Secrets store
  2. Build a Docker image with the secrets passed in as a `build-arg`
  3. Push the Docker image up to Google Container Service
  4. Deploy the new image to the Google Run service named "coyote"

The above documented workflow is orchestrated through the following Google Cloud services:

1. Cloud Build (triggers builds from Github)
2. Secrets Manager (imports cryptographic keys into the build process)
3. Cloud Run (runs new images)
4. Cloud SQL (provides access to the the PostgreSQL server)
5. Cloud Logging (provides logs for Cloud Run services)
6. Cloud Storage (used for file uploads)
7. Cloud Tasks (used for asynchronous job processing)

## Automating it

**The simplest and fastest way to get set up** is to run `./bin/gcp_setup ENVIRONMENT` where ENVIRONMENT is either `production` or `staging`. It will create, configure, and deploy the app for you to GCP.

You can also follow the manual steps below to do it all by hand, in case you dislike happiness.

## Step 1: Ensure the person setting it up has the correct roles

As such, you will need a Google Cloud project and a user with either `roles/editor` OR the following IAM roles:

- `roles/cloudbuild.builds.builder` (to set up a Cloud Build trigger)
- `roles/cloudsql.admin` (to set up a SQL instance)
- `roles/iam.serviceAccountAdmin` (to set up a service account with the correct permissions)
- `roles/run.admin` (to set up a Cloud Run server)
- `roles/secretmanager.admin` (to set up secrets for the build process)
- `roles/serviceusage.serviceUsageAdmin` (to enable APIs)
- `roles/storage.admin` (to set up a storage bucket)
- `roles/appengine.appAdmin` (to set up an App Engine app [temporarily] in order to run Cloud Tasks)

In order to grant those to someone, you'd run something like

```
gcloud projects add-iam-policy-binding [PROJECT_ID] --member user:[EMAIL] --role roles/cloudbuild.builds.builder
gcloud projects add-iam-policy-binding [PROJECT_ID] --member user:[EMAIL] --role roles/cloudsql.admin
gcloud projects add-iam-policy-binding [PROJECT_ID] --member user:[EMAIL] --role roles/iam.serviceAccountAdmin
gcloud projects add-iam-policy-binding [PROJECT_ID] --member user:[EMAIL] --role roles/run.admin
gcloud projects add-iam-policy-binding [PROJECT_ID] --member user:[EMAIL] --role roles/secretmanager.admin
gcloud projects add-iam-policy-binding [PROJECT_ID] --member user:[EMAIL] --role roles/serviceusage.serviceUsageAdmin
gcloud projects add-iam-policy-binding [PROJECT_ID] --member user:[EMAIL] --role roles/storage.admin
```

## Step 2: Enable the APIs

You'll want to switch on the needed APIs in order to deploy:

```
gcloud services enable --project [PROJECT_ID] cloudbuild.googleapis.com secretmanager.googleapis.com run.googleapis.com
```

## Step 3: Set up the SQL instance

You need a Cloud SQL instance to continue. It's simple to set one up:

```
gcloud sql instances create coyote --database-version=POSTGRES_11 --tier db-g1-small --region="us-east1"
```

Voila!

## Step 4: Configure secrets for the build

The build needs encryption keys, a DATABASE_URL, and a MAILER_PASSWORD in order to function. The easiest way to configure this stuff is to add the contents of `master.key`, `production.key` and `staging.key` to the secrets vault as `RAILS_BASE_KEY`, `RAILS_MASTER_KEY`, and `RAILS_STAGING_KEY` respectively:

```
cat config/master.key | gcloud secrets create RAILS_BASE_KEY --replication-policy="automatic" --data-file=-
cat config/credentials/production.key | gcloud secrets create RAILS_MASTER_KEY --replication-policy="automatic" --data-file=-
cat config/credentials/staging.key | gcloud secrets create RAILS_STAGING_KEY --replication-policy="automatic" --data-file=-
```

You'll also want to add your SMTP password like so:

```
echo "YOUR_SMTP_PASSWORD" | gcloud secrets create MAILER_PASSWORD --replication-policy="automatic" --data-file=-
```

## Step 5: Set up the storage bucket

You need a bucket to store file uploads. The `storage.yml` file defaults to `teamcoyote-uploads-#{RAILS_ENV}`.

```
gsutil mb gs://teamcoyote-uploads-staging/ -p [PROJECT_ID] -l us-east1
```

## Step 6: Set up the Cloudtasker queue

Since the project uses Cloudtasker (which is Sidekiq but on Google Cloud Tasks via Google PubSub), you'll need to have an App Engine app set up. You don't need to deploy anything; it's just a prerequisite to getting Cloud Tasks running. Be sure to create it in the same region you want the rest of the app to be located in. Once you have that, you can create the queue like so:

```
RAILS_ENV=production rails cloudtasker:setup_queue
```

For staging, you should add a `STAGING=1` flag, e.g.

```
RAILS_ENV=production STAGING=1 rails cloudtasker:setup_queue
```

## Step 7: Create a cloud build trigger

1. Connect Cloud Build to Github: https://cloud.google.com/cloud-build/docs/running-builds/create-manage-triggers#connecting_to_source_repositories
2. Create a trigger. Here's an example of creating a trigger to deploy the `master` branch to a staging environment:
  ```
  gcloud beta builds triggers create github \
    --project=[PROJECT_ID]
    --repo-owner=coyote-team \
    --repo-name=coyote \
    --branch-pattern="^master$" \
    --build-config=cloudbuild.yaml \
    --description="Deploy master to staging"
  ```

## Step 8: Deploy

Conveniently enough, the Cloud Build process will AUTOMATICALLY create a Cloud Run service named "coyote" that runs on the coyote image it builds. As long as you have created a Cloud Build trigger and a service user with permissions to deploy to Cloud Run, you should be good to go: just trigger a build

```
gcloud build submit
```
