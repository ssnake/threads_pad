# ThreadsPad

A helpful tool for paralleling and asynchronous processing for Rails .

## Installation


Add this line to your application's Gemfile:

    gem "threads_pad", github: "ssnake/threads_pad"'

And then execute:

    $ bundle

Then, you have to generate migrations:

    rails generate threads_pad install

Console outputs should look like this:
    
    create  db/migrate/20160222142854_create_threads_pad_jobs.rb
    create  db/migrate/20160222142855_create_threads_pad_job_logs.rb

Let's rake it:

    rake db:migrate


These migrations will create two tables:

* threads_pad_jobs - it will contains all meta data for your job like: current, min, max, started, destroy_on_finish etc
* threads_pad_job_logs - it will contains all logs are connected to your job.
