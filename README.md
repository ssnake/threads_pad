# ThreadsPad

A helpful tool for paralleling and asynchronous processing for Rails

**Note!** It works with threads. Be aware thatnot all ruby intreperters fully support threads. 

##[Demo](https://tpd-demo.herokuapp.com/) (JRuby)

## Installation


Add this line to your application's Gemfile:

    gem "threads_pad", github: "ssnake/threads_pad"'

And then execute:

    $ bundle

You have to generate migrations:

    rails generate threads_pad install

Console outputs should look like this:
    
    create  db/migrate/20160222142854_create_threads_pad_jobs.rb
    create  db/migrate/20160222142855_create_threads_pad_job_logs.rb

Let's rake it:

    rake db:migrate


These migrations will create two tables:

* threads_pad_jobs - it will contain all meta data for your job like: current, min, max, started, destroy_on_finish etc
* threads_pad_job_logs - it will contain all logs are connected to your job.


## Getting started

Let's say we need to parse a csv file(demo.csv). To make it faster we can devide parsing process. We will run a few worker and each of them will parse its own range in a file.

First of all you have to create a class with base class *ThreadsPad::Job*  and define *work* method. This method will be run in *Thread*

    class CsvParsingJob << ThreadsPad::Job
      def initialize filename, start_row, count
        self.max = count
        @start_row = start_row
        ...
      end
      
      def work
        ...
        while self.current < @start_row + self.max do
            #parsing
            ....
            break if self.terminated?
            self.current += 1
        end
        ...
      end
    end
    
Base class *ThreadsPad::Job* has following methods:

* #max - specifies max position of the progress 
* #min - specifies min position of then progress 
* #current - specifies current position of the progress 
* #terminated? - check if a job is terminated
* #debug(msg) - log a msg

Ok, now it's time to run a job. Let's say our *demo.csv* has 10000 lines.

    pad = ThreadsPad::Pad.new
    pad << YourJob.new 'demo.csv', 1, 5000
    pad << YourJob.new 'demo.csv', 5001, 5000
    @job_id = pad.start


Once we memorize *@job_id* we can use it to check status of parsing process:

    pad = ThreadsPad::Pad.new @job_id
    puts 'The file has parsed' if @pad.done?
    
The *ThreadsPad::Pad* class has following methods:

* #current - get a current position of the progress 
* #done? - check if a process is finished/terminated or dead
* #log - log a msg
* #logs - get logs for a current job
* #terminate - terminate a current job
* ::terminate - terminate all jobs which are in database
* #destroy_all - remove from db all records that belongs to a current job. If a job is not finished yet, it will be marked as *destroy_on_finish*. Once it get finished it will destroy itself.


### Getting a status

Let's say we have *status* method in our rails controller and we have a html page that periodically call *status* method via *xhr*. The coffee script file might look like this:

    $('#percents').html("<%= @pad.current%>")
    <% if @pad.done? %>
        <% @pad.log "Done at #{Time.now}"%>
    <% end %>
    <% filter_job_logs(@pad.logs).each do |log|%>
    	$('#logs').append("<%= "#{log[:id]}\t#{log[:msg]}\<br\>".html_safe %>")
    <%end%>
    <% if @pad.done? %>
    	#disable timer
    	...
    <%end%>

*@pad.logs* is collection of objects *ThreadsPad::JobReflectionLog*(with ancestor as *ActiveRecord::Base*). This object has following fields:

* level - specifies importance of msg
* msg -  message itself
* group_id - specifies to which job it belongs (in our case it's *@job_id*)

*filter_job_logs* is a view helper. It prevents from getting logs into html page more then one. 

**Important!** 
It works with rails *session*. So you must specify *csrf* in your ajax request. In other case your page will be flooded with logs:
    
    $.ajax({
		url:"/main/status",
		dataType: 'script'
		settings: 
			beforeSend: (xhr)->
	    		xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
		})

